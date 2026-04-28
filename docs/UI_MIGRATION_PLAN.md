# UI 转化进度与详细计划 (UI Migration Plan)

> **目标项目**: `flutter_ui_project`
> **参考项目**: `bw-v3/src/projects/m1` (Vue3 + Vant 移动端架构)
> **当前总体进度**: ~98% (核心业务页面已完成，仅剩极少数边缘占位页待完善)

---

## 阶段一：基础设施与静态资源 (Phase 1: Foundation & Assets)
*这一阶段负责把“盖房子”所需的“砖块”和“图纸”准备好。*

### 1.1 核心配置 (Core Setup)
- [x] 引入 `flutter_screenutil` 并完成初始化配置 (基于设计稿基准尺寸)。
- [x] 引入 `go_router` 并建立基础路由表。
- [x] 配置 `app_theme.dart` (全局 Material Theme)。
- [x] 配置 `app_colors.dart` (对齐 Vant 的 Primary, Success, Danger, Warning 等色值)。
- [x] 配置 `app_typography.dart` (字体大小、行高、字重映射)。

### 1.2 静态资源同步 (Assets Migration)
- [x] 创建 `assets/images/` 目录。
- [x] 创建 `assets/icons/` (或 `assets/svg/`) 目录。
- [x] 从 `bw-v3/src/projects/m1/assets` 拷贝所有通用图标和背景图。
- [x] 在 `pubspec.yaml` 中注册所有 assets 路径。
- [x] (可选) 封装 `AppImages` 或 `AppIcons` 静态类，方便代码中通过 `AppImages.logo` 调用。

### 1.3 国际化与本地化 (i18n Setup)
- [x] 引入 `flutter_localizations` 和相关多语言库 (如 `easy_localization` 或 `intl`)。
- [x] 映射 `bw-v3` 中的 `CN.js`, `EN.js`, `TH.js`, `VN.js` 等语言包到 Flutter 的 `.arb` 或 `.json` 文件。
- [x] 封装全局多语言切换逻辑。

---

## 阶段二：原子级/通用 UI 组件 (Phase 2: Common Components)
*这一阶段负责封装项目中高频复用的 Vant 风格组件。*

- [x] **CustomButton**: 基础按钮 (支持 Primary, Ghost, Disabled, Loading 态)。
- [x] **CustomTextField**: 输入框 (对齐 Vant Field，支持前缀图标、清除按钮、密码显隐、错误提示)。
- [x] **CustomNavBar**: 顶部导航栏 (带返回按钮、居中标题、右侧自定义 Action)。
- [x] **CustomTabBar**: 底部全局导航栏 (对应 Web 端的主 App 框架底导)。
- [x] **CustomCell / Card**: 列表项与卡片容器 (用于个人中心、设置等页面的列表排版)。
- [x] **NoticeBar**: 滚动通知公告栏。
- [x] **AppDownloadBar**: 顶部或底部的 App 下载引导条。
- [x] **SearchInput**: 搜索框组件。
- [x] **Dialog & Toast**: 全局弹窗、轻提示和 Loading 遮罩封装。

---

## 阶段三：业务模块转化 (Phase 3: Business Modules)
*按原项目 `m1/views` 的目录结构，逐个页面进行 1:1 UI 还原。*

### 3.1 身份验证模块 (Auth Module)
- [x] `LoginScreen` (对应 `Login.vue`): 账号/密码登录、验证码登录。
- [x] `RegisterScreen` (对应 `Register.vue`): 用户注册表单。
- [x] `ResetPasswordScreen` (对应 `ResetPassword.vue`): 忘记密码/重置密码。
- [x] `TelegramLoginScreen` (对应 `TelegramLogin.vue`): TG 快捷登录授权页。

### 3.2 首页与主业务模块 (Main Module)
- [x] `HomeScreen` (对应 `Home.vue`): 首页 (轮播图、金刚区、热门游戏推荐)。
- [x] `GameScreen` (对应 `Game.vue` / `GamePlay.vue`): 游戏大厅、WebView 游戏容器。
- [x] `GameSubListScreen` (对应 `GameSubList.vue`): 游戏子分类列表。
- [x] `ActivityScreen` (对应 `activity.vue`): 优惠活动列表。
- [x] `ActivityDetailScreen` (对应 `ActivityDetail.vue`): 活动详情图文。
- [x] `ServiceScreen` (对应 `Service.vue`): 客服中心/帮助页面。
- [ ] `MaintenanceScreen` (对应 `Maintenance.vue`): 系统维护拦截页。

### 3.3 财务模块 (Finance Module)
- [x] `DepositScreen` (对应 `Deposit.vue`): 充值中心 (支付通道列表、金额输入)。
- [x] `DepositOrderDetailScreen` (对应 `DepositOrderDetail.vue`): 充值订单确认与详情。
- [x] `DepositPaySuccessScreen` (对应 `DepositPaySuccess.vue`): 充值成功结果页。
- [x] `WithdrawScreen` (对应 `Withdraw.vue`): 提现页面 (提现金额、提现银行卡选择)。
- [x] `WithdrawSuccessScreen` (对应 `WithdrawSuccess.vue`): 提现发起成功页。
- [x] `OnlinePayDetailScreen` (对应 `OnlinePayDetail.vue`): 第三方线上支付跳转过渡页。

### 3.4 个人中心模块 (User Module)
**主入口**
- [x] `ProfileScreen` / `UserProfileScreen` (对应 `Profile.vue`): 我的页面主面板 (余额展示、快捷入口、菜单列表)。

**账户安全与设置**
- [x] `SettingScreen` (对应 `Setting.vue`): 系统设置。
- [x] `BindPhoneScreen` (对应 `BindPhone.vue`): 绑定/修改手机号。
- [x] `BindEmailScreen` (对应 `BindEmail.vue`): 绑定/修改邮箱。
- [x] `ChangePasswordScreen` (对应 `ChangePassword.vue`): 修改登录密码。
- [x] `WithdrawPasswordScreen` (对应 `WithdrawPassword.vue`): 设置/修改资金密码。
- [x] `RealNameScreen` (对应 `RealName.vue`): 实名认证。

**资金与记录**
- [x] `MyWalletScreen` (对应 `MyWallet.vue` / `FundManage.vue`): 资金管家/我的钱包。
- [x] `BankCardListScreen` (对应 `card/CardList.vue`): 银行卡/钱包地址管理列表。
- [x] `AddBankCardScreen` (对应 `card/AddCard.vue`): 添加银行卡/虚拟币钱包表单。

**其他功能**
- [x] `VipScreen` (对应 `Vip.vue`): VIP 等级与特权展示。
- [x] `MessageScreen` (对应 `Message.vue`): 站内信/通知列表。
- [x] `FeedbackScreen` (对应 `Feedback.vue`): 意见反馈表单。
- [x] `FeedbackRecordsScreen` (对应 `FeedbackRecords.vue`): 反馈历史记录。
- [x] `ShareScreen` (对应 `Share.vue`): 推广分享/邀请好友页。

---

## 阶段四：联调与体验优化 (Phase 4: Polish & Polish)
- [x] 完善路由传参和页面切换动画 (`go_router` 深度配置)。
- [x] 接入 API 请求库 (`dio`) 替代静态 Mock 数据。
- [x] 统一处理网络错误、空状态 (Empty State)、加载骨架屏 (Skeleton)。
- [x] 全面真机测试 (iOS 齐刘海/灵动岛适配、Android 底部小白条沉浸式适配)。
