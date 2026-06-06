# API Integration Sequence

本文档用于规划当前 Flutter 主工程的接口对接顺序。目标不是单纯把接口接通，而是让已经按 m1 项目制作的高仿 Flutter UI 在当前工程中具备真实业务能力，并逐步补齐合格 Flutter 项目的工程能力。

接口来源：`docs/bw-pc-api-v2（适配h5）接口文档.md`

架构规范：`docs/NEW_FRONTEND_ARCHITECTURE_GUIDE.md`

UI 和页面对接逻辑来源：`/Users/john/Documents/trae_projects/bw-6-2/src/projects/m1`

m1 术语约定：本文档及本项目所有任务中，“m1”“m1 项目”或“bw-6-2 参考项目”均固定指向 `/Users/john/Documents/trae_projects/bw-6-2/src/projects/m1`，不得使用 bw-6-2 的其他子项目、旧 Flutter 项目或其他相似目录替代。

Flutter 工程能力参考：`/Users/john/Documents/trae_projects/flutter-v1`，仅参考网络、状态、模型、缓存、错误处理和平台能力等实现经验，不参考页面对接逻辑。

## 1. 当前任务边界

当前任务目标已经从“规划接口对接顺序”调整为“完成 m1 核心业务闭环收尾”。主体页面已基本具备 Flutter 对应实现，后续重点是把 m1 写操作、真实数据和关键交互补齐到当前 Flutter 架构中。

当前允许并优先执行以下工作：

- 把已定义但未接到页面的 m1 接口接入 `Provider -> Screen`。
- 补齐写操作的 loading、success、error、防重复提交和刷新逻辑。
- 校准模型字段，避免 Screen 直接解析原始 Map。
- 已补齐 m1 少数交互模块：右侧搜索弹窗、游戏最小化浮窗、公告弹窗增强、充值失败页；下一阶段进入 P2 路由与联调细节。
- 按完成项同步更新本文档、`ENGINEERING_BUSINESSIZATION_PLAN.md` 和 `docs/UI_REPLICA_PROGRESS.md`。

当前仍不主动执行以下工作：

- 不重做已完成高仿 UI。
- 不整包复制 m1 Vue template/CSS。
- 不把旧 Flutter 项目作为页面业务逻辑来源。
- 不主动提交、不推送、不更新 Git 状态，除非用户明确要求。

## 1.1 当前收尾进度快照

- 页面覆盖：m1 主体路由页面基本已有 Flutter 对应实现；`/deposit/failed/:id` 充值失败页已补齐。
- endpoint 覆盖：m1 主要 API 已基本定义在 `ApiEndpoints`。
- service/model 覆盖：提现、删卡、分享返利、今日收益、返水领取、找回密码、Telegram 等闭环所需 service/model 已补齐。
- P0/P2 闭环：提现提交、银行卡删除、找回密码、Telegram 登录、分享返利、游戏返水领取、我的页今日收益已完成 `Provider -> Screen` 一轮接入；本轮已追加找回密码多方式、修改资金密码旧密码输入、提现取款密码输入和兑换码页面闭环。
- 优先方向：P1 交互体验补齐已完成；P2 深链、邀请参数、系统配置 terminal、活动语言参数和关键模型字段兼容校准已完成；上线安全硬化已启动，当前已补齐 URL policy、外链校验、游戏承载 URL 拦截和禁用全局写操作自动重试，接下来做真实账号冒烟、Web token 风险治理和部署安全策略。

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
- 游戏一级分类列表图片布局以 bw-6-2 m1 `views/main/Game.vue` 的 `.provider-grid` / `.provider-cover` 为准：一级分类图片容器不设置固定高度或正方形比例；子游戏列表的正方形规则不得套用于一级分类列表。

## 3. 阶段顺序

### Current Closing Sequence: m1 业务闭环收尾

当前优先执行顺序如下，优先级高于历史 Phase 描述中的旧规划口径：

1. **P0 Provider 状态层补齐**

- [x] `WalletProvider`：接入提现提交和银行卡删除状态。
- [x] `AuthProvider`：接入找回密码、Telegram 登录和设置密码状态。
- [x] `UserProvider`：接入今日收益、分享返利信息和领取返利状态。
- [x] `GameManagementProvider`：接入游戏返水一键领取状态。

2. **P0 页面业务闭环**

- [x] `WithdrawScreen`：接 `/drawing/order`，替换 `comingSoon`。
- [x] `BankCardListScreen`：接 `/member_bank/delete`，增加删除确认和刷新。
- [x] `ResetPasswordScreen`：接 `/code/send`、`/password/get`。
- [x] `ResetPasswordScreen`：按 m1 补齐手机号、邮箱、真实姓名 + 取款密码三种找回方式，支持确认新密码和手机号区号选择。
- [x] `ShareScreen`：接 `/retabe/list`、`/retabe/amount`，移除静态金额/会员/邀请码/链接。
- [x] `GameManagementScreen`：启用 `/member_fs_log/claim`。
- [x] `ProfileScreen`：接 `/day_revenue/getlist`。
- [x] `WithdrawScreen`：补齐 6 位取款密码输入、校验和 `pay_password` 提交。
- [x] `WithdrawPasswordScreen`：已设置资金密码时补齐旧取款密码输入框和本地校验，接口仍按 m1 只提交新 `pay_password`。
- [x] `RedemptionCodeScreen`：新增 `/redemption-code` 页面与入口，接 `/redemption/code`、`/redemption/getlist`，支持提交、粘贴、记录、刷新和空态。

3. **P1 m1 交互体验补齐**

- [x] 首页/游戏/活动搜索改为页面内右侧全屏弹窗体验，并接入搜索历史、热门/全部/收藏、分页、收藏和游戏启动。
- [x] 游戏承载页补齐最小化、浮窗恢复、跨页面保留游戏状态。
- [x] 公告弹窗补齐富文本、图片、跳转和按公告粒度本地关闭状态。
- [x] 补齐 `/deposit/failed/:id` 充值失败页。

