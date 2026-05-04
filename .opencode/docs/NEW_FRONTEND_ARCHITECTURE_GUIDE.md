# flutter_ui_project 前端架构规范

本文档是 `flutter_ui_project` 后续前端业务开发的唯一规范入口。当前项目不是单纯 UI Demo，也不是旧 Flutter 项目的改皮版本，而是最终落地的 Flutter 业务前端主工程。

核心定位：当前 Flutter UI 已按 m1 项目完成高仿，后续要在这套高仿 UI 上接入 m1 的页面业务逻辑和真实接口，同时参考旧 Flutter 项目补齐合格 Flutter 工程应具备的路由、网络、认证、状态、模型、缓存、错误处理和平台能力。

## 1. 项目定位

当前项目路径：`/Users/john/Documents/trae_projects/flutter_ui_project`

项目目标：

- 以现有 m1 高仿 Flutter UI 为基础接入真实业务。
- 页面业务逻辑按 m1 项目映射，包括初始化、表单提交、接口调用顺序、弹窗状态、跳转参数、分页、登录拦截和多语言 key。
- 工程能力参考旧 Flutter 项目，但按当前项目架构重新落地，不整包复制旧实现。
- 建立稳定的路由、网络、认证、状态、模型、主题、组件、缓存、错误处理和国际化底座。
- 避免旧 Flutter 项目中的 Token 混乱、响应兼容堆叠、日志泄露、状态分散和接口重复请求问题。
- 保留已完成的 m1 高仿 UI 成果，不因接口对接推倒重做页面。

不建议在旧项目 `flutter-v1` 中直接替换新 UI。当前项目的视觉体系、页面结构和组件拆分已经独立成型，应在当前项目中补齐业务架构。对接页面逻辑时不要按旧 Flutter 项目页面行为迁移；旧 Flutter 项目只能帮助判断 Flutter 工程实现方式，例如 Service/Provider 拆分、模型解析、缓存、错误处理和平台差异。

## 1.1 参考源边界

| 参考源 | 用途 | 禁止事项 |
| --- | --- | --- |
| 当前 `flutter_ui_project` | 最终 Flutter 主工程 | 承载 m1 高仿 UI、业务对接代码和上线工程能力 | 不因业务对接推倒重做已完成 UI |
| `/Users/john/Documents/trae_projects/bw-v3-504/src/projects/m1` | UI 和页面逻辑来源 | 页面视觉意图、页面生命周期、接口入参、路由参数、跳转规则、状态处理、多语言 key | 不直接复制 Vue template/CSS 重写 Flutter |
| `/Users/john/Documents/trae_projects/flutter-v1` | Flutter 工程能力参考 | 网络封装、Provider/Service/Model 组织、缓存、错误处理、平台适配和踩坑经验 | 不作为页面对接逻辑来源，不整包复制，不继承旧问题 |

## 2. 技术栈规范

### 2.1 当前基础依赖

项目当前 `pubspec.yaml` 已包含：

| 依赖 | 当前用途 | 规范 |
| --- | --- | --- |
| `go_router` | 声明式路由 | 保留，统一管理页面跳转、重定向和登录拦截 |
| `provider` | 状态管理 | 短期保留，业务复杂后再评估 Riverpod |
| `easy_localization` | 多语言 | 保留，语言资源集中放在 `assets/i18n/` |
| `flutter_screenutil` | 设计稿适配 | 保留，继续使用 `.w`、`.h`、`.sp`、`.r` |
| `flutter_svg` | SVG 资源渲染 | 保留，图标和插画优先使用 SVG |
| `google_fonts` | 字体加载 | 保留或按设计稿改为本地字体 |

版本基线：

```yaml
environment:
  sdk: '>=3.3.0 <4.0.0'
```

### 2.2 业务阶段建议新增依赖

进入接口联调前建议新增：

```yaml
dependencies:
  dio: ^5.9.2
  dio_smart_retry: ^7.0.1
  flutter_secure_storage: ^10.0.0
  shared_preferences: ^2.5.4
  cached_network_image: ^3.4.1
  json_annotation: ^4.11.0

dev_dependencies:
  build_runner: ^2.12.2
  json_serializable: ^6.13.0
```

新增依赖规则：

- 能用现有依赖解决的问题，不新增依赖。
- 新依赖必须解决明确工程问题，例如网络、缓存、序列化、安全存储。
- UI 小效果不允许随意引入大型动画或组件库。
- 同类能力只允许一个主方案，例如网络统一用 `dio`，不混用多个 HTTP 客户端。

