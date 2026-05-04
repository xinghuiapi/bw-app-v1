# Engineering Businessization Plan

本文档记录 `flutter_ui_project` 从 m1 高仿 Flutter UI 工程演进为可上线业务前端主工程的实施计划。当前阶段已经进入接口和工程能力对接期：在保留 m1 高仿 UI 的前提下，按 m1 页面逻辑接入真实业务，并参考旧 Flutter 项目补齐工程能力。

关联文档：

- 架构规范：`.opencode/docs/NEW_FRONTEND_ARCHITECTURE_GUIDE.md`
- 接口对接顺序：`.opencode/docs/API_INTEGRATION_SEQUENCE.md`
- 接口文档：`.opencode/docs/bw-pc-api-v2（适配h5）接口文档.md`
- 页面逻辑参考：`/Users/john/Documents/trae_projects/bw-v3-504/src/projects/m1`
- 工程实现参考：`/Users/john/Documents/trae_projects/flutter-v1`

## 1. 当前状态

当前项目已经具备：

- 按 m1 项目制作的高仿 Flutter UI 页面和基础组件。
- `go_router` 路由基础。
- `theme/` 视觉 token 基础。
- `widgets/` 通用 UI 组件基础。
- `models/` 业务模型基础。
- 新接口文档和接口对接顺序文档。
- 基础网络、认证、Provider、Service 和部分真实接口接入能力。

当前项目主要待补齐：

- 部分业务服务层 `services/` 尚为空壳，需要按 m1 页面逻辑逐步补齐。
- 部分状态层 `providers/` 尚为空壳，需要接入真实加载、刷新、分页、错误和 fallback 状态。
- 环境配置、构建配置和平台能力仍需继续完善。
- Loading、Empty、Error、Skeleton、NetworkImage 等业务状态组件需按页面持续落地。
- 请求缓存、去重、分页、搜索 debounce 等性能策略需按业务模块补齐。
- 表单校验、资金操作防重复提交、Release 日志管控等上线安全能力。
- 部分页面仍有 Mock 状态，需按 m1 页面逻辑映射真实接口和状态流。

## 2. 实施原则

- 先工程底座，再接口对接。
- 先只读链路，再写操作链路。
- 先无资金风险模块，再资金相关模块。
- 保留当前 m1 高仿 UI，不因业务接入破坏视觉结构。
- 当前项目按自身架构落地工程能力，不整包复制任何旧项目。
- 页面业务对接逻辑以 m1 项目为准，包括页面初始化、接口调用、表单入参、路由参数、登录拦截、弹窗和状态处理。
- 旧 Flutter 项目只复用工程实现经验，不复用页面对接逻辑，也不复用旧问题。
- 每个阶段必须能独立验证，不做不可回退的大批量改造。
- 不主动执行 Git 更新类操作，必须等待明确指令。

## 3. 目标目录结构

业务化完成后建议目录：

```text
lib/
  api/
    dio_client.dart
    api_exception.dart
    request_cache_manager.dart
    interceptors/
      auth_interceptor.dart
      error_interceptor.dart
      cache_interceptor.dart
  config/
    app_env.dart
    api_endpoints.dart
  models/
  services/
    auth/
    home/
    user/
    game/
    wallet/
    activity/
    content/
  providers/
    auth/
    system/
    home/
    user/
    game/
    wallet/
    activity/
    message/
    record/
  router/
    app_router.dart
    route_paths.dart
  screens/
  theme/
  utils/
    auth_helper.dart
    toast_utils.dart
    formatters.dart
    validators.dart
  widgets/
    common/
      app_loading.dart
      app_empty.dart
      app_error.dart
      app_skeleton.dart
      app_network_image.dart
      app_paged_list.dart
    layout/
    ui/
```

## 4. Phase 0: 基线盘点

目标：确认当前项目、m1 页面逻辑和旧 Flutter 工程能力之间的差距，避免边做边补导致架构发散。

任务：

