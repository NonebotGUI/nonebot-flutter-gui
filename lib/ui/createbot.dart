import 'package:NonebotGUI/darts/utils.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:NonebotGUI/ui/creatingbot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CreateBot(),
    );
  }
}

class CreateBot extends StatefulWidget {
  const CreateBot({super.key});

  @override
  State<CreateBot> createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<CreateBot> {
  final myController = TextEditingController();
  bool isvenv = true;
  bool isdep = true;
  String? _selectedFolderPath;

  Future<void> _pickFolder() async {
    String? folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath != null) {
      setState(() {
        _selectedFolderPath = folderPath.toString();
      });
    }
  }

  Map<String, bool> drivers = {
    'None': false,
    'FastAPI': false,
    'Quart': false,
    'HTTPX': false,
    'websockets': false,
    'AIOHTTP': false,
  };

  Map<String, bool> adapters = {
    'OneBot V11(nonebot-adapter-onebot.v11)': false,
    'OneBot V12(nonebot-adapter-onebot.v12)': false,
    '开黑啦(nonebot-adapter-kaiheila)': false,
    '飞书(nonebot-adapter-feishu)': false,
    'Discord(nonebot-adapter-discord)': false,
    'Telegram(nonebot-adapter-telegram)': false,
    'QQ(nonebot-adapter-qq)': false,
    'mirai2(nonebot_adapter_mirai2)': false,
    //'console(nonebot-adapter-console)': false,
    'Github(nonebot-adapter-github)': false,
    'NtChat(nonebot-adapter-ntchat)': false,
    'Minecraft(nonebot-adapter-minecraft)': false,
    'BilibiliLive(nonebot-adapter-bilibili)': false,
    'Walle-Q(nonebot-adapter-walleq)': false,
    'RedProtocol(nonebot-adapter-red)': false,
    'Satori(nonebot-adapter-satori)': false,
    'DoDo(nonebot-adapter-dodo)': false,
  };

  void onDriversChanged(String option, bool value) {
    setState(() {
      drivers[option] = value;
    });
  }

  void onAdaptersChanged(String option, bool value) {
    setState(() {
      adapters[option] = value;
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
        adapters.keys.where((option) => adapters[option] == true).toList();
    String selectedAdapters = selectedOptions.join(',').toString();
    return selectedAdapters;
  }

  List<Widget> buildDriversCheckboxes() {
    return drivers.keys.map((driver) {
      return CheckboxListTile(
        title: Text(driver),
        activeColor: const Color.fromRGBO(238, 109, 109, 1),
        value: drivers[driver],
        onChanged: (bool? value) => onDriversChanged(driver, value!),
      );
    }).toList();
  }

  List<Widget> buildAdaptersCheckboxes() {
    return adapters.keys.map((adapter) {
      return CheckboxListTile(
        title: Text(adapter),
        activeColor: const Color.fromRGBO(238, 109, 109, 1),
        value: adapters[adapter],
        onChanged: (bool? value) => onAdaptersChanged(adapter, value!),
      );
    }).toList();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  void _toggleVenv(bool newValue) {
    setState(() {
      isvenv = newValue;
    });
  }

  void _toggledep(bool newValue) {
    setState(() {
      isdep = newValue;
    });
  }

  String name = 'Nonebot';
  final List<String> template = ['bootstrap(初学者或用户)', 'simple(插件开发者)'];
  late String dropDownValue = template.first;
  final List<String> plugindir = ['在[bot名称]/[bot名称]下', '在src文件夹下'];
  late String dropDownValuePluginDir = plugindir.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "创建Bot",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromRGBO(238, 109, 109, 1),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                if (_selectedFolderPath.toString() != 'null') {
                  createBotWriteConfig(
                      name,
                      _selectedFolderPath,
                      isvenv,
                      isdep,
                      buildSelectedDriverOptions(),
                      buildSelectedAdapterOptions(),
                      dropDownValue,
                      dropDownValuePluginDir);
                  createBotWriteConfigRequirement(
                      buildSelectedDriverOptions(),
                      buildSelectedAdapterOptions());
                  createFolder(
                      _selectedFolderPath, name, dropDownValuePluginDir);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const CreatingBot();
                  }));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('你还没有选择存放Bot的目录！'),
                    duration: Duration(seconds: 3),
                  ));
                }
              },
              icon: const Icon(Icons.arrow_forward),
              color: Colors.white,
              tooltip: "下一步",
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              //bot名称
              children: <Widget>[
                TextField(
                  controller: myController,
                  decoration: const InputDecoration(
                    hintText: "bot名称，不填则默认为Nonebot",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(238, 109, 109, 1),
                        width: 5.0,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
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
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 31, 28, 28),
                        ),
                        onChanged: (String? value) {
                          setState(() {
                            dropDownValue = value!;
                          });
                        },
                        items: template
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    )),
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
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 31, 28, 28),
                          ),
                          onChanged: (String? value) {
                            setState(() {
                              dropDownValuePluginDir = value!;
                            });
                          },
                          items: plugindir
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      )),
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
                    )),
                    Expanded(
                        child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _pickFolder,
                        tooltip: "选择bot存放路径",
                        icon: const Icon(Icons.folder),
                      ),
                    )),
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
                          value: isvenv,
                          onChanged: _toggleVenv,
                          activeColor: const Color.fromRGBO(238, 109, 109, 1),
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
                          value: isdep,
                          onChanged: _toggledep,
                          activeColor: const Color.fromRGBO(238, 109, 109, 1),
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
                Column(children: buildAdaptersCheckboxes()),
              ],
            ),
          ),
        ));
  }
}
