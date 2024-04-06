import 'package:Nonebot_GUI/darts/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: manage_cli(),
    );
  }
}
class manage_cli extends StatefulWidget {
  const manage_cli({super.key});

  @override
  State<manage_cli> createState() => _MyCustomFormState();
}


class _MyCustomFormState extends State<manage_cli> {
//屎山
//别骂了别骂了😭😭😭

  final plugin_output = TextEditingController();
  void manage_plugin(manage,name) async {
    plugin_output.clear();
    List<String> commands = [manage_cli_plugin(manage, name)];
    for (String command in commands) {
      List<String> args = command.split(' ');
      String executable = args.removeAt(0);
      Process process = await Process.start(executable, args, runInShell: true,workingDirectory: manage_bot_readcfg_path());
      process.stdout.transform(systemEncoding.decoder).listen((data) {
        plugin_output.text += data;
        plugin_output.selection = TextSelection.fromPosition(TextPosition(offset: plugin_output.text.length));
        setState(() {});
      });
      process.stderr.transform(systemEncoding.decoder).listen((data) {
        plugin_output.text += data;
        plugin_output.selection = TextSelection.fromPosition(TextPosition(offset: plugin_output.text.length));
        setState(() {});
      });
      await process.exitCode;
    }
  }

  final adapter_output = TextEditingController();
  void manage_adapter(manage,name) async {
    adapter_output.clear();
    List<String> commands = [manage_cli_adapter(manage, name)];
    for (String command in commands) {
      List<String> args = command.split(' ');
      String executable = args.removeAt(0);
      Process process = await Process.start(executable, args, runInShell: true,workingDirectory: manage_bot_readcfg_path());
      process.stdout.transform(systemEncoding.decoder).listen((data) {
        adapter_output.text += data;
        adapter_output.selection = TextSelection.fromPosition(TextPosition(offset: adapter_output.text.length));
        setState(() {});
      });
      process.stderr.transform(systemEncoding.decoder).listen((data) {
        adapter_output.text += data;
        adapter_output.selection = TextSelection.fromPosition(TextPosition(offset: adapter_output.text.length));
        setState(() {});
      });
      await process.exitCode;
    }
  }

  final driver_output = TextEditingController();
  void manage_driver(manage,name) async {
    driver_output.clear();
    List<String> commands = [manage_cli_driver(manage, name)];
    for (String command in commands) {
      List<String> args = command.split(' ');
      String executable = args.removeAt(0);
      Process process = await Process.start(executable, args, runInShell: true,workingDirectory: manage_bot_readcfg_path());
      process.stdout.transform(systemEncoding.decoder).listen((data) {
        driver_output.text += data;
        driver_output.selection = TextSelection.fromPosition(TextPosition(offset: driver_output.text.length));
        setState(() {});
      });
      process.stderr.transform(systemEncoding.decoder).listen((data) {
        driver_output.text += data;
        driver_output.selection = TextSelection.fromPosition(TextPosition(offset: driver_output.text.length));
        setState(() {});
      });
      await process.exitCode;
    }
  }

  final package_output = TextEditingController();
  void manage_package(manage,name) async {
    package_output.clear();
    List<String> commands = [manage_cli_self(manage, name)];
    for (String command in commands) {
      List<String> args = command.split(' ');
      String executable = args.removeAt(0);
      Process process = await Process.start(executable, args, runInShell: true,workingDirectory: manage_bot_readcfg_path());
      process.stdout.transform(systemEncoding.decoder).listen((data) {
        package_output.text += data;
        package_output.selection = TextSelection.fromPosition(TextPosition(offset: package_output.text.length));
        setState(() {});
      });
      process.stderr.transform(systemEncoding.decoder).listen((data) {
        package_output.text += data;
        package_output.selection = TextSelection.fromPosition(TextPosition(offset: package_output.text.length));
        setState(() {});
      });
      await process.exitCode;
    }
  }




  final myController_plugin = TextEditingController();
  final myController_package = TextEditingController();
  final myController_adapter = TextEditingController();
  final myController_driver = TextEditingController();

