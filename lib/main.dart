import 'dart:io';
import 'package:NoneBotGUI/darts/global.dart';
import 'package:NoneBotGUI/darts/utils.dart';
import 'dart:convert';
import 'package:NoneBotGUI/ui/createbot.dart';
import 'package:NoneBotGUI/ui/import_bot.dart';
import 'package:NoneBotGUI/ui/settings/about.dart';
import 'package:NoneBotGUI/ui/manage_bot.dart';
import 'package:NoneBotGUI/ui/settings/setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() async {
  userDir = await createMainFolder();
  nbLog = '';
  version = 'v0.1.10';
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
        ),
      );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  final String configFolder = '${createMainFolderBots(userDir)}';

  @override
  void initState() {
    super.initState();
    check();
    refresh();
    _startRefreshing();
  }

  void refresh() {
    Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      _readConfigFiles();

    });
  }

  void _startRefreshing() {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _loadFileContent(),
    );
  }


  void _loadFileContent() async {
    String filePath = '${manageBotReadCfgPath(userDir)}/nbgui_stdout.log';
    File stdoutFile = File(filePath);
    if (stdoutFile.existsSync()) {
      try {
        File file = File(filePath);
        final lines = await file.readAsLines(encoding: systemEncoding);
        final last50Lines =
            lines.length > 50 ? lines.sublist(lines.length - 50) : lines;
          nbLog = last50Lines.join('\n');
          getPyPid(userDir);
      } catch (e) {
        print('Error: $e');
      }
    }
  }
  ///检查更新
  Future<void> check() async{
    //如果“检查更新”为开启则检查
    if (userCheckUpdate()){
        try {
          final response = await http.get(Uri.parse('https://api.github.com/repos/NoneBotGUI/nonebot-flutter-gui/releases/latest'));
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

  List<String> configFileContentsNameNew = [];
  List<String> configFileContentsPathNew = [];
  List<String> configFileContentsRunNew = [];
  List<String> configFileContentsTimeNew = [];



//byd我真是个天才🤓
  void _readConfigFiles() async {
    Directory directory = Directory(configFolder);
    List<FileSystemEntity> files = await directory.list().toList();
    configFileContentsNameNew.clear();
    configFileContentsPathNew.clear();
    configFileContentsRunNew.clear();
    configFileContentsTimeNew.clear();
    for (FileSystemEntity file in files) {
      if (file is File) {
        String content = await file.readAsString();
        Map<String, dynamic> jsonContent = json.decode(content);
        configFileContentsNameNew.add(jsonContent['name']);
        configFileContentsPathNew.add(jsonContent['path']);
        configFileContentsRunNew.add(jsonContent['isrunning']);
        configFileContentsTimeNew.add(jsonContent['time']);
      }
    }
    //判断新列表和旧列表是否一致
    if (configFileContentsNameNew != configFileContentsName &&
        configFileContentsPathNew != configFileContentsPath &&
        configFileContentsRunNew != configFileContentsRun &&
        configFileContentsTimeNew != configFileContentsTime)
        {
          //如果不一致则刷新UI
          configFileContentsName.clear();
          configFileContentsPath.clear();
          configFileContentsRun.clear();
          configFileContentsTime.clear();
          configFileContentsName = List.from(configFileContentsNameNew);
          configFileContentsPath = List.from(configFileContentsPathNew);
          configFileContentsRun = List.from(configFileContentsRunNew);
          configFileContentsTime = List.from(configFileContentsTimeNew);
          setState(() {
          });
        }

  }


  int _selectedIndex = 0;
  String _appBarTitle = 'Nonebot GUI';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle,style: const TextStyle(color: Colors.white),),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _readConfigFiles();
            },
            tooltip: "刷新列表",
            color: Colors.white,
          ),
        ]
      ),
      body: Row(
        children: <Widget>[
          NavigationRail(
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
                _appBarTitle =
                  index == 0 ? 'NoneBot GUI' :
                  index == 1 ? manageBotReadCfgName(userDir) :
                  index == 2 ? '添加bot' :
                  index == 3 ? '导入Bot':
                  index == 4 ? '公告':
                  index == 5 ? '设置':
                  index == 6 ? '关于Nonebot GUI':
                  index == 7 ? '开源许可证':
                  'Null';
              });
            },
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home_rounded),
                label: Text('主页'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_rounded),
                label: Text('管理Bot'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add_rounded),
                label: Text('添加bot'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.file_download_outlined),
                label: Text('导入Bot'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.messenger_outline_rounded),
                label: Text('公告'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_rounded),
                label: Text('设置'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info_outline_rounded),
                label: Text('关于'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.balance),
                label: Text('开源许可证'),
              ),
            ],
            selectedIndex: _selectedIndex,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                configFileContentsName.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('还没有Bot,侧边栏的“+”来创建'),
                                  SizedBox(height: 3),
                                  Text('如果你已经有了Bot,可以使用侧边栏的导入按钮导入'),
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
                                  return SingleChildScrollView(
                                      child: Card(
                                    child: ListTile(
                                      title: Text(name),
                                      subtitle:
                                        status == 'true' ?
                                          const Text(
                                            "运行中",
                                            style: TextStyle(color: Colors.green),
                                            )
                                          : const Text(
                                            "未运行"
                                          ),
                                      onTap: () {
                                        manageBotOnOpenCfg(userDir, name, time);
                                        createLog(path);
                                        _loadFileContent();
                                        setState(() {
                                          _selectedIndex = 1;
                                          _appBarTitle = manageBotReadCfgName(userDir);
                                        });
                                      },
                                      trailing:
                                        status == "true"
                                          ? IconButton(
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
                                            )
                                          : IconButton(
                                              icon: const Icon(Icons.play_arrow_rounded),
                                              onPressed: (){
                                                manageBotOnOpenCfg(userDir, name, time);
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                  content: Text('Nonebot,启动！如果发现控制台无刷新请检查bot目录下的nbgui_stderr.log查看报错'),
                                                  duration: Duration(seconds: 3),
                                                ));
                                                setState(() {
                                                  runBot(userDir,manageBotReadCfgPath(userDir));
                                                });
                                              },
                                              tooltip: '停止Bot',
                                            ),
                                    ),
                                  ));
                              },
                            ),
                File('$userDir/on_open.txt').existsSync()
                  ? const ManageBot()
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('lib/assets/loading.gif'),
                          const SizedBox(height: 10),
                          const Text('你还没有选择要打开的bot'),
                        ],
                      ),
                    ),
                const CreateBot(),
                const ImportBot(),
                const Settings(),
                const About(),
                LicensePage(
                        applicationIcon: Image.asset('lib/assets/logo.png'),
                        applicationName: 'NoneBotGUI',
                        applicationVersion: '0.1.9',
                        ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

