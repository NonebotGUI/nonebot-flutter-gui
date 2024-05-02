import 'dart:io';

import 'package:Nonebot_GUI/darts/utils.dart';
import 'package:Nonebot_GUI/ui/adapter.dart';
import 'package:Nonebot_GUI/ui/driver.dart';
import 'package:Nonebot_GUI/ui/manage_cli.dart';
import 'package:Nonebot_GUI/ui/manage_plugin.dart';
import 'package:Nonebot_GUI/ui/plugin.dart';
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
      home: ManageCli(),
    );
  }
}




class ManageCli extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ManageCli> {

  final myController = TextEditingController();







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "管理CLI",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
        ],
        backgroundColor: Color.fromRGBO(238, 109, 109, 1),
      ),
      body: SingleChildScrollView(
      child: Column(
          children: <Widget>[
            SizedBox(
              height: 80,
              child: InkWell(
                child: Card(
                  child: Row(
                    children: <Widget>[
                      Text('  插件商店'),
                      Icon(Icons.keyboard_arrow_right_rounded)
                    ],
                  ),
                ),
                onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder:(context) {
                      return PluginStore();
                  }));
                }
              )
            ),
            SizedBox(height: 4,),
            SizedBox(
              height: 80,
              child: InkWell(
                child: Card(
                  child: Row(
                    children: <Widget>[
                      Text('  管理插件'),
                      Icon(Icons.keyboard_arrow_right_rounded)
                    ],
                  ),
                ),
                onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder:(context) {
                      return ManagePlugin();
                  }));
                }
              )
            ),
            const SizedBox(height: 4,),
            SizedBox(
              height: 80,
              child: InkWell(
                child: Card(
                  child: Row(
                    children: <Widget>[
                      Text('  适配器商店'),
                      Icon(Icons.keyboard_arrow_right_rounded)
                    ],
                  ),
                ),
                onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder:(context) {
                      return AdapterStore();
                  }));
                }
              )
            ),
            SizedBox(height: 4,),
            SizedBox(
              height: 80,
              child: InkWell(
                child: Card(
                  child: Row(
                    children: <Widget>[
                      Text('  驱动器商店'),
                      Icon(Icons.keyboard_arrow_right_rounded)
                    ],
                  ),
                ),
                onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder:(context) {
                      return DriverStore();
                  }));
                }
              )
            ),
            SizedBox(
              height: 80,
              child: InkWell(
                child: Card(
                  child: Row(
                    children: <Widget>[
                      Text('  管理nb-cli本体'),
                      Icon(Icons.keyboard_arrow_right_rounded)
                    ],
                  ),
                ),
                onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder:(context) {
                      return manage_cli();
                  }));
                }
              )
            ),
            const SizedBox(height: 4,),
            SizedBox(
              height: 80,
              child: InkWell(
                child: Card(
                  child: Row(
                    children: <Widget>[
                      Text('  生成机器人的入口文件(bot.py)  '),
                      Icon(Icons.file_open_rounded,size: 20,)
                    ],
                  ),
                ),
                onTap: (){
                  Process.start('nb', ['generate'],runInShell: true,workingDirectory: manage_bot_readcfg_path());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                    content: Text('已生成'),
                    duration: Duration(seconds: 3),)
                    );
                }
              )
            ),
            const SizedBox(height: 4,),
          ],
        ),
      ),
    );
  }
}

