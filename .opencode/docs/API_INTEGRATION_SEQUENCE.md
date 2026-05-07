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

### 2026-05-07 用户中心与主导航 m1 对齐

已完成：

- 账户安全绑定状态接入 `/token/user` 只读展示，设置/个人资料中根据实名、手机、邮箱和资金密码字段展示当前状态。
- 已绑定手机号/邮箱进入绑定页时展示只读状态卡；已实名时实名认证页禁用输入框和提交按钮。
- `CustomTextField` 支持 `enabled`，`CustomButton.onPressed` 支持 `null` 禁用态。
- 登录密码修改对接 m1 `POST /token/repass`，请求参数为 `currentPass`、`newPass`、`confirmpass`。
- `/setting` 和 `/user-profile` 按 m1 `Setting.vue`、`UserProfile.vue` 拆分职责；头像/用户信息入口和“注册信息”入口进入 `/user-profile`。
- 个人资料页 QQ、Telegram 改为行内输入并通过底部保存按钮统一提交。
- 消息中心对接 `POST /notify/getlist` 和 `POST /notify/status`，支持全部/未读/已读 Tab、未读红点、下拉刷新、滚动分页、点击未读标记已读，并保留 fallback mock。
- “我的”页顶部补齐邮件和设置图标，邮件图标显示未读红点，分别跳转 `/message` 和 `/setting`。
- `/profile`、`/activity`、`/service` 补齐底部导航并高亮当前 Tab。
- 主 Tab 切换使用 `context.go(...)`，对齐 m1 `van-tabbar-item replace to="..."` 的 replace 行为。
- 主 Tab 路由 `/`、`/game`、`/activity`、`/service`、`/profile` 已改为 `NoTransitionPage`，底部导航点击切换时不再出现从右到左页面滑动动画。
- 保留详情页、资金页、设置页、消息页等非主 Tab 默认转场，不改变普通页面进入/返回体验。

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

后续注意：

- 当前主 Tab 底部导航仍由多个页面分别持有 `CustomTabBar`；如果继续扩展主框架，建议用 `ShellRoute` 或统一 Layout 收敛重复维护。
- 头像上传、关于我们内容页、手机号/邮箱验证码发送真实接入仍未完成。

### 2026-05-07 反馈类型、提交反馈与反馈记录接入

已完成：

- 对照 m1 `views/user/Feedback.vue`、`views/user/FeedbackRecords.vue`、`api/feedback.js` 和接口文档补齐反馈链路。
- 新增 `ApiEndpoints.feedbackTypeList = '/feedback_type/getlist'`。
- 新增 `ApiEndpoints.feedbackSubmit = '/feedback/to'`。
- 新增 `ApiEndpoints.feedbackList = '/feedback/getlist'`。
- 补齐 `FeedbackType`、`SubmitFeedbackRequest`、`FeedbackRecord`、`FeedbackRecordPage`。
- `UserService` 新增 `fetchFeedbackTypes()`、`submitFeedback()`、`fetchFeedbackRecords()`。
- 新增 `FeedbackProvider`，维护反馈类型、提交状态、反馈记录分页、加载更多和 fallback。
- `FeedbackScreen` 进入后加载反馈类型，分类弹窗优先展示接口分类，提交时按 m1 参数 `id`、`text`、`img` 调用真实接口。
- `FeedbackRecordsScreen` 优先展示真实反馈记录，支持下拉刷新、滚动分页、空态、处理中/已处理状态和回复内容展示。
- 接口失败时继续保留原高仿 fallback 分类和反馈记录，避免页面白屏。
- 图片上传仍保持当前占位 UI，暂不接上传接口；提交参数 `img` 为空。

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

后续注意：

- 需要用真实账号验证 `/feedback/getlist` 的 `data.lastPage`、`data.current_page` 和 `img` 字段是否与当前模型完全一致。
- 图片上传接口尚未接入，反馈提交暂不携带图片。
- m1 反馈记录页面本地存储提交记录；Flutter 当前改为真实记录优先、fallback 兜底。

### 2026-05-07 手机号/邮箱验证码发送与绑定提交接入

已完成：

