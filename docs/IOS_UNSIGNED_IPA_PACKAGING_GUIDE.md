# iOS 裸包 IPA 打包指南

本文说明如何在当前 Flutter 项目中打出未签名 IPA，交给客户使用自己的 Apple 证书和描述文件重签。

项目根目录：

```bash
/Users/john/Documents/trae_projects/flutter_ui_project
```

## 推荐统一打包命令

发版前只需要先完成三件事：

- 把新 PNG logo 放到 `assets/logo/logo.png`。
- 确认客户生产域名，例如 `https://example.com`，不要带 `/api`。
- 执行统一打包脚本并传入应用名称和域名。

```bash
dart run scripts/package_release.dart --name "你的App名字" --domain https://你的域名
```

脚本会把 `--domain https://你的域名` 自动生成并传给 Flutter 编译参数：

```text
APP_ENV=production
API_BASE_URL=https://你的域名/api
ASSET_BASE_URL=https://你的域名
```

这是 iOS IPA 域名的稳定来源。不要再依赖修改 `lib/config/app_env.dart` 默认值来发包；默认值只作为代码兜底，不作为正式 IPA 发版依据。

默认 iOS 裸包产物路径格式：

```text
build/ios/unsigned-YYYYMMDD-HHMMSS/Runner-unsigned.ipa
```

下面的手工流程保留为排错参考，正常发版优先使用统一命令。

## 产物说明

裸包 IPA 只用于交给客户重签，不能直接安装到 iPhone，也不能直接提交 App Store。

默认产物路径格式：

```text
build/ios/unsigned-YYYYMMDD-HHMMSS/Runner-unsigned.ipa
```

IPA 内部必须包含：

```text
Payload/Runner.app/
```

## 前置条件

### 1. 必须使用 macOS

iOS 构建依赖 Xcode 工具链，必须在 macOS 上执行。

### 2. 安装 Flutter 依赖

```bash
flutter pub get
```

### 3. 安装 CocoaPods

项目使用了 iOS 原生插件，例如 `flutter_secure_storage`、`package_info_plus`、`url_launcher` 等，必须安装 CocoaPods。

检查命令：

```bash
pod --version
```

如果提示 `command not found: pod`，可以使用用户级 RubyGems 安装，避免使用 `sudo`：

```bash
gem install --user-install cocoapods
```

如果安装后提示 gem bin 不在 PATH，本机可临时使用：

```bash
export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"
```

如果执行 `pod install` 时遇到 `uninitialized constant ActiveSupport::LoggerThreadSafeLevel::Logger`，本机可临时加：

```bash
export RUBYOPT=-rlogger
```

## 打包流程

以下命令默认在项目根目录执行：

```bash
cd /Users/john/Documents/trae_projects/flutter_ui_project
```

### 1. 换 Logo

准备一张 PNG logo，建议尺寸至少 `1024x1024`，放到：

```text
assets/logo/logo.png
```

执行：

```bash
dart run scripts/update_app_logo.dart assets/logo/logo.png
```

脚本会更新 `assets/images/logo.png`，并根据 `pubspec.yaml` 里的 `flutter_launcher_icons` 配置重新生成 Android 和 iOS 桌面图标。

### 2. 换名字

执行：

```bash
dart run scripts/update_app_name.dart "你的App名字"
```

脚本会先读取当前旧名字，再替换成传入的新名字。旧名字来自 Android 配置里的 `android:label`，执行成功后会提示：

```text
Updated app name: "旧名字" -> "新名字"
```

脚本会同步更新：

- Android 应用名。
- Web 标题和 PWA 名称。
- iOS 后台卡片/桌面显示名，即 `ios/Runner/Info.plist` 的 `CFBundleDisplayName`。

示例：

```bash
dart run scripts/update_app_name.dart "Flutter UI Conversion"
```

如果当前旧名字是 `云鼎国际`，成功输出会类似：

```text
Updated app name: "云鼎国际" -> "Flutter UI Conversion"
```

### 3. 确认生产域名

iOS Release 包里的 API 域名来自 Flutter 编译参数 `--dart-define`，不是运行时读取本地文件。

统一打包脚本通过命令行 `--domain` 生成固定规则：

- `--domain https://example.com` 会生成 `API_BASE_URL=https://example.com/api`。
- `--domain https://example.com` 会生成 `ASSET_BASE_URL=https://example.com`。
- `APP_ENV` 固定生成 `production`。

推荐命令：

```bash
dart run scripts/package_release.dart --name "你的App名字" --domain https://example.com
```

说明：

- `--domain` 必须是资源域名，不要带 `/api`。
- 脚本会自动给 `API_BASE_URL` 追加 `/api`。
- 脚本会在终端打印最终参与编译的 `APP_ENV`、`API_BASE_URL`、`ASSET_BASE_URL`，发包前看这三行即可确认域名是否正确。
- 如果漏掉这些参数，App 会使用代码里的默认域名；如果默认域名请求失败或没有返回 `config_site`，首页会显示内置 fallback 文案，例如 `flutter.dev`、`xh-bet.com`、`星汇演示`。

### 4. 清理旧产物

打裸包前建议清理旧的 iOS 构建产物和旧的 unsigned 输出，避免发错包。

```bash
rm -rf build/ios/iphoneos \
  build/ios/Release-iphoneos \
  build/ios/XCBuildData \
  build/ios/unsigned-*(N)
```

