# Engineering Businessization Plan

本文档记录 `flutter_ui_project` 从 m1 高仿 Flutter UI 工程演进为可上线业务前端主工程的实施计划。当前阶段已经进入接口和工程能力对接期：在保留 m1 高仿 UI 的前提下，按 m1 页面逻辑接入真实业务，并参考旧 Flutter 项目补齐工程能力。

关联文档：

- 架构规范：`docs/NEW_FRONTEND_ARCHITECTURE_GUIDE.md`
- 接口对接顺序：`docs/API_INTEGRATION_SEQUENCE.md`
- 接口文档：`docs/bw-pc-api-v2（适配h5）接口文档.md`
- 页面逻辑参考：`/Users/john/Documents/trae_projects/bw-6-2/src/projects/m1`
- 工程实现参考：`/Users/john/Documents/trae_projects/flutter-v1`

**m1 术语约定**：本文档及本项目所有任务中，“m1”“m1 项目”或“bw-6-2 参考项目”均固定指向 `/Users/john/Documents/trae_projects/bw-6-2/src/projects/m1`，不得使用 bw-6-2 的其他子项目、旧 Flutter 项目或其他相似目录替代。

## 1. 当前状态

当前项目已经具备：

- 按 m1 项目制作的高仿 Flutter UI 页面和基础组件。
- `go_router` 路由基础。
- `theme/` 视觉 token 基础。
- `widgets/` 通用 UI 组件基础。
- `models/` 业务模型基础。
- 新接口文档和接口对接顺序文档。
- 基础网络、认证、Provider、Service 和部分真实接口接入能力。
- 发版工程已支持文档化品牌索引驱动的批量打包流程：通过 `brand_release/BRAND_RELEASE_INDEX.md` 维护 `domain/logo/app_name`，使用 `brand_release/package_all_brands.dart` 循环调用统一单品牌打包命令，并将 arm64-v8a APK 与 unsigned IPA 归档到 `brand_release/release_artifacts/品牌ID/`。
- m1 主体路由页面基本都有 Flutter 对应实现；当前已不是“大页面缺失”阶段。
- m1 主要 endpoint 已基本覆盖在 `ApiEndpoints`。
- 提现、删卡、分享返利、今日收益、返水领取、找回密码、Telegram 等收尾闭环所需的 service/model 已补齐。
- P0 核心业务闭环已完成一轮 `Provider -> Screen` 接入：提现提交、银行卡删除、找回密码、Telegram 登录、分享返利、游戏返水领取、我的页今日收益。
- 表单完整性已完成一轮 m1 517 对齐：提现取款密码输入、找回密码三方式、修改资金密码旧密码输入、兑换码页面和接口闭环已补齐。

当前项目主要待补齐：

- P0 已进入联调校准阶段，后续需要用真实账号验证后端响应字段、成功提示和边界错误。
- m1 右侧搜索弹窗、游戏最小化浮窗、公告富文本/图片/跳转、充值失败页已补齐并完成基础验证。
- 当前下一阶段开发重点为 P2：Telegram query 拦截、邀请/refcode 持久化、`/system/getlist` terminal 参数、活动详情语言参数和关键模型字段兼容校准已完成；上线安全硬化已启动，当前已补齐统一 URL policy、外链/支付/游戏/客服链接校验、游戏 WebView/iframe URL 拦截和禁用全局自动重试，后续继续真实账号冒烟、Web token 风险治理和部署安全策略。

## 1.1 当前任务目标

当前阶段目标：把 Flutter 工程从“m1 高仿 UI 已基本完成”推进到“m1 核心业务闭环可验收”。

验收重点：

- 资金：充值链路继续保持可用，提现提交和银行卡删除完成闭环。
- 账号：找回密码、Telegram 登录/设置密码形成真实提交闭环；找回密码已扩展为手机号、邮箱、真实姓名 + 取款密码三种方式，并补齐确认新密码与区号选择。
- 收益：分享返利、游戏返水领取、今日收益/未领取返水展示真实数据。
- 表单：提现页提交 `pay_password`、修改资金密码页校验旧取款密码、兑换码页接入提交和记录列表。
- 体验：搜索弹窗、公告弹窗、游戏最小化浮窗和充值失败页已补齐 m1 用户可感知差异。
- 工程：所有新接口按 `Model/Service/Provider/Screen` 分层落地，写操作具备 loading/error/success 和防重复提交。

## 2. 实施原则

- 先工程底座，再接口对接。
- 先只读链路，再写操作链路。
- 先无资金风险模块，再资金相关模块。
- 保留当前 m1 高仿 UI，不因业务接入破坏视觉结构。
- 当前项目按自身架构落地工程能力，不整包复制任何旧项目。
- 页面业务对接逻辑以 m1 项目为准，包括页面初始化、接口调用、表单入参、路由参数、登录拦截、弹窗和状态处理。
- 游戏一级分类列表图片布局以 bw-6-2 m1 `views/main/Game.vue` 的 `.provider-grid` / `.provider-cover` 为准；一级分类图片容器不设置固定高度或正方形比例，不能套用 `GameSubList.vue` 的正方形图片规则。
- 旧 Flutter 项目只复用工程实现经验，不复用页面对接逻辑，也不复用旧问题。
- 每个阶段必须能独立验证，不做不可回退的大批量改造。
- 不主动执行 Git 更新类操作，必须等待明确指令。

## 2.1 当前收尾执行步骤

1. **Provider 状态层**：P0 已完成一轮接入。
2. **页面按钮和数据展示**：P0 已替换静态值、空实现、`comingSoon` 和禁用按钮。
3. **写操作闭环**：P0 已具备提交前校验、提交中禁用、成功刷新相关数据、失败展示后端错误。
4. **m1 体验差异**：搜索右侧弹窗、游戏浮窗、公告弹窗增强、充值失败页已完成。
5. **当前联调边界**：Telegram 深链、邀请参数、系统 terminal、活动详情语言参数和 DayRevenue/Withdraw/Telegram 字段兼容校准已完成；仍需要真实账号冒烟确认后端环境实际差异。
6. **表单完整性补齐**：提现页取款密码输入、找回密码三方式、资金密码旧密码输入和兑换码页面已完成；兑换码接口路径按当前 baseUrl 规则使用 `/redemption/code`、`/redemption/getlist`。
7. **安全硬化边界**：当前已建立 `UrlPolicy`，集中处理外链/支付/客服/游戏下载和承载 URL；WebView 移动端增加游戏导航拦截，Web iframe 增加 referrer policy；网络层已移除全局 POST 自动 retry，避免资金写操作重复提交。后续仍需 Web token 存储治理、全局敏感状态清理和部署层 CSP/HSTS。
8. **每步完成后同步文档**：更新接口顺序、业务化计划和 UI 进度，保持任务状态一致。

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
5. 提交充值。`2026-05-10 已按 m1 接入 /recharge/order`
6. 上传充值凭证。`2026-05-10 已按 m1 接入 /img/save(name=recharge) + /recharge/img`
7. 取消充值。`2026-05-10 已按 m1 接入 /recharge/cancel`
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