- 对照接口文档和 m1 `BindPhone.vue`、`BindEmail.vue` 补齐账户安全绑定链路。
- 手机验证码发送使用 `POST /phone_code/send`，参数为 `type: 2`、`area_code: '+86'`、`phone`。
- 邮箱验证码发送使用 `POST /mail_code/send`，参数为 `type: 2`、`email`。
- 绑定提交继续走已接入的 `POST /user/edit`，手机号参数为 `phone`、`area_code`、`code`，邮箱参数为 `email`、`code`。
- `UserProvider` 复用 `AuthService.sendSmsCode()` 和 `AuthService.sendEmailCode()`，新增 `sendPhoneCode()`、`sendEmailCode()`。
- `BindPhoneScreen` 点击获取验证码时真实调用短信验证码接口，成功后才启动倒计时。
- `BindEmailScreen` 点击获取验证码时真实调用邮箱验证码接口，成功后才启动倒计时。
- 绑定成功后刷新 `/token/user` 的用户资料并返回上一页。
- 已绑定手机/邮箱仍保持只读状态卡，不展示绑定表单。

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

后续注意：

- 需要用真实账号验证 `/user/edit` 接收手机/邮箱绑定验证码时字段名是否确认为 `code`，因为接口文档仅列出手机号/邮箱字段，绑定验证码字段来自当前页面既有实现。
- 当前手机绑定区号固定为 `+86`，后续如需多国家区号，应接全局配置或区号选择组件。

### 2026-05-07 实名认证提交接入确认

已完成：

- 对照 m1 `views/user/RealName.vue` 确认实名认证提交使用资料编辑接口。
- Flutter `RealNameScreen` 未实名时提交真实姓名，已实名时保持只读/禁用状态。
- 新增 `UserProvider.submitRealName(realName)` 专用封装，内部复用 `POST /user/edit` 提交 `real_name`。
- 提交成功后沿用 `UserProvider.updateProfile()` 的刷新逻辑，重新拉取 `/token/user`。
- 提交中禁用按钮，避免重复提交。
- 接口失败使用现有表单错误提示，不破坏页面。

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

后续注意：

- 需要用真实账号确认 `/user/edit` 提交 `real_name` 后 `/token/user.real_name` 是否立即更新。
- 当前实名认证仅对齐 m1 的真实姓名提交，没有身份证号、证件照片等额外字段。

### 2026-05-07 VIP 信息只读展示完善

状态：已对接完毕。

已完成：

- 对照 m1 `views/user/Vip.vue` 和 `api/vip.js` 确认 VIP 页面为只读信息展示。
- 继续使用已接入的 `POST /vip/getlist` 拉取 VIP 等级、升级条件、福利、返水和累计充值/流水。
- Flutter `VipScreen` 保持升级进度、等级 tab、福利表、返水表、升级说明展示。
- `/profile` 顶部 VIP 标签补齐点击入口，点击进入 `/vip`，对齐 m1 顶部 VIP tag 行为。
- `VipScreen` 增加下拉刷新，刷新时重新调用 `/vip/getlist`。
- `VipScreen` 增加加载提示；真实接口失败且没有等级数据时展示 fallback 提示，并继续显示默认等级规则，避免页面白屏。
- 当前改动仅为只读展示和刷新，不涉及 VIP 购买、充值、升级支付或资金写操作。

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

后续注意：

- 需要用真实账号确认 `/vip/getlist` 返回结构是否为数组或嵌套分页对象，以及 `total_deposit`、`total_bet` 位置是否与当前兼容解析一致。
- 需要确认 `title` 是否稳定包含 VIP 等级数字，例如 `VIP1`、`VIP2`。
- VIP 相关资金门槛当前仅展示，不触发充值/提款等资金流程。

修正记录：

- 真实账号测试发现 `/vip` 充值进度当前值不应优先使用 `/vip/getlist.total_deposit`，而应使用 `/token/user` 用户资料中的 `recharge`。
- `UserProfile` 已补充解析 `recharge` 字段。
- `VipScreen` 当前充值计算优先级调整为：`level_data.recharge` -> `profile.recharge` -> `total_recharge` -> `total_deposit` -> `recharge_amount` -> `/vip/getlist.total_deposit`。
- 当前等级计算同步使用该当前充值值，避免因为 `/vip/getlist.total_deposit` 与用户资料不一致导致进度和当前等级错误。

