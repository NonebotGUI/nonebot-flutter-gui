//全局变量

//用户目录

late final userDir;

//log
late String nbLog;

//协议端日志
late String protocolLog;

//版本号
late String version;

//当前打开的Bot
String gOnOpen = '';


//以下全局变量全都是由于不会传参导致的（byd全局变量太好用了
//主页面
//公告id
late int broadcastId;

//部署id
late int deployId;

//侧边栏是否展开
late bool barExtended;



//快速部署相关
//快速部署页面
late int deployPage;

//下载连接
late List<String> dlLink;

//部署时是否启用虚拟环境
late bool deployVenv;

//部署路径
late String deployPath;

//选择的路径
late String selectPath;


//部署名称
late String deployName;

//Websocket主机
late String wsHost;

//Websocket端口
late String wsPort;

//协议端本体解压后的目录
late String extDir;

//协议端配置文件
late String botConfig;

//协议端配置文件是否包含QQ号
late bool needQQ;

//如果需要QQ号，那么Bot的QQ号是？（诶诶真麻烦）
late String botQQ;

//协议端配置文件的相对路径
late String configPath;

//协议端配置文件的名称
late String configName;

//配套安装的驱动器
late String deployDriver;

//配套安装的适配器
late String deployAdapter;

//启动协议端的命令
late String cmd;

//模板
late String deployTemplate;

//插件存放位置
late String deployPluginDir;



