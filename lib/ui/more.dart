import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../darts/utils.dart';
import '../assets/my_flutter_app_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' show Platform;
import 'dart:io';
import 'package:flutter/services.dart';






class More extends StatefulWidget {
  @override
  _MoreState createState() => _MoreState();
}

class _MoreState extends State<More> {

  String? _PythonPath;
  String? _NbcliPath;

  void _selectpy() async {
    final result = await FilePicker.platform.pickFiles(
    );

    if (result != null) {
      set_pypath(result.files.single.path.toString());
      setState(() {
        _PythonPath= result.files.single.path.toString();
      });
    }
  }

  void _selectnbcli() async {
    final result = await FilePicker.platform.pickFiles(
    );

    if (result != null) {
      set_nbclipath(result.files.single.path.toString());
      setState(() {
        _NbcliPath= result.files.single.path.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text(
          "更多",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(238, 109, 109, 1),
        actions: <Widget>[
          IconButton(
            onPressed: (){
              Clipboard.setData(ClipboardData(text: 'https://github.com/XTxiaoting14332/nonebot-flutter-gui'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('项目仓库链接已复制到剪贴板'),
                  duration: Duration(seconds: 3),));
            },
            icon: Icon(MyFlutterApp.github),
            tooltip: '项目仓库地址',
            iconSize: 30,
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget> [
            Center(
            child:Image.asset('lib/assets/logo.png',
            width: MediaQuery.of(context).size.width * 0.2, 
            height: null, 
            fit: BoxFit.contain,),
            ),


            Center(
              child:Text("Nonebot GUI",
              style: TextStyle(fontSize: MediaQuery.of(context).textScaleFactor * 35.0,
              fontWeight: FontWeight.bold),)
            ),



            Center(
              child: Text("_✨基于Flutter的Nonebot GUI✨_",
              style: TextStyle(color: Colors.black),),
            ),
            const Divider(
              height: 20,
              thickness: 2,
              indent: 20,
              endIndent: 20,
              color: Colors.grey,
            ),

          SizedBox(height: 8,),
          Row(children: <Widget> [
          Expanded(child: Align(alignment: Alignment.centerLeft,
          child: Text('软件版本',
          style: TextStyle(fontWeight: FontWeight.bold),),
          )
          ),
          Expanded(child: Align(alignment: Alignment.centerRight,
          child: Text('0.1.4+1'),
        )
        )
        ]
        ),
            SizedBox(height: 16,),
            Row(children: <Widget>[
             Expanded(child: Align(alignment: Alignment.centerLeft,
             child: Text('平台',style: TextStyle(fontWeight: FontWeight.bold),),)
             ),
            Expanded(child: Align(alignment: Alignment.bottomRight,
            child: Text(Platform.operatingSystem[0].toUpperCase() + Platform.operatingSystem.substring(1)),),)
            ],
            ),


            const SizedBox(height: 20,),
            Row(children: <Widget> [
            Expanded(child: Align(alignment: Alignment.centerLeft,
            child: Text('当前Python环境',
            style: TextStyle(fontWeight: FontWeight.bold),),
            )
            ),
            Expanded(child: Align(alignment: Alignment.centerRight,
            child :FutureBuilder<String>(
            future: getpyver(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data.toString());
              } else if (snapshot.hasError) {
                return Text('你似乎还没安装Python？');
              } else {
                return Text('获取中...');
              }
            },
          ),
          )
          )
          ]
          ),
          SizedBox(height: 16,),
          Row(children: <Widget> [
          Expanded(child: Align(alignment: Alignment.centerLeft,
          child: Text('当前nb-cli版本',
          style: TextStyle(fontWeight: FontWeight.bold),),
          )
          ),
          Expanded(child: Align(alignment: Alignment.centerRight,
          child :FutureBuilder<String>(
          future: getnbcliver(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data.toString().replaceAll('nb: ', ''));
            } else if (snapshot.hasError) {
              return Text('你似乎还没安装nb-cli？');
            } else {
              return Text('获取中...');
            }
          },
        ),
        )
        )
        ]
        ),
        const SizedBox(height: 16,),
        Row(children: <Widget>[
          Expanded(child: Align(alignment: 
          Alignment.centerLeft,
          child: Text('选择Python命令路径[${_PythonPath}]',
          style: TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,),
          )),

          Expanded(child: Align(alignment: 
          Alignment.centerRight,
          child:
              IconButton(
                onPressed: _selectpy,
                tooltip: "选择Python命令路径",
                icon: const Icon(Icons.file_open_rounded),
              ),
          ),
          ) 
        ],
        ),
        const SizedBox(height: 16,),
        Row(children: <Widget>[
          Expanded(child: Align(alignment: 
          Alignment.centerLeft,
          child: Text('选择nb-cli命令路径[${_NbcliPath}]',
          style: TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,),
          )),

          Expanded(child: Align(alignment: 
          Alignment.centerRight,
          child:
              IconButton(
                onPressed: _selectnbcli,
                tooltip: "选择nb-cli命令路径",
                icon: const Icon(Icons.file_open_rounded),
              ),
          ),
          ) 
        ],
        ),
        const SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {
               set_pypath('default');
               setState(() {
               });
              },
              child: Text('重置Python路径',style: TextStyle(color: Color.fromRGBO(238, 109, 109, 1),)),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(width: 15,),
            TextButton(
              onPressed: () {
                set_nbclipath('default');
                setState(() {
                });
              },
              child: Text('重置nb-cli路径',style: TextStyle(color: Color.fromRGBO(238, 109, 109, 1),)),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
        ]
        ),
      )
    );
  }
}

