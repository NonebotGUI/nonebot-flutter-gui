import 'dart:convert';
import 'dart:io';
import 'package:NoneBotGUI/utils/core.dart';
import 'package:NoneBotGUI/utils/userConfig.dart';
import 'package:http/http.dart' as http;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:NoneBotGUI/utils/global.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';


class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Settings> {
  void _selectPy() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      UserConfig.setPythonPath(result.files.single.path.toString());
    }
  }

  void _selectNbCli() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      UserConfig.setNbcliPath(result.files.single.path.toString());
    }
  }

  final List<String> colorMode = ['light', 'dark'];
  final List<String> encoding = ['systemEncoding', 'utf8'];
  final List<String> httpEncoding = ['utf8', 'systemEncoding'];
  final List<String> deployEncoding = ['utf8', 'systemEncoding'];
  final List<String> botEcoding = ['systemEncoding', 'utf8'];
  final List<String> protocolEncoding = ['utf8', 'systemEncoding'];
  final List<String> mirror = ['https://registry.nonebot.dev', 'https://api.nbgui.top/api/nbgui/proxy', 'https://api.zobyic.top/api/nbgui/proxy'];
  final List<String> refreshMode = ['auto', 'always'];



  late String dropDownValueRefresh = UserConfig.refreshMode();
  late String dropDownValueMirror = UserConfig.mirror();
  late String dropDownValue = UserConfig.colorMode();
  late String dropDownValueEncoding =
      (UserConfig.encoding() == systemEncoding) ? 'systemEncoding' : 'utf8';
  late String dropDownValueHttpEncoding =
      (UserConfig.httpEncoding() == systemEncoding) ? 'systemEncoding' : 'utf8';
  late String dropDownValueBotEncoding =
      (UserConfig.botEncoding() == systemEncoding) ? 'systemEncoding' : 'utf8';
  late String dropDownValueProtocolEncoding =
      (UserConfig.protocolEncoding() == systemEncoding) ? 'systemEncoding' : 'utf8';
  late String dropDownValueDeployEncoding =
      (UserConfig.deployEncoding() == systemEncoding) ? 'systemEncoding' : 'utf8';
  bool checkUpdate = UserConfig.checkUpdate();

  void _toggleCheckUpdate(bool newValue) {
    setState(() {
      checkUpdate = newValue;
      UserConfig.setCheckUpdate(checkUpdate);
    });
  }

  ///检查更新
  Future<void> check() async {
    //如果“检查更新”为开启则检查
    if (UserConfig.checkUpdate()) {
      try {
        final response = await http.get(Uri.parse(
            'https://api.github.com/repos/NoneBotGUI/nonebot-flutter-gui/releases/latest'));
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          final tagName = jsonData['tag_name'];
          final changeLog = jsonData['body'];
          final url = jsonData['html_url'];
          if (tagName != MainApp.version) {
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
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: url));
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
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
            child: Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          const Row(
            children: <Widget>[
              Text(
                '常规',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          ListTile(
            title: const Text('颜色主题'),
            trailing: DropdownButton<String>(
              value: dropDownValue,
              onChanged: (String? newValue) {
                setState(() {
                  dropDownValue = newValue!;
                  UserConfig.setColorMode(newValue);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('已更改，重启后生效'),
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
          const SizedBox(height: 4),
          ListTile(
            title: Row(
              children: <Widget>[
                const Text('刷新策略'),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.help_outline_rounded),
                  onPressed: () => refreshToolTip(context),
                  iconSize: 20,
                )
              ],
            ),
            trailing: DropdownButton<String>(
              value: dropDownValueRefresh,
              onChanged: (String? newValue) {
                setState(() {
                  dropDownValueRefresh = newValue!;
                  UserConfig.setRefreshMode(newValue);
                  Clipboard.setData(ClipboardData(text: userDir));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('已更改，重启后生效'),
                    duration: Duration(seconds: 3),
                  ));
                });
              },
              items: refreshMode.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: const Text('是否自动检查更新'),
            trailing: Switch(
              value: checkUpdate,
              onChanged: _toggleCheckUpdate,
              focusColor: Colors.black,
              inactiveTrackColor: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          ListTile(
            title: const Text('检查更新'),
            onTap: check,
          ),
          const SizedBox(height: 8),
          const Divider(),
          const Row(
            children: <Widget>[
              Text(
                '编码',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          ListTile(
            title: const Text('应用程序编码'),
            trailing: DropdownButton<String>(
              value: dropDownValueEncoding,
              onChanged: (String? newValue) {
                setState(() {
                  dropDownValueEncoding = newValue!;
                  UserConfig.setEncoding(newValue);
                });
              },
              items: encoding.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          ListTile(
            title: const Text('HTTP编码'),
            trailing: DropdownButton<String>(
              value: dropDownValueHttpEncoding,
              onChanged: (String? newValue) {
                setState(() {
                  dropDownValueHttpEncoding = newValue!;
                  UserConfig.setHttpEncoding(newValue);
                });
              },
              items: httpEncoding.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          ListTile(
            title: const Text('部署控制台编码'),
            trailing: DropdownButton<String>(
              value: dropDownValueDeployEncoding,
              onChanged: (String? newValue) {
                setState(() {
                  dropDownValueDeployEncoding = newValue!;
                  UserConfig.setDeployEncoding(newValue);
                });
              },
              items:
                  deployEncoding.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          ListTile(
            title: const Text('Bot控制台编码'),
            trailing: DropdownButton<String>(
              value: dropDownValueBotEncoding,
              onChanged: (String? newValue) {
                setState(() {
                  dropDownValueBotEncoding = newValue!;
                  UserConfig.setBotEncoding(newValue);
                });
              },
              items: botEcoding.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          ListTile(
            title: const Text('协议端控制台编码'),
            trailing: DropdownButton<String>(
              value: dropDownValueProtocolEncoding,
              onChanged: (String? newValue) {
                setState(() {
                  dropDownValueProtocolEncoding = newValue!;
                  UserConfig.setProtocolEncoding(newValue);
                });
              },
              items: protocolEncoding
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const Row(
            children: <Widget>[
              Text(
                '路径',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          ListTile(
            title: const Text('Python路径'),
            subtitle: Text(UserConfig.pythonPath()),
            onTap: _selectPy,
          ),
          const SizedBox(height: 4),
          ListTile(
            title: const Text('NoneBotCLI路径'),
            subtitle: Text(UserConfig.nbcliPath()),
            onTap: _selectNbCli,
          ),
          const SizedBox(height: 4),
          ListTile(
            title: const Text('重置Python路径'),
            onTap: () {
              UserConfig.setPythonPath('default');
            },
          ),
          const SizedBox(height: 4),
          ListTile(
            title: const Text('重置NoneBotCLI路径'),
            onTap: () {
              UserConfig.setNbcliPath('default');
            },
          ),
          const SizedBox(height: 8),
          const Divider(),
          const Row(
            children: <Widget>[
              Text(
                '其他',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          ListTile(
            title: const Text('Registry镜像'),
            trailing: DropdownButton<String>(
              value: dropDownValueMirror,
              onChanged: (String? newValue) {
                setState(() {
                  dropDownValueMirror = newValue!;
                  UserConfig.setMirror(newValue);
                });
              },
              items: mirror.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          ListTile(
            title: const Text('旧版本数据迁移指南'),
            trailing: const Icon(Icons.account_box_rounded),
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
                          children: <Widget>[Text('旧版本数据移动指南')],
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              const Text('''
                                            NoneBotGUI从0.1.7版本开始，开始使用path_provider提供用户目录。这意味着你需要将旧版本的数据迁移至新版本的目录下
                                            步骤1：打开用户目录
                                            Windows下：C:\\Users\\用户名
                                            Linux或MacOS下：/home/用户名
                                            步骤2：找到.nbgui文件夹 在用户目录中，找到名为.nbgui的文件夹（如果找不到请打开“显示隐藏文件”选项）
                                            步骤3：将.nbgui文件夹中的所有文件和目录复制到新版本目录下。
                                            '''),
                              const SizedBox(
                                height: 8,
                              ),
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
                              Clipboard.setData(
                                  ClipboardData(text: '$userDir'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
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
                            onPressed: () {
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
            },
          ),
          const SizedBox(height: 4),
          ListTile(
            title: const Text('复制数据目录路径'),
            trailing: IconButton(
              icon: const Icon(Icons.folder_rounded),
              onPressed: () => openFolder(userDir),
              tooltip: "直接打开",
            ),
            onTap: () {
              Clipboard.setData(ClipboardData(text: userDir));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('已复制到剪贴板'),
                duration: Duration(seconds: 3),
              ));
            },
          ),
          const SizedBox(height: 4),
          ListTile(
            title: const Text('捐赠'),
            trailing: const Icon(Icons.star_rounded),
            subtitle: const Text('您的支持是我们最大的动力！'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('选择支付方式'),
                    content: Row(
                          children: <Widget>[
                            Expanded(
                              child: InkWell(
                                child: SvgPicture.asset(
                                  'lib/assets/alipay.svg',
                                  width: 70,
                                  color: UserConfig.colorMode() == 'dark' ? Colors.white : Colors.black,
                                ),
                                onTap: () => donate_alipay(context),
                              )
                            ),
                            const SizedBox(
                              width: 50,
                            ),
                            Expanded(
                              child: InkWell(
                                child: SvgPicture.asset(
                                  'lib/assets/wechat.svg',
                                  width: 70,
                                  color: UserConfig.colorMode() == 'dark' ? Colors.white : Colors.black,
                                ),
                                onTap: () => donate_wechat(context),
                              )
                            ),
                            const SizedBox(
                              width: 50,
                            ),
                            Expanded(
                              child: InkWell(
                                child: SvgPicture.asset(
                                  'lib/assets/aifadian.svg',
                                  width: 70,
                                  color: UserConfig.colorMode() == 'dark' ? Colors.white : Colors.black,
                                ),
                                onTap: () {
                                  Clipboard.setData(
                                      const ClipboardData(text: 'https://afdian.com/a/NoneBotGUI'));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text('爱发电url已复制到剪贴板'),
                                    duration: Duration(seconds: 3),
                                  ));
                                },
                              )
                            )
                          ],
                        ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('关闭'),
                      )
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
    )));
  }
}

void donate_wechat(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('微信'),
        content: Image.asset(
            'lib/assets/donate_wechat.png',
            fit: BoxFit.cover,
          ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('关闭'),
          )
        ],
      );
    },
  );
}

void donate_alipay(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('支付宝'),
        content: Image.asset(
            'lib/assets/donate_alipay.png',
            fit: BoxFit.cover,
          ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('关闭'),
          )
        ],
      );
    },
  );
}

void refreshToolTip(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('关于刷新策略'),
        content: const Text(
          '''
          auto(推荐): 当数据目录下的文件发生变化时自动刷新，有时候可能会出现无法刷新的情况;磁盘io占用较低
          always: 无脑刷新，每1.5s刷新一次页面，同时进行一次文件读写，磁盘io频率较高
          '''
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('关闭'),
          )
        ],
      );
    },
  );
}