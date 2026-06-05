# Release Packaging Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a single Dart command that updates release branding, validates production domains, builds Android split APKs, builds an unsigned iOS IPA, and prints the generated package paths.

**Architecture:** Add `scripts/package_release.dart` as the only new entry point. Keep existing logo/name/iOS define scripts as the source of truth and make the new script a small orchestration layer with testable pure helpers for argument parsing, define parsing, command construction, and IPA path generation.

**Tech Stack:** Dart script, Flutter CLI, CocoaPods, `flutter_test` for script-level tests.

---

### Task 1: Script Helper Tests

**Files:**
- Create: `test/package_release_script_test.dart`
- Create: `scripts/package_release.dart`

- [x] **Step 1: Write failing tests for argument parsing, define validation, command arguments, and IPA path generation**

Run: `flutter test test/package_release_script_test.dart`

Expected: FAIL because `scripts/package_release.dart` does not exist yet.

- [x] **Step 2: Add minimal helper implementation**

Implement `ReleaseOptions.parse`, `ReleaseDefines.parse`, `ReleaseDefines.validate`, `androidBuildArgs`, `iosBuildArgs`, `unsignedIpaDirectoryName`, and `unsignedIpaPath` inside `scripts/package_release.dart`.

- [x] **Step 3: Verify helper tests pass**

Run: `flutter test test/package_release_script_test.dart`

Expected: PASS.

### Task 2: Release Orchestration Script

**Files:**
- Modify: `scripts/package_release.dart`

- [x] **Step 1: Implement input validation**

Check `--name`, `assets/logo/logo.png`, `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`, and `tool/ios_build_defines.dart` before starting slow release commands.

- [x] **Step 2: Implement command runner with step names**

Run each external command with printed step headers and fail immediately with the current step name when an exit code is non-zero.

- [x] **Step 3: Implement release sequence**

Run logo update, app name update, `flutter clean`, `flutter pub get`, Android APK build, iOS cleanup, `pod install`, iOS build with generated defines, unsigned IPA packaging, and artifact verification.

### Task 3: Documentation Update

**Files:**
- Modify: `docs/PACKAGING_GUIDE.md`
- Modify: `docs/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md`

- [x] **Step 1: Add recommended unified command**

Document `dart run scripts/package_release.dart --name "你的App名字"` as the preferred release path.

- [x] **Step 2: Keep manual commands as troubleshooting reference**

Do not remove existing Android/iOS low-level commands; mark them as manual fallback details.

### Task 4: Verification

**Files:**
- All touched files

- [x] **Step 1: Format Dart changes**

Run: `dart format scripts/package_release.dart test/package_release_script_test.dart`

- [x] **Step 2: Run focused tests**

Run: `flutter test test/package_release_script_test.dart test/ios_packaging_guide_test.dart`