- `docs/API_INTEGRATION_SEQUENCE.md` 的“当前进度记录”和“下一次任务执行方式”。
- `docs/bw-pc-api-v2（适配h5）接口文档.md` 中 `/system/getlist` 的字段结构。
- `/Users/john/Documents/trae_projects/bw-6-2/src/projects/m1` 中首页公告或 Banner 的页面逻辑、API 调用和字段使用。
- 如需 Flutter 工程实现参考，再查旧 Flutter 项目 `/Users/john/Documents/trae_projects/flutter-v1` 中对应 Service/Provider/Model 写法，不参考旧 Flutter 页面逻辑。

下一轮完成标准：

- UI 不因接口失败白屏、不跳动、不破坏当前高保真布局。
- 保留 fallback 静态内容。
- 运行 `dart format lib test`、`flutter analyze lib test`、`flutter test test/widget_test.dart` 并记录结果。

## 18. 2026-05-07 用户中心与主导航 m1 对齐记录

### 18.1 本次任务目标

- 继续按 m1 页面逻辑对齐用户中心、设置页、个人资料页、消息中心和底部导航交互。
- 在不破坏现有 m1 高仿 UI 的前提下，接入用户中心低风险只读状态和少量已确认写操作。
- 修复底部导航点击主 Tab 时出现默认从右到左页面切换动画的问题，对齐 m1 无感切换。

### 18.2 已完成内容

用户中心与账户安全：

- 设置/个人资料中根据 `/token/user` 的 `real_name`、`phone`、`email`、`pay_password` 展示实名、手机、邮箱和资金密码状态。
- 已绑定手机号/邮箱进入绑定页时显示只读状态卡，不再展示绑定表单。
- 已实名时实名认证页输入框和按钮禁用。
- `CustomTextField` 增加 `enabled`。
- `CustomButton.onPressed` 支持 `null` 禁用态。

修改登录密码：

- 对接 m1 `POST /token/repass`。
- 请求参数为 `currentPass`、`newPass`、`confirmpass`。
- 新增 `ApiEndpoints.changePassword`、`ChangePasswordRequest`、`UserService.changePassword()`、`UserProvider.changePassword()`。
- `ChangePasswordScreen` 已补齐校验、提交 loading、成功返回和错误提示。

设置页与个人资料页：

- `/setting` 对齐 m1 `views/user/Setting.vue`，包含修改登录密码、设置资金密码、关于我们、注册信息、清除缓存、版本和退出登录。
- 新增 `/user-profile` 对齐 m1 `views/user/UserProfile.vue`。
- “我的”页点击头像/用户信息进入 `/user-profile`。
- `注册信息` 入口进入 `/user-profile`。
- QQ 和 Telegram 改成框内行内输入，并通过保存按钮统一提交。

消息中心：

- 对接 m1 `POST /notify/getlist` 和 `POST /notify/status`。
- 新增 `UserMessagePage`、`UserMessage`、`UserService.fetchMessages()`、`UserService.markMessageRead()` 和 `MessageProvider`。
- UI 对齐 m1 胶囊 Tab：全部、未读、已读。
- 支持未读 badge、消息卡片、“详情 >”、未读红点、空态、下拉刷新、滚动分页和点击未读标记已读。
- 接口失败时保留 fallback mock 消息，避免页面白屏。

我的页顶部操作：

- 右侧补齐邮件图标，点击进入 `/message`。
- 右侧补齐设置图标，点击进入 `/setting`。
- 邮件图标显示未读红点。
- `ProfileScreen` 进入时预加载消息列表用于未读红点。

底部导航与路由体验：

- `/profile`、`/activity`、`/service` 已补齐底部导航并高亮当前 Tab。
- 主 Tab 点击使用 `context.go(...)`，对齐 m1 `van-tabbar-item replace to="..."`。
- 主 Tab 路由 `/`、`/game`、`/activity`、`/service`、`/profile` 改为 `NoTransitionPage`。
- 底部导航点击主 Tab 时已取消默认从右到左页面切换动画，实现 m1 风格无感切换。
- 非主 Tab 页面继续保留默认页面转场，不影响详情页、资金页、设置页、消息页等普通页面进入/返回体验。

质量修复：

- 修复注册页 `_selectedCurrencyCode` 字段与同名方法冲突，方法改名为 `_registrationCurrencyCode(HomeConfig config)`。

### 18.3 验证结果

工程验证：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

结果：

- `dart format lib test` 已执行通过。
- `flutter analyze lib test` 已执行通过，结果为 `No errors`。
- `flutter test test/widget_test.dart` 已执行通过，当前为 `9 tests passed`。

### 18.4 后续建议

- 将五个主 Tab 页的底部导航抽成统一公共主框架，优先评估 GoRouter `ShellRoute`，避免 `HomeScreen`、`GameScreen`、`ActivityScreen`、`ServiceScreen`、`ProfileScreen` 重复维护底栏。
- 完善 `/user-profile` 头像上传/选择流程，目前仍是占位提示。
- 完善 `/setting` 的“关于我们”内容页或接口，目前仍是占位提示。
- 继续验证真实账号下 `/notify/getlist`、`/notify/status` 响应结构是否完全匹配当前 `UserMessagePage.fromResponse()` 和 `UserMessage.fromJson()`。
- 继续接入手机号/邮箱验证码发送接口，当前绑定页面验证码发送仍未完全真实接入。

### 18.5 接续注意事项

- m1 主 Tab 切换要求是无感 replace 式切换，不要改回 `context.push(...)` 或默认页面转场。
- 当前主 Tab 底部导航仍分散在多个页面中，这是后续工程收敛项，不是当前功能缺陷。
- 非主 Tab 默认转场应保留，除非后续明确要求全局禁用页面动画。