4. **P2 路由与联调细节**

- [x] Telegram query 拦截：任意路由出现 `user_id`、`username` 时转 `/telegram-login` 并保留 redirect；Telegram 登录页已按 m1 自动登录并处理首次登录默认设密。
- [x] 邀请/refcode query 持久化。
- [x] `/system/getlist` 与 m1 `{ terminal: 2 }` 规则对齐。
- [x] `/activity/details?lang=CN` 规则兼容。
- [x] `DayRevenueSummary`、`WithdrawOrderResult`、Telegram 登录/设密相关字段按 m1 响应包装和页面使用规则完成兼容校准。

5. **P2 m1 517 剩余字段与机制差异**

- [x] `LoginScreen`：补齐 m1 `m1_login_fail_count`、`config_pic.login_error`、失败 3 次后图形验证码、成功清零机制。
- [x] `LoginScreen`：补齐手机号登录区号选择器，提交 `area_code` 使用选择值。
- [x] `LoginScreen`：短信/邮箱验证码发送后应用后端返回的 `captcha_key/captcha_img/captcha_code`。
- [x] `BindPhoneScreen`：补齐国际区号，避免固定 `+86`；中国区号保留中国手机号正则，其他区号使用通用数字长度校验。
- [ ] `ActivityService`：真实接口冒烟确认 `/activity/details` 的 `lang=CN` 固定规则或当前语言规则。
- [x] `WalletService.uploadCardImage`：`/img/save` 的 `name` 参数已按 m1 调整为 `recharge`；仍需真实接口冒烟确认。
- [x] `BindCardRequest`：绑定银行卡/支付宝时已带已实名姓名 `name` 字段，兼容后端可能校验姓名的场景。
- [ ] `SystemService/HomeConfig`：补强 m1 同等级配置 URL 归一化，覆盖 logo、app、客服、banner、notice 跳转等字段。
- [ ] Router：复核匿名白名单和 m1 一致，确认新增 `/redemption-code` 等页面必须登录。

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

状态：2026-05-10 已完成卡包列表、绑卡类型、提现页基础只读信息接入；充值分类/通道/详情仍待接入。

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

- [x] 钱包页和卡包页能展示真实卡包列表。
- [ ] 充值页能展示真实充值分类、通道和详情。
- [x] 提现页能展示余额、卡包、VIP 提现规则、流水锁定和取款密码状态。
- 记录列表支持筛选、分页、刷新和空状态。
- 金额、状态、时间格式统一。

### Phase 8: 钱包写操作接口

状态：2026-05-10 已完成绑卡、二维码上传和一键归户接入；提交充值、确认提现、手动转入/转出仍后置。

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

- [x] 绑卡表单具备基础校验和提交中防重复点击。
- [ ] 支付密码、安全码、金额精度处理明确。
- [x] 已接入的写操作具备提交中防重复点击。
- 失败提示不泄露敏感信息。
- [x] 绑卡成功后刷新卡包列表。
- [x] 一键归户成功后刷新余额。
- [ ] 充值/提现写操作成功后刷新余额和记录。

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

### 2026-05-08 游戏子列表搜索、分页与收藏接入

状态：已完成非资金链路接入，进入游戏仍后置。

已完成：

- 对照 m1 `components/GameSubList.vue`、`api/gamelist.js` 和 `api/favorites.js` 确认游戏子列表交互。
- 子游戏列表继续使用 `POST /gamelist/getlist`，请求参数包含 `page`、`size`、`code`、`game`、`search_word`。
- 新增 `ApiEndpoints.gameFavorite = '/user_favorites/game'`。
- `GameService.setGameFavorite()` 接入收藏/取消收藏，请求参数为 `id` 和 `status`。
- `GameProvider` 新增当前搜索词匹配、收藏提交中状态和 `toggleGameFavorite()`，收藏成功后局部更新当前列表中的收藏状态。
- `GameSubListScreen` 搜索按钮从占位改为真实搜索栏，输入 300ms debounce 后重新请求首屏列表，关闭搜索栏时清空搜索并恢复列表。
- 远程子游戏列表收藏按钮改为真实提交；未登录时提示先登录，不调用接口。
- 保留已有滚动分页加载更多逻辑；收藏 Tab 仍基于当前已加载列表过滤，不额外批量请求资金或启动游戏接口。
- 本次清理了游戏页和主页面中的未使用字段/import，保持 `flutter analyze` 无 warning。

验证命令：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

当前结果：

- `dart format lib test`：已执行通过。
- `flutter analyze lib test`：`No issues found!`。
- `flutter test test/widget_test.dart`：已执行通过，当前为 `9 tests passed`。

后续注意：

- 需要用真实账号验证 `/user_favorites/game` 对 `id/status` 的业务规则和重复点击返回文案。
- 收藏 Tab 当前展示当前已加载列表中的收藏项；如后端后续提供独立“我的收藏”分页接口，再单独接入。
- 进入游戏 `/game/login`、游戏余额和场馆转账仍属于后续链路，本次不接入。

### 2026-05-08 首页推荐游戏只读接入

状态：已完成只读接入，推荐游戏启动已接入。

已完成：

