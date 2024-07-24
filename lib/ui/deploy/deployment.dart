import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:NoneBotGUI/darts/global.dart';
import 'package:NoneBotGUI/darts/utils.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';



class Deployment extends StatefulWidget {
  const Deployment({super.key});

  @override
  State<Deployment> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Deployment> {


  final myController = TextEditingController();
  final hostController = TextEditingController();
  final portController = TextEditingController();
  final qqController = TextEditingController();
  final List<String> template = ['bootstrap(初学者或用户)', 'simple(插件开发者)'];
  final List<String> pluginDir = ['在[bot名称]/[bot名称]下', '在src文件夹下'];
  final List<String> mirror = ['https://github.com', 'https://hub.xb6868.com'];
  late String dropDownValue = template.first;
  late String dropDownValuePluginDir = pluginDir.first;
  late String dropDownValueMirror = 'https://github.com';
  bool isVENV = true;
  String? _selectedFolderPath;
  String name = 'NoneBot';
  String tip = '';
  String cmd = '';
  String cmdWin = '';
  List drivers = [];
  String config = '';
  String raw = '';
  String dlLinkRaw = '';
  Map<String, dynamic> configRaw = {};
  bool couldNext = false;
  Map<String, dynamic> apiContent = {};



  Future<void> _pickFolder() async {
    String? folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath != null) {
      setState(() {
        _selectedFolderPath = folderPath.toString();
        setDeployPath(_selectedFolderPath, name);
      });
    }
  }


  @override
  void dispose() {
    myController.dispose();
    hostController.dispose();
    portController.dispose();
    super.dispose();
  }

