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
  final List<String> _envList = ['.env', '.env.prod', '.env.dev'];
  List<String> _envContent = [];
  RegExp pattern = RegExp(r'^[^=]+=[^=]+$');
  String envFile = '.env';
  final TextEditingController _fileContentController = TextEditingController();

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
    _fileContentController.dispose();
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
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _envContent
                          .where((line) => pattern.hasMatch(line))
                          .length,
                      itemBuilder: (context, index) {
                        String filteredLine = _envContent
                            .where((line) => pattern.hasMatch(line))
                            .toList()[index];
                        List<String> parts = filteredLine.split('=');
                        String variableName = parts[0];
                        String variableValue = parts.length > 1 ? parts[1] : '';

                        return ListTile(
                          title: Row(
                            children: <Widget>[
                              Expanded(
                                child: Center(
                                  child: Text(
                                    variableName,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    variableValue,
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
                                            final TextEditingController
                                                _controller1 =
                                                TextEditingController(
                                                    text: variableName);
                                            final TextEditingController
                                                _controller2 =
                                                TextEditingController(
                                                    text: variableValue);
                                            return AlertDialog(
                                              title: const Text('编辑变量'),
                                              content: SizedBox(
                                                height: 150,
                                                child: Column(
                                                  children: <Widget>[
                                                    TextField(
                                                      controller: _controller1,
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText: '请输入变量名',
                                                        labelText: '变量名',
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    TextField(
                                                      controller: _controller2,
                                                      decoration:
                                                          const InputDecoration(
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
                                                    _envContent[
                                                            _envContent.indexOf(
                                                                filteredLine)] =
                                                        '${_controller1.text}=${_controller2.text}';
                                                    File('${Bot.path()}/$envFile')
                                                        .writeAsStringSync(
                                                            _envContent
                                                                .join('\n'));
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
                                        _envContent.remove(filteredLine);
                                        File('${Bot.path()}/$envFile')
                                            .writeAsStringSync(
                                                _envContent.join('\n'));
                                        _loadEnv();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add_var',
            tooltip: '添加变量',
            shape: const CircleBorder(),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  final TextEditingController _varNameController =
                      TextEditingController();
                  final TextEditingController _varValueController =
                      TextEditingController();
                  return AlertDialog(
                    title: const Text('添加变量'),
                    content: SizedBox(
                      height: 150,
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: _varNameController,
                            decoration: const InputDecoration(
                              hintText: '请输入变量名',
                              labelText: '变量名',
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: _varValueController,
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
                          _envContent.add(
                              '${_varNameController.text}=${_varValueController.text}');
                          File('${Bot.path()}/$envFile')
                              .writeAsStringSync(_envContent.join('\n'));
                          _loadEnv();
                          Navigator.of(context).pop();
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'edit_file',
            tooltip: '编辑文件',
            shape: const CircleBorder(),
            onPressed: () {
              _fileContentController.text = _envContent.join('\n');
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('编辑 $envFile 文件内容'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _fileContentController,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '编辑文件内容',
                                alignLabelWithHint: true,
                              ),
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
                          File('${Bot.path()}/$envFile')
                              .writeAsStringSync(_fileContentController.text);
                          _loadEnv();
                          Navigator.of(context).pop();
                        },
                        child: const Text('保存'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  _loadEnv() {
    File('${Bot.path()}/$envFile').readAsString().then((String contents) {
      setState(() {
        _envContent = contents.split('\n').toList();
      });
    });
  }
}