- 盘点当前 `screens/` 页面与接口模块的对应关系。
- 盘点当前所有页面中的 Mock 数据来源。
- 盘点当前所有列表是否已经 builder 化。
- 盘点当前所有网络图片、远程图片、HTML 内容入口。
- 盘点当前路由中哪些页面需要登录保护。
- 建立接口到 Service、Provider、Screen 的映射表。

产物：

- 页面业务映射表。
- Mock 数据清单。
- 受保护路由清单。
- 性能风险清单。

验收标准：

- 每个页面明确属于哪个业务模块。
- 每个页面明确后续是否接接口。
- 每个登录态页面明确拦截策略。

## 5. Phase 1: 工程底座

目标：建立可承载业务请求的基础架构，但不绑定页面。

任务：

- 新增环境配置能力，区分开发、测试、生产 baseUrl。
- 新增 `api/` 网络层。
- 新增 `ApiException` 和统一错误类型。
- 新增 `DioClient`。
- 新增 Auth、Error、Cache Interceptor。
- 新增请求超时、重试、日志开关策略。
- 新增 `api_endpoints.dart` 管理接口路径。
- 建立 Service 返回模型的统一规范。

注意事项：

- 业务页面不能直接使用 `Dio`。
- Release 禁止打印 token、密码、验证码、用户资料、支付链接和提现参数。
- 网络层只负责通用能力，不写页面跳转和 Toast。

验收标准：

- 可以用 Service 通过统一 client 发请求。
- Debug 日志可控，Release 无敏感日志。
- 网络错误、业务错误、解析错误有明确类型。

## 6. Phase 2: 登录态与路由保护

目标：把 Token 生命周期做成唯一可信入口。

任务：

- 新增 Token 存储封装。
- 统一 Token key，例如 `access_token`。
- 新增 `AuthProvider`。
- 实现 App 启动时恢复登录态。
- 实现请求头自动注入 Token。
- 实现 401 或登录失效业务 code 的统一处理。
- 实现 401 重定向锁，避免重复弹窗和重复跳转。
- 建立受保护路由列表。
- 登录成功后支持回跳原目标页。

注意事项：

- Refresh Token 要么不做，要做完整并发控制和原请求重放。
- 登录、注册、退出、刷新 Token 接口应进入全局 401 忽略列表。
- 页面不允许手写 Authorization header。

验收标准：

- 关闭 App 后再次启动能恢复登录态。
- Token 失效后只触发一次登出流程。
- 未登录访问受保护页面会被正确拦截。
- 登出后用户资料、余额、消息等敏感状态被清理。

## 7. Phase 3: 通用业务状态组件

目标：所有业务页面具备一致的加载、空态、错误和重试体验。

任务：

- 新增 `AppLoading`。
- 新增 `AppSkeleton`。
- 新增 `AppEmpty`。
- 新增 `AppError`。
- 新增 `AppNetworkImage`。
- 新增 `AppPagedList` 或分页状态 mixin。
- 统一 Toast 和 Dialog 使用入口。

`AppNetworkImage` 必须支持：

- 自动补全资源域名。
- 处理 `//` 协议图片地址。
- placeholder。
- error widget。
- 明确宽高。
- 移动端缓存图片。
- Web 端兼容处理。

验收标准：

- 接口异常时页面不白屏。
- 图片失败时有统一兜底。
- 列表空数据有统一空态。
- 页面 loading 不破坏高保真布局。

## 8. Phase 4: Service 与 Provider 分层

目标：建立业务模块调用链，页面只消费状态，不直接处理接口细节。

调用链：

```text
Screen / Widget
  -> Provider
    -> Service
      -> DioClient
        -> API
```

优先建立的 Service：

- `AuthService`
- `HomeService`
- `UserService`
- `GameService`
- `WalletService`
- `ActivityService`
- `ContentService`

优先建立的 Provider：

- `AuthProvider`
- `SystemProvider`
- `HomeProvider`
- `UserProvider`
- `GameProvider`
- `WalletProvider`
- `RecordProvider`
- `ActivityProvider`
- `MessageProvider`