## 19. 2026-05-07 主框架收敛与反馈链路接入记录

### 19.1 主框架收敛

- 新增 `lib/screens/main/main_shell_screen.dart`。
- 五个主 Tab `/`、`/game`、`/activity`、`/service`、`/profile` 已收敛到 `StatefulShellRoute.indexedStack`。
- `MainShellScreen` 统一持有 `CustomTabBar`，根据 `StatefulNavigationShell.currentIndex` 高亮当前 Tab。
- 主 Tab 点击通过 `navigationShell.goBranch(index)` 切换，保留无感切换体验。
- 已移除 `HomeScreen`、`GameScreen`、`ActivityScreen`、`ServiceScreen`、`ProfileScreen` 中重复维护的底部导航。
- 非主 Tab 页面继续留在 shell 外，例如 `/game-sub`、`/message`、`/setting`、`/deposit` 等，避免详情页被统一底栏包住。

### 19.2 反馈链路接入

- 对照 m1 `views/user/Feedback.vue`、`views/user/FeedbackRecords.vue`、`api/feedback.js` 和接口文档补齐反馈真实接口。
- 新增接口：
- `POST /feedback_type/getlist`：反馈类型。
- `POST /feedback/to`：提交反馈。
- `POST /feedback/getlist`：我的反馈记录。
- 补齐 `FeedbackType`、`SubmitFeedbackRequest`、`FeedbackRecord`、`FeedbackRecordPage`。
- `UserService` 新增 `fetchFeedbackTypes()`、`submitFeedback()`、`fetchFeedbackRecords()`。
- 新增 `FeedbackProvider`，维护反馈类型、提交状态、反馈记录分页、加载更多和 fallback。
- `FeedbackScreen` 进入后加载反馈类型，提交时按 m1 参数 `id`、`text`、`img` 调用真实接口。
- `FeedbackRecordsScreen` 优先展示真实反馈记录，支持下拉刷新、滚动分页、空态、处理中/已处理状态和回复内容展示。
- 接口失败时继续保留原高仿 fallback 分类和反馈记录。
- 图片上传仍为占位 UI，本次不接上传接口，提交参数 `img` 暂为空。

### 19.3 验证结果

工程验证：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

结果：

- `dart format lib test` 已执行通过。
- `flutter analyze lib test` 已执行通过，结果为 `No errors`。
- `flutter test test/widget_test.dart` 已执行通过，当前为 `9 tests passed`。

### 19.4 后续建议

- 用真实账号验证 `/feedback/getlist` 的分页字段、回复字段和图片字段是否与当前模型完全一致。
- 继续用真实账号验证手机号/邮箱绑定提交字段，尤其是 `/user/edit` 是否接受验证码字段 `code`。
- 后续如需完整反馈图片能力，应先确认上传接口，再把上传结果拼入 `img` 参数。

## 20. 2026-05-07 手机号/邮箱绑定链路接入记录

### 20.1 本次任务目标

- 完善账户安全中手机号和邮箱绑定的验证码发送与提交链路。
- 继续保持已绑定手机号/邮箱只读展示，不提供修改入口。
- 不进入资金、充值、提现、绑卡等高风险写操作。

### 20.2 已完成内容

- 手机验证码发送接入 `POST /phone_code/send`。
- 邮箱验证码发送接入 `POST /mail_code/send`。
- 验证码发送参数对齐接口文档：
- 手机：`type: 2`、`area_code: '+86'`、`phone`。
- 邮箱：`type: 2`、`email`。
- `UserProvider` 复用 `AuthService`，新增 `sendPhoneCode()` 和 `sendEmailCode()`。
- `BindPhoneScreen` 获取验证码时真实调用短信验证码接口，接口成功后才启动倒计时。
- `BindEmailScreen` 获取验证码时真实调用邮箱验证码接口，接口成功后才启动倒计时。
- 绑定提交继续走 `POST /user/edit`，提交后刷新 `/token/user` 并返回上一页。
- 已绑定手机号/邮箱仍显示只读状态卡，避免误导用户修改已绑定信息。

### 20.3 验证结果

工程验证：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

结果：

- `dart format lib test` 已执行通过。
- `flutter analyze lib test` 已执行通过，结果为 `No errors`。
- `flutter test test/widget_test.dart` 已执行通过，当前为 `9 tests passed`。

### 20.4 后续建议

- 用真实账号验证 `/user/edit` 对绑定验证码字段 `code` 的校验规则。
- 当前区号固定为 `+86`，如果后续需要支持多国家区号，应参考系统配置或新增区号选择组件。
- 继续接实名提交、反馈图片上传或 VIP 信息展示完善等非资金链路。

## 21. 2026-05-07 实名认证提交接入记录

### 21.1 本次任务目标

- 对齐 m1 `RealName.vue` 的实名认证提交行为。
- 未实名用户可提交真实姓名。
- 已实名用户继续保持只读展示和禁用提交。
- 不新增身份证号、证件照片等 m1 未实现字段。

### 21.2 已完成内容

- 确认 m1 使用 `editUserProfile({ real_name: name })` 提交实名认证。
- Flutter 继续使用 `POST /user/edit` 提交 `real_name`。
- `UserProvider` 新增 `submitRealName(realName)` 专用封装，避免页面直接拼资料更新请求。
- `RealNameScreen` 提交改为调用 `submitRealName()`。
- 提交成功后复用资料刷新逻辑，重新请求 `/token/user`。
- 提交中按钮禁用，避免重复提交。
- 已实名时输入框和按钮保持禁用状态。

### 21.3 验证结果

工程验证：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

结果：

- `dart format lib test` 已执行通过。
- `flutter analyze lib test` 已执行通过，结果为 `No errors`。
- `flutter test test/widget_test.dart` 已执行通过，当前为 `9 tests passed`。

### 21.4 后续建议

- 用真实账号验证 `/user/edit` 提交 `real_name` 后 `/token/user` 是否立即返回最新真实姓名。
- 如果后端存在更完整实名接口，应再确认是否需要身份证号、证件照片、审核状态等字段；当前按 m1 只提交真实姓名。
- 下一步建议继续做 VIP 信息只读完善或反馈图片上传。

## 22. 2026-05-07 VIP 信息只读展示完善记录

状态：已对接完毕。

### 22.1 本次任务目标

