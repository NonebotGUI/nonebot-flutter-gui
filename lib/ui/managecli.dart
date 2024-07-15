import 'dart:io';
import 'package:NoneBotGUI/darts/utils.dart';
import 'package:NoneBotGUI/darts/global.dart';
import 'package:NoneBotGUI/ui/adapter.dart';
import 'package:NoneBotGUI/ui/driver.dart';
import 'package:NoneBotGUI/ui/manage_cli.dart';
import 'package:NoneBotGUI/ui/manage_plugin.dart';
import 'package:NoneBotGUI/ui/plugin.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

// void main() {
//   runApp(
//     const MyApp(),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: manageCli(),
//     );
//   }
// }

class manageCli extends StatefulWidget {
  const manageCli({super.key});

  @override
  State<manageCli> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<manageCli> {
  final myController = TextEditingController();

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
                  title: const Text(
                    'Bot管理',
                    style: TextStyle(
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 80,
              child: InkWell(
                child: const Card(
                  child: Row(
                    children: <Widget>[
                      Text('  插件商店'),
                      Icon(Icons.keyboard_arrow_right_rounded)
                    ],
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PluginStore(),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            SizedBox(
              height: 80,
              child: InkWell(
                child: const Card(
                  child: Row(
                    children: <Widget>[
                      Text('  管理插件'),
                      Icon(Icons.keyboard_arrow_right_rounded)
                    ],
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManagePlugin(),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            SizedBox(
              height: 80,
              child: InkWell(
                child: const Card(
                  child: Row(
                    children: <Widget>[
                      Text('  适配器商店'),
                      Icon(Icons.keyboard_arrow_right_rounded)
                    ],
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdapterStore(),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            SizedBox(
              height: 80,
              child: InkWell(
                child: const Card(
                  child: Row(
                    children: <Widget>[
                      Text('  驱动器商店'),
                      Icon(Icons.keyboard_arrow_right_rounded)
                    ],
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DriverStore(),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 80,
              child: InkWell(
                child: const Card(
                  child: Row(
                    children: <Widget>[
                      Text('  管理nb-cli本体'),
                      Icon(Icons.keyboard_arrow_right_rounded)
                    ],
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageCli(),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            SizedBox(
              height: 80,
              child: InkWell(
                child: const Card(
                  child: Row(
                    children: <Widget>[
                      Text('  生成机器人的入口文件(bot.py)  '),
                      Icon(
                        Icons.file_open_rounded,
                        size: 20,
                      )
                    ],
                  ),
                ),
                onTap: () {
                  Process.start(
                    'nb',
                    ['generate'],
                    runInShell: true,
                    workingDirectory: manageBotReadCfgPath(userDir),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('已生成'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 4,
            ),
          ],
        ),
      ),
    );
  }
}
