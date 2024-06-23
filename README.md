<div align="center">
  <a ><img src="lib/assets/logo.png" width="180" height="180" alt="NonebotGUI_Logo"></a>
  <br>
<div align="center">

# nonebot-flutter-gui
</div>

_✨ 新一代Nonebot图形化界面 ✨_

<br>


<a href="./LICENSE">
    <img src="https://img.shields.io/github/license/XTxiaoting14332/nonebot-flutter-gui.svg" alt="license">
</a>

</div>

## ⚠️ 史山警告

本项目包含了**大量的史山代码**

## 👆🤓 依赖
本软件运行需要Microsoft Visual C++ Redistributable运行时，如无法打开请尝试从此处下载安装运行时再使用。
[https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)

## 📖 介绍

新一代Nonebot图形化界面,基于Dart和Flutter进行开发<br>

## ✨特点
### 快速上手，开箱即用
Nonebot Flutter GUI提供了简洁的UI界面供用户使用，即使是小白也能够轻松上手，从安装到运行，一步到位
<br>

### 多平台适配
基于Google的革命性框架Flutter开发，因此能够在Windows/MacOS/Linux上使用
<br>

### 更高效地管理
轻松对bot的插件/适配器/驱动器/cli的软件包进行安装和卸载，一步到位，不再需要手打nb plugin install等命令
<br>

### 简洁实用
简洁实用的管理面板让你更好地对bot进行操作，运行/停止/重启，打开文件夹，仅需点击按钮即可搞定！
<br>

### 多bot管理
只需要在主页面，即可对已有的Bot进行管理，不再需要手动切换文件夹

## 💪 支持的系统
| 系统 | 是否经过测试 | 是否能够正常工作 | 测试环境 |
|:-----:|:----:|:----:| :----: |
| Windows | ✅ | ✅ | Windows10LTSC |
| Linux | ✅ | ✅ | Ubuntu 22.04.2 LTS |
| MacOS  | ❌ | ❓ | 🤔 |


## 🚚 0.1.7 数据迁移指南
从``0.1.7``版本开始，NonebotGUI将不再使用``用户目录/.nbgui``作为数据文件夹，而是使用``path_provider``提供路径<br>
你需要**手动**将旧版本``.nbgui``下的所有目录和文件移动到新版本的文件夹中，在应用程序的``更多-设置-旧版本数据迁移指南``中可以看见新版本的路径

## ⚙️安装
我们推荐您前往``Release``页面下载对应平台的稳定发版，或者前往``Actions``下载最新的构建 **（这可能会不稳定！）**

## 🔧手动构建
如果您想要手动构建，请确保你已经安装了``Flutter SDK``<br>

### 为Windows构建
```
flutter build windows
```
### 为Linux构建
```
flutter build linux
```
### 为MacOS构建
```
flutter build macos
```

## 📑 TODO List

- [ ] 清理史山
- [ ] 使用GetX管理状态
- [X] 重构新的UI
- [X] 在主页面直接启动Bot
- [X] 检查更新
