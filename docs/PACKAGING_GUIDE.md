# APK 打包简化指南

本文只说明 Android APK 打包。打包前先确认当前目录是：

```bash
/Users/john/Documents/trae_projects/flutter_ui_project
```

## APK 三种产物

### 1. 通用 APK

一个 APK 包，兼容所有 Android ABI，文件较大。

产物位置：

```text
build/app/outputs/flutter-apk/app-release.apk
```

命令：

```bash
flutter build apk --release
```

### 2. 分架构 APK

按 CPU 架构拆成多个 APK，文件更小，适合渠道分发。

产物位置：

```text
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
build/app/outputs/flutter-apk/app-x86_64-release.apk
```

命令：

```bash
flutter build apk --release --split-per-abi
```

### 3. 加固/混淆 APK

Release 包开启 Dart 混淆，并输出符号文件，正式分发推荐使用。

产物位置：

```text
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
build/app/outputs/flutter-apk/app-x86_64-release.apk
build/app/outputs/symbols/
```

命令：

```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols
```

## 打包流程

### 1. 换域名

打包时通过 `--dart-define` 指定 API 域名和资源域名。

示例：

```bash
--dart-define=APP_ENV=production \
--dart-define=API_BASE_URL=https://你的域名/api \
--dart-define=ASSET_BASE_URL=https://你的域名
```

说明：

- `API_BASE_URL` 必须带 `/api`。
- `ASSET_BASE_URL` 不带 `/api`。

### 2. 换 Logo

准备一张 PNG logo，建议尺寸至少 `1024x1024`，放到：

```text
assets/logo/logo.png
```

执行：

```bash
dart run scripts/update_app_logo.dart assets/logo/logo.png
```

脚本会更新 `assets/images/logo.png` 并重新生成 Android 图标。

### 3. 换名字

执行：

```bash
dart run scripts/update_app_name.dart "你的App名字"
```

### 4. 执行打包命令

执行前一般不需要手动清理旧产物，Flutter 会覆盖同名 APK。

如果刚换过 Logo、App 名称，或怀疑旧缓存影响结果，可以先执行：

```bash
flutter clean && flutter pub get
```

默认使用这个单行命令：

```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols
```

如果需要同时指定生产域名，使用下面这种多行格式：

```bash
flutter build apk \
  --release \
  --split-per-abi \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols \
  --dart-define=APP_ENV=production \
  --dart-define=API_BASE_URL=https://你的域名/api \
  --dart-define=ASSET_BASE_URL=https://你的域名
```

打包完成后，到这里取 APK：

```text
build/app/outputs/flutter-apk/
```

常用安装包一般选择：

```text
app-arm64-v8a-release.apk
```

大多数新 Android 手机使用 `arm64-v8a`。
