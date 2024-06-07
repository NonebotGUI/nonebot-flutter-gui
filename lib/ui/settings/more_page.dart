import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:NonebotGUI/ui/settings/about.dart';
import 'package:NonebotGUI/ui/settings/setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//这段不知道干嘛用的 如果是Test应该放到 /test 文件夹
// void main() {
//   runApp(
//     const More(),
//   );
//
// }

class More extends StatefulWidget {
  const More({super.key});

  @override
  State<More> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<More> {
  final String version = 'v0.1.8+fix3';
  Future<void> check() async{
        try {
          final response = await http.get(Uri.parse('https://api.github.com/repos/NonebotGUI/nonebot-flutter-gui/releases/latest'));
          if (response.statusCode == 200) {
              final jsonData = jsonDecode(response.body);
              final tagName = jsonData['tag_name']; 
              final changeLog = jsonData['body'];
              final url = jsonData['html_url'];
              if (tagName != version){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('发现新版本！'),
                duration: Duration(seconds: 3),
              ));
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('有新的版本：$tagName'),
                    content: Text(changeLog),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('复制url'),
                        onPressed: (){
                          Clipboard.setData(ClipboardData(text: url));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('已复制到剪贴板'),
                            duration: Duration(seconds: 3),
                          ));
                        },
                      ),
                      TextButton(
                        child: const Text('确定'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
              }
              else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('暂无新版本'),
                duration: Duration(seconds: 3),
              ));
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('检查更新失败（${response.statusCode}）'),
                duration: const Duration(seconds: 3),
              ));
            }
          } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('错误：$e'),
                duration: const Duration(seconds: 3),
              ));
          }
  }

  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "更多",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
                height: 80,
                child: InkWell(
                    child: const Card(
                      child: Row(
                        children: <Widget>[
                          Text('  设置'),
                          Icon(Icons.keyboard_arrow_right_rounded)
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const Settings();
                      }));
                    })),
            SizedBox(
                height: 80,
                child: InkWell(
                    child: const Card(
                      child: Row(
                        children: <Widget>[
                          Text('  关于NonebotGUI'),
                          Icon(Icons.keyboard_arrow_right_rounded)
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const About();
                      }));
                    })),
            SizedBox(
                height: 80,
                child: InkWell(
                    child: const Card(
                      child: Row(
                        children: <Widget>[
                          Text('  开源许可证'),
                          Icon(Icons.keyboard_arrow_right_rounded)
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return LicensePage(
                        applicationIcon: Image.asset('lib/assets/logo.png'),
                        applicationName: 'NonebotGUI',
                        applicationVersion: '0.1.8',
                        );
                      }));
                    })),
            SizedBox(
                height: 80,
                child: InkWell(
                    child: const Card(
                      child: Row(
                        children: <Widget>[
                          Text('  检查更新'),
                          Icon(Icons.update_rounded)
                        ],
                      ),
                    ),
                    onTap: () {
                      check();
                    })),
          ],
        ),
      ),
    );
  }
}

