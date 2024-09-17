import 'dart:convert';
import 'package:NoneBotGUI/utils/global.dart';
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
    await http.get(Uri.parse('https://api.nbgui.top/api/nbgui/broadcast/list/'));
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
    MainApp.broadcastId = broadcast['id'];
    Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BroadcastDetail(),
          ),
        );
  },
  child: Card(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      broadcast['name'].toString().substring(0,  broadcast['name'].length - 3),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  broadcast['time'],
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).textScaleFactor * 12,
                    color: Colors.grey[550]
                    ),
                ),
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
          :  Container(
            margin: const EdgeInsets.fromLTRB(32, 20, 32, 12),
            child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 6 / 1,
            mainAxisExtent: 100
          ),
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) =>
              list(data[index]),
        ),
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