- 对照接口文档确认推荐游戏接口为 `POST /interface/reco`。
- 对照 m1 `views/main/Home.vue` 和 `api/interface.js` 确认首页推荐游戏展示逻辑。
- 新增 `RecommendedGame` 模型，解析 `id`、`code`、`game`、`gamecode`、`title`、`img`、`label`、`status_s`、`favorites`。
- `GameService.fetchRecommendedGames()` 接入 `POST /interface/reco`。
- `GameProvider` 新增推荐游戏列表、加载状态、错误状态和 `loadRecommendedGames()`。
- `HomeScreen` 进入后加载推荐游戏，推荐游戏区优先展示接口图片和标题。
- 接口为空、失败或未加载成功且无可见数据时不展示推荐游戏模块，不使用原静态推荐游戏 fallback UI。
- 推荐游戏图片继续使用 `AppNetworkImage`，支持资源域名补全和失败兜底。
- 推荐游戏“更多”入口跳转游戏大厅。
- 点击推荐游戏已接入 `/game/login`，复用统一启动规则：未登录跳登录、维护中不请求、提交中防重复、`nesting=false` 外部打开、其他情况进入 `/game-view`。
- 推荐游戏卡片启动中展示遮罩、spinner 和 `启动中...`。
- 推荐游戏数据源已增加 m1 兼容 fallback：优先使用 `POST /interface/reco`，为空或失败时回退到 m1 的 `POST /interface/list` 并筛选 `label` 包含 `reco` 的项目。
- 推荐游戏项若 `category == 1`，按 m1 逻辑进入子游戏列表，不直接调用 `/game/login`。

验证命令：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

当前结果：

- `dart format lib test`：已执行通过。
- `flutter analyze lib test`：`No issues found!`。
- `flutter test test/widget_test.dart`：已执行通过，当前为 `9 tests passed`。

后续注意：

- 需要用真实接口验证 `/interface/reco` 是否稳定返回数组，以及图片字段是否为 `img` 或 `h5_logo`。
- 需要用真实账号验证首页推荐游戏点击是否能正常请求 `/game/login` 并打开游戏。
- 需要验证 `/interface/reco` 为空或失败时，`/interface/list` + `label=reco` fallback 是否返回 m1 一致推荐游戏。

### 2026-05-08 游戏启动最小接入

状态：已完成最小启动链路，已补齐内嵌承载页；资金相关能力后置。

已完成：

- 对照接口文档确认启动游戏接口为 `POST /game/login`，参数为 `id`、`mobile: 1`。
- 对照 m1 `api/game.js`、`views/main/Game.vue`、`components/GameSubList.vue` 确认进入游戏行为：未登录跳登录、维护中提示、提交中防重复、成功后根据 `url/nesting` 打开游戏。
- `GameLaunchResult` 补齐 `nesting` 字段解析。
- 新增 `GameLaunchTarget`，统一承载启动所需 `id/title`。
- `GameProviderItem`、`GameItem`、`RecommendedGame` 补齐 `launchTarget`。
- `GameService.launchGame()` 接入 `/game/login`。
- `GameProvider` 新增 `launchingGameId`、`launchError` 和 `launchGame()`。
- 游戏大厅非子列表厂商卡片点击时：未登录跳 `/login`，已登录调用 `/game/login`。
- 子游戏列表卡片点击时：未登录跳 `/login`，已登录调用 `/game/login`。
- 启动中展示卡片遮罩和 `启动中...`，避免重复点击。
- 参考旧 Flutter 项目 `GameViewScreen`，新增跨平台 `/game-view` 游戏承载页。
- 移动端使用 `webview_flutter` 承载游戏 URL，Web 端使用 iframe `HtmlElementView` 承载游戏 URL。
- 成功拿到 URL 后进入 `/game-view`，不再外跳到首页或停留在游戏大厅底栏。
- 二级分类非子列表游戏和子游戏列表卡片均走同一启动路径。
- 新增依赖 `webview_flutter` 和直接依赖 `web`，用于游戏内嵌承载。
- 本次不接游戏余额、场馆转入/转出、一键回收或资金相关接口。

验证命令：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

当前结果：

- `dart format lib test`：已执行通过。
- `flutter analyze lib test`：`No issues found!`。
- `flutter test test/widget_test.dart`：已执行通过，当前为 `9 tests passed`。

后续注意：

- 需要用真实账号验证 `/game/login` 成功、维护中、未登录、商户密钥错误、无 URL、WebView/iframe 加载失败等场景。
- 当前 `/game-view` 为独立页面承载，不带主 Tab 底栏；若后续需要 m1 弹层最小化浮窗，再单独实现。
- 游戏余额和场馆资金操作仍后置，不与启动链路混做。

### 2026-05-08 游戏管理只读记录接入

状态：已完成只读接入，领取返水写操作后置。

已完成：

- 对照 m1 `views/user/GameManage.vue`、`api/gameRecord.js`、`api/memberFsLog.js`。
- 接入返水记录 `POST /member_fs_log/getlist`。
- 接入游戏记录 `POST /gamerecord/getlist`。
- 新增 `GameManageQuery`、`RebateRecordPage`、`RebateRecord`、`GameRecordPage`、`GameBetRecord`。
- 新增 `GameManagementService`。
- 新增 `GameManagementProvider`，支持日期范围、首屏加载、下拉刷新、滚动分页和错误状态。
- `GameManagementScreen` 从 mock 列表改为真实数据；接口返回空数组时展示空态，不再显示静态 fallback 记录。
- 日期快捷筛选区改为横向滚动，修复本月/上月在窄宽度下 RenderFlex 溢出。
- 记录页 UI 进一步贴近 m1：压缩日期卡片、Tab、统计卡片和记录卡片的垂直密度；空态不再展示列表 footer。
- 记录模型增加 payload 类型保护：返水记录只解析 `fs_money`、`bl`、`created_at` 等 `/member_fs_log/getlist` 字段；游戏记录只解析 `betAmount`、`validBetAmount`、`netAmount`、`betTime` 等 `/gamerecord/getlist` 字段，避免两个 `getlist` 响应在 UI 上混用。
- 日期快捷筛选支持今天、昨日、本月、上月。
- 返水记录展示总返水、已领取、未领取、返水金额、有效金额、领取状态。
- 游戏记录展示注单笔数、投注金额、有效金额、盈亏、结算状态。
- m1 的 `claimMemberFsLog()` 领取返水属于写操作，本次不接入，按钮保留禁用状态。

