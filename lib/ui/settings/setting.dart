import 'package:NonebotGUI/darts/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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
      setPyPath(result.files.single.path.toString());
    }
  }

  void _selectNbCli() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setNbcliPath(result.files.single.path.toString());
    }
  }

  final List<String> colorMode = ['light', 'dark'];
  late String dropDownValue = userColorMode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "设置",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:userColorMode() == 'light'
          ? const Color.fromRGBO(238, 109, 109, 1)
          : const Color.fromRGBO(127, 86, 151, 1),
      ),
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
                        child: Text('颜色主题'),
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
                            setColorMode(dropDownValue);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('已更改，重启应用后生效'),
                            duration: Duration(seconds: 3),
                          ));
                          });
                        },
                        items: colorMode
                            .map<DropdownMenuItem<String>>((String value) {
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
                      setPyPath('default');
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
                      setNbcliPath('default');
                    })),
                    const SizedBox(height: 4,),
          ],
        ),
      )
    );
  }
}

