# Tasks

- [x] Task 1: 初始化 Flutter 高还原度工程基建
  - [x] SubTask 1.1: 执行 `flutter create`，清理模板代码，配置 iOS/Android 原生侧的沉浸式状态栏 (Edge-to-Edge)。
  - [x] SubTask 1.2: 引入 `flutter_screenutil`, `flutter_svg`, `google_fonts`, `provider` 及 `go_router` 依赖。
  - [x] SubTask 1.3: 提取 Web 端所有 SVG 资源和切图，放入 `assets/` 并在 `pubspec.yaml` 中注册。
- [x] Task 2: 提取并构建 Design Tokens (ThemeData & ThemeExtension)
  - [x] SubTask 2.1: 解析原 Web CSS 变量，在 `app_colors.dart` 中建立精准的 Hex/Opacity 颜色映射表。
  - [x] SubTask 2.2: 在 `app_typography.dart` 中配置文字样式，确保 `fontSize` (.sp), `fontWeight`, `height` (行高倍数), `letterSpacing` 严格对齐设计稿。
  - [x] SubTask 2.3: 在 `app_theme.dart` 中使用 `ThemeExtension` 封装阴影 (`BoxShadow`)、圆角 (`BorderRadius`) 规范。
- [x] Task 3: 高精度封装原子组件 (Atomic Widgets)
  - [x] SubTask 3.1: 封装按钮组 (Primary/Outline/Text)，使用 `AnimatedContainer` 还原 Hover 和 Pressed 态的颜色及阴影过渡。
  - [x] SubTask 3.2: 封装输入框 (TextField)，高度还原聚焦状态的边框色变、外发光 (Glow) 及错误状态提示。
  - [x] SubTask 3.3: 封装通用卡片 (Card/Surface)，精准匹配 CSS `box-shadow` 的 spread 和 blur 半径，并实现毛玻璃背景 (`BackdropFilter`)。
- [x] Task 4: 搭建全局路由与页面过渡动画 (Routing & Transitions)
  - [x] SubTask 4.1: 配置 `go_router` 路由表，映射原 Web 的嵌套路由结构。
  - [x] SubTask 4.2: 自定义 `PageTransitionsBuilder`，还原 Web 侧页面切换时的滑动 (Slide) 或渐显 (Fade) 效果。
  - [x] SubTask 4.3: 封装带有手势动画的侧边栏 (Drawer) 或底部导航栏 (BottomNavigationBar)，保证切换丝滑。
- [x] Task 5: 核心业务页面静态与自适应还原 (Responsive Screens)
  - [x] SubTask 5.1: 还原首页/Dashboard，使用 `flutter_screenutil` 保证各类组件尺寸按屏幕比例缩放。
  - [x] SubTask 5.2: 还原列表/网格页，使用 `Sliver` 体系处理复杂滚动和粘性头部 (Sticky Headers)。
  - [x] SubTask 5.3: 处理长文本和边缘安全区 (SafeArea)，确保多端设备上无任何 UI 溢出 (Pixel Overflow)。
- [x] Task 6: 注入微交互与 Mock 数据 (Micro-interactions & Mocking)
  - [x] SubTask 6.1: 针对下拉菜单、折叠面板 (Accordion) 注入展开/折叠的补间动画 (`SizeTransition` 或 `AnimatedSize`)。
  - [x] SubTask 6.2: 填充极具真实感的 Mock 数据，测试长标题折行、数据为空等边界情况的 UI 表现。

# Task Dependencies
- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 2]
- [Task 4] depends on [Task 1]
- [Task 5] depends on [Task 3] and [Task 4]
- [Task 6] depends on [Task 5]