验证命令：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

后续注意：

- 需要用真实账号验证 `/member_fs_log/getlist` 和 `/gamerecord/getlist` 的分页字段、合计字段和空态。
- 领取返水 `/member_fs_log/claim` 属于弱写但涉及金额状态，后置单独接入。

### 下一次任务执行方式

### 2026-05-08 m1 路由兼容与维护页

状态：已完成路由基础对齐，资金写操作仍后置。

已完成：

- 当前 Flutter 初始路由从 `/login` 调整为 `/`，对齐 m1 未登录可先进入首页的入口体验。
- 保留现有 Flutter 路径，同时新增 m1 alias 路由，避免站内链接、后端配置链接或 Telegram redirect 使用 m1 路径时落到错误页。
- 新增 m1 兼容路径：`/game/sub`、`/game/play`、`/activity/detail/:id`、`/activity/records`、`/feedback/records`、`/user/UserProfile`、`/user/real-name`、`/user/withdrawpassword`、`/user/change-password`、`/user/bind-phone`、`/user/bind-email`、`/card`、`/card/add`、`/game-manage`、`/fund-manage`、`/deposit/online-pay`、`/deposit/order/:id`、`/deposit/success/:id`、`/withdraw/success`。
- 补齐登录保护遗漏，支持精确路径和动态前缀保护，例如 `/activity/detail/:id`、`/deposit/order/:id`、`/deposit/success/:id`。
- 新增 `/maintenance` 和 `MaintenanceScreen`。
- `SystemProvider` 改为复用全局 `DioClient`，避免系统配置请求绕过统一 token/lang/interceptor 行为。
- `GoRouter` 同时监听 `AuthProvider` 和 `SystemProvider`；当 `/system/getlist.config_site.status == 0` 时全局跳转 `/maintenance?redirect=...`，维护恢复后返回 redirect 或首页。

验证命令：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

后续注意：

- 需要用真实配置验证 `config_site.status = 0` 时是否能进入维护页，恢复为非 0 后是否能回到原 redirect。
- 当前 `/game/play` alias 直接映射到 `/game-view` 独立承载页；如需 m1 popup/minimize 交互，需要后续单独实现。
- 资金相关写操作继续后置。

### 2026-05-08 游戏承载页 m1 基础对齐

状态：已完成 `/game-view` 基础承载体验对齐，floating 小窗后置。

已完成：

- 对照 m1 `Game.vue`、`GameSubList.vue` 和 `GamePlay.vue`，补齐 `nesting === false` 时外部打开逻辑。
- 游戏大厅非子列表游戏和子游戏列表启动成功后，如果后端返回 `nesting: false`，使用 `url_launcher` 外部打开游戏 URL。
- `nesting` 缺省或非 `false` 时继续进入 `/game-view` 内嵌承载。
- 新增 `GameViewShell`，统一移动端、Web 和 stub 的顶部黑色承载栏。
- `/game-view` 顶部对齐 m1：黑色 34px header、左侧标题、中间站点 Logo、右侧关闭按钮。
- 移动端 WebView 保持 unrestricted JavaScript，增加无效 URL 和加载失败错误状态、重新加载入口。
- Web iframe 补齐 m1 参数：`allow="fullscreen; autoplay; picture-in-picture"`、`sandbox="allow-same-origin allow-scripts allow-forms allow-popups allow-top-navigation-by-user-activation"`、`allowfullscreen`、`webkitallowfullscreen`、`mozallowfullscreen`。

后续注意：

- 需要真实验证 `nesting: false` 外部打开和 `nesting: true` 内嵌承载。
- 当前仍为独立 `/game-view` 页面，不是 m1 页面内 popup；最小化 floating 小窗后置。

### 2026-05-10 钱包卡包、提现只读与充值全链路接入

状态：已完成 Phase 7 钱包部分只读接入，并完成卡包绑定与充值链路写操作；提现提交、手动转入/转出和领取类写操作仍后置。

已完成：

