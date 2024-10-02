import 'dart:io';
import 'package:NoneBotGUI/utils/core.dart';
import 'package:NoneBotGUI/utils/manage.dart';
import 'package:NoneBotGUI/utils/userConfig.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class ManagePlugin extends StatefulWidget {
  const ManagePlugin({super.key});

  @override
  State<ManagePlugin> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ManagePlugin> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Row(
          children: [
            Expanded(
              child: MoveWindow(
                child: AppBar(
                  title: const Text(
                    '插件管理',
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.remove_rounded),
                      color: Colors.white,
                      onPressed: () => appWindow.minimize(),
                      iconSize: 20,
                      tooltip: "最小化",
                    ),
                    appWindow.isMaximized
                        ? IconButton(
                            icon: const Icon(Icons.rectangle_outlined),
                            color: Colors.white,
                            onPressed: () => appWindow.restore(),
                            iconSize: 20,
                            tooltip: "恢复大小",
                          )
                        : IconButton(
                            icon: const Icon(Icons.rectangle_outlined),
                            color: Colors.white,
                            onPressed: () => appWindow.maximize(),
                            iconSize: 20,
                            tooltip: "最大化",
                          ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: Colors.white,
                      onPressed: () => windowManager.hide(),
                      iconSize: 20,
                      tooltip: "关闭",
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              _selectedIndex == 0
                  ? getPluginList().isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('还没有安装任何插件'),
                              SizedBox(height: 3),
                              Text('你可以前往插件商店进行安装'),
                              SizedBox(height: 3),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: getPluginList().length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(getPluginList()[index]),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons
                                        .do_not_disturb_on_total_silence_rounded),
                                    tooltip: '禁用',
                                    onPressed: () {
                                      setState(() {
                                        Plugin.disable(getPluginList()[index]);
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    tooltip: '卸载',
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return uninstallDialog(
                                              context, index);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                  : File('${Bot.path()}/.disabled_plugins')
                          .readAsStringSync()
                          .isEmpty
                      ? const Center(
                          child: Text('空空如也...'),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: getDisabledPluginList().length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(getDisabledPluginList()[index]),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        Icons.open_in_browser_rounded),
                                    tooltip: '启用',
                                    onPressed: () {
                                      setState(() {
                                        Plugin.enable(
                                            getDisabledPluginList()[index]);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        )
            ],
          )),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.open_in_browser_rounded),
            label: '已启用的插件',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.do_not_disturb_on_total_silence_rounded),
            label: '已禁用的插件',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: (UserConfig.colorMode() == 'light')
            ? const Color.fromRGBO(238, 109, 109, 1)
            : const Color.fromRGBO(127, 86, 151, 1),
        onTap: _onItemTapped,
      ),
    );
  }
}

AlertDialog uninstallDialog(BuildContext context, int index) {
  String name = getPluginList()[index];
  return AlertDialog(
    title: const Text('确认卸载'),
    content: const Text('你确定要卸载这个插件吗？'),
    actions: <Widget>[
      TextButton(
        child: const Text('取消'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      TextButton(
        child: const Text(
          '确定',
          style: TextStyle(color: Color.fromRGBO(238, 109, 109, 1)),
        ),
        onPressed: () {
          Navigator.of(context).pop();
          _uninstall(name);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已发起卸载命令'),
              duration: Duration(seconds: 5),
            ),
          );
        },
      ),
    ],
  );
}

void _uninstall(name) async {
  List<String> commands = [Cli.plugin('uninstall', name)];
  for (String command in commands) {
    List<String> args = command.split(' ');
    String executable = args.removeAt(0);
    Process process = await Process.start(
      executable,
      args,
      runInShell: true,
      workingDirectory: Bot.path(),
    );
    await process.exitCode;
  }
}
