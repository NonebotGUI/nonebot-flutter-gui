import 'dart:convert';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:NoneBotGUI/utils/global.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:window_manager/window_manager.dart';

class BroadcastDetail extends StatefulWidget {
  const BroadcastDetail({super.key});

  @override
  State<BroadcastDetail> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<BroadcastDetail> {
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  String md = '';
  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://api.zobyic.top/api/nbgui/broadcast/detail?id=${MainApp.broadcastId}'));
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Row(
            children: [
              Expanded(
                child: MoveWindow(
                  child: AppBar(
                    title: const Text(
                      '公告详情',
                      style: TextStyle(color: Colors.white),
                    ),
                    actions: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.remove_rounded),
                        color: Colors.white,
                        onPressed: () => appWindow.minimize(),
                        iconSize: 20,
                        tooltip: "最小化",
                      ),
                      appWindow.isMaximized
                          ? IconButton(
                              icon: const Icon(Icons.rectangle_outlined),
                              color: Colors.white,
                              onPressed: () => appWindow.restore(),
                              iconSize: 20,
                              tooltip: "恢复大小",
                            )
                          : IconButton(
                              icon: const Icon(Icons.rectangle_outlined),
                              color: Colors.white,
                              onPressed: () => appWindow.maximize(),
                              iconSize: 20,
                              tooltip: "最大化",
                            ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: Colors.white,
                        onPressed: () => windowManager.hide(),
                        iconSize: 20,
                        tooltip: "关闭",
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: md.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator()],
                ),
              )
            : Markdown(
                styleSheet: MarkdownStyleSheet(textScaleFactor: 1.3),
                data: md));
  }
}
