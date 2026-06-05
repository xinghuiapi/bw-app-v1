# 双端打包总入口文档设计

## 背景

当前项目已经具备双端统一打包能力：

- Android 细则文档：`docs/PACKAGING_GUIDE.md`
- iOS 细则文档：`docs/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md`
- 统一打包脚本：`scripts/package_release.dart`

现状问题不是“没有打包说明”，而是说明入口分散：

- 交付同事需要快速找到一条能直接执行的发版命令。
- 开发同事需要在遇到失败时快速定位应该看 Android 细则还是 iOS 细则。
- 现有两份平台文档虽然已经补充了统一命令，但仍然缺少一份真正的“双端总入口”文档，用来承接最常见的发版场景。

因此需要新增一份总入口文档，作为双端发版的第一阅读入口。

## 目标

新增一份双端打包文档，满足“两者兼顾”的阅读场景：

- 交付同事可以直接照着文档完成发版。
- 开发同事可以理解统一脚本做了什么，并知道出错后该去看哪份细则文档。

文档应把统一命令作为唯一推荐入口，同时保留现有 Android / iOS 细则文档作为深入说明与排错参考。

## 非目标

本次不包含：

- 删除或合并现有 `docs/PACKAGING_GUIDE.md` 与 `docs/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md`
- 在总文档里重复完整收录所有 Android / iOS 底层命令说明
- 新增新的打包脚本参数、构建产物或工作流逻辑

## 文档位置

新增文件：

```text
docs/DUAL_PLATFORM_PACKAGING_GUIDE.md
```

命名目标是让读者一眼知道这是“双端统一发版入口”，而不是单平台细则。

## 读者定位

目标读者为“两者兼顾”：

- 面向交付同事时，强调最少步骤、统一命令、产物路径、快速排错。
- 面向开发同事时，补充脚本行为说明、前置条件和文档跳转关系。

因此文档整体采用“前半部分短路径，后半部分补机制”的组织方式。

## 推荐方案

采用“主流程 + 产物 + 常见问题 + 跳转细则”的结构。

原因：

- 能把最核心的发版路径压缩成几分钟可读完的内容。
- 不会和现有 Android / iOS 文档形成大段重复。
- 当构建失败时，用户能快速判断问题归属的平台，再跳转到对应文档继续处理。

## 文档结构

建议结构如下：

### 1. 文档目标

用一小段话说明：

- 这是双端发布包的总入口文档。
- 正常发版优先使用统一命令。
- Android / iOS 单独文档主要用于深入说明和排错。

### 2. 发版前只做三件事

明确列出：

1. 修改 `lib/config/app_env.dart` 中默认域名。
2. 将新 logo 放到 `assets/logo/logo.png`。
3. 执行统一命令并传入应用名称。

这一节应该足够短，让交付同事可以直接照做。

### 3. 推荐统一命令

只突出一条命令：

```bash
dart run scripts/package_release.dart --name "你的App名字"
```

并说明该命令成功后默认会产出：

- Android 分 ABI Release APK
- iOS 未签名 IPA

### 4. 脚本会自动做什么

用顺序列表说明 `scripts/package_release.dart` 的实际行为：

1. 校验名称和关键文件是否存在。
2. 读取并校验域名 defines。
3. 替换 logo。
4. 替换应用名称。
5. 执行 `flutter clean`。
6. 执行 `flutter pub get`。
7. 构建 Android APK。
8. 清理旧 iOS 构建产物。
9. 执行 `pod install`。
10. 构建 iOS unsigned App。
11. 打包 unsigned IPA。
12. 打印最终产物路径。

这一节用于帮助开发同事理解统一命令不是黑盒，也便于交付同事知道脚本耗时主要在哪些阶段。

### 5. 默认产物路径

明确列出：

```text
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
build/app/outputs/flutter-apk/app-x86_64-release.apk
build/ios/unsigned-YYYYMMDD-HHMMSS/Runner-unsigned.ipa
```

并说明脚本结束后会打印实际路径，优先以终端输出为准。

### 6. 前置条件

只保留必要前提，避免重复过多平台细节：

- iOS 构建必须在 macOS 上执行。
- 本机需要 Flutter 环境正常。
- iOS 需要可用 CocoaPods。

这一节只说明最基本条件，不展开安装教程，安装细节交给 iOS 细则文档。

### 7. 常见失败点

总入口文档只覆盖高频问题，采用“现象 -> 去哪看”的方式：

- `--name` 缺失或为空：重新检查命令参数。
- `assets/logo/logo.png` 不存在：先准备 logo 文件。
- 域名校验失败：检查 `lib/config/app_env.dart` 和 `dart tool/ios_build_defines.dart` 输出。
- `pod install` 失败：跳转 iOS 细则文档中的 CocoaPods 章节。
- Android APK 缺失：跳转 Android 打包文档查看构建命令和产物目录。
- `Runner.app` 或 IPA 缺失：跳转 iOS 裸包文档查看 iOS 构建与 IPA 校验章节。

### 8. 进一步阅读

在文末给出明确跳转：

- Android 细则：`docs/PACKAGING_GUIDE.md`
- iOS 细则：`docs/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md`

并说明：

- 只关心 Android 发包时优先看 Android 文档。
- 只关心 iOS 裸包或重签交付时优先看 iOS 文档。
- 正常双端发版时先看总入口文档。

## 写作原则

总文档应遵循以下原则：

- 第一屏就出现统一命令，不把读者引到冗长背景里。
- 先说怎么发，再说为什么。
- 平台细则只做链接，不在总文档中复制整段底层步骤。
- 用词直白，避免过多 Flutter / iOS 术语堆叠。
- 所有命令、路径、产物名必须与当前脚本实现保持一致。

## 验收标准

文档完成后应满足：

- 用户能在 1 分钟内找到统一打包命令。
- 用户能在 3 分钟内理解发版前需要准备什么。
- 用户能在脚本失败时判断应该看 Android 还是 iOS 细则文档。
- 文档内容与 `scripts/package_release.dart` 当前实现一致，不描述脚本尚未实现的行为。

## 风险与约束

- 如果未来 `scripts/package_release.dart` 的步骤、参数或产物路径发生变化，总入口文档必须同步更新。
- 总入口文档不能替代平台细则文档，否则会重新回到内容冗长、难维护的问题。
- 文档需要避免把 Android 和 iOS 的所有背景知识都塞进来，保持总入口属性。
