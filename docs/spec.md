# Flutter UI Conversion Spec (High-Fidelity Edition)

## Why
当前项目是最终落地的 Flutter 业务前端主工程。UI 已经按照 m1 项目完成高仿，后续重点是在这套 Flutter 高仿 UI 上接入 m1 页面业务逻辑和真实接口，并补齐合格 Flutter 项目的工程能力。

UI 和页面对接逻辑以 `/Users/john/Documents/trae_projects/bw-6-2/src/projects/m1` 为准。本项目中所有“m1”“m1 项目”或“bw-6-2 参考项目”提法均固定指向该路径，不得使用 bw-6-2 的其他子项目、旧 Flutter 项目或其他相似目录替代。旧 Flutter 项目 `/Users/john/Documents/trae_projects/flutter-v1` 只作为 Flutter 工程能力参考，不作为页面对接逻辑来源。

## What Changes
- 保留当前 Flutter 工程结构、页面和通用组件，维护 m1 高仿 UI 成果。
- 以 m1 `views/**` 的页面行为为依据，映射页面初始化、按钮事件、表单校验、弹窗、分页、刷新和跳转规则。
- 以 m1 `api/**` 为依据，校准 Flutter `ApiEndpoints`、`Service`、`Model` 和 `Provider`。
- 以页面对接进度为边界逐步更新数据模型：页面用到的 m1 字段必须进入对应 Model，暂未使用的字段不做批量迁移。
- 以 m1 `router/index.js` 为依据，校准 Flutter `go_router` 的路径、参数、登录拦截和重定向。
- 以旧 Flutter 项目作为工程分层、网络封装、状态管理、缓存、错误处理和平台能力的实现经验参考。

## Impact
- Affected specs: 当前 Flutter UI 页面业务化、接口对接、状态流和路由行为。
- Affected code: 当前 Flutter 工程内的 `api/`、`config/`、`models/`、`services/`、`providers/`、`router/` 和必要的页面状态绑定。数据模型必须随页面对接同步校准，避免 Screen 中散落临时 Map 解析。
- Source of Truth: UI 和页面业务对接逻辑以 `/Users/john/Documents/trae_projects/bw-6-2/src/projects/m1` 为准；旧 Flutter 项目只参考工程能力，不参考页面对接逻辑。

## 技术栈规范 (Tech Stack Specification)
- **Framework**: Flutter (用于构建跨平台原生 UI)
- **Language**: Dart (强类型保证 UI 配置的严谨性)
- **State Management**: `provider` 或 `flutter_hooks` (用于管理 UI 内部的精细交互状态，如复杂动画控制、多步骤表单状态、展开/折叠)
- **Routing**: `go_router` (支持嵌套路由、深链接，并自定义 `PageTransitionsBuilder` 还原 Web 路由动画)
- **Styling/Theming**:
  - `ThemeData` + `ThemeExtension`: 用于构建结构化的设计系统 (Design System)，避免硬编码颜色和尺寸。
  - `flutter_screenutil`: 核心基石，用于等比例缩放（`.w`, `.h`, `.sp`, `.r`），解决多端屏幕碎片化问题。
- **Assets Management**: 
  - 矢量图形：`flutter_svg` (所有 Icon 和插画强制使用 SVG 以保证视网膜屏幕的高清渲染)。
  - 字体：`google_fonts` 或引入本地 OTF/TTF，必须配置 `fontFamilyFallback` 保证多语言下的基线对齐。

## 版本规范 (Version Specification)
- **Flutter SDK**: `>=3.19.0 <4.0.0` (推荐最新稳定版，利用 Impeller 渲染引擎提升复杂 UI 和动画的流畅度)
- **Dart SDK**: `>=3.3.0 <4.0.0`
- **Dependency Versions**:
  - `go_router`: `^13.2.0`
  - `flutter_screenutil`: `^5.9.0`
  - `flutter_svg`: `^2.0.10`
  - `provider`: `^6.1.2`
  - `cached_network_image`: `^3.3.1` (用于未来网络图片的高性能缓存展示)

