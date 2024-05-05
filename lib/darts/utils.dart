import 'dart:io';
import 'dart:core';
import 'dart:convert';
import 'package:toml/toml.dart';

//存放一些小功能的地方
createMainFolder() {
  if (Platform.isWindows) {
    Directory dir = Directory('${Platform.environment['USERPROFILE']!}/.nbgui');
    if (!dir.existsSync()) {
      dir.createSync();
    }
    Directory.current = dir;
    File cfgFile = File(
        '${dir.toString().replaceAll("Directory: ", '').replaceAll("'", '')}/user_config.json');
    if (!cfgFile.existsSync()) {
      String cfg = '''
    {
      "python":"default",
      "nbcli":"default"
    }
    ''';
      cfgFile.writeAsStringSync(cfg);
    }
    return dir.toString().replaceAll("Directory: ", '').replaceAll("'", '');
  } else if (Platform.isLinux || Platform.isMacOS) {
    Directory dir = Directory('${Platform.environment['HOME']!}/.nbgui');
    if (!dir.existsSync()) {
      dir.createSync();
    }
    Directory.current = dir;
    File cfgFile = File(
        '${dir.toString().replaceAll("Directory: ", '').replaceAll("'", '')}/user_config.json');
    if (!cfgFile.existsSync()) {
      String cfg = '''
    {
      "python":"default",
      "nbcli":"default"
    }
    ''';
      cfgFile.writeAsStringSync(cfg);
    }
    return dir.toString().replaceAll("Directory: ", '').replaceAll("'", '');
  }
}

createMainFolderBots() {
  if (Platform.isLinux) {
    String dir = "${createMainFolder()}/bots/";
    return dir;
  } else if (Platform.isMacOS) {
    String dir = "${createMainFolder()}/bots/";
    return dir;
  } else if (Platform.isWindows) {
    String dir = "${createMainFolder()}\\bots\\";
    return dir;
  }
}

userReadConfigPython() {
  File file = File('${createMainFolder()}/user_config.json');
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

setPyPath(path) {
  File file = File('${createMainFolder()}/user_config.json');
  Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());
  jsonMap['python'] = path;
  file.writeAsStringSync(jsonEncode(jsonMap));
}

userReadConfigNbcli() {
  File file = File('${createMainFolder()}/user_config.json');
  Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());
  String nbcliPath = jsonMap['nbcli'].toString();
  if (nbcliPath == 'default') {
    return 'nb';
  } else {
    return nbcliPath.replaceAll('\\', '\\\\');
  }
}

setNbcliPath(path) {
  File file = File('${createMainFolder()}/user_config.json');
  Map<String, dynamic> jsonMap = jsonDecode(file.readAsStringSync());
  jsonMap['nbcli'] = path;
  file.writeAsStringSync(jsonEncode(jsonMap));
}

//检查py
Future<String> getpyver() async {
  try {
    if (Platform.isLinux || Platform.isMacOS) {
      ProcessResult results =
          await Process.run('${userReadConfigPython()}', ['--version']);
      return results.stdout.trim();
    } else if (Platform.isWindows) {
      ProcessResult results =
          await Process.run('${userReadConfigPython()}', ['--version']);
      return results.stdout.trim();
    } else {
      return '不支持的平台...';
    }
  } catch (e) {
    return '你似乎还没有安装python？';
  }
}

//检查nbcli
Future<String> getnbcliver() async {
  try {
    final ProcessResult results =
        await Process.run('${userReadConfigNbcli()}', ['-V']);
    return results.stdout;
  } catch (error) {
    return '你似乎还没有安装nb-cli？';
  }
}

//创建bot的配置文件
Future createBotWriteConfig(
    name, path, venv, dep, drivers, adapters, template, plugindir) async {
  String name_ = name.toString();
  String path_ = path.toString();
  String venv_ = venv.toString();
  String dep_ = dep.toString();
  String drivers_ = drivers.toString();
  String adapters_ = adapters.toString();
  String template_ = template.toString();
  String plugindir_ = plugindir.toString();
  File file = File('${createMainFolder()}/cache_config.txt');
  File fileDrivers = File('${createMainFolder()}/cache_drivers.txt');
  File fileAdapters = File('${createMainFolder()}/cache_adapters.txt');
  file.writeAsStringSync('$name_,$path_,$venv_,$dep_,$template_,$plugindir_');
  fileDrivers.writeAsStringSync(drivers_);
  fileAdapters.writeAsStringSync(adapters_);
}

createBotReadConfig() {
  File file = File('${createMainFolder()}/cache_config.txt');
  String args = file.readAsStringSync();
  return args;
}

createBotReadConfigName() {
  File file = File('${createMainFolder()}/cache_config.txt');
  String args = file.readAsStringSync();
  List args_ = args.split(',');
  return args_[0];
}

createBotReadConfigPath() {
  File file = File('${createMainFolder()}/cache_config.txt');
  String args = file.readAsStringSync();
  List args_ = args.split(',');
  return args_[1];
}

createBotReadConfigVENV() {
  File file = File('${createMainFolder()}/cache_config.txt');
  String args = file.readAsStringSync();
  List args_ = args.split(',');
  return args_[2];
}

createBotReadConfigDep() {
  File file = File('${createMainFolder()}/cache_config.txt');
  String args = file.readAsStringSync();
  List args_ = args.split(',');
  return args_[3];
}

createBotReadConfigTemplate() {
  File file = File('${createMainFolder()}/cache_config.txt');
  String args = file.readAsStringSync();
  List args_ = args.split(',');
  return args_[4];
}

createBotReadConfigPluginDir() {
  File file = File('${createMainFolder()}/cache_config.txt');
  String args = file.readAsStringSync();
  List args_ = args.split(',');
  return args_[5];
}

//处理适配器和驱动器
Future<void> createBotWriteConfigRequirement(
    String drivers, String adapters) async {
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
  File file = File('${createMainFolder()}/requirements.txt');
  file.writeAsStringSync('$driverlist\n$adapterlist');
}

//判断平台并使用对应的venv指令
installBot(path, name, venv, dep) {
  if (venv == 'true') {
    if (dep == 'true') {
      if (Platform.isLinux) {
        String installbot =
            '$path/$name/.venv/bin/pip install -r requirements.txt';
        return installbot;
      } else if (Platform.isWindows) {
        String installbot =
            '$path\\$name\\.venv\\Scripts\\pip.exe install -r requirements.txt';
        return installbot;
      } else if (Platform.isMacOS) {
        String installbot =
            '$path/$name/.venv/bin/pip install -r requirements.txt';
        return installbot;
      }
    } else if (dep == 'false') {
      File requirements = File('${createMainFolder()}/requirements.txt');
      requirements.copy(
          '${createBotReadConfigPath()}/${createBotReadConfigName()}/requirements.txt');
      return 'echo 跳过依赖安装，将requirements.txt复制至${createBotReadConfigPath()}/${createBotReadConfigName()}下';
    }
  } else if (venv == 'false') {
    if (dep == 'true') {
      String installbot =
          '${userReadConfigPython()} -m pip install -r requirements.txt';
      return installbot;
    } else if (dep == 'false') {
      File requirements = File('${createMainFolder()}/requirements.txt');
      requirements.copy(
          '${createBotReadConfigPath()}/${createBotReadConfigName()}/requirements.txt');
      return 'echo 跳过依赖安装，将requirements.txt复制至${createBotReadConfigPath()}/${createBotReadConfigName()}下';
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

createVENV(path, name, venv) {
  if (venv == 'true') {
    if (Platform.isLinux || Platform.isMacOS) {
      String createvenv =
          '${userReadConfigPython()} -m venv $path/$name/.venv --prompt $name';
      return createvenv;
    } else if (Platform.isWindows) {
      String createvenv =
          '${userReadConfigPython()} -m venv $path\\$name\\.venv --prompt $name';
      return createvenv;
    }
  } else if (venv == 'false') {
    return 'echo 虚拟环境已关闭，跳过...';
  }
}

createFolder(path, name, plugindir) {
  Directory dir = Directory('$path/$name');
  Directory dirBots = Directory('${createMainFolder()}/bots');
  if (!dir.existsSync()) {
    dir.createSync();
  }
  if (!dirBots.existsSync()) {
    dirBots.createSync();
  }
  if (createBotReadConfigTemplate() == 'simple(插件开发者)') {
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

writeENV(path, name) {
  File file = File('${createMainFolder()}/cache_drivers.txt');
  String drivers = file.readAsStringSync();
  drivers = drivers.toLowerCase();
  String driverlist = drivers.split(',').map((driver) => '~$driver').join('+');
  if (createBotReadConfigTemplate() == 'bootstrap(初学者或用户)') {
    String env = 'DRIVER=$driverlist';
    File fileEnv = File('$path/$name/.env.prod');
    fileEnv.writeAsStringSync(env);
    String echo = "echo 写入.env文件";
    return echo;
  } else if (createBotReadConfigTemplate() == 'simple(插件开发者)') {
    String env = 'ENVIRONMENT=dev\nDRIVER=$driverlist';
    File fileEnv = File('$path/$name/.env');
    fileEnv.writeAsStringSync(env);
    File fileEnvdev = File('$path/$name/.env.dev');
    fileEnvdev.writeAsStringSync('LOG_LEVEL=DEBUG');
    File fileEnvprod = File('$path/$name/.env.prod');
    fileEnvprod.createSync();
    String echo = "echo 写入.env文件";
    return echo;
  }
}

writePyProject(path, name) {
  File file = File('${createMainFolder()}/cache_adapters.txt');
  String adapters = file.readAsStringSync();

  RegExp regex = RegExp(r'\(([^)]+)\)');
  Iterable<Match> matches = regex.allMatches(adapters);
  String adapterlist = '';
  for (Match match in matches) {
    adapterlist += '${match.group(1)},';
  }
  String adapterlist_ = adapterlist
      .split(',')
      .map((adapter) =>
          '{ name = "${adapter.replaceAll('nonebot-adapter-', '').replaceAll('.', ' ')}", module_name = "${adapter.replaceAll('-', '.').replaceAll('adapter', 'adapters')}" }')
      .join(',');

  if (createBotReadConfigTemplate() == 'bootstrap(初学者或用户)') {
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
  } else if (createBotReadConfigTemplate() == 'simple(插件开发者)') {
    if (createBotReadConfigPluginDir() == '在src文件夹下') {
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
    } else if (createBotReadConfigPluginDir() == '在[bot名称]/[bot名称]下') {
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

writebot(name, path) {
  DateTime now = DateTime.now();
  String time =
      "${now.year}年${now.month}月${now.day}日${now.hour}时${now.minute}分${now.second}秒";
  File cfgFile = File('${createMainFolder()}/bots/$name.$time.json');

  if (Platform.isWindows) {
    String botInfo = '''
{
  "name": "$name",
  "path": "${path.replaceAll('\\', '\\\\')}\\\\$name",
  "time": "$time",
  "isrunning": "false",
  "pid": "Null"
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
  "pid": "Null"
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
  "pid": "Null"
}
''';
    cfgFile.writeAsStringSync(botInfo);
    String echo = "echo 写入json";
    return echo;
  }
}

//导入
importbot(name, path) {
  DateTime now = DateTime.now();
  String time =
      "${now.year}年${now.month}月${now.day}日${now.hour}时${now.minute}分${now.second}秒";
  File cfgFile = File('${createMainFolder()}/bots/$name.$time.json');

  if (Platform.isWindows) {
    String botInfo = '''
{
  "name": "$name",
  "path": "${path.replaceAll('\\', '\\\\')}",
  "time": "$time",
  "isrunning": "false",
  "pid": "Null"
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
  "pid": "Null"
}
''';
    cfgFile.writeAsStringSync(botInfo);
    String echo = "echo 写入json";
    return echo;
  }
}

//管理bot的函数
Future manageBotOnOpenCfg(name, time) async {
  String onOpen = '$name.$time';
  File onOpenFile = File('${createMainFolder()}/on_open.txt');
  onOpenFile.writeAsStringSync(onOpen);
}

manageBotReadCfgName() {
  File cfgFile = File('${createMainFolder()}/on_open.txt');
  String cfg = cfgFile.readAsStringSync();
  File botcfg = File('${createMainFolder()}/bots/$cfg.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['name'].toString();
}

manageBotReadCfgPath() {
  File cfgFile = File('${createMainFolder()}/on_open.txt');
  String cfg = cfgFile.readAsStringSync();
  File botcfg = File('${createMainFolder()}/bots/$cfg.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['path'].toString();
}

manageBotReadCfgTime() {
  File cfgFile = File('${createMainFolder()}/on_open.txt');
  String cfg = cfgFile.readAsStringSync();
  File botcfg = File('${createMainFolder()}/bots/$cfg.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['time'].toString();
}

manageBotReadCfgStatus() {
  File cfgFile = File('${createMainFolder()}/on_open.txt');
  String cfg = cfgFile.readAsStringSync();
  File botcfg = File('${createMainFolder()}/bots/$cfg.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['isrunning'].toString();
}

manageBotReadCfgPid() {
  File cfgFile = File('${createMainFolder()}/on_open.txt');
  String cfg = cfgFile.readAsStringSync();
  File botcfg = File('${createMainFolder()}/bots/$cfg.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['pid'].toString();
}

manageBotViewStderr() {
  File stderrfile = File('${manageBotReadCfgPath()}/nbgui_stderr.log');
  String stderr = stderrfile.readAsStringSync();
  return stderr;
}

deleteStderr() {
  File stderrfile = File('${manageBotReadCfgPath()}/nbgui_stderr.log');
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

//唤起Bot进程
Future runBot(path) async {
  String name = manageBotReadCfgName();
  String time = manageBotReadCfgTime();
  Directory.current = Directory(path);
  File cfgFile = File('${createMainFolder()}/bots/$name.$time.json');
  final stdout = File('$path/nbgui_stdout.log');
  final stderr = File('$path/nbgui_stderr.log');
  Process process = await Process.start('${userReadConfigNbcli()}', ['run'],
      workingDirectory: path);
  int pid = process.pid;
  //重写配置文件来更新状态
  Map<String, dynamic> jsonMap = jsonDecode(cfgFile.readAsStringSync());
  jsonMap['pid'] = pid;
  jsonMap['isrunning'] = 'true';
  cfgFile.writeAsStringSync(jsonEncode(jsonMap));

  final outputSink = stdout.openWrite();
  final errorSink = stderr.openWrite();

  process.stdout.transform(systemEncoding.decoder).listen((data) {
    outputSink.write(data);
  });

  process.stderr.transform(systemEncoding.decoder).listen((data) {
    errorSink.write(data);
  });
}

//结束bot进程
Future stopBot() async {
  //读取配置文件
  String name = manageBotReadCfgName();
  String time = manageBotReadCfgTime();
  File cfgFile = File('${createMainFolder()}/bots/$name.$time.json');
  Map botInfo = json.decode(cfgFile.readAsStringSync());
  String pidString = botInfo['pid'].toString();
  int pid = int.parse(pidString);
  Process.killPid(pid);
  //更新配置文件
  botInfo['isrunning'] = 'false';
  botInfo['pid'] = 'Null';
  cfgFile.writeAsStringSync(json.encode(botInfo));
}

//删除bot
Future deleteBot() async {
  String name = manageBotReadCfgName();
  String time = manageBotReadCfgTime();
  File cfgFile = File('${createMainFolder()}/bots/$name.$time.json');
  cfgFile.delete();
}

Future deleteBotAll() async {
  String name = manageBotReadCfgName();
  String time = manageBotReadCfgTime();
  File cfgFile = File('${createMainFolder()}/bots/$name.$time.json');
  String path = manageBotReadCfgPath();
  Directory(path).delete(recursive: true);
  cfgFile.delete();
}

clearLog() async {
  String path = manageBotReadCfgPath();
  File stdout = File('$path/nbgui_stdout.log');
  stdout.delete();
  String info = "[I]Welcome to Nonebot GUI!\n";
  stdout.writeAsString(info);
}

manageCliPlugin(manage, pluginName) {
  if (manage == 'install') {
    String cmd = '${userReadConfigNbcli()} plugin install $pluginName';
    return cmd;
  }
  if (manage == 'uninstall') {
    String cmd = '${userReadConfigNbcli()} plugin uninstall $pluginName -y';
    return cmd;
  }
}

manageCliAdapter(manage, adapterName) {
  if (manage == 'install') {
    String cmd = '${userReadConfigNbcli()} adapter install $adapterName';
    return cmd;
  }
  if (manage == 'uninstall') {
    String cmd = '${userReadConfigNbcli()} adapter uninstall $adapterName -y';
    return cmd;
  }
}

manageCliDriver(manage, driverName) {
  if (manage == 'install') {
    String cmd = '${userReadConfigNbcli()} driver install $driverName';
    return cmd;
  }
  if (manage == 'uninstall') {
    String cmd = '${userReadConfigNbcli()} driver uninstall $driverName -y';
    return cmd;
  }
}

manageCliSelf(manage, packageName) {
  if (manage == 'install') {
    String cmd = '${userReadConfigNbcli()} self install $packageName';
    return cmd;
  }
  if (manage == 'uninstall') {
    String cmd = '${userReadConfigNbcli()} self uninstall $packageName -y';
    return cmd;
  }
  if (manage == 'update') {
    String cmd = '${userReadConfigNbcli()} self update';
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

//从pyproject.toml中读取插件列表
getPluginList() {
  File pyprojectFile = File('${manageBotReadCfgPath()}/pyproject.toml');
  String pyproject = pyprojectFile.readAsStringSync();
  var toml = TomlDocument.parse(pyproject).toMap();
  var nonebot = toml['tool']['nonebot'];
  List pluginsList = nonebot['plugins'];
  return pluginsList;
}