### 2.3 状态管理路线

短期继续使用 `provider`，原因是当前项目已经引入且 UI 阶段依赖简单。

中长期如果业务模块扩展到登录、钱包、游戏、消息、分页、缓存、用户资料等复杂状态，可以迁移到 `flutter_riverpod`。迁移必须作为单独架构任务执行，不允许在同一阶段同时混写两套风格。

Provider 使用规则：

- 页面只监听自己需要的状态。
- 全局状态放在模块 Provider 中，不放在 Widget 本地变量中。
- Provider 负责状态和流程编排，不直接写 UI。
- Service 负责接口调用，不持有 UI 状态。
- 不在 `build()` 中发起网络请求。

## 3. 推荐目录结构

当前项目已有 `router/`、`screens/`、`theme/`、`widgets/`。业务阶段建议逐步演进为：

```text
lib/
  main.dart
  app.dart
  router/
    app_router.dart
    route_paths.dart
  api/
    dio_client.dart
    request_cache_manager.dart
    interceptors/
      auth_interceptor.dart
      error_interceptor.dart
      cache_interceptor.dart
  models/
    core/
      api_response.dart
      paginated_response.dart
    auth/
    user/
    home/
    game/
    wallet/
  services/
    auth/
    user/
    home/
    game/
    wallet/
  providers/
    auth/
    user/
    home/
    game/
    wallet/
    system/
  screens/
    splash/
    auth/
    home/
    game/
    wallet/
    personal/
    info/
  widgets/
    common/
    layout/
    ui/
  theme/
    app_theme.dart
    app_colors.dart
    app_spacing.dart
    app_text_styles.dart
    app_radius.dart
  utils/
    auth_helper.dart
    toast_utils.dart
    constants.dart
  i18n/
```

目录规则：

- `screens/` 只放页面级 Widget。
- `widgets/` 只放可复用组件，不写接口请求。
- `providers/` 放业务状态、加载状态、分页状态和流程编排。
- `services/` 只负责调用 API，不依赖 `BuildContext`。
- `models/` 只负责数据结构和 JSON 解析。
- `api/` 只放网络底座、拦截器、缓存、错误归一化。
- `theme/` 只放视觉 token，不放业务状态。
- `utils/` 只放无状态工具，不放复杂业务流程。
- 新模块必须按业务域归档，例如 `auth`、`game`、`wallet`、`user`。

### 3.1 数据模型更新规则

数据模型必须跟随 m1 页面逻辑逐步校准，不能一次性全量迁移所有 m1 字段，也不能长期用 `Map<String, dynamic>` 绕过模型层。

原则：

- 页面接到哪里，模型更新到哪里。
- m1 `views/**` 实际读取的字段优先进入对应 Model。
- m1 `api/**` 中用于兼容响应结构、分页、状态判断和金额计算的字段必须进入 Model 或 Service 解码逻辑。
- 接口文档存在但当前页面未使用的字段可以暂缓，不为未知需求提前膨胀模型。
- 不确定类型的字段可先用 `dynamic`，但必须集中在 Model 层处理，不能散落在 Screen。
- 响应结构兼容逻辑放在 `fromJson`、`fromResponse` 或 Service decoder 中，不放在 Widget。
- Provider 保存强类型状态，例如 `UserProfile`、`VipOverview`、`GameListPage`，不保存裸 `Map` 作为长期方案。

建议更新顺序：

1. 认证和用户模型：`AuthToken`、`LoginRequest`、`RegisterRequest`、`UserProfile`。
2. 启动和首页模型：`HomeConfig`、`SiteConfig`、`BannerModel`、`NoticeModel`。
3. VIP 模型：`VipOverview`、`VipLevel`，保留 `total_deposit` 和 `total_bet` 等 m1 计算字段。
4. 游戏模型：分类、游戏列表、推荐游戏、进入游戏结果。
5. 钱包和记录模型：中心钱包、场馆余额、资金记录、转账记录、游戏记录。
6. 活动模型：活动分类、列表、详情、申请记录。
7. 资金模型：银行卡、充值通道、充值订单、提现规则、提现结果。

## 4. 分层架构规则

统一调用链：

```text
Screen / Widget
  -> Provider / Controller
    -> Service
      -> DioClient
        -> API
```

禁止：

