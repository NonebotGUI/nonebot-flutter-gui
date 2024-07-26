import 'dart:io';
import 'dart:core';
import 'dart:convert';
import 'package:NoneBotGUI/darts/global.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toml/toml.dart';



//超～级～大～史～山～
//存放一些"小"功能的地方


///初始化用户文件夹
createMainFolder() async {
  Directory usrDir = await getApplicationSupportDirectory();
  if (!usrDir.existsSync()) {
    usrDir.createSync();
  }
  String dir = usrDir.path;
  File cfgFile = File('$dir/user_config.json');
  if (!cfgFile.existsSync()) {
    String cfg = '''
  {
    "python":"default",
    "nbcli":"default",
    "color":"light",
    "checkUpdate": true,
    "encoding": "systemEncoding",
    "httpencoding": "utf8"
  }
  ''';
    cfgFile.writeAsStringSync(cfg);
  }
  Directory botDir = Directory('$dir/bots/');
  if (!botDir.existsSync()) {
    botDir.createSync();
  }
  return dir;
}

createMainFolderBots() {
  if (Platform.isLinux) {
    String dir = "$userDir/bots/";
    return dir;
  } else if (Platform.isMacOS) {
    String dir = "$userDir/bots/";
    return dir;
  } else if (Platform.isWindows) {
    String dir = "$userDir\\bots\\";
    return dir;
  }
}

userReadConfigPython(dir) {
  File file = File('${dir}/user_config.json');
  Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());
  String pyPath = jsonMap['python'].toString();
  if (pyPath == 'default') {
    if (Platform.isLinux || Platform.isMacOS) {
      return 'python3';
    } else if (Platform.isWindows) {
      return 'python.exe';
    }
  } else {
    return pyPath.replaceAll('\\', '\\\\');
  }
}

setPyPath(dir,path) {
  File file = File('${dir}/user_config.json');
  Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());
  jsonMap['python'] = path;
  file.writeAsStringSync(jsonEncode(jsonMap));
}

userReadConfigNbcli(dir) {
  File file = File('${dir}/user_config.json');
  Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());
  String nbcliPath = jsonMap['nbcli'].toString();
  if (nbcliPath == 'default') {
    return 'nb';
  } else {
    return nbcliPath.replaceAll('\\', '\\\\');
  }
}

setNbcliPath(dir,path) {
  File file = File('${dir}/user_config.json');
  Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());
  jsonMap['nbcli'] = path;
  file.writeAsStringSync(jsonEncode(jsonMap));
}

userColorMode(dir) {
  File file = File('${dir}/user_config.json');
  Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());
  if ( jsonMap.containsKey("color")){
    String colorMode = jsonMap['color'].toString();
    return colorMode;
  }
  else {
    setColorMode(dir,'light');
    return 'light';
  }
}
setColorMode(dir,mode) {
  File file = File('${dir}/user_config.json');
  Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());
  jsonMap['color'] = mode;
  file.writeAsStringSync(jsonEncode(jsonMap));
}

userEncoding() {
  File file = File('$userDir/user_config.json');
  Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());
  if ( jsonMap.containsKey("encoding")){
    String encoding = jsonMap['encoding'].toString();
    return (encoding == 'utf8') ? utf8 : systemEncoding;
  }
  else {
    setEncoding('systemEncoding');
    return systemEncoding;
  }
}
setEncoding(mode) {
  File file = File('$userDir/user_config.json');
  Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());
  jsonMap['encoding'] = mode;
  file.writeAsStringSync(jsonEncode(jsonMap));
}

userHttpEncoding() {
  File file = File('$userDir/user_config.json');
  Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());
  if ( jsonMap.containsKey("httpencoding")){
    String encoding = jsonMap['httpencoding'].toString();
    return (encoding == 'utf8') ? utf8 : systemEncoding;
  }
  else {
    setHttpEncoding('utf8');
    return utf8;
  }
}
setHttpEncoding(mode) {
  File file = File('$userDir/user_config.json');
  Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());
  jsonMap['httpencoding'] = mode;
  file.writeAsStringSync(jsonEncode(jsonMap));
}


