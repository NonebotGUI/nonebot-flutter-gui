import 'package:NoneBotGUI/ui/manage/managecli.dart';
import 'package:NoneBotGUI/utils/core.dart';
import 'package:NoneBotGUI/utils/manage.dart';
import 'package:NoneBotGUI/utils/userConfig.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:NoneBotGUI/ui/manage/stderr.dart';
import 'package:NoneBotGUI/utils/global.dart';

class ManageBot extends StatefulWidget {
  const ManageBot({super.key});
  @override
  State<ManageBot> createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<ManageBot> {
  Timer? _timer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    getDir();
    super.initState();
    loadFileContent();
    _startRefreshing();
  }

  String getDir() {
    return userDir;
  }

  void _startRefreshing() {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => loadFileContent(),
    );
  }

  void loadFileContent() async {
    if (gOnOpen.isNotEmpty) {
      String filePath = '${Bot.path()}/nbgui_stdout.log';
      File stdoutFile = File(filePath);
      if (stdoutFile.existsSync()) {
        try {
          File file = File(filePath);
          final lines =
              await file.readAsLines(encoding: UserConfig.botEncoding());
          final last50Lines =
              lines.length > 50 ? lines.sublist(lines.length - 50) : lines;
          MainApp.nbLog = last50Lines.join('\n');
          //Bot.pypid(Bot.path());
          setState(() {});
        } catch (e) {
          print('Error: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer?.cancel();
    }
  }

  void _reloadConfig() {
    setState(() {
      //Bot.setPyPid(pid);
      _filePath = '${Bot.path()}/nbgui_stdout.log';
      _scrollController.addListener(() {});
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.easeOut,
      );
    });
  }

  String name = Bot.name();
  String _filePath = '${Bot.path()}/nbgui_stdout.log';
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: size.width * 0.3,
              child: Card(
                  child: Column(
                children: <Widget>[
                  const Center(
                    child: Text(
                      'Bot信息',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),
                  //有bug，暂时不用
                  // DropdownButton<String>(
                  //   value: gOnOpen,
                  //   icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  //   elevation: 16,
                  //   onChanged: (String? value) {
                  //     setState(() => gOnOpen = value!);
                  //   },
                  //   items: botList
                  //       .map<DropdownMenuItem<String>>(
                  //         (String value) => DropdownMenuItem<String>(
                  //           value: value,
                  //           child: Padding(
                  //             padding: const EdgeInsets.all(4.0),
                  //             child: Text(value.replaceAll('.${value.split('.').last}', '')),
                  //           ),
                  //         ),
                  //       )
                  //       .toList(),
                  // ),
                  SizedBox(height: size.height * 0.05),
                  const Padding(
                    padding: EdgeInsets.all(4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '名称',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Bot.name(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.all(4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '路径',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Bot.path(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.all(4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '创建时间',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Bot.time(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.all(4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '进程ID(Nonebot)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Bot.pid(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // const Padding(
                  //   padding: EdgeInsets.all(4),
                  //   child: Align(
                  //     alignment: Alignment.centerLeft,
                  //     child: Text(
                  //       '进程ID(Python)',
                  //       style: TextStyle(fontWeight: FontWeight.bold),
                  //     ),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(4),
                  //   child: Align(
                  //     alignment: Alignment.centerLeft,
                  //     child: Text(
                  //       Bot.pypid(Bot.path()),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.all(4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '状态',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (Bot.status() == 'true')
                    const Padding(
                      padding: EdgeInsets.all(4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '运行中',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                  if (Bot.status() == 'false')
                    const Padding(
                      padding: EdgeInsets.all(4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '未运行',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  SizedBox(
                    width: size.width * 0.2,
                    child: OutlinedButton(
                        child: const Icon(Icons.edit_rounded),
                        onPressed: () {
                          setState(() {
                            name = Bot.name();
                          });
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('编辑Bot属性'),
                                actions: <Widget>[
                                  SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Column(
                                        children: <Widget>[
                                          const Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text('重命名Bot'),
                                          ),
                                          TextField(
                                              controller:
                                                  TextEditingController(),
                                              decoration: InputDecoration(
                                                hintText: name,
                                              ),
                                              onChanged: (value) {
                                                setState(() => name = value);
                                              }),
                                        ],
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    child: const Text(
                                      '保存',
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      if (name != Bot.name()) {
                                        Bot.rename(name);
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }),
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  SizedBox(
                    width: size.width * 0.2,
                    child: OutlinedButton(
                      child: const Icon(Icons.delete_rounded),
                      onPressed: () => _showConfirmationDialog(context),
                    ),
                  )
                ],
              )),
            ),
            Expanded(
                child: Column(
              children: <Widget>[
                Card(
                  child: Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '控制台输出',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        width: size.width * 0.65,
                        height: size.height * 0.75,
                        child: Card(
                          color: const Color.fromARGB(255, 31, 28, 28),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'JetBrainsMono',
                                  ),
                                  children: _logSpans(MainApp.nbLog),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Expanded(
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '操作',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              IconButton(
                                onPressed: () {
                                  if (Bot.status() == 'false') {
                                    Bot.run();
                                    _reloadConfig();
                                    _startRefreshing();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Nonebot,启动！如果发现控制台无刷新请检查bot目录下的nbgui_stderr.log查看报错',
                                        ),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Bot已经在运行中了！'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                },
                                tooltip: "运行",
                                icon: const Icon(Icons.play_arrow_rounded),
                                iconSize: size.height * 0.03,
                              ),
                              IconButton(
                                onPressed: () {
                                  if (Bot.status() == 'true') {
                                    Bot.stop();
                                    _reloadConfig();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Bot已停止'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Bot未在运行！'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                },
                                tooltip: "停止",
                                icon: const Icon(Icons.stop_rounded),
                                iconSize: size.height * 0.03,
                              ),
                              IconButton(
                                onPressed: () {
                                  if (Bot.status() == 'true') {
                                    Bot.stop();
                                    Bot.run();
                                    clearLog(Bot.path());
                                    _reloadConfig();
                                    _startRefreshing();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Bot正在重启...'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Bot未在运行！'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                },
                                tooltip: "重启",
                                icon: const Icon(Icons.refresh),
                                iconSize: size.height * 0.03,
                              ),
                              IconButton(
                                onPressed: () =>
                                    openFolder(Bot.path().toString()),
                                tooltip: "打开文件夹",
                                icon: const Icon(Icons.folder),
                                iconSize: size.height * 0.03,
                              ),
                              IconButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const manageCli(),
                                  ),
                                ),
                                tooltip: "管理CLI",
                                icon: const Icon(Icons.terminal_rounded),
                                iconSize: size.height * 0.03,
                              ),
                              IconButton(
                                onPressed: () {
                                  if (Bot.status() == 'true') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('请先停止后再清空！'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  } else {
                                    clearLog(Bot.path());
                                  }
                                },
                                tooltip: "清空日志",
                                icon: const Icon(Icons.delete_rounded),
                                iconSize: size.height * 0.03,
                              ),
                              Visibility(
                                visible: File('${Bot.path()}/nbgui_stderr.log')
                                    .readAsStringSync(encoding: systemEncoding)
                                    .isNotEmpty,
                                child: IconButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const StdErr(),
                                    ),
                                  ),
                                  tooltip: '查看报错日志',
                                  icon: const Icon(Icons.error_rounded),
                                  color: Colors.red,
                                  iconSize: size.height * 0.04,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )),
          ],
        ),
      ),
    );
  }
}

///终端字体颜色
//这一段AI写的我什么也不知道😭
List<TextSpan> _logSpans(text) {
  RegExp regex = RegExp(
    r'(\[[A-Z]+\])|(nonebot \|)|(uvicorn \|)|(Env: dev)|(Env: prod)|(Config)|(nonebot_plugin_[\S]+)|("nonebot_plugin_[\S]+)|(使用 Python: [\S]+)|(Loaded adapters: [\S]+)|(\d{2}-\d{2} \d{2}:\d{2}:\d{2})|(Calling API [\S]+)',
  );
  List<TextSpan> spans = [];
  int lastEnd = 0;

  for (Match match in regex.allMatches(text)) {
    if (match.start > lastEnd) {
      spans.add(TextSpan(
        text: text.substring(lastEnd, match.start),
        style: const TextStyle(color: Colors.white),
      ));
    }

    Color color;
    switch (match.group(0)) {
      case '[SUCCESS]':
        color = Colors.greenAccent;
        break;
      case '[INFO]':
        color = Colors.white;
        break;
      case '[WARNING]':
        color = Colors.orange;
        break;
      case '[ERROR]':
        color = Colors.red;
        break;
      case '[DEBUG]':
        color = Colors.blue;
        break;
      case 'nonebot |':
        color = Colors.green;
        break;
      case 'uvicorn |':
        color = Colors.green;
        break;
      case 'Env: dev':
        color = Colors.orange;
        break;
      case 'Env: prod':
        color = Colors.orange;
        break;
      case 'Config':
        color = Colors.orange;
        break;
      default:
        if (match.group(0)!.startsWith('nonebot_plugin_')) {
          color = Colors.yellow;
        } else if (match.group(0)!.startsWith('"nonebot_plugin_')) {
          color = Colors.yellow;
        } else if (match.group(0)!.startsWith('Loaded adapters:')) {
          color = Colors.greenAccent;
        } else if (match.group(0)!.startsWith('使用 Python:')) {
          color = Colors.greenAccent;
        } else if (match.group(0)!.startsWith('Calling API')) {
          color = Colors.purple;
        } else if (match.group(0)!.contains('-') &&
            match.group(0)!.contains(':')) {
          color = Colors.green;
        } else {
          color = Colors.white;
        }
        break;
    }

    spans.add(TextSpan(
      text: match.group(0),
      style: TextStyle(color: color),
    ));

    lastEnd = match.end;
  }
  if (lastEnd < text.length) {
    spans.add(TextSpan(
      text: text.substring(lastEnd),
      style: const TextStyle(color: Colors.white),
    ));
  }

  return spans;
}

void _showConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('删除'),
        content: const Text('你确定要删除这个Bot吗？'),
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
              if (Bot.status() == 'true') {
                Bot.stop();
              }
              Bot.delete();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Bot已删除'),
                duration: Duration(seconds: 3),
              ));
            },
          ),
          TextButton(
            child: const Text(
              '确定（连同bot目录一起删除）',
              style: TextStyle(color: Color.fromRGBO(255, 0, 0, 1)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              if (Bot.status() == 'true') {
                Bot.stop();
              }
              Bot.deleteForever();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Bot已删除'),
                duration: Duration(seconds: 3),
              ));
            },
          ),
        ],
      );
    },
  );
}
