# App 图标源文件

这个目录只用于存放 **App 桌面图标 / Launcher Icon** 的源文件。

它不是启动图，也不会影响 App 启动时显示的 splash/startup screen。

把要替换的 App 图标图片放到这里，并命名为：

```text
assets/logo/logo.png
```

然后在项目根目录执行：

```bash
dart run scripts/update_app_logo.dart
```

脚本会把这个文件复制到：

```text
assets/images/logo.png
```

然后通过 `flutter_launcher_icons` 重新生成 Android 桌面图标。

会更新类似下面这些文件：

```text
android/app/src/main/res/mipmap-*/ic_launcher.png
```

不会更新 Android 启动图文件：

```text
android/app/src/main/res/drawable/launch_background.xml
android/app/src/main/res/drawable-v21/launch_background.xml
```

如果不想放到 `assets/logo/logo.png`，也可以手动传入 PNG 路径：

```bash
dart run scripts/update_app_logo.dart path/to/logo.png
```

注意：图片必须是 PNG。建议使用正方形高清图片，例如 `1024x1024`。
