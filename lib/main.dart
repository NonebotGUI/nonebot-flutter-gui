import 'dart:io';
import 'package:NoneBotGUI/darts/global.dart';
import 'package:NoneBotGUI/darts/utils.dart';
import 'package:NoneBotGUI/ui/broadcast/list.dart';
import 'dart:convert';
import 'package:NoneBotGUI/ui/mainPage/createbot.dart';
import 'package:NoneBotGUI/ui/mainPage/fast_deploy.dart';
import 'package:NoneBotGUI/ui/mainPage/import_bot.dart';
import 'package:NoneBotGUI/ui/settings/about.dart';
import 'package:NoneBotGUI/ui/mainPage/manage_bot.dart';
import 'package:NoneBotGUI/ui/settings/setting.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';


void main() async {
  userDir = await createMainFolder();
  nbLog = '';
  barExtended = false;
  version = 'v0.2.0';
  WidgetsFlutterBinding.ensureInitialized();
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1280, 720);
    win.size = initialSize;
    win.minSize = const Size(100, 100);
    win.alignment = Alignment.center;
    win.title = 'NoneBot GUI';
    win.show();
  });
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

class _HomeScreenState extends State<HomeScreen> with TrayListener, WindowListener{
  Timer? _timer;
  final String configFolder = '${createMainFolderBots(userDir)}';