  void _toggleVenv(bool newValue) {
    setState(() {
      isVENV = newValue;
    });
  }
  @override
  void initState() {
    super.initState();
    needQQ = false;
    botQQ = '';
    wsHost = '127.0.0.1';
    wsPort = '8080';
    deployAdapter = 'None';
    deployDriver = 'None';
    deployTemplate = 'bootstrap(初学者或用户)';
    deployPluginDir = '在[bot名称]/[bot名称]下';
    fetchData();
  }



  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('https://api.zobyic.top/api/nbgui/deploy/detail?id=$deployId'));
    if (response.statusCode == 200) {
      couldNext = true;
      setState(() {
        String decodedBody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> jsonMap = json.decode(decodedBody);
        raw = json.encode(jsonMap);
        tip = jsonMap['tip'];
        name = jsonMap['name'];
        deployAdapter = jsonMap['adapter'];
        drivers = jsonMap['drivers'];
        deployDriver = drivers.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');
        configRaw = jsonMap['config'];
        var botConfigRaw = json.encode(configRaw);
        var decodedJson = jsonDecode(botConfigRaw);
        botConfig = const JsonEncoder.withIndent('   ').convert(decodedJson);
        dlLinkRaw = jsonMap['dl'].toString().replaceAll('[', '').replaceAll(']', '');
        dlLink = dlLinkRaw.toString().replaceAll('https://github.com', dropDownValueMirror)
                                      .split(',').map((item) => item.trim())
                                      .toList();
        extDir = jsonMap['dir'];
        needQQ = jsonMap['needQQNum'];
        configName = jsonMap['configName'];
        configPath = jsonMap['configPath'];
        apiContent = jsonMap;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: myController,
                decoration: InputDecoration(
                  hintText: "bot名称，不填则默认为$name",
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(238, 109, 109, 1),
                      width: 5.0,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() => name = value);
                },
              ),
              const SizedBox(height: 12),
              Text(
                "本模板Tip:${tip.isEmpty ? '无' : tip}"
              ),
              const SizedBox(height: 12,),
              Row(
                children: <Widget>[
                  const Expanded(
                      child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '选择模式',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: DropdownButton<String>(
                        value: dropDownValue,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        elevation: 16,
                        onChanged: (String? value) {
                          setState(() => dropDownValue = value!);
                        },
                        items: template
                            .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: dropDownValue == template[1],
                child: Row(
                  children: <Widget>[
                    const Expanded(
                        child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '选择插件存放位置',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    )),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: DropdownButton<String>(
                          value: dropDownValuePluginDir,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          elevation: 16,
                          onChanged: (String? value) {
                            setState(() {
                              dropDownValuePluginDir = value!;
                            });
                          },
                          items: pluginDir
                              .map<DropdownMenuItem<String>>(
                                (String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value, maxLines: 1 ,overflow: TextOverflow.fade,),
                                ),
                              )
                              .toList(),
                        ),
                        )
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                children: <Widget>[
                  const Expanded(
                      child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '选择下载镜像',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: DropdownButton<String>(
                        value: dropDownValueMirror,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        elevation: 16,
                        onChanged: (String? value) {
                          setState(() => dropDownValueMirror = value!);
                          dlLink = dlLinkRaw.toString().replaceAll('https://github.com', dropDownValueMirror)
                                    .split(',').map((item) => item.trim())
                                    .toList();

                        },
                        items: mirror
                            .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
              //bot目录
              Row(
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '存放bot的目录[$_selectedFolderPath]',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _pickFolder,
                        tooltip: "选择bot存放路径",
                        icon: const Icon(Icons.folder),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("是否开启虚拟环境"),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Switch(
                        value: isVENV,
                        onChanged: _toggleVenv,
                        focusColor: Colors.black,
                        inactiveTrackColor: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8,),
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("反向Websocket主机(默认为127.0.0.1)"),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 150,
                        child: TextField(
                        controller: hostController,
                        decoration: const InputDecoration(
                          hintText: '127.0.0.1',
                        ),
                        onChanged: (value) {
                          setState(() => wsHost = value);
                        },
                      ),
                      )
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8,),
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("监听端口(默认为8080)"),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 150,
                        child: TextField(
                        controller: portController,
                        keyboardType: TextInputType.number,
                        //只能输入数字
                        inputFormatters: [
                            FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                        ],
                        decoration: const InputDecoration(
                          hintText: '8080',
                        ),
                        onChanged: (value) {
                          setState(() => wsPort = value);
                        },
                      ),
                      )
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: needQQ,
                child: Row(
                  children: <Widget>[
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Bot的QQ号"),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 150,
                          child: TextField(
                          controller: qqController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                              FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                          ],
                          decoration: const InputDecoration(
                            hintText: '',
                          ),
                          onChanged: (value) {
                            setState(() => botQQ = value);
                          },
                        ),
                        )
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("将要安装的适配器"),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        deployAdapter
                      )
                      )
                    ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("将要安装的驱动器"),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        drivers.toString().replaceAll('[', '').replaceAll(']', '')
                      )
                      )
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
            onPressed: () {
              deployTemplate = dropDownValue;
              deployPluginDir = dropDownValuePluginDir;
              deployVenv = isVENV;
              setCmd(apiContent);
              //神金写法
              if (couldNext){
                  if (_selectedFolderPath.toString() != 'null') {
                  Directory dir = Directory('$_selectedFolderPath/$name');
                  Directory dirBots = Directory('$userDir/bots');
                  if (!dir.existsSync()) {
                    dir.createSync();
                  }
                  if (!dirBots.existsSync()) {
                    dirBots.createSync();
                  }
                  if (dropDownValue == 'simple(插件开发者)') {
                    if (dropDownValuePluginDir == '在[bot名称]/[bot名称]下') {
                      Directory dirSrc = Directory('$_selectedFolderPath/$name/$name');
                      Directory dirSrcPlugins = Directory('$_selectedFolderPath/$name/$name/plugins');
                      if (!dirSrc.existsSync()) {
                        dirSrc.createSync();
                      }
                      if (!dirSrcPlugins.existsSync()) {
                        dirSrcPlugins.createSync();
                      }
                    } else if (dropDownValuePluginDir == '在src文件夹下') {
                      Directory dirSrc = Directory('$_selectedFolderPath/$name/src');
                      Directory dirSrcPlugins = Directory('$_selectedFolderPath/$name/src/plugins');
                      if (!dirSrc.existsSync()) {
                        dirSrc.createSync();
                      }
                      if (!dirSrcPlugins.existsSync()) {
                        dirSrcPlugins.createSync();
                      }
                    }
                  }
                  deployName = name;
                  selectPath = _selectedFolderPath.toString();
                  setState(() {
                    deployPage++;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('你是不是漏了什么？'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('变量未初始化完成'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
            },
        tooltip: '完成',
        child: const Icon(Icons.navigate_next_rounded, color: Colors.white,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

