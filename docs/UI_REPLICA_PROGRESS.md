# 🚀 Flutter UI 高保真复刻进度报告 (UI Replica Progress)

**当前综合复刻进度：约 100%**
*注：核心架构、主业务流程、以及所有垂类业务页面（游戏大厅及其二级页、VIP、消息、反馈、结果页、资金管理）已完成高保真（>80%）还原，并持续进行多语言、字体回退与防溢出修复。*

---

## 🟢 1. 已完成高保真复刻 (Completed - 100%)
*这些页面已经通过 `ui-fidelity-checker` 与 `screenshot-to-flutter` 规则走查，具备了高还原度（布局、渐变、字体、阴影、防溢出均已处理）。*

### 全局UI组件精修 (UI Polish)
- **卡片组件 (`CustomCard`)**：全面升级了立体感，默认圆角增加至 `12.r`，加入白色高光内边框与双层 `BoxShadow`（大半径柔和主阴影 + 小半径环境阴影），模拟出现代 Glassmorphism/iOS 的高质感悬浮效果。
- **按钮组件 (`CustomButton`)**：全面重构为“大圆角胶囊风格” (`24.r`)，主按钮附带对应主题色的发光阴影与水波纹点击效果 (`InkWell`)。
- **全局字体回退**：在 `app_theme.dart` 中补齐 `fontFamilyFallback`，统一修复中文、英文和混排时的字体缺失问题。

### 核心架构 & 导航
- **全局路由** (`app_router.dart`)：基于 `GoRouter` 的多层级页面跳转支持。
- **底导架构** (`CustomTabBar`)：**【深度对齐】** 5 个主 Tab（首页、游戏大厅、活动、客服、我的）均已接入底部导航；Tab 点击使用 Shell 分支切换，保留 m1 `van-tabbar route replace` 的无感切换体验。当前已新增 m1 alias 路由兼容层，并补齐 `/maintenance` 系统维护页与全局维护跳转。
- **公共组件**：`CustomNavBar` (顶部导航)、`CustomTabBar` (弹性底导防溢出)、`CustomCard` (阴影圆角卡片)、`CustomCell` (列表行)。

### 一级主页面 (Primary Screens)
- **我的页面精修** (`ProfileScreen`)：完成带编辑图标的栈叠头像、Pill-shape VIP标签、蓝色渐变钱包面板（¥ 符号与金额排版对齐）、白色圆角“今日收益”面板（垂直灰线分割与蓝色箭头贴字）、8宫格“更多服务”。底导钱包/资金管理入口统一指向 `FundManagementScreen`；头像数据随 `/token/user.img` 刷新回显。
- **首页推荐游戏与分类区** (`HomeScreen`)：推荐游戏横向区已接入真实只读数据，优先展示接口图片与标题；热门游戏已按 m1 接入 `POST /gamelist/getlist(label=hot)`。Banner、公告、推荐游戏、热门游戏均对齐 m1 首页规则：有可见数据才展示模块，空数据不展示模块，也不使用“暂无公告”或静态 mock 兜底 UI。首页分类区使用 m1 本地静态资源并按截图高保真复刻：真人大卡、彩票/电子中卡、四个小卡比例、`Live/Lottery/Slot` 浅蓝英文底字、图片尺寸和文字密度已精修，并接入 `/interface/class` 与 `/game?code=...` 点击入口；多处 RenderFlex 溢出已处理。运行时语言包里的首页 demo 标题/描述文案已收口为业务文案，`home.fallbackNotice` 保持空字符串，避免空公告撑出模块。后续首页剩余 m1 对齐重点为：补齐 `NoticeModal` 公告弹窗/今日不再提示、评估搜索右侧弹窗和游戏内嵌弹窗/最小化浮窗。
- **活动页面** (`ActivityScreen`)：已对齐 m1 `views/main/activity.vue`，顶部品牌区域读取系统配置，活动分类接入 `/activity/class`，活动列表接入 `/activity/list`，分类横向 Tab 与活动卡片展示真实图片、标签、标题和时间；接口失败时保留 fallback 活动。
- **客服页面** (`ServiceScreen`)：已切换到新项目客服模式，复用 `/system/getlist.config_kefu` 展示问候卡片和纵向客服列表；客服页不再依赖 `config_site.service_link` 与 `tg_link` 旧模式字段，`config_kefu` 为空或无效时直接展示空态；点击客服项继续通过安全外链能力打开。

