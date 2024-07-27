
import 'dart:convert';

import 'package:NoneBotGUI/darts/utils.dart';
import 'package:NoneBotGUI/ui/manage/managecli.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:NoneBotGUI/ui/manage/stderr.dart';
import 'package:NoneBotGUI/darts/global.dart';


class ManageProtocol extends StatefulWidget {
  const ManageProtocol({super.key});
  @override
  State<ManageProtocol> createState() => _MyCustomFormState();
}


class _MyCustomFormState extends State<ManageProtocol> {
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
    if (gOnOpen.isNotEmpty){
      String filePath = '${getProtocolPath()}/nbgui_stdout.log';
      File stdoutFile = File(filePath);
      if (stdoutFile.existsSync()) {
        try {
          File file = File(filePath);
          final lines = await file.readAsLines(encoding: userProtocolEncoding());
          final last50Lines =
              lines.length > 50 ? lines.sublist(lines.length - 50) : lines;
           protocolLog = last50Lines.join('\n');
            setState(() {
              
            });
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
      getPyPid(userDir);
      _filePath = '${manageBotReadCfgPath()}/nbgui_stdout.log';
      _scrollController.addListener(() {
     });
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut,
    );
    });
  }

  String protocolCMD = getProtocolCmd();
  String _filePath = '${getProtocolPath()}/nbgui_stdout.log';
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
                          '协议端信息',
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.1),
                      const Padding(
                        padding: EdgeInsets.all(4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '路径',
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            getProtocolPath()
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.all(4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '启动命令',
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            getProtocolCmd()
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            manageBotReadCfgTime(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.all(4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '进程ID',
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            getProtocolPid()
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.all(4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '状态',
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      if (getProtocolStatus())
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
                      if (!getProtocolStatus())
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
                              protocolCMD = getProtocolCmd();
                            });
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('编辑属性'),
                                  actions: <Widget>[
                                    SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Column(
                                          children: <Widget>[
                                            const Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text('设置启动命令'),
                                            ),
                                            TextField(
                                              controller: TextEditingController(),
                                              decoration: InputDecoration(
                                                hintText: protocolCMD,
                                              ),
                                              onChanged: (value){
                                                setState(() => protocolCMD = value);
                                              }
                                            ),
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
                                        if (protocolCMD != manageBotReadCfgName()){
                                          reEditCmd(protocolCMD);
                                          setState(() {
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                    ],
                  )
                ),
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              ),
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
                                child: Text(
                                  protocolLog,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'JetBrainsMono',
                                  ),
                                )
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              IconButton(
                                onPressed: () {
                                  if (getProtocolStatus() == false) {
                                    runProtocol();
                                    _reloadConfig();
                                    _startRefreshing();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          '协议端已启动，如果发现控制台无刷新请检查协议端目录下的nbgui_stderr.log查看报错',
                                        ),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('已经在运行中了！'),
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
                                  if (getProtocolStatus()) {
                                    stopProtocol();
                                    _reloadConfig();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('已停止'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('未在运行！'),
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
                                  if (getProtocolStatus()) {
                                    stopProtocol();
                                    runProtocol();
                                    clearLog(userDir);
                                    _reloadConfig();
                                    _startRefreshing();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('正在重启...'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('未在运行！'),
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
                                    openFolder(getProtocolPath().toString()),
                                tooltip: "打开文件夹",
                                icon: const Icon(Icons.folder),
                                iconSize: size.height * 0.03,
                              ),
                              // 下次一定（
                              // IconButton(
                              //  onPressed: () => Navigator.push(
                              //  context,
                              //  MaterialPageRoute(
                              //  builder: (context) => const manageCli(),
                              //   ),
                              //   ),
                              //   tooltip: "显示登录二维码",
                              //   icon: const Icon(Icons.qr_code_rounded),
                              //   iconSize: size.height * 0.03,
                              //   ),
                              IconButton(
                                onPressed: () {
                                  File stdout = File('${getProtocolPath()}/nbgui_stdout.log');
                                  stdout.delete();
                                  String info = "[INFO]Welcome to Nonebot GUI!";
                                  stdout.writeAsString(info);
                                },
                                tooltip: "清空日志",
                                icon: const Icon(Icons.delete_rounded),
                                iconSize: size.height * 0.03,
                              ),
                              Visibility(
                                visible: File('${manageBotReadCfgPath()}/nbgui_stderr.log').readAsStringSync(encoding: systemEncoding).isNotEmpty,
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
              )
            ),
          ],
        ),
      ),
    );
  }
}




