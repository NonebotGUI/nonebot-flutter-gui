import 'dart:async';
import 'dart:io';
import 'dart:core';
import 'dart:convert';

import 'package:flutter/material.dart';




//存放一些小功能的地方
create_main_folder(){
  if (Platform.isWindows){
    Directory dir = Directory('${Platform.environment['USERPROFILE']!}/.nbgui');
    if (!dir.existsSync()){
      dir.createSync();
    }
    Directory.current = dir;
    return dir.toString().replaceAll("Directory: ", '').replaceAll("'", '');
  }
  else if (Platform.isLinux){
    Directory dir = Directory('${Platform.environment['HOME']!}/.nbgui');
    if (!dir.existsSync()){
      dir.createSync();
    }
    Directory.current = dir;
    return dir.toString().replaceAll("Directory: ", '').replaceAll("'", '');
  }
  else if (Platform.isMacOS){
    Directory dir = Directory('${Platform.environment['HOME']!}/.nbgui');
    if (!dir.existsSync()){
      dir.createSync();
    }
    Directory.current = dir;
    return dir.toString().replaceAll("Directory: ", '').replaceAll("'", '');
  }
}



//检查py
Future<String> getpyver() async {
  try {
    final ProcessResult results = await Process.run('python3', ['--version']);
    return results.stdout;
  } catch (error) {
    return '你似乎还没有安装Python？';
  }
}

//检查nbcli
Future<String> getnbcliver() async {
  try {
    final ProcessResult results = await Process.run('nb', ['-V']);
    return results.stdout;
  } catch (error) {
    return '你似乎还没有安装nb-cli？';
  }
}

//创建bot的配置文件
Future creatbot_writeconfig(name,path,venv,dep,drivers,adapters) async{
  String name_ = name.toString();
  String path_ = path.toString();
  String venv_ = venv.toString();
  String dep_ = dep.toString();
  String drivers_ = drivers.toString();
  String adapters_ = adapters.toString();
  File file = File('${create_main_folder()}/cache_config.txt');
  File file_drivers = File('${create_main_folder()}/cache_drivers.txt');
  File file_adapters = File('${create_main_folder()}/cache_adapters.txt');
  file.writeAsStringSync('${name_},${path_},${venv_},${dep_}');
  file_drivers.writeAsStringSync(drivers_);
  file_adapters.writeAsStringSync(adapters_);
}


createbot_readconfig() {
  File file = File('${create_main_folder()}/cache_config.txt');
  String args = file.readAsStringSync();
  return args; 
}

createbot_readconfig_name() {
  File file = File('${create_main_folder()}/cache_config.txt');
  String args = file.readAsStringSync();  
  List args_ = args.split(',');
  return args_[0];
}


createbot_readconfig_path() {
  File file = File('${create_main_folder()}/cache_config.txt');
  String args = file.readAsStringSync();  
  List args_ = args.split(',');
  return args_[1];
}

createbot_readconfig_venv() {
  File file = File('${create_main_folder()}/cache_config.txt');
  String args = file.readAsStringSync();  
  List args_ = args.split(',');   
  return args_[2];
}

createbot_readconfig_dep() {
  File file = File('${create_main_folder()}/cache_config.txt');
  String args = file.readAsStringSync();    
  List args_ = args.split(',');   
  return args_[3];
}

//处理适配器和驱动器
Future<void> createbot_writeconfig_requirement(String drivers, String adapters) async {
  drivers = drivers.toLowerCase();
  String driverlist = drivers.split(',')
    .map((driver) => 'nonebot2[$driver]')
    .join(',');
  driverlist = driverlist.replaceAll(',', '\n');

  RegExp regex = RegExp(r'\(([^)]+)\)');
  Iterable<Match> matches = regex.allMatches(adapters);
  String adapterlist = '';
  for (Match match in matches) {
    adapterlist += '${match.group(1)}\n';
  }
  //处理OB V11与OB V12
  adapterlist = adapterlist.replaceAll('nonebot-adapter-onebot.v11','nonebot-adapter-onebot').replaceAll('nonebot-adapter-onebot.v12','nonebot-adapter-onebot');
  File file = File('${create_main_folder()}/requirements.txt');
  file.writeAsStringSync('${driverlist}\n${adapterlist}');
}

//判断平台并使用对应的venv指令
installbot(path,name){
  if (Platform.isLinux){
    String installbot = '${path}/${name}/.venv/bin/pip install -r requirements.txt';
    return installbot;
  } else if (Platform.isWindows){
    String installbot = '${path}\\${name}\.venv\\Scripts\\pip install -r requirements.txt';
    return installbot;
  } else if (Platform.isMacOS){
    String installbot = '${path}/${name}/.venv/bin/pip install -r requirements.txt';
    return installbot;
  }
}

