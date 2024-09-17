
import 'package:NoneBotGUI/utils/manage.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class StdErr extends StatefulWidget {
  const StdErr({super.key});

  @override
  State<StdErr> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<StdErr> {
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
                  title: Text(
                    "${Bot.name()} - stderr.log",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.delete_rounded),
                      onPressed: () => _showConfirmationDialog(context),
                      iconSize: 20,
                      tooltip: "删除",
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_rounded),
                      color: Colors.white,
                      onPressed: () => appWindow.minimize(),
                      iconSize: 20,
                      tooltip: "最小化",
                    ),
                    appWindow.isMaximized ?
                      IconButton(
                        icon: const Icon(Icons.rectangle_outlined),
                        color: Colors.white,
                        onPressed: () => appWindow.restore(),
                        iconSize: 20,
                        tooltip: "恢复大小",
                      ) :
                    IconButton(
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
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: 20000,
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(Bot.stderr()))),
            ],
          ),
        ),
      ),
    );
  }
}

void _showConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('删除'),
        content: const Text('你确定要删除吗？'),
        actions: <Widget>[
          TextButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text(
              '确定',
              style: TextStyle(color: Color.fromRGBO(238, 109, 109, 1)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Bot.deleteStderr();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已删除'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}
