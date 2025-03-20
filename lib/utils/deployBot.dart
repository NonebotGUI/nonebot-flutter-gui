import 'dart:io';

import 'package:NoneBotGUI/utils/global.dart';
import 'package:NoneBotGUI/utils/userConfig.dart';

///部署Bot时的相关操作
class DeployBot {
  ///写入requirements.txt
  static writeReq(path, name, driver, adapter) {
    String drivers = driver.toLowerCase();
    String driverlist =
        drivers.split(',').map((driver) => 'nonebot2[$driver]').join(',');
    driverlist = driverlist.replaceAll(',', '\n');

    RegExp regex = RegExp(r'\(([^)]+)\)');
    Iterable<Match> matches = regex.allMatches(adapter);
    String adapterlist = '';
    for (Match match in matches) {
      adapterlist += '${match.group(1)}\n';
    }
    //处理OB V11与OB V12
    adapterlist = adapterlist
        .replaceAll('nonebot-adapter-onebot.v11', 'nonebot-adapter-onebot')
        .replaceAll('nonebot-adapter-onebot.v12', 'nonebot-adapter-onebot');
    File file = File('$userDir/requirements.txt');
    file.writeAsStringSync('$driverlist\n$adapterlist');
  }

  ///安装依赖
  static install(path, name, bool venv, bool installDep) {
    if (venv) {
      if (installDep) {
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
              '$path/$name/.venv/bin/pip install -r $userDir/requirements.txt';
          return installbot;
        }
      } else if (installDep) {
        File requirements = File('$userDir/requirements.txt');
        requirements.copy('$path/$name/requirements.txt');
        return 'echo 跳过依赖安装，将requirements.txt复制至$path/$name下';
      }
    } else if (venv) {
      if (installDep) {
        String installbot =
            '${UserConfig.pythonPath()} -m pip install -r requirements.txt';
        return installbot;
      } else if (installDep) {
        File requirements = File('$userDir/requirements.txt');
        requirements.copy('$path/$name/requirements.txt');
        return 'echo 跳过依赖安装，将requirements.txt复制至$path/$name下';
      }
    }
  }

  ///创建虚拟环境
  static createVENV(path, name, bool venv) {
    if (venv) {
      if (Platform.isLinux || Platform.isMacOS) {
        String createvenv =
            '${UserConfig.pythonPath()} -m venv $path/$name/.venv --prompt $name';
        return createvenv;
      } else if (Platform.isWindows) {
        String createvenv =
            '${UserConfig.pythonPath()} -m venv $path\\$name\\.venv --prompt $name';
        return createvenv;
      }
    } else {
      return 'echo 虚拟环境已关闭，跳过...';
    }
  }

  static createVENVEcho(path, name) {
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

  ///创建目录
  static createFolder(path, name, template, pluginDir) {
    Directory dir = Directory('$path/$name');
    Directory dirBots = Directory('$userDir/bots');
    if (!dir.existsSync()) {
      dir.createSync();
    }
    if (!dirBots.existsSync()) {
      dirBots.createSync();
    }
    if (template == 'simple(插件开发者)') {
      if (pluginDir == '在[bot名称]/[bot名称]下') {
        Directory dirSrc = Directory('$path/$name/$name');
        Directory dirSrcPlugins = Directory('$path/$name/$name/plugins');
        if (!dirSrc.existsSync()) {
          dirSrc.createSync();
        }
        if (!dirSrcPlugins.existsSync()) {
          dirSrcPlugins.createSync();
        }
      } else if (pluginDir == '在src文件夹下') {
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

  ///写入.env文件
  static writeENV(path, name, port, template, drivers) {
    drivers = drivers.toLowerCase();
    String driverlist =
        drivers.split(',').map((driver) => '~$driver').join('+');
    if (template == 'bootstrap(初学者或用户)') {
      String env = port.toString().isEmpty
          ? 'DRIVER=$driverlist'
          : 'DRIVER=$driverlist\n\n\n\n\nPORT=$port';
      File fileEnv = File('$path/$name/.env.prod');
      fileEnv.writeAsStringSync(env);
      String echo = "echo 写入.env文件";
      return echo;
    } else if (template == 'simple(插件开发者)') {
      String env = 'ENVIRONMENT=dev\nDRIVER=$driverlist';
      File fileEnv = File('$path/$name/.env');
      fileEnv.writeAsStringSync(env);
      File fileEnvdev = File('$path/$name/.env.dev');
      String devEnv = port.toString().isNotEmpty
          ? 'LOG_LEVEL=DEBUG'
          : 'LOG_LEVEL=DEBUG\n\n\n\n\nPORT=$port';
      fileEnvdev.writeAsStringSync(devEnv);
      File fileEnvprod = File('$path/$name/.env.prod');
      fileEnvprod.createSync();
      String echo = "echo 写入.env文件";
      return echo;
    }
  }

  ///写入pyproject.toml
  static writePyProject(path, name, adapters, template, pluginDir) {
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

    if (template == 'bootstrap(初学者或用户)') {
      String pyproject = '''
    [project]
    name = "$name"
    version = "0.1.0"
    description = "$name"
    readme = "README.md"
    requires-python = ">=3.9, <4.0"

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
    } else if (template == 'simple(插件开发者)') {
      String dir = pluginDir == '在[bot名称]/[bot名称]下'
          ? '"$name/plugins"'
          : '"src/plugins"';
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
    plugin_dirs = [$dir]
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

  ///写入Bot的json文件
  static writebot(name, path, type, protocolPath, cmd) {
    DateTime now = DateTime.now();
    String time =
        "${now.year}年${now.month}月${now.day}日${now.hour}时${now.minute}分${now.second}秒";
    File cfgFile = File('$userDir/bots/$name.$time.json');

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
}

///协议端部署相关操作
class DeployProtocol {
  ///设置协议端的cmd
  static setCmd(jsonMap) {
    if (Platform.isWindows) {
      FastDeploy.cmd = jsonMap['cmdWin'];
      if (FastDeploy.needQQ) {
        FastDeploy.cmd =
            FastDeploy.cmd.replaceAll('NBGUI.QQNUM', FastDeploy.botQQ);
      }
    } else if (Platform.isLinux || Platform.isMacOS) {
      FastDeploy.cmd = jsonMap['cmd'];
      if (FastDeploy.needQQ) {
        FastDeploy.cmd =
            FastDeploy.cmd.replaceAll('NBGUI.QQNUM', FastDeploy.botQQ);
      }
    }
  }

  ///写入协议端配置文件
  static Future<void> writeConfig() async {
    if (FastDeploy.extDir.isEmpty) {
      print('extDir is null');
      return;
    }

    // 配置文件绝对路径
    String path = '${FastDeploy.extDir}/${FastDeploy.configPath}';
    File pcfg = File(FastDeploy.needQQ
        ? path.replaceAll('NBGUI.QQNUM', FastDeploy.botQQ)
        : path);

    // 将wsPort转为int类型
    String content = FastDeploy.botConfig
        .toString()
        .replaceAll('NBGUI.HOST:NBGUI.PORT',
            "${FastDeploy.wsHost}:${FastDeploy.wsPort}")
        .replaceAll('"NBGUI.PORT"', FastDeploy.wsPort)
        .replaceAll('NBGUI.HOST', FastDeploy.wsHost);

    await pcfg.writeAsString(content);

    if (Platform.isLinux || Platform.isMacOS) {
      // 给予执行权限
      await Process.run('chmod', ['+x', FastDeploy.cmd],
          workingDirectory: FastDeploy.extDir, runInShell: true);
    }
  }

  ///写入requirements.txt和pyproject.toml
  static writeReq(name, adapter, drivers) {
    drivers = drivers.toLowerCase();
    String driverlist =
        drivers.split(',').map((driver) => 'nonebot2[$driver]').join(',');
    driverlist = driverlist.replaceAll(',', '\n');
    String reqs = "$driverlist\n$adapter";
    File('$userDir/requirements.txt').writeAsStringSync(reqs);
    if (FastDeploy.template == 'bootstrap(初学者或用户)') {
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
      File('${FastDeploy.path}/pyproject.toml').writeAsStringSync(pyproject);
    } else if (FastDeploy.template == 'simple(插件开发者)') {
      if (FastDeploy.pluginDir == '在src文件夹下') {
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
        File('${FastDeploy.path}/pyproject.toml').writeAsStringSync(pyproject);
      } else {
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
        File('${FastDeploy.path}/pyproject.toml').writeAsStringSync(pyproject);
      }
    }
    return 'echo 写入依赖...';
  }
}