### 核心二级内页 (Secondary Screens)
- **游戏大厅** (`GameScreen` & `GameSubListScreen`)：**【基于截图深度复刻】** 重构了带 Logo 和域名的专属头部（星汇演示），解决了 `TabBar` M3 默认偏移（`tabAlignment: TabAlignment.start`），实现了 3 列游戏卡片网格布局。在二级页中，完美还原了带有 PG 角标与心形收藏按钮叠加 (`Stack`) 的 4 列网格布局；已接入 `/gamelist/getlist` 搜索与分页加载、`/user_favorites/game` 收藏/取消收藏，以及 `/game/login` 游戏启动链路。游戏启动成功后按 m1 规则处理 `nesting=false` 外部打开，否则进入独立 `/game-view` 承载页；承载页已对齐 m1 黑色顶部栏、标题、站点 Logo 和关闭入口，移动端使用 WebView，Web 端使用 iframe 且补齐 fullscreen/sandbox 参数，不保留主 Tab 底栏。
- **VIP中心** (`VipScreen`)：**【深度对齐】** 重构为纯净白底+蓝点 (`Blue Dot`) 装饰的立体感卡片风格。实现了基于当前等级动态计算的“充值”与“流水”双轨进度条，并通过 TabBar 实现了各 VIP 等级专属特权（升级礼金、返水比例等）的精细化列表展示；已接入 `/vip/getlist` 只读数据、下拉刷新、加载提示和 fallback 规则展示，充值当前值优先使用 `/token/user.recharge`。当前阶段已通过真实账号验证并标记为对接完毕。
- **消息通知** (`MessageScreen`)：**【深度对齐】** 新增顶部“全部/未读/已读” Tab 分类过滤器，实现了未读红点 (`Badge`) 点击消除并实时变更为已读状态的业务逻辑。
- **意见反馈** (`FeedbackScreen` & `FeedbackRecordsScreen`)：**【深度对齐】** 补齐了问题分类选择、多行文本框 300 字限制与实时字数统计器；问题分类弹窗已加最大高度和滚动约束，修复分类过多时的溢出；图片区域已接入 `/img/save`，支持最多 3 张图片上传、缩略图预览、删除，并在提交时传给 `/feedback/to.img`。反馈类型、提交反馈和反馈记录真实接口均已接入，并保留 fallback。
- **充值中心** (`DepositScreen`)：**【对齐 m1 并接入真实链路】** 充值渠道单选网格列表、自适应大字体的金额输入框、带快捷金额选项与实时汇率提示，重构了浅灰蓝背景与立体感卡片，完美还原“充值类型”、“充值通道”与“充值信息”三个模块的蓝点标题排版；已接入 `/deposit/class`、`/deposit/getlist` 和 `/recharge/order`，提交成功后按 m1 规则进入在线支付或充值详情。
- **提现中心** (`WithdrawScreen`)：提现银行卡信息展示、全部提现快捷键；已接入 `/drawing/order` 提现提交、提交中状态、余额/流水/取款密码校验、成功跳转和错误提示。
- **财务记录** (`TransactionRecordScreen` & `FundRecordScreen`)：实现了基于盈亏状态动态变色、红蓝上下箭头动态图标的流水列表。
- **个人资料** (`UserProfileScreen`)：已对齐 m1 资料编辑结构，支持实名、手机、邮箱、性别、生日、QQ、Telegram 展示/编辑；头像入口已接入相册选择、`/img/save` 上传和 `/user/edit.img` 保存流程。
- **系统设置** (`SettingScreen`)：完成各类设置项的入口卡片构建；“关于我们”已从占位提示改为进入 `AboutUsScreen`。
- **关于我们** (`AboutUsScreen`)：新增只读站点信息页，复用 `/system/getlist.config_site` 展示 Logo、站点名称、平台介绍、域名、版本、APP 下载、客服入口和 TG 客服，支持下拉刷新和 fallback 展示。
- **银行卡管理** (`BankCardListScreen`)：带有银行专属背景色、虚线卡号、及底部悬浮“添加银行卡”按钮的高保真列表；已接入 `/member_bank/delete` 删除确认、提交和刷新列表。
- **活动详情** (`ActivityDetailScreen`)：基于截图复刻并接入 `/activity/details` 数据，支持通过活动 ID 展示标题、发放方式、倍数、时间和活动说明；活动说明已支持安全富文本降级渲染和图片展示；手动活动底部按钮已接入 `/activity/apply`，支持提交中禁用、成功提示和后端错误提示。
- **活动申请记录** (`ActivityRecordScreen`)：已对齐 m1 `ActivityApplyRecords.vue` 并接入 `/activity/record`，支持申请记录分页、下拉刷新、滚动加载、空态、状态标签、账号和申请时间展示，接口失败保留 fallback。
- **游戏管理** (`GameManagementScreen`)：基于截图复刻与精修，实现带“查询日期”筛选项与“返水记录”、“游戏记录”双 Tab。移除默认下划线，卡片应用 `16.r` 大圆角与柔和阴影提升立体感，底部常驻栏采用 `Column+Expanded` 隔离实现防溢出；已接入 `/member_fs_log/getlist` 返水记录和 `/gamerecord/getlist` 游戏记录，展示统计、分页、下拉刷新和空态，接口空数组不再显示静态记录；日期筛选按钮支持横向滚动防溢出，记录卡片/统计卡片/空态已按 m1 移动端信息密度精修，记录模型已按 m1 字段区分返水/游戏记录避免误展示；底部领取按钮已接入 `/member_fs_log/claim`，成功后刷新返水记录。
- **资金管理** (`FundManagementScreen`)：基于截图复刻与精修，统一收口了原有的“我的钱包”、“充提记录”、“交易记录”、“银行卡管理”入口。实现带“查询日期”筛选项，以及“充值记录”、“提现记录”、“转账记录”、“账户明细”四个 Tab 切换。卡片长文本使用 `Flexible` + `TextOverflow.ellipsis` 防止水平挤压，底部统一配置了“没有更多了”状态提示。
- **我的钱包/场馆余额** (`MyWalletScreen`)：**【基于截图深度复刻】** 重构了“场馆余额”功能模块，实现带蓝色渐变及底部内嵌按钮组的高质感钱包卡片，并采用 `GridView.builder` 实现了带比例控制 (`childAspectRatio`) 的场馆资金网格布局，配置了场馆自动转账开关。
- **分享赚钱** (`ShareScreen`)：**【基于截图深度复刻】** 完成了推广分享页的高保真复刻。实现了“分享返利”、“会员总览”、“分享信息（含二维码与复制链接）”以及“邀请规则说明”四个专属卡片，精准还原了字体大小、间距、蓝点标题及边框细节；已接入 `/retabe/list` 真实金额和会员统计，通过 `/retabe/amount` 领取返利；邀请码按 m1 使用账号 ID，分享链接按 m1 前端规则生成 `/m1/register?invite=账号ID`，二维码已从静态占位改为按分享链接实时生成并支持点击预览；已补齐 m1 “无可用邀请策略”空态、下拉刷新 profile+返利、无奖励/领取成功提示，以及领取条件/有效会员规则/规则 5 的动态参数；首帧使用默认有效充值金额避免 `{amount}` 占位符闪现。

