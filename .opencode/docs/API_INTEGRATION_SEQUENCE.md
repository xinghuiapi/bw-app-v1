# API Integration Sequence

本文档用于规划当前 Flutter 主工程的接口对接顺序。目标不是单纯把接口接通，而是让已经按 m1 项目制作的高仿 Flutter UI 在当前工程中具备真实业务能力，并逐步补齐合格 Flutter 项目的工程能力。

接口来源：`.opencode/docs/bw-pc-api-v2（适配h5）接口文档.md`

架构规范：`.opencode/docs/NEW_FRONTEND_ARCHITECTURE_GUIDE.md`

UI 和页面对接逻辑来源：`/Users/john/Documents/trae_projects/bw-v3-504/src/projects/m1`

Flutter 工程能力参考：`/Users/john/Documents/trae_projects/flutter-v1`，仅参考网络、状态、模型、缓存、错误处理和平台能力等实现经验，不参考页面对接逻辑。

## 1. 暂停边界

当前不执行以下工作：

- 不把页面 Mock 数据替换为真实接口。
- 不修改登录态、Token 存储或路由拦截逻辑。
- 不新增接口请求依赖。
- 不提交、不推送、不更新 Git 状态。

当前允许的工作：

- 梳理接口对接顺序。
- 补充或校准模型字段。
- 标记接口依赖关系、风险和前置条件。
- 后续按本顺序逐步拆分实施任务。
- 对低风险只读接口做 Service、Provider、Model 和 UI fallback 的最小接入。

## 2. 总体原则

- 先搭底座，再接页面。
- 先保住 m1 高仿 UI，再替换业务数据。
- 先认证和全局配置，再接依赖登录态的业务。
- 先只读接口，再写操作接口。
- 先核心链路，再低频功能。
- 先无资金风险接口，再资金操作接口。
- 每处理一个页面或接口对接，都必须先参考接口文档和 m1 项目的 `views/**`、`api/**`、`router/index.js`，确认页面行为、请求参数和跳转规则。
- 旧 Flutter 项目只用于参考 Service/Provider/Model/缓存/错误处理、平台能力等 Flutter 工程实现方式，不用于决定页面对接逻辑。
- 每个阶段完成后必须格式化、静态分析，并尽量验证页面不破坏高保真 UI。

## 3. 阶段顺序

### Phase 0: 对接准备

目标：确认基础设施和模型可承载 66 个接口。

建议任务：

- 核对接口文档中的路径、请求方法、参数和返回结构。
- 对照 m1 `api/**` 和对应页面 `views/**`，确认接口在页面中的真实调用时机和入参来源。
- 建立接口清单与模型映射表。
- 按页面对接范围校准现有 `lib/models/` 字段，补齐 m1 页面实际使用的字段，暂不全量迁移未使用字段。
- 明确环境配置字段，例如 baseUrl、语言、币种、渠道、设备信息。

完成标准：

- 每个接口都有归属模块。
- 每个接口明确是否需要登录态。
- 每个接口明确响应类型或无需业务模型。
- 每个已对接页面都有对应强类型 Model；复杂响应兼容逻辑不放在 Screen。

模型更新要求：

- 对接页面前先读 m1 `views/**`，列出页面实际读取字段。
- 再读 m1 `api/**`，确认响应结构、分页结构、总计字段和兼容分支。
- Model 只补当前页面需要的字段；未知或暂未使用字段暂缓。
- 金额、状态、VIP、分页、列表总数等会影响页面判断的字段必须保留。
- 如果 m1 响应存在两种结构，例如 `data` 为数组或 `data.data` 为数组，兼容逻辑必须放在 `fromResponse` 或 Service decoder。
- Provider 不长期保存裸 Map；Screen 不直接解析接口原始 JSON。

### Phase 1: 网络与运行底座

目标：建立统一请求能力，但暂不接入页面。

状态：2026-04-30 已完成首轮底座落地，可进入验证和 Phase 2 前置确认。

建议任务：

