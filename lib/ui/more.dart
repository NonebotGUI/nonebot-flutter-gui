import 'package:flutter/material.dart';
import 'package:NonebotGUI/darts/utils.dart';
import 'package:NonebotGUI/assets/my_flutter_app_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' show Platform;
import 'dart:io';
import 'package:flutter/services.dart';

class More extends StatefulWidget {
  const More({super.key});

  @override
  State<More> createState() => _MoreState();
}

class _MoreState extends State<More> {
  int tapCount = 0;
  final int tapsToReveal = 9;
  bool showImage = false;
  String? _pythonPath;
  String? _nbcliPath;

  void _selectpy() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setPyPath(result.files.single.path.toString());
      setState(() {
        _pythonPath = result.files.single.path.toString();
      });
    }
  }

  void _selectnbcli() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setNbcliPath(result.files.single.path.toString());
      setState(() {
        _nbcliPath = result.files.single.path.toString();
      });
    }
  }

  void _handleTap() {
    setState(() {
      tapCount++;
      if (tapCount >= tapsToReveal) {
        showImage = true;
      }
    });
  }

  void _resetCounter() {
    setState(() {
      tapCount = 0;
      showImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "更多",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromRGBO(238, 109, 109, 1),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Clipboard.setData(const ClipboardData(
                    text:
                        'https://github.com/XTxiaoting14332/nonebot-flutter-gui'));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('项目仓库链接已复制到剪贴板'),
                  duration: Duration(seconds: 3),
                ));
              },
              icon: const Icon(MyFlutterApp.github),
              tooltip: '项目仓库地址',
              iconSize: 30,
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: <Widget>[
            Center(
              child: Image.asset(
                'lib/assets/logo.png',
                width: MediaQuery.of(context).size.width * 0.2,
                height: null,
                fit: BoxFit.contain,
              ),
            ),
            Center(
                child: Text(
              "NoneBot GUI",
              //TODO: Deprecated API use, please use the latest API for secure
              style: TextStyle(
                  fontSize: MediaQuery.of(context).textScaleFactor * 35.0,
                  fontWeight: FontWeight.bold),
            )),
            const Center(
              child: Text(
                "_✨新一代NoneBot图形化界面✨_",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            const Divider(
              height: 20,
              thickness: 2,
              indent: 20,
              endIndent: 20,
              color: Colors.grey,
            ),
            const SizedBox(
              height: 8,
            ),
            Row(children: <Widget>[
              const Expanded(
                  child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '软件版本',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )),
              Expanded(
                  child: Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  child: const Text('0.1.5.1'),
                  onTap: () {
                    if (showImage) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Material(
                            color: Colors.transparent,
                            child: Center(
                              child: AlertDialog(
                                title: Row(
                                  children: <Widget>[
                                    Image.asset(
                                      'lib/assets/loading.gif',
                                      width: 180 * 0.15,
                                      height: 180 * 0.15,
                                    ),
                                    const Text('UWU')
                                  ],
                                ),
                                content: InkWell(
                                  child: Image.asset('lib/assets/colorEgg.png'),
                                  onTap: () {
                                    _resetCounter();
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      _handleTap();
                    }
                  },
                ),
              ))
            ]),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: <Widget>[
                const Expanded(
                    child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '平台',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(Platform.operatingSystem[0].toUpperCase() +
                        Platform.operatingSystem.substring(1)),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(children: <Widget>[
              const Expanded(
                  child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '当前Python环境',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )),
              Expanded(
                  child: Align(
                alignment: Alignment.centerRight,
                child: FutureBuilder<String>(
                  future: getpyver(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data.toString());
                    } else if (snapshot.hasError) {
                      return const Text('你似乎还没安装Python？');
                    } else {
                      return const Text('获取中...');
                    }
                  },
                ),
              ))
            ]),
            const SizedBox(
              height: 16,
            ),
            Row(children: <Widget>[
              const Expanded(
                  child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '当前nb-cli版本',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )),
              Expanded(
                  child: Align(
                alignment: Alignment.centerRight,
                child: FutureBuilder<String>(
                  future: getnbcliver(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                          snapshot.data.toString().replaceAll('nb: ', ''));
                    } else if (snapshot.hasError) {
                      return const Text('你似乎还没安装nb-cli？');
                    } else {
                      return const Text('获取中...');
                    }
                  },
                ),
              ))
            ]),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: <Widget>[
                Expanded(
                    child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '选择Python命令路径[$_pythonPath]',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                )),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: _selectpy,
                      tooltip: "选择Python命令路径",
                      icon: const Icon(Icons.file_open_rounded),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: <Widget>[
                Expanded(
                    child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '选择nb-cli命令路径[$_nbcliPath]',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                )),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: _selectnbcli,
                      tooltip: "选择nb-cli命令路径",
                      icon: const Icon(Icons.file_open_rounded),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    setPyPath('default');
                    setState(() {});
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('重置Python路径',
                      style: TextStyle(
                        color: Color.fromRGBO(238, 109, 109, 1),
                      )),
                ),
                const SizedBox(
                  width: 15,
                ),
                TextButton(
                  onPressed: () {
                    setNbcliPath('default');
                    setState(() {});
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('重置nb-cli路径',
                      style: TextStyle(
                        color: Color.fromRGBO(238, 109, 109, 1),
                      )),
                ),
              ],
            ),
          ]),
        ));
  }
}