### 用户表单类 (Forms) - [Sprint 1 完成]
- **绑定手机号** (`BindPhoneScreen`)：实现带获取验证码倒计时功能的表单；已接入短信验证码发送接口和 `/user/edit` 绑定提交。
- **绑定邮箱** (`BindEmailScreen`)：实现邮箱输入及验证码验证表单；已接入邮箱验证码发送接口和 `/user/edit` 绑定提交。
- **修改登录密码** (`ChangePasswordScreen`)：包含旧密码验证、新密码双重输入的表单。
- **找回密码** (`ResetPasswordScreen`)：已按 m1 补齐手机号、邮箱、真实姓名 + 取款密码三种找回方式；新增确认新密码输入、手机号区号选择器、验证码发送与 `/password/get` 提交闭环，并使用 `ui-ux-pro-max` 优化为安全蓝单列验证页。
- **设置/修改资金密码** (`WithdrawPasswordScreen`)：6位纯数字安全密码设置表单；已设置状态下补齐旧取款密码输入框与本地校验，请求 payload 按 m1 保持只提交新的 `pay_password`。
- **实名认证** (`RealNameScreen`)：姓名输入、认证状态和安全提示；已接入 `/user/edit` 提交 `real_name`，成功后刷新 `/token/user`，已实名保持只读禁用。
- **添加银行卡** (`AddBankCardScreen`)：持卡人、卡号、开户行信息输入表单。
- **公共输入组件**：升级 `CustomTextField`，支持焦点状态变色、`suffixIcon` 清除按钮及错误红字提示。新增 `CountdownButton` 实现验证码倒计时效果。
- **兑换码** (`RedemptionCodeScreen`)：已补齐 m1 `/redemption-code` 页面，包含兑换码输入、粘贴、提交、兑换记录列表、下拉刷新和空态；接口接入 `/redemption/code`、`/redemption/getlist`，页面 UI 已使用 `ui-ux-pro-max` 优化为奖励渐变卡片与记录卡片。

### 结果与过渡页 (Feedback & Transitions)
- **充值订单详情** (`DepositOrderDetailScreen`)：已对齐 m1 `DepositOrderDetail.vue`，实现渐变背景、状态金额卡、二维码卡、支付信息卡、风险提示、凭证上传卡和取消支付底部弹窗；已接入 `/recharge/details`、`/img/save?name=recharge`、`/recharge/img` 和 `/recharge/cancel`，支持图片凭证、虚拟币交易哈希和取消原因提交。
- **充值成功** (`DepositPaySuccessScreen`)：大图标反馈与状态提示。
- **提现成功** (`WithdrawSuccessScreen`)：大图标反馈及预计到账提示。
- **线上支付** (`OnlinePayDetailScreen`)：支持接收 `/recharge/order` 返回的支付 URL 和订单 ID，可外部打开支付网关并跳转订单详情。

