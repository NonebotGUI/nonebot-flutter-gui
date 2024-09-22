import 'dart:convert';
import 'dart:io';
import 'package:NoneBotGUI/utils/global.dart';
import 'package:NoneBotGUI/utils/userConfig.dart';

class Bot {
  static final File _configFile = File('$userDir/bots/$gOnOpen.json');

  static Map<String, dynamic> _config() {
    File file = File('$userDir/bots/$gOnOpen.json');
    String content = file.readAsStringSync();
    return jsonDecode(content);
  }

  /// 获取Bot名称
  static String name() {
    Map<String, dynamic> jsonMap = _config();
    return jsonMap['name'].toString();
  }

  /// 获取Bot的创建时间
  static String time() {
    Map<String, dynamic> jsonMap = _config();
    return jsonMap['time'].toString();
  }

  /// 获取Bot的路径
  static String path() {
    Map<String, dynamic> jsonMap = _config();
    return jsonMap['path'].toString();
  }

  /// 获取Bot运行状态
  static String status() {
    Map<String, dynamic> jsonMap = _config();
    return jsonMap['isrunning'].toString();
  }

  /// 获取Bot Pid
  static String pid() {
    Map<String, dynamic> jsonMap = _config();
    return jsonMap['pid'].toString();
  }

  /// 获取Bot的Python Pid
  static String pypid(path) {
    File file = File('$path/nbgui_stdout.log');
    RegExp regex = RegExp(r'Started server process \[(\d+)\]');
    Match? match =
        regex.firstMatch(file.readAsStringSync(encoding: systemEncoding));
    if (match != null && match.groupCount >= 1) {
      String pid = match.group(1)!;
      Bot.setPyPid(pid);
      return pid;
    } else {
      Bot.setPyPid("Null");
      return "Null";
    }
  }

  /// 设置Bot的Python Pid
  static void setPyPid(pid) {
    Map<String, dynamic> jsonMap = _config();
    jsonMap['pypid'] = pid;
    _configFile.writeAsStringSync(jsonEncode(jsonMap));
  }

  /// 唤起Bot进程
  static Future run() async {
    File cfgFile = File('$userDir/bots/$gOnOpen.json');
    final stdout = File('${Bot.path()}/nbgui_stdout.log');
    final stderr = File('${Bot.path()}/nbgui_stderr.log');
    Process process = await Process.start('${UserConfig.nbcliPath()}', ['run'],
        workingDirectory: Bot.path());
    int pid = process.pid;

    /// 重写配置文件来更新状态
    Map<String, dynamic> jsonMap = jsonDecode(cfgFile.readAsStringSync());
    jsonMap['pid'] = pid;
    jsonMap['isrunning'] = 'true';
    cfgFile.writeAsStringSync(jsonEncode(jsonMap));

    final outputSink = stdout.openWrite();
    final errorSink = stderr.openWrite();

    // 直接监听原始字节输出
    process.stdout.listen((data) {
      outputSink.add(data);
    });

    process.stderr.listen((data) {
      errorSink.add(data);
    });
  }

  ///结束bot进程
  static stop() async {
    //读取配置文件
    File cfgFile = File('$userDir/bots/$gOnOpen.json');
    Map botInfo = json.decode(cfgFile.readAsStringSync());
    String pidString = botInfo['pid'].toString();
    int pid = int.parse(pidString);
    Process.killPid(pid);

    ///更新配置文件
    botInfo['isrunning'] = 'false';
    botInfo['pid'] = 'Null';
    cfgFile.writeAsStringSync(json.encode(botInfo));
    //如果平台为Windows则释放端口
    //有bug,先注释掉（
    //   if (Platform.isWindows) {
    //     await Process.start(
    //         "taskkill.exe", ['/f', '/pid', Bot.pypid(Bot.path()).toString()],
    //         runInShell: true);
    //   }
    //   setPyPid('Null');
  }

  ///重命名Bot
  static void rename(name) {
    // 暂存数据
    String time = Bot.time();
    String oldName = Bot.name();

    // 重写配置文件
    File botcfg = File('$userDir/bots/$oldName.$time.json');
    Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
    jsonMap['name'] = name;
    botcfg.writeAsStringSync(jsonEncode(jsonMap));
    File('$userDir/bots/$oldName.$time.json')
        .rename('$userDir/bots/$name.$time.json');

    // 重命名文件
    gOnOpen = "";
    //File('$userDir/bots/$oldName.$time.json').deleteSync();
  }

  ///获取stderr.log
  static String stderr() {
    File file = File('${Bot.path()}/nbgui_stderr.log');
    return file.readAsStringSync();
  }

  ///清空stderr.log
  static void deleteStderr() {
    File file = File('${Bot.path()}/nbgui_stderr.log');
    file.writeAsStringSync('');
  }

  ///删除Bot
  static void delete() {
    gOnOpen = '';
    _configFile.delete();
  }

  ///彻底删除Bot
  static void deleteForever() async {
    String path = Bot.path();
    Directory(path).delete(recursive: true);
    _configFile.delete();
    gOnOpen = '';
  }

