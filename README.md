# my_flutter_app



### 1）这是一个什么项目？

- **应用类型**：一款 **云游戏平台 / 的 Flutter 客户端。
- **核心业务功能**：
  - **首页与推荐**：轮播 Banner、公告跑马灯、app下载提示条、游戏分类与推荐卡片等。
  - **游戏中心**：游戏分类、游戏搜索、游戏详情、游戏启动（嵌入 WebView 或外部 H5）、游戏登录。
  - **钱包**：充值、提现、转账、充值记录详情等资金相关操作。
  - **用户体系**：登录/注册/重置密码、个人中心、资料编辑、VIP 信息、银行卡管理、通知中心、邀请分享等。
  - **记录类页面**：投注记录、资金流水记录等。
  - **活动与客服**：活动列表、活动详情页、客服入口、关于我们、合作代理介绍、系统维护页等。

这些功能在代码中主要对应：
- `lib/screens/home_screen.dart`（首页）
- `lib/widgets/home/*`（首页各模块）
- `lib/screens/basic/*`（活动、客服等基础页面）
- `lib/screens/personal/*`（个人中心相关）
- `lib/screens/wallet/*`（钱包相关）
- `lib/services/*_service.dart`（对应的业务接口）

---

### 2）主要技术栈与依赖

- **运行环境**
  - **Dart SDK**：`^3.11.0`
  - Flutter 版本由本机 SDK 决定（代码整体已适配 Dart 3）。

- **重要依赖按功能分类**

- **路由与导航**
  - **`go_router`**：集中在 `lib/router/app_router.dart`，使用 `GoRouter` 声明所有页面路由，并通过 `_authGuard` 实现登录拦截。

- **状态管理**
  - **`flutter_riverpod` + `riverpod_annotation`**：项目统一使用 Riverpod 管理状态。
  - 各业务模块都有对应的 `Notifier`：
    - 例如：`language_provider.dart`, `theme_provider.dart`, `home_provider.dart`, `game_provider.dart`, `game_launcher_provider.dart`, `recharge_provider.dart`, `withdraw_provider.dart`, `user_provider.dart`, `auth_provider.dart`, `feedback_provider.dart` 等。

- **网络层**
  - **`dio`**：HTTP 客户端，在 `lib/api/dio_client.dart` 做统一封装（baseUrl、超时、拦截器等）。
  - **`dio_smart_retry`**：请求失败自动重试。
  - 自定义拦截器：
    - `lib/api/interceptors/auth_interceptor.dart`：注入 Token、语言 Header，处理鉴权。
    - `lib/api/interceptors/error_interceptor.dart`：统一错误日志与错误处理。

- **数据模型与 JSON**
  - **`json_annotation` + `json_serializable` + `build_runner`**：通过注解自动生成模型序列化代码。
  - 模型示例：`home_data.dart`, `user_models.dart`, `game_model.dart`, `betting_models.dart`, `finance_models.dart`, `auth_models.dart`, `paginated_response.dart`, `api_response.dart` 等，对应的 `.g.dart` 文件自动生成。

- **本地存储**
  - **`shared_preferences`**：持久化一些简单配置，如主题模式、语言选择等，被 `theme_provider`、`language_provider` 使用。

- **多语言（i18n）**
  - **`slang` + `slang_flutter`**：核心多语言方案。
  - **`intl`** + **`flutter_localizations`**：Flutter 自带国际化基础。
  - 通过配置 `i18n.yaml` + `assets/translations/*.i18n.json` 生成 `lib/gen/strings*.g.dart`，在全局通过 `TranslationProvider` 和 `AppLocale` 使用。

- **UI & 组件相关**
  - `cupertino_icons`, `font_awesome_flutter`：图标库。
  - `flutter_swiper_view`：首页轮播图。
  - `marquee`：公告跑马灯。
  - `shimmer`, `flutter_spinkit`：骨架屏和 Loading 动效。
  - 自定义主题 `lib/theme/app_theme.dart`：封装浅色/深色主题和项目主色系。

