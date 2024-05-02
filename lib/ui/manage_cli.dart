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




  final myController_package = TextEditingController();
  String package = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "管理CLI",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(238, 109, 109, 1),
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
            SizedBox(
            height: 400,
            width: 2000,
            child: Card(
                color: const Color.fromARGB(255, 31, 28, 28),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      style: TextStyle(color: Colors.white), 
                      package_output.text,
                    ),
                  ),
                ),
              ),
            )
              ]
            )
          ],
        ),
        
      ),
      )
    );
  }
}

