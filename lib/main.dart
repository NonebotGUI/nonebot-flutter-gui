import 'dart:io';
import 'package:Nonebot_GUI/darts/utils.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'ui/createbot.dart';
import 'ui/more.dart';
import 'ui/manage_bot.dart';
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
      home: HomeScreen(),
    );
  }
}




class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String configFolder = '${create_main_folder_bots()}';

  @override
  void initState() {
    super.initState();
    create_main_folder();
    _readConfigFiles();
  }

  List<String> configFileContents_name = [];
  List<String> configFileContents_path = [];
  List<String> configFileContents_run = [];
  List<String> configFileContents_time = [];

  void _readConfigFiles() async {
    Directory directory = Directory(configFolder);
    List<FileSystemEntity> files = await directory.list().toList();

    configFileContents_name.clear();
    configFileContents_path.clear();
    configFileContents_run.clear();
    configFileContents_time.clear();

    for (FileSystemEntity file in files) {
      if (file is File) {
        String content = await file.readAsString();
         Map<String, dynamic> jsonContent = json.decode(content);
        configFileContents_name.add(jsonContent['name']);
        configFileContents_path.add(jsonContent['path']);
        configFileContents_run.add(jsonContent['isrunning']);
        configFileContents_time.add(jsonContent['time']);
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nonebot GUI',
        style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromRGBO(238, 109,109, 1),
        leading: IconButton(icon: const Icon(Icons.menu),
            tooltip: '更多',
            onPressed: () {    
                       Navigator.push(context, MaterialPageRoute(builder:(context) {
                                return  More();
                       }));
              },
            color: Colors.white,
              ),
          actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: (){_readConfigFiles();create_main_folder();},
            tooltip: "刷新列表",
            color: Colors.white,
          ),
        ],
      ),

        body: configFileContents_name.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('还没有Bot,点击右下角的“+”来创建'),
                  SizedBox(height: 3),
                  Text('如果创建后没有显示请点击右上角的按钮刷新列表'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: configFileContents_name.length,
              itemBuilder: (context, index) {
                String name = configFileContents_name[index];
                String status = configFileContents_run[index];
                String time = configFileContents_time[index];
                if (status == 'true') {
                return SingleChildScrollView(
                child: Card(
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text("运行中",
                    style: TextStyle(color: Colors.green),),
                    onTap: () {
                        manage_bot_onopencfg(name, time);
                        Navigator.push(context, MaterialPageRoute(builder:(context) {
                                return  manage_bot();
                       }));
                    },
                    trailing: Icon(Icons.menu), 
                  ),
                )
                );
                }
                else{
                return SingleChildScrollView(
                child: Card(
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text("未运行",),
                    onTap: () {
                        manage_bot_onopencfg(name, time);
                        Navigator.push(context, MaterialPageRoute(builder:(context) {
                                return  manage_bot();
                       }));
                    },
                    
                    trailing: Icon(Icons.menu), 
                  ),
                )
                );
                }
              },
            ),
        floatingActionButton:  FloatingActionButton(
          onPressed:  () {    
                       Navigator.push(context, MaterialPageRoute(builder:(context) {
                                return  CreateBot();
                       }));
              },
          tooltip: '添加一个bot',
          child: Icon(Icons.add,color: Colors.white,),
          backgroundColor: Color.fromRGBO(238, 109, 109, 1),
          shape: CircleBorder(),
          ),
    );
  }
}