setCheckUpdate(tof) {
  File file = File('$userDir/user_config.json');
  Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());
  jsonMap['checkUpdate'] = tof;
  file.writeAsStringSync(jsonEncode(jsonMap));
}

userCheckUpdate() {
  File file = File('$userDir/user_config.json');
  Map jsonMap = jsonDecode(file.readAsStringSync());
  if ( jsonMap.containsKey("checkUpdate")){
    bool checkUpdate = jsonMap['checkUpdate'];
    return checkUpdate;
  }
  else {
    setCheckUpdate(true);
    return true;
  }
}


//检查py
Future<String> getPyVer(dir) async {
  try {
    if (Platform.isLinux || Platform.isMacOS) {
      ProcessResult results =
          await Process.run('${userReadConfigPython(dir)}', ['--version']);
      return results.stdout.trim();
    } else if (Platform.isWindows) {
      ProcessResult results =
          await Process.run('${userReadConfigPython(dir)}', ['--version']);
      return results.stdout.trim();
    } else {
      return '不支持的平台...';
    }
  } catch (e) {
    return '你似乎还没有安装python？';
  }
}

//检查nbcli
Future<String> getnbcliver(dir) async {
  try {
    final ProcessResult results =
        await Process.run('${userReadConfigNbcli(dir)}', ['-V']);
    return results.stdout;
  } catch (error) {
    return '你似乎还没有安装nb-cli？';
  }
}

//创建bot的配置文件
Future createBotWriteConfig(dir,name, path, venv, dep, drivers, adapters, template, plugindir) async {
  String name_ = name.toString();
  String path_ = path.toString();
  String venv_ = venv.toString();
  String dep_ = dep.toString();
  String drivers_ = drivers.toString();
  String adapters_ = adapters.toString();
  String template_ = template.toString();
  String plugindir_ = plugindir.toString();
  File file = File('${dir}/cache_config.txt');
  File fileDrivers = File('${dir}/cache_drivers.txt');
  File fileAdapters = File('${dir}/cache_adapters.txt');
  file.writeAsStringSync('$name_,$path_,$venv_,$dep_,$template_,$plugindir_');
  fileDrivers.writeAsStringSync(drivers_);
  fileAdapters.writeAsStringSync(adapters_);
}

createBotReadConfig(dir) {
  File file = File('${userDir}/cache_config.txt');
  String args = file.readAsStringSync();
  return args;
}

createBotReadConfigName(dir) {
  File file = File('${userDir}/cache_config.txt');
  String args = file.readAsStringSync();
  List args_ = args.split(',');
  return args_[0];
}

createBotReadConfigPath(dir) {
  File file = File('${userDir}/cache_config.txt');
  String args = file.readAsStringSync();
  List args_ = args.split(',');
  return args_[1];
}

createBotReadConfigVENV(dir) {
  File file = File('${userDir}/cache_config.txt');
  String args = file.readAsStringSync();
  List args_ = args.split(',');
  return args_[2];
}

createBotReadConfigDep(dir) {
  File file = File('${userDir}/cache_config.txt');
  String args = file.readAsStringSync();
  List args_ = args.split(',');
  return args_[3];
}

createBotReadConfigTemplate(dir) {
  File file = File('${userDir}/cache_config.txt');
  String args = file.readAsStringSync();
  List args_ = args.split(',');
  return args_[4];
}

createBotReadConfigPluginDir(dir) {
  File file = File('${userDir}/cache_config.txt');
  String args = file.readAsStringSync();
  List args_ = args.split(',');
  return args_[5];
}

//处理适配器和驱动器
createBotWriteConfigRequirement(dir,String drivers, String adapters){
  drivers = drivers.toLowerCase();
  String driverlist =
      drivers.split(',').map((driver) => 'nonebot2[$driver]').join(',');
  driverlist = driverlist.replaceAll(',', '\n');

  RegExp regex = RegExp(r'\(([^)]+)\)');
  Iterable<Match> matches = regex.allMatches(adapters);
  String adapterlist = '';
  for (Match match in matches) {
    adapterlist += '${match.group(1)}\n';
  }
  //处理OB V11与OB V12
  adapterlist = adapterlist
      .replaceAll('nonebot-adapter-onebot.v11', 'nonebot-adapter-onebot')
      .replaceAll('nonebot-adapter-onebot.v12', 'nonebot-adapter-onebot');
  File file = File('${userDir}/requirements.txt');
  file.writeAsStringSync('$driverlist\n$adapterlist');
}

