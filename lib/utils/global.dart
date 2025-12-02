//全局变量
//用户目录
late final userDir;

///当前打开的Bot
String gOnOpen = '';

class MainApp {
  ///log
  static late String nbLog;

  ///协议端日志
  static late String protocolLog;

  ///版本号
  static late String version;

  static late int broadcastId;

  ///部署id
  static late int deployId;

  ///侧边栏是否展开
  static late bool barExtended;

  ///Bot列表
  static List botList = [];
}

///创建Bot相关
class Create {
  ///Bot名称
  static late String name;

  ///Bot路径
  static late String? path;

  ///是否启用虚拟环境
  static late bool venv;

  ///是否立刻安装依赖
  static late bool installDep;

  ///适配器
  static late String adapter;

  ///驱动器
  static late String driver;

  ///模板
  static late String template;

  ///插件存放位置
  static late String pluginDir;
}

///Bot.time列表
List<String> botList = [];