- **媒体/系统能力**
  - `url_launcher`：打开外部链接。
  - `cached_network_image`：带缓存的网络图片组件（例如游戏封面、Banner）。
  - `image_picker`：图片选择（例如上传头像）。
  - `webview_flutter`：嵌入支付页、游戏 Web 页面（如游戏 WebView 页、支付 H5 页）。
  - `just_audio`：音频播放（可以用于音效或提示音）。
  - `qr_flutter`：生成二维码（可能用于邀请/收款）。
  - `flutter_widget_from_html`：将后端传来的 HTML 文本渲染为 Flutter Widget。
  - `web`：Web 平台类型支持。

---

### 3）项目结构与各目录职责（`lib/`）

- **入口与路由**
  - `lib/main.dart`：应用总入口，初始化错误处理、Riverpod Provider 容器、多语言 Provider，构建 `MaterialApp.router`。
  - `lib/router/app_router.dart`：通过 `go_router` 定义路由表和登录守卫（拦截未登录用户访问需要登录的页面）。

- **API 与网络层（`lib/api/`）**
  - `dio_client.dart`：创建和配置全局 `Dio` 实例，注册拦截器、配置重试、超时、baseUrl 等。
  - `interceptors/auth_interceptor.dart`：为请求加上 Token、语言信息，处理鉴权相关逻辑，并与 `LanguageNotifier` 协作。
  - `interceptors/error_interceptor.dart`：统一处理错误（打印、转换为统一错误对象等）。
  - `request_cache_manager.dart`：请求缓存管理。

- **数据模型（`lib/models/`）**
  - 各业务模块的数据结构定义，如：
    - `auth/`：认证相关模型 (`auth_models.dart` 等)。
    - `core/`：核心公共模型 (`api_response.dart`, `paginated_response.dart`, `pagination_state.dart`)。
    - `game/`：游戏相关模型 (`game_model.dart`, `betting_models.dart`)。
    - `home/`：首页相关模型 (`home_data.dart`)。
    - `user/`：用户与代理相关模型 (`user.dart`, `user_models.dart`, `agent_models.dart`)。
    - `wallet/`：钱包与财务相关模型 (`finance_models.dart`)。
  - 通过 `json_serializable` 生成相应的 `*.g.dart`。

- **服务层（`lib/services/`）**
  - 面向业务的 API 封装：
    - `auth/`：认证服务 (`auth_service.dart`)。
    - `game/`：游戏服务 (`game_service.dart`)。
    - `home/`：首页服务 (`home_service.dart`)。
    - `user/`：用户服务 (`user_service.dart`)。
    - `wallet/`：财务服务 (`finance_service.dart`)。

- **状态管理（`lib/providers/`）**
  - 按业务模块划分的 Riverpod Notifier：
    - `activity/`：活动状态 (`activities_provider.dart`)。
    - `auth/`：认证与登录状态 (`auth_provider.dart`, `password_reset_provider.dart`, `telegram_login_provider.dart`)。
    - `game/`：游戏业务状态 (`game_provider.dart`, `game_launcher_provider.dart`, `hot_games_provider.dart`, `favorite_games_provider.dart`)。
    - `home/`：首页状态 (`home_provider.dart`, `search_provider.dart`)。
    - `system/`：系统级状态 (`theme_provider.dart`, `language_provider.dart`)。
    - `user/`：用户中心状态 (`user_provider.dart`, `referral_provider.dart`, `notifications_provider.dart`, `feedback_provider.dart`)。
    - `wallet/`：钱包资金状态 (`recharge_provider.dart`, `withdraw_provider.dart`, `transfer_provider.dart`, `recharge_detail_provider.dart`)。

- **页面层（`lib/screens/`）**
  - `activity/`：活动与活动详情页。
  - `auth/`：登录、注册、重置密码、Telegram登录页。
  - `common/`：通用页面 (占位符等)。
  - `game/`：游戏列表与游戏视图容器 (`game_view_screen` 系列)。
  - `home/`：首页与搜索页。
  - `info/`：静态信息页 (关于我们、客服、反馈、系统维护、代理合作等)。
  - `personal/`：个人中心相关页面 (资料、记录、VIP、卡包等)。
  - `splash/`：启动页。
  - `wallet/`：充值、提现、转账详情页。