## 高还原度转化方案 (High-Fidelity Conversion Methodology)

### 1. 设计令牌 (Design Tokens) 1:1 映射
- **色彩体系 (Color Palette)**: 提取 CSS 变量 (如 `--primary-color`, `--text-secondary`)，在 Flutter 中通过 `Color(0xFF...)` 严格映射，并考虑透明度 (Opacity) 的准确叠加。
- **排版系统 (Typography)**: 严格对齐 Web 端的 `font-size`, `font-weight`, `line-height`, `letter-spacing`。注意 Flutter 的 `height` 属性为行高/字号的倍数，需进行精确换算。
- **视觉修饰 (Effects)**: 
  - CSS `box-shadow` -> 转化为 Flutter `BoxShadow`，精确匹配 `color`, `offset`, `blurRadius`, `spreadRadius`。
  - CSS `backdrop-filter: blur` -> 使用 `BackdropFilter` 配合 `ImageFilter.blur` 实现毛玻璃效果。

### 2. 布局与适配策略 (Layout & Responsiveness)
- **基准设定**: 在 `ScreenUtilInit` 中严格设定与原 Web 设计稿一致的逻辑像素尺寸（例如 `designSize: const Size(375, 812)`）。
- **弹性与网格**:
  - Flexbox (`justify-content`, `align-items`) 转化为 `Row`/`Column` 的 `mainAxisAlignment` 和 `crossAxisAlignment`。
  - 对于 Web 的 `display: grid` 复杂布局，使用 `SliverGrid` 或 `GridView.builder` 配合 `crossAxisCount` 和 `childAspectRatio` 精确还原。
  - 游戏一级分类列表图片必须参考 bw-6-2 m1 `views/main/Game.vue` 的 `.provider-grid` / `.provider-cover`：3 列网格、12px 间距、标题在图片下方；`.provider-cover` 不设置固定高度或 `aspect-ratio`。Flutter 迁移时不得为一级分类图片强行套正方形高度，除非 bw-6-2 m1 对应页面明确如此。
- **安全区域 (Safe Area)**: 针对刘海屏和底部手势区，全局合理使用 `SafeArea` 或利用 `MediaQuery.padding` 调整 `Padding`。

### 3. 微交互与动画还原 (Micro-Interactions & Animations)
- **交互态 (States)**: 按钮和卡片的 `Hover`, `Active`, `Focus` 状态，通过 `MaterialStateProperty` 或自定义 `GestureDetector` + `AnimatedContainer` 还原颜色和阴影的平滑过渡。
- **过渡动画 (Transitions)**: 使用 `AnimatedOpacity`, `AnimatedPositioned`, `AnimatedSize` 替代 Web 的 CSS `transition`。
- **路由动画**: 在 `go_router` 中通过 `CustomTransitionPage` 还原页面的淡入淡出 (Fade) 或滑动 (Slide) 切换效果。

### 4. 分阶段实施路径
- **阶段一：对接规则校准 (Mapping Rules)**。建立 m1 页面、m1 API、Flutter Screen、Flutter Service/Provider 的映射关系。
- **阶段二：核心业务闭环 (Core Flows)**。优先接入启动配置、认证、首页、游戏、用户信息和钱包余额。
- **阶段三：扩展业务模块 (Business Modules)**。继续接入活动、充值提现、银行卡、消息、反馈、VIP 和记录类页面。
- **阶段四：稳定性验证 (Stabilization)**。验证 token 失效、重复提交、分页刷新、空状态、错误态、缓存和多语言，不破坏现有 UI。

## ADDED Requirements
### Requirement: Pixel-Perfect Flutter UI Foundation
系统需要提供一套极高还原度的 Flutter UI 框架。

#### Scenario: 视觉与交互验收
- **WHEN** 在多尺寸设备（如 iPhone 15 Pro, iPad, Android 主流机型）上运行该项目
- **THEN** UI 布局无任何 Overflow 报错，字体排版、阴影层级、组件圆角与原 Web 项目视觉一致率达到 95% 以上，且按钮点击、页面切换动画丝滑无卡顿。
