import 'package:NonebotGUI/ui/settings/about.dart';
import 'package:NonebotGUI/ui/settings/setting.dart';
import 'package:flutter/material.dart';

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
                        applicationVersion: '0.1.7',
                        );
                      }));
                    })),
          ],
        ),
      ),
    );
  }
}

