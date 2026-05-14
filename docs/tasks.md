# Tasks

## 当前任务目标

把当前 Flutter 主工程从“m1 高仿 UI 基本完成”推进到“m1 核心业务闭环可验收”。后续任务不再以大规模补页面为主，而是按 m1 项目 `/Users/john/Documents/trae_projects/bw-v3-504/src/projects/m1` 对齐以下内容：

- 页面入口和路由行为。
- m1 `views/**` 的页面生命周期、按钮事件、弹窗、分页、刷新和跳转规则。
- m1 `api/**` 的接口路径、请求方法、入参字段和响应字段使用。
- Flutter `Service -> Provider -> Screen` 的真实数据流。
- 写操作的 loading、success、error、防重复提交和刷新闭环。

## 当前任务进度

- [x] 核心 Flutter UI 页面和主路由已基本覆盖 m1 主体页面。
- [x] 全局网络、认证拦截、错误处理、基础 Provider/Service/Model 分层已建立。
- [x] 大部分 m1 endpoint 已在 `ApiEndpoints` 中定义。
- [x] 充值、活动、游戏大厅、游戏启动、反馈、消息、VIP、个人资料、实名、绑定手机/邮箱、设置资金密码、资金记录等只读或低风险链路已完成主要对接。
- [x] 已补齐一批后续闭环所需模型和 service 方法：提现订单、删卡、分享返利、今日收益、返水领取、找回密码、Telegram 登录/设置密码。
- [x] P0 Provider 状态层已接入提现提交、删卡、分享返利、找回密码、Telegram、返水领取、今日收益等核心状态。
- [x] P0 页面闭环已完成一轮接入：提现提交、银行卡删除、找回密码、Telegram 登录、分享返利、游戏返水领取、我的页今日收益。
- [x] 已按 m1 504 项目复核分享页和今日收益字段：分享页邀请码/链接由账号 ID 前端生成，二维码按链接实时生成并支持预览，禁用空态、刷新逻辑、动态规则文案和领取提示已对齐 m1；已修复首帧 `{amount}` 占位符闪现；今日收益模型完整覆盖五字段且卡片按 m1 展示三项。
- [x] P1 m1 体验补齐已完成：右侧搜索弹窗、游戏最小化浮窗、公告富文本/图片/跳转、充值失败页均已接入并完成基础验证。
- [ ] 当前剩余重点已进入 P2：Telegram 深链、邀请/refcode 持久化、系统配置 terminal、活动详情语言参数和关键模型字段联调校准。

## 当前任务方向

优先级按业务风险和验收价值排序：

1. P0 资金和账号闭环：提现提交、银行卡删除、找回密码、分享返利、返水领取、今日收益。
2. P1 m1 体验补齐：右侧搜索弹窗、游戏最小化浮窗、公告弹窗增强、充值失败页。
3. P2 授权和联调细节：Telegram 深链登录/设置密码、邀请/refcode 持久化、接口字段联调校准。

## 执行步骤

### Task 1: P0 Provider 状态层补齐

- [x] `WalletProvider` 增加 `createWithdrawOrder`，包含 `isWithdrawSubmitting`、`withdrawSubmitError`。
- [x] `WalletProvider` 增加 `deleteCard`，包含 `isDeletingCard`、`deleteCardError`，成功后刷新卡列表。
- [x] `AuthProvider` 增加 `sendResetPasswordCode`、`resetPassword` 和对应发送中/提交中状态。
- [x] `AuthProvider` 增加 `telegramLogin`、`setTelegramPassword` 和 token 保存逻辑。
- [x] `UserProvider` 增加 `loadDayRevenue`、`loadRebateInfo`、`claimRebateAmount`。
- [x] `GameManagementProvider` 增加 `claimAllRebates`，成功后刷新返水记录。

### Task 2: P0 页面闭环接入

