# 启动图源文件

这个目录预留给 **启动图 / Splash Screen / Startup Screen** 的源文件。

它和 App 桌面图标不是同一个东西。

当前 Android 启动图仍然使用 Flutter 默认启动背景：

```text
android/app/src/main/res/drawable/launch_background.xml
android/app/src/main/res/drawable-v21/launch_background.xml
```

替换 App 桌面图标的脚本不会修改这些启动图文件。

如果后续需要一键替换启动图，建议单独新增脚本，例如：

```text
scripts/update_splash.dart
```

不要和 `scripts/update_app_logo.dart` 混用。
