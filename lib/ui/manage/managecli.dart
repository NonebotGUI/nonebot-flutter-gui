import 'dart:io';

import 'package:NoneBotGUI/ui/manage/adapter.dart';
import 'package:NoneBotGUI/ui/manage/driver.dart';
import 'package:NoneBotGUI/ui/manage/manage_cli.dart';
import 'package:NoneBotGUI/ui/manage/manage_plugin.dart';
import 'package:NoneBotGUI/ui/manage/plugin.dart';
import 'package:NoneBotGUI/utils/manage.dart';
import 'package:NoneBotGUI/utils/userConfig.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';


class manageCli extends StatefulWidget {
  const manageCli({super.key});

  @override
  State<manageCli> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<manageCli> {
  final myController = TextEditingController();
  int _selectedIndex = 0;
  String _appBarTitle = '管理Bot';

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
                    'Bot管理',
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
                            onPressed: () => setState(() {
                              appWindow.restore();
                            }),
                            iconSize: 20,
                            tooltip: "恢复大小",
                          )
                        : IconButton(
                            icon: const Icon(Icons.rectangle_outlined),
                            color: Colors.white,
                            onPressed: () => setState(() {
                              appWindow.maximize();
                            }),
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
      body: Row(
        children: <Widget>[
          NavigationRail(
            useIndicator: false,
            selectedIconTheme: IconThemeData(
                color: UserConfig.colorMode() == 'light'
                    ? const Color.fromRGBO(238, 109, 109, 1)
                    : const Color.fromRGBO(127, 86, 151, 1),
                size: 25),
            selectedLabelTextStyle: TextStyle(
                color: UserConfig.colorMode() == 'light'
                    ? const Color.fromRGBO(238, 109, 109, 1)
                    : const Color.fromRGBO(127, 86, 151, 1)),
            unselectedIconTheme: IconThemeData(
                size: 25,
                color:
                    UserConfig.colorMode() == 'light' ? Colors.grey[900] : Colors.grey[200]),
            elevation: 2,
            minExtendedWidth: 200,
            indicatorShape: const RoundedRectangleBorder(),
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
                switch (index) {
                  case 0:
                    _appBarTitle = '插件商店';
                    break;
                  case 1:
                    _appBarTitle = '适配器商店';
                    break;
                  case 2:
                    _appBarTitle = '驱动器商店';
                    break;
                  case 3:
                    _appBarTitle = '管理插件';
                    break;
                  case 4:
                    _appBarTitle = '管理cli本体';
                    break;
                  case 5:
                    _appBarTitle = 'env配置';
                    break;
                  default:
                    _appBarTitle = 'Null';
                    break;
                }
              });
            },
            selectedIndex: _selectedIndex,
            extended: true,
            destinations: <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(
                  _selectedIndex == 0
                      ? Icons.storefront_rounded
                      : Icons.storefront_outlined,
                ),
                label: const Text('插件商店'),
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 15)
              ),
              NavigationRailDestination(
                icon: Icon(
                  _selectedIndex == 1
                      ? Icons.storefront_rounded
                      : Icons.storefront_outlined,
                ),
                label: const Text('适配器商店'),
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 15)
              ),
              NavigationRailDestination(
                icon: Icon(
                  _selectedIndex == 2
                      ? Icons.storefront_rounded
                      : Icons.storefront_outlined,
                ),
                label: const Text('驱动器商店'),
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 15)
              ),
              NavigationRailDestination(
                icon: Icon(
                  _selectedIndex == 3
                      ? Icons.extension_rounded
                      : Icons.extension_outlined,
                ),
                label: const Text('管理插件'),
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 15)
              ),
              NavigationRailDestination(
                icon: Icon(
                  _selectedIndex == 4
                      ? Icons.settings_applications_rounded
                      : Icons.settings_applications_outlined,
                ),
                label: const Text('管理cli本体'),
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 15)
              ),
              NavigationRailDestination(
                icon: Icon(
                  _selectedIndex == 5
                      ? Icons.file_copy_rounded
                      : Icons.file_copy_outlined,
                ),
                label: const Text('env配置'),
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 15)
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
        ],
      )
    );
  }
}
