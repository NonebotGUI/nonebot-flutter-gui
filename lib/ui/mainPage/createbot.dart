import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:NoneBotGUI/utils/deployBot.dart';
import 'package:NoneBotGUI/utils/userConfig.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class CreateBot extends StatefulWidget {
  const CreateBot({super.key});

  @override
  State<CreateBot> createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<CreateBot> {
  final _output = TextEditingController();
  final _outputController = StreamController<String>.broadcast();
  final ScrollController _scrollController = ScrollController();

  void _executeCommands(path, name, driver, adapters, template, pluginDir, venv,
      installDep) async {
    _output.clear();

    List<String> commands = [
      'echo 开始创建Bot：$name',
      'echo 读取配置...',
      DeployBot.createVENVEcho(path, name),
      DeployBot.createVENV(path, name, venv),
      'echo 开始安装依赖...',
      DeployBot.install(path, name, venv, installDep),
      DeployBot.writePyProject(path, name, adapters, template, pluginDir),
      DeployBot.writeENV(path, name, 8080, dropDownValue, driver),
      DeployBot.writebot(name, path, "default", "none", "none"),
      'echo 安装完成，可退出'
    ];

    for (String command in commands) {
      List<String> args = command.split(' ');
      String executable = args.removeAt(0);
      Process process = await Process.start(executable, args, runInShell: true);
      process.stdout
          .transform(systemEncoding.decoder)
          .listen((data) => _outputController.add(data));
      process.stderr
          .transform(systemEncoding.decoder)
          .listen((data) => _outputController.add(data));
      await process.exitCode;
    }
  }

  final myController = TextEditingController();
  bool isVENV = true;
  bool isDep = true;
  String? _selectedFolderPath;

  Future<void> _pickFolder() async {
    String? folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath != null) {
      setState(() {
        _selectedFolderPath = folderPath.toString();
      });
    }
  }

//拉取适配器和驱动器列表
  @override
  void initState() {
    super.initState();
    _fetchAdapters();
  }

//驱动器，万年不更新一次的东西就不搞http请求了🤓
  Map<String, bool> drivers = {
    'None': false,
    'FastAPI': true,
    'Quart': false,
    'HTTPX': false,
    'websockets': false,
    'AIOHTTP': false,
  };

