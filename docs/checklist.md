# Checkpoints

## 任务目标检查

- [x] m1 参考源已固定为 `/Users/john/Documents/trae_projects/bw-v3-517/src/projects/m1`。
- [x] 当前任务目标已从“补齐大页面”调整为“补齐 m1 核心业务闭环”。
- [x] 已确认主体页面基本覆盖 m1 路由页面。
- [x] 已确认后续重点是写操作接口、真实数据闭环和少数 m1 交互模块。

## 当前进度检查

- [x] 主 Tab：首页、游戏、活动、客服、我的已实现。
- [x] 账号页、钱包页、资金管理、游戏管理、活动详情、活动记录、反馈、消息、VIP、充值链路已完成主要 UI 和接口接入。
- [x] `ApiEndpoints` 已覆盖 m1 主要 API。
- [x] 基础 `Service`、`Provider`、`Model` 分层已建立。
- [x] 已初步补齐提现、删卡、分享、今日收益、返水领取、找回密码、Telegram 等缺口所需 service/model。
- [x] P0 写操作和真实数据入口已完成一轮 `Provider -> Screen` 接入。
- [x] P1 m1 交互已完成基础对齐，剩余进入 P2 路由与联调细节。

## P0 验收检查

- [x] `/drawing/order`：提现提交可用，按钮有提交中状态，成功跳提现成功页，失败展示后端错误。
- [x] `/member_bank/delete`：银行卡删除确认、提交、刷新列表可用。
- [x] `/code/send`、`/password/get`：找回密码验证码发送、重置提交、成功态和错误态可用。
- [x] `/retabe/list`、`/retabe/amount`：分享页金额、会员数、领取返利来自真实数据；邀请码按 m1 使用账号 ID，分享链接按 m1 前端规则生成 `/m1/register?invite=账号ID`，二维码按分享链接实时生成并支持预览，禁用空态、刷新逻辑、动态规则文案和领取提示已补齐；首帧不会闪现 `{amount}` 占位符。
- [x] `/member_fs_log/claim`：游戏返水一键领取可用，成功后刷新返水记录。
- [x] `/day_revenue/getlist`：模型完整解析 `day_netAmount`、`day_bet_count`、`day_zongfs`、`day_lingqu`、`day_weiling`；我的页卡片按 m1 实际展示投注数、净盈亏、未领取返水三项。

## P1 验收检查

- [x] 搜索入口对齐 m1 右侧全屏弹窗体验，并保留必要的独立页兼容；搜索业务已验证可用。
- [x] 游戏承载页支持最小化、浮窗恢复、关闭和跨页面保留游戏状态；最小化弹窗已验证可用。
- [x] 公告弹窗支持多公告、今日不再提示、富文本/图片、跳转和按公告粒度 suppression。
- [x] `/deposit/failed/:id` 充值失败页或失败态路由已补齐。

## P2 验收检查

- [x] Telegram query 拦截逻辑对齐 m1 router。
- [x] Telegram 登录真实接口已接入；query 拦截与首次登录默认设置密码闭环已补齐。
- [x] 邀请/refcode query 持久化逻辑对齐 m1。
- [x] `/system/getlist` 终端参数与 m1 一致并通过联调确认。
- [x] `/activity/details` 语言参数与 m1/后端规则一致。
- [x] `DayRevenueSummary`、`WithdrawOrderResult`、Telegram 相关模型字段已按 m1 响应包装和页面使用字段完成兼容校准；真实账号冒烟时继续记录后端环境差异。

## 表单完整性检查

- [x] 已完成 m1 输入型页面和 Flutter 表单页面差异核查。
- [x] 提现页已补齐取款密码输入框、校验和 `pay_password` 提交，且避免首帧显示 locale key。
- [x] 找回密码页补齐邮箱找回、真实姓名 + 取款密码找回、确认新密码输入和手机区号选择器。
- [x] 修改资金密码页在已设置状态下补齐旧取款密码输入框。
- [x] 兑换码页面如确认属于目标范围，则补齐页面、接口、路由和入口。

## m1 517 剩余差异检查

- [x] 登录失败 3 次后图形验证码策略对齐 m1 `login_error` 配置。
- [x] 登录失败计数 `m1_login_fail_count` 等价机制已补齐，登录成功后清零。
- [x] 手机号登录区号选择器已补齐，`area_code` 不再固定 `+86`。
- [x] 登录短信/邮箱验证码发送返回的 `captcha_key/captcha_img/captcha_code` 已正确应用到图形验证码。
- [x] 绑定手机号固定 `+86` 和中国手机号正则已评估；已补区号选择，中国区号保留中国手机号正则，其他区号使用通用数字长度校验。
- [ ] 活动详情 `/activity/details` 的 `lang` 参数已通过真实接口确认，Flutter 行为与 m1/后端一致。
- [x] 添加收款方式二维码上传 `/img/save.name` 已按 m1 调整为 `recharge`；仍需真实后端冒烟确认。
- [x] 添加收款方式 `/member_bank/binding` payload 已补实名姓名 `name` 字段。
- [ ] 系统配置 URL 清洗规则已补强或确认当前 `UrlPolicy`/图片组件已覆盖后端脏数据。
- [ ] 路由鉴权白名单已复核，匿名可访问页面与 m1 保持一致。
- [ ] Web 浏览器标题是否需要对齐 m1 已评估；如需要，已按页面标题 + 站点标题实现。

## 质量检查

- [x] 每个落地阶段执行 `dart format`。
- [x] 每个落地阶段执行 `flutter analyze` 且无新增问题。
- [x] 写操作均具备 loading、success、error 和防重复提交。
- [x] 外链、支付、客服、游戏承载 URL 已统一接入 `UrlPolicy`，并加固 WebView/iframe 初始 URL 与游戏导航校验。
- [x] 已移除网络层全局自动 retry，避免资金和账号写操作被重复提交。
- [ ] 接口失败或空数据不展示静态假数据。
- [ ] 新增 UI 在小屏、长文本、多语言场景下无明显溢出。
- [ ] 完成业务/API/UI 改动后同步更新任务、进度和接口文档。
