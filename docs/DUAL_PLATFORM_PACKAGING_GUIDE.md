# 双端打包总入口指南

## 这份文档解决什么问题

这是双端发版的总入口文档，目标是把 Android 和 iOS 打包合并到一个统一命令里完成。遇到平台专项问题时，再查看 Android 或 iOS 详细文档做深入排查。

## 发版前只做三件事

1. 把新 logo 放到 `assets/logo/logo.png`。
2. 确认客户生产域名，例如 `https://example.com`，不要带 `/api`。
3. 执行统一命令并传入应用名称和域名。

## 推荐统一命令

```bash
dart run scripts/package_release.dart --name "你的App名字" --domain https://你的域名
```

执行成功后，会输出按 ABI 拆分的 Android release APK，以及一个未签名的 iOS IPA。

脚本会把 `--domain https://你的域名` 自动生成并传给 Flutter 编译参数：`API_BASE_URL=https://你的域名/api` 和 `ASSET_BASE_URL=https://你的域名`。

版本规则：`pubspec.yaml` 初始版本为 `1.0.0+0`，对外四段版本为 `1.0.0.0`。每次统一命令成功打包后，脚本会自动把 build number 加 `1`，首次成功打包后变为 `1.0.0+1`，对外显示为 `1.0.0.1`。独立打包某个品牌会递增一次；`brand_release/package_all_brands.dart` 批量品牌打包按整批只递增一次，批内所有品牌使用同一个 build number。

## 脚本会自动做什么

1. 检查 logo、AndroidManifest 和 Info.plist 是否存在。
2. 根据 `--domain` 生成并校验发布域名配置，确保 API 地址以 `/api` 结尾、资源地址不以 `/api` 结尾。
3. 用 `assets/logo/logo.png` 更新启动图标。
4. 用 `--name` 传入的名称更新应用名称。
5. 执行 `flutter clean` 和 `flutter pub get`。
6. 构建 Android release APK，并按 ABI 拆包，同时生成混淆符号信息。
7. 清理旧 iOS 构建产物和旧的未签名 IPA 目录。
8. 在 `ios` 目录执行 `pod install`。
9. 构建未签名 iOS release app，并打包成 `Runner-unsigned.ipa`。
10. 校验并打印最终产物路径。

## 默认产物路径

Android：

```text
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
build/app/outputs/flutter-apk/app-x86_64-release.apk
```

iOS：

```text
build/ios/unsigned-YYYYMMDD-HHMMSS/Runner-unsigned.ipa
```

终端输出的路径是最终准确信息，以终端输出为准。

## 前置条件

- iOS 构建必须在 macOS 上执行。
- 本机 Flutter 环境必须可用。
- iOS 需要可用的 CocoaPods。

## 常见失败点

- `--name` 缺失或为空：重新检查命令参数。
- `--domain` 缺失、为空或带 `/api`：重新传入不带 `/api` 的资源域名，例如 `--domain https://example.com`。
- `assets/logo/logo.png` 不存在：先准备 logo 文件。
- 域名校验失败：检查 `--domain` 是否是完整 `https://` 域名且末尾没有 `/api`。
- `pod install` 失败：查看 `brand_release/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md` 里的 CocoaPods 章节。
- Android APK 没有生成：查看 `docs/PACKAGING_GUIDE.md` 里的 APK 构建章节。
- `Runner.app` 或 IPA 没有生成：查看 `brand_release/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md` 里的 iOS 构建与 IPA 校验章节。

## 进一步阅读

阅读顺序：正常双端发版时先看本文；只处理 Android 发包时再看 Android 文档；只处理 iOS 裸包或重签交付时再看 iOS 文档。

- Android 细则：`docs/PACKAGING_GUIDE.md`
- iOS 细则：`brand_release/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md`