完成确认：

- 真实账号验证后确认 VIP 页面当前阶段对接完毕。
- `/profile` 顶部 VIP 入口、`/vip/getlist` 等级规则、`/token/user.recharge` 当前充值进度、下拉刷新、加载提示和 fallback 展示均已完成。

### 2026-05-07 关于我们只读页面接入

状态：已对接完毕。

已完成：

- 对照 m1 `views/user/Setting.vue` 确认“关于我们”在 m1 目前只有设置页静态 cell，无点击事件、无独立页面、无专属 API。
- Flutter 新增 `/about-us` 登录保护路由，并从 `/setting` 的“关于我们”入口跳转进入。
- 复用已接入的 `POST /system/getlist` 和 `SystemProvider.config.siteConfig`，读取 `config_site.title`、`logo`、`desc`、`domain`、`app_version`、`app_download`、`service_link`、`tg_link`。
- 新增 `AboutUsScreen` 只读展示站点 Logo、站点名称、平台介绍、域名、版本、APP 下载、客服入口和 TG 客服。
- 页面支持下拉刷新重新调用系统配置；接口失败或字段为空时展示 fallback 内容，避免页面白屏。
- 当前页面仅展示链接文本，不主动打开外链，不涉及资金、登录态写入或敏感操作。

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

### 2026-05-07 头像上传接入

状态：已对接完毕，待真实账号上传验证。

已完成：

- 对照 m1 `views/user/UserProfile.vue` 确认头像入口为 `van-uploader`，m1 当前逻辑只做本地预览并在保存时通过 `/user/edit.img` 提交，没有调用真实上传接口。
- 对照接口文档确认通用图片上传接口为 `POST /img/save`，`form-data` 参数为 `file` 和 `name`，响应包含 `data.data.path` 与 `data.data.url`。
- Flutter 新增依赖 `image_picker`，用于从相册选择头像图片。
- 新增 `ApiEndpoints.imageUpload = '/img/save'`。
- `UserService.uploadImage()` 使用 `MultipartFile.fromBytes` 上传图片，兼容移动端和 Web 的 `XFile.readAsBytes()`。
- `UserProvider.uploadAvatar()` 先调用 `/img/save`，再用返回的 `url` 或 `path` 调用 `/user/edit` 保存 `img`，最后刷新 `/token/user`。
- `/user-profile` 头像行由占位提示改为真实选择、上传、保存流程，并展示 `上传中...` 状态。

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

后续注意：

- 需要用真实账号验证 `/img/save` 在当前域名下返回的 `url/path` 是否可直接提交给 `/user/edit.img`。
- 若真实接口只接受相对路径，应保留 `path` 优先；当前实现优先使用 `url`，再 fallback 到 `path`。
- 反馈图片上传后续可复用 `UserService.uploadImage()` 或抽成通用上传服务。

### 2026-05-07 客服页 m1 对齐

状态：已对齐完毕，待真实客服链接点击验证。

已完成：

- 对照 m1 `views/main/Service.vue` 确认客服页不新增专属接口，复用 `POST /system/getlist` 的 `config_site.service_link` 与 `config_site.tg_link`。
- `ServiceScreen` 从静态 mock 联系方式改为读取 `SystemProvider.config.siteConfig` 和 `UserProvider.profile`。
- 页面结构对齐 m1：顶部白色问候卡片展示头像和 `Hi，用户名`，下方两列渐变客服卡片展示在线客服和 Telegram 通道。
- 兼容 `service_link`、`tg_link` 的数组、字符串、多行、逗号、中文逗号和空白分隔格式。
- 新增 `url_launcher` 依赖，用于点击客服/Telegram 卡片时打开系统外部浏览器或对应 App。
- 支持下拉刷新重新加载系统配置；无客服配置时展示空态提示，避免白屏。
- 当前仍不涉及充值、提现、转账、绑卡等资金写操作。

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

后续注意：

