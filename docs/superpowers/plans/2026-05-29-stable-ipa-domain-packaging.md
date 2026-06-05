# Stable IPA Domain Packaging Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make release packaging require an explicit `--domain` argument and reliably pass the generated domain defines into the unsigned iOS IPA build.

**Architecture:** `scripts/package_release.dart` becomes the single source of release domain truth for packaging. It parses `--domain https://host`, derives `API_BASE_URL=https://host/api` and `ASSET_BASE_URL=https://host`, validates them, and passes the same defines to Android and iOS build commands.

**Tech Stack:** Dart CLI script, Flutter build `--dart-define`, Flutter widget tests for script behavior, Markdown packaging docs.

---

### Task 1: Lock Domain CLI Behavior With Tests

**Files:**
- Modify: `test/package_release_script_test.dart`

- [ ] Add tests that `ReleaseOptions.parse` requires `--domain`, normalizes a trailing slash, rejects domains ending with `/api`, and exposes generated `ReleaseDefines`.
- [ ] Run `flutter test "test/package_release_script_test.dart"` and confirm it fails before implementation.

### Task 2: Implement Explicit Domain Defines

**Files:**
- Modify: `scripts/package_release.dart`

- [ ] Add `--domain` parsing to `ReleaseOptions`.
- [ ] Add `ReleaseDefines.fromDomain` to generate `APP_ENV`, `API_BASE_URL`, and `ASSET_BASE_URL`.
- [ ] Stop reading `tool/ios_build_defines.dart` during release packaging.
- [ ] Keep printing release defines before building.
- [ ] Run `flutter test "test/package_release_script_test.dart"` and confirm tests pass.

### Task 3: Update iOS Packaging Documentation

**Files:**
- Modify: `docs/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md`

- [ ] Replace instructions that tell users to edit `lib/config/app_env.dart` for release packaging.
- [ ] Document the stable command: `dart run scripts/package_release.dart --name "你的App名字" --domain https://你的域名`.
- [ ] Explain that the script generates `API_BASE_URL=https://你的域名/api` and `ASSET_BASE_URL=https://你的域名` and passes them into `flutter build ios --dart-define`.
- [ ] Keep the manual iOS build section as troubleshooting reference, but update it to use explicit `--dart-define` flags.

### Task 4: Verify

**Files:**
- Test: `test/package_release_script_test.dart`
- Test: `test/ios_packaging_guide_test.dart`

- [ ] Run `dart format scripts/package_release.dart test/package_release_script_test.dart`.
- [ ] Run analyzer for changed Dart files.
- [ ] Run `flutter test "test/package_release_script_test.dart"`.
- [ ] Run `flutter test "test/ios_packaging_guide_test.dart"`.
