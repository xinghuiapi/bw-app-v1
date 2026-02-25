# my_flutter_app

这是一个 Flutter 项目。本文档旨在帮助新手队友快速搭建环境并运行项目。

## 🚀 环境搭建指南 (针对 Windows 用户)

由于国内网络环境特殊，请严格按照以下步骤操作，以确保下载速度。

### 1. 安装 Flutter SDK
1.  **下载**：访问 [Flutter 官网](https://docs.flutter.dev/install/manual/windows/mobile/android) 下载最新的 Stable 版本压缩包。
2.  **解压**：将压缩包解压到一个**没有中文、没有空格**的路径（例如 `C:\src\flutter`）。
    *   *注意：不要安装在 `C:\Program Files` 等需要管理员权限的目录。*

### 2. 配置国内镜像 (重要！)
为了解决下载插件缓慢或失败的问题，请配置以下环境变量：
1.  右键点击“此电脑” -> “属性” -> “高级系统设置” -> “环境变量”。
2.  在“用户变量”中新建两个变量：
    *   变量名：`PUB_HOSTED_URL`，值：`https://pub.flutter-io.cn`
    *   变量名：`FLUTTER_STORAGE_BASE_URL`，值：`https://storage.flutter-io.cn`

### 3. 配置环境变量 (PATH)
1.  在“用户变量”中找到名为 `Path` 的变量，点击“编辑”。
2.  新建一条，填入你解压的 Flutter SDK 中 `bin` 目录的完整路径（例如 `C:\src\flutter\bin`）。
3.  **验证**：打开一个新的命令行 (cmd 或 PowerShell)，输入 `flutter --version`。如果看到版本信息，说明成功了！

### 4. 安装 Android 开发环境 (如果需要跑在安卓手机上)
1.  下载并安装 [Android Studio](https://developer.android.google.cn/studio)。
2.  安装完成后，打开 Android Studio，进入 **SDK Manager** -> **SDK Tools**。
3.  勾选 **Android SDK Command-line Tools (latest)** 并安装。
4.  运行命令同意协议：`flutter doctor --android-licenses` (一路输入 `y` 即可)。

## 🍎 环境搭建指南 (针对 macOS / iOS 用户)

iOS 开发必须使用 macOS 系统。

### 1. 安装 Flutter SDK
1.  **下载**：访问 [Flutter 官网](https://docs.flutter.dev/install/manual/macos/mobile/ios) 下载最新的 Stable 版本。
2.  **解压并配置 PATH**：
    *   将 SDK 解压到你喜欢的目录（如 `~/development/flutter`）。
    *   在终端运行 `open ~/.zshrc`（如果你用的是 zsh），添加以下内容：
        ```bash
        export PATH="$PATH:[你的FLUTTER路径]/bin"
        ```

### 2. 配置国内镜像
在同一个配置文件（如 `~/.zshrc`）中添加：
```bash
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```
修改完成后，运行 `source ~/.zshrc` 使其生效。

### 3. 安装开发工具
1.  **Xcode**：在 Mac App Store 下载安装。安装后运行：
    ```bash
    sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
    sudo xcodebuild -runFirstLaunch
    ```
2.  **CocoaPods** (iOS 依赖管理工具)：
    ```bash
    sudo gem install cocoapods
    ```

---

## 🛠️ 项目初始化与运行

克隆代码到本地后，请执行以下步骤：

### 1. 安装项目依赖
在项目根目录下运行：
```powershell
flutter pub get
```

### 2. 检查环境
运行以下命令查看是否还有遗漏的配置：
```powershell
flutter doctor
```

### 3. 运行项目
确保你已经连接了设备（安卓手机需开启 USB 调试，iPhone 需连接 Mac 并信任电脑）或者打开了浏览器/模拟器：
```powershell
flutter run
```

## 💻 推荐开发工具
*   **VS Code** (轻量级，推荐)：
    *   安装插件：`Flutter` 和 `Dart`。
*   **Android Studio** (功能强大)：
    *   安装插件：`Flutter`。

## 📁 项目结构简述
*   `lib/main.dart`：应用入口，所有的代码逻辑基本都在 `lib` 目录下。
*   `pubspec.yaml`：配置文件，用于管理第三方库和图片资源。
