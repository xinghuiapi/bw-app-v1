# Checkpoints

- [x] Flutter 基础工程成功创建，成功执行 `flutter run`，iOS/Android 原生状态栏已配置沉浸式。
- [x] 核心库 (`go_router`, `flutter_screenutil`, `flutter_svg`, `provider`) 无版本冲突引入。
- [x] Web 端原有的所有 SVG 图标和位图资产 100% 导入并在 `pubspec.yaml` 中正确声明。
- [x] `app_colors.dart` 与 Web CSS 的色彩变量（含透明度叠加）映射验证完成，无硬编码。
- [x] `app_typography.dart` 的 `fontSize`, `height`, `fontWeight` 严格对齐原设计系统，使用 `.sp` 适配。
- [x] 基于 `ThemeExtension` 的全局设计规范 (`BoxShadow`, `BorderRadius`) 已在全局 `MaterialApp.theme` 中生效。
- [x] Button、Input 等基础组件的 Hover/Focus/Pressed 等交互态的微动画、色变过渡与原 Web 完全一致。
- [x] Card 等容器组件的阴影 (Spread/Blur 半径) 效果和毛玻璃背景肉眼不可见差异。
- [x] 路由层配置自定义 `PageTransitionsBuilder`，页面切换动画 (Slide/Fade) 与 Web 体验保持同频。
- [x] 首页、列表页、详情页等核心页面布局代码中严格使用 `.w`/`.h` 尺寸缩放体系。
- [x] 针对长文本、深层嵌套层级进行边界测试，在不同宽高比的模拟器上确认无 Overflow 像素溢出警告。
- [x] 下拉菜单、折叠面板等带有物理位移效果的组件已接入补间动画 (`AnimatedSize` 等)，无生硬闪烁。
- [x] 代码质量：运行 `flutter analyze` 零错误、零高危警告；整体 UI 对比 Web 还原率达 95% 以上。
