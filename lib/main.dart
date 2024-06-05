import 'dart:io';
import 'package:NonebotGUI/darts/global.dart';
import 'package:NonebotGUI/darts/utils.dart';
import 'dart:convert';
import 'package:NonebotGUI/ui/createbot.dart';
import 'package:NonebotGUI/ui/import_bot.dart';
import 'package:NonebotGUI/ui/settings/more_page.dart';
import 'package:NonebotGUI/ui/manage_bot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:http/http.dart' as http;


void main() async{
  userDir = await createMainFolder();
  runApp(
    MaterialApp(
      home: const HomeScreen(),
      theme: _getTheme(userColorMode(userDir)),
    ),
  );
}

///颜色主题
ThemeData _getTheme(mode) {
  switch (mode) {
    case 'light':
      return ThemeData.light().copyWith(
        primaryColor: const Color.fromRGBO(238, 109, 109, 1),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color.fromRGBO(238, 109, 109, 1),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return const Color.fromRGBO(238, 109, 109, 1);
            }
            return Colors.white;
          }),
          checkColor: MaterialStateProperty.all(Colors.white),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color.fromRGBO(238, 109, 109, 1)
        ),
        appBarTheme: const AppBarTheme(
          color: Color.fromRGBO(238, 109, 109, 1)
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(238, 109, 109, 1)
        ),
        switchTheme: const SwitchThemeData(
          trackColor: MaterialStatePropertyAll(Color.fromRGBO(238, 109, 109, 1))
        )
      );
    case 'dark':
      return ThemeData.dark().copyWith(
        primaryColor: const Color.fromRGBO(127, 86, 151, 1),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color.fromRGBO(127, 86, 151, 1),
        ),
        checkboxTheme: const CheckboxThemeData(
          checkColor: MaterialStatePropertyAll(Color.fromRGBO(127, 86, 151, 1),)
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color.fromRGBO(127, 86, 151, 1),
        ),
        appBarTheme: const AppBarTheme(
          color: Color.fromRGBO(127, 86, 151, 1),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(127, 86, 151, 1)
        ),
        switchTheme: const SwitchThemeData(
          trackColor: MaterialStatePropertyAll(Color.fromRGBO(127, 86, 151, 1))
        )
      );
    default:
      return ThemeData.light().copyWith(
        primaryColor: const Color.fromRGBO(238, 109, 109, 1),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color.fromRGBO(238, 109, 109, 1)
        ),
        checkboxTheme: const CheckboxThemeData(
          checkColor: MaterialStatePropertyAll(Color.fromRGBO(238, 109, 109, 1))
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color.fromRGBO(238, 109, 109, 1)
        ),
        appBarTheme: const AppBarTheme(
          color: Color.fromRGBO(238, 109, 109, 1)
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(238, 109, 109, 1)
        ),
        switchTheme: const SwitchThemeData(
          trackColor: MaterialStatePropertyAll(Color.fromRGBO(238, 109, 109, 1))
        )
      );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String configFolder = '${createMainFolderBots(userDir)}';
  final String version = 'v0.1.8+fix1';

  @override
  void initState() {
    super.initState();
    refresh();
    check();
  }

  void refresh() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      _readConfigFiles();
      setState(() {
      });
    });
  }

  ///检查更新
  Future<void> check() async{
    //如果“检查更新”为开启则检查
    if (userCheckUpdate()){
        try {
          final response = await http.get(Uri.parse('https://api.github.com/repos/NonebotGUI/nonebot-flutter-gui/releases/latest'));
          if (response.statusCode == 200) {
              final jsonData = jsonDecode(response.body);
              final tagName = jsonData['tag_name']; 
              final changeLog = jsonData['body'];
              final url = jsonData['html_url'];
              if (tagName != version){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('发现新版本！'),
                duration: Duration(seconds: 3),
              ));
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('有新的版本：$tagName'),
                    content: Text(changeLog),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('复制url'),
                        onPressed: (){
                          Clipboard.setData(ClipboardData(text: url));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('已复制到剪贴板'),
                            duration: Duration(seconds: 3),
                          ));
                        },
                      ),
                      TextButton(
                        child: const Text('确定'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('检查更新失败（${response.statusCode}）'),
                duration: const Duration(seconds: 3),
              ));
            }
          } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('错误：$e'),
                duration: const Duration(seconds: 3),
              ));
          }
    }
  }

  List<String> configFileContentsName = [];
  List<String> configFileContentsPath = [];
  List<String> configFileContentsRun = [];
  List<String> configFileContentsTime = [];

  void _readConfigFiles() async {
    Directory directory = Directory(configFolder);
    List<FileSystemEntity> files = await directory.list().toList();

    configFileContentsName.clear();
    configFileContentsPath.clear();
    configFileContentsRun.clear();
    configFileContentsTime.clear();

    for (FileSystemEntity file in files) {
      if (file is File) {
        String content = await file.readAsString();
        Map<String, dynamic> jsonContent = json.decode(content);
        configFileContentsName.add(jsonContent['name']);
        configFileContentsPath.add(jsonContent['path']);
        configFileContentsRun.add(jsonContent['isrunning']);
        configFileContentsTime.add(jsonContent['time']);
      }
    }

    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NonebotGUI',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: '更多',
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const More();
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
            },
            tooltip: "刷新列表",
            color: Colors.white,
          ),
        ],
      ),
      body: configFileContentsName.isEmpty
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
              itemCount: configFileContentsName.length,
              itemBuilder: (context, index) {
                String name = configFileContentsName[index];
                String status = configFileContentsRun[index];
                String time = configFileContentsTime[index];
                String path = configFileContentsPath[index];
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
                        manageBotOnOpenCfg(userDir, name, time);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          createLog(path);
                          return const ManageBot();
                        }));
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.stop_rounded),
                        onPressed: (){
                          manageBotOnOpenCfg(userDir, name, time);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Bot已停止'),
                            duration: Duration(seconds: 3),
                          ));
                          setState(() {
                            stopBot(userDir);
                          });
                        },
                        tooltip: '停止Bot',
                      ),
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
                        manageBotOnOpenCfg(userDir, name, time);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          createLog(path);
                          return const ManageBot();
                        }));
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow_rounded),
                        onPressed: (){
                          manageBotOnOpenCfg(userDir, name, time);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Bot已启动'),
                            duration: Duration(seconds: 3),
                          ));
                          setState(() {
                            runBot(userDir,manageBotReadCfgPath(userDir));
                          });
                        },
                        tooltip: '运行Bot',
                      ),
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
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
