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
      home: LicensePage(),
    );
  }
}




class import_bot extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<import_bot> {

  final myController = TextEditingController();







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "1",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
        ],
        backgroundColor: Color.fromRGBO(238, 109, 109, 1),
      ),
    );
  }
}

