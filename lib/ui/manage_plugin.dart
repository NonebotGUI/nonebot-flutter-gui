import 'dart:io';
import 'package:Nonebot_GUI/darts/utils.dart';
import 'package:flutter/material.dart';



void main() {
  runApp(
    MyApp(),
  );

}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ManagePlugin(),
    );
  }
}




class ManagePlugin extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ManagePlugin> {








  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "管理插件",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
        ],
        backgroundColor: Color.fromRGBO(238, 109, 109, 1),
      ),
      body: get_pluginlist().length == 0
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('你还没有安装任何插件'),
                SizedBox(height: 3),
                Text('你可以前往插件商店来安装'),
              ]
            ),
          )
        : ListView.builder(
          itemCount: get_pluginlist().length,
          itemBuilder:(context, index) {
            return Container(
              child: Card(
                child: SizedBox(
                  height: 70,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(' ${get_pluginlist()[index]}',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                                        builder: (BuildContext context) {
                                          String name = get_pluginlist()[index];
                                          return AlertDialog(
                                            title: Text('确认卸载'),
                                            content: Text('你确定要卸载这个插件吗？'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('取消'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text('确定',style: TextStyle(color: Color.fromRGBO(238, 109, 109, 1)),),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  _uninstall(name);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                          content: Text('已发起卸载命令'),
                                                          duration: Duration(seconds: 5),));
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                  },
                                  tooltip: '卸载插件',
                                  icon: Icon(Icons.delete_rounded),
                                  iconSize: 25,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
              )
            )
              );
          },
         )
      );
  }
}

void _uninstall(name) async {
    List<String> commands = [manage_cli_plugin('uninstall', name)];
    for (String command in commands) {
      List<String> args = command.split(' ');
      String executable = args.removeAt(0);
      Process process = await Process.start(
        executable,
        args,
        runInShell: true,
        workingDirectory: manage_bot_readcfg_path(),
      );
      await process.exitCode;
    }
  }