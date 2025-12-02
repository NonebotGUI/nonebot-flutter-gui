import 'dart:convert';
import 'dart:io';
import 'package:NoneBotGUI/utils/global.dart';
import 'package:NoneBotGUI/utils/userConfig.dart';
import 'package:toml/toml.dart';
import 'package:uuid/uuid.dart';

class Bot {
  static List<dynamic> loadBots() {
    final jsonList = <dynamic>[];
    Directory dir = Directory('$userDir/bots');
    if (!dir.existsSync()) return [];

    List<FileSystemEntity> files = dir.listSync();
    for (FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.json')) {
        try {
          String contents = file.readAsStringSync();
          var jsonObject = jsonDecode(contents);
          if (jsonObject is Map && jsonObject.containsKey('id')) {
            jsonList.add(jsonObject);
          }
        } catch (e) {
          print('Error loading bot config: ${file.path}, $e');
        }
      }
    }
    return jsonList;
  }

  static Map<String, dynamic> _config() {
    if (gOnOpen.isEmpty) return {};
    File file = File('$userDir/bots/$gOnOpen.json');
    if (!file.existsSync()) return {};
    String content = file.readAsStringSync();
    return jsonDecode(content);
  }

  /// 获取Bot名称
  static String name() {
    return _config()['name']?.toString() ?? 'Unknown';
  }

  /// 获取Bot的创建时间
  static String time() {
    return _config()['time']?.toString() ?? '';
  }

  /// 获取Bot的路径
  static String path() {
    return _config()['path']?.toString() ?? '';
  }

  /// 获取Bot运行状态
  static String status() {
    Map<String, dynamic> jsonMap = _config();
    return (jsonMap['isRunning'] ?? jsonMap['isrunning'] ?? false).toString();
  }

  /// 获取Bot Pid
  static String pid() {
    return _config()['pid']?.toString() ?? 'Null';
  }

  /// 直接抓取Bot日志的的Python Pid
  static pypid(path) {
    File file = File('$path/nbgui_stdout.log');
    if (!file.existsSync()) return null;
    RegExp regex = RegExp(r'Started server process \[(\d+)\]');
    Match? match =
        regex.firstMatch(file.readAsStringSync(encoding: systemEncoding));
    if (match != null && match.groupCount >= 1) {
      String pid = match.group(1)!;
      return pid;
    }
  }

  /// 唤起Bot进程
  static Future run() async {
    File cfgFile = File('$userDir/bots/$gOnOpen.json');
    final stdout = File('${Bot.path()}/nbgui_stdout.log');
    final stderr = File('${Bot.path()}/nbgui_stderr.log');

    if (!Directory(Bot.path()).existsSync()) {
      throw Exception("Bot directory not found");
    }

    Process process = await Process.start('${UserConfig.nbcliPath()}', ['run'],
        workingDirectory: Bot.path());
    int pid = process.pid;

    /// 更新配置文件
    if (cfgFile.existsSync()) {
      Map<String, dynamic> jsonMap = jsonDecode(cfgFile.readAsStringSync());
      jsonMap['pid'] = pid;
      jsonMap['isRunning'] = true;
      cfgFile.writeAsStringSync(jsonEncode(jsonMap));
    }

    final outputSink = stdout.openWrite();
    final errorSink = stderr.openWrite();

    process.stdout.listen((data) {
      outputSink.add(data);
    });

    process.stderr.listen((data) {
      errorSink.add(data);
    });
  }

  /// 结束bot进程
  static stop() async {
    File cfgFile = File('$userDir/bots/$gOnOpen.json');
    if (!cfgFile.existsSync()) return;

    Map botInfo = json.decode(cfgFile.readAsStringSync());
    String pidString = botInfo['pid'].toString();

    if (pidString != 'Null') {
      int? pid = int.tryParse(pidString);
      if (pid != null) Process.killPid(pid);
    }

    /// 更新配置文件
    botInfo['isRunning'] = false; // 使用新字段名
    botInfo['pid'] = 'Null';
    cfgFile.writeAsStringSync(json.encode(botInfo));

    if (Platform.isWindows) {
      var pyPid = Bot.pypid(Bot.path());
      if (pyPid != null) {
        await Process.start("taskkill.exe", ['/f', '/pid', pyPid.toString()],
            runInShell: true);
      }
    }
  }

  /// 重命名Bot
  /// 适配说明：因为文件名是 UUID，重命名只需修改 JSON 内容，无需改文件名
  static void rename(String newName) {
    File botcfg = File('$userDir/bots/$gOnOpen.json');
    if (botcfg.existsSync()) {
      Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
      jsonMap['name'] = newName;
      botcfg.writeAsStringSync(jsonEncode(jsonMap));
    }
  }

  /// 获取stderr.log
  static String stderr() {
    File file = File('${Bot.path()}/nbgui_stderr.log');
    if (!file.existsSync()) return "";
    return file.readAsStringSync(encoding: systemEncoding);
  }

  /// 清空stderr.log
  static void deleteStderr() {
    File file = File('${Bot.path()}/nbgui_stderr.log');
    if (file.existsSync()) file.writeAsStringSync('');
  }

  /// 删除Bot
  static void delete() async {
    File file = File('$userDir/bots/$gOnOpen.json');
    if (file.existsSync()) {
      await file.delete();
    }
    gOnOpen = '';
  }

  /// 彻底删除Bot
  static void deleteForever() async {
    String path = Bot.path();
    if (path.isNotEmpty && Directory(path).existsSync()) {
      try {
        await Directory(path).delete(recursive: true);
      } catch (e) {
        print("Error deleting directory: $e");
      }
    }
    Bot.delete();
  }

  /// 导入Bot
  static import(name, path, withProtocol, protocolPath, cmd) {
    DateTime now = DateTime.now();
    String time =
        "${now.year}年${now.month}月${now.day}日${now.hour}时${now.minute}分${now.second}秒";

    var uuid = const Uuid();
    String id = uuid.v4();

    File cfgFile = File('$userDir/bots/$id.json');
    String type = withProtocol ? 'deployed' : 'imported';

    Map<String, dynamic> botInfo = {
      "id": id,
      "name": name,
      "path": path,
      "time": time,
      "isRunning": false,
      "pid": "Null",
      "type": type,
      "protocolPath": protocolPath ?? "none",
      "cmd": cmd ?? "none",
      "protocolPid": "Null",
      "protocolIsRunning": false,
      "autoStart": false
    };

    cfgFile.writeAsStringSync(jsonEncode(botInfo));
    return "echo 写入json";
  }
}