Provider 状态必须包含：

- `isLoading`
- `error`
- `data`
- `isRefreshing`，如页面支持刷新
- `isSubmitting`，如页面有提交动作

分页状态必须包含：

- `items`
- `currentPage`
- `lastPage`
- `hasMore`
- `isLoadingMore`
- `loadMoreError`

验收标准：

- 页面不直接解析复杂 JSON。
- 页面不直接调用 Service 以外的网络能力。
- Provider 不写 UI 组装逻辑。
- Service 不依赖 `BuildContext`。

## 9. Phase 5: 核心只读业务接入

目标：先接入低风险只读接口，让页面具备真实数据来源。

顺序：

1. 全局配置、语言、币种、注册配置。
2. 首页 Banner、公告、推荐游戏。
3. 用户信息、VIP 信息。
4. 游戏分类、二级分类、子游戏列表。
5. 活动分类、活动列表、活动详情。
6. 卡包、充值分类、充值通道、提现基础信息。
7. 充值记录、提现记录、注单记录、帐变记录。

验收标准：

- 页面可从 Mock 数据平滑切换到接口数据。
- 接口失败时保留 fallback，不影响基本浏览。
- 列表支持刷新、分页、空态、错误态。

## 10. Phase 6: 写操作与资金链路

目标：在只读链路稳定后接入高风险写操作。

顺序：

1. 修改用户资料。
2. 修改登录密码。
3. 设置或修改支付密码。
4. 绑定银行卡或虚拟币地址。
5. 提交充值。
6. 上传充值凭证。
7. 取消充值。
8. 确认提现。
9. 手动转入、手动转出。
10. 领取反水、领取返利。

资金操作必须具备：

- 表单校验。
- 金额精度处理。
- 提交中防重复点击。
- 成功后刷新余额和记录。
- 失败后展示后端原始提示。
- 不记录敏感请求参数。

验收标准：

- 重复点击不会重复提交订单。
- 提交失败不会导致本地状态错误。
- 支付、提现、转账状态刷新可靠。

## 11. Phase 7: 性能治理

目标：避免业务接入后出现卡顿、重复请求、首屏慢和内存压力。

任务：

- 检查所有长列表是否 builder 化。
- 对游戏列表、记录列表、活动列表统一分页。
- 首页配置、分类、公告等 GET 接口启用缓存。
- 对重复请求做 pending request 去重。
- 搜索接口增加 300ms 到 500ms debounce。
- Provider 监听范围下沉到局部组件。
- 网络图片统一走 `AppNetworkImage`。
- 首屏初始化设置 timeout，例如 5 秒。
- 对游戏大厅、支付页、活动详情、富文本页评估 deferred loading。

验收标准：

- 首页不会重复请求同一配置接口。
- 大列表滚动无明显卡顿。
- 首屏初始化失败不会无限卡住。
- 搜索不会每个字符都立即请求接口。

## 12. Phase 8: 稳定性与发布质量

目标：进入可验收、可测试、可发布状态。

任务：

- 检查所有接口错误状态。
- 检查所有空数据状态。
- 检查所有资金操作的重复提交保护。
- 检查登录失效和路由回跳。
- 检查 Release 日志。
- 检查小屏和 Web 适配。
- 检查多语言长文本溢出。
- 检查 RenderFlex overflow。
- 执行 `flutter analyze`。
- 执行必要测试。
- 执行 Web 构建验证。

验收标准：

- `flutter analyze` 无错误。
- 核心页面无 RenderFlex overflow。
- 弱网、断网、超时有可恢复状态。
- Release 不输出敏感日志。
- Web 和移动端关键页面都能正常加载。

## 13. 优先级路线图

P0：工程必需

- 环境配置。
- 网络层。
- Token 存储和恢复。
- 认证拦截器。
- 错误处理。
- 路由登录保护。
- Auth、System、Home 基础 Provider。
- Loading、Empty、Error、NetworkImage。