- [x] 新增网络依赖，例如 `dio`。
- [x] 创建 `lib/api/dio_client.dart`。
- [x] 创建认证、错误、缓存相关 Interceptor。
- [x] 创建统一错误类型和请求结果处理方式。
- [x] 处理 Token 注入、401/登录失效、超时、业务错误码。
- [ ] 语言、币种、渠道、设备信息请求头待全局配置接口和后端规则确认后补齐。

完成标准：

- [x] Service 可以通过统一 client 发起请求。
- [x] Debug 日志不会输出敏感信息。
- [x] Release 不打印请求详情。

验证命令：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

### Phase 2: 启动与全局配置

状态：2026-04-30 已完成 `/system/getlist` 启动探针，Web 验证通过。下一步可将探针沉淀为正式启动配置加载，并选择 Banner 或公告做页面可视化读取。

优先接口：

- 获取全局参数
- 获取首页 Banner
- 获取首页公告
- 获取语言配置
- 获取币种配置
- 获取验证码配置
- 获取注册配置

目标：让 App 启动后具备基础配置、语言、站点信息和首页静态动态混合能力。

建议模块：

- `services/home/`
- `providers/system/`
- `providers/home/`

完成标准：

- [x] App 启动后能加载站点配置。
- 首页可读取配置和公告数据。
- [x] 失败时保留当前高保真 UI 的安全 fallback。

### Phase 3: 认证链路

优先接口：

- 登录
- 注册
- 退出登录
- 获取验证码
- 发送短信或邮箱验证码
- 忘记密码
- Telegram 登录
- 设置 Telegram 密码

目标：建立完整登录态生命周期。

建议模块：

- `services/auth/`
- `providers/auth/`
- Token 安全存储
- 路由登录拦截

完成标准：

- 登录成功后保存 Token。
- 退出登录后清理 Token 和用户态。
- 登录态失效时统一跳转登录页或显示登录弹窗。
- 注册字段根据全局配置动态展示。

### Phase 4: 用户中心基础信息

优先接口：

- 获取用户信息
- 修改用户信息
- 获取 VIP 信息
- 修改登录密码
- 设置或修改支付密码
- 站内消息列表
- 站内消息已读
- 反馈类型
- 提交反馈
- 反馈记录

目标：让个人中心、消息、账户安全具备真实数据。

建议模块：

- `services/user/`
- `providers/user/`
- `providers/message/`

完成标准：

- 登录后可刷新用户信息。
- 个人中心金额、等级、基础资料可展示。
- 消息和反馈页面具备分页和空状态。

### Phase 5: 游戏只读与启动链路

优先接口：

- 获取游戏分类
- 获取二级游戏分类
- 获取子游戏列表
- 获取推荐游戏
- 获取收藏游戏
- 收藏或取消收藏游戏
- 获取游戏余额
- 启动游戏

目标：接通首页、游戏大厅、游戏详情和启动游戏入口。

建议模块：

- `services/game/`
- `providers/game/`

完成标准：

- 游戏大厅支持真实分类和分页。
- 收藏状态能刷新。
- 启动游戏前处理登录态和余额检查。
- 游戏 URL、错误状态和维护状态有明确 UI fallback。

### Phase 6: 活动与内容

优先接口：

- 活动分类
- 活动列表
- 活动详情
- 申请活动
- 活动申请记录
- 单页分类
- 单页内容

目标：接入优惠活动、帮助中心、规则说明、静态内容页。

建议模块：

- `services/activity/`
- `providers/activity/`
- `services/content/`

完成标准：

- 活动列表和详情可展示接口内容。
- 申请活动有提交状态、错误提示和成功反馈。
- 富文本或 HTML 内容有统一渲染策略。

### Phase 7: 钱包只读接口

优先接口：

- 获取卡包列表
- 获取绑卡类型
- 获取充值分类
- 获取充值通道
- 获取充值详情
- 获取提现信息
- 获取充值记录
- 获取提现记录
- 获取转账记录
- 获取帐变记录

目标：先让钱包页面、记录页面具备真实查询能力。

建议模块：