- Widget 直接调用 `Dio`。
- Widget 直接拼接 Token。
- Widget 直接解析复杂 JSON。
- Widget 直接维护跨页面业务状态。
- Service 直接弹 Toast 或跳路由。
- Provider 中写大段 UI 组装逻辑。

允许：

- Widget 读取 Provider 状态并展示 loading、empty、error、data。
- Provider 调用 Service 并处理状态切换。
- Service 返回 Model 或统一的 Result 类型。
- Interceptor 统一注入 Token、语言、设备信息和处理认证失效。

## 5. 编码规则

### 5.1 Dart 与 Flutter 规则

- 遵守 `flutter_lints`。
- 文件名使用 `snake_case.dart`。
- 类名使用 `UpperCamelCase`。
- 变量和方法使用 `lowerCamelCase`。
- 常量优先使用 `const`。
- 不写无意义注释，只在复杂流程前写简短解释。
- 不在业务代码硬编码颜色、间距、圆角、字体大小，优先使用 `theme/` 中的 token。
- 不在业务代码硬编码 asset 路径，后续应建立 `AppAssets` 或同类映射。
- 页面 Widget 尽量保持薄层，复杂区块拆成私有小 Widget 或 `widgets/` 复用组件。

### 5.2 UI 规则

- 已完成的高保真 UI 不应为了接接口而破坏视觉结构。
- 长文本必须处理 `maxLines`、`overflow` 或 `Flexible`。
- Row 内文本默认考虑溢出风险，必要时使用 `Expanded` 或 `Flexible`。
- 大列表必须使用 `ListView.builder`、`GridView.builder`、`SliverList` 或 `SliverGrid`。
- 页面底部固定按钮必须考虑安全区和小屏高度。
- 图片必须有 placeholder、error 状态和明确宽高。
- 弹窗、Toast、Loading 样式必须统一封装。

### 5.3 国际化规则

- 所有面向用户的文案都应进入多语言资源。
- 禁止在业务页面散落大量中文硬编码，临时 Mock 文案除外。
- 语言切换由全局入口管理，不允许单页面私自维护语言状态。
- 接口请求头中的语言参数由拦截器统一注入。

### 5.4 日志规则

Debug 可打印必要调试信息，Release 禁止打印敏感信息。

禁止打印：

- access token
- refresh token
- 登录密码
- 验证码
- 用户资料完整 response
- 支付链接
- 提现、转账请求体

`Dio LogInterceptor` 只能在 debug 模式开启。

### 5.5 Git 协作规则

- 不主动执行任何会改变 Git 历史或远端状态的操作。
- 不主动 `git add`、`git commit`、`git push`、`git pull`、`git merge`、`git rebase`、`git reset`、`git checkout`。
- 只有在收到明确指令时，才允许执行对应 Git 操作。
- 查看状态类命令如 `git status`、`git diff` 仅用于确认工作区情况，不代表可以主动提交或推送。
- 工作区存在用户或其他 Agent 的改动时，不允许擅自回滚、覆盖或整理。

## 6. 路由规范

路由统一由 `go_router` 管理。

规则：

- 路径常量集中放在 `route_paths.dart`。
- 页面注册集中放在 `app_router.dart`。
- 登录拦截通过 `redirect` 或统一守卫处理。
- 需要登录的页面必须明确标记或归入受保护路由列表。
- 跳转参数使用明确字段，不传递复杂可变对象。
- 自定义转场统一封装，不在每个页面重复写动画。

路由登录拦截必须满足：

- 未登录访问受保护页面时跳登录页。
- 登录成功后可以回到原目标页。
- Token 失效时清理状态并跳登录页。
- 防止多个 401 同时触发重复跳转。

## 7. 网络层规范

### 7.1 DioClient

网络底座应统一封装：

- `baseUrl`
- 超时时间
- 默认 headers
- Auth 拦截器
- Error 拦截器
- Cache 拦截器
- Retry 策略
- Debug 日志

业务模块不能自行创建新的 `Dio()` 实例。

### 7.2 统一响应模型

建议建立：

```dart
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;
}
```

分页建议建立：

```dart
class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;
}
```

规则：

- Service 层负责把 response 转成 Model。
- Provider 不直接解析深层 JSON。
- 页面不处理后端字段兼容。
- 后端响应结构不统一时，在 Service 或 Model 层集中归一化。

### 7.3 错误处理

错误分层：

- 网络错误：断网、超时、DNS、证书。
- HTTP 错误：401、403、404、500。
- 业务错误：后端 `code` 非成功。
- 解析错误：字段缺失、类型不匹配。

处理规则：