说明：`build/ios/unsigned-*(N)` 是 zsh 写法，表示没有匹配到旧裸包目录时也不报错。

如果刚换过 App 名称、Logo、Bundle ID、域名配置，建议再执行完整清理：

```bash
flutter clean
flutter pub get
```

### 5. 安装 iOS Pods

如果本机 CocoaPods 通过用户级 RubyGems 安装，先设置临时环境变量：

```bash
export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"
export RUBYOPT=-rlogger
```

执行 Pod 安装：

```bash
cd ios
pod install
cd ..
```

成功后应看到类似输出：

```text
Pod installation complete!
```

### 6. 构建未签名 iOS Release App

```bash
PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH" RUBYOPT=-rlogger flutter build ios \
  --release \
  --no-codesign \
  --dart-define=APP_ENV=production \
  --dart-define=API_BASE_URL=https://example.com/api \
  --dart-define=ASSET_BASE_URL=https://example.com
```

不要直接执行裸命令 `flutter build ios --release --no-codesign`。如果 `pod` 是通过 `gem install --user-install cocoapods` 安装的，直接执行裸命令时 Flutter 可能找不到 CocoaPods；如果漏掉 `--dart-define`，IPA 会使用默认域名而不是客户域名。

成功后应生成：

```text
build/ios/iphoneos/Runner.app
```

### 7. 打成裸包 IPA

使用带时间戳的目录保存产物：

```bash
OUT_DIR="build/ios/unsigned-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT_DIR/Payload"
cp -R "build/ios/iphoneos/Runner.app" "$OUT_DIR/Payload/"
cd "$OUT_DIR"
/usr/bin/zip -qry "Runner-unsigned.ipa" Payload
cd -
```

最终产物：

```text
$OUT_DIR/Runner-unsigned.ipa
```

### 8. 校验 IPA

如果当前终端还保留着打包时的 `$OUT_DIR`，可以直接校验。若重新打开了终端或不确定 `$OUT_DIR`，先自动引用最新裸包目录：

```bash
OUT_DIR="$(ls -td build/ios/unsigned-* | head -n 1)"
/usr/bin/unzip -l "$OUT_DIR/Runner-unsigned.ipa" "Payload/Runner.app/Info.plist" "Payload/Runner.app/Frameworks/*"
ls -lh "$OUT_DIR/Runner-unsigned.ipa"
```

校验重点：

- 能看到 `Payload/Runner.app/Info.plist`。
- 能看到 `Payload/Runner.app/Frameworks/`。
- IPA 文件大小不是 `0B`。

## 一键命令

如果环境已准备好，可以直接执行下面整段命令重新打裸包：

```bash
cd /Users/john/Documents/trae_projects/flutter_ui_project
export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"
export RUBYOPT=-rlogger

dart run scripts/update_app_logo.dart assets/logo/logo.png
dart run scripts/update_app_name.dart "你的App名字"

rm -rf build/ios/iphoneos \
  build/ios/Release-iphoneos \
  build/ios/XCBuildData \
  build/ios/unsigned-*(N)

flutter pub get
cd ios
pod install
cd ..

PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH" RUBYOPT=-rlogger flutter build ios \
  --release \
  --no-codesign \
  --dart-define=APP_ENV=production \
  --dart-define=API_BASE_URL=https://example.com/api \
  --dart-define=ASSET_BASE_URL=https://example.com

OUT_DIR="build/ios/unsigned-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT_DIR/Payload"
cp -R "build/ios/iphoneos/Runner.app" "$OUT_DIR/Payload/"
cd "$OUT_DIR"
/usr/bin/zip -qry "Runner-unsigned.ipa" Payload
cd -

OUT_DIR="$(ls -td build/ios/unsigned-* | head -n 1)"
/usr/bin/unzip -l "$OUT_DIR/Runner-unsigned.ipa" "Payload/Runner.app/Info.plist" "Payload/Runner.app/Frameworks/*"
ls -lh "$OUT_DIR/Runner-unsigned.ipa"
```

## 客户重签注意事项

交付客户前，确认以下信息：

- 当前 `Bundle ID` 要和客户的 App ID、Provisioning Profile 匹配。
- 如果客户要改 `Bundle ID`，需要他们重签时同步修改包内配置，或你在项目里先改好再重新打包。
- 如果 App 使用推送、Associated Domains、登录、Keychain Groups 等能力，客户 Apple Developer 后台也要开启对应能力。
- 裸包 IPA 不包含客户签名，客户需要使用自己的证书、描述文件和签名工具重新签名。
- 如果客户用于上架 App Store，更推荐交付 `.xcarchive`，IPA 裸包更适合客户已有重签流程的场景。

## 常见问题

### `pod: command not found`

说明本机没有可用 CocoaPods。执行：

```bash
gem install --user-install cocoapods
export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"
```

### `uninitialized constant ActiveSupport::LoggerThreadSafeLevel::Logger`

说明系统 Ruby 和 CocoaPods 依赖初始化有兼容问题。执行：

```bash
export RUBYOPT=-rlogger
```

然后重新执行：

```bash
cd ios
pod install
cd ..
```

### `Runner.app` 不存在

说明 `flutter build ios --release --no-codesign` 没有成功。先检查 Flutter 构建日志，确认 Xcode、Pods 和 Flutter 依赖都正常。

### IPA 不能安装

这是正常现象。裸包 IPA 未签名，必须由客户重签后才能安装或分发。
