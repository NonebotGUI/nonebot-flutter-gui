import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

// 这段无意义的main不知道有什么用Test应该放到 /test 进行
// 如果只是检查单页状态，可以在DEBUG Console里面调用NavPush来跳转路由
// void main() {
//   runApp(
//     const MyApp(),
//   );
//
// }
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Template(),
//     );
//   }
// }

class Template extends StatefulWidget {
  const Template({super.key});

  @override
  State<Template> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Template> {

  final myController = TextEditingController();

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
                  title: Text("data"),
                  actions: <Widget>[
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
        backgroundColor: const Color.fromRGBO(238, 109, 109, 1),
    );
  }
}

