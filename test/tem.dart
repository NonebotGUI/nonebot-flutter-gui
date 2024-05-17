import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text(
          "1",
          style: TextStyle(color: Colors.white),
        ),
        actions: const <Widget>[
        ],
        backgroundColor: const Color.fromRGBO(238, 109, 109, 1),
      ),
    );
  }
}

