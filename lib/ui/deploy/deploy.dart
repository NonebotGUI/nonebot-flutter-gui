import 'dart:async';
import 'package:NoneBotGUI/darts/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:NoneBotGUI/darts/global.dart';
import 'package:archive/archive_io.dart';
import 'dart:io';



class Deploy extends StatefulWidget {
  const Deploy({super.key});

  @override
  State<Deploy> createState() => _DeployState();
}

class _DeployState extends State<Deploy> {
  final _output = TextEditingController();
  final _outputController = StreamController<String>.broadcast();
  late String dropDownValueDL = dlLink.first;
  String extensionName = '';
  bool _isDownloading = false;
  bool _couldDeploy = false;
  double _dlProgress = 0;
  bool isDeploying = false;





Future<void> download() async {
  Dio dio = Dio();
  try {
    setState(() {
      _couldDeploy = true;
      _isDownloading = true;
    });
    Response response = await dio.download(
      dropDownValueDL,
      '$deployPath/${dropDownValueDL.split('/').last}',
      onReceiveProgress: (int received, int total) {
        setState(() {
          _dlProgress = (received / total).toDouble();
        });
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('协议端下载完成')),
      );
      await extractFileToDisk('$deployPath/${dropDownValueDL.split('/').last}', '$deployPath/Protocol');
      getProtocolFileName();
      String? dirPath = await getExtDir(protocolFileName, '$deployPath/Protocol');
      if (dirPath != null) {
        extDir = dirPath.toString().replaceAll('\\', '\\\\');
        _couldDeploy = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未能找到协议端目录')),
        );
      }
    }
    await writeProtocolConfig();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('下载失败: $e')),
    );
  } finally {
    setState(() {
      _isDownloading = false;
    });
  }
}



  void _executeCommands(name, path, venv, cmd, port) async {
    setState(() {
      isDeploying = true;
    });
    _output.clear();

    List<String> commands = [
      'echo 开始创建Bot：$name',
      'echo 读取配置...',
      'echo 写入配置...',
      createVENVEcho(selectPath, name),
      createVENV(userDir, selectPath, name, venv.toString()),
      'echo 开始安装依赖',
      writeReq(name, deployAdapter, deployDriver),
      installBot(userDir, selectPath, name, venv.toString(), 'true'),
      writeENV(selectPath, name, selectPath, deployTemplate),
      writebot(userDir, name, selectPath, "deployed", extDir, cmd),
      'echo 部署完成，可退出'
    ];

    for (String command in commands) {
      List<String> args = command.split(' ');
      String executable = args.removeAt(0);
      Process process = await Process.start(executable, args, runInShell: true);
      process.stdout
          .transform(userDeployEncoding().decoder)
          .listen((data) => _outputController.add(data));
      process.stderr
          .transform(userDeployEncoding().decoder)
          .listen((data) => _outputController.add(data));
      await process.exitCode;
    }

    setState(() {
      isDeploying = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Row(
              children: [
                Text("选择适合你系统的压缩包", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                DropdownButton<String>(
                  value: dropDownValueDL,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  elevation: 16,
                  onChanged: (String? value) {
                    setState(() => dropDownValueDL = value!);
                  },
                  items: dlLink
                      .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(value.split('/').last),
                          ),
                        ),
                      )
                      .toList(),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 80,
                      child: OutlinedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                            userColorMode(userDir) == 'light'
                                ? const Color.fromRGBO(238, 109, 109, 1)
                                : const Color.fromRGBO(127, 86, 151, 1),
                          ),
                        ),
                        onPressed: () {
                          _isDownloading
                              ? ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('已经在下载中了！')),
                                )
                              : ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('开始下载，请注意：部署过程中有可能出现应用程序卡住的现象，请不要关闭程序，耐心等待部署完成'),
                                    duration: Duration(seconds: 5),
                                  ),
                                );
                                download();
                        },
                        child: const Text(
                          '下载',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text("下载进度[${(_dlProgress * 100).toInt()}%]", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: _dlProgress,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation(
                userColorMode(userDir) == 'light'
                    ? const Color.fromRGBO(238, 109, 109, 1)
                    : const Color.fromRGBO(127, 86, 151, 1),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                _couldDeploy
                    ? const Text(
                        'Bot本体部署',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    : const Text(
                        'Bot本体部署[请先下载协议端]',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: isDeploying
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: 80,
                            child: OutlinedButton(
                              onPressed: () {
                                if (_couldDeploy) {
                                  setState(() {
                                    isDeploying = true;
                                  });
                                  _executeCommands(deployName, deployPath, deployVenv, cmd, wsPort);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('请先下载协议端！')),
                                  );
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                  userColorMode(userDir) == 'light'
                                      ? const Color.fromRGBO(238, 109, 109, 1)
                                      : const Color.fromRGBO(127, 86, 151, 1),
                                ),
                              ),
                              child: const Text(
                                "部署",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                SizedBox(
                  width: size.width * 0.25,
                  height: size.height * 0.64,
                  child: Card(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      child: Column(
                        children: <Widget>[
                          const Text(
                            'Bot配置',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: size.height * 0.045),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '名称',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(deployName),
                          ),
                          SizedBox(height: size.height * 0.03),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '路径',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(deployPath),
                          ),
                          SizedBox(height: size.height * 0.03),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '驱动器',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(deployDriver),
                          ),
                          SizedBox(height: size.height * 0.03),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '适配器',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(deployAdapter),
                          ),
                          SizedBox(height: size.height * 0.03),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: size.height * 0.64,
                    child: Card(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        child: Column(
                          children: <Widget>[
                            const Row(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    '控制台输出',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.555,
                              width: size.width * 0.64,
                              child: StreamBuilder<String>(
                                        stream: _outputController.stream,
                                        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                          return Card(
                                            color: const Color.fromARGB(255, 31, 28, 28),
                                            child: SingleChildScrollView(
                                              child: StreamBuilder<String>(
                                                stream: _outputController.stream,
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<String> snapshot) {
                                                  if (snapshot.hasData) {
                                                    final newText =
                                                    _output.text + (snapshot.data ?? '');
                                                    _output.text = newText;
                                                  }
                                                  return  Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text(
                                                          _output.text,
                                                          style: const TextStyle(
                                                            color: Colors.white,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