### 多语言与文案修复 (i18n & Copy) - [静态 UI 已收尾]
- 已接入 `easy_localization`，并完成 `zh-CN`、`zh-TW`、`en-US`、`ja-JP`、`ko-KR`、`th-TH`、`vi-VN`、`my-MM` 共 8 套 locale 的静态 UI 文案收口。
- 已覆盖 `common`、`auth`、`nav`、`home`、`game`、`search`、`activity`、`service`、`profile`、`settings`、`about`、`account`、`wallet`、`message`、`security`、`finance`、`deposit`、`share`、`feedback`、`vip`、`gameManagement`、`maintenance` 等模块。
- 已修复非英语语言包中与日语包同类的问题：语言包 key 虽对齐但 value 混入英文/中文占位。当前 `ko-KR`、`th-TH`、`vi-VN`、`my-MM` 已完成英文原文和中文残留清理。
- `CN.json` 已同步为 `zh-CN.json`，避免简体 fallback 加载旧包后出现英文；`zh-TW.json` 保持繁体中文，`ja-JP.json` 保持日语汉字，不按中文残留处理。
- `lib/generated/locale_keys.g.dart` 已按 `en-US.json` 重新生成，当前与 825 个 locale key 对齐。
- 前端多语言边界已明确：只翻译静态 UI 文案；接口返回的游戏名、活动/公告内容、支付渠道名称、客服名称、站点信息、用户数据和后端错误 message 等动态数据由后端按语言返回，前端不做二次翻译。
- 已清理展示为真实业务内容的静态 mock/fallback 数据；接口失败或空数据时展示空态/错误提示，不再展示假游戏、假场馆、假消息、假活动或假反馈记录。
- 当前静态 UI 多语言已完成收尾验证：locale JSON/key 对齐、直接 `.tr()` key 检查、动态 helper key 检查、生成 key 对齐、`flutter analyze` 和 `flutter build web --no-web-resources-cdn` 均已通过。

---

## 🟢 2. 多语言体系 (I18n) - [静态 UI 已收尾]
*Flutter 专属语言包体系已完成静态 UI 文案收尾；后续仅保留真实页面视觉验收和接口动态数据多语言协同。*

### 多语言静态文案
- [x] **全项目 Flutter 专属语言包建设**：`assets/i18n/*.json` 已按 Flutter 实际使用的静态 UI key 对齐，所有语言包与 `en-US.json` key 结构一致。
- [x] **生成 key 对齐**：`lib/generated/locale_keys.g.dart` 已按 `en-US.json` 重新生成，与 825 个 locale key 一致。
- [x] **硬编码与本地兜底收口**：资金管理、游戏管理、个人中心等页面已移除本地中文/英文静态文案兜底，统一走 locale。
- [x] **混合语言清理**：已按“日语包中英混合问题”的同一标准清理 `ko-KR`、`th-TH`、`vi-VN`、`my-MM` 的英文/中文占位。
- [x] **静态 UI 多语言收尾验证**：JSON/key 对齐、生成 key 对齐、`.tr()` key 存在性、动态 helper key、mixed-language 审计、`flutter analyze` 和 Web 构建均已通过。
- [ ] **多语言视觉走查**：作为后续验收项，真实切换每种语言验证文本溢出、按钮截断、Tab 宽度、长句换行和小屏布局稳定性。

## 🟡 3. 待精修与开发页面 (Pending / Stubbed)
*主体页面已基本完成，后续重点转为 m1 剩余交互模块、写操作接口和真实数据闭环。*

### 当前收尾目标与方向
- **任务目标**：当前阶段目标不是继续大规模补页面，而是把已完成的 m1 高仿 Flutter UI 接入真实业务闭环，达到核心资金、账号、收益和游戏链路可验收。
- **当前进度**：m1 主体路由页面在 Flutter 中基本都有对应实现；P1 搜索弹窗、游戏最小化浮窗、公告弹窗增强和 `/deposit/failed/:id` 充值失败页已完成。P2 路由授权、邀请参数、系统配置 terminal、活动详情语言参数和表单缺失补齐已完成，当前主要差距集中在登录验证码机制、手机号区号机制、添加收款方式上传分类、系统配置脏 URL 兼容、模型字段联调和真实账号冒烟。
- **任务方向**：P0 资金/账号/收益闭环和 P1 m1 体验补齐已完成一轮接入；P2 路由授权、邀请参数、系统配置、活动语言参数和关键模型字段兼容校准已完成，剩余重点为 m1 517 机制差异收口、真实账号冒烟和上线安全/性能硬化。
- **执行原则**：每个闭环按 `m1 views/api/router -> Flutter Model/Service -> Provider -> Screen -> 验证 -> 文档` 顺序推进，不把接口调用直接散落在 Screen 中。

### 边缘业务与占位页
- [x] `MaintenanceScreen` (系统维护中占位页)：已接入 `/maintenance`，当 `/system/getlist.config_site.status == 0` 时全局跳转维护页。

