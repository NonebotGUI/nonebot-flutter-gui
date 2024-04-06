import 'package:Nonebot_GUI/darts/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'creatingbot.dart';


void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  String template = "bootstrap";
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
    'console(nonebot-adapter-console)': false,
    'Github(nonebot-adapter-github)': false,
    'NtChat(nonebot-adapter-ntchat)': false,
    'Minecraft(nonebot-adapter-minecraft)': false,
    'BilibiliLive(nonebot-adapter-bilibili)': false,
    'Walle-Q(nonebot-adapter-walleq)': false,
    'RedProtocol(nonebot-adapter-red)': false,
    'Satori(nonebot-adapter-satori)': false,
    'DoDo(nonebot-adapter-dodo)': false,   
  };

  void onChanged_drivers(String option, bool value) {
    setState(() {
      drivers[option] = value;
    });
  }

  void onChanged_adapters(String option, bool value) {
    setState(() {
      adapters[option] = value;
    });
  }

  String buildSelectedOptions_driver() {
    List<String> selectedOptions = drivers.keys.where((option) => drivers[option] == true).toList();
    String selectedDrivers = selectedOptions.join(',').toString();
    return '${selectedDrivers}';
  }

  String buildSelectedOptions_adapter() {
    List<String> selectedOptions = adapters.keys.where((option) => adapters[option] == true).toList();
    String selectedAdapters = selectedOptions.join(',').toString();
    return '${selectedAdapters}';
  }

  List<Widget> buildDriversCheckboxes() {
    return drivers.keys.map((driver) {
      return CheckboxListTile(
        title: Text(driver),
        value: drivers[driver],
        onChanged: (bool? value) => onChanged_drivers(driver, value!),
      );
    }).toList();
  }

  List<Widget> buildAdaptersCheckboxes() {
    return adapters.keys.map((adapter) {
      return CheckboxListTile(
        title: Text(adapter),
        value: adapters[adapter],
        onChanged: (bool? value) => onChanged_adapters(adapter, value!),
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


  void _no(bool newValue){
    print("我还没写，不许关😡😡😡");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "创建Bot",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(238, 109, 109, 1),
        actions: <Widget>[
          IconButton(
            onPressed:() {
              if (_selectedFolderPath.toString() != 'null') {
                       creatbot_writeconfig(name, _selectedFolderPath, isvenv, isdep, buildSelectedOptions_driver(),buildSelectedOptions_adapter()); 
                       createbot_writeconfig_requirement(buildSelectedOptions_driver(),buildSelectedOptions_adapter()) ;
                       createfolder(_selectedFolderPath, name);
                       Navigator.push(context, MaterialPageRoute(builder:(context) {
                                return  creatingbot();
                       }));
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('你还没有选择存放Bot的目录！'),
                  duration: Duration(seconds: 3),));
            }},
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

            //bot目录
            Row(children: <Widget>[
              Expanded(child: Align(alignment: 
              Alignment.centerLeft,
              child: Text('存放bot的目录[${_selectedFolderPath}]',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,),
              )),

              Expanded(child: Align(alignment: 
              Alignment.centerRight,
              child: IconButton(
                onPressed: _pickFolder,
                tooltip: "选择bot存放路径",
                icon: const Icon(Icons.folder),
              ),             
              )
              ),         
            ],
            ),

            const SizedBox(height: 10,),            
            
            Row(
              children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("是否开启虚拟环境(不许关😡😡😡)"),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Switch(
                      value: isvenv,
                      onChanged: _no,
                      activeColor: Color.fromRGBO(238, 109, 109, 1),
                      focusColor: Colors.black,
                      inactiveTrackColor: Colors.grey,
                    ),
                  ),
                ),
              ],
              
            ),
            const SizedBox(height: 10,),
            Row(
              children: <Widget> [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("是否安装依赖(不许关😡😡😡)"),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Switch(
                      value: isdep,
                      onChanged: _no,
                      activeColor: Color.fromRGBO(238, 109, 109, 1),
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
            Center(
              child: Text("选择驱动器"),
            ),
            const SizedBox(height: 3,),
            Column(
              children: buildDriversCheckboxes()
            ),

            const Divider(
            height: 20,
            thickness: 2,
            indent: 20,
            endIndent: 20,
            color: Colors.grey,
            ),
            Center(
              child: Text("选择适配器"),
            ),
            const SizedBox(height: 3,),
            Column(
              children: buildAdaptersCheckboxes()
            ),
          ],
        ),
      ),
      )
    );
  }
}

