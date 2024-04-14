import 'package:Nonebot_GUI/darts/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'dart:async';
import '../darts/utils.dart';
import 'manage_cli.dart';


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
  Timer? _timer;
  String _log = '[I]Welcome to Nonebot GUI!\n';
  final _filePath = '${manage_bot_readcfg_path()}/nbgui_stdout.log';
  final _outputController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadFileContent();
  }

  void _startRefreshing() {
    if (_timer == null) {
      _timer = Timer.periodic(Duration(seconds: 2), (Timer t) => _loadFileContent());
    }
  }

  void _stopRefreshing() {
    _timer?.cancel();
    _timer = null;
  }

  void _loadFileContent() async {
    try {
      final file = File(_filePath);
      final lines = await file.readAsLines();
      final last50Lines = lines.length > 50 ? lines.sublist(lines.length - 50) : lines;
      setState(() {
        _log = last50Lines.join('\n');
      });
    } catch (e) {
      print('Error reading file: $e');
    }
  }
  void _executeCommands() async {


    
    _outputController.clear();

    List<String> commands = [''];

    for (String command in commands) {
      List<String> args = command.split(' ');

      String executable = args.removeAt(0);
      Process process = await Process.start(executable, args, runInShell: true);

      process.stdout.transform(systemEncoding.decoder).listen((data) {
        _outputController.text += data;
        _outputController.selection = TextSelection.fromPosition(TextPosition(offset: _outputController.text.length));
        setState(() {});
      });

      process.stderr.transform(systemEncoding.decoder).listen((data) {
        _outputController.text += data;
        _outputController.selection = TextSelection.fromPosition(TextPosition(offset: _outputController.text.length));
        setState(() {});
      });

      await process.exitCode;
    }
  }
  void _reloadConfig() {
    setState(() {});
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
            onPressed: () => _showConfirmationDialog(context),
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
                Expanded(child: Align(alignment: Alignment.centerLeft, child: Text('状态',style: TextStyle(fontWeight: FontWeight.bold),))),
                if (manage_bot_readcfg_status().toString() == 'true')
                  Expanded(child: Align(alignment: Alignment.centerRight, child: Text('运行中',style: TextStyle(color: Colors.green),))),
                if (manage_bot_readcfg_status().toString() == 'false')
                  Expanded(child: Align(alignment: Alignment.centerRight, child: Text('未运行',style: TextStyle(color: Colors.red),))),
              ]),
            Row(
              children: <Widget>[
                Expanded(child: Align(alignment: Alignment.centerLeft, child: Text('进程ID',style: TextStyle(fontWeight: FontWeight.bold),))),
                Expanded(child: Align(alignment: Alignment.centerRight, child: Text(manage_bot_readcfg_pid().toString()))),
              ]
            )
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
              IconButton(
                onPressed: (){
                  if (manage_bot_readcfg_status().toString() == 'false'){
                  run_bot(manage_bot_readcfg_path());
                  _reloadConfig();
                  _startRefreshing();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                      content: Text('Nonebot,启动！如果发现控制台无刷新请检查bot目录下的nbgui_stderr.log查看报错'),
                      duration: Duration(seconds: 3),));
                  }
                  else{
                      ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                      content: Text('Bot已经在运行中了！'),
                      duration: Duration(seconds: 3),));
                  }
                  },
                tooltip: "运行",
                icon: Icon(Icons.play_arrow_rounded),
                iconSize: 25,),

              IconButton(
                onPressed: (){
                  if (manage_bot_readcfg_status().toString() == 'true'){
                  stop_bot();
                  _reloadConfig();
                  Future.delayed(Duration(seconds: 10), () {
                    _stopRefreshing();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                      content: Text('Bot已停止'),
                      duration: Duration(seconds: 3),));
                  }
                  else{
                      ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                      content: Text('Bot未在运行！'),
                      duration: Duration(seconds: 3),));
                  }
                }, 
                tooltip: "停止",
                icon: Icon(Icons.stop_rounded),
                iconSize: 25,),

              IconButton(
                onPressed: (){
                  if  (manage_bot_readcfg_status().toString() == 'true'){
                  stop_bot();
                  run_bot(manage_bot_readcfg_path());
                  _reloadConfig();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                      content: Text('Bot正在重启...'),
                      duration: Duration(seconds: 3),));
                  }
                  else{
                      ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                      content: Text('Bot未在运行！'),
                      duration: Duration(seconds: 3),));
                  }
                },
                tooltip: "重启",
                icon: Icon(Icons.refresh),
                iconSize: 25,),


              IconButton(onPressed: (){openfolder(manage_bot_readcfg_path().toString());}, tooltip: "打开文件夹",icon: Icon(Icons.folder),iconSize: 25,),

              IconButton(
                onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder:(context) {
                                return  manage_cli();
                       }));
              }, 
                tooltip: "管理CLI",
                icon: Icon(Icons.terminal_rounded),
                iconSize: 25,),

              IconButton(
                onPressed: (){_startRefreshing();clear_log();},
                tooltip: "清空日志",
                icon: Icon(Icons.delete_rounded),
                iconSize: 25,),

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
          SizedBox(
          height: 400,
          width: 2000,
          child: Card(
            color: const Color.fromARGB(255, 31, 28, 28),
            child: SingleChildScrollView(
              child: Text(_log,style: TextStyle(color: Colors.white),)),
          )
          )
          ]
        )
      ),
    ],
  ),
      )
    );
  }
}

void _showConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('删除'),
        content: Text('你确定要删除这个Bot吗？'),
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
              delete_bot(); 
              ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                      content: Text('Bot已删除，请回到主页面刷新列表'),
                      duration: Duration(seconds: 3),));
            },
          ),
          TextButton(
            child: Text('确定（连同bot目录一起删除）',style: TextStyle(color: Color.fromRGBO(255, 0, 0, 1)),),
            onPressed: () {
              Navigator.of(context).pop();
              delete_bot_all(); 
              ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                      content: Text('Bot已删除，请回到主页面刷新列表'),
                      duration: Duration(seconds: 3),));
            },
          ),
        ],
      );
    },
  );
}