### m1 剩余模块与交互
- [x] **首页公告弹窗 `NoticeModal`**：Flutter `_NoticeDialog` 已对齐 m1 多公告弹窗，支持今日不再提示、富文本降级渲染、图片公告、公告跳转字段，以及按公告 ID/日期控制本地关闭状态。
- [x] **首页/游戏/活动右侧搜索弹窗**：已抽离 `SearchScreen` 内容为共享 `SearchPanel`，首页、游戏、活动搜索入口改为 m1 同款页面内右侧全屏弹窗，独立 `/search` 路由继续复用同一内容组件；搜索业务已按 m1 接入 `/gamelist/getlist` 搜索/热门分页、搜索历史、收藏列表、收藏切换和 `/game/login` 游戏启动链路，并已完成验证。
- [x] **游戏内嵌浮窗/最小化继续游戏**：当前 `/game-view` 承载页已新增最小化入口，顶部栏按 m1 保持左侧标题、中间 Logo、右侧最小化/关闭操作区；`FloatingGameProvider` 保存当前游戏 session，主 Tab Shell 展示恢复/关闭浮窗，支持跨页面继续游戏，最小化弹窗已验证可用。
- [x] **分享赚钱真实数据闭环**：`ShareScreen` 已接入返利信息、可领取金额、会员统计、邀请码/分享链接、真实二维码预览、禁用空态和领取返利。
- [x] **提现提交闭环**：提现页已接入真实提现订单提交、提交中状态、成功/失败处理和提现成功页跳转。
- [x] **银行卡删除**：已补齐银行卡删除确认、删除接口和删除后列表刷新。
- [x] **找回密码真实提交**：`ResetPasswordScreen` 已接入验证码发送、重置密码提交、错误提示和成功态。
- [x] **找回密码多方式补齐**：`ResetPasswordScreen` 已对齐 m1 支持手机号、邮箱、真实姓名 + 取款密码三种方式，并补齐确认新密码和手机号区号选择。
- [x] **兑换码闭环**：新增 `RedemptionCodeScreen` 与 `/redemption-code` 路由，接入兑换码提交、记录列表、粘贴、刷新、空态和错误提示。
- [x] **资金密码修改补齐**：`WithdrawPasswordScreen` 在已设置资金密码时展示旧取款密码输入框，并做 6 位数字校验。
- [x] **Telegram 登录接口接入**：`TelegramLoginScreen` 已按 m1 改为自动 loading 登录页，接入任意路由 `user_id/username` query 拦截、redirect 保留、登录态保存，以及首次登录默认设置密码 `123456` 闭环。
- [x] **游戏返水一键领取**：底部领取按钮已接入 `/member_fs_log/claim`，支持领取中状态、错误提示和记录刷新。
- [x] **我的页今日收益数据**：个人中心已接入 m1 `/day_revenue/getlist` 真实数据，今日收益三列严格按 m1 显示 `day_bet_count` 注单笔数、`total_no_fs` 可领返水和 `total_no_fy` 可领佣金；`total_fs/total_fy` 不参与可领金额展示，避免与 m1 字段语义偏离；日期按 m1 `profile.dateMD` 显示为当天月日。
- [x] **我的收入页 m1 对齐**：个人中心“可领返水/可领佣金”进入 `/income`，新增 m1 两块收入面板（可领返水、可领返佣）、领取按钮、记录入口、今日结算三格数据；收入页进入时强制刷新 `/day_revenue/getlist`，避免只展示个人中心旧缓存。收入页三格结算布局已修正为有界高度，避免滚动列表中触发无界高度白屏和 Web `mouse_tracker` 连锁断言；收入页文案命名空间已修正为 Flutter 专属 `income.*`，不再显示 `user.income.*` 裸 key；收入页标题、查看返水比例、返佣比例、记录入口和领取提示已补页面级 locale 兜底，避免移动端旧资源缓存或热重载状态下露出残缺 key；今日收益三列已改为整块 72h 热区并去掉延后一帧导航，同时增加防重复入栈锁，避免连续点击造成进入/返回都需要多次点击。
- [x] **返佣等级页 m1 对齐**：新增 `/fy-level` 和 `FyLevelScreen`，按 m1 `FyLevel.vue` 接入 `/fy/level`，展示彩票、电子、棋牌、真人、体育、捕鱼 Tab，以及当前等级、下级 VIP 等级和您的返佣比例表格；页面空数据时展示空态，不使用假数据。
- [x] **VIP 返水比例格式对齐**：VIP 页返水比例继续严格读取 `/vip/getlist` 的 `sport_bl/live_bl/games_bl/poker_bl/fishing_bl/gaming_bl/lottery_bl`，百分比格式改为 m1 的 `toFixed(2)` 去零并保留整数 `.0` 规则。
- [x] **游戏管理页入口与返回**：`/game-manage?tab=rebate/fy/game` 已支持 m1 三 Tab 初始定位，个人中心注单笔数进入返水记录，收入页返佣记录进入返佣 Tab；返佣 Tab 按 m1 接入 `/fy/getlist` 与 `/fy/claim`，展示总返佣、已领取、未领取、流水金额、返佣比例和返佣金额；返回按钮在无路由栈时兜底回 `/profile`，避免从我的页入口进入后返回失效；收入页和游戏管理页返回按钮左侧热区扩至 72w，公共导航栏右侧操作也补最小 56px 热区。
- [x] **我的团队页**：新增 `/team` 和 `TeamScreen`，按 m1 `Team.vue` 接入 `/team/getlist`，展示“名称 / 个人流水”表格卡片、空态、下拉刷新和滚动加载更多；收入页“我的团队”入口已改为真实跳转。
- [x] **充值失败页 `/deposit/failed/:id`**：已按 m1 `DepositPayFailed.vue` 新增 `DepositPayFailedScreen` 和 `/deposit/failed/:id` 路由，提供失败卡片、重新充值和返回首页入口。

