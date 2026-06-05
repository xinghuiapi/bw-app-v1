# 发布打包工作流设计文档

## 背景

当前项目已经具备以下独立能力：

- `scripts/update_app_logo.dart`：用 `assets/logo/logo.png` 更新双端 launcher logo。
- `scripts/update_app_name.dart`：同步更新 Android、iOS、Web 的应用名称。
- `tool/ios_build_defines.dart`：从 `lib/config/app_env.dart` 读取默认域名并生成 iOS 构建参数。
- 文档中已有 Android APK 和 iOS unsigned IPA 的手工打包命令。

现状问题不是“不能打包”，而是步骤分散：每次换项目时需要手动改域名、放 logo、改名字、清缓存、分别执行 Android 和 iOS 命令，容易漏步骤，也容易把旧 logo、旧名称或错误域名带进发布包。

本次设计目标是提供一个统一的一键工作流，让用户只保留最少的手工输入。

## 用户目标

用户每次发版前只做三件事：

1. 修改 `lib/config/app_env.dart` 中的默认域名。
2. 把新 logo 放到 `assets/logo/logo.png`。
3. 执行一条统一命令并传入应用名称。

目标命令形态：

```bash
dart run scripts/package_release.dart --name "你的App名字"
```

执行成功后，脚本默认产出：

- Android release APK（按 ABI 分包）。
- iOS 未签名 IPA。

## 范围

本设计只覆盖发布工作流编排，不改变现有业务逻辑，不修改应用运行时的环境读取方式。

包含：

- 新增统一编排脚本。
- 复用现有换 logo、换名字脚本。
- 复用现有 iOS 构建 define 机制。
- 统一执行清理、依赖安装、Android 构建、iOS 构建、IPA 打包与结果汇总。
- 为工作流补充文档说明。

不包含：

- Bundle ID 自动修改。
- 签名证书或自动重签。
- Android AAB 默认产物。
- 将域名改为命令行参数输入。
- 自动扫描多个 logo 文件。

## 输入约定

工作流输入固定为：

- 应用名称：通过命令参数 `--name` 传入。
- logo 文件：固定读取 `assets/logo/logo.png`。
- 域名配置：固定读取 `lib/config/app_env.dart` 当前默认值。

脚本不引入新的项目配置文件，避免额外维护点。

## 输出约定

Android 默认输出：

```text
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
build/app/outputs/flutter-apk/app-x86_64-release.apk
```

iOS 默认输出：

```text
build/ios/unsigned-YYYYMMDD-HHMMSS/Runner-unsigned.ipa
```

脚本执行完成后必须打印实际生成的产物路径，便于直接取包。

## 方案概述

新增 `scripts/package_release.dart` 作为统一入口，串联当前已有能力：

1. 校验输入参数与必要文件。
2. 打印并校验当前域名配置。
3. 执行 `scripts/update_app_logo.dart`。
4. 执行 `scripts/update_app_name.dart`。
5. 执行 `flutter clean`。
6. 执行 `flutter pub get`。
7. 构建 Android release APK。
8. 安装 iOS Pods。
9. 构建 iOS release 未签名产物。
10. 将 `Runner.app` 打包成 unsigned IPA。
11. 打印最终 APK / IPA 路径。

脚本作为编排层，不重复实现 logo/name 替换逻辑，避免和现有脚本形成双份实现。

## 详细流程

### 1. 参数与输入检查

启动命令：

```bash
dart run scripts/package_release.dart --name "你的App名字"
```

脚本首先检查：

- `--name` 是否存在且非空。
- `assets/logo/logo.png` 是否存在。
- `android/app/src/main/AndroidManifest.xml`、`ios/Runner/Info.plist`、`tool/ios_build_defines.dart` 是否存在。

任一条件不满足时立即失败，并输出明确错误信息。

### 2. 域名检查

脚本调用 `dart tool/ios_build_defines.dart` 获取构建参数，并在终端打印：

- `APP_ENV`
- `API_BASE_URL`
- `ASSET_BASE_URL`

同时做最基本校验：

- `API_BASE_URL` 必须以 `/api` 结尾。
- `ASSET_BASE_URL` 不得以 `/api` 结尾。

若不满足则停止，避免用错环境域名生成发布包。

### 3. 替换 logo 与名称

脚本依次执行：

```bash
dart run scripts/update_app_logo.dart assets/logo/logo.png
dart run scripts/update_app_name.dart "你的App名字"
```

这样保持当前项目已有脚本作为唯一事实来源，避免重复修改 launcher icon 和应用名称的实现细节。

### 4. 清理与依赖安装

根据用户要求，默认每次构建前都执行完整清理：

```bash
flutter clean
flutter pub get
```

此外，在打 iOS 裸包前，脚本还会删除旧的 unsigned 输出目录以及旧的 iOS 构建目录，避免混淆产物。

### 5. Android 打包

Android 使用项目当前推荐参数：

```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols
```

设计上不新增新的 Android 参数开关，先把默认发布流程固定下来，减少误用空间。

### 6. iOS 打包

脚本负责：

- 配置 `PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"`
- 配置 `RUBYOPT=-rlogger`
- 在 `ios/` 目录执行 `pod install`
- 使用 `tool/ios_build_defines.dart` 输出的参数执行 `flutter build ios --release --no-codesign`

之后再将 `build/ios/iphoneos/Runner.app` 打成带时间戳目录的 unsigned IPA。

### 7. 结果汇总

脚本最后汇总输出：

- Android APK 目录。
- 找到的各 ABI APK 文件路径。
- 最新 unsigned IPA 文件路径。

如果任一关键产物不存在，脚本判定为失败。

## 错误处理

脚本采用失败即停止策略，不允许忽略错误继续向后执行。

典型失败场景：

- 没传 `--name`。
- `assets/logo/logo.png` 不存在。
- 域名格式校验失败。
- `flutter_launcher_icons` 执行失败。
- `flutter clean` / `flutter pub get` 失败。
- `pod install` 失败。
- `flutter build apk` 失败。
- `flutter build ios` 失败。
- `Runner.app` 不存在。
- IPA 压缩完成后找不到输出文件。

每一类失败都应带上当前步骤名，便于快速定位。

## 测试策略

本次工作流以脚本编排为主，测试重点不是完整构建双端包，而是验证脚本的关键逻辑与文档一致性。

建议覆盖：

- 参数缺失时报错。
- 关键路径缺失时报错。
- 域名 define 解析与校验逻辑。
- iOS define 输出格式被正确消费。
- 构建命令参数字符串符合预期。

如需要端到端验证，使用真实环境手动执行一次工作流命令即可，不将完整双端构建纳入自动化测试。

## 文档更新

需要同步更新现有中文文档，至少包括：

- `docs/PACKAGING_GUIDE.md`
- `docs/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md`

文档重点从“手工多步命令”补充为“推荐统一命令入口”，同时保留底层命令说明，方便排错。

## 为什么采用该方案

选择 Dart 编排脚本而不是 shell 脚本，主要因为：

- 当前项目已经有多个 Dart 工具脚本，技术栈一致。
- 参数解析、路径处理、错误提示更稳定。
- 更容易复用现有脚本并追加后续能力。
- 相比新增配置文件，更符合“只改域名、放 logo、传名字、执行命令”的目标。

## 后续扩展空间

本设计保留以下扩展点，但本次不实现：

- `--android-only` / `--ios-only`
- `--skip-clean`
- `--logo <path>`
- Android AAB 输出
- Bundle ID 自动替换
- 构建完成后自动重命名产物为带应用名的文件名

这些能力只有在真实发版流程中被证明确有需求时再加入，避免过度设计。
