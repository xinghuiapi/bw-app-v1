# Dual Platform Packaging Guide Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a new top-level dual-platform packaging guide that makes `scripts/package_release.dart` the first-choice release path while keeping Android and iOS platform guides as troubleshooting references.

**Architecture:** Create one new guide file at `docs/DUAL_PLATFORM_PACKAGING_GUIDE.md` and keep it intentionally short in the first half. Reuse the already-written platform guides through explicit links instead of copying their low-level command details into the new document.

**Tech Stack:** Markdown documentation, existing Dart release script, focused Flutter doc tests when applicable.

---

## File Structure

- Create: `docs/DUAL_PLATFORM_PACKAGING_GUIDE.md`
  Purpose: New dual-platform release entry point for both delivery and engineering readers.
- Read for consistency: `scripts/package_release.dart`
  Purpose: Confirm the documented workflow, prerequisites, environment details, and artifact paths match the current script behavior.
- Read for linking and wording consistency: `docs/PACKAGING_GUIDE.md`
  Purpose: Keep Android-only low-level instructions as the deeper reference.
- Read for linking and wording consistency: `docs/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md`
  Purpose: Keep iOS unsigned IPA low-level instructions as the deeper reference.

### Task 1: Draft the New Guide Structure

**Files:**
- Create: `docs/DUAL_PLATFORM_PACKAGING_GUIDE.md`

- [ ] **Step 1: Write the document skeleton with the approved sections**

Create `docs/DUAL_PLATFORM_PACKAGING_GUIDE.md` with these headings in this exact order:

```md
# 双端打包总入口指南

## 这份文档解决什么问题

## 发版前只做三件事

## 推荐统一命令

## 脚本会自动做什么

## 默认产物路径

## 前置条件

## 常见失败点

## 进一步阅读
```

- [ ] **Step 2: Verify the file contains the agreed headings only once**

Run: `grep -n "^## " docs/DUAL_PLATFORM_PACKAGING_GUIDE.md`

Expected: exactly 8 section headings matching the approved structure.

### Task 2: Fill the Operational Content

**Files:**
- Modify: `docs/DUAL_PLATFORM_PACKAGING_GUIDE.md`

- [ ] **Step 1: Add the short opening and three required preparation steps**

Use this content pattern near the top of the file:

```md
## 这份文档解决什么问题

这是一份双端发版总入口文档。正常发版时，优先使用统一命令；当 Android 或 iOS 某一端单独排错时，再进入对应的平台细则文档。

## 发版前只做三件事

1. 修改 `lib/config/app_env.dart` 中的默认域名。
2. 把新 logo 放到 `assets/logo/logo.png`。
3. 执行统一命令并传入应用名称。
```

- [ ] **Step 2: Add the recommended command and its release outputs**

Use this content block:

```md
## 推荐统一命令

```bash
dart run scripts/package_release.dart --name "你的App名字"
```

执行成功后，默认会产出：

- Android release APK（按 ABI 分包）
- iOS 未签名 IPA
```

- [ ] **Step 3: Add the exact release-sequence list from the script behavior**

Document the workflow as a numbered list with these items:

```md
## 脚本会自动做什么

1. 校验名称和关键文件是否存在。
2. 读取并校验域名配置。
3. 更新 launcher logo。
4. 更新应用名称。
5. 执行 `flutter clean`。
6. 执行 `flutter pub get`。
7. 构建 Android release APK。
8. 清理旧的 iOS 构建产物和旧的 unsigned 输出目录。
9. 执行 `pod install`。
10. 构建 iOS release 未签名产物。
11. 打包 unsigned IPA。
12. 打印最终 APK / IPA 路径。
```

- [ ] **Step 4: Add the default artifact paths and the terminal-output note**

Use this content block:

```md
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

脚本结束后会打印实际生成的产物路径，取包时优先以终端输出为准。
```

### Task 3: Add Prerequisites, Troubleshooting, and Cross-Links

**Files:**
- Modify: `docs/DUAL_PLATFORM_PACKAGING_GUIDE.md`

- [ ] **Step 1: Add the minimal prerequisites section**

Use these bullets:

```md
## 前置条件

- iOS 构建必须在 macOS 上执行。
- 本机 Flutter 环境必须可用。
- iOS 需要可用的 CocoaPods。
```

- [ ] **Step 2: Add the high-frequency failure routing section**

Use this content pattern and keep each bullet focused on symptom -> action:

```md
## 常见失败点

- `--name` 缺失或为空：重新检查命令参数。
- `assets/logo/logo.png` 不存在：先准备 logo 文件。
- 域名校验失败：检查 `lib/config/app_env.dart` 和 `dart tool/ios_build_defines.dart` 输出。
- `pod install` 失败：查看 `docs/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md` 里的 CocoaPods 章节。
- Android APK 没有生成：查看 `docs/PACKAGING_GUIDE.md` 里的 APK 构建章节。
- `Runner.app` 或 IPA 没有生成：查看 `docs/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md` 里的 iOS 构建与 IPA 校验章节。
```

- [ ] **Step 3: Add the final reading guide with explicit navigation rules**

Use this content block:

```md
## 进一步阅读

- Android 细则：`docs/PACKAGING_GUIDE.md`
- iOS 细则：`docs/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md`

建议阅读顺序：

- 正常双端发版时，先看本文。
- 只处理 Android 发包时，再看 `docs/PACKAGING_GUIDE.md`。
- 只处理 iOS 裸包或重签交付时，再看 `docs/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md`。
```

### Task 4: Validate Against the Existing Workflow

**Files:**
- Modify: `docs/DUAL_PLATFORM_PACKAGING_GUIDE.md`
- Read: `scripts/package_release.dart`
- Read: `docs/PACKAGING_GUIDE.md`
- Read: `docs/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md`

- [ ] **Step 1: Check command, sequence, and artifact names against the script**

Run: `grep -n "package_release\.dart\|app-arm64-v8a-release\.apk\|Runner-unsigned\.ipa" docs/DUAL_PLATFORM_PACKAGING_GUIDE.md`

Expected: the new guide references the exact command and artifact names used by the current workflow.

- [ ] **Step 2: Read the finished guide once for duplication and overreach**

Review the final file and confirm:

- It does not copy large low-level Android command sections from `docs/PACKAGING_GUIDE.md`.
- It does not copy large low-level iOS signing or CocoaPods setup sections from `docs/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md`.
- It keeps the first screen short and action-oriented.

- [ ] **Step 3: Run a focused documentation smoke check**

Run: `flutter test test/ios_packaging_guide_test.dart`

Expected: PASS. Existing iOS guide references remain valid after the new top-level guide is added.