### 待对接接口清单
| 接口 | m1 用途 | 当前 Flutter 状态 | 优先级 |
| --- | --- | --- | --- |
| `/drawing/order` | 创建提现订单 | 已接入 Provider 和提现页 | 高 |
| `/member_bank/delete` | 删除银行卡 | 已接入 Provider 和卡列表页 | 高 |
| `/code/send` | 找回密码验证码 | 已接入 ResetPassword 页面 | 高 |
| `/password/get` | 找回密码提交 | 已接入 ResetPassword 页面 | 高 |
| `/retabe/list` | 分享返利信息、会员统计、邀请码/分享链接 | 已接入 Provider 和分享页 | 高 |
| `/retabe/amount` | 领取分享返利 | 已接入领取按钮 | 高 |
| `/member_fs_log/claim` | 游戏返水领取 | 已接入 Provider 和底部按钮 | 高 |
| `/day_revenue/getlist` | 我的页今日收益、投注数、未领取返水、收入页返水/返佣结算 | 已接入 Provider、我的页和收入页 | 高 |
| `/fy/getlist` | 游戏管理返佣记录、返佣统计和分页 | 已接入游戏管理返佣 Tab | 高 |
| `/fy/claim` | 返佣一键领取 | 已接入收入页 Provider 和领取按钮 | 高 |
| `/team/getlist` | 我的团队成员与个人流水 | 已接入团队页 | 中 |
| `/redemption/code` | 兑换码提交 | 已接入 UserProvider 和兑换码页 | 中 |
| `/redemption/getlist` | 兑换码记录列表 | 已接入 UserProvider 和兑换码页 | 中 |
| `/telegram/login` | Telegram 登录 | 页面已调用并保存登录态；路由 query 拦截未实现 | 中 |
| `/telegram/password` | Telegram 设置密码 | endpoint/service/model 已补，页面未调用 | 中 |

### P2 待开发任务

- [x] **Telegram query 拦截**：对齐 m1 `router.beforeEach`，任意路由带 `user_id`、`username` 时转 `/telegram-login`，并保留去除授权 query 后的 redirect。
- [x] **邀请/refcode 持久化**：对齐 m1 `persistRefCodeFromQuery`，在任意路由读取邀请参数并持久化，注册页自动带入。
- [x] **系统配置 terminal 联调**：确认 `/system/getlist` 是否需要 `{ terminal: 2 }`，并统一 banner、公告、语言、站点配置使用规则。
- [x] **活动详情语言参数**：确认 `/activity/details?lang=CN` 是否为后端必要规则，并按当前语言兼容。
- [x] **关键模型字段校准**：已按 m1 页面/API 响应规则复核 `DayRevenueSummary`、`WithdrawOrderResult`、Telegram 登录/设密相关模型；Telegram 兼容 `access_token/token` 与双层 `data`，提现结果兼容订单号、金额、手续费、状态文本、message 和包装结构。
- [x] **登录验证码机制补齐**：已对齐 m1 `Login.vue` 的 `m1_login_fail_count`、`config_pic.login_error`、失败 3 次后图形验证码、成功清零和发送验证码返回 captcha 应用机制。
- [x] **登录手机号区号补齐**：`LoginScreen` 手机号登录已支持国家/地区区号选择，`area_code` 不再固定 `+86`。
- [x] **绑定手机号国际化评估**：`BindPhoneScreen` 已补区号选择，中国区号保留中国手机号正则，其他区号使用通用数字长度校验。
- [x] **添加收款方式接口细节确认**：`/img/save.name` 已按 m1 调整为 `recharge`，`/member_bank/binding` payload 已补实名姓名 `name` 字段；仍建议真实接口冒烟确认。
- [ ] **系统配置 URL 归一化补强**：按 m1 `system.js` 清洗规则复核 logo、app 下载、客服链接、banner、notice 跳转等 URL 脏数据兼容。
- [ ] **Web 标题机制评估**：如 Web 端需要对齐 m1 router，按页面 title + `config_site.title` 更新浏览器标题。

---

## 🗺️ 4. 下一步“完美复刻”路线图 (Next Steps to 100%)