- 对照 m1 `CardList.vue`、`AddCard.vue`、`Withdraw.vue`、`Deposit.vue` 和 `api/drawing.js`、`api/bank.js`、`api/memberBank.js` 梳理钱包链路。
- 卡包列表接入 `POST /drawing/getlist`，银行卡/虚拟币/支付宝列表优先展示真实数据。
- 银行卡列表移除静态 fallback，真实数据为空时展示空态，接口失败时展示错误重试。
- 银行卡列表页只调用 `WalletProvider.loadCards()`，不再同时调用 `/bank/getlist`，避免进入页面触发额外请求。
- 绑卡类型接入 `POST /bank/getlist`，添加卡页面按当前 tab 懒加载 `type: 1|2|3`，不一次性请求三类。
- 新增 `POST /member_bank/binding` 绑定卡包链路，提交字段对齐 m1：`id`、`card`、`addres`、`alias`、`img`。
- 添加银行卡/虚拟币/支付宝页面支持真实提交，提交中禁用按钮，成功后刷新卡包列表并返回上一页。
- 实名规则按 m1 对齐：银行卡和支付宝需要实名，虚拟币不强制实名。
- 虚拟币和支付宝支持二维码上传，复用 `POST /img/save`，上传参数 `name = member_bank`，提交时优先使用返回 `path`，fallback `url`。
- 修复添加卡页面类型选择点击无反应；点击文字或箭头均可弹出底部选择器，类型未加载时先刷新加载。
- 类型选择底部抽屉补齐搜索、选中态、空态和圆角卡片 UI。
- 提现页接入 `POST /drawing/getlist`、`POST /user/balance`、`POST /token/user`、`POST /vip/getlist` 的只读数据。
- 提现页展示真实可提现余额、收款卡包、当前 VIP 最低提现/每日次数/每日额度、流水锁定进度和取款密码状态。
- 提现页支持下拉刷新，同时刷新卡包、实时余额、用户资料和 VIP 等级。
- 提现页“一键归户”复用已接入的场馆余额回收能力，成功后刷新余额。
- “确认提现”仍不调用 `POST /drawing/order`，当前仅提示 `提现提交功能待接入`。
- 充值/提现页面按 m1 做 UI 精修：浅灰背景、区块标题、金额输入、快捷金额、卡包卡片、规则卡片和胶囊按钮。
- 充值分类接入 `POST /deposit/class`，充值通道接入 `POST /deposit/getlist`，金额输入/固定金额/混合金额按通道 `amount_type` 和 `amount` 真实配置展示。
- 充值提交接入 `POST /recharge/order`，请求字段对齐 m1：`id` 为通道 ID，`money` 为充值金额；提交前校验通道、金额、最小/最大限额和固定金额选项。
- 充值订单创建成功后按 m1 处理 `type == 1` 在线支付：`nesting == false` 外部打开支付 URL，否则进入 `/deposit/online-pay`；普通订单跳转 `/deposit/order/:id`。
- 充值详情接入 `POST /recharge/details`，`/deposit/order/:id` 和 `/deposit-detail?id=xxx` 均支持加载真实详情。
- 充值详情页已按 m1 `DepositOrderDetail.vue` 重构为渐变背景、状态金额卡、二维码卡、支付信息卡、风险提示、凭证上传卡和取消支付底部弹窗。
- 上传充值凭证接入 m1 链路：先调用 `POST /img/save` 且 `name = recharge` 上传图片，再调用 `POST /recharge/img` 提交 `{id,img}`；虚拟币 `type == 3` 支持交易哈希模式提交 `{id,hash}`。
- 取消充值接入 `POST /recharge/cancel`，底部弹窗填写 `note` 后提交 `{id,note}`，成功后本地订单状态更新为已取消并返回充值页。
- 钱包页场馆模式开关修复 loading 出现/消失时横向错位问题。
- 提现页顶部可提现余额卡片改为 `Stack` 布局，固定高度压缩到 `112.h`，避免卡片过高并对齐提现金额卡片视觉密度。

验证命令：

```bash
dart format lib test
flutter analyze lib test
flutter test test/widget_test.dart
```

当前结果：

- `dart format`：已执行通过。
- `flutter analyze` / 官方分析工具：`No errors`。
- `flutter test test/widget_test.dart`：已执行通过，当前为 `9 tests passed`。

后续注意：

- 需要用真实账号验证 `/img/save` 返回的 `path/url` 是否都可用于 `/member_bank/binding.img`。
- 需要真实验证银行卡、虚拟币和支付宝绑定时，后端是否接受当前字段组合和 `addres` 拼写。
- 需要真实验证提现页 `/vip/getlist` 的提现规则字段和 `/token/user` 的流水字段是否与当前解析完全一致。
- 需要真实账号验证充值分类、通道、创建订单、详情、凭证上传、哈希提交和取消支付在不同通道类型下的完整闭环。
- 确认提现 `/drawing/order`、手动转入/转出、领取返水/返利仍属于后续资金写操作。

### 2026-05-11 资金记录页 m1 对齐收尾

状态：已完成记录页业务对齐收尾；后续只需真实账号验收接口字段和空态。

已完成：

- 对照 m1 `views/user/FundManage.vue`、`api/tradeRecord.js`、`api/transfersLog.js`、`api/moneyLog.js`。
- `/fund-management`、`/fund-manage`、`/fund-records`、`/transaction-records` 支持 m1 query tab 参数，`withdraw/drawing/1` 打开提现记录，`transfer/transfers/2` 打开转账记录，`account/bill/money/3` 打开账户明细。
- 记录页默认查询范围从“本月”改为“今天”，对齐 m1 默认 `today`。
- 记录页请求时间改为完整区间：`YYYY-MM-DD 00:00:00` 到 `YYYY-MM-DD 23:59:59`，对齐 m1 `rangeParams()`。
- 充值/提现状态文案对齐 m1：`1` 成功，`0` 已超时，`5` 充值中/处理中，`2` 人工确认，`3` 用户取消，`4` 已拒绝。
- 记录金额使用用户资料 `symbol`，无值时 fallback `¥`，不再硬编码固定币种。
- 充值/提现金额去掉强制正负号，贴近 m1 直接金额展示；转账和账户明细仍保留出入账正负方向。
- 提现备注仅在失败类状态展示，避免正常提现记录出现误导性备注。
- 提现页右上“提现记录”入口改为 `/fund-management?tab=withdraw`，直接打开提现记录 Tab。
- 记录页金额文本增加单行省略，降低小屏和长币种符号下的溢出风险。
- Web 启动短命令确认为 `./run_web.sh`，内部使用 `flutter run -d chrome --no-web-resources-cdn`，用于规避 CanvasKit/字体资源访问 Google CDN 失败。

验证结果：

- `dart format`：已执行通过。
- 官方分析工具：`No errors`。
- `flutter test test/widget_test.dart`：已执行通过，当前为 `9 tests passed`。
- `./run_web.sh`：已成功启动 Chrome 调试，启动探针 `/system/getlist` 正常返回。

后续注意：

- 需要真实账号验证 `/trade/record`、`/transfers_log/getlist`、`/money_log/getlist` 的分页字段、状态码、币种、空态和真实订单展示。
- 记录页属于真实业务数据页面，不建议失败时展示静态假记录；后续如需增强，可加“加载失败，下拉重试”的轻量错误态。
- 当前筛选 chips 使用横向滚动以防窄屏溢出，没有完全照搬 m1 `flex-wrap`；除非验收要求极限复刻，否则不建议大改。
- 当前 Tab 保持 Flutter 卡片化视觉，不完全照搬 m1 `van-tabs` 下划线样式；与项目现有资金页视觉统一。

