import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:NonebotGUI/assets/my_flutter_app_icons.dart';
import 'package:flutter/services.dart';
import 'package:NonebotGUI/darts/utils.dart';

// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: DriverStore(),
//     );
//   }
// }

class DriverStore extends StatefulWidget {
  const DriverStore({super.key});

  @override
  State<DriverStore> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<DriverStore> {
  final TextEditingController _searchController = TextEditingController();

  final driverOutput = TextEditingController();
  final driverOutputController = StreamController<String>.broadcast();
  void manageDriver(String manage, String name) async {
    driverOutput.clear();
    List<String> commands = [manageCliDriver(manage, name)];
    for (String command in commands) {
      List<String> args = command.split(' ');
      String executable = args.removeAt(0);
      Process process = await Process.start(
        executable,
        args,
        runInShell: true,
        workingDirectory: manageBotReadCfgPath(),
      );
      process.stdout
          .transform(systemEncoding.decoder)
          .listen((data) => driverOutputController.add(data));
      process.stderr
          .transform(systemEncoding.decoder)
          .listen((data) => driverOutputController.add(data));
      await process.exitCode;
    }
  }

  @override
  void dispose() {
    driverOutputController.close();
    super.dispose();
  }

  //初始化json列表
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> search = [];

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('https://registry.nonebot.dev/drivers.json'));
    if (response.statusCode == 200) {
      setState(() {
        String decodedBody = systemEncoding.decode(response.bodyBytes);
        final List<dynamic> jsonData = json.decode(decodedBody);
        data = jsonData.map((item) => item as Map<String, dynamic>).toList();
        search = data;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _install(name) async {
    manageDriver('install', name);
    setState(() {});
  }

  void _searchDrivers(value) {
    setState(() {
      //根据名字，描述等搜索
      search = data
          .where(
            (driver) =>
                driver['name'].toLowerCase().contains(value.toLowerCase()) ||
                driver['desc'].toLowerCase().contains(value.toLowerCase()) ||
                driver['module_name']
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                driver['author'].toLowerCase().contains(value.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '搜索适配器...',
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: _searchDrivers,
        ),
        backgroundColor: userColorMode() == 'light'
            ? const Color.fromRGBO(238, 109, 109, 1)
            : const Color.fromRGBO(127, 86, 151, 1),
      ),
      body: data.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/assets/loading.gif'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: search.length,
              itemBuilder: (BuildContext context, int index) =>
                  driverList(search[index]),
            ),
    );
  }

  InkWell driverList(drivers) => InkWell(
        onTap: () {},
        child: Card(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        drivers['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(drivers['module_name']),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(drivers['desc']),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('By ${drivers['author']}'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) =>
                                  driverInstall(drivers),
                            );
                          },
                          tooltip: '安装适配器',
                          icon: const Icon(Icons.download_rounded),
                          iconSize: 25,
                        ),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: drivers['homepage']));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('项目仓库链接已复制到剪贴板'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                          tooltip: '复制仓库地址',
                          icon: const Icon(MyFlutterApp.github),
                          iconSize: 25,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Material driverInstall(drivers) {
    String name = drivers['module_name'];
    _install(name);
    return Material(
      color: Colors.transparent,
      child: Center(
        child: AlertDialog(
          title: const Text('正在安装适配器'),
          content: SizedBox(
            height: 600,
            width: 800,
            child: StreamBuilder<String>(
              stream: driverOutputController.stream,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                return Card(
                  color: const Color.fromARGB(255, 31, 28, 28),
                  child: SingleChildScrollView(
                    child: StreamBuilder<String>(
                      stream: driverOutputController.stream,
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<String> snapshot,
                      ) {
                        if (snapshot.hasData) {
                          driverOutput.text =
                              driverOutput.text + (snapshot.data ?? '');
                        }
                        return Card(
                          color: const Color.fromARGB(255, 31, 28, 28),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                driverOutput.text,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                '关闭窗口',
                style: TextStyle(color: Colors.grey[800]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