- `services/wallet/`
- `providers/wallet/`
- `providers/record/`

完成标准：

- 钱包页能展示卡包、充值通道、提现基础信息。
- 记录列表支持筛选、分页、刷新和空状态。
- 金额、状态、时间格式统一。

### Phase 8: 钱包写操作接口

优先接口：

- 绑定银行卡或虚拟币地址
- 提交充值
- 上传充值凭证
- 取消充值
- 确认提现
- 一键回收余额
- 手动转入
- 手动转出
- 转账模式切换

目标：接入资金相关操作，必须在只读链路稳定后进行。

建议模块：

- `services/wallet/`
- `providers/wallet/`

完成标准：

- 表单校验完整。
- 支付密码、安全码、金额精度处理明确。
- 提交中防重复点击。
- 失败提示不泄露敏感信息。
- 成功后刷新余额和记录。

### Phase 9: 注单、反水与代理返利

优先接口：

- 注单记录
- 反水记录
- 领取反水
- 全民返利统计
- 全民返利列表
- 领取全民返利

目标：接入报表、返利和领取类接口。

建议模块：

- `services/record/`
- `providers/record/`
- `services/rebate/`
- `providers/rebate/`

完成标准：

- 报表筛选、分页、状态展示稳定。
- 领取动作有幂等保护和成功后刷新。
- 金额统计和列表明细一致。

### Phase 10: 收尾与质量验证

目标：统一体验、错误处理和边界状态。

建议任务：

- 统一 Loading、Empty、Error、Retry 组件。
- 检查所有列表分页和下拉刷新。
- 检查登录失效、弱网、接口错误、空数据。
- 检查 UI 溢出、长文本、多语言和小屏适配。
- 执行格式化、静态分析和必要测试。

完成标准：

- 核心页面不因接口异常白屏。
- 资金操作有防重复、防误触和明确状态反馈。
- 高保真 UI 未被业务接入破坏。

## 4. 建议接口优先级

P0 必须优先：

- 全局配置
- 登录
- 注册
- 退出登录
- 用户信息
- 首页 Banner 和公告
- 游戏分类
- 子游戏列表
- 启动游戏
- 充值分类和充值通道
- 提现信息

P1 第二批：

- VIP 信息
- 修改资料
- 修改密码
- 站内消息
- 活动列表和详情
- 卡包列表
- 充值记录
- 提现记录
- 注单记录
- 游戏余额

P2 第三批：

- 反馈
- 单页内容
- 收藏游戏
- 转账记录
- 帐变记录
- 反水记录
- 全民返利
- Telegram 登录相关接口

高风险接口：

- 提交充值
- 确认提现
- 上传充值凭证
- 绑定银行卡或虚拟币地址
- 手动转入、转出
- 领取反水或返利

这些接口必须在对应只读接口和登录态稳定后再接入。

## 5. 模型映射策略

已有模型目录：`lib/models/`

建议保持以下映射：

- 认证接口使用 `auth/auth_models.dart`。
- 用户接口使用 `user/user_models.dart`。
- 首页和全局配置使用 `home/home_models.dart`。
- 游戏接口使用 `game/game_models.dart`。
- 钱包接口使用 `wallet/wallet_models.dart`。
- 充值、提现、注单、反水、转账、帐变记录使用 `wallet/record_models.dart`。
- 活动接口使用 `activity/activity_models.dart`。
- 单页内容接口使用 `content/content_models.dart`。
- 上传图片等通用接口使用 `common/upload_models.dart`。
- 所有响应统一由 `core/api_response.dart` 和 `core/paginated_response.dart` 承载。

不要为了凑齐接口数量强行创建重复模型。接口数量和模型数量不是一一对应关系。需要显式标识 66 个接口覆盖关系时，优先在 Service 方法签名或接口映射表中体现。

## 6. 后续启动条件

只有满足以下条件后，才建议开启真实接口对接：

- 用户明确要求开始对接。
- 接口清单与模型映射表确认完成。
- baseUrl、环境、Token 规则和错误码规则确认完成。
- 网络依赖变更获得确认。
- 当前 UI 高保真页面无明显布局阻塞问题。

