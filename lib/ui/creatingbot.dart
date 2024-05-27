import 'package:NonebotGUI/darts/utils.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:NonebotGUI/darts/global.dart';

// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: CreatingBot(),
//     );
//   }
// }

class CreatingBot extends StatefulWidget {
  const CreatingBot({super.key});

  @override
  State<CreatingBot> createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _MyCustomFormState extends State<CreatingBot> {
  final _outputController = TextEditingController();

  void _executeCommands() async {
    //读取配置文件
    String cfg = createBotReadConfig(userDir);
    List<String> arg = cfg.split(',');
    String name = arg[0];
    String path = arg[1];
    String venv = arg[2];
    String dep = arg[3];

    _outputController.clear();

    List<String> commands = [
      'echo 开始创建Bot：$name',
      'echo 读取配置...',
      createVENVEcho(path, name),
      createVENV(userDir, path, name, venv),
      'echo 开始安装依赖...',
      installBot(userDir, path, name, venv, dep),
      writePyProject(userDir, path, name),
      writeENV(userDir, path, name),
      writebot(userDir, name, path),
      'echo 安装完成，可退出'
    ];

    for (String command in commands) {
      List<String> args = command.split(' ');

      String executable = args.removeAt(0);
      Process process = await Process.start(executable, args, runInShell: true);

      process.stdout.transform(systemEncoding.decoder).listen((data) {
        _outputController.text += data;
        _outputController.selection = TextSelection.fromPosition(
          TextPosition(offset: _outputController.text.length),
        );
        // 更新UI
        setState(() {});
      });

      process.stderr.transform(systemEncoding.decoder).listen((data) {
        _outputController.text += data;
        _outputController.selection = TextSelection.fromPosition(
          TextPosition(offset: _outputController.text.length),
        );
        setState(() {});
      });

      await process.exitCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "确认创建",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: _executeCommands,
                child: const Text(
                  '确认创建',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            const Divider(
              height: 20,
              thickness: 2,
              indent: 20,
              endIndent: 20,
              color: Colors.grey,
            ),
            const Center(child: Text('Bot信息')),
            Row(
              children: <Widget>[
                const Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Bot名称',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(createBotReadConfigName(userDir)),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(children: <Widget>[
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bot路径',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    createBotReadConfigPath(userDir),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: <Widget>[
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '虚拟环境',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(createBotReadConfigVENV(userDir)),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: <Widget>[
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '依赖',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(createBotReadConfigDep(userDir)),
                ),
              ),
            ]),
            Row(children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FutureBuilder<String>(
                    future: getPyVer(userDir),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        return const Text(
                          'Python版本',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Text(
                          'Python版本',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      } else {
                        return const Text(
                          'Python版本',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FutureBuilder<String>(
                    future: getPyVer(userDir),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data.toString());
                      } else if (snapshot.hasError) {
                        return const Text('未检测到Python');
                      } else {
                        return const Text('获取中...');
                      }
                    },
                  ),
                ),
              )
            ]),
            Row(children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FutureBuilder<String>(
                    future: getnbcliver(userDir),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        return const Text(
                          'nb-cli版本',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        );
                      } else if (snapshot.hasError) {
                        return const Text(
                          'nb-cli版本',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        );
                      } else {
                        return const Text(
                          'nb-cli版本',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        );
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FutureBuilder<String>(
                    future: getnbcliver(userDir),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                            snapshot.data.toString().replaceAll('nb:', ''));
                      } else if (snapshot.hasError) {
                        return const Text('未检测到nb-cli');
                      } else {
                        return const Text('获取中...');
                      }
                    },
                  ),
                ),
              ),
            ]),
            const Divider(
              height: 20,
              thickness: 2,
              indent: 20,
              endIndent: 20,
              color: Colors.grey,
            ),
            const Center(child: Text('控制台输出')),
            const SizedBox(height: 4),
            Expanded(
              child: SizedBox(
                height: 400,
                width: 2000,
                child: Card(
                  color: const Color.fromARGB(255, 31, 28, 28),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        style: const TextStyle(color: Colors.white),
                        _outputController.text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