//判断平台并使用对应的venv指令
installBot(dir,path, name, venv, dep) {
  if (venv == 'true') {
    if (dep == 'true') {
      if (Platform.isLinux) {
        String installbot =
            '$path/$name/.venv/bin/pip install -r $userDir/requirements.txt';
        return installbot;
      } else if (Platform.isWindows) {
        String installbot =
            '$path\\$name\\.venv\\Scripts\\pip.exe install -r $userDir\\requirements.txt';
        return installbot;
      } else if (Platform.isMacOS) {
        String installbot =
            '$path/$name/.venv/bin/pip install -r requirements.txt';
        return installbot;
      }
    } else if (dep == 'false') {
      File requirements = File('$userDir/requirements.txt');
      requirements.copy(
          '${createBotReadConfigPath(dir)}/${createBotReadConfigName(dir)}/requirements.txt');
      return 'echo 跳过依赖安装，将requirements.txt复制至${createBotReadConfigPath(dir)}/${createBotReadConfigName(dir)}下';
    }
  } else if (venv == 'false') {
    if (dep == 'true') {
      String installbot =
          '${userReadConfigPython(dir)} -m pip install -r requirements.txt';
      return installbot;
    } else if (dep == 'false') {
      File requirements = File('$userDir/requirements.txt');
      requirements.copy(
          '${createBotReadConfigPath(dir)}/${createBotReadConfigName(dir)}/requirements.txt');
      return 'echo 跳过依赖安装，将requirements.txt复制至${createBotReadConfigPath(dir)}/${createBotReadConfigName(dir)}下';
    }
  }
}

createVENVEcho(path, name) {
  if (Platform.isLinux) {
    String echo = "echo 在$path/$name/.venv/中创建虚拟环境";
    return echo;
  } else if (Platform.isWindows) {
    String echo = "echo 在$path\\$name\\.venv\\中创建虚拟环境";
    return echo;
  } else if (Platform.isMacOS) {
    String echo = "echo 在$path/$name/.venv/中创建虚拟环境";
    return echo;
  }
}

createVENV(dir,path, name, venv) {
  if (venv == 'true') {
    if (Platform.isLinux || Platform.isMacOS) {
      String createvenv =
          '${userReadConfigPython(dir)} -m venv $path/$name/.venv --prompt $name';
      return createvenv;
    } else if (Platform.isWindows) {
      String createvenv =
          '${userReadConfigPython(dir)} -m venv $path\\$name\\.venv --prompt $name';
      return createvenv;
    }
  } else if (venv == 'false') {
    return 'echo 虚拟环境已关闭，跳过...';
  }
}

createFolder(udir,path, name, plugindir) {
  Directory dir = Directory('$path/$name');
  Directory dirBots = Directory('$udir/bots');
  if (!dir.existsSync()) {
    dir.createSync();
  }
  if (!dirBots.existsSync()) {
    dirBots.createSync();
  }
  if (createBotReadConfigTemplate(dir) == 'simple(插件开发者)') {
    if (plugindir == '在[bot名称]/[bot名称]下') {
      Directory dirSrc = Directory('$path/$name/$name');
      Directory dirSrcPlugins = Directory('$path/$name/$name/plugins');
      if (!dirSrc.existsSync()) {
        dirSrc.createSync();
      }
      if (!dirSrcPlugins.existsSync()) {
        dirSrcPlugins.createSync();
      }
    } else if (plugindir == '在src文件夹下') {
      Directory dirSrc = Directory('$path/$name/src');
      Directory dirSrcPlugins = Directory('$path/$name/src/plugins');
      if (!dirSrc.existsSync()) {
        dirSrc.createSync();
      }
      if (!dirSrcPlugins.existsSync()) {
        dirSrcPlugins.createSync();
      }
    }
  }
}