  ///导入Bot
  static import(name, path, withProtocol, protocolPath, cmd) {
    DateTime now = DateTime.now();
    String time =
        "${now.year}年${now.month}月${now.day}日${now.hour}时${now.minute}分${now.second}秒";
    File cfgFile = File('$userDir/bots/$name.$time.json');
    String type = withProtocol ? 'deployed' : 'imported';
    if (Platform.isWindows) {
      String botInfo = '''
{
  "name": "$name",
  "path": "${path.replaceAll('\\', '\\\\')}",
  "time": "$time",
  "isrunning": "false",
  "pid": "Null",
  "type": "$type",
  "protocolPath": "$protocolPath",
  "cmd": "$cmd",
  "protocolPid": "Null",
  "protocolIsrunning": false
}
''';
      cfgFile.writeAsStringSync(botInfo);
      String echo = "echo 写入json";
      return echo;
    }

    if (Platform.isLinux || Platform.isMacOS) {
      String botInfo = '''
{
  "name": "$name",
  "path": "$path",
  "time": "$time",
  "isrunning": "false",
  "pid": "Null",
  "type": "$type",
  "protocolPath": "$protocolPath",
  "cmd": "$cmd",
  "protocolPid": "Null",
  "protocolIsrunning": false
}
''';
      cfgFile.writeAsStringSync(botInfo);
      String echo = "echo 写入json";
      return echo;
    }
  }
}

// 协议端相关操作
class Protocol {
  static final File _configFile = File('$userDir/bots/${gOnOpen}.json');
  static Map<String, dynamic> _config() {
    File file = File('$userDir/bots/${gOnOpen}.json');
    String content = file.readAsStringSync();
    return jsonDecode(content);
  }

  ///协议端路径
  static String path() {
    Map<String, dynamic> jsonMap = _config();
    return jsonMap['protocolPath'].toString().replaceAll('\\\\', '\\');
  }

  ///协议端运行状态
  static bool status() {
    Map<String, dynamic> jsonMap = _config();
    bool protocolStatus = jsonMap['protocolIsrunning'];
    return protocolStatus;
  }

  ///协议端pid
  static String pid() {
    Map<String, dynamic> jsonMap = _config();
    return jsonMap['protocolPid'].toString();
  }

  ///协议端启动命令
  static String cmd() {
    Map<String, dynamic> jsonMap = _config();
    return jsonMap['cmd'].toString();
  }

  ///启动协议端进程
  static Future run() async {
    Directory.current = Directory(Protocol.path());
    Map<String, dynamic> jsonMap = _config();
    String ucmd = Protocol.cmd();
    //分解cmd
    List<String> cmdList = ucmd.split(' ').toList();
    String pcmd = '';
    List<String> args = [];
    if (cmdList.length > 1) {
      pcmd = cmdList[0];
      args = cmdList.sublist(1);
    } else {
      pcmd = cmdList[0];
      args = [];
    }
    final stdout = File('${Protocol.path()}/nbgui_stdout.log');
    final stderr = File('${Protocol.path()}/nbgui_stderr.log');
    Process process =
        await Process.start(pcmd, args, workingDirectory: Protocol.path());
    int pid = process.pid;

    /// 重写配置文件来更新状态
    jsonMap['protocolPid'] = pid;
    jsonMap['protocolIsrunning'] = true;
    _configFile.writeAsStringSync(jsonEncode(jsonMap));

    final outputSink = stdout.openWrite();
    final errorSink = stderr.openWrite();

    // 直接监听原始字节输出
    process.stdout.listen((data) {
      outputSink.add(data);
    });

    process.stderr.listen((data) {
      errorSink.add(data);
    });
  }

  ///结束协议端进程
  static Future stop() async {
    Map botInfo = _config();
    String pidString = botInfo['protocolPid'].toString();
    int pid = int.parse(pidString);
    Process.killPid(pid, ProcessSignal.sigkill);
    //更新配置文件
    botInfo['protocolIsrunning'] = false;
    botInfo['protocolPid'] = 'Null';
    _configFile.writeAsStringSync(json.encode(botInfo));
  }

  ///更改协议端启动命令
  static void changeCmd(String cmd) {
    Map<String, dynamic> jsonMap = _config();
    jsonMap['cmd'] = cmd;
    _configFile.writeAsStringSync(jsonEncode(jsonMap));
  }
}

///Cli
class Cli {
  ///插件管理
  static plugin(mode, name) {
    if (mode == 'install') {
      String cmd = '${UserConfig.nbcliPath()} plugin install $name';
      return cmd;
    }
    if (mode == 'uninstall') {
      String cmd = '${UserConfig.nbcliPath()} plugin uninstall $name -y';
      return cmd;
    }
    return null;
  }

  ///适配器管理
  static adapter(mode, name) {
    if (mode == 'install') {
      String cmd = '${UserConfig.nbcliPath()} adapter install $name';
      return cmd;
    }
    if (mode == 'uninstall') {
      String cmd = '${UserConfig.nbcliPath()} adapter uninstall $name -y';
      return cmd;
    }
    return null;
  }

  ///驱动器管理
  static driver(mode, name) {
    if (mode == 'install') {
      String cmd = '${UserConfig.nbcliPath()} driver install $name';
      return cmd;
    }
    if (mode == 'uninstall') {
      String cmd = '${UserConfig.nbcliPath()} driver uninstall $name -y';
      return cmd;
    }
    return null;
  }

  ///CLI本体管理
  static self(mode, name) {
    if (mode == 'install') {
      String cmd = '${UserConfig.nbcliPath()} self install $name';
      return cmd;
    }
    if (mode == 'uninstall') {
      String cmd = '${UserConfig.nbcliPath()} self uninstall $name -y';
      return cmd;
    }
    if (mode == 'update') {
      String cmd = '${UserConfig.nbcliPath()} self update';
      return cmd;
    }
  }
}
