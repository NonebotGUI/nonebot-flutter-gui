import 'package:Nonebot_GUI/darts/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'dart:convert';
import '../darts/utils.dart';


void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: manage_bot(),
    );
  }
}
class manage_bot extends StatefulWidget {
  const manage_bot({super.key});
  

  @override
  State<manage_bot> createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _MyCustomFormState extends State<manage_bot> {
  final _outputController = TextEditingController();

  void _executeCommands() async {

    //读取配置文件
    String cfg = createbot_readconfig();
    List<String> arg = cfg.split(',');
    String name = arg[0];
    String path = arg[1];
    String venv = arg[2];
    String dep = arg[3];

    
    _outputController.clear();

    List<String> commands = ['echo 开始创建Bot：${name}', 'echo 读取配置...','echo 在${path}/${name}/.venv中创建虚拟环境',createvenv(path, name),'echo 开始安装依赖...',installbot(path,name),writepyproject(path, name),writeenv(path, name),writebot(name, path),'echo 安装完成，可退出'];

    for (String command in commands) {
      List<String> args = command.split(' ');

      String executable = args.removeAt(0);
      Process process = await Process.start(executable, args, runInShell: true);

      process.stdout.transform(utf8.decoder).listen((data) {
        _outputController.text += data;
        _outputController.selection = TextSelection.fromPosition(TextPosition(offset: _outputController.text.length));
        // 更新UI
        setState(() {});
      });

      process.stderr.transform(utf8.decoder).listen((data) {
        _outputController.text += data;
        _outputController.selection = TextSelection.fromPosition(TextPosition(offset: _outputController.text.length));
        setState(() {});
      });

      await process.exitCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${manage_bot_readcfg_name()}",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              print('1');
            },
            tooltip: "删除",
            color: Colors.white,
          )
        ],
        backgroundColor: Color.fromRGBO(238, 109, 109, 1),
      ),
      body: SingleChildScrollView(
  child: Column(
    children: <Widget>[
      Card(
        margin: EdgeInsets.all(12.0),
        child: Column(
        children: <Widget>[
            const Center(
              child: Text('Bot信息',
              style: TextStyle(fontWeight: FontWeight.bold),)
            ),
            Row(
              children: <Widget>[
                Expanded(child: Align(alignment: Alignment.centerLeft, child: Text('名称',style: TextStyle(fontWeight: FontWeight.bold),))),
                Expanded(child: Align(alignment: Alignment.centerRight, child: Text(manage_bot_readcfg_name().toString()))),
              ]),
            const SizedBox(height: 6,),
            Row(
              children: <Widget>[
                Expanded(child: Align(alignment: Alignment.centerLeft, child: Text('路径',style: TextStyle(fontWeight: FontWeight.bold),))),
                Expanded(child: Align(alignment: Alignment.centerRight, child: Text(manage_bot_readcfg_path().toString()))),
              ]),
            const SizedBox(height: 6,),
            Row(
              children: <Widget>[
                Expanded(child: Align(alignment: Alignment.centerLeft, child: Text('创建时间',style: TextStyle(fontWeight: FontWeight.bold),))),
                Expanded(child: Align(alignment: Alignment.centerRight, child: Text(manage_bot_readcfg_time().toString()))),
              ]),
            const SizedBox(height: 7,),
            Row(
              children: <Widget>[
                Expanded(child: Align(alignment: Alignment.centerLeft, child: Text('备注',style: TextStyle(fontWeight: FontWeight.bold),))),
                if (manage_bot_readcfg_status().toString() == 'true')
                  Expanded(child: Align(alignment: Alignment.centerRight, child: Text('运行中     ',style: TextStyle(color: Colors.green),))),
                if (manage_bot_readcfg_status().toString() == 'false')
                  Expanded(child: Align(alignment: Alignment.centerRight, child: Text('未运行     ',style: TextStyle(color: Colors.red),))),
              ]),
          ],
        ),
      ),
      Card(
        margin: EdgeInsets.all(4.0),
        child: Column(
          children: <Widget>[
           const Center(
            child: Text('操作',style: TextStyle(fontWeight: FontWeight.bold),)
           ),
           SizedBox(height: 3,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(onPressed: (){print('1');}, tooltip: "运行",icon: Icon(Icons.play_arrow_rounded),iconSize: 25,),
              IconButton(onPressed: (){print('1');}, tooltip: "停止",icon: Icon(Icons.stop_rounded),iconSize: 25,),
              IconButton(onPressed: (){print('1');}, tooltip: "重启",icon: Icon(Icons.refresh),iconSize: 25,),
              IconButton(onPressed: (){openfolder(manage_bot_readcfg_path().toString());}, tooltip: "打开文件夹",icon: Icon(Icons.folder),iconSize: 25,),
              IconButton(onPressed: (){print('1');}, tooltip: "管理CLI",icon: Icon(Icons.terminal_rounded),iconSize: 25,),
            ],
          )
          ],
        ),
      ),
      Card(
        margin: EdgeInsets.all(4.0),
        child: Column(
          children: <Widget>[
           const Center(child: Text('控制台输出',style: TextStyle(fontWeight: FontWeight.bold),),),
           SizedBox(height: 3,),

          ]
        )
      ),
    ],
  ),
      )
    );
  }
}