createvenv(path,name){
  if (Platform.isLinux){
    String createvenv = 'python3 -m venv ${path}/${name}/.venv';
    return createvenv;
  } else if (Platform.isWindows){
    String createvenv = 'python -m venv ${path}\\${name}\\.venv';
    return createvenv;
  } else if (Platform.isMacOS){
    String createvenv = 'python3 -m venv ${path}/${name}/.venv';
    return createvenv;
  }
}

createfolder(path,name){
  Directory dir = Directory('${path}/${name}');
  Directory dir_src = Directory('${path}/${name}/src');
  Directory dir_src_plugins = Directory('${path}/${name}/src/plugins');
  Directory dir_bots = Directory('${create_main_folder()}/bots');
  if (!dir.existsSync()){
    dir.createSync();
  }
  if (!dir_src.existsSync()){
    dir_src.createSync();
  }
  if (!dir_src_plugins.existsSync()){
    dir_src_plugins.createSync();
  }
  if (!dir_bots.existsSync()){
    dir_bots.createSync();
  }
}



writeenv(path,name){
  File file = File('${create_main_folder()}/cache_drivers.txt');
  String drivers = file.readAsStringSync();   
  drivers = drivers.toLowerCase();
  String driverlist = drivers.split(',')
    .map((driver) => '~${driver}')
    .join('+');
  String env = 'ENVIRONMENT=dev\nDRIVER=${driverlist}';
  File file_drivers = File('${path}/${name}/.env');
  file_drivers.writeAsStringSync(env);
  String echo = "echo 写入.env文件";
  return echo;
}

writepyproject(path,name){
  File file = File('${create_main_folder()}/cache_adapters.txt');
  String adapters = file.readAsStringSync();  

  RegExp regex = RegExp(r'\(([^)]+)\)');
  Iterable<Match> matches = regex.allMatches(adapters);
  String adapterlist = '';
  for (Match match in matches) {
    adapterlist += '${match.group(1)},';
  }
  String adapterlist_ = adapterlist.split(',')
    .map((adapter) => '{ name = "${adapter.replaceAll('nonebot-adapter-','').replaceAll('.', ' ')}", module_name = "${adapter.replaceAll('-', '.').replaceAll('adapter', 'adapters')}" }')
    .join(',');  

  String pyproject = '[tool.poetry]\nname = "${name}"\nversion = "0.1.0"\ndescription = "${name}"\n\n[tool.poetry.dependencies]\npython = ">=3.8,<4.0"\n\n[tool.nonebot]\nadapters = [${adapterlist_}]\nplugins = []\nplugin_dirs = ["src/plugins"]\nbuiltin_plugins = ["echo"]';
  File file_pyproject = File('${path}/${name}/pyproject.toml');
  file_pyproject.writeAsStringSync(pyproject.replaceAll(',{ name = "", module_name = "" }', ''.replaceAll('adapter', 'adapters')));
  String echo = "echo 写入pyproject.toml";
  return echo;
}

writebot(name,path){
  DateTime now = DateTime.now();
  String time = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}";
  File cfgfile = File('${create_main_folder()}/bots/${name}.${time}.json');
  String bot_info = '''
{
  "name": "${name}",
  "path": "${path}/${name}",
  "time": "${time}",
  "isrunning": "false"
}
''';
cfgfile.writeAsStringSync(bot_info);
String echo = "echo 写入json";
return echo;
}



//管理bot的函数
Future manage_bot_onopencfg(name,time) async{
  String on_open = '${name}.${time}';
  File on_open_file = File('${create_main_folder()}/on_open.txt');
  on_open_file.writeAsStringSync(on_open);
}

manage_bot_readcfg_name(){
  File cfgfile = File('${create_main_folder()}/on_open.txt');
  String cfg = cfgfile.readAsStringSync();
  File botcfg = File('${create_main_folder()}/bots/${cfg}.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['name'].toString();
}

manage_bot_readcfg_path(){
  File cfgfile = File('${create_main_folder()}/on_open.txt');
  String cfg = cfgfile.readAsStringSync();
  File botcfg = File('${create_main_folder()}/bots/${cfg}.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['path'].toString();
}

manage_bot_readcfg_time(){
  File cfgfile = File('${create_main_folder()}/on_open.txt');
  String cfg = cfgfile.readAsStringSync();
  File botcfg = File('${create_main_folder()}/bots/${cfg}.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['time'].toString();
}

manage_bot_readcfg_status(){
  File cfgfile = File('${create_main_folder()}/on_open.txt');
  String cfg = cfgfile.readAsStringSync();
  File botcfg = File('${create_main_folder()}/bots/${cfg}.json');
  Map<String, dynamic> jsonMap = jsonDecode(botcfg.readAsStringSync());
  return jsonMap['isrunning'].toString();
}


Future openfolder(path) async{
  if(Platform.isWindows){
    await Process.run('explorer', [path]);
  }
  else if(Platform.isLinux){
    await Process.run('xdg-open', [path]);
  }
  else if(Platform.isMacOS){
    await Process.run('open', [path]);
  }
}