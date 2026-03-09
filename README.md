# my_flutter_app

这是一个 Flutter 项目。本文档旨在帮助新手队友快速搭建环境并运行项目。

---

## 🛠️ 技术栈 (Tech Stack)

本项目采用现代化的 Flutter 跨平台架构，确保了代码的高复用性和运行的高性能：

*   **核心框架**：Flutter 3.x (Dart 3.x)
*   **状态管理**：**Riverpod 3.x** —— 响应式、编译时安全的状态管理方案。
*   **路由导航**：**GoRouter 17.x** —— 官方推荐的声明式路由，支持 Deep Link。
*   **网络层**：**Dio 5.x** —— 支持拦截器、全局错误处理及请求缓存。
*   **数据持久化**：Shared Preferences (用于 Token 和用户配置存储)。
*   **数据模型**：json_serializable (配合 build_runner 自动生成序列化代码)。
*   **UI/组件库**：
    - CachedNetworkImage (高效图片缓存)
    - FontAwesome (第三方图标库)
    - Shimmer & SpinKit (加载动画)

## 📱 平台兼容性 (Compatibility)

项目原生支持以下平台，并已完成核心功能的适配：

*   **Web 端**：完美兼容，已处理 CORS 跨域图片显示问题（通过 `WebSafeImage`）。
*   **Android 端**：**完全兼容**。支持原生 APK/App Bundle 打包，运行稳定。
*   **iOS 端**：**完全兼容**。适配了 iOS 侧滑返回手感及居中标题。
    *   *注意：由于涉及图片上传功能，发布前需在 `Info.plist` 中补充相机/相册权限说明。*
*   **Windows 端**：支持桌面端运行。

---

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

## 📁 项目目录结构 (Project Layout)

### 1. 根目录结构 (Root Directory)

项目根目录包含了跨平台配置、资源管理及开发工具配置：

```text
.
├── .trae/              # Trae IDE 专属配置，包含 AI 辅助规则 (rules/1.md)
├── .vscode/            # VS Code 编辑器配置 (调试启动 launch.json)
├── android/            # Android 原生工程：权限申请、打包配置、原生插件集成
├── ios/                # iOS 原生工程：证书管理、Info.plist 配置、原生代码
├── web/                # Web 平台工程：index.html 入口、PWA 配置、图标资源
├── windows/            # Windows 桌面端原生工程
├── macos/              # macOS 桌面端原生工程
├── linux/              # Linux 桌面端原生工程
├── assets/             # 静态资源库：多语言翻译 (translations/)、图片、字体
├── docs/               # 项目文档：接口文档 (获取数据.md)、业务逻辑说明
├── lib/                # 核心源代码目录 (详见下方 lib 结构)
├── test/               # 自动化测试：单元测试、Widget 测试
├── .gitignore          # Git 忽略文件配置
├── analysis_options.yaml # Dart 代码规范与 Lint 规则配置
├── build.yaml          # build_runner 自动化代码生成配置
├── pubspec.yaml        # 项目核心配置文件：依赖管理、资源声明
├── pubspec.lock        # 依赖版本锁定文件
└── REFACTOR_GUIDE.md   # 重构指南：记录了从 Web 迁移至 Flutter 的技术约定
```

### 2. 核心代码目录 (lib/)

本项目遵循清晰的分层架构，确保代码的可维护性和可扩展性：

```text
lib/
├── api/                # 网络层：基于 Dio 封装的 HTTP 客户端
├── models/             # 数据模型：包含 API 响应及实体类 (使用 json_serializable)
├── providers/          # 状态管理：Riverpod Notifiers (AsyncNotifier/Notifier)
├── router/             # 路由配置：GoRouter 声明式路由定义
├── services/           # 业务逻辑：API 调用及底层数据处理
├── screens/            # 页面 UI：完整的业务场景页面
├── theme/              # 全局样式：颜色、字体、主题配置
├── utils/              # 工具类：常量定义、辅助函数、Toast 通知
├── widgets/            # 组件库：可复用的 UI 单元
├── main.dart           # 应用入口
└── driver_main.dart    # 自动化测试入口 (可选)
```

### 3. lib 同级目录深度解析 (Root Sibling Directories)

除了核心逻辑所在的 `lib/` 目录外，以下同级目录也承载了重要的功能：

- **`assets/`**: **静态资源中心**。
    - `translations/`: 存放多语言 i18n JSON 文件。
    - *注：所有新增的图片、字体或本地数据文件均应在此目录下分类存放。*
- **`docs/`**: **项目文档库**。
    - 存放业务逻辑说明、接口文档（如 `获取数据.md`）及重构过程中的技术笔记。
- **`test/`**: **测试套件**。
    - 包含单元测试（Unit Tests）和组件测试（Widget Tests），是 CI/CD 流程的重要组成部分。
- **`android/` / `ios/` / `web/` / `windows/`**: **平台特定工程**。
    - 包含各平台的入口文件和原生配置（如 Android 的 `AndroidManifest.xml` 和 iOS 的 `Info.plist`）。
    - 除非涉及原生功能集成（如支付、深度链接配置），否则开发者通常无需频繁修改。
- **`.trae/` / `.vscode/`**: **编辑器与辅助工具配置**。
    - 存放 Trae AI 规则和 VS Code 的调试/运行配置。

### 4. 各层级作用深度解析 (In-depth Layering)

- **`lib/api/`**: 统一管理 HTTP 请求配置。`auth_interceptor.dart` 负责在请求头中自动注入 Token，`error_interceptor.dart` 负责全局错误捕获并联动 `ToastUtils` 提示。
- **`lib/models/`**: 定义类型安全的数据结构。所有以 `.g.dart` 结尾的文件均由 `build_runner` 自动生成。
- **`lib/providers/`**: 业务状态的“单一数据源”。通过 Riverpod 实现响应式 UI 更新，将 UI 逻辑与业务逻辑解耦。
- **`lib/services/`**: 负责具体的 API 调用。它从 `api/` 获取原始数据，并将其转换为 `models/` 中的对象。
- **`lib/screens/`**: 存放完整的页面视图。页面应尽量简洁，通过 `providers` 获取数据，通过 `widgets` 构建 UI。
- **`lib/widgets/`**: 颗粒化 UI 组件。遵循“高内聚低耦合”原则，方便在不同页面间复用。特别注意 `WebSafeImage` 用于解决 Web 端跨域图片显示问题。
- **`lib/theme/`**: 维护全局视觉一致性。修改 `app_theme.dart` 即可实现一键换肤或全局样式调整。
- **`lib/router/`**: 集中管理页面跳转逻辑，支持路径参数和查询参数。
