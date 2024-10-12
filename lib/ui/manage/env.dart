import 'dart:io';

import 'package:NoneBotGUI/utils/manage.dart';
import 'package:NoneBotGUI/utils/userConfig.dart';
import 'package:flutter/material.dart';

class EditEnv extends StatefulWidget {
  const EditEnv({super.key});

  @override
  State<EditEnv> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<EditEnv> {
  int _selectedIndex = 0;
  List<String> _envList = ['.env', '.env.prod', '.env.dev'];
  List<String> _envContent = [];
  String envFile = '.env';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      envFile = _envList[index];
      _loadEnv();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadEnv();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.file_copy_rounded),
            label: '.env',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_copy_rounded),
            label: '.env.prod',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_copy_rounded),
            label: '.env.dev',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: (UserConfig.colorMode() == 'light')
            ? const Color.fromRGBO(238, 109, 109, 1)
            : const Color.fromRGBO(127, 86, 151, 1),
        onTap: _onItemTapped,
      ),
      body: Container(
          margin: const EdgeInsets.fromLTRB(32, 20, 32, 12),
          child: SingleChildScrollView(
              child: Column(
            children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Text(
                        '变量名',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '值',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '操作',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              const Divider(
                height: 1,
                color: Colors.grey,
              ),
              File('${Bot.path()}/$envFile').existsSync()
              ? ListView.builder(
                itemCount: _envContent.length,
                shrinkWrap: true,
                itemBuilder: (context, index) => ListTile(
                  title: Row(
                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: Text(
                            _envContent[index].split('=')[0],
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            _envContent[index].split('=')[1],
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: '编辑',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    final TextEditingController _controller = TextEditingController();
                                    _controller.text = _envContent[index].split('=')[1];
                                    return AlertDialog(
                                      title: const Text('修改变量值'),
                                      content: TextField(
                                        controller: _controller,
                                        decoration: const InputDecoration(
                                          hintText: '请输入新的值',
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('取消'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _envContent[index] = '${_envContent[index].split('=')[0]}=${_controller.text}';
                                            File('${Bot.path()}/$envFile').writeAsStringSync(_envContent.join('\n'));
                                            Navigator.of(context).pop();
                                            _loadEnv();
                                          },
                                          child: const Text('确定'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: '删除',
                              onPressed: () {
                                _envContent.removeAt(index);
                                File('${Bot.path()}/$envFile').writeAsStringSync(_envContent.join('\n'));
                                _loadEnv();
                              },
                            )
                          ],
                        )
                      )
                    ],
                  ),
                ),
              )
              : Center(
                child: Column(
                  children: <Widget>[
                    const Text('文件不存在'),
                    Image.asset('lib/assets/loading.gif')
                  ],
                ),
              ),
            ],
          ))),
          floatingActionButton: FloatingActionButton(
            shape: const CircleBorder(),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  final TextEditingController _controller1 = TextEditingController();
                  final TextEditingController _controller2 = TextEditingController();
                  return AlertDialog(
                    title: const Text('添加变量'),
                    content: SizedBox(
                      height: 150,
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: _controller1,
                            decoration: const InputDecoration(
                              hintText: '请输入变量名',
                              labelText: '变量名',
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: _controller2,
                            decoration: const InputDecoration(
                              hintText: '请输入变量值',
                              labelText: '变量值',
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          _envContent.add('${_controller1.text}=${_controller2.text}');
                          File('${Bot.path()}/$envFile').writeAsStringSync(_envContent.join('\n'));
                          Navigator.of(context).pop();
                          _loadEnv();
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Icon(Icons.add),
          ),
    );
  }

  _loadEnv() {
    File('${Bot.path()}/$envFile').readAsString().then((String contents) {
      setState(() {
        _envContent = contents.split('\n').where((line) => line.isNotEmpty).toList();
      });
    });
  }
}
