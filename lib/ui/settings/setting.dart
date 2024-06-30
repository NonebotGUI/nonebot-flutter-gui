import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:NoneBotGUI/darts/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:NoneBotGUI/darts/global.dart';
import 'package:flutter/services.dart';

// void main() {
//   runApp(
//     Settings(),
//   );
// }

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Settings> {

  void _selectPy() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setPyPath(userDir, result.files.single.path.toString());
    }
  }

  void _selectNbCli() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setNbcliPath(userDir, result.files.single.path.toString());
    }
  }

  final List<String> colorMode = ['light', 'dark'];
  late String dropDownValue = userColorMode(userDir);
  bool checkUpdate = userCheckUpdate();

    void _toggleCheckUpdate(bool newValue) {
    setState(() {
      checkUpdate = newValue;
      setCheckUpdate(checkUpdate);
    });
  }

  ///检查更新
  Future<void> check() async{
    //如果“检查更新”为开启则检查
    if (userCheckUpdate()){
        try {
          final response = await http.get(Uri.parse('https://api.github.com/repos/NoneBotGUI/nonebot-flutter-gui/releases/latest'));
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
                height: 80,
                child: Card(
                  child: Row(
                    children: <Widget>[
                      const Expanded(child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(' 颜色主题'),
                      )),
                      Expanded(child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child:  DropdownButton<String>(
                        value: dropDownValue,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        elevation: 16,
                        onChanged: (String? value) {
                          setState(() {
                            dropDownValue = value!;
                            setColorMode(userDir,dropDownValue);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('已更改，重启应用后生效'),
                            duration: Duration(seconds: 3),
                          ));
                          });
                        },
                        items: colorMode.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                        ),
                      ))
                    ],
                  ),
                ),
            ),
            const SizedBox(height: 4,),
            SizedBox(
                height: 80,
                child: Card(
                  child: Row(
                    children: <Widget>[
                      const Expanded(child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(' 是否自动检查更新'),
                      )),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Switch(
                        value: checkUpdate,
                        onChanged: _toggleCheckUpdate,
                        focusColor: Colors.black,
                        inactiveTrackColor: Colors.grey,
                      ),
                    ),
                  ),
                    ],
                  ),
                ),
            ),
            const SizedBox(height: 4,),
            SizedBox(
                height: 80,
                child: InkWell(
                    child: const Card(
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(' 更改Python路径'),
                          )),
                          Expanded(child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(padding: EdgeInsets.all(4),
                            child: Icon(Icons.file_open_rounded),),
                          )),
                        ],
                      ),
                    ),
                    onTap: () {
                      _selectPy();
                    })),
                    const SizedBox(height: 4,),
            SizedBox(
                height: 80,
                child: InkWell(
                    child: const Card(
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(' 重置Python路径'),
                          )),
                          Expanded(child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(padding: EdgeInsets.all(4),
                            child: Icon(Icons.refresh_rounded),),
                          )),
                        ],
                      ),
                    ),
                    onTap: () {
                      setPyPath(userDir, 'default');
                    })),
                    const SizedBox(height: 4,),
            SizedBox(
                height: 80,
                child: InkWell(
                    child: const Card(
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(' 更改nb-cli路径'),
                          )),
                          Expanded(child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(padding: EdgeInsets.all(4),
                            child: Icon(Icons.file_open_rounded),),
                          )),
                        ],
                      ),
                    ),
                    onTap: () {
                      _selectNbCli();
                    })),
                    const SizedBox(height: 4,),
            SizedBox(
                height: 80,
                child: InkWell(
                    child: const Card(
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(' 重置nb-cli路径'),
                          )),
                          Expanded(child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(padding: EdgeInsets.all(4),
                            child: Icon(Icons.refresh_rounded),),
                          )),
                        ],
                      ),
                    ),
                    onTap: () {
                      setNbcliPath(userDir, 'default');
                    })),
                    const SizedBox(height: 4,),
            SizedBox(
                height: 80,
                child: InkWell(
                    child: const Card(
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(' 检查更新'),
                          )),
                          Expanded(child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(padding: EdgeInsets.all(4),
                            child: Icon(Icons.update_rounded),),
                          )),
                        ],
                      ),
                    ),
                    onTap: () {
                      check();
                    })),
                    const SizedBox(height: 4,),
            SizedBox(
                height: 80,
                child: InkWell(
                    child: const Card(
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(' 旧版本数据迁移指南'),
                          )),
                          Expanded(child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(padding: EdgeInsets.all(4),
                            child: Icon(Icons.account_box_rounded),),
                          )),
                        ],
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Material(
                            color: Colors.transparent,
                            child: Center(
                              child: AlertDialog(
                                title: const Row(
                                  children: <Widget>[
                                    Text('旧版本数据移动指南')
                                  ],
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: <Widget>[
                                      const Text(
                                        '''
                                        NoneBotGUI从0.1.7版本开始，开始使用path_provider提供用户目录。这意味着你需要将旧版本的数据迁移至新版本的目录下
                                        步骤1：打开用户目录
                                        Windows下：C:\\Users\\用户名
                                        Linux或MacOS下：/home/用户名
                                        步骤2：找到.nbgui文件夹 在用户目录中，找到名为.nbgui的文件夹（如果找不到请打开“显示隐藏文件”选项）
                                        步骤3：将.nbgui文件夹中的所有文件和目录复制到新版本目录下。
                                        '''
                                      ),
                                      const SizedBox(height: 8,),
                                      const Text('新版本目录路径为：'),
                                      Center(
                                        child: Text(userDir),
                                      )
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                          text:'$userDir'));
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text('已复制到剪贴板'),
                                        duration: Duration(seconds: 3),
                                      ));
                                    },
                                    child: Text(
                                      '复制新版本路径',
                                      style: TextStyle(color: Colors.red[300]),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: (){
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      '关闭',
                                      style: TextStyle(color: Colors.red[300]),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    })),
                    const SizedBox(height: 4,),
          ],
        ),
      )
    );
  }
}

