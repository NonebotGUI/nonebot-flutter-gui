import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:NoneBotGUI/darts/global.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;


class BroadcastDetail extends StatefulWidget {
  const BroadcastDetail({super.key});

  @override
  State<BroadcastDetail> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<BroadcastDetail> {


  //拉取公告列表
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  String md = '';
  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('https://api.zobyic.top/api/nbgui/broadcast/detail?id=$broadcastId'));
    if (response.statusCode == 200) {
      setState(() {
        String decodedBody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> jsonMap = json.decode(decodedBody);
        md = jsonMap['content'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "公告详情",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: md.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator()
                ],
              ),
            )
          : Markdown(
            data: md
          )
    );
  }
}

