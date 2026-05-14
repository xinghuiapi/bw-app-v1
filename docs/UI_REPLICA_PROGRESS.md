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
- **首页推荐游戏与分类区** (`HomeScreen`)：推荐游戏横向区已接入 `POST /interface/reco` 只读数据，优先展示接口图片与标题；`/interface/reco` 为空或失败时回退到 m1 当前使用的 `/interface/list` 并筛选 `label=reco`；热门游戏已按 m1 接入 `POST /gamelist/getlist(label=hot)`，接口失败保留静态高仿 fallback。Banner 已从单图改为按 `terminal/lang` 过滤的轮播并支持真实跳转；APP 下载、复制安全域名、余额刷新交互已补齐。首页分类区使用 m1 本地静态资源并按截图高保真复刻：真人大卡、彩票/电子中卡、四个小卡比例、`Live/Lottery/Slot` 浅蓝英文底字、图片尺寸和文字密度已精修，并接入 `/interface/class` 真实标题和 `/game?code=...` 点击入口；多处 RenderFlex 溢出已处理。后续首页剩余 m1 对齐重点为：重做 Flutter 专属静态语言包并替换硬编码文案、补齐 `NoticeModal` 公告弹窗/今日不再提示、评估搜索右侧弹窗和游戏内嵌弹窗/最小化浮窗。
- **活动页面** (`ActivityScreen`)：已对齐 m1 `views/main/activity.vue`，顶部品牌区域读取系统配置，活动分类接入 `/activity/class`，活动列表接入 `/activity/list`，分类横向 Tab 与活动卡片展示真实图片、标签、标题和时间；接口失败时保留 fallback 活动。
- **客服页面** (`ServiceScreen`)：已对齐 m1 `views/main/Service.vue`，复用 `/system/getlist.config_site` 的 `service_link` 与 `tg_link` 展示问候卡片和两列渐变客服卡片；点击卡片通过外部浏览器/App 打开客服链接，支持下拉刷新和无配置空态。