  String package = "";
  String plugin = "";
  String adapter = "";
  String driver = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "管理CLI",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(onPressed: (){
            Process.start('nb', ['generate'],runInShell: true,workingDirectory: manage_bot_readcfg_path());
          },
          icon: Icon(Icons.file_open_rounded,color: Colors.white,),
          tooltip: "生成bot的入口文件（bot.py)",)
        ],
        backgroundColor: Color.fromRGBO(238, 109, 109, 1),
      ),
      body: SingleChildScrollView(
        child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
          SizedBox(
           // height: 500,
           // width: 2000,
            child: Card(
            child: Column(
              children: <Widget>[
            Text('插件管理',style: TextStyle(fontWeight: FontWeight.bold),),
            TextField(
              scrollPadding: EdgeInsets.all(6),
              controller: myController_plugin,
              decoration: const InputDecoration(
                hintText: "输入插件包名，每次只输入一个",
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(238, 109, 109, 1),
                    width: 5.0,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  plugin = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    if ( plugin != "" ){
                    manage_plugin('install', plugin);
                    }
                    else
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                        content: Text('请输入插件包名！'),
                        duration: Duration(seconds: 3),)); 
                    }
                  },
                  child: Text('安装插件',style: TextStyle(color: Colors.blue.shade700,)),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(width: 15,),
                TextButton(
                  onPressed: () {
                    if ( plugin != "" ){
                    manage_plugin('uninstall', plugin);
                    }
                    else
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                        content: Text('请输入插件包名！'),
                        duration: Duration(seconds: 3),)); 
                    }
                  },
                  child: Text('卸载插件',style: TextStyle(color: Color.fromRGBO(238, 109, 109, 1),)),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ]),
            Card(
                color: const Color.fromARGB(255, 31, 28, 28),
                child: SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.white), 
                      text: plugin_output.text,
                    ),
                  ),
                ),
              ),
            
              ]
            )
            ),
        ),
          const SizedBox(height: 8,),
          SizedBox(
            child: Card(
            child: Column(
              children: <Widget>[
            Text('适配器管理',style: TextStyle(fontWeight: FontWeight.bold),),
            TextField(
              scrollPadding: EdgeInsets.all(6),
              controller: myController_adapter,
              decoration: const InputDecoration(
                hintText: "输入适配器包名，每次只输入一个",
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(238, 109, 109, 1),
                    width: 5.0,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  adapter = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    if ( adapter != "" ){
                    manage_adapter('install', adapter);
                    }
                    else
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                        content: Text('请输入适配器包名！'),
                        duration: Duration(seconds: 3),)); 
                    }
                  },
                  child: Text('安装适配器',style: TextStyle(color: Colors.blue.shade700,)),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(width: 15,),
                TextButton(
                  onPressed: () {
                    if ( adapter != "" ){
                    manage_adapter('uninstall', adapter);
                    }
                    else
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                        content: Text('请输入适配器包名！'),
                        duration: Duration(seconds: 3),)); 
                    }
                  },
                  child: Text('卸载适配器',style: TextStyle(color: Color.fromRGBO(238, 109, 109, 1),)),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ]),
            Card(
                color: const Color.fromARGB(255, 31, 28, 28),
                child: SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.white), 
                      text: adapter_output.text,
                    ),
                  ),
                ),
              ),
            
              ]
            )
            ),
        ),
          const SizedBox(height: 8,),


          SizedBox(
            child: Card(
            child: Column(
              children: <Widget>[
            Text('驱动器管理',style: TextStyle(fontWeight: FontWeight.bold),),
            TextField(
              scrollPadding: EdgeInsets.all(6),
              controller: myController_driver,
              decoration: const InputDecoration(
                hintText: "输入驱动器包名，每次只输入一个",
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(238, 109, 109, 1),
                    width: 5.0,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  driver = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    if ( driver != "" ){
                    manage_driver('install', driver);
                    }
                    else
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                        content: Text('请输入驱动器包名！'),
                        duration: Duration(seconds: 3),)); 
                    }
                  },
                  child: Text('安装驱动器',style: TextStyle(color: Colors.blue.shade700,)),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(width: 15,),
                TextButton(
                  onPressed: () {
                    if ( driver != "" ){
                    manage_driver('uninstall', driver);
                    }
                    else
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                        content: Text('请输入驱动器包名！'),
                        duration: Duration(seconds: 3),)); 
                    }
                  },
                  child: Text('卸载驱动器',style: TextStyle(color: Color.fromRGBO(238, 109, 109, 1),)),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ]),
            Card(
                color: const Color.fromARGB(255, 31, 28, 28),
                child: SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.white), 
                      text: driver_output.text,
                    ),
                  ),
                ),
              ),
            
              ]
            )
            ),
        ),
          const SizedBox(height: 8,),


          SizedBox(
            child: Card(
            child: Column(
              children: <Widget>[
            Text('cli-self管理',style: TextStyle(fontWeight: FontWeight.bold),),
            TextField(
              scrollPadding: EdgeInsets.all(6),
              controller: myController_package,
              decoration: const InputDecoration(
                hintText: "输入包名，每次只输入一个",
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(238, 109, 109, 1),
                    width: 5.0,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  package = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    if ( package != "" ){
                    manage_package('install', package);
                    }
                    else
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                        content: Text('请输入包名！'),
                        duration: Duration(seconds: 3),)); 
                    }
                  },
                  child: Text('安装软件包到cli',style: TextStyle(color: Colors.blue.shade700,)),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(width: 15,),
                TextButton(
                  onPressed: () {
                    if ( package != "" ){
                    manage_package('uninstall', package);
                    }
                    else
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                        content: Text('请输入包名！'),
                        duration: Duration(seconds: 3),)); 
                    }
                  },
                  child: Text('卸载cli中的软件包',style: TextStyle(color: Color.fromRGBO(238, 109, 109, 1),)),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    manage_package('update', 'update');
                  },
                  child: Text('更新cli',style: TextStyle(color: Colors.green.shade700,)),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ]),

            Card(
                color: const Color.fromARGB(255, 31, 28, 28),
                child: SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.white), 
                      text: package_output.text,
                    ),
                  ),
                ),
              ),
            
              ]
            )
            ),
        )
          ],
        ),
        
      ),
      )
    );
  }
}