### 2026-05-11 首页数据接入与分类区 m1 高保真复刻

状态：已完成首页主要真实数据接入和分类区高保真复刻；剩余语言切换弹窗、公告弹窗和游戏浮窗最小化可后置。

已完成：

- 对照 m1 `views/main/Home.vue`、`api/system.js`、`api/interface.js`、`api/gamelist.js` 和 `api/game.js`。
- 首页启动时加载 `/interface/class`、推荐游戏和热门游戏，分类数据、推荐游戏、热门游戏均通过 `GameProvider` 消费。
- 推荐游戏保持已有兼容数据源逻辑；最终 UI 对齐 m1 首页 `v-if="recoGameList.length > 0"`，无可见数据时不展示推荐模块，不使用静态 mock/fallback UI。
- 热门游戏按 m1 接入 `POST /gamelist/getlist`，参数 `page=1`、`size=30`、`label=hot`；最终 UI 对齐 m1 首页 `v-if="hotGameList.length > 0"`，无可见数据时不展示热门模块，不使用静态 mock/fallback UI。
- 首页 Banner 从单图改为轮播，解析 `config_banner.terminal` 和 `lang`，只展示 `terminal == 2` 且语言匹配 `CN` 的 Banner；支持 3 秒自动切换和指示点。
- Banner 点击补齐真实跳转：外链使用 `url_launcher` 打开，内链使用 `GoRouter` 跳转。
- APP 下载按钮从 debug log 改为真实打开 `config_site.app_download/apk_download`。
- 安全域名点击复制 `config_site.domain`，复制成功后显示 SnackBar。
- 用户余额刷新图标补齐点击逻辑，刷新 `/token/user` 和 `/user/balance` 对应的用户资料/实时余额。
- 首页分类卡片接入 `/interface/class` 真实标题，点击跳转 `/game?code=...`。
- 分类区图片确认与 m1 一致使用本地静态资源：`zr.png`、`cp.png`、`dz.webp`、`ty.webp`、`by.webp`、`qp.png`、`dj.webp`。
- 分类区按 m1 截图高保真复刻：上方左右两列、左侧真人大卡、右侧彩票/电子两张中卡、底部四张小卡；补齐 `Live`、`Lottery`、`Slot` 浅蓝英文背景字。
- 分类区比例按 m1 调整：真人图区约 `148.h`，文字区约 `92.h`；中卡右图约 `70.w`，小卡约 `86.h`，图片约 `52.w`。
- 修复分类区多处 RenderFlex 底部溢出：真人文字区、中卡描述、小卡图片/标题均增加弹性约束、字号和行高压缩。
- 修复热门游戏卡片中 `context.select` 在 builder helper 内触发 Provider Web debug 断言的问题，改为父级读取 `launchingGameId` 后传参。
- 修复小卡 `SizedBox` 误用 `decoration` 导致的编译错误，改回 `Container`。

验证结果：

- `dart format`：已执行通过。
- 官方分析工具：`No errors`。
- `flutter test test/widget_test.dart`：已执行通过，当前为 `9 tests passed`。
- `./run_web.sh` 热重启后已验证首页接口请求链路：`/system/getlist`、`/interface/class`、`/interface/reco`、`/gamelist/getlist`。

后续注意：

- Web 控制台仍可能出现 `EncodingError: The source image cannot be decoded`，需用真实返回图片 URL 排查是哪张远端图片解码失败；本地分类图片资源本身可用。
- m1 多语言底部弹窗、`config_notice.pop_up` 公告弹窗、“今日不再提示”和游戏浮窗最小化仍后置。
- 分类区当前为视觉高保真优先，若后端分类标题变长，仍通过短标题映射和省略号避免溢出。

### 2026-05-12 多语言方案约束与后续优先级

状态：多语言架构方向已确认，前端静态 UI 文案多语言已完成收尾；后续不再把“全项目 Flutter 专属语言包体系建设”作为首位任务。多语言仅保留校验、视觉走查和新增页面文案补齐，当前开发优先级转入 P1 m1 交互补齐：右侧搜索弹窗、游戏最小化浮窗、公告弹窗增强和充值失败页。

多语言硬性规则：

- Flutter 运行时语言包 `assets/i18n/*.json` 只允许维护 Flutter 自己实际使用的 key，例如 `common.*`、`nav.*`、`home.*`、`auth.*`、`game.*`、`activity.*`、`profile.*`、`finance.*`。
- 不要在 `assets/i18n/*.json` 里同时塞 m1 全量 key 和 Flutter key；禁止把 m1 `main.*`、`page.*`、`user.*` 等全量结构长期混入 Flutter 运行时语言包。
- m1 语言包只作为翻译来源和语义参考，不能作为 Flutter 的运行时 key 结构。
- 后续应建立 `m1 key -> Flutter key` 的映射脚本或映射表，从 m1 `CN/TW/MY/EN/JP/KR/TH/VN` 抽取翻译值，生成 Flutter 专属语言包。
- Flutter 静态语言文件名继续使用 locale 风格：`zh-CN.json`、`zh-TW.json`、`my-MM.json`、`en-US.json`、`ja-JP.json`、`ko-KR.json`、`th-TH.json`、`vi-VN.json`。
- 接口请求语言继续使用 m1 业务 code：`CN/TW/MY/EN/JP/KR/TH/VN`，由 `AppLanguage` 负责 locale 与业务 code 映射。
- 切换语言后，所有新接口请求 header `lang` 必须使用当前业务 code；`/system/getlist` 仍不要追加 query `lang`。
- 新增页面多语言时，优先定义 Flutter key；只有翻译值可以参考 m1，不要为了复用 m1 翻译而强行在 Flutter 代码里使用 m1 Vue key。

多语言后续维护项：