- **组件层（`lib/widgets/`）**
  - `common/`：通用组件 (`skeleton_widget.dart`, `state_widgets.dart`, `web_safe_image` 系列)。
  - `home/`：首页专有组件 (`banner_widget.dart`, `notices_widget.dart`, `quick_access_widget.dart`, `game_categories_widget.dart`, `app_download_bar_widget.dart`)。
  - `layout/`：布局组件 (`header_widget.dart`, `footer_widget.dart`, `user_drawer.dart`)。
  - `payment_webview/`：支付/收银台跨端 WebView 组件 (`payment_webview` 系列)。

- **主题与工具（`lib/theme/`, `lib/utils/`）**
  - `theme/app_theme.dart`：定义深浅色主题、颜色、TextStyle 等全局样式。
  - `utils/constants.dart`：统一常量，尤其是 API baseUrl、资源域名等。
  - `utils/toast_utils.dart`：基于 `ScaffoldMessenger` 实现统一弹窗/Toast。
  - `utils/auth_helper.dart`：登录状态辅助函数，比如 `hasToken()`，被路由守卫使用。

- **多语言生成文件（`lib/gen/`）**
  - `strings.g.dart` + `strings_en.g.dart` + `strings_pt.g.dart` + `strings_zh.g.dart` 等：`slang` 自动生成的多语言访问代码。

---

### 4）应用启动流程（`lib/main.dart`）

- **初始化阶段**
  - `WidgetsFlutterBinding.ensureInitialized()`：确保绑定初始化。
  - 设置：
    - `FlutterError.onError`：捕获并打印 Flutter 内部错误，自定义红屏 `ErrorWidget`。
    - `PlatformDispatcher.instance.onError`：捕获未处理的异步错误并打印日志。
- **挂载全局 Provider 与 i18n**
  - `runApp` 时，最外层是：
    - `ProviderScope`：Riverpod 的根容器。
    - 里面包 `TranslationProvider`：来自 `slang_flutter`，提供多语言上下文。
    - 内层是 `MyApp`（`ConsumerStatefulWidget`），根据 Provider 状态构建 `MaterialApp.router`。
- **`MyApp` 的初始化逻辑**
  - 在 `initState` 里调用 `_initApp()`：
    - 通过 `ref.read(languageProvider.notifier).init()` 读取本地存储的语言并设置当前语言（含 `slang` 和 `Dio` 的语言 header）。
    - 使用 `Future.wait([...]).timeout(Duration(seconds: 5))`，有超时时间保护。
    - 完成后将 `_isInitialized` 设为 `true`，结束初始 Loading。
- **加载页面 vs 正式 App**
  - `_isInitialized == false` 时：
    - 返回一个简单 `MaterialApp` + 黑底 + `CircularProgressIndicator` + “正在初始化...” 文案。
  - `_isInitialized == true` 时构建真正的应用：
    - `themeMode` 来自 `theme_provider`。
    - `MaterialApp.router` 关键配置：
      - `scaffoldMessengerKey: ToastUtils.messengerKey`
      - `theme: AppTheme.lightTheme`
      - `darkTheme: AppTheme.darkTheme`
      - `themeMode: themeMode`
      - `routerConfig: AppRouter.router`
      - `locale: TranslationProvider.of(context).flutterLocale`
      - `supportedLocales: AppLocaleUtils.instance.supportedLocales`
      - `localizationsDelegates: GlobalMaterialLocalizations.delegates`
- **登录拦截与路由**
  - 在 `app_router.dart` 中使用 `GoRouter` 定义路由，并通过 `_authGuard` 判断访问某些路由是否需要登录。
  - `_authGuard` 会调用 `AuthHelper.hasToken()` 判断本地是否有 Token，如果没有，就重定向到 `/login?redirect=<原路径>`。

---

### 5）国际化（i18n）方案

- **采用方案：`slang` + `slang_flutter`**
  - 配合 `intl` 与 `flutter_localizations` 实现完整多语言支持。
  - 基础语言：中文（`base_locale: zh`）。