//适配器
  Map<String, bool> adapterMap = {};
  List adapterList = [];
  bool loadAdapter = true;
  Future<void> _fetchAdapters() async {
    final response =
        await http.get(Uri.parse('${UserConfig.mirror()}/adapters.json'));
    if (response.statusCode == 200) {
      final decodedBody = UserConfig.httpEncoding().decode(response.bodyBytes);
      List<dynamic> adapters = json.decode(decodedBody);
      setState(() {
        adapterList = adapters;
        adapterMap = {for (var item in adapters) item['name']: false};
        loadAdapter = false;
      });
    } else {
      setState(() {
        loadAdapter = false;
      });
    }
  }

  void onDriversChanged(String option, bool value) {
    setState(() {
      drivers[option] = value;
    });
  }

  void onAdaptersChanged(String option, bool value) {
    setState(() {
      adapterMap[option] = value;
    });
  }

  String buildSelectedDriverOptions() {
    List<String> selectedOptions =
        drivers.keys.where((option) => drivers[option] == true).toList();
    String selectedDrivers = selectedOptions.join(',').toString();
    return selectedDrivers;
  }

  String buildSelectedAdapterOptions() {
    List<String> selectedOptions =
        adapterMap.keys.where((option) => adapterMap[option] == true).toList();
    List<String> selectedAdapters = selectedOptions.map((option) {
      String showText =
          '$option(${adapterList.firstWhere((adapter) => adapter['name'] == option)['module_name']})';
      return showText
          .replaceAll('adapters', 'adapter')
          .replaceAll('.', '-')
          .replaceAll('-v11', '.v11')
          .replaceAll('-v12', '.v12');
    }).toList();
    String selectedAdaptersString = selectedAdapters.join(', ');
    return selectedAdaptersString;
  }

  List<Widget> buildDriversCheckboxes() {
    return drivers.keys.map((driver) {
      return CheckboxListTile(
        title: Text(driver),
        value: drivers[driver],
        onChanged: (bool? value) => onDriversChanged(driver, value!),
      );
    }).toList();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.;
    myController.dispose();
    super.dispose();
  }

  void _toggleVenv(bool newValue) {
    setState(() {
      isVENV = newValue;
    });
  }

  void _toggleDep(bool newValue) {
    setState(() {
      isDep = newValue;
    });
  }

  String name = 'NoneBot';
  final List<String> template = ['bootstrap(初学者或用户)', 'simple(插件开发者)'];
  late String dropDownValue = template.first;
  final List<String> pluginDir = ['在[bot名称]/[bot名称]下', '在src文件夹下'];
  late String dropDownValuePluginDir = pluginDir.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            //bot名称
            children: <Widget>[
              TextField(
                controller: myController,
                decoration: const InputDecoration(
                  hintText: "bot名称，不填则默认为NoneBot",
                  border: OutlineInputBorder(
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
              Row(
                children: <Widget>[
                  const Expanded(
                      child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '选择模板',
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
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(value),
                                  )),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
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
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(value),
                                    )),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 12,
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
                height: 10,
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
              const SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("是否安装依赖"),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Switch(
                        value: isDep,
                        onChanged: _toggleDep,
                        focusColor: Colors.black,
                        inactiveTrackColor: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                height: 20,
                thickness: 2,
                indent: 20,
                endIndent: 20,
                color: Colors.grey,
              ),
              const Center(
                child: Text("选择驱动器"),
              ),
              const SizedBox(
                height: 3,
              ),
              Column(children: buildDriversCheckboxes()),

              const Divider(
                height: 20,
                thickness: 2,
                indent: 20,
                endIndent: 20,
                color: Colors.grey,
              ),
              const Center(
                child: Text("选择适配器"),
              ),
              const SizedBox(
                height: 3,
              ),
              Column(
                children: [
                  if (loadAdapter)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: adapterList.map((adapter) {
                        String name = adapter['name'];
                        //屎山，别骂了别骂了😭
                        // 还好
                        String moduleName = adapter['module_name']
                            .replaceAll('adapters', 'adapter')
                            .replaceAll('.', '-')
                            .replaceAll('-v11', '.v11')
                            .replaceAll('-v12', '.v12');
                        String showText = '$name($moduleName)';
                        return CheckboxListTile(
                          title: Text(showText),
                          value: adapterMap[name],
                          onChanged: (bool? value) =>
                              onAdaptersChanged(name, value!),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedFolderPath.toString() != 'null' &&
              buildSelectedAdapterOptions().isNotEmpty &&
              buildDriversCheckboxes().isNotEmpty) {
            name = name;
            String? path = _selectedFolderPath;
            bool venv = isVENV;
            bool installDep = isDep;
            String adapter = buildSelectedAdapterOptions();
            String driver = buildSelectedDriverOptions();
            String template = dropDownValue;
            String pluginDir = dropDownValuePluginDir;
            DeployBot.writeReq(path, name, driver, adapter);
            DeployBot.createFolder(
              _selectedFolderPath,
              name,
              dropDownValue,
              dropDownValuePluginDir,
            );
            _executeCommands(path, name, driver, adapter, template, pluginDir,
                venv, installDep);
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Material(
                  color: Colors.transparent,
                  child: Center(
                    child: AlertDialog(
                      title: const Text('正在安装Bot'),
                      content: SizedBox(
                        height: 600,
                        width: 800,
                        child: StreamBuilder<String>(
                          stream: _outputController.stream,
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            return Card(
                              color: const Color.fromARGB(255, 31, 28, 28),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: StreamBuilder<String>(
                                  stream: _outputController.stream,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<String> snapshot) {
                                    if (snapshot.hasData) {
                                      final newText =
                                          _output.text + (snapshot.data ?? '');
                                      _output.text = newText;
                                    }
                                    return Card(
                                      color:
                                          const Color.fromARGB(255, 31, 28, 28),
                                      child: SingleChildScrollView(
                                        controller: _scrollController,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            _output.text,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('安装进程已在后台运行，请耐心等待安装完成'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                          child: Text(
                            '关闭窗口',
                            style: TextStyle(color: Colors.red[400]),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            print(buildSelectedAdapterOptions());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('你是不是漏选了什么？'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        tooltip: '完成',
        shape: const CircleBorder(),
        child: const Icon(
          Icons.done_rounded,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