为了达到 100% 的完美高保真复刻，我们将严格启用 `ui-fidelity-checker` 规则，按照以下 4 个阶段逐一攻克：

### ✅ 阶段一：攻坚高频交互表单页 (Sprint 1: Forms & Inputs) - [已完成]
- **目标**：完成所有用户安全与绑卡相关的表单页。
- **重点规则**：输入框 (`TextField`) 的焦点状态 (Focus) 颜色、清除按钮 (`suffixIcon`)、错误提示红字排版、获取验证码倒计时按钮的样式对齐。
- **涉及页面**：`AddBankCardScreen`, `ChangePasswordScreen`, `WithdrawPasswordScreen`, `BindPhoneScreen`, `BindEmailScreen`, `RealNameScreen`。

### ✅ 阶段二：重构游戏大厅与VIP中心 (Sprint 2: Core Business Views) - [已完成并深度重构]
- **目标**：补齐最具视觉冲击力的业务大厅，并严格对齐原 Vue3 逻辑。
- **重点规则**：
  - `GameScreen`：处理横向滑动游戏列表 (`ListView.builder`)、带遮罩层的 3 列网格布局及专属 Logo 头部。
  - `VipScreen`：处理 VIP 等级双轨进度条 (`LinearProgressIndicator`)、白底蓝点立体卡片、以及解锁特权与返水比例的列表排版。

### ✅ 阶段三：结果反馈与消息流 (Sprint 3: Feedbacks & Messaging) - [已完成并深度重构]
- **目标**：处理操作完成后的闭环体验，并严格对齐原 Vue3 逻辑。
- **重点规则**：
  - 成功/失败的居中大图标与结果文本。
  - `MessageScreen` 消息列表的分类 Tab 过滤及未读红点 (`Badge`) 点击消除状态管理。
  - `FeedbackScreen` 的问题分类选择、多行文本输入 (`maxLines: 5`) 字数统计，以及最多 3 张图片上传、预览和删除。

### 阶段四：微交互、动效与全局走查 (Sprint 4: Polish & Animations)
- **目标**：注入灵魂，完成最终的 100% 体验闭环。
- **动作**：
  - 全局引入点击水波纹优化 (`InkWell` 颜色调优)。
  - 列表加入下拉刷新 (`RefreshIndicator`) 样式适配。
  - 主 Tab 已完成无动画切换；后续可评估是否用 `ShellRoute` 收敛底部导航重复维护。
- 使用 `ui-fidelity-checker` 进行全量走查，确保在小屏/大屏设备上的边界约束（防溢出）坚如磐石。