/// 协议端相关操作 (适配 UUID 和新字段名)
class Protocol {
  // 动态获取配置文件，不要使用 static final
  static Map<String, dynamic> _config() {
    if (gOnOpen.isEmpty) return {};
    File file = File('$userDir/bots/$gOnOpen.json');
    if (!file.existsSync()) return {};
    return jsonDecode(file.readAsStringSync());
  }

  static String path() {
    return _config()['protocolPath']?.toString().replaceAll('\\\\', '\\') ?? '';
  }

  /// 协议端运行状态
  static bool status() {
    Map<String, dynamic> jsonMap = _config();
    // 优先读取新字段 protocolIsRunning
    return jsonMap['protocolIsRunning'] ??
        jsonMap['protocolIsrunning'] ??
        false;
  }

  static String pid() {
    return _config()['protocolPid']?.toString() ?? 'Null';
  }

  static String cmd() {
    return _config()['cmd']?.toString() ?? '';
  }

  /// 启动协议端进程
  static Future run() async {
    String protoPath = Protocol.path();
    if (protoPath.isEmpty || protoPath == 'none') return;

    Directory.current = Directory(protoPath);
    File cfgFile = File('$userDir/bots/$gOnOpen.json');

    String ucmd = Protocol.cmd();
    List<String> cmdList = ucmd.split(' ').toList();
    String pcmd = '';
    List<String> args = [];
    if (cmdList.isNotEmpty) {
      pcmd = cmdList[0];
      if (cmdList.length > 1) {
        args = cmdList.sublist(1);
      }
    }

    final stdout = File('$protoPath/nbgui_stdout.log');
    final stderr = File('$protoPath/nbgui_stderr.log');

    Process process =
        await Process.start(pcmd, args, workingDirectory: protoPath);
    int pid = process.pid;

    /// 更新配置文件
    if (cfgFile.existsSync()) {
      Map<String, dynamic> jsonMap = jsonDecode(cfgFile.readAsStringSync());
      jsonMap['protocolPid'] = pid;
      jsonMap['protocolIsRunning'] = true; // 使用新字段名
      cfgFile.writeAsStringSync(jsonEncode(jsonMap));
    }

    final outputSink = stdout.openWrite();
    final errorSink = stderr.openWrite();

    process.stdout.listen((data) => outputSink.add(data));
    process.stderr.listen((data) => errorSink.add(data));
  }

