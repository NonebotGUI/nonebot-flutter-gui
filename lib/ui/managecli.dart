import 'dart:io';
import 'package:NonebotGUI/ui/manage_cli.dart';
import 'package:NonebotGUI/darts/utils.dart';
import 'package:NonebotGUI/ui/adapter.dart';
import 'package:NonebotGUI/ui/driver.dart';
import 'package:NonebotGUI/ui/manage_plugin.dart';
import 'package:NonebotGUI/ui/plugin.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: manageCli(),
    );
  }
}

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
      appBar: AppBar(
        title: const Text(
          "管理CLI",
          style: TextStyle(color: Colors.white),
        ),
        actions: const <Widget>[],
        backgroundColor: userColorMode() == 'light'
          ? const Color.fromRGBO(238, 109, 109, 1)
          : const Color.fromRGBO(127, 86, 151, 1),
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
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const PluginStore();
                      }));
                    })),
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
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const ManagePlugin();
                      }));
                    })),
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
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const AdapterStore();
                      }));
                    })),
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
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const DriverStore();
                      }));
                    })),
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
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const ManageCli();
                      }));
                    })),
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
                      Process.start('nb', ['generate'],
                          runInShell: true,
                          workingDirectory: manageBotReadCfgPath());
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('已生成'),
                        duration: Duration(seconds: 3),
                      ));
                    })),
            const SizedBox(
              height: 4,
            ),
          ],
        ),
      ),
    );
  }
}