### 后续事项：多语言视觉验收与接口协同
- 静态 UI 文案多语言已完成收尾，后续重点转为真实浏览器逐页视觉验收。
- 缅甸语适配已按英文 key 对齐复查：`my-MM.json` 无中文残留，登录/注册/找回密码/绑定手机号/兑换码/提现/充值失败/Telegram 登录/通用空态等 Flutter fallback 已去除硬编码中文。
- 语言选择面板在缅甸语环境下改为按语言 code 展示缅甸语语言名称，避免本地兜底语言列表露出中文或其他非缅甸语名称。
- 语言切换流程已加固：先完成 `easy_localization` locale 切换再更新业务语言码，首页切换期间展示 loading 遮罩，并对系统配置、首页分类、推荐游戏、热门游戏请求加入过期结果丢弃，避免旧语言异步响应覆盖新语言页面。
- 首次启动语言初始化已前置到 `runApp` 前：从本地存储读取语言后传入 `EasyLocalization.startLocale` 与 `LanguageProvider` 初始值，避免首帧先按中文 fallback 渲染首页、底栏、活动、客服和我的页。
- 首次安装/信任后打开已加启动门闩：保持项目默认语言与翻译 fallback 为中文，启动时只应用本地已保存语言，不再根据后端默认语言自动切换；无本地语言时首次展示保持全中文，用户主动切换缅文后再按切换流程全量刷新，避免中文/缅文混杂。
- 语言持久化已收敛为单一来源：关闭 `easy_localization.saveLocale` 并在启动时清理其旧 `locale` 缓存，只使用项目自己的 `lang` 存储，避免 iOS 旧 locale 缓存与业务语言码不一致导致首次打开混杂。
- 首页顶级游戏分类导航已改为固定 code 对应本地 i18n 文案，接口/缓存分类标题只用于路由数据，不再参与首屏标题展示，避免接口缓存语言与当前底栏 locale 不一致时出现中缅混合。
- 客服页在线客服标题改为本地 i18n 固定文案，不再优先展示后端 `config_kefu.title`；公告弹窗按当前语言过滤明显中文公告内容，避免缅文界面首次弹出中文公告；我的页兑换码入口改用允许根下的 `user.redemption.title` key。
- 启动阶段新增语言敏感缓存清理：进入 App 前清除系统配置缓存和游戏分类/列表/热门游戏本地缓存，避免历史混杂期间写入的脏缓存再次在首屏渲染旧语言内容。
- 启动初始化顺序已修正：先清理 `easy_localization` 旧 `locale` 和语言敏感业务缓存，再执行 `EasyLocalization.ensureInitialized()`；随后在 loading 阶段同步项目语言、重置语言敏感 Provider，并按确定语言加载首屏配置，避免库静态缓存旧 locale 后再清理导致无效。
- 已按 m1 参考项目复核语言链路：m1 以 `localStorage.lang` 作为 i18n 与 `headers.lang` 的单一来源，并将接口缓存按 `lang/auth` 隔离；Flutter 已同步补强通用 Dio 内存缓存 key 和游戏接口内存缓存清理，避免同一进程内跨语言复用旧响应。由于项目维护需求不同，Flutter 不跟随 m1 的 `config_lang.status_s` 首启默认语言覆盖逻辑，无本地语言时仍保持中文首屏。
- 兑换码页面和我的页兑换码入口已补 `user.redemption.*` 全语言 key，中文/英文/缅文不再显示英文 fallback 或裸 key；反馈类型新增处罚/违规申诉相关 key，避免意见反馈分类列表出现 `feedback.types.*` 原始 key。
- 公告首屏闪烁继续加固：公告栏只拼当前语言匹配的公告；弹窗调度时记录当前语言，并在真正显示前再次复核语言和过滤后的公告列表，防止首启同步或切换过程中的旧语言公告闪一帧。
- 首页无数据模块已对齐 m1：Banner 仅在当前语言/terminal 有可见数据时显示；推荐游戏和热门游戏只有接口返回非空列表才渲染整块模块，不再显示模块标题、空态或错误占位。
- 按钮 loading 态已按 m1 `van-button :loading` 审计并补齐公共能力：`CustomButton` 支持内部 spinner 并自动禁用；充值提交、提现提交、充值凭证提交、取消订单、活动申请、反馈提交、资料保存、退出登录、实名/绑定/密码/加卡等提交按钮已接入；兑换码和找回密码自定义按钮已改为提交中显示 spinner；登录/注册提交、场馆钱包转入/转出已补齐“spinner + 文案”的稳定 loading 态，游戏启动遮罩在首页、游戏列表和搜索结果中统一为 m1 的半透明遮罩、24px spinner 和 13px 文案。
- 游戏启动失败提示按用户反馈调整为直接展示接口响应解析出的错误信息：`/game/login` 现在保留完整响应给 decoder，并兼容顶层、`data` 嵌套和字符串 JSON 响应；当接口返回 `code != 200`（例如 `{ code: 0, msg: "商户未开通该接口" }`）时强制抛业务异常展示接口 `msg`，当接口成功但 `data` 无有效 URL 时也优先展示接口 `msg`，避免只显示本地“进入游戏失败”；我的页今日收益标题区改为标题/日期纵向弹性布局，避免小屏或长语言下“今日收益”显示不全；首页、我的页和场馆钱包余额卡片货币符号统一固定为 `¥`，不再随语言或账户 `symbol` 变化；首页热门游戏 Grid 高度按内容行数收紧，一级标题和展示行间距对齐推荐游戏模块。
- 缅文长文案已按 m1 分场景处理：游戏标题、卡片标题等固定窄标题保留单行省略；底部导航、公共按钮、验证码按钮和我的页服务宫格按缅文环境缩小字号或允许两行；搜索、游戏子列表和游戏/资金管理类 Tab 改为横向滚动；空态、错误态、加载说明等正文反馈增加多行容量并用 fade 截断，避免关键说明过早显示省略号。
- 游戏维护中遮罩已对齐 m1 `maintain-mask`：推荐/热门游戏、游戏子列表、游戏大厅和搜索结果统一使用半透明黑色遮罩、居中 13sp/600 白色维护文案，不显示 loading spinner；搜索结果补齐维护中遮罩，维护状态覆盖启动态。
- 需要重点检查：登录/注册、首页、游戏大厅、充值、充值详情、在线支付、提现、资金管理、场馆钱包、个人中心、反馈、VIP、分享、维护页。
- 视觉验收维度：文本溢出、按钮截断、Tab 横向滚动、小屏换行、泰语/缅甸语行高、越南语长句、韩语紧凑排版。
- 接口动态数据不纳入前端翻译；如页面仍出现中文动态内容，需要后端按语言返回或提供稳定 code/type/status 映射。
- 仍建议后续把依赖中文字符串的业务判断改为依赖接口 code/type，例如支付方式图标、登录失效判断等。
- 当前收尾验证结果：locale JSON/key 对齐通过，直接 `.tr()` key 检查通过，动态 helper key 检查通过，生成 key 对齐通过，`flutter analyze` 无问题，`flutter build web --no-web-resources-cdn` 构建成功。

---
*本文档由 Agent 自动维护，将在后续复刻任务中持续更新进度。*