- 对齐 m1 `Vip.vue` 的 VIP 页面只读展示。
- 保持 `/vip/getlist` 真实接口优先，fallback 默认等级规则兜底。
- 不进入 VIP 购买、充值、提款、升级支付等资金相关写操作。

### 22.2 已完成内容

- 确认 m1 VIP 接口为 `POST /vip/getlist`。
- 保留并使用 Flutter 已有 `VipOverview`、`VipLevel`、`UserProvider.loadVipLevels()`。
- `VipScreen` 继续展示：
- 升级进度。
- VIP 等级 tab。
- 当前等级标记。
- 升级条件。
- VIP 福利。
- VIP 返水比例。
- 升级说明。
- `/profile` 顶部 VIP 标签补齐点击入口，点击进入 `/vip`。
- `VipScreen` 增加下拉刷新，刷新时重新请求 `/vip/getlist`。
- `VipScreen` 增加加载提示。
- 接口失败且无真实等级数据时显示 fallback 提示，并继续展示默认等级规则，避免页面白屏。

### 22.3 验证结果

工程验证：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

结果：

- `dart format lib test` 已执行通过。
- `flutter analyze lib test` 已执行通过，结果为 `No errors`。
- `flutter test test/widget_test.dart` 已执行通过，当前为 `9 tests passed`。

### 22.4 后续建议

- 用真实账号打开 `/vip`，确认 `/vip/getlist` 的等级数组、累计充值、累计流水字段位置是否与当前兼容解析一致。
- 确认 m1/API 的 `title` 字段是否稳定带等级数字，当前 Flutter 通过标题数字计算等级。
- 继续接反馈图片上传、头像上传或关于我们内容页等低风险链路。

### 22.5 真实账号修正记录

- 真实账号测试发现 VIP 充值进度当前值显示为 `/vip/getlist` 的 `total_deposit`，但业务预期应使用 `/token/user` 返回的 `recharge`，例如 `103834.0000`。
- `UserProfile` 已补充 `recharge` 字段解析和序列化。
- `VipScreen` 当前充值优先级调整为用户资料优先：`level_data.recharge` -> `profile.recharge` -> `total_recharge` -> `total_deposit` -> `recharge_amount` -> `/vip/getlist.total_deposit`。
- 当前 VIP 等级计算同步改用该当前充值值。

### 22.6 完成确认

- 真实账号验证后确认 VIP 页面当前阶段对接完毕。
- `/profile` 顶部 VIP 入口已可进入 `/vip`。
- `/vip/getlist` 等级规则、升级条件、福利和返水展示已接入。
- 充值进度当前值已按业务预期使用 `/token/user.recharge`。
- 下拉刷新、加载提示和 fallback 默认规则展示均已完成。
- 当前 VIP 页面仍为只读展示，不涉及充值、提款、购买或升级支付。

## 23. 2026-05-07 关于我们只读页面接入记录

状态：已对接完毕。

### 23.1 本次任务目标

- 补齐 `/setting` 中“关于我们”入口，替换原先 `功能即将上线` 占位。
- 优先使用现有系统配置接口，不新增无依据接口。
- 保持页面只读和 fallback 展示，不进入外链打开、客服跳转或资金相关行为。

### 23.2 m1 对齐结论

- m1 `views/user/Setting.vue` 中“关于我们”目前只有 `van-cell` 静态展示。
- m1 未配置“关于我们”点击事件、独立路由或专属 API。
- Flutter 因此采用已接入的 `/system/getlist.config_site` 作为关于我们信息源。

### 23.3 已完成内容

- 新增 `RoutePaths.aboutUs = '/about-us'`，并加入登录保护集合。
- `app_router.dart` 新增 `/about-us` 路由，指向 `AboutUsScreen`。
- `/setting` 中“关于我们”入口由占位 toast 改为 `context.push('/about-us')`。
- 新增 `AboutUsScreen`：
- 展示站点 Logo、站点名称、站点描述/平台介绍。
- 展示域名、APP 版本、APP 下载、客服入口和 TG 客服。
- 支持下拉刷新，刷新时调用 `SystemProvider.loadConfig(refresh: true)`。
- 接口失败或字段为空时展示默认 fallback，不白屏。

### 23.4 验证结果

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

结果：

- `dart format lib test` 已执行通过。
- `flutter analyze lib test` 已执行通过，结果为 `No errors`。
- `flutter test test/widget_test.dart` 已执行通过，当前为 `9 tests passed`。

### 23.5 后续建议

- 若后续产品确认“关于我们”有独立富文本接口，再替换当前 `config_site` 只读信息源。
- 若需要打开 APP 下载、客服或 TG 链接，应统一接入安全外链打开能力，不在当前页面直接临时实现。
- 下一步可继续接头像上传或反馈图片上传，两者都需要先确认上传接口并复用文件上传能力。

## 24. 2026-05-07 头像上传接入记录

状态：已对接完毕，待真实账号上传验证。

### 24.1 本次任务目标

- 补齐 `/user-profile` 头像上传/保存流程，替换原先 `头像上传即将上线` 占位。
- 对齐 m1 个人资料页头像入口，同时使用接口文档中的真实上传接口。
- 保持最小改动，不改动其他资料字段保存逻辑。

### 24.2 m1 与接口结论

- m1 `views/user/UserProfile.vue` 中头像使用 `van-uploader` 选择图片。
- m1 当前 `afterReadAvatar` 只把本地 `file.content` 放到 `profile.avatarUrl` 做预览，并在保存时通过 `editUserProfile({ img })` 提交，没有真实上传请求。
- 接口文档提供通用上传接口 `POST /img/save`，`form-data` 参数为 `file`、`name`，响应包含 `path` 和 `url`。
- Flutter 本次按真实接口实现：先上传图片，再把返回图片地址保存到 `/user/edit.img`。

### 24.3 已完成内容

- 新增依赖 `image_picker`。
- 新增 `ApiEndpoints.imageUpload = '/img/save'`。
- 新增 `UserService.uploadImage()`：
- 使用 `FormData` + `MultipartFile.fromBytes`。
- 参数 `name` 默认为 `avatar`。
- 兼容接口返回 `data.data.path/url` 的嵌套结构。
- 新增 `UserProvider.isUploadingAvatar` 与 `uploadAvatar()`：
- 调用 `/img/save` 上传图片。
- 使用返回 `url` 或 `path` 调用 `/user/edit` 保存 `img`。
- 保存后刷新 `/token/user`。
- `/user-profile` 头像行改为相册选择、上传、保存流程，并在上传期间显示 `上传中...`。