writeENV(path, name, port) {
  File file = File('$userDir/cache_drivers.txt');
  String drivers = file.readAsStringSync();
  drivers = drivers.toLowerCase();
  String driverlist = drivers.split(',').map((driver) => '~$driver').join('+');
  if (createBotReadConfigTemplate(userDir) == 'bootstrap(初学者或用户)') {
    String env = port.toString().isNotEmpty ? 'DRIVER=$driverlist' : 'DRIVER=$driverlist\n\n\n\n\nPORT=$port';
    File fileEnv = File('$path/$name/.env.prod');
    fileEnv.writeAsStringSync(env);
    String echo = "echo 写入.env文件";
    return echo;
  } else if (createBotReadConfigTemplate(userDir) == 'simple(插件开发者)') {
    String env = 'ENVIRONMENT=dev\nDRIVER=$driverlist';
    File fileEnv = File('$path/$name/.env');
    fileEnv.writeAsStringSync(env);
    File fileEnvdev = File('$path/$name/.env.dev');
    String devEnv = port.toString().isNotEmpty ? 'LOG_LEVEL=DEBUG' : 'LOG_LEVEL=DEBUG\n\n\n\n\nPORT=$port';
    fileEnvdev.writeAsStringSync(devEnv);
    File fileEnvprod = File('$path/$name/.env.prod');
    fileEnvprod.createSync();
    String echo = "echo 写入.env文件";
    return echo;
  }
}

writePyProject(path, name) {
  File file = File('$userDir/cache_adapters.txt');
  String adapters = file.readAsStringSync();

  RegExp regex = RegExp(r'\(([^)]+)\)');
  Iterable<Match> matches = regex.allMatches(adapters);
  String adapterlist = '';
  for (Match match in matches) {
    adapterlist += '${match.group(1)},';
  }
  String adapterlist_ = adapterlist.split(',').map((adapter) =>'{ name = "${adapter.replaceAll('nonebot-adapter-', '').replaceAll('.', ' ')}", module_name = "${adapter.replaceAll('-', '.').replaceAll('adapter', 'adapters')}" }') .join(',');

  if (createBotReadConfigTemplate(userDir) == 'bootstrap(初学者或用户)') {
    String pyproject = '''
    [project]
    name = "$name"
    version = "0.1.0"
    description = "$name"
    readme = "README.md"
    requires-python = ">=3.8, <4.0"

    [tool.nonebot]
    adapters = [
        $adapterlist_
    ]
    plugins = []
    plugin_dirs = []
    builtin_plugins = ["echo"]
  ''';
    File filePyproject = File('$path/$name/pyproject.toml');
    filePyproject.writeAsStringSync(pyproject.replaceAll(
        ',{ name = "", module_name = "" }',
        ''.replaceAll('adapter', 'adapters')));
    String echo = "echo 写入pyproject.toml";
    return echo;
  } else if (createBotReadConfigTemplate(userDir) == 'simple(插件开发者)') {
    if (createBotReadConfigPluginDir(userDir) == '在src文件夹下') {
      String pyproject = '''
    [project]
    name = "$name"
    version = "0.1.0"
    description = "$name"
    readme = "README.md"
    requires-python = ">=3.8, <4.0"

    [tool.nonebot]
    adapters = [
        $adapterlist_
    ]
    plugins = []
    plugin_dirs = ["src/plugins"]
    builtin_plugins = ["echo"]
  ''';
      File filePyproject = File('$path/$name/pyproject.toml');
      filePyproject.writeAsStringSync(pyproject.replaceAll(
          ',{ name = "", module_name = "" }',
          ''.replaceAll('adapter', 'adapters')));
      String echo = "echo 写入pyproject.toml";
      return echo;
    } else if (createBotReadConfigPluginDir(userDir) == '在[bot名称]/[bot名称]下') {
      String pyproject = '''
    [project]
    name = "$name"
    version = "0.1.0"
    description = "$name"
    readme = "README.md"
    requires-python = ">=3.8, <4.0"

    [tool.nonebot]
    adapters = [
        $adapterlist_
    ]
    plugins = []
    plugin_dirs = ["$name/plugins"]
    builtin_plugins = ["echo"]
  ''';
      File filePyproject = File('$path/$name/pyproject.toml');
      filePyproject.writeAsStringSync(pyproject.replaceAll(
          ',{ name = "", module_name = "" }',
          ''.replaceAll('adapter', 'adapters')));
      String echo = "echo 写入pyproject.toml";
      return echo;
    }
  }
}

