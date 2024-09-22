import 'dart:convert';
import 'dart:io';
import 'package:NoneBotGUI/utils/global.dart';

/// 用户配置文件
class UserConfig {
  static final File _configFile = File('$userDir/user_config.json');

  /// 初始化用户配置文件
  static Map<String, dynamic> _config() {
    File file = File('$userDir/user_config.json');
    String content = file.readAsStringSync();
    return jsonDecode(content);
  }

  /// 获取用户主题色
  static String colorMode() {
    Map<String, dynamic> jsonMap = _config();
    if (jsonMap.containsKey("color")) {
      String colorMode = jsonMap['color'].toString();
      return colorMode;
    } else {
      setColorMode('light');
      return 'light';
    }
  }

  /// 设置用户主题色
  static void setColorMode(mode) {
    Map<String, dynamic> jsonMap = _config();
    jsonMap['color'] = mode;
    _configFile.writeAsStringSync(jsonEncode(jsonMap));
  }

  /// 获取用户刷新策略
  static String refreshMode() {
    Map<String, dynamic> jsonMap = _config();
    if (jsonMap.containsKey("refreshMode")) {
      String refreshMode = jsonMap['refreshMode'].toString();
      return refreshMode;
    } else {
      setRefreshMode('auto');
      return 'auto';
    }
  }

  /// 设置用户刷新策略
  static void setRefreshMode(mode) {
    Map<String, dynamic> jsonMap = _config();
    jsonMap['refreshMode'] = mode;
    _configFile.writeAsStringSync(jsonEncode(jsonMap));
  }

  /// 获取用户编码
  static dynamic encoding() {
    Map<String, dynamic> jsonMap = _config();
    if (jsonMap.containsKey("encoding")) {
      String encoding = jsonMap['encoding'].toString();
      return (encoding == 'utf8') ? utf8 : systemEncoding;
    } else {
      setEncoding('systemEncoding');
      return systemEncoding;
    }
  }

  /// 设置用户编码
  static void setEncoding(encoding) {
    Map<String, dynamic> jsonMap = _config();
    jsonMap['encoding'] = encoding;
    _configFile.writeAsStringSync(jsonEncode(jsonMap));
  }

  /// 获取用户HTTP编码
  static dynamic httpEncoding() {
    Map<String, dynamic> jsonMap = _config();
    if (jsonMap.containsKey("httpencoding")) {
      String httpEncoding = jsonMap['httpencoding'].toString();
      return (httpEncoding == 'utf8') ? utf8 : systemEncoding;
    } else {
      setHttpEncoding('utf8');
      return utf8;
    }
  }

  /// 设置用户HTTP编码
  static void setHttpEncoding(encoding) {
    Map<String, dynamic> jsonMap = _config();
    jsonMap['httpencoding'] = encoding;
    _configFile.writeAsStringSync(jsonEncode(jsonMap));
  }

  /// 获取用户Bot控制台编码
  static dynamic botEncoding() {
    Map<String, dynamic> jsonMap = _config();
    if (jsonMap.containsKey("botEncoding")) {
      String botEncoding = jsonMap['botEncoding'].toString();
      return (botEncoding == 'utf8') ? utf8 : systemEncoding;
    } else {
      setBotEncoding('systemEncoding');
      return systemEncoding;
    }
  }

  /// 设置用户Bot控制台编码
  static void setBotEncoding(encoding) {
    Map<String, dynamic> jsonMap = _config();
    jsonMap['botEncoding'] = encoding;
    _configFile.writeAsStringSync(jsonEncode(jsonMap));
  }

  /// 获取用户协议端编码
  static dynamic protocolEncoding() {
    Map<String, dynamic> jsonMap = _config();
    if (jsonMap.containsKey("protocolEncoding")) {
      String protocolEncoding = jsonMap['protocolEncoding'].toString();
      return (protocolEncoding == 'utf8') ? utf8 : systemEncoding;
    } else {
      setProtocolEncoding('utf8');
      return utf8;
    }
  }

  /// 设置用户协议端编码
  static void setProtocolEncoding(encoding) {
    Map<String, dynamic> jsonMap = _config();
    jsonMap['protocolEncoding'] = encoding;
    _configFile.writeAsStringSync(jsonEncode(jsonMap));
  }

  /// 获取用户部署控制台编码
  static dynamic deployEncoding() {
    Map<String, dynamic> jsonMap = _config();
    if (jsonMap.containsKey("deployEncoding")) {
      String deployEncoding = jsonMap['deployEncoding'].toString();
      return (deployEncoding == 'utf8') ? utf8 : systemEncoding;
    } else {
      setDeployEncoding('systemEncoding');
      return systemEncoding;
    }
  }

  /// 设置用户部署控制台编码
  static void setDeployEncoding(encoding) {
    Map<String, dynamic> jsonMap = _config();
    jsonMap['deployEncoding'] = encoding;
    _configFile.writeAsStringSync(jsonEncode(jsonMap));
  }

  /// 获取镜像源
  static String mirror() {
    Map<String, dynamic> jsonMap = _config();
    if (jsonMap.containsKey("mirror")) {
      String mirror = jsonMap['mirror'].toString();
      return mirror;
    } else {
      setMirror('https://registry.nonebot.dev');
      return 'https://registry.nonebot.dev';
    }
  }

  /// 设置镜像源
  static void setMirror(mirror) {
    Map<String, dynamic> jsonMap = _config();
    jsonMap['mirror'] = mirror;
    _configFile.writeAsStringSync(jsonEncode(jsonMap));
  }

  /// 是否自动检查更新
  static bool checkUpdate() {
    Map<String, dynamic> jsonMap = _config();
    if (jsonMap.containsKey("checkUpdate")) {
      bool checkUpdate = jsonMap['checkUpdate'];
      return checkUpdate;
    } else {
      setCheckUpdate(true);
      return true;
    }
  }

  /// 设置是否自动检查更新
  static void setCheckUpdate(checkUpdate) {
    Map<String, dynamic> jsonMap = _config();
    jsonMap['checkUpdate'] = checkUpdate;
    _configFile.writeAsStringSync(jsonEncode(jsonMap));
  }

  /// Python路径
  static dynamic pythonPath() {
    Map<String, dynamic> jsonMap = _config();
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

  /// 设置Python路径
  static void setPythonPath(pythonPath) {
    Map<String, dynamic> jsonMap = _config();
    jsonMap['python'] = pythonPath;
    _configFile.writeAsStringSync(jsonEncode(jsonMap));
  }

  /// NoneBot-CLI路径
  static dynamic nbcliPath() {
    Map<String, dynamic> jsonMap = _config();
    String nbcliPath = jsonMap['nbcli'].toString();
    if (nbcliPath == 'default') {
      return 'nb';
    } else {
      return nbcliPath.replaceAll('\\', '\\\\');
    }
  }

  /// 设置NoneBot-CLI路径
  static void setNbcliPath(nbcliPath) {
    Map<String, dynamic> jsonMap = _config();
    jsonMap['nbcli'] = nbcliPath;
    _configFile.writeAsStringSync(jsonEncode(jsonMap));
  }
}