- **配置与资源**
  - **配置文件**：`i18n.yaml`
    - 指定：
      - `base_locale: zh`
      - `input_directory: assets/translations`
      - `output_directory: lib/i18n`（实际生成目前在 `lib/gen`，即项目做了相应调整）
      - `output_file_name: strings.g.dart`
      - `translate_var: t`
      - `enum_name: AppLocale`
  - **文案资源**：`assets/translations/`
    - `en.i18n.json`（英文）
    - `pt.i18n.json`（葡语）
    - `zh.i18n.json`（中文）
    - 旧的 `strings.json` 等已被删除，说明项目已经从「自定义 JSON」迁移到 `slang` 约定格式的 `*.i18n.json`。
  - **生成代码**：`lib/gen/strings*.g.dart`
    - 提供 `t.xxx` 的翻译访问方法。
    - 提供 `AppLocale` 枚举和相关工具（如 `AppLocaleUtils`、`LocaleSettings`）。

- **语言状态管理与 API 语言同步**
  - 通过 `lib/providers/language_provider.dart` 管理当前语言：
    - 启动时 `init()` 从 `SharedPreferences` 读取语言。
    - `setLanguage(AppLocale locale)` 会：
      - 更新 `state`。
      - 调用 `LocaleSettings.setLocale(locale)` 通知 `slang`。
      - 调用 `DioClient().authInterceptor.updateLanguage(locale.apiCode)` 更新请求头的语言字段。
      - 写入 `SharedPreferences` 保存。
    - 同时会 `invalidate` 相关 Provider，让首页、活动等按新语言重新请求数据。
- **与 `MaterialApp` 集成**
  - `MaterialApp.router` 中：
    - `locale: TranslationProvider.of(context).flutterLocale`
    - `supportedLocales: AppLocaleUtils.instance.supportedLocales`
    - `localizationsDelegates: GlobalMaterialLocalizations.delegates`

---

### 6）你可以怎么继续了解/开发这个项目？

- **想了解「页面层」**：可以重点看 `lib/screens/home_screen.dart` + `lib/widgets/home/*`，理解首页结构；再看 `lib/screens/wallet/*`, `lib/screens/personal/*`。
- **想看「网络与数据流」**：从 `lib/services/game_service.dart` 或 `home_service.dart` 入手，然后对应到 `providers` 和 `screens` 看数据如何流向 UI。
- **想扩展多语言**：在 `assets/translations/*.i18n.json` 增加字段，然后通过 `slang` 重新生成 `lib/gen/strings*.g.dart`，再在页面中使用 `t.xxx`。

如果你告诉我你更关心哪一部分（比如：游戏启动逻辑、钱包流水、登录流程、主题/语言切换等），我可以结合具体文件帮你画一条「从 UI 到 API」的详细数据流。
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

本项目遵循清晰的分层架构，按业务模块进行解耦，确保代码的可维护性和可扩展性：

