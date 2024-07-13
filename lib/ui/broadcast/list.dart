import 'dart:convert';
import 'package:NoneBotGUI/darts/global.dart';
import 'package:NoneBotGUI/ui/broadcast/detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class BoradcastList extends StatefulWidget {
  const BoradcastList({super.key});

  @override
  State<BoradcastList> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<BoradcastList> {

  List data = [];


  //拉取公告列表
  @override
  void initState() {
    super.initState();
    fetchData();
  }


  Future<void> fetchData() async {
final response =
    await http.get(Uri.parse('https://api.zobyic.top/api/nbgui/broadcast/list/'));
    if (response.statusCode == 200) {
    setState(() {
      String decodedBody = utf8.decode(response.bodyBytes);
      final List jsonData = json.decode(decodedBody);
      jsonData.sort((a, b) => b['id'] - a['id']); // 按id从大到小排序
      data = jsonData;
    });
    } else {
      throw Exception('Failed to load data');
    }
  }


  InkWell list(broadcast) => InkWell(
    onTap: () {
      broadcastId = broadcast['id'];
      Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BroadcastDetail(),
            ),
          );
    },
    child: Card(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        broadcast['name'].toString().substring(0,  broadcast['name'].length - 3),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(broadcast['time']),
                    ),
                  ],
                ),
              ),
            ],
          ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: data.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator()
                ],
              ),
            )
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) =>
                  list(data[index]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            data.clear();
            fetchData();
          });
        },
        tooltip: "刷新列表",
        shape: const CircleBorder(),
        child: const Icon(Icons.refresh_rounded,color: Colors.white,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