P1：业务主链路

- 首页真实数据。
- 登录注册真实流程。
- 用户信息和 VIP。
- 游戏分类、列表、启动。
- 钱包只读数据。
- 活动列表和详情。
- 分页、刷新、缓存。

P2：高风险与增强

- 充值、提现、转账。
- 上传凭证。
- 反水、返利。
- 搜索优化。
- deferred loading。
- 更完整测试和发布检查。

## 14. 不迁移旧项目的问题

旧项目以下问题不能带入新项目：

- Token key 混用。
- Service 中堆叠大量 response 兼容逻辑。
- 页面或 Service 打印敏感日志。
- POST 读接口无缓存策略。
- Provider 写法混杂。
- 开发错误页在生产显示 stack trace。
- 登出、登录失效路径处理不一致。
- Widget 直接处理复杂接口字段。

## 15. 开始实施前置条件

只有满足以下条件后，才建议开始实际工程化改造：

- 用户明确要求开始实施。
- 确认是否新增 `dio`、`flutter_secure_storage`、`shared_preferences`、`cached_network_image` 等依赖。
- 确认 baseUrl 和环境规则。
- 确认 Token header 格式。
- 确认登录失效业务 code。
- 确认 Web 与移动端的存储策略。
- 确认先做 P0，不直接批量接业务接口。

## 16. 2026-04-30 工程底座实施记录

本次实施范围：按用户要求开始实际工程化改造，优先完成 P0 / Phase 1 工程底座；不接真实页面接口，不替换页面 Mock 数据，不改造业务页面逻辑，不执行 Git 提交或推送。

### 16.1 已新增依赖

`pubspec.yaml` 已新增：

- `dio`
- `dio_smart_retry`
- `flutter_secure_storage`
- `shared_preferences`
- `cached_network_image`

本次未新增 `build_runner`、`json_serializable`、`json_annotation`，原因是当前阶段只搭建网络与状态底座，尚未进入接口模型生成和批量序列化阶段。

### 16.2 已落地目录与文件

环境与接口配置：

- `lib/config/app_env.dart`
- `lib/config/api_endpoints.dart`

网络层：

- `lib/api/api.dart`
- `lib/api/dio_client.dart`
- `lib/api/api_exception.dart`
- `lib/api/token_storage.dart`
- `lib/api/request_cache_manager.dart`
- `lib/api/interceptors/auth_interceptor.dart`
- `lib/api/interceptors/error_interceptor.dart`
- `lib/api/interceptors/cache_interceptor.dart`

Service 分层骨架：

- `lib/services/base_service.dart`
- `lib/services/services.dart`
- `lib/services/auth/auth_service.dart`
- `lib/services/home/home_service.dart`
- `lib/services/user/user_service.dart`
- `lib/services/game/game_service.dart`
- `lib/services/wallet/wallet_service.dart`
- `lib/services/activity/activity_service.dart`
- `lib/services/content/content_service.dart`

Provider 分层骨架：

- `lib/providers/base_provider.dart`
- `lib/providers/paged_state.dart`
- `lib/providers/providers.dart`
- `lib/providers/auth/auth_provider.dart`
- `lib/providers/system/system_provider.dart`
- `lib/providers/home/home_provider.dart`
- `lib/providers/user/user_provider.dart`
- `lib/providers/game/game_provider.dart`
- `lib/providers/wallet/wallet_provider.dart`
- `lib/providers/activity/activity_provider.dart`
- `lib/providers/message/message_provider.dart`
- `lib/providers/record/record_provider.dart`

通用业务状态组件：

- `lib/widgets/common/common.dart`
- `lib/widgets/common/app_loading.dart`
- `lib/widgets/common/app_empty.dart`
- `lib/widgets/common/app_error.dart`
- `lib/widgets/common/app_skeleton.dart`
- `lib/widgets/common/app_network_image.dart`
- `lib/widgets/common/app_paged_list.dart`

路由底座：

- `lib/router/route_paths.dart`
- `lib/main.dart` 已注入基础 Provider。