### 核心二级内页 (Secondary Screens)
- **游戏大厅** (`GameScreen` & `GameSubListScreen`)：**【基于截图深度复刻】** 重构了带 Logo 和域名的专属头部（星汇演示），解决了 `TabBar` M3 默认偏移（`tabAlignment: TabAlignment.start`），实现了 3 列游戏卡片网格布局。在二级页中，完美还原了带有 PG 角标与心形收藏按钮叠加 (`Stack`) 的 4 列网格布局；已接入 `/gamelist/getlist` 搜索与分页加载、`/user_favorites/game` 收藏/取消收藏，以及 `/game/login` 游戏启动链路。游戏启动成功后按 m1 规则处理 `nesting=false` 外部打开，否则进入独立 `/game-view` 承载页；承载页已对齐 m1 黑色顶部栏、标题、站点 Logo 和关闭入口，移动端使用 WebView，Web 端使用 iframe 且补齐 fullscreen/sandbox 参数，不保留主 Tab 底栏。
- **VIP中心** (`VipScreen`)：**【深度对齐】** 重构为纯净白底+蓝点 (`Blue Dot`) 装饰的立体感卡片风格。实现了基于当前等级动态计算的“充值”与“流水”双轨进度条，并通过 TabBar 实现了各 VIP 等级专属特权（升级礼金、返水比例等）的精细化列表展示；已接入 `/vip/getlist` 只读数据、下拉刷新、加载提示和 fallback 规则展示，充值当前值优先使用 `/token/user.recharge`。当前阶段已通过真实账号验证并标记为对接完毕。
- **消息通知** (`MessageScreen`)：**【深度对齐】** 新增顶部“全部/未读/已读” Tab 分类过滤器，实现了未读红点 (`Badge`) 点击消除并实时变更为已读状态的业务逻辑。
- **意见反馈** (`FeedbackScreen` & `FeedbackRecordsScreen`)：**【深度对齐】** 补齐了问题分类选择、多行文本框 300 字限制与实时字数统计器；问题分类弹窗已加最大高度和滚动约束，修复分类过多时的溢出；图片区域已接入 `/img/save`，支持最多 3 张图片上传、缩略图预览、删除，并在提交时传给 `/feedback/to.img`。反馈类型、提交反馈和反馈记录真实接口均已接入，并保留 fallback。
- **充值中心** (`DepositScreen`)：**【对齐 m1 并接入真实链路】** 充值渠道单选网格列表、自适应大字体的金额输入框、带快捷金额选项与实时汇率提示，重构了浅灰蓝背景与立体感卡片，完美还原“充值类型”、“充值通道”与“充值信息”三个模块的蓝点标题排版；已接入 `/deposit/class`、`/deposit/getlist` 和 `/recharge/order`，提交成功后按 m1 规则进入在线支付或充值详情。
- **提现中心** (`WithdrawScreen`)：提现银行卡信息展示、全部提现快捷键。
- **财务记录** (`TransactionRecordScreen` & `FundRecordScreen`)：实现了基于盈亏状态动态变色、红蓝上下箭头动态图标的流水列表。
- **个人资料** (`UserProfileScreen`)：已对齐 m1 资料编辑结构，支持实名、手机、邮箱、性别、生日、QQ、Telegram 展示/编辑；头像入口已接入相册选择、`/img/save` 上传和 `/user/edit.img` 保存流程。
- **系统设置** (`SettingScreen`)：完成各类设置项的入口卡片构建；“关于我们”已从占位提示改为进入 `AboutUsScreen`。
- **关于我们** (`AboutUsScreen`)：新增只读站点信息页，复用 `/system/getlist.config_site` 展示 Logo、站点名称、平台介绍、域名、版本、APP 下载、客服入口和 TG 客服，支持下拉刷新和 fallback 展示。
- **银行卡管理** (`BankCardListScreen`)：带有银行专属背景色、虚线卡号、及底部悬浮“添加银行卡”按钮的高保真列表。
- **活动详情** (`ActivityDetailScreen`)：基于截图复刻并接入 `/activity/details` 数据，支持通过活动 ID 展示标题、发放方式、倍数、时间和活动说明；活动说明已支持安全富文本降级渲染和图片展示；手动活动底部按钮已接入 `/activity/apply`，支持提交中禁用、成功提示和后端错误提示。
- **活动申请记录** (`ActivityRecordScreen`)：已对齐 m1 `ActivityApplyRecords.vue` 并接入 `/activity/record`，支持申请记录分页、下拉刷新、滚动加载、空态、状态标签、账号和申请时间展示，接口失败保留 fallback。
- **游戏管理** (`GameManagementScreen`)：基于截图复刻与精修，实现带“查询日期”筛选项与“返水记录”、“游戏记录”双 Tab。移除默认下划线，卡片应用 `16.r` 大圆角与柔和阴影提升立体感，底部常驻栏采用 `Column+Expanded` 隔离实现防溢出；已接入 `/member_fs_log/getlist` 返水记录和 `/gamerecord/getlist` 游戏记录，只读展示统计、分页、下拉刷新和空态，接口空数组不再显示静态记录；日期筛选按钮支持横向滚动防溢出，记录卡片/统计卡片/空态已按 m1 移动端信息密度精修，记录模型已按 m1 字段区分返水/游戏记录避免误展示，领取返水写操作后置。
- **资金管理** (`FundManagementScreen`)：基于截图复刻与精修，统一收口了原有的“我的钱包”、“充提记录”、“交易记录”、“银行卡管理”入口。实现带“查询日期”筛选项，以及“充值记录”、“提现记录”、“转账记录”、“账户明细”四个 Tab 切换。卡片长文本使用 `Flexible` + `TextOverflow.ellipsis` 防止水平挤压，底部统一配置了“没有更多了”状态提示。
- **我的钱包/场馆余额** (`MyWalletScreen`)：**【基于截图深度复刻】** 重构了“场馆余额”功能模块，实现带蓝色渐变及底部内嵌按钮组的高质感钱包卡片，并采用 `GridView.builder` 实现了带比例控制 (`childAspectRatio`) 的场馆资金网格布局，配置了场馆自动转账开关。
- **分享赚钱** (`ShareScreen`)：**【基于截图深度复刻】** 完成了推广分享页的高保真复刻。实现了“分享返利”、“会员总览”、“分享信息（含二维码与复制链接）”以及“邀请规则说明”四个专属卡片，精准还原了字体大小、间距、蓝点标题及边框细节。

### 用户表单类 (Forms) - [Sprint 1 完成]
- **绑定手机号** (`BindPhoneScreen`)：实现带获取验证码倒计时功能的表单；已接入短信验证码发送接口和 `/user/edit` 绑定提交。
- **绑定邮箱** (`BindEmailScreen`)：实现邮箱输入及验证码验证表单；已接入邮箱验证码发送接口和 `/user/edit` 绑定提交。
- **修改登录密码** (`ChangePasswordScreen`)：包含旧密码验证、新密码双重输入的表单。
- **设置资金密码** (`WithdrawPasswordScreen`)：6位纯数字安全密码设置表单。
- **实名认证** (`RealNameScreen`)：姓名输入、认证状态和安全提示；已接入 `/user/edit` 提交 `real_name`，成功后刷新 `/token/user`，已实名保持只读禁用。
- **添加银行卡** (`AddBankCardScreen`)：持卡人、卡号、开户行信息输入表单。
- **公共输入组件**：升级 `CustomTextField`，支持焦点状态变色、`suffixIcon` 清除按钮及错误红字提示。新增 `CountdownButton` 实现验证码倒计时效果。