### 24.4 验证结果

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

结果：

- `dart format lib test` 已执行通过。
- `flutter analyze lib test` 已执行通过，结果为 `No errors`。
- `flutter test test/widget_test.dart` 已执行通过，当前为 `9 tests passed`。

### 24.5 后续建议

- 使用真实账号验证 `/img/save` 返回的 `url/path` 是否能被 `/user/edit.img` 接受并在 `/token/user.img` 中回显。
- 如接口要求提交相对路径，需把保存头像逻辑改为 `path` 优先。
- 后续反馈图片上传可复用当前上传能力，必要时再抽成 `CommonUploadService`。

## 25. 2026-05-07 客服页 m1 对齐记录

状态：已对齐完毕，待真实客服链接点击验证。

### 25.1 本次任务目标

- 优先处理底部导航栏的客服页，保持低风险只读接入顺序。
- 对齐 m1 `views/main/Service.vue` 的页面结构和链接来源。
- 替换 Flutter 原有静态 mock 客服列表，不进入反馈图片上传或资金链路。

### 25.2 m1 对齐结论

- m1 客服页进入后调用 `getSystemConfigList()`，读取 `data.config_site`。
- 客服链接来源为 `config_site.service_link`，Telegram 链接来源为 `config_site.tg_link`。
- m1 页面会解析数组、JSON 字符串、多链接字符串，并生成在线客服和 TG 渐变卡片。
- m1 点击客服卡片通过 `window.open(url, '_blank')` 打开外链。

### 25.3 已完成内容

- `ServiceScreen` 改为消费 `SystemProvider.config.siteConfig` 和 `UserProvider.profile`。
- 顶部卡片展示用户头像、`Hi，用户名` 和客服欢迎文案。
- 下方两列卡片展示在线客服与 Telegram 通道，颜色、圆角和排版对齐 m1。
- 解析 `service_link` 和 `tg_link` 时兼容 List、普通字符串、数组样式字符串、逗号/中文逗号/换行/空白分隔。
- 新增 `url_launcher` 依赖，点击卡片时使用系统外部浏览器或对应 App 打开链接。
- 支持下拉刷新系统配置。
- 无客服配置时展示 `暂无客服通道` 空态，不白屏。

### 25.4 验证结果

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

结果：

- `dart format lib test` 已执行通过。
- `flutter analyze lib test` 已执行通过，结果为 `No errors`。
- `flutter test test/widget_test.dart` 已执行通过，当前为 `9 tests passed`。

### 25.5 后续建议

- 用真实配置验证 `service_link` 和 `tg_link` 是否都包含 URL scheme。
- 若后端存在裸域名或 Telegram 用户名格式，需要确认是否由前端自动补全链接。
- 下一步继续接反馈图片上传，复用现有 `/img/save` 上传能力。

## 26. 2026-05-07 反馈页图片上传与溢出修复记录

状态：已对齐完毕，待真实账号上传验证。

### 26.1 本次任务目标

- 将 Flutter 反馈页继续向 m1 `views/user/Feedback.vue` 对齐。
- 修复选择问题类型时的弹窗溢出。
- 补齐反馈图片上传，完成反馈提交的图片参数闭环。

### 26.2 m1 对齐结论

- m1 反馈页包含问题分类、问题描述、图片上传、提交按钮和右上角反馈记录入口。
- m1 使用 `van-action-sheet` 选择问题分类，分类来自 `/feedback_type/getlist`。
- m1 图片最多 3 张，提交时将图片地址以逗号拼接传给 `/feedback/to.img`。
- m1 当前图片逻辑偏本地预览，Flutter 使用接口文档中的 `/img/save` 做真实上传。

### 26.3 已完成内容

- 问题类型选择弹窗改为最大高度约束 + 可滚动列表，避免分类过多时 RenderFlex 溢出。
- 分类名称设置单行省略，避免长分类标题水平溢出。
- `FeedbackProvider` 新增 `isUploadingImage` 和 `uploadFeedbackImage()`。
- 反馈页图片区域支持选择多图，最多 3 张。
- 选择图片后调用 `POST /img/save`，上传参数 `name = feedback`。
- 上传成功后展示缩略图，支持删除。
- 提交反馈时把图片地址通过 `SubmitFeedbackRequest.img` 传给 `/feedback/to`。
- 图片选择插件未加载时提示完整重启，上传失败时提示错误且保留无图提交能力。

### 26.4 验证结果

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

结果：

- `dart format lib test` 已执行通过。
- `flutter analyze lib test` 已执行通过，结果为 `No errors`。
- `flutter test test/widget_test.dart` 已执行通过，当前为 `9 tests passed`。

### 26.5 后续建议

- 用真实账号提交带图片的反馈，确认 `/feedback/to.img` 接受当前图片地址格式。
- 若接口要求相对路径，统一调整头像和反馈上传后的保存优先级为 `path`。
- 下一步可继续做活动页只读详情、游戏收藏/搜索等非资金链路。

## 27. 2026-05-07 活动页只读链路接入记录

状态：已完成只读接入，活动申请写操作暂缓。

### 27.1 本次任务目标

- 继续按低风险顺序推进底部主 Tab 的活动页。
- 优先接活动分类、活动列表和活动详情只读展示。
- 暂不调用活动申请接口，避免进入写操作。

### 27.2 m1 对齐结论

- m1 活动主页面为 `views/main/activity.vue`。
- m1 活动详情页为 `views/main/ActivityDetail.vue`。
- m1 接口文件为 `api/activity.js`。
- 活动分类接口：`POST /activity/class`。
- 活动列表接口：`POST /activity/list`，分类筛选时传 `id`。
- 活动详情接口：`POST /activity/details`，传活动 `id` 后从返回数组中匹配详情。
- 活动申请接口：`POST /activity/apply`，本次不接。

### 27.3 已完成内容

