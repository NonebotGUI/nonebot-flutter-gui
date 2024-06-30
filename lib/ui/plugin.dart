import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:NoneBotGUI/darts/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:NoneBotGUI/assets/my_flutter_app_icons.dart';
import 'package:flutter/services.dart';
import 'package:NoneBotGUI/darts/utils.dart';

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
//       home: PluginStore(),
//     );
//   }
// }

class PluginStore extends StatefulWidget {
  const PluginStore({super.key});

  @override
  State<PluginStore> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<PluginStore> {
  final TextEditingController _searchController = TextEditingController();

  final pluginOutput = TextEditingController();
  final pluginOutputController = StreamController<String>.broadcast();
  void managePlugin(String manage, String name) async {
    pluginOutput.clear();
    List<String> commands = [manageCliPlugin(userDir, manage, name)];
    for (String command in commands) {
      List<String> args = command.split(' ');
      String executable = args.removeAt(0);
      Process process = await Process.start(
        executable,
        args,
        runInShell: true,
        workingDirectory: manageBotReadCfgPath(userDir),
      );
      process.stdout
          .transform(systemEncoding.decoder)
          .listen((data) => pluginOutputController.add(data));
      process.stderr
          .transform(systemEncoding.decoder)
          .listen((data) => pluginOutputController.add(data));
      await process.exitCode;
    }
  }

  @override
  void dispose() {
    pluginOutputController.close();
    super.dispose();
  }

  //初始化json列表
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> search = [];

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('https://registry.nonebot.dev/plugins.json'));
    if (response.statusCode == 200) {
      setState(() {
        String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = json.decode(decodedBody);
        data = jsonData.map((item) => item as Map<String, dynamic>).toList();
        search = data;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _install(name) async {
    managePlugin('install', name);
    setState(() {});
  }

  void _searchPlugins(value) => setState(() {
        //根据名字，描述等搜索
        search = data.where((plugin) {
          return plugin['name'].toLowerCase().contains(value.toLowerCase()) ||
              plugin['desc'].toLowerCase().contains(value.toLowerCase()) ||
              plugin['module_name'].toLowerCase().contains(value.toLowerCase()) ||
              plugin['author'].toLowerCase().contains(value.toLowerCase());
        }).toList();
      });

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
            hintText: '搜索插件...',
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: _searchPlugins,
        ),
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
              itemBuilder: (BuildContext context, int index) {
                final plugins = search[index];
                return InkWell(
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
                                  plugins['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(plugins['module_name']),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(plugins['desc']),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('By ${plugins['author']}'),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Flexible(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) =>
                                            installingPluginDialog(plugins),
                                      );
                                    },
                                    tooltip: '安装插件',
                                    icon: const Icon(Icons.download_rounded),
                                    iconSize: 25,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                          text: plugins['homepage']));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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

  Material installingPluginDialog(Map plugins) {
    String name = plugins['module_name'];
    _install(name);
    return Material(
      color: Colors.transparent,
      child: Center(
        child: AlertDialog(
          title: const Text('正在安装插件'),
          content: SizedBox(
            height: 600,
            width: 800,
            child: StreamBuilder<String>(
              stream: pluginOutputController.stream,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                return Card(
                  color: const Color.fromARGB(255, 31, 28, 28),
                  child: SingleChildScrollView(
                    child: StreamBuilder<String>(
                      stream: pluginOutputController.stream,
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          final newText =
                              pluginOutput.text + (snapshot.data ?? '');
                          pluginOutput.text = newText;
                        }
                        return Card(
                          color: const Color.fromARGB(255, 31, 28, 28),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                pluginOutput.text,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
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
                style: TextStyle(color: Colors.red[400]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
