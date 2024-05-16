import 'package:NonebotGUI/ui/settings/about.dart';
import 'package:NonebotGUI/ui/settings/setting.dart';
import 'package:flutter/material.dart';
import 'package:NonebotGUI/darts/utils.dart';


void main() {
  runApp(
    More(),
  );

}
class More extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: more(),
    );
  }
}




class more extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<more> {

  final myController = TextEditingController();







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "更多",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: userColorMode() == 'light'
          ? const Color.fromRGBO(238, 109, 109, 1)
          : const Color.fromRGBO(127, 86, 151, 1),
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
                        return settings();
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
                        return About();
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
                        return const LicensePage();
                      }));
                    })),          
          ],
        ),
      ),
    );
  }
}