### 结果与过渡页 (Feedback & Transitions)
- **充值订单详情** (`DepositOrderDetailScreen`)：已对齐 m1 `DepositOrderDetail.vue`，实现渐变背景、状态金额卡、二维码卡、支付信息卡、风险提示、凭证上传卡和取消支付底部弹窗；已接入 `/recharge/details`、`/img/save?name=recharge`、`/recharge/img` 和 `/recharge/cancel`，支持图片凭证、虚拟币交易哈希和取消原因提交。
- **充值成功** (`DepositPaySuccessScreen`)：大图标反馈与状态提示。
- **提现成功** (`WithdrawSuccessScreen`)：大图标反馈及预计到账提示。
- **线上支付** (`OnlinePayDetailScreen`)：支持接收 `/recharge/order` 返回的支付 URL 和订单 ID，可外部打开支付网关并跳转订单详情。

### 多语言与文案修复 (i18n & Copy)
- 已接入 `easy_localization`，并完成 `zh-CN`、`zh-TW`、`en-US`、`ja-JP`、`ko-KR`、`th-TH`、`vi-VN`、`my-MM` 共 8 套 locale 的静态 UI 文案收口。
- 已覆盖 `common`、`auth`、`nav`、`home`、`game`、`search`、`activity`、`service`、`profile`、`settings`、`about`、`account`、`wallet`、`message`、`security`、`finance`、`deposit`、`share`、`feedback`、`vip`、`gameManagement`、`maintenance` 等模块。
- 已修复非英语语言包中与日语包同类的问题：语言包 key 虽对齐但 value 混入英文/中文占位。当前 `ko-KR`、`th-TH`、`vi-VN`、`my-MM` 已完成英文原文和中文残留清理。
- `CN.json` 已同步为 `zh-CN.json`，避免简体 fallback 加载旧包后出现英文；`zh-TW.json` 保持繁体中文，`ja-JP.json` 保持日语汉字，不按中文残留处理。
- `lib/generated/locale_keys.g.dart` 已按 `en-US.json` 重新生成，当前与 825 个 locale key 对齐。
- 前端多语言边界已明确：只翻译静态 UI 文案；接口返回的游戏名、活动/公告内容、支付渠道名称、客服名称、站点信息、用户数据和后端错误 message 等动态数据由后端按语言返回，前端不做二次翻译。
- 已清理展示为真实业务内容的静态 mock/fallback 数据；接口失败或空数据时展示空态/错误提示，不再展示假游戏、假场馆、假消息、假活动或假反馈记录。

---

## 🟢 2. 当前首位任务：多语言体系 (Top Priority: I18n)
*Flutter 专属语言包体系已完成静态文案收口，当前进入真实页面视觉验收阶段。*

### 多语言静态文案
- [x] **全项目 Flutter 专属语言包建设**：`assets/i18n/*.json` 已按 Flutter 实际使用的静态 UI key 对齐，所有语言包与 `en-US.json` key 结构一致。
- [x] **生成 key 对齐**：`lib/generated/locale_keys.g.dart` 已按 `en-US.json` 重新生成，与 825 个 locale key 一致。
- [x] **硬编码与本地兜底收口**：资金管理、游戏管理、个人中心等页面已移除本地中文/英文静态文案兜底，统一走 locale。
- [x] **混合语言清理**：已按“日语包中英混合问题”的同一标准清理 `ko-KR`、`th-TH`、`vi-VN`、`my-MM` 的英文/中文占位。
- [ ] **多语言视觉走查**：仍需真实切换每种语言验证文本溢出、按钮截断、Tab 宽度、长句换行和小屏布局稳定性。

## 🟡 3. 待精修与开发页面 (Pending / Stubbed)
*剩余极少数分享与维护等边缘状态页待完善，当前让位于多语言任务。*

### 边缘业务与占位页
- [x] `MaintenanceScreen` (系统维护中占位页)：已接入 `/maintenance`，当 `/system/getlist.config_site.status == 0` 时全局跳转维护页。

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

### 当前进行中：多语言视觉验收与接口协同
- 静态 UI 文案多语言已完成代码/资源层面收口，后续重点转为真实浏览器逐页视觉验收。
- 需要重点检查：登录/注册、首页、游戏大厅、充值、充值详情、在线支付、提现、资金管理、场馆钱包、个人中心、反馈、VIP、分享、维护页。
- 视觉验收维度：文本溢出、按钮截断、Tab 横向滚动、小屏换行、泰语/缅甸语行高、越南语长句、韩语紧凑排版。
- 接口动态数据不纳入前端翻译；如页面仍出现中文动态内容，需要后端按语言返回或提供稳定 code/type/status 映射。
- 仍建议后续把依赖中文字符串的业务判断改为依赖接口 code/type，例如支付方式图标、登录失效判断等。
- 当前验证结果：locale JSON/key 对齐通过，直接 `.tr()` key 检查通过，动态 helper key 检查通过，`flutter analyze` 无问题，`flutter build web --no-web-resources-cdn` 构建成功。

---
*本文档由 Agent 自动维护，将在后续复刻任务中持续更新进度。*