- 新增 `lib/models/activity/activity_models.dart`。
- `ActivityCategory` 解析分类 `id/title`。
- `ActivityItem` 解析活动 `id/title/img/content/type/multiple/lasting/start_time/end_time`。
- 补齐 `ActivityService.fetchCategories()`、`fetchActivities()`、`fetchActivityDetails()`。
- 补齐 `ActivityProvider` 分类、列表、详情状态和 fallback 活动数据。
- `ActivityScreen` 改为读取真实分类和活动列表：
- 顶部品牌区域读取 `SystemProvider.config.siteConfig`。
- 分类横向 tab 对齐 m1。
- 活动卡片展示图片、标签、标题和时间。
- 支持下拉刷新分类与列表。
- `ActivityDetailScreen` 支持通过 `/activity-detail?id=...` 加载详情。
- 活动详情展示标题、发放方式、倍数、时间和说明。
- 手动活动底部按钮保留视觉，但点击仅提示 `活动申请功能待接入`。

### 27.4 验证结果

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

结果：

- `dart format lib test` 已执行通过。
- `flutter analyze lib test` 已执行通过，结果为 `No errors`。
- `flutter test test/widget_test.dart` 已执行通过，当前为 `9 tests passed`。

### 27.5 后续建议

- 用真实账号检查 `/activity/list`、`/activity/details` 的字段和图片地址是否与当前模型一致。
- 如活动详情 content 包含图片、表格或复杂 HTML，后续补安全富文本渲染。
- 下一步可接活动申请记录只读 `/activity/record`，或转入游戏搜索/收藏等非资金链路。

## 28. 2026-05-07 活动申请记录只读接入记录

状态：已完成只读接入。

### 28.1 本次任务目标

- 继续完善活动模块，但仍保持只读低风险范围。
- 对齐 m1 `views/main/ActivityApplyRecords.vue`。
- 接入活动申请记录接口，不接活动申请提交。

### 28.2 m1 对齐结论

- m1 活动申请记录页面为 `views/main/ActivityApplyRecords.vue`。
- 接口为 `POST /activity/record`。
- 请求参数为 `page`、`size`。
- 响应分页字段为 `data.data`、`current_page`、`lastPage`、`total`。
- 状态映射：`1` 申请中、`2` 已通过、`3` 已拒绝、其他未知状态。

### 28.3 已完成内容

- `ActivityRecordPage` 解析分页响应。
- `ActivityApplyRecord` 解析 `username`、`status`、`apply_time`、`title`。
- `ActivityService.fetchActivityRecords()` 接入 `/activity/record`。
- `ActivityProvider` 新增申请记录状态：
- 首屏加载。
- 下拉刷新。
- 滚动加载更多。
- 失败 fallback。
- `ActivityRecordScreen` 从静态 mock 改为真实记录列表。
- 页面支持空态、底部“没有更多了”、加载更多 loading。
- 记录卡片视觉对齐 m1：标题 + 状态标签 + 账号 + 申请时间。

### 28.4 验证结果

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

结果：

- `dart format lib test` 已执行通过。
- `flutter analyze lib test` 已执行通过，结果为 `No errors`。
- `flutter test test/widget_test.dart` 已执行通过，当前为 `9 tests passed`。

### 28.5 后续建议

- 使用真实账号验证无记录、单页记录、多页记录三种响应。
- 后续若要继续活动模块，可接活动详情安全富文本渲染，再评估 `/activity/apply` 申请提交。
- 也可转向游戏搜索/收藏等非资金链路。

## 29. 2026-05-08 活动详情富文本安全渲染记录

状态：已完成只读 UI 增强。

### 29.1 本次任务目标

- 补齐活动详情 `content` 的 HTML 展示能力。
- 对齐 m1 `ActivityDetail.vue` 的 `v-html` 活动说明效果。
- 不引入写操作，不接 `/activity/apply`。

### 29.2 m1 对齐结论

- m1 使用 `safeHtml = stripScripts(rawContent)` 后通过 `v-html` 渲染。
- m1 会移除 `script` 和内联事件属性。
- Flutter 侧不能直接执行 HTML，因此采用轻量安全渲染策略。

### 29.3 已完成内容

- `ActivityDetailScreen` 的活动说明从纯文本剥离 HTML 改为 `_ActivityContent`。
- 移除 `script`、`style`、`on*` 事件属性和 `javascript:` 链接/图片地址。
- 支持普通文本、段落、换行、列表项、表格单元文本降级。
- 支持 `<img src="...">` 图片块展示，复用 `AppNetworkImage`。
- 空内容继续显示 `暂无活动内容`。
- 未新增第三方 HTML/WebView 依赖，避免引入额外安全和资源风险。

### 29.4 验证结果

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

结果：

- `dart format lib test` 已执行通过。
- `flutter analyze lib test` 已执行通过，结果为 `No errors`。
- `flutter test test/widget_test.dart` 已执行通过，当前为 `9 tests passed`。

### 29.5 后续建议

- 用真实活动内容验证图片地址、富文本段落和表格降级效果。
- 若后续活动大量依赖复杂表格，可单独实现安全表格组件。
- 下一步可评估 `/activity/apply` 申请提交，或转向游戏收藏/搜索等非资金链路。

## 30. 2026-05-08 活动申请提交接入记录

状态：已完成弱写操作接入。

### 30.1 本次任务目标

- 接入手动活动申请提交。
- 对齐 m1 `ActivityDetail.vue` 中 `handleApply()` 的调用方式。
- 保持活动详情 UI 不大改，仅替换占位提示为真实提交。

### 30.2 m1 对齐结论

- m1 仅当 `activity.type === 2` 且 `id > 0` 时展示申请按钮。
- 点击按钮调用 `applyActivity({ id })`。
- 提交中禁用按钮，避免重复点击。
- 成功提示后端 `msg` 或默认成功文案。
- 失败走后端错误提示。

### 30.3 已完成内容

- `ActivityService.applyActivity(id)` 接入 `POST /activity/apply`。
- `ActivityProvider` 新增：
- `isApplying`。
- `applyError`。
- `applyActivity(id)`。
- `ActivityDetailScreen` 的 `申请参与活动` 按钮改为真实提交。
- 提交中展示 `申请中...` 并禁用按钮。
- 成功显示 `申请成功`。
- 失败展示后端业务错误信息，兜底 `申请失败`。
- 申请成功后清空活动申请记录缓存，后续进入记录页会重新加载 `/activity/record`。

### 30.4 验证结果

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

结果：

- `dart format lib test` 已执行通过。
- `flutter analyze lib test` 已执行通过，结果为 `No errors`。
- `flutter test test/widget_test.dart` 已执行通过，当前为 `9 tests passed`。

### 30.5 后续建议