## 7. 当前进度记录

### 2026-04-30 全局配置启动探针

已完成：

- 开发域名默认切到 `https://apis.xh-demo.com/api`。
- 资源域名默认切到 `https://apis.xh-demo.com`。
- 新增 `SystemService.fetchConfig()`，请求 `POST /system/getlist`。
- 新增 `SystemProvider.loadConfig()`，维护加载、刷新、错误和 fallback 状态。
- 复用 `HomeConfig` 解析全局配置响应。
- App 启动首帧后触发 `SystemProvider.loadConfig()`。
- Debug 控制台输出 `[startup-probe] system config loaded: ...`。
- `/system/getlist` 保持 header `lang: CN`，不追加 query `lang`。
- 用户已通过 `curl` 和 Web App 验证接口探针通过。

验证命令：

```bash
flutter analyze lib test
flutter test test/widget_test.dart
```

当前结果：

- `flutter analyze lib test`：`No errors`。
- `flutter test test/widget_test.dart`：`6 tests passed`。

### 2026-05-03 首页公告可视化接入

已完成：

- 首页公告栏开始读取 `SystemProvider.config.notices`。
- 多条公告按 `   |   ` 拼接展示，并清理简单 HTML 标签和 `&nbsp;`。
- 接口公告为空、配置加载失败或字段为空时，继续显示原静态高保真公告文案。
- 页面只消费 `SystemProvider`，不直接调用 Service 或 Dio。
- 本次只接入首页公告一个低风险只读区域，不扩大到登录、注册、钱包或资金操作。

验证命令：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

当前结果：

- `dart format lib test`：已执行通过。
- `flutter analyze lib test`：`No errors`。
- `flutter test test/widget_test.dart`：`9 tests passed`。

### 2026-05-04 用户信息接口闭环接入

已完成：

- 新增 `UserService.fetchProfile()`，请求 `POST /token/user` 并解析接口返回的 `data` 数组首项为 `UserProfile`。
- `UserProvider` 从空壳改为维护 `profile`、加载、刷新和错误状态，并支持 `clearProfile()`。
- App 启动恢复 Token 后会尝试加载用户信息；无登录态时不请求用户信息。
- 登录和注册成功保存 Token 后，会继续拉取用户信息再跳转目标页面。
- 退出登录后清理 `AuthProvider` 与 `UserProvider`，避免残留用户资料、余额和等级。
- 个人中心只小范围读取真实用户头像、用户名、账号 ID、VIP 等级、钱包余额和金融符号；接口为空或失败时继续保留原静态 fallback。
- 本次不进入充值、提现、转账、绑卡等资金写操作，也不批量替换页面 Mock 数据。

验证命令：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

当前结果：

- `dart format lib test`：已执行通过。
- `flutter analyze lib test`：`No errors`。
- `flutter test test/widget_test.dart`：`9 tests passed`。
- 备注：官方测试工具在当前 Flutter 版本下会注入不兼容的 `--chain-stack-traces` 参数，本次使用同等 shell 命令完成测试验证。

### 2026-05-04 VIP 权益列表接入

已完成：

- 新增 `ApiEndpoints.vipList = '/vip/getlist'`。
- 新增 `VipLevel` 模型，覆盖接口文档中的 `charge_level`、`flowing_level`、礼金、提现限制、充值限制和各游戏品类返水字段。
- 新增 `UserService.fetchVipLevels()`，请求 `POST /vip/getlist`，解析并按 `VIP` 等级数字升序排序。
- `UserProvider` 新增 `vipLevels`、`isVipLevelsLoading`、`isVipLevelsRefreshing` 和 `vipLevelsError` 状态。
- `VipScreen` 进入页面后加载 VIP 权益列表；接口成功时用真实等级权益、提现限制和返水比例渲染。
- `VipScreen` 继续使用 `/token/user.level_data` 展示当前用户升级进度，`/vip/getlist` 仅负责等级权益列表。
- 接口为空或失败时继续使用原静态 VIP 权益 fallback，不破坏页面结构。
- 本次仍限定在 VIP 只读信息，不进入充值、提现、转账、绑卡等资金写操作。