- 需要用真实账号/真实配置验证 `service_link`、`tg_link` 是否都带 `http://` 或 `https://` scheme。
- 若后台返回无 scheme 的客服链接，需和后端确认是否应自动补 `https://`。
- 关于我们页面后续如需要点击客服/TG 链接，可复用本次引入的外链打开能力。

### 2026-05-07 反馈页图片上传与溢出修复

状态：已对齐完毕，待真实账号上传验证。

已完成：

- 对照 m1 `views/user/Feedback.vue` 重新确认反馈页结构：问题分类、问题描述、最多 3 张图片、提交按钮、反馈记录入口。
- 修复问题类型选择弹窗溢出：将直接铺开的 `Column + ListTile` 改为带最大高度约束的 `ListView.separated`，分类过多时可滚动，长分类名单行省略。
- 反馈图片区域从占位按钮改为真实上传：支持选择多张图片，最多 3 张。
- 复用通用上传接口 `POST /img/save`，上传参数 `name = feedback`。
- `FeedbackProvider` 新增 `isUploadingImage` 和 `uploadFeedbackImage()`，页面不直接调用 `UserService`。
- 上传成功后展示图片缩略图，支持删除已选图片。
- 提交反馈时将上传后的图片地址以逗号拼接传给 `/feedback/to.img`。
- 保留纯文字反馈能力；图片选择组件未加载或上传失败时只提示错误，不阻断无图提交。

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

后续注意：

- 新增/使用图片选择插件后，运行中 App 需要完整重启，不能只 hot reload。
- 需要用真实账号验证 `/img/save` 返回的 `url/path` 是否都可作为 `/feedback/to.img` 的提交值。
- 若后台要求相对路径，需将反馈图片保存逻辑和头像保存逻辑统一改为 `path` 优先。

### 2026-05-07 活动页只读链路接入

状态：已完成只读接入，活动申请写操作暂缓。

已完成：

- 对照 m1 `views/main/activity.vue`、`views/main/ActivityDetail.vue` 和 `api/activity.js` 确认活动主链路。
- 接入 `POST /activity/class` 获取活动分类。
- 接入 `POST /activity/list` 获取活动列表，分类切换时传 `id`，全部分类不传 `id`。
- 接入 `POST /activity/details` 获取活动详情，传活动 `id` 后从返回数组中匹配详情。
- 新增 `ActivityCategory`、`ActivityItem` 模型，解析 `id`、`title`、`img`、`content`、`type`、`multiple`、`lasting`、`start_time`、`end_time`。
- 补齐 `ActivityService` 和 `ActivityProvider`，页面不直接调用接口。
- `ActivityScreen` 从静态 mock 改为真实分类 tab + 真实活动卡片，顶部品牌区域读取 `SystemProvider.config.siteConfig`，并保留 fallback 活动列表。
- `ActivityDetailScreen` 通过 query `id` 加载详情，展示标题、发放方式、倍数、活动时间和活动说明。
- 手动活动详情底部仍展示“申请参与活动”，但点击仅提示 `活动申请功能待接入`，不调用 `/activity/apply`。

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

后续注意：

- 需要用真实账号验证 `/activity/list` 和 `/activity/details` 返回结构是否稳定为数组。
- 当前详情内容只做 HTML 标签剥离后纯文本展示；若后续需要完全还原富文本图片/table，需要引入安全 HTML 渲染方案。
- 活动申请 `/activity/apply` 和活动申请记录 `/activity/record` 属于后续弱写/只读任务，本次未接提交。

### 2026-05-07 活动申请记录只读接入

状态：已完成只读接入。

已完成：

- 对照 m1 `views/main/ActivityApplyRecords.vue` 和 `api/activity.js` 确认活动申请记录链路。
- 接入 `POST /activity/record`，请求参数为 `page`、`size`。
- 新增 `ActivityRecordPage` 和 `ActivityApplyRecord` 模型，解析 `username`、`status`、`apply_time`、`title`、`current_page`、`lastPage`、`total`。
- `ActivityService` 新增 `fetchActivityRecords()`。
- `ActivityProvider` 新增活动申请记录状态、分页、下拉刷新和加载更多。
- `ActivityRecordScreen` 从静态 mock 改为真实申请记录列表。
- 状态文案对齐 m1：`1` 申请中、`2` 已通过、`3` 已拒绝、其他未知状态。
- 支持空态、下拉刷新、滚动分页、底部“没有更多了”和接口失败 fallback。

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

