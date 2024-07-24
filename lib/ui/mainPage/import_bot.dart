import 'package:NoneBotGUI/darts/utils.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:NoneBotGUI/darts/global.dart';

// void main() {
//   runApp(
//     const MyApp(),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: ImportBot(),
//     );
//   }
// }

class ImportBot extends StatefulWidget {
  const ImportBot({super.key});

  @override
  State<ImportBot> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ImportBot> {
  String name = 'ImportedBot';
  final myController = TextEditingController();
  String? _selectedFolderPath;

  Future<void> _pickFolder() async {
    String? folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath != null) {
      setState(() {
        _selectedFolderPath = folderPath.toString();
      });
    }
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
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
                decoration: const InputDecoration(
                  hintText: "bot名称，不填则默认为ImportedBot",
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
              const SizedBox(
                height: 12,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'bot根目录[$_selectedFolderPath]',
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
                        tooltip: "选择bot的根目录",
                        icon: const Icon(Icons.folder),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (_selectedFolderPath.toString() != 'null') {
                importbot(userDir, name, _selectedFolderPath.toString());
                Navigator.of(context).popUntil((route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('导入完成'),
                    duration: Duration(seconds: 3),
                  ),
                );
                setState(() {
                  name = 'ImportedBot';
                  _selectedFolderPath = null;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('你还没有选择Bot的根目录！'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            tooltip: "导入",
        shape: const CircleBorder(),
        child: const Icon(
          Icons.done_rounded,
          color: Colors.white,
        ),
      ),
    );
  }
}
