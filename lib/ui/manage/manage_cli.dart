
import 'package:NoneBotGUI/utils/manage.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:NoneBotGUI/utils/global.dart';
import 'package:window_manager/window_manager.dart';
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
//       home: ManageCli(),
//     );
//   }
// }

class ManageCli extends StatefulWidget {
  const ManageCli({super.key});

  @override
  State<ManageCli> createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<ManageCli> {
//屎山
//别骂了别骂了😭😭😭

  final packageOutput = TextEditingController();
  void managePackage(manage, name) async {
    packageOutput.clear();
    List<String> commands = [Cli.self(manage, name)];
    for (String command in commands) {
      List<String> args = command.split(' ');
      String executable = args.removeAt(0);
      Process process = await Process.start(
        executable,
        args,
        runInShell: true,
        workingDirectory: Bot.path(),
      );
      process.stdout.transform(systemEncoding.decoder).listen((data) {
        packageOutput.text += data;
        packageOutput.selection = TextSelection.fromPosition(
          TextPosition(offset: packageOutput.text.length),
        );
        setState(() {});
      });
      process.stderr.transform(systemEncoding.decoder).listen((data) {
        packageOutput.text += data;
        packageOutput.selection = TextSelection.fromPosition(
          TextPosition(offset: packageOutput.text.length),
        );
        setState(() {});
      });
      await process.exitCode;
    }
  }

  final myPackageController = TextEditingController();
  String package = "";

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
                    '管理CLI',
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
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  //Text('cli-self管理',style: TextStyle(fontWeight: FontWeight.bold),),
                  TextField(
                    scrollPadding: const EdgeInsets.all(6),
                    controller: myPackageController,
                    decoration: const InputDecoration(
                      hintText: "输入包名，每次只输入一个",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(238, 109, 109, 1),
                          width: 5.0,
                        ),
                      ),
                    ),
                    onChanged: (value) => setState(() => package = value),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          if (package != "") {
                            managePackage('install', package);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('请输入包名！'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          '安装软件包到cli',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      TextButton(
                        onPressed: () {
                          if (package != "") {
                            managePackage('uninstall', package);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('请输入包名！'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          '卸载cli中的软件包',
                          style: TextStyle(
                            color: Color.fromRGBO(238, 109, 109, 1),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          managePackage('update', 'update');
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          '更新cli',
                          style: TextStyle(
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 400,
                    width: 2000,
                    child: Card(
                      color: const Color.fromARGB(255, 31, 28, 28),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            style: const TextStyle(color: Colors.white),
                            packageOutput.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
