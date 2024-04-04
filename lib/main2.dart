import 'package:flutter/material.dart';
import 'ui/createbot.dart';
import 'ui/more.dart';
import 'dart:convert';

class MyAppBar extends StatelessWidget {
  const MyAppBar({required this.title, super.key});

  // Fields in a Widget subclass are always marked "final".

  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56, // in logical pixels
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Color.fromRGBO(238, 109, 109, 1)),
      // Row is a horizontal, linear layout.
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu),
            tooltip: '更多',
            onPressed: () {    
                       Navigator.push(context, MaterialPageRoute(builder:(context) {
                                return  More();
                       }));
              }, // null disables the button
          ),
          // Expanded expands its child
          // to fill the available space.
          Expanded(
            child: title,
          ),
        ],
      ),
    );
  }
}

class MyScaffold extends StatelessWidget {
  const MyScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    // Material is a conceptual piece
    // of paper on which the UI appears.
    return Material(
      // Column is a vertical, linear layout.
      child: Column(
        children: [
          MyAppBar(
            title: Text(
              'Nonebot GUI',
              style: Theme.of(context) //
                  .primaryTextTheme
                  .titleLarge,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('还没有Bot，请先点击下面的"+"来创建'),
              ),
            ),
  
        FloatingActionButton(
          onPressed:  () {    
                       Navigator.push(context, MaterialPageRoute(builder:(context) {
                                return  CreateBot();
                       }));
              },
          tooltip: '添加一个bot',
          child: Icon(Icons.add),
          backgroundColor: Color.fromRGBO(238, 109, 109, 1),
          ),
        ],
      ),
    );
  }
}





void main() {
  runApp(
    const MaterialApp(
      title: 'Nonebot GUI', // used by the OS task switcher
      home: SafeArea(
        child: MyScaffold(),
      ),
    ),
  );
}