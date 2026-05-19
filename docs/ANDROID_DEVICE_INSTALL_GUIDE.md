# Android 真机装包测试流程

本文档记录把当前 Flutter 项目安装到数据线连接的 Android 手机上的常用流程和命令。

## 前置条件

- 手机已用数据线连接电脑。
- 手机已开启开发者模式和 USB 调试。
- 手机弹出 USB 调试授权时选择允许。
- 当前目录在项目根目录：

```bash
cd /Users/john/Documents/trae_projects/flutter_ui_project
```

## 1. 检查设备

查看 Flutter 能识别到的设备：

```bash
flutter devices
```

示例输出：

```text
25098PN5AC (mobile) • 74c09bb9 • android-arm64 • Android 16 (API 36)
```

其中 `74c09bb9` 是设备 ID，后续安装命令会用到。

如果没有看到手机：

```bash
flutter doctor
```

也可以检查 Android 设备授权状态：

```bash
adb devices
```

如果显示 `unauthorized`，需要看手机屏幕并允许 USB 调试授权。

## 2. 直接运行到手机

适合开发调试，Flutter 会构建 debug 包并安装启动应用：

```bash
flutter run -d 74c09bb9
```

如果只有一台 Android 手机，也可以：

```bash
flutter run -d android
```

特点：

- 会安装并启动应用。
- 支持热重载。
- 终端会进入调试会话。
- 首次构建可能较慢。

## 3. 构建 APK 后安装

适合只想“传一个最新版包到手机测试”，比 `flutter run` 更清晰。

构建 debug APK：

```bash
flutter build apk --debug
```

构建完成后 APK 路径通常是：

```text
build/app/outputs/flutter-apk/app-debug.apk
```

安装到指定手机：

```bash
flutter install -d 74c09bb9 --debug
```

或者直接用 adb 安装指定 APK：

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

`-r` 表示覆盖安装已有应用。

## 4. Release 包安装

如果要测试接近线上性能的包：

```bash
flutter build apk --release
```

APK 路径通常是：

```text
build/app/outputs/flutter-apk/app-release.apk
```

安装：

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

注意：release 包不支持热重载，日志和调试能力也比 debug 弱。

## 5. 常用排查命令

查看设备：

```bash
flutter devices
adb devices
```

查看已生成 APK：

```bash
ls build/app/outputs/flutter-apk/
```

清理后重建：

```bash
flutter clean
flutter pub get
flutter build apk --debug
```

卸载手机上的应用后重新安装：

```bash
adb uninstall <applicationId>
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

`applicationId` 可在 `android/app/build.gradle.kts` 中查看。

## 6. 为什么构建会慢

慢通常发生在这一步：

```text
Running Gradle task 'assembleDebug'...
```

原因包括：

- 首次构建需要编译 Android/Flutter 依赖。
- 修改了原生 Android 配置、资源、依赖或插件，增量缓存失效。
- 同时运行了 Web 调试、另一个 Flutter 构建或占用 CPU 的程序。
- Gradle daemon 冷启动。
- 网络较差时，Gradle 或 Flutter SDK 检查依赖会变慢。

建议：

- 只装手机包时，优先使用 `flutter build apk --debug` 加 `flutter install`。
- 构建 Android 前尽量停掉正在运行的 `./run_web.sh` 或其他 Flutter 调试任务。
- 第一次慢是正常的，后续增量构建通常会快很多。

## 7. 本机当前设备示例

当前检测到的 Android 真机：

```text
Name: 25098PN5AC
Device ID: 74c09bb9
Target Platform: android-arm64
```

推荐测试命令：

```bash
flutter build apk --debug
flutter install -d 74c09bb9 --debug
```

如果只是开发调试：

```bash
flutter run -d 74c09bb9
```
