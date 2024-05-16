import 'dart:io';
import 'package:NonebotGUI/darts/utils.dart';
import 'dart:convert';
import 'package:NonebotGUI/ui/createbot.dart';
import 'package:NonebotGUI/ui/settings/more_page.dart';
import 'package:NonebotGUI/ui/manage_bot.dart';
import 'package:NonebotGUI/ui/import_bot.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      theme: _getTheme(userColorMode()),
    );
  }
}


  ThemeData _getTheme(mode) {
    switch (mode) {
      case 'light':
        return ThemeData.light();
      case 'dark':
        return ThemeData.dark();
      default:
        return ThemeData.light();
    }
  }



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String configFolder = '${createMainFolderBots()}';

  @override
  void initState() {
    super.initState();
    createMainFolder();
    refresh();
    _getTheme(userColorMode());
  }

  void refresh() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _readConfigFiles();
      setState(() {
        _getTheme(userColorMode());
      });
    });
  }

  List<String> configFileContents_name = [];
  List<String> configFileContents_path = [];
  List<String> configFileContents_run = [];
  List<String> configFileContents_time = [];

  void _readConfigFiles() async {
    Directory directory = Directory(configFolder);
    List<FileSystemEntity> files = await directory.list().toList();

    configFileContents_name.clear();
    configFileContents_path.clear();
    configFileContents_run.clear();
    configFileContents_time.clear();

    for (FileSystemEntity file in files) {
      if (file is File) {
        String content = await file.readAsString();
        Map<String, dynamic> jsonContent = json.decode(content);
        configFileContents_name.add(jsonContent['name']);
        configFileContents_path.add(jsonContent['path']);
        configFileContents_run.add(jsonContent['isrunning']);
        configFileContents_time.add(jsonContent['time']);
      }
    }

    setState(() {
      _getTheme(userColorMode());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nonebot GUI',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: userColorMode() == 'light'
          ? const Color.fromRGBO(238, 109, 109, 1)
          : const Color.fromRGBO(127, 86, 151, 1),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: '更多',
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return more();
            }));
          
          },
          color: Colors.white,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const ImportBot();
              }));
            },
            tooltip: "从已有的Bot中导入",
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _readConfigFiles();
              createMainFolder();
            },
            tooltip: "刷新列表",
            color: Colors.white,
          ),
        ],
      ),
      body: configFileContents_name.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('还没有Bot,点击右下角的“+”来创建'),
                  SizedBox(height: 3),
                  Text('如果你已经有了Bot,可以使用右上角的按钮导入'),
                  SizedBox(height: 3),
                  Text('如果创建后没有显示请点击右上角的按钮刷新列表'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: configFileContents_name.length,
              itemBuilder: (context, index) {
                String name = configFileContents_name[index];
                String status = configFileContents_run[index];
                String time = configFileContents_time[index];
                String path = configFileContents_path[index];
                if (status == 'true') {
                  return SingleChildScrollView(
                      child: Card(
                    child: ListTile(
                      title: Text(name),
                      subtitle: const Text(
                        "运行中",
                        style: TextStyle(color: Colors.green),
                      ),
                      onTap: () {
                        manageBotOnOpenCfg(name, time);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          createLog(path);
                          return const ManageBot();
                        }));
                      },
                      trailing: const Icon(Icons.menu),
                    ),
                  ));
                } else {
                  return SingleChildScrollView(
                      child: Card(
                    child: ListTile(
                      title: Text(name),
                      subtitle: const Text(
                        "未运行",
                      ),
                      onTap: () {
                        manageBotOnOpenCfg(name, time);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          createLog(path);
                          return const ManageBot();
                        }));
                      },
                      trailing: const Icon(Icons.menu),
                    ),
                  ));
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const CreateBot();
          }));
        },
        tooltip: '添加一个bot',
        backgroundColor: userColorMode() == 'light'
          ? const Color.fromRGBO(238, 109, 109, 1)
          : const Color.fromRGBO(127, 86, 151, 1),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

