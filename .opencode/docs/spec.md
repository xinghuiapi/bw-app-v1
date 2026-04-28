# Flutter UI Conversion Spec (High-Fidelity Edition)

## Why
目前项目 (bw-v3) 基于 Web 前端技术构建。为了支持多端原生体验，需要将现有的前端 UI 转化为纯 Flutter 页面项目。由于本次转化**追求极高的 UI 还原度（Pixel-Perfect）**，转化工作将严格对照原 Web 项目的设计细节（包括色彩、排版、阴影、动画过渡等）。本次仅涉及静态 UI 和交互还原，暂不进行接口对接。

## What Changes
- 创建全新的 Flutter 工程结构，采用规范化的目录划分。
- 1:1 提取 Web 端的 CSS/SCSS 变量（Design Tokens），建立 Flutter 侧的强类型 `ThemeData` 和 `ThemeExtension`。
- 将当前项目的核心组件转化为 Flutter 高定制化 Widget，完美还原圆角、边框、阴影、交互态（Hover/Pressed）。
- 建立声明式路由，并还原 Web 端的页面切换动画（Transitions）。
- 实现自适应布局体系，确保不同尺寸的移动设备上视觉比例与设计稿完全一致。

## Impact
- Affected specs: 原 Web 端的 UI 交互、视觉呈现、微动画（Micro-interactions）。
- Affected code: 新增独立 Flutter 工程，原 Web 侧代码作为视觉和交互的唯一参考基准（Source of Truth）。

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
- **安全区域 (Safe Area)**: 针对刘海屏和底部手势区，全局合理使用 `SafeArea` 或利用 `MediaQuery.padding` 调整 `Padding`。

### 3. 微交互与动画还原 (Micro-Interactions & Animations)
- **交互态 (States)**: 按钮和卡片的 `Hover`, `Active`, `Focus` 状态，通过 `MaterialStateProperty` 或自定义 `GestureDetector` + `AnimatedContainer` 还原颜色和阴影的平滑过渡。
- **过渡动画 (Transitions)**: 使用 `AnimatedOpacity`, `AnimatedPositioned`, `AnimatedSize` 替代 Web 的 CSS `transition`。
- **路由动画**: 在 `go_router` 中通过 `CustomTransitionPage` 还原页面的淡入淡出 (Fade) 或滑动 (Slide) 切换效果。

### 4. 分阶段实施路径
- **阶段一：基建与规范 (Infrastructure)**。初始化工程，构建基于 `ThemeExtension` 的设计系统，完成全局字体、颜色、尺寸基准配置。
- **阶段二：原子组件精雕 (Atomic Widgets)**。高精度封装 Button、Input、Card 等组件，通过单元测试级别的视觉比对，确保交互态和阴影像素级一致。
- **阶段三：复合组件与骨架 (Complex Components)**。还原复杂的导航栏、侧边栏、Tab 栏及底部弹窗 (BottomSheet)，确保动画流畅。
- **阶段四：页面组装与 Mock (Page Assembly)**。逐个组装业务页面，使用静态数据填充，处理溢出 (Overflow) 问题，确保各种极端内容长度下的表现与 Web 一致。

## ADDED Requirements
### Requirement: Pixel-Perfect Flutter UI Foundation
系统需要提供一套极高还原度的 Flutter UI 框架。

#### Scenario: 视觉与交互验收
- **WHEN** 在多尺寸设备（如 iPhone 15 Pro, iPad, Android 主流机型）上运行该项目
- **THEN** UI 布局无任何 Overflow 报错，字体排版、阴影层级、组件圆角与原 Web 项目视觉一致率达到 95% 以上，且按钮点击、页面切换动画丝滑无卡顿。