```text
lib/
├── api/                    # 网络请求核心模块 (拦截器、缓存管理)
├── gen/                    # 自动生成代码 (国际化 strings.g.dart)
├── models/                 # 数据模型层 (JSON 序列化模型，按业务模块如 auth, game 等细分)
├── providers/              # Riverpod 状态管理层 (按业务模块细分，统一使用 Notifier)
├── router/                 # 路由配置 (app_router.dart，声明式路由)
├── screens/                # 页面 UI 层 (按业务模块如 auth, home, game, wallet 等细分)
├── services/               # 服务层 (处理 API 调用与底层业务逻辑)
├── theme/                  # 全局样式定义 (颜色、字体、主题配置)
├── utils/                  # 工具类 (常量、Toast 通知、Auth 辅助等)
├── widgets/                # 组件库：可复用的 UI 单元 (通用组件、业务组件、布局组件)
├── driver_main.dart        # 自动化测试入口 (可选)
└── main.dart               # 应用程序主入口
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
- **`android/` / `ios/` / `web/`**: **平台特定工程**。
    - 包含各平台的入口文件和原生配置（如 Android 的 `AndroidManifest.xml` 和 iOS 的 `Info.plist`）。
    - 除非涉及原生功能集成（如支付、深度链接配置），否则开发者通常无需频繁修改。
- **`.trae/` / `.vscode/`**: **编辑器与辅助工具配置**。
    - 存放 Trae AI 规则和 VS Code 的调试/运行配置。

### 4. 各层级作用深度解析 (In-depth Layering)

- **`lib/api/`**: 统一管理 HTTP 请求配置。`auth_interceptor.dart` 负责在请求头中自动注入 Token，`error_interceptor.dart` 负责全局错误捕获并联动 `ToastUtils` 提示。`request_cache_manager.dart` 负责处理请求缓存。
- **`lib/models/`**: 定义类型安全的数据结构，按业务模块存放。所有以 `.g.dart` 结尾的文件均由 `build_runner` 自动生成。
- **`lib/providers/`**: 业务状态的“单一数据源”。通过 Riverpod (`Notifier` / `AsyncNotifier`) 实现响应式 UI 更新，将 UI 逻辑与业务逻辑解耦，同样按业务模块细分。
- **`lib/services/`**: 负责具体的 API 调用。它从 `api/` 获取原始数据，并将其转换为 `models/` 中的对象。
- **`lib/screens/`**: 存放完整的页面视图。页面应尽量简洁，按业务域划分。通过 `providers` 获取数据，通过 `widgets` 构建 UI。
- **`lib/widgets/`**: 颗粒化 UI 组件。遵循“高内聚低耦合”原则，方便在不同页面间复用。特别注意 `WebSafeImage` 用于解决 Web 端跨域图片显示问题，`payment_webview` 封装了跨平台的网页加载容器。
- **`lib/theme/`**: 维护全局视觉一致性。修改 `app_theme.dart` 即可实现一键换肤或全局样式调整。
- **`lib/router/`**: 集中管理页面跳转逻辑，支持路径参数和查询参数。


# 打包发布指南 (Packaging Guide)

按照以下步骤进行应用发布前的配置与打包：

### **第一步：更换应用 Logo**
1. 将新的 Logo 图片放入 `assets/images/` 目录下，并命名为 `logo.png`。
2. 在终端执行以下命令自动生成各平台图标：
   ```bash
   dart run flutter_launcher_icons
   ```

### **第二步：更换应用名称**
使用项目提供的脚本一键修改各平台的应用显示名称：
```bash
# 将 "你的平台名字" 替换为实际名称
dart run scripts/update_app_name.dart "你的平台名字"

# 建议在修改名称后清理缓存并重新获取依赖
flutter clean
flutter pub get
```

### **第三步：配置服务器域名**
在 [constants.dart](lib/utils/constants.dart) 中配置生产环境域名：
- 修改 `AppConstants.devBaseUrl` 变量。
- 取消注释对应的正式域名，并确保同时只有一个域名处于启用状态。

### **第四步：执行打包命令**
运行以下命令生成分架构的 Release APK：
```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols
```
安装到手机
flutter run --release

**打包产物路径：**
生成的 APK 文件位于以下目录：
`build/app/outputs/flutter-apk/`

**关于分架构打包 (`--split-per-abi`)：**
默认情况下，Flutter 会将所有 CPU 架构（arm64, arm-v7a, x86_64）打包进一个 APK。使用该参数后会生成独立的 APK，显著减小安装包体积：
- `app-arm64-v8a-release.apk`: 主流 Android 手机使用。
- `app-armeabi-v7a-release.apk`: 旧款 Android 手机使用。
- `app-x86_64-release.apk`: 部分平板和模拟器使用。

# 开发运行指南 (Development Guide)

### **1. 查看已连接设备**
列出当前所有可用的真机、模拟器或浏览器：
```bash
flutter devices
```

### **2. 运行项目**
- **默认运行（单一设备）：**
  ```bash
  flutter run
  ```
- **指定设备运行：**
  ```bash
  # 将 <Device_ID> 替换为 flutter devices 输出的 ID
  flutter run -d <Device_ID>
  ```

### **3. Web 局域网调试（手机浏览器访问）**
为了方便在手机浏览器预览 Web 版，需指定主机地址和端口：
```bash
flutter run -d chrome --web-hostname 0.0.0.0 --web-port 8080
```
*提示：手机需与电脑处于同一局域网，通过 `http://电脑IP:8080` 访问。*

### **4. 编译 Debug APK**
快速生成一个调试用的 APK 安装包：
```bash
flutter build apk --debug
```
*产物路径：`build/app/outputs/flutter-apk/app-debug.apk`*