测试：

- `test/widget_test.dart` 已从模板 Counter 测试调整为工程底座单元测试，验证受保护路由清单和 `ApiException` 类型信息。

### 16.3 当前能力

- 可通过 `AppEnv` 使用 `--dart-define` 配置环境、API 域名和资源域名。
- 可通过统一 `DioClient` 发起 GET / POST 请求。
- 网络层具备超时、一次重试、Auth 注入、缓存拦截、错误归一化和 Debug 日志开关。
- `ApiException` 已区分 network、timeout、http、unauthorized、business、parse、cancel、unknown。
- Token key 统一为 `access_token` 和 `refresh_token`。
- iOS / Android 使用 `FlutterSecureStorage`，Web 使用 `SharedPreferences`。
- Auth 拦截器统一注入 `Authorization: bearer <token>`，并保留 `token_type` 覆盖能力。
- Auth 拦截器已具备 401 / 403、业务 code 和常见登录失效 message 的基础判断。
- 已建立 `authIgnoredPaths`，避免登录、注册、登出、获取用户 Token 等接口触发重复全局登出。
- 已建立受保护路由清单 `protectedRoutePaths`，并已接入 `go_router.redirect` 登录保护和登录后回跳。
- 已建立 Loading、Empty、Error、Skeleton、NetworkImage、PagedList 通用组件。
- `AppNetworkImage` 支持完整 URL、`//` 协议 URL、相对路径资源域名补全、placeholder、error widget、明确宽高。

### 16.4 当前刻意不做的内容

- 不把任何页面 Mock 数据替换为接口数据。
- 不让页面直接调用 Service 或 Dio。
- 不接入真实登录、注册、钱包、游戏、活动等业务接口。
- 不启用 Refresh Token 原请求重放，因为文档要求“要么不做，要做完整”。
- 不在 Service 中加入大量接口响应兼容逻辑。
- 不新增代码生成链路，待接口模型稳定后再评估 `json_serializable`。

### 16.5 验证方式

依赖安装验证：

```bash
flutter pub get
```

代码格式验证：

```bash
dart format lib test
```

静态分析验证：

```bash
flutter analyze lib test
```

测试验证：

```bash
flutter test test/widget_test.dart
```

本次验证结果：

- `dart format lib test` 已执行通过。
- `flutter analyze lib test` 已执行通过，无错误。
- `flutter test test/widget_test.dart` 已执行通过，当前为 `6 tests passed`。

运行环境验证：

```bash
flutter run --dart-define=APP_ENV=development --dart-define=API_BASE_URL=http://45.200.16.18:60000/api
```

Web 构建验证：

```bash
flutter build web --dart-define=APP_ENV=production --dart-define=API_BASE_URL=http://45.200.16.18:60000/api
```

手工检查建议：

- 启动 App 后确认默认仍进入登录页。
- 从登录页点击“先去逛逛”确认仍可进入首页。
- 检查首页、游戏、活动、钱包、用户中心等静态页面视觉未因 Provider 注入而改变。
- 检查控制台 Debug 网络日志不会输出 request body、response body、token、密码、验证码等敏感信息。
- 如需验证 `AppNetworkImage`，可在临时页面或后续业务页面中分别传入完整 URL、`//example.com/a.png`、相对路径，确认 placeholder 和 error 兜底有效。

### 16.6 后续建议

下一阶段建议进入 Phase 2：登录态与路由保护，但仍应小步提交、单点验证。

优先确认：

- `APP_ENV` 枚举是否使用 `development`、`staging`、`production`。
- 开发、测试、生产 `API_BASE_URL`。
- 静态资源 `ASSET_BASE_URL`。
- Token header 是否确认为 `Authorization: Bearer <token>`。
- 登录失效业务 code 是否仅为 `401` / `403`，还是另有自定义 code。
- 登录、注册、退出、刷新 Token 等接口是否需要加入 401 忽略列表。
- Web 端 Token 存储是否接受 `SharedPreferences`，或需要改为更明确的 Web 专用策略。