- 使用真实手动活动验证成功、重复申请、活动过期、登录过期等业务场景。
- 当前 `DioClient` 默认只返回 `data` payload，成功提示暂用本地文案；如需要完全展示后端成功 `msg`，需补完整 envelope 返回能力。
- 活动模块主要链路已完成，下一步建议转入游戏搜索/收藏等非资金链路。

## 31. 2026-05-08 游戏子列表搜索、分页与收藏接入记录

状态：已完成非资金链路接入，待真实账号验证收藏接口。

### 31.1 本次任务目标

- 继续按照文档转入游戏模块非资金链路。
- 补齐 m1 `GameSubList.vue` 中已存在的搜索、分页和收藏交互。
- 不接进入游戏、游戏余额、场馆转账或其他资金相关接口。

### 31.2 m1 对齐结论

- 子游戏列表接口为 `POST /gamelist/getlist`。
- 请求参数为 `page`、`size`、`code`、`game`、`search_word`。
- 搜索输入在 m1 中使用 300ms debounce 后重新拉取第一页。
- 收藏接口为 `POST /user_favorites/game`。
- 收藏参数为 `id` 和 `status`，`status = 1` 表示收藏，`status = 0` 表示取消收藏。
- 未登录点击收藏时只提示登录，不发起收藏请求。

### 31.3 已完成内容

- 新增 `ApiEndpoints.gameFavorite`。
- `GameService` 新增 `setGameFavorite({id, favorited})`。
- `GameItem` 新增 `copyWith()`，用于收藏状态局部更新。
- `GameProvider` 新增：
- 当前子列表搜索词匹配判断。
- `favoritingGameId` 收藏提交中状态。
- `toggleGameFavorite()` 收藏/取消收藏提交方法。
- `GameSubListScreen` 搜索图标可展开/关闭搜索栏。
- 搜索输入 300ms debounce 后调用 `/gamelist/getlist` 首屏刷新。
- 关闭搜索栏清空关键词并恢复原列表。
- 远程子游戏卡片收藏按钮调用真实接口，并展示提交中 loading。
- 未登录点击收藏提示 `请先登录查看收藏`。
- 分页加载更多继续沿用现有滚动触底逻辑。
- 清理了未使用字段、未使用方法和未使用 import，保持分析基线干净。

### 31.4 验证结果

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

结果：

- `dart format lib test` 已执行通过。
- `flutter analyze lib test` 已执行通过，结果为 `No issues found!`。
- `flutter test test/widget_test.dart` 已执行通过，当前为 `9 tests passed`。

### 31.5 后续建议

- 用真实账号验证收藏成功、取消收藏、重复点击和未登录提示。
- 当前收藏 Tab 过滤当前已加载列表中的收藏项；如需要独立收藏分页，需要确认是否有专属收藏列表接口后再接。
- 下一步可继续游戏推荐/首页推荐游戏只读接口，或评估游戏启动 `/game/login` 前的非资金安全状态处理。

## 32. 2026-05-08 首页推荐游戏只读接入记录

状态：已完成只读接入，待真实接口数据验证。

### 32.1 本次任务目标

- 继续推进游戏模块低风险只读链路。
- 将首页“推荐游戏”从纯静态 mock 改为真实接口优先。
- 不接游戏启动 `/game/login`，不进入余额、转账或资金链路。

### 32.2 m1 与接口结论

- 接口文档中推荐游戏接口为 `POST /interface/reco`。
- m1 接口封装为 `getInterfaceReco()`，路径 `/api/interface/reco`。
- m1 首页存在推荐游戏横向滚动区，展示游戏图片和标题。
- m1 点击推荐游戏会进入游戏启动逻辑；Flutter 本次暂不接启动，只保留占位提示。

### 32.3 已完成内容

- 新增 `RecommendedGame` 模型，覆盖推荐游戏展示所需字段。
- `GameService.fetchRecommendedGames()` 接入 `/interface/reco`。
- `GameProvider` 新增：
- `recommendedGames`。
- `isRecommendedLoading`。
- `hasRecommendedLoaded`。
- `recommendedError`。
- `loadRecommendedGames()`。
- `HomeScreen.initState()` 首帧后加载推荐游戏。
- 首页推荐游戏区优先展示真实推荐游戏图片和标题。
- 真实接口无可见数据时对齐 m1 首页模块规则：不展示推荐游戏模块，不使用静态推荐游戏 fallback UI。
- 推荐游戏图片使用 `AppNetworkImage`，图片加载失败仅显示图片占位，不补静态业务游戏数据。
- “更多”入口跳转 `/game` 游戏大厅。
- 点击推荐游戏已接入 `/game/login`，复用游戏大厅启动逻辑和 `/game-view` 承载页。
- 推荐游戏启动中显示遮罩和 `启动中...`。
- 推荐游戏列表优先使用 `/interface/reco`，失败或为空时 fallback 到 m1 当前使用的 `/interface/list`，筛选 `label` 包含 `reco`。
- 推荐游戏若为二级分类入口（`category == 1`），点击进入子游戏列表，而不是直接启动游戏。

### 32.4 验证结果

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

结果：

- `dart format lib test` 已执行通过。
- `flutter analyze lib test` 已执行通过，结果为 `No issues found!`。
- `flutter test test/widget_test.dart` 已执行通过，当前为 `9 tests passed`。

### 32.5 后续建议

- 用真实接口验证 `/interface/reco` 的返回结构、图片地址和维护状态字段。
- 首页推荐游戏启动已接入，需要继续用真实账号验证登录态、维护状态、外跳/内嵌 WebView、失败提示和重复点击保护。
- 推荐游戏列表需要验证 `/interface/reco` 与 `/interface/list` fallback 两种来源的数据结构。
- 继续保留资金相关接口后置原则。

## 33. 2026-05-08 游戏启动最小接入记录

状态：已完成最小启动链路，待真实账号验证。

### 33.1 本次任务目标

- 接入游戏启动 `/game/login` 的最小可用链路。
- 对齐 m1 的未登录、维护、提交中和 URL 打开处理。
- 不接游戏余额、场馆转账、一键回收等资金相关接口。

### 33.2 m1 与接口结论