验证命令：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
flutter build web
```

当前结果：

- `dart format lib test`：已执行通过。
- `flutter analyze lib test`：`No errors`。
- `flutter test test/widget_test.dart`：`9 tests passed`。
- `flutter build web`：已执行通过，生成 `build/web`。

### 2026-05-03 首页 Banner 可视化接入

已完成：

- 首页顶部 Banner 开始读取 `SystemProvider.config.banners`。
- 当前最小实现只展示接口返回的第一张有效 Banner 图片，不新增轮播依赖。
- Banner 图片通过 `AppNetworkImage` 加载，支持资源域名补全、placeholder 和失败兜底。
- 接口 Banner 为空、图片字段为空或图片加载失败时，继续显示原静态高保真 Banner 图。
- Banner 点击只处理站内路径跳转；外部链接暂不打开，仅在 Debug 输出轻量提示，避免引入额外依赖和行为风险。
- 本次仍限定在首页低风险只读区域，不进入写操作或资金链路。

验证命令：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

当前结果：

- `dart format lib test`：已执行通过。
- `flutter analyze lib test`：`No errors`。
- `flutter test test/widget_test.dart`：`9 tests passed`。

### 2026-05-03 首页站点信息可视化接入

已完成：

- 首页 App 下载条开始读取 `SystemProvider.config.siteConfig`。
- 下载条标题优先使用站点标题，描述优先使用 `app_desc`，否则使用站点描述。
- 下载条图标优先使用 `app_icon`，否则使用站点 `logo`，加载失败时保留原静态 Vite 图标。
- 首页顶部左侧站点品牌区优先使用站点 `logo`、`title` 和 `domain`，为空或加载失败时保留静态 fallback。
- 首页顶部右侧域名胶囊优先使用站点 `domain`，为空时保留静态 fallback。
- 下载按钮暂不发起外部跳转，仅在 Debug 输出下载链接，避免新增外部链接依赖和行为风险。
- 本次继续限定在 `/system/getlist` 已有配置数据消费，不新增接口。

验证命令：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

当前结果：

- `dart format lib test`：已执行通过。
- `flutter analyze lib test`：`No errors`。
- `flutter test test/widget_test.dart`：`9 tests passed`。

### 2026-05-04 游戏大厅分类与厂商列表只读接入

已完成：

- 对照 m1 `views/main/Game.vue`、`api/interface.js` 的页面逻辑，补齐游戏大厅只读链路。
- 新增 `GameLobbyCategory` 和 `GameProviderItem`，保留 m1 页面实际使用的 `code`、`title`、`img`、`se_img`、`h5_logo`、`status_s`、`category`、`type`、`label` 等字段。
- `GameService` 新增 `fetchInterfaceClasses()`，对接 `POST /interface/class`。
- `GameService` 新增 `fetchInterfaceList(code)`，对接 `POST /interface/list`，并按 m1 逻辑优先使用 `type == code` 的厂商列表。
- `GameProvider` 新增分类、分类 loading、按 code 加载厂商列表和失败 fallback 状态。
- `GameScreen` 优先展示真实分类和厂商列表；接口为空或失败时继续显示原 m1 高仿 UI mock fallback。
- 本次只接游戏大厅只读数据，不接进入游戏、收藏、搜索、转账或资金相关操作。

验证命令：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

当前结果：

- `dart format lib test`：已执行通过。
- `flutter analyze lib test`：`No errors`。
- `flutter test test/widget_test.dart`：`9 tests passed`。

### 2026-05-04 游戏子列表首屏只读接入

已完成：

- 对照 m1 `components/GameSubList.vue`、`api/gamelist.js`，补齐子游戏列表首屏只读链路。
- `GameService` 新增 `fetchGameList()`，对接 `POST /gamelist/getlist`，请求参数包含 `page`、`size`、`code`、`game`、`search_word`。
- `GameProvider` 新增 `subListPage`、`isSubListLoading`、`subListError` 和 `loadGameSubList()`。
- `GameItem` 补齐 m1 子列表使用的收藏状态和维护状态字段解析。
- `GameScreen` 跳转 `/game-sub` 时携带 `code`、`game`、`title` query 参数，对齐 m1 `GameSubList` props。
- `GameSubListScreen` 优先展示真实子游戏列表；接口为空、参数缺失或失败时继续使用原 m1 高仿 UI mock fallback。
- 本次只接首屏只读列表，不接分页加载、搜索、收藏写操作、进入游戏或资金相关操作。

验证命令：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

当前结果：

- `dart format lib test`：已执行通过。
- `flutter analyze lib test`：`No errors`。
- `flutter test test/widget_test.dart`：`9 tests passed`。

### 下一次任务执行方式

每开始一个接口对接任务，按以下顺序执行：

1. 查 `.opencode/docs/bw-pc-api-v2（适配h5）接口文档.md`，确认接口路径、请求方法、Header、Query、Body、认证、响应结构、错误码。
2. 查 m1 项目 `/Users/john/Documents/trae_projects/bw-v3-504/src/projects/m1` 中对应 `views/**`、`api/**`、`router/index.js`，确认页面对接逻辑、入参来源、调用时机和跳转规则。
3. 如需参考 Flutter 工程实现，再查旧 Flutter 项目 `/Users/john/Documents/trae_projects/flutter-v1` 中对应 Service、Provider、Model、缓存或错误处理方式；不得按旧 Flutter 页面逻辑迁移。
4. 在新项目按模块补齐最小 Service 方法、Provider 状态和必要模型字段。
5. 若接 UI，只替换一小块低风险数据，并保留当前 m1 高仿 UI fallback。
6. 不在 Service 中写 Toast、路由跳转或依赖 `BuildContext`。
7. 不打印 token、密码、验证码、支付链接、提现参数、request body、response body 等敏感信息。
8. 完成后运行 `dart format lib test`、`flutter analyze lib test`、`flutter test test/widget_test.dart`。

建议下一步：

- 优先补齐用户中心基础信息的低风险只读区域，例如账户设置绑定状态。
- 游戏大厅分类、厂商列表和子游戏首屏列表已完成最小只读接入。下一步可继续接推荐游戏、子列表搜索/分页或用户中心低风险只读字段。
- 暂不进入充值、提现、转账、绑卡等资金写操作。

## 8. 接续用压缩上下文

当前可接续结论：

- 网络底座已经可用，不需要重建 Dio、Interceptor、TokenStorage、Service/Provider 基类。
- 当前真实域名使用 `https://apis.xh-demo.com/api`，资源域名使用 `https://apis.xh-demo.com`。
- `/system/getlist` 已接入 `SystemService.fetchConfig()` 和 `SystemProvider.loadConfig()`。
- Web 启动探针已经通过，Debug 日志形如 `[startup-probe] system config loaded: title=..., languages=..., banners=...`。
- 当前首页、个人中心、VIP、游戏大厅分类、厂商列表和子游戏首屏列表已有小范围真实接口数据消费，其余页面仍以 m1 高仿 UI fallback 为主。
- 当前验证基线：`flutter analyze lib test` 无错误，`flutter test test/widget_test.dart` 为 9 个测试通过。

下次不要重复做：

- 不要重新搭建网络层。
- 不要重新定义全局配置模型，优先复用 `HomeConfig`。
- 不要把 `/system/getlist` 加 query `lang`。
- 不要批量替换首页、游戏、钱包、活动等页面 Mock 数据。
- 不要重建认证链路或进入充值、提现、转账等高风险资金链路。

下次优先做：

- 选择用户中心低风险只读字段、VIP 信息或游戏只读列表继续小步接入。
- 接口数据为空或失败时继续显示当前 m1 高仿 UI fallback。
- 页面只读消费 Provider，不让页面直接调用 Service 或 Dio。
- 完成后跑格式化、分析和测试。