Phase 2 建议任务：

- 将 `AuthProvider.init()` 纳入启动恢复流程的可视化状态。
- 接入 `go_router.redirect`，基于 `protectedRoutePaths` 做登录保护。
- 未登录访问受保护页面时跳转登录页，并携带原目标页用于登录后回跳。
- Token 失效时只触发一次 `clearAuth()` 和一次登录跳转。
- 登出后清理用户资料、余额、消息、钱包等敏感 Provider 状态。

Phase 3 建议任务：

- 将页面内零散 Loading、Empty、Error、网络图片逐步替换为 `widgets/common/` 统一组件。
- 为列表页面接入 `PagedState` 或后续分页 Provider 基类。
- 对搜索接口预留 300ms 到 500ms debounce。

Phase 4 建议任务：

- 从全局配置、语言、币种、Banner、公告等低风险只读接口开始接入。
- 每接一个接口，补齐 Service、Provider、Model 和页面 fallback。
- 接口失败时保留当前高保真 Mock UI 的安全兜底。

## 17. 2026-04-30 全局配置启动探针记录

### 17.1 本次任务目标

- 将开发域名切换为确认可用的 `https://apis.xh-demo.com`。
- 接入第一个低风险只读接口探针：`POST /system/getlist`。
- App Web 启动时验证真实接口链路可用，但不替换页面 Mock 数据，不改首页视觉结构。
- 清理 `flutter analyze lib test` 中已暴露的问题，保持后续接口对接前的工程基线干净。

### 17.2 已完成内容

环境配置：

- `lib/config/app_env.dart` 默认 `API_BASE_URL` 已改为 `https://apis.xh-demo.com/api`。
- `lib/config/app_env.dart` 默认 `ASSET_BASE_URL` 已改为 `https://apis.xh-demo.com`。
- `AppEnv.current` 已从 `static const` 改为 getter，避免 const 初始化非编译期常量问题。

全局配置接口：

- 新增 `lib/services/system/system_service.dart`。
- `SystemService.fetchConfig()` 使用 `POST /system/getlist`。
- 响应解析已处理接口文档中的双层结构：`data.data`。
- `/system/getlist` 已保持不追加 query `lang`，但仍注入 header `lang: CN`。
- 复用 `HomeConfig` 作为全局配置模型，避免重复创建系统配置模型。
- `LanguageConfig` 已补齐接口文档字段：`title`、`code`、`img`、`status_s`。

启动探针：

- `lib/main.dart` 已在 App 首帧后调用 `SystemProvider.loadConfig()`。
- Debug 模式下控制台输出启动探针结果，例如：

```text
[startup-probe] system config loaded: title=星汇演示11, languages=11, banners=3
```

- 该探针只用于验证真实接口连通性，不改变页面 UI，不替换首页 Banner、公告或站点信息。
- 用户已在 Web 环境验证探针通过。

Provider 状态：

- `SystemProvider` 已支持 `loadConfig({bool refresh = false})`。
- `SystemProvider.config` 提供安全 fallback，接口失败时返回空 `HomeConfig`。
- `SystemProvider` 维护 `isLoading`、`isRefreshing`、`error`、`hasLoadedConfig`。

质量修复：

- `TokenStorage` 已补齐 `@override`。
- 清理 `app_router.dart` 未使用 import。
- 修复若干 `prefer_final_fields`、`prefer_const_constructors`。
- 将 `withOpacity` 替换为 `withValues(alpha: ...)`。

### 17.3 验证结果

接口手工验证：

- 用户已通过 `curl` 验证 `https://apis.xh-demo.com/api/system/getlist` 有响应。
- 用户已通过 Web 启动验证 `[startup-probe]` 探针通过。

工程验证：

```bash
flutter analyze lib test
```

结果：

```text
No errors
```

```bash
flutter test test/widget_test.dart
```

结果：

```text
00:00 +6: All tests passed!
```

### 17.4 下次任务建议