- m1 `api/game.js` 中 `gameLogin(data)` 调用 `/api/game/login`。
- 接口文档请求参数为 `id` 和 `mobile`，移动端传 `mobile: 1`。
- 响应字段为 `data.url` 和 `data.nesting`。
- m1 已登录才调用启动接口；未登录跳登录页。
- m1 维护中游戏不启动。
- m1 `nesting === false` 时外部打开；否则使用 `GamePlay` 内嵌组件。
- 旧 Flutter 项目已有 `GameViewScreen` 跨平台承载方案，移动端使用 WebView，Web 端使用 iframe。
- Flutter 当前项目本次补齐 `/game-view` 内嵌承载页，避免游戏启动后错误回到首页或保留游戏大厅底栏。

### 33.3 已完成内容

- `GameLaunchResult` 增加 `nesting` 字段。
- 新增 `GameLaunchTarget`，统一表示可启动游戏的 `id/title`。
- `GameProviderItem`、`GameItem`、`RecommendedGame` 增加 `launchTarget`。
- `GameService.launchGame()` 接入 `POST /game/login`，参数为 `id`、`mobile: 1`。
- `GameProvider` 新增：
- `launchingGameId`。
- `launchError`。
- `launchGame()`。
- 游戏大厅非子列表卡片点击从跳登录占位改为真实启动。
- 子游戏列表卡片点击接入真实启动。
- 未登录点击游戏跳转 `/login`。
- 维护中游戏不启动。
- 启动中卡片显示遮罩和 `启动中...`。
- 启动成功后进入 `/game-view` 内嵌承载游戏地址。
- 移动端使用 `webview_flutter`，Web 端使用 iframe `HtmlElementView`。
- 接口失败、无 URL、URL 无效均有提示。

### 33.4 验证结果

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

结果：

- `dart format lib test` 已执行通过。
- `flutter analyze lib test` 已执行通过，结果为 `No issues found!`。
- `flutter test test/widget_test.dart` 已执行通过，当前为 `9 tests passed`。

### 33.5 后续建议

- 用真实账号验证 `/game/login` 返回的 `url` 是否可被外部浏览器/App 打开。
- 继续用真实账号验证二级分类游戏和子游戏列表点击是否都能触发 `/game/login` 并进入 `/game-view`。
- 如果产品要求 m1 的弹层最小化浮窗体验，需要作为独立交互任务实现。
- 场馆余额、转入、转出、一键回收等资金动作继续后置。

## 34. 2026-05-08 路由兼容与维护页记录

状态：已完成基础路由对齐。

### 34.1 本次任务目标

- 对齐 m1 主要业务路径，保留当前 Flutter 已有路径作为兼容入口。
- 补齐登录保护遗漏，降低后续接口接入时的越权访问风险。
- 补齐 m1 `/maintenance` 系统维护页和全局维护跳转。

### 34.2 已完成内容

- 初始路由调整为 `/`，不再默认进入 `/login`。
- 新增 m1 alias 路由：`/game/sub`、`/game/play`、`/activity/detail/:id`、`/activity/records`、`/feedback/records`、`/user/*`、`/card/*`、`/game-manage`、`/fund-manage`、`/deposit/*`、`/withdraw/success`。
- 新增 `routeRequiresAuth(path)`，支持精确路径和动态路径前缀登录保护。
- 补齐 `/game-sub`、`/activity-detail`、`/activity-record`、`/online-pay`、`/deposit-detail`、`/deposit-success`、`/withdraw-success` 等保护遗漏。
- 新增 `MaintenanceScreen` 和 `/maintenance` 路由。
- `SystemProvider` 绑定全局 `DioClient`。
- `GoRouter` 合并监听 `AuthProvider` 与 `SystemProvider`，支持配置加载后即时触发维护重定向。

### 34.3 后续建议

- 使用真实配置验证维护状态跳转。
- 如后续需要完全对齐 m1 游戏体验，再实现页面内 popup/minimize 游戏承载，而不是仅使用独立 `/game-view`。
- 继续避免接入充值、提现、转账、绑卡等资金写操作。

## 35. 2026-05-08 游戏承载页 m1 基础对齐记录

状态：已完成独立承载页基础体验对齐。

### 35.1 本次任务目标

- 在不大改 App 顶层结构的前提下，让当前 `/game-view` 更接近 m1 `GamePlay.vue`。
- 对齐 m1 的 `nesting === false` 外部打开规则。
- 保持资金相关游戏余额和转账动作后置。

### 35.2 已完成内容

- `GameScreen` 和 `GameSubListScreen` 启动成功后读取 `GameLaunchResult.nesting`。
- `nesting == false` 时通过 `url_launcher` 外部打开游戏 URL。
- 其他情况继续进入 `/game-view` 内嵌承载。
- 新增 `GameViewShell`，统一黑色顶部栏、标题、站点 Logo、关闭按钮和错误状态。
- 移动端 `webview_flutter` 承载增加无效 URL、加载失败和重新加载处理。
- Web iframe 增加 m1 的 allow/sandbox/fullscreen 参数。

### 35.3 后续建议

- 用真实账号验证游戏启动后窗口打开行为。
- 若产品继续要求完全对齐 m1，再实现页面内 popup 和 floating 小窗。

## 36. 2026-05-08 游戏管理只读记录接入记录

状态：已完成只读记录接入。

### 36.1 本次任务目标

- 接入游戏管理页的只读记录数据。
- 对齐 m1 的返水记录和游戏记录接口、日期筛选、分页和统计展示。
- 不接领取返水写操作。

### 36.2 已完成内容

- 新增接口：`/member_fs_log/getlist`、`/gamerecord/getlist`。
- 新增模型：`GameManageQuery`、`RebateRecordPage`、`RebateRecord`、`GameRecordPage`、`GameBetRecord`。
- 新增 `GameManagementService` 和 `GameManagementProvider`。
- `GameManagementScreen` 接入真实返水记录和游戏记录。
- 支持快捷日期筛选、下拉刷新、滚动分页、真实统计和空态。
- 空数组不显示静态 fallback 记录；日期筛选区使用横向滚动避免窄屏溢出。
- 记录卡片、统计卡片和日期筛选卡片完成 m1 风格精修，减少过大的 padding 和列表空态干扰。
- 已按 m1 数据模型补充记录字段保护，返水记录和游戏记录不会互相误解析。
- 返水领取按钮保持禁用，避免本阶段引入金额写操作。

### 36.3 后续建议

- 用真实账号验证字段映射和分页。
- 下一步可继续接资金管理页只读记录，仍不接提交类资金写操作。