- 新增页面或弹窗时继续使用 Flutter 专属 key，不直接沿用 m1 Vue key。
- 保持 `assets/i18n/*.json` 与 `en-US.json` key 集合一致，并通过 `tool/i18n/validate_i18n.js` 校验。
- 继续做真实浏览器多语言视觉走查，重点验证长文本、按钮、Tab、小屏和非拉丁语言溢出。
- m1 非中文语言包本身存在 `...CN` 继承，未覆盖字段会保留中文；后续新增翻译值时必须标记或补齐未翻译字段，不能误认为已完整翻译。

当前首位任务：P1 m1 交互补齐

- 首页、游戏、活动搜索入口从独立 `/search` 页面优先改为 m1 右侧全屏弹窗体验，并抽离现有 `SearchScreen` 内容为可复用组件。
- 游戏承载补齐最小化、跨页面浮窗恢复和关闭逻辑，对齐 m1 `GamePlay.vue`。
- 首页公告弹窗继续增强富文本、图片公告、跳转规则和按公告 ID/日期控制“今日不再提示”。
- 补齐 `/deposit/failed/:id` 充值失败页，或将失败态路由映射到现有结果页。

首页 m1 完整对齐任务：

- 首页语言切换底部弹窗静态文案已接入 `.tr()`；后续只做全语言视觉验收，验证切换语言后静态文案、Banner 过滤和新接口请求 header 同步变化。
- `config_notice.pop_up` 公告弹窗、排序规则、`terminal` 过滤和“今日不再提示”已接入；后续继续做富文本/图片/跳转规则和样式走查。
- 首页搜索需要从路由跳转优先改为 m1 右侧全屏弹窗形态。
- 游戏启动后续评估从独立 `/game-view` 扩展为 m1 首页内右侧全屏 popup，并补最小化浮窗。
- 首页分类描述文案建议使用 Flutter 专属 key，例如 `home.category.liveDesc`、`home.category.lotteryDesc`、`home.category.slotDesc`，不要沿用 m1 硬编码缺陷。

每开始一个接口对接任务，按以下顺序执行：

1. 查 `docs/bw-pc-api-v2（适配h5）接口文档.md`，确认接口路径、请求方法、Header、Query、Body、认证、响应结构、错误码。
2. 查 `/Users/john/Documents/trae_projects/bw-6-2/src/projects/m1` 中对应 `views/**`、`api/**`、`router/index.js`，确认页面对接逻辑、入参来源、调用时机和跳转规则。
3. 如需参考 Flutter 工程实现，再查旧 Flutter 项目 `/Users/john/Documents/trae_projects/flutter-v1` 中对应 Service、Provider、Model、缓存或错误处理方式；不得按旧 Flutter 页面逻辑迁移。
4. 在新项目按模块补齐最小 Service 方法、Provider 状态和必要模型字段。
5. 若接 UI，只替换一小块低风险数据，并保留当前 m1 高仿 UI fallback。
6. 不在 Service 中写 Toast、路由跳转或依赖 `BuildContext`。
7. 不打印 token、密码、验证码、支付链接、提现参数、request body、response body 等敏感信息。
8. 完成后运行 `dart format lib test`、`flutter analyze lib test`、`flutter test test/widget_test.dart`。

建议下一步：

- 首位任务：进入 P1 m1 交互补齐，优先做右侧全屏搜索弹窗；抽离 `SearchScreen` 内容为复用组件，并接入首页、游戏、活动入口。
- 第二优先级：游戏内嵌弹窗/最小化浮窗，补全跨页面恢复和关闭状态。
- 第三优先级：公告弹窗增强和 `/deposit/failed/:id` 充值失败页。
- 多语言仅作为新增 UI 的配套维护和视觉走查，不再作为当前首位开发任务。
- 或用真实账号验收资金记录页 `/trade/record`、`/transfers_log/getlist`、`/money_log/getlist`，确认分页、状态码、空态和币种展示。
- 记录验收通过后，再评估接入确认提现 `POST /drawing/order`；必须先确认真实卡包、余额、VIP 规则和流水锁定字段稳定。

## 8. 接续用压缩上下文

### 2026-06-05 我的收入页 m1 对齐

状态：已完成个人中心今日收益卡片和收入页业务对齐；后续需真实账号验证返佣领取接口返回文案和佣金字段。

已完成：

- 对照 m1 `views/user/Profile.vue` 和 `views/user/Income.vue`。
- `DayRevenueSummary` 扩展并严格按 m1 解析 `total_no_fs`、`total_no_fy`、`day_zongfy`、`day_lingqu_fy`、`day_weiling_fy`；可领金额不使用 `total_fs/total_fy` fallback，避免偏离 m1 字段语义。
- 个人中心今日收益卡片按 m1 调整：
  - 注单笔数进入 `/game-manage?tab=rebate`。
  - 可领返水使用 `total_no_fs` 展示并进入 `/income`。
  - 可领佣金使用 `total_no_fy` 展示并进入 `/income`。
- `GameManagementScreen` 从双 Tab 补齐为 m1 三 Tab：
  - 返水记录：`/member_fs_log/getlist`，统计 `total_fs_money/yes_fs_money/not_fs_money`。
  - 返佣记录：`/fy/getlist`，统计 `totalFsMoney/receivedFsMoney/unreceivedFsMoney`，列表字段 `bl/money/fs_money/status`。
  - 游戏记录：`/gamerecord/getlist`，统计 `total/total_betAmount/total_validBetAmount/total_netAmount`。