下一次建议继续 Phase 2，只接低风险只读链路，不进入资金类和写操作接口。

优先级建议：

- 将启动探针沉淀为正式启动配置加载流程，保留失败 fallback。
- 让首页在不破坏高保真 UI 的前提下读取 `SystemProvider.config` 的站点标题、公告或 Banner 中的一项。
- 优先选择公告或 Banner 作为第一个页面可视化接口数据，因为它们来自同一个 `/system/getlist` 响应，风险低，不需要新增写操作。

下一次执行流程：

- 先查接口文档，确认字段、请求方式、认证和 `lang` 规则。
- 再查 m1 项目对应页面、API 和路由逻辑，确认页面对接行为。
- 旧 Flutter 项目只参考 Service、Provider、Model、缓存和错误处理等工程实现经验，不参考页面对接逻辑。
- 在新项目做最小实现，优先复用现有 `HomeConfig`、`SystemProvider`、通用组件。
- UI 接入必须有 fallback，接口失败时继续显示当前 m1 高仿 UI 的安全内容。
- 完成后运行 `dart format lib test`、`flutter analyze lib test`、`flutter test test/widget_test.dart`。

### 17.5 注意事项

- 当前启动探针会在 Debug 模式打印站点标题、语言数量和 Banner 数量，不打印 token、request body、response body 或用户敏感信息。
- Web 本地如果遇到 CORS，可继续使用旧项目同类方式临时启动：

```bash
flutter run -d chrome --web-browser-flag --disable-web-security --web-port 8080
```

- `--disable-web-security` 只能用于本地开发调试，生产 Web 必须由后端 CORS 或同域反代解决。

### 17.6 上下文压缩交接

当前项目状态：

- 工程底座、网络层、Service/Provider 骨架、通用状态组件和路由保护已经完成首轮落地。
- Phase 2 已启动，`/system/getlist` 是第一个真实接口探针，Web 已验证通过。
- 当前页面保持 m1 高仿 UI，部分低风险区域已开始接入真实接口数据，其余区域继续保留 fallback。
- 当前质量基线为 `flutter analyze lib test` 无错误、`flutter test test/widget_test.dart` 共 6 个测试通过。

关键工程规则：

- 成功响应只认 `code == 200`，`code == 0` 是业务失败。
- `401` / `403` 作为登录失效处理。
- Header 默认注入 `lang: CN`。
- 除 `/system/getlist` 外，接口默认追加 query `lang=CN`。
- Token Header 为 `Authorization: bearer <token>`，并支持存储的 `token_type` 覆盖。
- Debug 日志不得打印 token、密码、验证码、request body、response body、支付链接、提现参数等敏感信息。

下一轮最小可执行任务：

- 从首页公告或 Banner 中选择一个低风险区域接入 `SystemProvider.config`。
- 只替换一小块可视化数据，接口为空或失败时继续显示当前 m1 高仿 UI fallback。
- 不进入登录、注册、钱包、充值、提现、转账等写操作或资金相关接口。

下一轮开始前必须阅读：

- `.opencode/docs/API_INTEGRATION_SEQUENCE.md` 的“当前进度记录”和“下一次任务执行方式”。
- `.opencode/docs/bw-pc-api-v2（适配h5）接口文档.md` 中 `/system/getlist` 的字段结构。
- m1 项目 `/Users/john/Documents/trae_projects/bw-v3-504/src/projects/m1` 中首页公告或 Banner 的页面逻辑、API 调用和字段使用。
- 如需 Flutter 工程实现参考，再查旧 Flutter 项目 `/Users/john/Documents/trae_projects/flutter-v1` 中对应 Service/Provider/Model 写法，不参考旧 Flutter 页面逻辑。

下一轮完成标准：

- UI 不因接口失败白屏、不跳动、不破坏当前高保真布局。
- 保留 fallback 静态内容。
- 运行 `dart format lib test`、`flutter analyze lib test`、`flutter test test/widget_test.dart` 并记录结果。
