import 'dart:convert';
import 'dart:io';
import 'dart:core';
import 'package:NoneBotGUI/utils/manage.dart';
import 'package:NoneBotGUI/utils/userConfig.dart';
import 'package:path_provider/path_provider.dart';
import 'package:NoneBotGUI/utils/global.dart';
import 'package:toml/toml.dart';
import 'package:path/path.dart' as path;

///初始化nbgui
nbguiInit() async {
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
    "httpencoding": "utf8",
    "botEncoding": "systemEncoding",
    "protocolEncoding": "utf8",
    "deployEncoding": "systemEncoding",
    "mirror": "https://registry.nonebot.dev",
    "refreshMode": "auto"
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

///检查py
Future<String> getPyVer() async {
  try {
    ProcessResult results =
        await Process.run('${UserConfig.pythonPath()}', ['--version']);
    return results.stdout.trim();
  } catch (e) {
    return '你似乎还没有安装python？';
  }
}

///检查nbcli
Future<String> getnbcliver() async {
  try {
    final ProcessResult results =
        await Process.run('${UserConfig.nbcliPath()}', ['-V']);
    return results.stdout;
  } catch (error) {
    return '你似乎还没有安装nb-cli？';
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

///清除日志
clearLog(path) async {
    File stdout = File('$path/nbgui_stdout.log');
    stdout.delete();
    String info = "[INFO]Welcome to Nonebot GUI!";
    stdout.writeAsString(info);
}


///从pyproject.toml中读取插件列表
getPluginList() {
  File pyprojectFile = File('${Bot.path()}/pyproject.toml');
  String pyproject = pyprojectFile.readAsStringSync();
  var toml = TomlDocument.parse(pyproject).toMap();
  var nonebot = toml['tool']['nonebot'];
  List pluginsList = nonebot['plugins'];
  return pluginsList;
}



///获取协议端文件名
getProtocolFileName(){
  String ucmd = FastDeploy.cmd.replaceAll('./', '').replaceAll('.\\', '');
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
  FastDeploy.protocolFileName = pcmd;
}

//获取extDir
Future<String?> getExtDir(String fileName, String searchDirectory) async {
  Directory dir = Directory(searchDirectory);

  if (await dir.exists()) {
    List<FileSystemEntity> entities = dir.listSync(recursive: true);
    for (FileSystemEntity entity in entities) {
      if (entity is File && path.basename(entity.path) == fileName) {
        String normalizedPath = path.normalize(path.dirname(entity.absolute.path));
        String escapedPath = normalizedPath.replaceAll(r'\', r'\\');
        return escapedPath;
      }
    }
  } else {
    print('Directory does not exist: $searchDirectory');
  }
  return null;
}

///打开文件夹
Future openFolder(path) async {
  if (Platform.isWindows) {
    await Process.run('explorer', [path]);
  } else if (Platform.isLinux) {
    await Process.run('xdg-open', [path]);
  } else if (Platform.isMacOS) {
    await Process.run('open', [path]);
  }
}

///清除stderr
deleteStderr(dir) {
  File stderrfile = File('$dir/nbgui_stderr.log');
  String clear = "";
  stderrfile.writeAsString(clear);
}


///检查bot的type键
//适配老东西（
checkBotType(){
  File botcfg = File('$userDir/bots/${MainApp.gOnOpen}.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  if (jsonMap.containsKey('type')){
    return (jsonMap['type'] == 'deployed') ? true : false;
  }
  else {
    return false;
  }
}

///设置快速部署的路径
setDeployPath(path, name){
  if (Platform.isWindows){
    FastDeploy.path = '${path.toString().replaceAll('\\', '\\\\')}\\\\$name';
  }
  else if (Platform.isLinux || Platform.isMacOS){
    FastDeploy.path = '$path/$name';
  }
}