后续注意：

- 需要用真实账号验证 `/activity/record` 是否在无记录时返回空分页对象或 `null`。
- 活动申请提交 `/activity/apply` 暂未接入，仍保留为后续弱写操作。
- 如果继续完善活动页，下一步可做详情富文本安全渲染或活动申请提交。

### 2026-05-08 活动详情富文本安全渲染

状态：已完成只读 UI 增强，无新增接口，无新增依赖。

已完成：

- 对齐 m1 `ActivityDetail.vue` 中 `v-html="safeHtml"` 的活动说明展示方式。
- `ActivityDetailScreen` 从纯文本剥离 HTML 改为轻量安全 HTML 渲染。
- 移除 `script`、`style`、`on*` 事件属性和 `javascript:` 链接/图片地址。
- 支持常见段落、换行、列表、表格单元文本降级展示。
- 支持活动说明中的 `<img src="...">`，图片复用 `AppNetworkImage`，不直接使用裸 `Image.network`。
- 非 HTML 内容仍按普通文本展示；空内容仍展示 `暂无活动内容`。

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

后续注意：

- 当前为轻量渲染，不执行 HTML，不加载 iframe/script/style。
- 表格目前降级为文本行展示；如真实活动大量使用复杂表格，后续再做专门表格布局。
- 活动申请提交 `/activity/apply` 仍未接入。

### 2026-05-08 活动申请提交接入

状态：已完成弱写操作接入。

已完成：

- 对齐 m1 `ActivityDetail.vue` 的 `handleApply()` 逻辑。
- 接入 `POST /activity/apply`，请求参数为当前手动活动 `id`。
- `ActivityService` 新增 `applyActivity(id)`。
- `ActivityProvider` 新增 `isApplying`、`applyError` 和 `applyActivity(id)`。
- `ActivityDetailScreen` 手动活动底部按钮从占位提示改为真实提交。
- 提交中按钮显示 `申请中...` 并禁用重复点击。
- 申请成功显示 `申请成功`。
- 申请失败显示后端业务错误信息，兜底为 `申请失败`。
- 申请成功后清空活动申请记录缓存，下次进入记录页重新拉取 `/activity/record`。

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

后续注意：

- 需要用真实手动活动验证重复申请、未登录/过期、已申请等后端业务错误文案。
- 当前成功提示使用本地 `申请成功`，如后续需要完全展示后端 `msg`，需要调整 `DioClient` 以保留完整响应 envelope。

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
- 当前首页、个人中心、VIP、游戏大厅分类、厂商列表、子游戏首屏列表、消息中心和反馈链路已有小范围真实接口数据消费，其余页面仍以 m1 高仿 UI fallback 为主。
- 当前主 Tab 路由 `/`、`/game`、`/activity`、`/service`、`/profile` 使用 `NoTransitionPage`，底部导航点击为无动画 replace 式切换。
- 当前验证基线：`flutter analyze lib test` 无错误，`flutter test test/widget_test.dart` 为 9 个测试通过。

下次不要重复做：

- 不要重新搭建网络层。
- 不要重新定义全局配置模型，优先复用 `HomeConfig`。
- 不要把 `/system/getlist` 加 query `lang`。
- 不要批量替换首页、游戏、钱包、活动等页面 Mock 数据。
- 不要重建认证链路或进入充值、提现、转账等高风险资金链路。
- 不要把主 Tab 切换改回 `push` 或默认路由转场；m1 对齐要求是无感 replace 式切换。

下次优先做：

- 选择用户中心低风险只读字段、VIP 信息或游戏只读列表继续小步接入。
- 或继续接入游戏收藏/搜索等非资金链路能力。
- 接口数据为空或失败时继续显示当前 m1 高仿 UI fallback。
- 页面只读消费 Provider，不让页面直接调用 Service 或 Dio。
- 完成后跑格式化、分析和测试。