- [x] `WithdrawScreen` 接入 `/drawing/order`，替换 `comingSoon`。
- [x] `BankCardListScreen` 增加删除确认、删除提交、删除后刷新。
- [x] `ResetPasswordScreen` 接入验证码发送和重置密码提交。
- [x] `ShareScreen` 从静态展示改为 `/retabe/list` 真实数据，并接入 `/retabe/amount` 领取返利；邀请码/分享链接按 m1 使用账号 ID 生成。
- [x] `GameManagementScreen` 启用底部“领取返水”按钮，接入 `/member_fs_log/claim`。
- [x] `ProfileScreen` 接入 `/day_revenue/getlist`，模型解析 `day_netAmount/day_bet_count/day_zongfs/day_lingqu/day_weiling`，卡片按 m1 展示投注数、净盈亏、未领取返水。

### Task 3: P1 m1 交互补齐

- [x] 新增或改造搜索入口：首页、游戏、活动页按 m1 使用页面内右侧全屏弹窗，而不是只跳独立 `/search`；搜索业务已验证可用。
- [x] 抽离现有 `SearchScreen` 内容为可复用组件，供独立页和右侧弹窗复用；已按 m1 接入搜索历史、热门/全部/收藏、分页、收藏和游戏启动。
- [x] 增加 `FloatingGameProvider` 或等价全局状态，保存当前游戏 session；游戏最小化浮窗已实现并验证。
- [x] `GameViewScreen` 增加最小化、恢复、关闭逻辑，对齐 m1 `GamePlay.vue`；顶部标题、Logo、最小化和关闭操作区已按 m1 调整。
- [x] `HomeScreen` 公告弹窗支持富文本、图片、跳转、按公告 ID/日期控制今日不再提示。
- [x] 新增 `/deposit/failed/:id` 充值失败页或将失败态路由映射到现有结果页。

### Task 4: P2 路由与联调细节

- [x] 在 Flutter router 中复刻 m1 Telegram query 拦截：任意路由出现 `user_id`、`username` 时转 `/telegram-login` 并保留 redirect；清理 redirect 中的 Telegram 授权 query，避免循环跳转。
- [ ] 增加 m1 `persistRefCodeFromQuery` 等价逻辑，在任意路由读取 `invite`、`refcode`、`ref_code` 等邀请参数并持久化，注册页优先使用持久化邀请值。
- [ ] `/system/getlist` 请求补齐或校准 m1 默认 `{ terminal: 2 }` 规则，并验证 banner、公告、语言、站点配置与后端 H5 配置一致。
- [ ] 确认 `/activity/details?lang=CN` 是否仍为后端必要规则，必要时在 Flutter service 中按当前语言兼容。
- [ ] 校准 `DayRevenueSummary`、`WithdrawOrderResult`、`TelegramLoginResult` 等模型字段，按真实响应补齐成功/失败/边界字段。

### Task 4.1: P2 下一阶段开发顺序

- [x] 路由前置处理：实现 Telegram query 拦截和 redirect 保留。
- [ ] 邀请参数持久化：新增统一工具/Provider，复刻 m1 `persistRefCodeFromQuery` 行为并接入注册页。
- [ ] 系统配置联调：确认 `/system/getlist` terminal 参数，修正公告/banner 等依赖 terminal 的过滤规则。
- [ ] 活动详情语言参数：确认并兼容 `/activity/details` 的语言入参。
- [ ] 字段校准：使用真实响应复核收益、提现订单、Telegram 登录/设密模型。

### Task 5: 验证与收尾

- [x] 每个闭环完成后执行 `dart format`。
- [x] 每个阶段完成后执行 `flutter analyze`。
- [ ] P0 全部完成后做资金/账号主流程冒烟：提现、删卡、找回密码、分享领取、返水领取、我的页收益刷新。
- [x] P1 完成后做 m1 交互对齐检查：搜索弹窗、公告弹窗、游戏最小化浮窗、充值失败页已完成基础验证。
- [ ] P2 每项完成后做深链/注册/配置/字段联调验证，并记录实际后端响应差异。
- [ ] 更新 `.opencode/docs/API_INTEGRATION_SEQUENCE.md`、`.opencode/docs/ENGINEERING_BUSINESSIZATION_PLAN.md`、`docs/UI_REPLICA_PROGRESS.md` 的完成状态。

## 非目标

- 不重做已完成的高仿 UI 页面。
- 不整包复制 m1 Vue template/CSS。
- 不把旧 Flutter 项目作为页面业务逻辑来源。
- 不为了“模型完整”批量迁移 m1 未使用字段；只按页面闭环逐步补齐。