  /// 结束协议端进程
  static Future stop() async {
    File cfgFile = File('$userDir/bots/$gOnOpen.json');
    if (!cfgFile.existsSync()) return;

    Map botInfo = json.decode(cfgFile.readAsStringSync());
    String pidString = botInfo['protocolPid'].toString();

    if (pidString != 'Null') {
      int? pid = int.tryParse(pidString);
      if (pid != null) Process.killPid(pid, ProcessSignal.sigkill);
    }

    // 更新配置文件
    botInfo['protocolIsRunning'] = false; // 使用新字段名
    botInfo['protocolPid'] = 'Null';
    cfgFile.writeAsStringSync(json.encode(botInfo));
  }

  static void changeCmd(String cmd) {
    File cfgFile = File('$userDir/bots/$gOnOpen.json');
    if (cfgFile.existsSync()) {
      Map<String, dynamic> jsonMap = jsonDecode(cfgFile.readAsStringSync());
      jsonMap['cmd'] = cmd;
      cfgFile.writeAsStringSync(jsonEncode(jsonMap));
    }
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

///插件
class Plugin {
  ///禁用插件
  static disable(name) {
    File disable = File('${Bot.path()}/.disabled_plugins');
    File pyprojectFile = File('${Bot.path()}/pyproject.toml');
    String pyprojectContent = pyprojectFile.readAsStringSync();
    List<String> linesWithoutComments = pyprojectContent
        .split('\n')
        .map((line) {
          int commentIndex = line.indexOf('#');
          if (commentIndex != -1) {
            return line.substring(0, commentIndex).trim();
          }
          return line;
        })
        .where((line) => line.isNotEmpty)
        .toList();
    String pyprojectWithoutComments = linesWithoutComments.join('\n');
    var toml = TomlDocument.parse(pyprojectWithoutComments).toMap();
    var nonebot = toml['tool']['nonebot'];
    List pluginsList = nonebot['plugins'];

    // 移除指定的插件
    pluginsList.remove(name);
    nonebot['plugins'] = pluginsList;

    // 手动更新 plugins 列表
    String updatedTomlContent = pyprojectContent.replaceFirstMapped(
        RegExp(r'plugins = \[([^\]]*)\]', dotAll: true),
        (match) =>
            'plugins = [${pluginsList.map((plugin) => '"$plugin"').join(', ')}]');

    pyprojectFile.writeAsStringSync(updatedTomlContent);
    if (disable.readAsStringSync().isEmpty) {
      disable.writeAsStringSync(name);
    } else {
      disable.writeAsStringSync('${disable.readAsStringSync()}\n$name');
    }
  }

  ///启用插件
  static enable(name) {
    File disable = File('${Bot.path()}/.disabled_plugins');
    File pyprojectFile = File('${Bot.path()}/pyproject.toml');
    String pyprojectContent = pyprojectFile.readAsStringSync();
    var toml = TomlDocument.parse(pyprojectContent).toMap();
    var nonebot = toml['tool']['nonebot'];
    List pluginsList = List<String>.from(nonebot['plugins']);

    if (!pluginsList.contains(name)) {
      pluginsList.add(name);
    }

    nonebot['plugins'] = pluginsList;

    // 手动更新 plugins 列表
    String updatedTomlContent = pyprojectContent.replaceFirstMapped(
        RegExp(r'plugins = \[([^\]]*)\]', dotAll: true),
        (match) =>
            'plugins = [${pluginsList.map((plugin) => '"$plugin"').join(', ')}]');

    pyprojectFile.writeAsStringSync(updatedTomlContent);
    String disabled = disable.readAsStringSync();
    List<String> disabledList = disabled.split('\n');
    disabledList.remove(name);
    disable.writeAsStringSync(disabledList.join('\n'));
  }
}
