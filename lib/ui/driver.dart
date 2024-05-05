import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Nonebot_GUI/assets/my_flutter_app_icons.dart';
import 'package:flutter/services.dart';
import 'package:Nonebot_GUI/darts/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DriverStore(),
    );
  }
}

class DriverStore extends StatefulWidget {
  const DriverStore({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<DriverStore> {
  final TextEditingController _searchController = TextEditingController();

  final driver_output = TextEditingController();
  final driverOutputController = StreamController<String>.broadcast();
  void manage_driver(String manage, String name) async {
    driver_output.clear();
    List<String> commands = [manage_cli_driver(manage, name)];
    for (String command in commands) {
      List<String> args = command.split(' ');
      String executable = args.removeAt(0);
      Process process = await Process.start(
        executable,
        args,
        runInShell: true,
        workingDirectory: manage_bot_readcfg_path(),
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
    final response = await http.get(Uri.parse('https://registry.nonebot.dev/drivers.json'));
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

    manage_driver('install', name); 
    setState(() {});

  }


  void _Searchdrivers(value) {
    setState(() {
      //根据名字，描述等搜索
      search = data.where((driver) {
        return driver['name'].toLowerCase().contains(value.toLowerCase()) ||
            driver['desc'].toLowerCase().contains(value.toLowerCase()) || 
            driver['module_name'].toLowerCase().contains(value.toLowerCase()) ||
            driver['author'].toLowerCase().contains(value.toLowerCase());
      }).toList();
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
          decoration: const InputDecoration(hintText: '搜索适配器...',hintStyle: TextStyle(color: Colors.white)),
          style: const TextStyle(color: Colors.white),
          onChanged: _Searchdrivers,
          
        ),
        backgroundColor: const Color.fromRGBO(238, 109, 109, 1),
      ),
      body: data.isEmpty
      ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('正在从Nonebot官网拉取驱动器列表...'),
            ],
          ),
        )
      : ListView.builder(
        itemCount: search.length,
        itemBuilder: (BuildContext context, int index) {
          final drivers = search[index];
          return InkWell(
            onTap: () {
            },
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
                          child: Text(drivers['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(drivers['module_name']),
                        ),
                        const SizedBox(height: 2,),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(drivers['desc']),
                        ),
                        const SizedBox(height: 2,),
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
                                  builder: (BuildContext context) {
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
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<String> snapshot) {
                                                return Card(
                                                  color: const Color.fromARGB(255, 31, 28, 28),
                                                  child: SingleChildScrollView(
                                                    child: StreamBuilder<String>(
                                                      stream: driverOutputController.stream,
                                                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                                        if (snapshot.hasData) {
                                                          final newText = driver_output.text + (snapshot.data ?? '');
                                                          driver_output.text = newText;
                                                        }
                                                        return Card(
                                                          color: const Color.fromARGB(255, 31, 28, 28),
                                                          child: SingleChildScrollView(
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Text(
                                                                driver_output.text,
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
                                  },
                                );
                              },
                              tooltip: '安装适配器',
                              icon: const Icon(Icons.download_rounded),
                              iconSize: 25,
                            ),
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: drivers['homepage']));
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
        },
      ),
    );
  }
}