- Interceptor 处理全局认证失效和通用网络错误。
- Provider 维护页面级错误状态。
- Widget 只展示错误，不判断复杂错误来源。
- 资金、支付、安全相关错误必须保留后端原始提示，不随意改写。

## 8. Token 与登录态规范

Token 是最高风险模块，必须从一开始统一。

### 8.1 Token key

只允许一个定义来源：

```dart
class AuthStorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
}
```

禁止混用：

```text
token
access_token
auth_token
```

### 8.2 存储策略

- iOS/Android：优先使用 `FlutterSecureStorage`。
- Web：使用 `SharedPreferences` 或 Web 专用方案，但必须意识到 XSS 风险。
- Token 不能分散写入多个存储位置。
- 登录态不能只存在内存，启动时必须恢复。

启动流程：

```text
本地 Token -> authProvider.init() -> 路由守卫 -> 请求拦截器
```

### 8.3 Token 注入

所有接口请求禁止手动写：

```dart
headers: {'Authorization': 'Bearer xxx'}
```

必须由 `AuthInterceptor` 统一注入：

```dart
options.headers['Authorization'] = 'Bearer $token';
```

Authorization 格式需要和后端确认：

- `Bearer <token>`
- 纯 token
- `token` header
- 自定义 header

### 8.4 登录失效判断

不能只依赖 HTTP 401。需要同时判断：

- HTTP status：`401`、`403`
- 业务 code：`401`、`403` 或约定登录失效 code
- message：`token`、`登录`、`认证`、`鉴权`、`unauthorized`、`forbidden`、`过期`

### 8.5 401 重定向锁

多个接口同时过期时，只能触发一次登出和跳转。

必须有类似机制：

```dart
bool isRedirecting = false;
```

流程：

1. 第一个 401 进入处理。
2. 加锁。
3. 清 Token。
4. 清登录状态。
5. 弹一次提示。
6. 跳登录页。
7. 延迟释放锁。

### 8.6 忽略全局 401 的接口

登出、登录、注册、刷新 Token 接口不应再次触发全局登出。

建议维护：

```dart
const authIgnoredPaths = [
  '/user/login',
  '/user/register',
  '/token/logout',
  '/user/logout',
  '/token/refresh',
];
```

### 8.7 Refresh Token

Refresh Token 要么不做，要做完整。

完整流程：

1. access token 过期。
2. 检查是否已有 refresh 请求进行中。
3. 没有则发起 refresh。
4. refresh 成功后更新本地 access token。
5. 重放原请求。
6. refresh 失败才强制登出。

禁止只写一个 `refreshToken()` 方法但没有并发控制和原请求重放。

## 9. 性能规范

### 9.1 请求时机

禁止在 `build()` 中发请求。

允许请求位置：

- Provider 初始化。
- StatefulWidget 的 `initState()`。
- 用户手动刷新。
- 分页加载更多。
- 路由进入时的一次性初始化。

### 9.2 列表与分页

大列表必须 builder 化。

分页状态必须包含：

- `items`
- `currentPage`
- `lastPage`
- `isLoading`
- `hasMore`
- `error`

加载更多前必须判断：

```dart
if (isLoading || !hasMore) return;
```

### 9.3 图片

后续应统一封装 `AppNetworkImage` 或同类组件。

能力要求：

- 自动补全资源域名。
- 自动处理 `//` 协议。
- 支持本地 asset。
- 移动端使用缓存图片。
- Web 端处理跨域和渲染问题。
- 支持 placeholder 和 error widget。
- 支持宽高参数，避免加载超大原图。

列表中禁止直接大量使用 `Image.network`。

### 9.4 请求缓存与去重

请求缓存优先对 GET 生效。

建议：

- 首页配置、分类、详情、列表查询优先使用 GET。
- 资金、余额、支付、用户敏感数据谨慎缓存。
- POST 读接口如需缓存，必须把 body 纳入 cache key。
- 公共数据放 Provider，共享给多个组件。
- 网络层可以做 pending request 去重。

### 9.5 Provider 监听范围

不要在首页顶层监听所有状态。

推荐：

- Header 自己监听用户信息。
- 游戏列表自己监听游戏列表。
- 钱包卡片自己监听余额。
- 父页面只负责布局。

### 9.6 搜索

实时搜索必须 debounce。

规则：

- debounce 300ms 到 500ms。
- 空关键词不请求。
- 新请求发出后忽略旧响应。
- 搜索结果分页。
- 搜索历史限制数量。

