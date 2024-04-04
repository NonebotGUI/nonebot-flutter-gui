import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../darts/utils.dart';
import 'dart:io' show Platform;






class More extends StatelessWidget {
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text(
          "更多",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(238, 109, 109, 1),
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
          ],
        ),
      )
    );
  }
}