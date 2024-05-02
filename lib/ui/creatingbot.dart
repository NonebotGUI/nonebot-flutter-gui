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
      home: creatingbot(),
    );
  }
}
class creatingbot extends StatefulWidget {
  const creatingbot({super.key});
  

  @override
  State<creatingbot> createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _MyCustomFormState extends State<creatingbot> {
  final _outputController = TextEditingController();

  void _executeCommands() async {

    //读取配置文件
    String cfg = createbot_readconfig();
    List<String> arg = cfg.split(',');
    String name = arg[0];
    String path = arg[1];
    //保留备用
    String venv = arg[2];
    String dep = arg[3];

    
    _outputController.clear();

    List<String> commands = ['echo 开始创建Bot：${name}', 'echo 读取配置...',createvenv_echo(path, name),createvenv(path, name,venv),'echo 开始安装依赖...',installbot(path,name,venv,dep),writepyproject(path, name),writeenv(path, name),writebot(name, path),'echo 安装完成，可退出'];

    for (String command in commands) {
      List<String> args = command.split(' ');

      String executable = args.removeAt(0);
      Process process = await Process.start(executable, args, runInShell: true);

      process.stdout.transform(systemEncoding.decoder).listen((data) {
        _outputController.text += data;
        _outputController.selection = TextSelection.fromPosition(TextPosition(offset: _outputController.text.length));
        // 更新UI
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "确认创建",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(238, 109, 109, 1),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
        children: <Widget>[
          Center(
          child: ElevatedButton(
            onPressed: _executeCommands,
            child: Text('确认创建',
            style: TextStyle(color: Colors.black),),
          ),
          ),
          const Divider(
            height: 20,
            thickness: 2,
            indent: 20,
            endIndent: 20,
            color: Colors.grey,
          ),

          Center(
            child: Text('Bot信息')
          ),

          Row(children: <Widget>[
            Expanded(child: Align(alignment: Alignment.centerLeft,
            child: Text('Bot名称',
            style: TextStyle(fontWeight: FontWeight.bold),),
            )
            ),

            Expanded(child: Align(alignment: Alignment.centerRight,
            child: Text(createbot_readconfig_name()),))
          ],
          ),
          
          const SizedBox(height: 8),

          Row(children: <Widget>[
              Expanded(child: Align(alignment: Alignment.centerLeft,
              child: Text('Bot路径',
              style: TextStyle(fontWeight: FontWeight.bold),),
                )
              ),

              Expanded(child: Align(alignment: Alignment.centerRight,
                child: Text(createbot_readconfig_path(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,),
              ))
            ]
          ),

          const SizedBox(height: 8),
          Row(children: <Widget>[
            Expanded(child: Align(alignment: Alignment.centerLeft,
            child: Text('虚拟环境',
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          )),

            Expanded(child: Align(alignment: Alignment.centerRight,
            child: Text(createbot_readconfig_venv()),
          ))
          ]
          ),

          const SizedBox(height: 8),

          Row(children: <Widget>[
            Expanded(child: Align(alignment: Alignment.centerLeft,
              child: Text('依赖',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            )),

            Expanded(child: Align(alignment: Alignment.centerRight,
              child: Text(createbot_readconfig_dep()),
            ))
          ]),

            Row(children: <Widget> [
            Expanded(child: Align(alignment: Alignment.centerLeft,
            child :FutureBuilder<String>(
            future: getpyver(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return const Text('Python版本',
                style: TextStyle(fontWeight: FontWeight.bold),);
              } else if (snapshot.hasError) {
                return const Text('Python版本',
                style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),);
              } else {
                return const Text('Python版本',
                style: TextStyle(fontWeight: FontWeight.bold),);
              }
            },
            ),
            )
            ),
            Expanded(child: Align(alignment: Alignment.centerRight,
            child :FutureBuilder<String>(
            future: getpyver(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data.toString());
              } else if (snapshot.hasError) {
                return Text('未检测到Python');
              } else {
                return Text('获取中...');
              }
            },
          ),
          )
          )
          ]
          ),

          Row(children: <Widget> [
          Expanded(child: Align(alignment: Alignment.centerLeft,
          child :FutureBuilder<String>(
          future: getnbcliver(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return const Text('nb-cli版本',
              style: TextStyle(fontWeight: FontWeight.bold),);
            } else if (snapshot.hasError) {
              return const Text('nb-cli版本',
              style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),);
            } else {
              return const Text('nb-cli版本',
              style: TextStyle(fontWeight: FontWeight.bold),);
            }
          },
          ),
          )
          ),
          Expanded(child: Align(alignment: Alignment.centerRight,
          child :FutureBuilder<String>(
          future: getnbcliver(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data.toString().replaceAll('nb:', ''));
            } else if (snapshot.hasError) {
              return Text('未检测到nb-cli');
            } else {
              return Text('获取中...');
            }
          },
        ),
        )
        )
        ]
        ),
          const Divider(
          height: 20,
          thickness: 2,
          indent: 20,
          endIndent: 20,
          color: Colors.grey,
        ),

          Center(
            child: Text('控制台输出')
          ),
          const SizedBox(height: 4),
          Expanded(
            child: SizedBox(
              height: 400,
              width: 2000,
              child: Card(
                color: const Color.fromARGB(255, 31, 28, 28),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      style: TextStyle(color: Colors.white),
                      _outputController.text,
                    ),
                    )
                  ),
                ),
          )
            ),
        ],
      ),
      ),
    );
  }
}

