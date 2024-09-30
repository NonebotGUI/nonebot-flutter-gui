import 'dart:io';
import 'package:NoneBotGUI/utils/global.dart';
import 'package:NoneBotGUI/ui/broadcast/list.dart';
import 'package:NoneBotGUI/ui/deploy/deploy.dart';
import 'package:NoneBotGUI/ui/deploy/deployment.dart';
import 'dart:convert';
import 'package:NoneBotGUI/ui/mainPage/createbot.dart';
import 'package:NoneBotGUI/ui/mainPage/fast_deploy.dart';
import 'package:NoneBotGUI/ui/mainPage/import_bot.dart';
import 'package:NoneBotGUI/ui/manage/manage_protocol.dart';
import 'package:NoneBotGUI/ui/settings/about.dart';
import 'package:NoneBotGUI/ui/mainPage/manage_bot.dart';
import 'package:NoneBotGUI/ui/settings/setting.dart';
import 'package:NoneBotGUI/utils/core.dart';
import 'package:NoneBotGUI/utils/manage.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:watcher/watcher.dart';
import 'package:NoneBotGUI/utils/userConfig.dart';

void main() async {
  //初始化程序
  //令人难以理解（
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  userDir = await nbguiInit();
  FastDeploy.page = 0;
  MainApp.nbLog = '[INFO]Welcome to NoneBot GUI!';
  MainApp.protocolLog = '[INFO]Welcome to NoneBot GUI!';
  MainApp.barExtended = false;
  MainApp.version = 'v1.0.0';
  // FlutterError.onError = (FlutterErrorDetails details) async {
  //   DateTime now = DateTime.now();
  //   String timestamp = now.toIso8601String();
  //   String errorMessage = '[ERROR]$timestamp -${details.exception.toString()}\n\n';
  //   final errorFile = File('$userDir/error.log');
  //   await errorFile.writeAsString(errorMessage, mode: FileMode.append);
  // };
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 730),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(
    MaterialApp(
      home: const HomeScreen(),
      theme: _getTheme(UserConfig.colorMode()),
    ),
  );
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1280, 730);
    win.size = initialSize;
    win.minSize = initialSize;
    win.alignment = Alignment.center;
    win.title = 'NoneBot GUI';
    win.show();
  });
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
            fillColor:
                MaterialStateProperty.resolveWith((Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return const Color.fromRGBO(238, 109, 109, 1);
              }
              return Colors.white;
            }),
            checkColor: MaterialStateProperty.all(Colors.white),
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: Color.fromRGBO(238, 109, 109, 1)),
          appBarTheme:
              const AppBarTheme(color: Color.fromRGBO(238, 109, 109, 1)),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color.fromRGBO(238, 109, 109, 1)),
          switchTheme: const SwitchThemeData(
              trackColor:
                  MaterialStatePropertyAll(Color.fromRGBO(238, 109, 109, 1))));
    case 'dark':
      return ThemeData.dark().copyWith(
          primaryColor: const Color.fromRGBO(127, 86, 151, 1),
          buttonTheme: const ButtonThemeData(
            buttonColor: Color.fromRGBO(127, 86, 151, 1),
          ),
          checkboxTheme: const CheckboxThemeData(
              checkColor: MaterialStatePropertyAll(
            Color.fromRGBO(127, 86, 151, 1),
          )),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Color.fromRGBO(127, 86, 151, 1),
          ),
          appBarTheme: const AppBarTheme(
            color: Color.fromRGBO(127, 86, 151, 1),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color.fromRGBO(127, 86, 151, 1)),
          switchTheme: const SwitchThemeData(
              trackColor:
                  MaterialStatePropertyAll(Color.fromRGBO(127, 86, 151, 1))));
    default:
      return ThemeData.light().copyWith(
        primaryColor: const Color.fromRGBO(238, 109, 109, 1),
        buttonTheme: const ButtonThemeData(
            buttonColor: Color.fromRGBO(238, 109, 109, 1)),
        checkboxTheme: const CheckboxThemeData(
            checkColor:
                MaterialStatePropertyAll(Color.fromRGBO(238, 109, 109, 1))),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Color.fromRGBO(238, 109, 109, 1)),
        appBarTheme: const AppBarTheme(color: Color.fromRGBO(238, 109, 109, 1)),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color.fromRGBO(238, 109, 109, 1)),
        switchTheme: const SwitchThemeData(
            trackColor:
                MaterialStatePropertyAll(Color.fromRGBO(238, 109, 109, 1))),
      );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TrayListener, WindowListener {
  Timer? _timer;
  final String configFolder = '$userDir/bots';
  final colorMode = UserConfig.colorMode();
  StreamSubscription<WatchEvent>? _subscription;
  List<String> _events = [];
  final String directoryPath = "$userDir/bots";
  final TrayManager _trayManager = TrayManager.instance;

  @override
  void initState() {
    super.initState();
    _startWatching();
    _readConfigFiles().then((_) {
      setState(() {});
    });
    check();
    _startRefreshing();
    deployPageListener();
    _init();
    _trayManager.addListener(this);
    windowManager.addListener(this);
    stateInit();
    alwaysRefresh();
    refresh();
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
  Future<void> _init() async {
    await _trayManager.setIcon(
      Platform.isWindows ? 'lib/assets/iconWin.ico' : 'lib/assets/icon.png',
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
    await _trayManager.setContextMenu(menu);
  }

  @override
  //右键打开托盘菜单
  void onTrayIconRightMouseDown() {
    _trayManager.popUpContextMenu();
  }

  void refresh() async {
    setState(() {
      _readConfigFiles();
    });
  }

  void stateInit() async {
    Future.delayed(const Duration(seconds: 1));
    refresh();
  }

  //使用Watcher监听目录
  void _startWatching() async {
    if (UserConfig.refreshMode() == 'auto') {
      final watcher = DirectoryWatcher(directoryPath);
      _subscription = watcher.events.listen((event) {
        _readConfigFiles();
        setState(() {});
      });
    }
  }

  void alwaysRefresh() {
    if (UserConfig.refreshMode() == 'always') {
      if (_timer != null) {
        _timer?.cancel();
      }
      _timer = Timer.periodic(const Duration(microseconds: 1500), (timer) {
        _readConfigFiles();
        setState(() {});
      });
    }
  }

  //监听bot Log
  void logListener() async {
    if (gOnOpen.isNotEmpty) {
      final logWatcher = DirectoryWatcher(Bot.path());
      _subscription = logWatcher.events.listen((event) async {
        if (event.path == '${Bot.path()}/nbgui_stdout.log' &&
            event.type == ChangeType.MODIFY) {
          loadFileContent();
        }
      });
    }
  }

  void _startRefreshing() {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (_selectedIndex == 1 || _selectedIndex == 2) {
        loadFileContent();
        loadProtocolFileContent();
        setState(() {});
      }
    });
  }

  //监听deployPage
  void deployPageListener() {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) {
        if (_selectedIndex == 3) {
          setState(() {});
        }
      },
    );
  }

  void loadFileContent() async {
    if (gOnOpen.isNotEmpty) {
      String filePath = '${Bot.path()}/nbgui_stdout.log';
      File stdoutFile = File(filePath);
      if (stdoutFile.existsSync()) {
        try {
          File file = File(filePath);
          final lines =
              await file.readAsLines(encoding: UserConfig.botEncoding());
          final last50Lines =
              lines.length > 250 ? lines.sublist(lines.length - 250) : lines;
          MainApp.nbLog = last50Lines.join('\n');
          setState(() {});
        } catch (e) {
          print('Error: $e');
        }
      }
    }
  }

  void loadProtocolFileContent() async {
    if (gOnOpen.isNotEmpty) {
      String filePath = '${Protocol.path()}/nbgui_stdout.log';
      File stdoutFile = File(filePath);
      if (stdoutFile.existsSync()) {
        try {
          File file = File(filePath);
          final lines =
              await file.readAsLines(encoding: UserConfig.protocolEncoding());
          final last50Lines =
              lines.length > 250 ? lines.sublist(lines.length - 250) : lines;
          MainApp.protocolLog = last50Lines.join('\n');
          setState(() {});
        } catch (e) {
          print('Error: $e');
        }
      }
    }
  }

  ///检查更新
  Future<void> check() async {
    //如果“检查更新”为开启则检查
    if (UserConfig.checkUpdate()) {
      try {
        final response = await http.get(Uri.parse(
            'https://api.github.com/repos/NoneBotGUI/nonebot-flutter-gui/releases/latest'));
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          final tagName = jsonData['tag_name'];
          final changeLog = jsonData['body'];
          final url = jsonData['html_url'];
          if (tagName != MainApp.version) {
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
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: url));
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
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

//byd我真是个天才🤓
  Future<void> _readConfigFiles() async {
    Directory directory = Directory(configFolder);
    List<FileSystemEntity> files = await directory.list().toList();
    configFileContentsName.clear();
    configFileContentsPath.clear();
    configFileContentsRun.clear();
    configFileContentsTime.clear();
    for (FileSystemEntity file in files) {
      if (file is File) {
        String content = file.readAsStringSync();
        Map<String, dynamic> jsonContent = json.decode(content);
        configFileContentsName.add(jsonContent['name']);
        configFileContentsPath.add(jsonContent['path']);
        configFileContentsRun.add(jsonContent['isrunning']);
        configFileContentsTime.add(jsonContent['time']);
        botList = List.generate(
          configFileContentsName.length,
          (i) => '${configFileContentsName[i]}.${configFileContentsTime[i]}',
        );
      }
    }
  }

  int _selectedIndex = 0;
  String _appBarTitle = 'NoneBot GUI';

  @override
  void dispose() {
    _trayManager.removeListener(this);
    _trayManager.destroy();
    windowManager.removeListener(this);
    super.dispose();
  }

  //主窗口
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
                    style: const TextStyle(color: Colors.white),
                  ),
                  actions: <Widget>[
                    (_selectedIndex == 0)
                        ? IconButton(
                            icon: const Icon(Icons.refresh_rounded),
                            color: Colors.white,
                            onPressed: () {
                              setState(() {
                                _readConfigFiles();
                                // print(botList);
                              });
                            },
                            iconSize: 20,
                            tooltip: "手动刷新",
                          )
                        : const SizedBox(),
                    IconButton(
                      icon: const Icon(Icons.remove_rounded),
                      color: Colors.white,
                      onPressed: () => appWindow.minimize(),
                      iconSize: 20,
                      tooltip: "最小化",
                    ),
                    appWindow.isMaximized
                        ? IconButton(
                            icon: const Icon(Icons.rectangle_outlined),
                            color: Colors.white,
                            onPressed: () => appWindow.restore(),
                            iconSize: 20,
                            tooltip: "恢复大小",
                          )
                        : IconButton(
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
                  leading: _selectedIndex == 3 && FastDeploy.page != 0
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              FastDeploy.page--;
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Row(
        children: <Widget>[
          NavigationRail(
            useIndicator: false,
            selectedIconTheme: IconThemeData(
                color: colorMode == 'light'
                    ? const Color.fromRGBO(238, 109, 109, 1)
                    : const Color.fromRGBO(127, 86, 151, 1),
                size: 25),
            selectedLabelTextStyle: TextStyle(
                color: colorMode == 'light'
                    ? const Color.fromRGBO(238, 109, 109, 1)
                    : const Color.fromRGBO(127, 86, 151, 1)),
            unselectedIconTheme: IconThemeData(
                size: 25,
                color:
                    colorMode == 'light' ? Colors.grey[900] : Colors.grey[200]),
            elevation: 2,
            minWidth: 55,
            indicatorShape: const RoundedRectangleBorder(),
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
                switch (index) {
                  case 0:
                    _appBarTitle = 'NoneBot GUI';
                    break;
                  case 1:
                    _appBarTitle =
                        gOnOpen.isNotEmpty ? Bot.name() : 'NoneBot GUI';
                    break;
                  case 2:
                    _appBarTitle = '协议端控制台';
                    break;
                  case 3:
                    _appBarTitle = '快速部署';
                    break;
                  case 4:
                    _appBarTitle = '添加Bot';
                    break;
                  case 5:
                    _appBarTitle = '导入Bot';
                    break;
                  case 6:
                    _appBarTitle = '公告';
                    break;
                  case 7:
                    _appBarTitle = '设置';
                    break;
                  case 8:
                    _appBarTitle = '关于NoneBot GUI';
                    break;
                  case 9:
                    _appBarTitle = '开源许可证';
                    break;
                  default:
                    _appBarTitle = 'Null';
                    break;
                }
              });
            },
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: IconButton(
                      icon: Icon(MainApp.barExtended
                          ? Icons.keyboard_arrow_left_rounded
                          : Icons.keyboard_arrow_right_rounded),
                      iconSize: 25,
                      tooltip: MainApp.barExtended ? "收起" : "展开",
                      onPressed: () {
                        MainApp.barExtended = !MainApp.barExtended;
                        setState(() {});
                      }),
                ),
              ),
            ),
            extended: MainApp.barExtended,
            destinations: <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Tooltip(
                  message: '主页',
                  child: Icon(_selectedIndex == 0
                      ? Icons.home_rounded
                      : Icons.home_outlined),
                ),
                label: const Text('主页'),
              ),
              NavigationRailDestination(
                icon: Tooltip(
                  message: 'Bot控制台',
                  child: Icon(_selectedIndex == 1
                      ? Icons.dashboard_rounded
                      : Icons.dashboard_outlined),
                ),
                label: const Text('Bot控制台'),
              ),
              NavigationRailDestination(
                icon: Tooltip(
                  message: '协议端控制台',
                  child: Icon(_selectedIndex == 2
                      ? Icons.connected_tv_rounded
                      : Icons.connected_tv_outlined),
                ),
                label: const Text('协议端控制台'),
              ),
              NavigationRailDestination(
                icon: Tooltip(
                  message: '快速部署',
                  child: Icon(_selectedIndex == 3
                      ? Icons.archive_rounded
                      : Icons.archive_outlined),
                ),
                label: const Text('快速部署'),
              ),
              NavigationRailDestination(
                icon: Tooltip(
                  message: '添加Bot',
                  child: Icon(_selectedIndex == 4
                      ? Icons.add_rounded
                      : Icons.add_outlined),
                ),
                label: const Text('添加Bot'),
              ),
              NavigationRailDestination(
                icon: Tooltip(
                  message: '导入Bot',
                  child: Icon(_selectedIndex == 5
                      ? Icons.file_download_rounded
                      : Icons.file_download_outlined),
                ),
                label: const Text('导入Bot'),
              ),
              NavigationRailDestination(
                icon: Tooltip(
                  message: '公告',
                  child: Icon(_selectedIndex == 6
                      ? Icons.messenger_rounded
                      : Icons.messenger_outline_rounded),
                ),
                label: const Text('公告'),
              ),
              NavigationRailDestination(
                icon: Tooltip(
                  message: '设置',
                  child: Icon(_selectedIndex == 7
                      ? Icons.settings_rounded
                      : Icons.settings_outlined),
                ),
                label: const Text('设置'),
              ),
              NavigationRailDestination(
                icon: Tooltip(
                  message: '关于',
                  child: Icon(_selectedIndex == 8
                      ? Icons.info_rounded
                      : Icons.info_outlined),
                ),
                label: const Text('关于'),
              ),
              NavigationRailDestination(
                icon: Tooltip(
                  message: '开源许可证',
                  child: Icon(_selectedIndex == 9
                      ? Icons.balance_rounded
                      : Icons.balance_outlined),
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
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2,
                                  childAspectRatio: 6 / 1,
                                  mainAxisExtent: 110),
                          itemCount: configFileContentsName.length,
                          itemBuilder: (context, index) {
                            String name = configFileContentsName[index];
                            String status = configFileContentsRun[index];
                            String time = configFileContentsTime[index];
                            String path = configFileContentsPath[index];
                            return Card(
                              child: InkWell(
                                onTap: () {
                                  gOnOpen = "$name.$time";
                                  createLog(path);
                                  setState(() {
                                    loadFileContent();
                                    _selectedIndex = 1;
                                    _appBarTitle = Bot.name();
                                  });
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, top: 8.0),
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        child: status == "true"
                                            ? IconButton(
                                                icon: const Icon(
                                                    Icons.stop_rounded),
                                                onPressed: () {
                                                  gOnOpen = '$name.$time';
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                          const SnackBar(
                                                    content: Text('Bot已停止'),
                                                    duration:
                                                        Duration(seconds: 3),
                                                  ));
                                                  setState(() {
                                                    Bot.stop();
                                                  });
                                                },
                                                tooltip: '停止Bot',
                                              )
                                            : IconButton(
                                                icon: const Icon(
                                                    Icons.play_arrow_rounded),
                                                onPressed: () {
                                                  gOnOpen = '$name.$time';
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                          const SnackBar(
                                                    content: Text(
                                                        'NoneBot,启动！如果发现控制台无刷新请检查bot目录下的nbgui_stderr.log查看报错'),
                                                    duration:
                                                        Duration(seconds: 3),
                                                  ));
                                                  setState(() {
                                                    Bot.run();
                                                  });
                                                },
                                                tooltip: '运行Bot',
                                              ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, bottom: 8),
                                      child: status == 'true'
                                          ? const Text(
                                              "运行中",
                                              style: TextStyle(
                                                  color: Colors.green),
                                            )
                                          : const Text("未运行"),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
                gOnOpen.isNotEmpty
                    ? ManageBot()
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
                gOnOpen.isNotEmpty
                    ? checkBotType()
                        ? const ManageProtocol()
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset('lib/assets/loading.gif'),
                                const SizedBox(height: 10),
                                const Text('当前选择的Bot不支持协议端控制台'),
                              ],
                            ),
                          )
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
                FastDeploy.page == 0
                    ? const FastDeployList()
                    : FastDeploy.page == 1
                        ? const Deployment()
                        : FastDeploy.page == 2
                            ? const Deploy()
                            : const Text('Null'),
                const CreateBot(),
                const ImportBot(),
                const BoradcastList(),
                const Settings(),
                const About(),
                LicensePage(
                  applicationIcon: Image.asset('lib/assets/logo.png'),
                  applicationName: 'NoneBotGUI',
                  applicationVersion: MainApp.version.replaceAll('v', ''),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
    // do something
  }
}