  @override
  void initState() {
    super.initState();
    check();
    refresh();
    _startRefreshing();
    _init();
    trayManager.addListener(this);
    windowManager.addListener(this);
  }



  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show') {
        windowManager.show();
    } else if (menuItem.key == 'exit') {
       exit(0);
    }
  }

  //初始化系统托盘
  Future<void> _init() async{
    await trayManager.setIcon(
      Platform.isWindows
        ? 'lib/assets/iconWin.ico'
        : 'lib/assets/icon.png',
    );
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'show',
          label: '显示主窗口',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit',
          label: '退出',
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
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


  @override
  void onWindowFocus() {

    setState(() {});
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
  String _appBarTitle = 'NoneBot GUI';



  @override
  void dispose() {
    trayManager.removeListener(this);
    trayManager.destroy();
    windowManager.removeListener(this);
    super.dispose();
  }


  //主窗口
  //为了某用户我重写了整个窗口😭😭😭
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Row(
          children: [
            Expanded(
              child: MoveWindow(
                child: AppBar(
                  title: Text(
                    _appBarTitle,
                    style: const TextStyle(
                      color: Colors.white
                    ),
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.remove_rounded),
                      color: Colors.white,
                      onPressed: () => appWindow.minimize(),
                      iconSize: 20,
                      tooltip: "最小化",
                    ),
                    appWindow.isMaximized ?
                      IconButton(
                        icon: const Icon(Icons.rectangle_outlined),
                        color: Colors.white,
                        onPressed: () => appWindow.restore(),
                        iconSize: 20,
                        tooltip: "恢复大小",
                      ) :
                    IconButton(
                        icon: const Icon(Icons.rectangle_outlined),
                        color: Colors.white,
                        onPressed: () => appWindow.maximize(),
                        iconSize: 20,
                        tooltip: "最大化",
                      ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: Colors.white,
                      onPressed: () => windowManager.hide(),
                      iconSize: 20,
                      tooltip: "关闭",
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Row(
        children: <Widget>[
          NavigationRail(
            indicatorColor: Colors.grey[50],
            selectedIconTheme: const IconThemeData(
              color: Color.fromRGBO(39, 32, 32, 1),
              size: 25
            ),
            unselectedIconTheme: const IconThemeData(
              size: 25
            ),
            elevation: 2,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
                _appBarTitle =
                  index == 0 ? 'NoneBot GUI' :
                  index == 1 ? manageBotReadCfgName(userDir) :
                  index == 2 ? '快速部署':
                  index == 3 ? '添加Bot' :
                  index == 4 ? '导入Bot':
                  index == 5 ? '公告':
                  index == 6 ? '设置':
                  index == 7 ? '关于NoneBot GUI':
                  index == 8 ? '开源许可证':
                  'Null';
              });
            },
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: IconButton(
                    icon: Icon(
                      barExtended ?
                        Icons.keyboard_arrow_left_rounded :
                        Icons.keyboard_arrow_right_rounded
                    ),
                    iconSize: 25,
                    tooltip: barExtended ? "收起" : "展开",
                    onPressed: () {
                      barExtended = !barExtended;
                      setState(() {
                      });
                    }
                  ),
                ),
              ),
            ),
            
            extended: barExtended,
            destinations: <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(
                  _selectedIndex == 0 ?
                    Icons.home_rounded :
                    Icons.home_outlined
                ),
                label: const Text('主页'),
              ),
              NavigationRailDestination(
                icon: Icon(
                  _selectedIndex == 1 ?
                    Icons.dashboard_rounded :
                    Icons.dashboard_outlined
                ),
                label: const Text('管理Bot'),
              ),
              NavigationRailDestination(
                icon: Icon(
                  _selectedIndex == 2 ?
                    Icons.archive_rounded :
                    Icons.archive_outlined
                ),
                label: const Text('快速部署'),
              ),
              NavigationRailDestination(
                icon: Icon(
                  _selectedIndex == 3 ?
                    Icons.add_rounded :
                    Icons.add_outlined
                ),
                label: const Text('添加Bot'),
              ),
              NavigationRailDestination(
                icon: Icon(
                  _selectedIndex == 4 ?
                    Icons.file_download_rounded :
                    Icons.file_download_outlined
                ),
                label: const Text('导入Bot'),
              ),
              NavigationRailDestination(
                icon: Icon(
                  _selectedIndex == 5 ?
                    Icons.messenger_rounded :
                    Icons.messenger_outline_rounded
                ),
                label: const Text('公告'),
              ),
              NavigationRailDestination(
                icon: Icon(
                  _selectedIndex == 6 ?
                    Icons.settings_rounded :
                    Icons.settings_outlined
                ),
                label: const Text('设置'),
              ),
              NavigationRailDestination(
                icon: Icon(
                  _selectedIndex == 7 ?
                    Icons.info_rounded :
                    Icons.info_outline_rounded
                ),
                label: const Text('关于'),
              ),
              NavigationRailDestination(
                icon: Icon(
                  _selectedIndex == 8 ?
                    Icons.balance_rounded :
                    Icons.balance_outlined
                ),
                label: const Text('开源许可证'),
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
                                  Text('还没有Bot,请使用侧边栏的“+”来创建'),
                                  SizedBox(height: 3),
                                  Text('如果你已经有了Bot,可以使用侧边栏的导入按钮导入'),
                                  SizedBox(height: 3),
                                ],
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.fromLTRB(32, 20, 32, 12),
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2,
                                  childAspectRatio: 6 / 1,
                                  mainAxisExtent: 110
                                ),
                                itemCount: configFileContentsName.length,
                                itemBuilder: (context, index) {
                                  String name = configFileContentsName[index];
                                  String status = configFileContentsRun[index];
                                  String time = configFileContentsTime[index];
                                  String path = configFileContentsPath[index];
                                  return Card(
                                    child: InkWell(
                                      onTap: () {
                                        manageBotOnOpenCfg(userDir, name, time);
                                        createLog(path);
                                        _loadFileContent();
                                        setState(() {
                                          _selectedIndex = 1;
                                          _appBarTitle = manageBotReadCfgName(userDir);
                                        });
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                child: status == "true"
                                                    ? IconButton(
                                                        icon: const Icon(Icons.stop_rounded),
                                                        onPressed: () {
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
                                                        onPressed: () {
                                                          manageBotOnOpenCfg(userDir, name, time);
                                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                            content: Text('Nonebot,启动！如果发现控制台无刷新请检查bot目录下的nbgui_stderr.log查看报错'),
                                                            duration: Duration(seconds: 3),
                                                          ));
                                                          setState(() {
                                                            runBot(userDir, manageBotReadCfgPath(userDir));
                                                          });
                                                        },
                                                        tooltip: '运行Bot',
                                                      ),
                                              ),
                                            ),
                                          ),
                                          // 运行状态显示在Card左下角
                                          const Spacer(),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8, bottom: 8),
                                            child: status == 'true'
                                                ? const Text(
                                                    "运行中",
                                                    style: TextStyle(color: Colors.green),
                                                  )
                                                : const Text("未运行"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
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
                const FastDeployList(),
                const CreateBot(),
                const ImportBot(),
                const BoradcastList(),
                const Settings(),
                const About(),
                LicensePage(
                        applicationIcon: Image.asset('lib/assets/logo.png'),
                        applicationName: 'NoneBotGUI',
                        applicationVersion: version.replaceAll('v', ''),
                        ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