### 9.7 启动初始化

首屏初始化必须有 timeout，例如 5 秒。

初始化项：

- 语言
- 主题
- 登录态
- 基础配置

失败后允许进入 App，再局部显示错误，不应无限卡在启动页。

### 9.8 deferred loading

适合延迟加载：

- 游戏大厅
- WebView 游戏页
- 支付页
- 活动详情
- 富文本页面
- 大型记录页

不适合延迟加载：

- Splash
- 登录页
- 首页首屏
- 核心 Tab 外壳

## 10. 业务开发流程

建议按以下顺序推进：

### 阶段一：工程底座

- 建立业务目录结构。
- 建立 `DioClient`。
- 建立统一响应模型。
- 建立错误模型。
- 建立 Token 存储。
- 建立 Auth 拦截器。
- 建立错误、空状态、骨架屏组件。

### 阶段二：认证系统

- 登录接口。
- 注册接口。
- 忘记密码接口。
- Token 存储和恢复。
- 请求头自动注入 Token。
- 401 全局处理。
- 登录路由拦截。

### 阶段三：首页

- 首页配置接口。
- Banner。
- 公告。
- 游戏分类。
- 推荐游戏。
- 图片优化。
- 骨架屏。

### 阶段四：游戏模块

- 游戏分类。
- 游戏列表分页。
- 收藏。
- 游戏启动。
- WebView 容器。
- 登录态拦截。

### 阶段五：钱包和用户模块

- 用户信息。
- 余额。
- 充值。
- 提现。
- 转账。
- 资金记录。
- 投注记录。
- 通知中心。

### 阶段六：性能和发布检查

- 检查所有列表是否 builder 化。
- 检查图片是否统一封装。
- 检查是否存在 build 中请求。
- 检查 release 日志。
- 检查 Token 过期流程。
- 检查首屏时间。
- 检查 Web 和移动端适配。

## 11. 验收与命令

安装依赖：

```bash
flutter pub get
```

静态分析：

```bash
flutter analyze
```

运行测试：

```bash
flutter test
```

运行 Web：

```bash
flutter run -d chrome
```

构建 Web：

```bash
flutter build web
```

如引入 `json_serializable` 或其他代码生成：

```bash
dart run build_runner build --delete-conflicting-outputs
```

每个业务模块完成前必须至少检查：

- `flutter analyze` 无错误。
- 关键页面无 RenderFlex overflow。
- 登录态恢复正常。
- Token 失效流程正常。
- 空状态、错误状态、加载状态齐全。
- Release 不输出敏感日志。

## 12. 旧项目经验取舍

值得复用的能力：

| 能力 | 旧项目参考 | 新项目处理 |
| --- | --- | --- |
| Dio 单例客户端 | `lib/api/dio_client.dart` | 迁移思想，按新项目重写 |
| Token 注入 | `auth_interceptor.dart` | 必须保留 |
| 统一错误处理 | `error_interceptor.dart` | 必须保留，但要精简 |
| 请求缓存和去重 | `request_cache_manager.dart` | 推荐保留思想 |
| 登录状态恢复 | `auth_provider.dart` | 必须保留 |
| 路由登录拦截 | `app_router.dart` | 必须保留 |
| 跨端图片处理 | `web_safe_image.dart` | 推荐重写为新组件 |
| 骨架屏、空状态、错误状态 | `widgets/common/` | 推荐保留思想 |
| 分页状态 | `game_provider.dart` | 列表模块复用模式 |

不应照搬的问题：

- Token key 存在 `token` 和 `access_token` 混用风险。
- 登出接口排除路径和实际路径不完全一致，可能导致 401 循环。
- Service 中存在大量响应结构兼容代码。
- 调试日志打印用户信息、请求参数、游戏 URL。
- POST 读接口过多，导致 GET 缓存收益有限。
- 错误页在开发期显示 stack trace，生产环境不能照搬。
- Provider 写法同时存在手写和注解生成，新项目要统一。

## 13. 总结原则

- 当前项目是新业务前端主工程，不是旧项目代码仓库的复制品。
- UI 层和业务层必须分离。
- Token 只允许一个入口读写。
- 网络错误只允许一个入口统一处理。
- 页面不直接调用 Dio。
- 页面不直接拼 Token。
- 页面不直接解析复杂 JSON。
- 大列表必须分页和 builder 化。
- 图片必须统一封装。
- Release 不能输出敏感日志。
- 先稳定架构，再批量接页面。