///写入Bot的json文件
writebot(dir,name, path, type, protocolPath, cmd) {
  DateTime now = DateTime.now();
  String time =
      "${now.year}年${now.month}月${now.day}日${now.hour}时${now.minute}分${now.second}秒";
  File cfgFile = File('${dir}/bots/$name.$time.json');

  if (Platform.isWindows) {
    String botInfo = '''
{
  "name": "$name",
  "path": "${path.replaceAll('\\', '\\\\')}\\\\$name",
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

  if (Platform.isLinux) {
    String botInfo = '''
{
  "name": "$name",
  "path": "$path/$name",
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

  if (Platform.isMacOS) {
    String botInfo = '''
{
  "name": "$name",
  "path": "$path/$name",
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

//导入
importbot(dir,name, path) {
  DateTime now = DateTime.now();
  String time =
      "${now.year}年${now.month}月${now.day}日${now.hour}时${now.minute}分${now.second}秒";
  File cfgFile = File('${dir}/bots/$name.$time.json');

  if (Platform.isWindows) {
    String botInfo = '''
{
  "name": "$name",
  "path": "${path.replaceAll('\\', '\\\\')}",
  "time": "$time",
  "isrunning": "false",
  "pid": "Null",
  "type": "imported",
  "protocolPath": "none",
  "cmd": "none",
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
  "type": "imported",
  "protocolPath": "none",
  "cmd": "none",
  "protocolPid": "Null",
  "protocolIsrunning": false
}
''';
    cfgFile.writeAsStringSync(botInfo);
    String echo = "echo 写入json";
    return echo;
  }
}

//管理bot的函数
Future manageBotOnOpenCfg(name, time) async {
  gOnOpen = '$name.$time';
}

manageBotReadCfgName() {
  File botcfg = File('$userDir/bots/$gOnOpen.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['name'].toString();
}

manageBotReadCfgPath() {
  String cfg = gOnOpen;
  if (gOnOpen.isNotEmpty){
  File botcfg = File('$userDir/bots/$cfg.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['path'].toString();
  }
}

manageBotReadCfgTime() {
  String cfg = gOnOpen;
  File botcfg = File('$userDir/bots/$cfg.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['time'].toString();
}

manageBotReadCfgStatus() {
  String cfg = gOnOpen;
  File botcfg = File('$userDir/bots/$cfg.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['isrunning'].toString();
}

manageBotReadCfgPid() {
  String cfg = gOnOpen;
  File botcfg = File('$userDir/bots/$cfg.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['pid'].toString();
}

manageBotViewStderr(dir) {
  File stderrfile = File('$dir/nbgui_stderr.log');
  String stderr = stderrfile.readAsStringSync(encoding: systemEncoding);
  return stderr;
}

deleteStderr(dir) {
  File stderrfile = File('$dir/nbgui_stderr.log');
  String clear = "";
  stderrfile.writeAsString(clear);
}

Future openFolder(path) async {
  if (Platform.isWindows) {
    await Process.run('explorer', [path]);
  } else if (Platform.isLinux) {
    await Process.run('xdg-open', [path]);
  } else if (Platform.isMacOS) {
    await Process.run('open', [path]);
  }
}

///唤起Bot进程
Future runBot(dir,String path) async {
  String name = manageBotReadCfgName();
  String time = manageBotReadCfgTime();
  Directory.current = Directory(path);
  File cfgFile = File('$userDir/bots/$name.$time.json');
  final stdout = File('$path/nbgui_stdout.log');
  final stderr = File('$path/nbgui_stderr.log');
  Process process = await Process.start('${userReadConfigNbcli(dir)}', ['run'],workingDirectory: path);
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
stopBot(dir) async {
  //读取配置文件
  String name = manageBotReadCfgName();
  String time = manageBotReadCfgTime();
  File cfgFile = File('$userDir/bots/$name.$time.json');
  Map botInfo = json.decode(cfgFile.readAsStringSync());
  String pidString = botInfo['pid'].toString();
  int pid = int.parse(pidString);
  Process.killPid(pid);
  ///更新配置文件
  botInfo['isrunning'] = 'false';
  botInfo['pid'] = 'Null';
  cfgFile.writeAsStringSync(json.encode(botInfo));
  //如果平台为Windows则释放端口
  if (Platform.isWindows){
    await Process.start("taskkill.exe", ['/f', '/pid', manageBotReadCfgPyPid().toString()],runInShell: true);
  }
  setPyPid('Null');
}



///重命名Bot
renameBot(name) {
  //暂存数据
  String time = manageBotReadCfgTime();
  String oldName = manageBotReadCfgName();

  //重写配置文件
  File botcfg = File('$userDir/bots/$oldName.$time.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  jsonMap['name'] = name;
  botcfg.writeAsStringSync(jsonEncode(jsonMap));

  //重命名文件
  File('$userDir/bots/$oldName.$time.json')
  .rename('$userDir/bots/$name.$time.json');

  //更新on_open.txt
  String newData = "$name.$time";
  gOnOpen = newData;

}




///获取Python PID
getPyPid(dir) {
  File file = File('${manageBotReadCfgPath()}/nbgui_stdout.log');
  RegExp regex = RegExp(r'Started server process \[(\d+)\]');
  Match? match = regex.firstMatch(file.readAsStringSync(encoding: systemEncoding));
  if (match != null && match.groupCount >= 1) {
    String pid = match.group(1)!;
    setPyPid(pid);
    return pid;
  } else {
    setPyPid("Null");
    return "Null";
  }
}

setPyPid(pid) {
  File botcfg = File('$userDir/bots/$gOnOpen.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  jsonMap['pypid'] = pid;
  botcfg.writeAsStringSync(jsonEncode(jsonMap));
}

manageBotReadCfgPyPid(){
  File botcfg = File('$userDir/bots/$gOnOpen.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['pypid'].toString();
}


///删除bot配置文件
deleteBot(dir) async {
  String name = manageBotReadCfgName();
  String time = manageBotReadCfgTime();
  File cfgFile = File('$dir/bots/$name.$time.json');
  gOnOpen = '';
  cfgFile.delete();
}

///连同bot文件夹一起删除
deleteBotAll(dir) async {
  String name = manageBotReadCfgName();
  String time = manageBotReadCfgTime();
  File cfgFile = File('$userDir/bots/$name.$time.json');
  String path = manageBotReadCfgPath();
  Directory(path).delete(recursive: true);
  gOnOpen = '';
  cfgFile.delete();
}

///清除日志
clearLog(dir) async {
  String path = manageBotReadCfgPath();
  File stdout = File('$path/nbgui_stdout.log');
  stdout.delete();
  String info = "[INFO]Welcome to Nonebot GUI!";
  stdout.writeAsString(info);
}

manageCliPlugin(dir,manage, pluginName) {
  if (manage == 'install') {
    String cmd = '${userReadConfigNbcli(dir)} plugin install $pluginName';
    return cmd;
  }
  if (manage == 'uninstall') {
    String cmd = '${userReadConfigNbcli(dir)} plugin uninstall $pluginName -y';
    return cmd;
  }
}

manageCliAdapter(dir,manage, adapterName) {
  if (manage == 'install') {
    String cmd = '${userReadConfigNbcli(dir)} adapter install $adapterName';
    return cmd;
  }
  if (manage == 'uninstall') {
    String cmd = '${userReadConfigNbcli(dir)} adapter uninstall $adapterName -y';
    return cmd;
  }
}

manageCliDriver(dir,manage, driverName) {
  if (manage == 'install') {
    String cmd = '${userReadConfigNbcli(dir)} driver install $driverName';
    return cmd;
  }
  if (manage == 'uninstall') {
    String cmd = '${userReadConfigNbcli(dir)} driver uninstall $driverName -y';
    return cmd;
  }
}

manageCliSelf(dir,manage, packageName) {
  if (manage == 'install') {
    String cmd = '${userReadConfigNbcli(dir)} self install $packageName';
    return cmd;
  }
  if (manage == 'uninstall') {
    String cmd = '${userReadConfigNbcli(dir)} self uninstall $packageName -y';
    return cmd;
  }
  if (manage == 'update') {
    String cmd = '${userReadConfigNbcli(dir)} self update';
    return cmd;
  }
}

//补救用，发现进managebot时如果找不到stderr就会炸（）
createLog(path) {
  File stdout = File('$path/nbgui_stdout.log');
  File stderr = File('$path/nbgui_stderr.log');
  if (!stdout.existsSync()) {
    stdout.createSync();
  }
  if (!stderr.existsSync()) {
    stderr.createSync();
  }
}

///从pyproject.toml中读取插件列表
getPluginList(dir) {
  File pyprojectFile = File('${manageBotReadCfgPath()}/pyproject.toml');
  String pyproject = pyprojectFile.readAsStringSync();
  var toml = TomlDocument.parse(pyproject).toMap();
  var nonebot = toml['tool']['nonebot'];
  List pluginsList = nonebot['plugins'];
  return pluginsList;
}


setDeployPath(path, name){
  if (Platform.isWindows){
    deployPath = '${path.toString().replaceAll('\\', '\\\\')}\\\\$name';
  }
  else if (Platform.isLinux || Platform.isMacOS){
    deployPath = '$path/$name';
  }
}


///获取协议端路径
getProtocolPath(){
  File botcfg = File('$userDir/bots/$gOnOpen.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['protocolPath'].toString();
}

///获取协议端启动命令
getProtocolCmd(){
  File botcfg = File('$userDir/bots/$gOnOpen.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['cmd'].toString();
}

///启动协议端进程
Future runProtocol() async {
  Directory.current = Directory(getProtocolPath());
  File cfgFile = File('$userDir/bots/$gOnOpen.json');
  String ucmd = getProtocolCmd();
  //分解cmd
  List<String> cmdList = ucmd.split(' ').toList();
  String pcmd = '';
  List<String> args = [];
  if (cmdList.length > 1){
    pcmd = cmdList[0];
    args = cmdList.sublist(1);
  } else {
    pcmd = cmdList[0];
    args = [];
  }
  final stdout = File('${getProtocolPath()}/nbgui_stdout.log');
  final stderr = File('${getProtocolPath()}/nbgui_stderr.log');
  Process process = await Process.start(pcmd, args,workingDirectory: getProtocolPath());
  int pid = process.pid;
  /// 重写配置文件来更新状态
  Map<String, dynamic> jsonMap = jsonDecode(cfgFile.readAsStringSync());
  jsonMap['protocolPid'] = pid;
  jsonMap['protocolIsrunning'] = true;
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


///结束协议端进程
stopProtocol() async {
  //读取配置文件
  File cfgFile = File('$userDir/bots/$gOnOpen.json');
  Map botInfo = json.decode(cfgFile.readAsStringSync());
  String pidString = botInfo['protocolPid'].toString();
  int pid = int.parse(pidString);
  Process.killPid(pid,ProcessSignal.sigkill);
  ///更新配置文件
  botInfo['protocolIsrunning'] = false;
  botInfo['protocolPid'] = 'Null';
  cfgFile.writeAsStringSync(json.encode(botInfo));
}

///获取协议端进程id
getProtocolPid(){
  File cfgFile = File('$userDir/bots/$gOnOpen.json');
  Map botInfo = json.decode(cfgFile.readAsStringSync());
  String pidString = botInfo['protocolPid'].toString();
  return pidString;
}

///获取协议端运行状态
getProtocolStatus(){
  File cfgFile = File('$userDir/bots/$gOnOpen.json');
  Map botInfo = json.decode(cfgFile.readAsStringSync());
  bool protocolStatus = botInfo['protocolIsrunning'];
  return protocolStatus;
}


//我真服了...
setCmd(jsonMap){
  if (Platform.isWindows){
    cmd = jsonMap['cmdWin'];
    if (needQQ){
      cmd = cmd.replaceAll('NBGUI.QQNUM', botQQ);
    }
  }
  else if (Platform.isLinux || Platform.isMacOS){
    cmd = jsonMap['cmd'];
    if (needQQ){
      cmd = cmd.replaceAll('NBGUI.QQNUM', botQQ);
    }
  }
}



///写入协议端配置文件
writeProtocolConfig(){
  //配置文件绝对路径
  String path = '$extDir/$configPath';
  File pcfg = File(needQQ ? path.replaceAll('NBGUI.QQNUM', botQQ) : path);
  // 将wsPort转为int类型
  String content = botConfig.toString().replaceAll('NBGUI.HOST:NBGUI.PORT', "$wsHost:$wsPort")
                            .replaceAll('"NBGUI.PORT"', wsPort)
                            .replaceAll('NBGUI.HOST', wsHost);
  pcfg.writeAsStringSync(content);
  if (Platform.isLinux || Platform.isMacOS){
    // 给予执行权限
    Process.run('chmod', ['+x', cmd],workingDirectory: extDir,runInShell: true);
  }
  return 'echo 配置协议端';
}



///写入requirements.txt和pyproject.toml
writeReq(name, adapter, drivers){
  drivers = drivers.toLowerCase();
    String driverlist =
        drivers.split(',').map((driver) => 'nonebot2[$driver]').join(',');
    driverlist = driverlist.replaceAll(',', '\n');
    File('$userDir/cache_drivers.txt').writeAsStringSync(drivers);
    String reqs = "$driverlist\n$adapter";
    File('$userDir/requirements.txt').writeAsStringSync(reqs);
  if (deployTemplate == 'bootstrap(初学者或用户)') {
    String pyproject = '''
    [project]
    name = "$name"
    version = "0.1.0"
    description = "$name"
    readme = "README.md"
    requires-python = ">=3.8, <4.0"

    [tool.nonebot]
    adapters = [
        { name = "onebot v11", module_name = "nonebot.adapters.onebot.v11" }
    ]
    plugins = []
    plugin_dirs = []
    builtin_plugins = ["echo"]
  ''';
    File('$deployPath/pyproject.toml').writeAsStringSync(pyproject);
  } else if (deployTemplate == 'simple(插件开发者)') {
    if (deployPluginDir == '在src文件夹下') {
      String pyproject = '''
    [project]
    name = "$name"
    version = "0.1.0"
    description = "$name"
    readme = "README.md"
    requires-python = ">=3.8, <4.0"

    [tool.nonebot]
    adapters = [
        { name = "$adapter", module_name = "nonebot.adapters.onebot.v11" }
    ]
    plugins = []
    plugin_dirs = ["src/plugins"]
    builtin_plugins = ["echo"]
  ''';
      File('$deployPath/pyproject.toml').writeAsStringSync(pyproject);
    } else if (deployTemplate == '在[bot名称]/[bot名称]下') {
      String pyproject = '''
    [project]
    name = "$name"
    version = "0.1.0"
    description = "$name"
    readme = "README.md"
    requires-python = ">=3.8, <4.0"

    [tool.nonebot]
    adapters = [
        { name = "onebot v11", module_name = "nonebot.adapters.onebot.v11" }
    ]
    plugins = []
    plugin_dirs = ["$name/plugins"]
    builtin_plugins = ["echo"]
    ''';
    File('$deployPath/pyproject.toml').writeAsStringSync(pyproject);
    }
  }
  return 'echo 写入依赖...';
}


///更改启动命令
reEditCmd(cmd) {
  //重写配置文件
  File botcfg = File('$userDir/bots/$gOnOpen.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  jsonMap['cmd'] = cmd;
  botcfg.writeAsStringSync(jsonEncode(jsonMap));

}


///检查bot的type键
//适配老东西（
checkBotType(){
  File botcfg = File('$userDir/bots/$gOnOpen.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  if (jsonMap.containsKey('type')){
    return (jsonMap['type'] == 'deployed') ? true : false;
  }
  else {
    return false;
  }
}

///获取extdir
getExtDir(String path){
  if (Platform.isWindows){
    return path.replaceAll("/", "\\").replaceAll("Protocol\\", "Protocol\\\\");
  }
  else {
    return path;
  }
}