- `/game-manage?tab=fy/game` 路由参数按 m1 映射到返佣和游戏记录 Tab，返水/返佣底部领取分别调用 `/member_fs_log/claim` 和 `/fy/claim`。
- `/fy-level` 按 m1 `FyLevel.vue` 接入 `POST /fy/level`，字段使用 `vip_name` 和 `lottery_bl/games_bl/poker_bl/live_bl/sport_bl/fishing_bl`，只展示真实接口数据。
- `/vip` 返水比例继续按 m1 `/vip/getlist` 字段 `sport_bl/live_bl/games_bl/poker_bl/fishing_bl/gaming_bl/lottery_bl` 展示，百分比格式对齐 m1。
- 个人中心日期按 m1 `user.profile.dateMD` 语义补为 Flutter `profile.dateMD`。
- 新增 `/income` 路由和 `IncomeScreen`，按 m1 分为“可领返水”和“可领返佣”两块面板。
- 返水领取接入 `/member_fs_log/claim`；返佣领取接入 `/fy/claim`；收入页进入和领取成功后均刷新 `/day_revenue/getlist`，避免页面只展示旧缓存。
- 收入页记录入口对齐 m1：返水记录进入 `/game-manage?tab=rebate`，返佣记录进入 `/game-manage?tab=fy`。
- 收入页“我的团队”入口已接 `/team`，新增团队页按 m1 调用 `/team/getlist`，参数 `page`、`size`、`username`，展示 `username` 和 `betamount`。
- 收入页三格结算布局使用有界 Row 对齐，避免滚动列表内无界高度导致白屏或 Web `mouse_tracker` 连锁断言。
- 新增 `income.*` 和 `profile.netProfit` 全语言 key，并通过 `tool/i18n/validate_i18n.js` 校验；`locale_keys.g.dart` 已重新生成。

验证结果：

- `node tool/i18n/validate_i18n.js`：通过，8 个语言文件、866 个 key 对齐。
- `flutter analyze lib/screens/user/income_screen.dart lib/screens/user/user_screens.dart lib/router/app_router.dart lib/router/route_paths.dart`：无问题。
- `flutter analyze lib test`：仍仅剩既有 9 条告警/提示，未引入新的收入页问题。

### 2026-06-05 VIP 金额符号修正

状态：已修正 VIP 页面金额文案误用账户 `currency` 字段的问题。

已完成：

- 对照 m1 `views/user/Vip.vue`，确认 VIP 金额展示使用本地货币符号，默认 `¥`。
- Flutter `VipScreen` 的金额格式化对用户资料 `symbol` 和 `currency` 都做合法符号/常见货币代码映射。
- 未知或非符号型 `symbol/currency` 值（例如 `k`）不再直接拼到“升级还需充值”“升级条件”“VIP 福利”等金额文案前，统一回退为 `¥`。

验证结果：

- `dart format lib/screens/user/user_screens.dart`：通过。
- `flutter analyze lib/screens/user/user_screens.dart`：无问题。

后续注意：

- `/vip` 已有页面可跳转；`/fy-level`、`/team` 当前仍未实现，如后续验收要求完整 m1 收入页右侧提示入口，需要继续补页面或改为“即将上线”。
- `/fy/claim` 的真实成功/失败文案由接口错误拦截直接透传；建议用真实账号验证金额为 0、有可领返佣、接口失败三种场景。
- `/team/getlist` 建议用真实账号验证分页字段 `current_page/lastPage/total` 和成员字段 `username/betamount`。

当前可接续结论：

- 网络底座已经可用，不需要重建 Dio、Interceptor、TokenStorage、Service/Provider 基类。
- 当前真实域名使用 `https://apis.xh-demo.com/api`，资源域名使用 `https://apis.xh-demo.com`。
- `/system/getlist` 已接入 `SystemService.fetchConfig()` 和 `SystemProvider.loadConfig()`。
- Web 启动探针已经通过，Debug 日志形如 `[startup-probe] system config loaded: title=..., languages=..., banners=...`。
- 当前首页、个人中心、VIP、游戏大厅分类、厂商列表、子游戏列表、游戏启动、消息中心、反馈链路、活动链路、卡包列表、添加卡包、充值全链路、提现只读链路和资金记录页已有真实接口数据消费；首页分类区已按 m1 截图做高保真复刻，其余页面仍以 m1 高仿 UI fallback 为主。
- 当前首位任务为 P1 m1 交互补齐：优先右侧全屏搜索弹窗，其次游戏最小化浮窗、公告弹窗增强和 `/deposit/failed/:id`。多语言静态 UI 文案已完成收尾，后续仅做新增文案维护和视觉走查。
- 当前主 Tab 路由 `/`、`/game`、`/activity`、`/service`、`/profile` 使用 `NoTransitionPage`，底部导航点击为无动画 replace 式切换。
- 当前验证基线：`flutter analyze lib test` 无错误，`flutter test test/widget_test.dart` 为 12 个测试通过。

下次不要重复做：

- 不要重新搭建网络层。
- 不要重新定义全局配置模型，优先复用 `HomeConfig`。
- 不要把 `/system/getlist` 加 query `lang`。
- 不要把 m1 全量语言包直接塞进 Flutter 运行时语言包；Flutter 语言包只保留 Flutter 实际使用 key。
- 不要批量替换首页、游戏、钱包、活动等页面 Mock 数据。
- 不要重建认证链路。
- 不要贸然接入确认提现、手动转入/转出、领取返水/返利等剩余高风险资金写操作；如需接入，必须先完成对应只读链路和真实账号验证。
- 不要把主 Tab 切换改回 `push` 或默认路由转场；m1 对齐要求是无感 replace 式切换。

下次优先做：

- 优先继续全项目多语言：建立 m1 -> Flutter key 映射和 key 一致性校验，补 `auth/nav/game/activity/profile/finance` 语言包，并按模块替换页面硬编码中文。
- 或在记录与充值链路经真实账号验证后，继续接入确认提现 `POST /drawing/order`。
- 记录页接口失败不要展示静态假交易数据；如需增强，使用真实错误态和下拉重试。
- 页面只读消费 Provider，不让页面直接调用 Service 或 Dio。
- 完成后跑格式化、分析和测试。
