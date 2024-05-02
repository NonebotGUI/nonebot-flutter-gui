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
      home: StdErr(),
    );
  }
}




class StdErr extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<StdErr> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${manage_bot_readcfg_name()} - nbgui_stderr.log",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showConfirmationDialog(context),
            tooltip: "删除报错日志",
            color: Colors.white,
          )
        ],
        backgroundColor: Color.fromRGBO(238, 109, 109, 1),
      ),

      body: SingleChildScrollView(
        child: Container(
          width: 20000,
          child: Row(
            children: <Widget>[
              Expanded(child: Align(alignment: Alignment.centerLeft, child: Text(manage_bot_view_stderr()))),  
            ],
        ),
      )
      ),
    );
  }
}







void _showConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('删除'),
        content: Text('你确定要删除吗？'),
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
              delete_stderr(); 
              ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                      content: Text('已删除'),
                      duration: Duration(seconds: 3),));
            },
          ),
        ],
      );
    },
  );
}