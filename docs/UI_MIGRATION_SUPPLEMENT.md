# Flutter UI 迁移补充规范与解决方案

针对从 Web (Vue3) 迁移到 Flutter 的过程中容易遇到的“水土不服”问题，本补充文档提供了具体的解决方案和代码落地的最佳实践。

## 1. 资产与切图管理 (Asset Pipeline)
**问题**：Web 中直接写图片路径很常见，但 Flutter 中硬编码路径容易出错，且对多分辨率屏幕支持不友好。
**解决方案**：
- 必须建立静态映射类统一管理所有资产。
- 矢量图（SVG）使用 `flutter_svg`。

```dart
// lib/core/constants/app_assets.dart
class AppImages {
  static const String _imagePath = 'assets/images';
  static const String _iconPath = 'assets/icons';

  // 严禁在业务代码写 'assets/images/logo.png'
  static const String logo = '$_imagePath/logo.png';
  
  // SVG 图标
  static const String icHome = '$_iconPath/home.svg';
}

// 使用方式
SvgPicture.asset(AppImages.icHome, width: 24.w, height: 24.w);
```

## 2. 全局设计令牌字典 (Theme System)
**问题**：Web 中的 CSS 变量 (`--primary-color`) 在 Flutter 中如果没有强类型约束，会导致 UI 还原度极差且难以维护。
**解决方案**：
- 建立 `AppColors` 静态类。
- 对于复杂的阴影或卡片样式，使用 `ThemeExtension` 注入全局主题。

```dart
// lib/theme/app_colors.dart
class AppColors {
  static const Color primary = Color(0xFF1989FA); // 对应原 Web 主题色
  static const Color textMain = Color(0xFF323233);
}

// lib/theme/app_theme.dart (ThemeExtension 解决复杂阴影映射)
class AppShadows extends ThemeExtension<AppShadows> {
  final BoxShadow? cardShadow;
  AppShadows({this.cardShadow});

  // ... 必须实现 copyWith 和 lerp 方法
}
```

## 3. 屏幕适配方案 (Screen Scaling)
**问题**：Web 的 `rem/vw` 或响应式布局在 Flutter 中如果不统一基准，会导致不同设备上 UI 变形。
**解决方案**：
- 强制在 `main.dart` 初始化 `flutter_screenutil`，并**硬编码**设计稿基准尺寸（如 `375x812`）。
- 字体行高必须精确换算（`line-height / font-size`）。

```dart
// main.dart
ScreenUtilInit(
  designSize: const Size(375, 812), // 必须与原 Web 设计稿(如 Figma)保持一致
  minTextAdapt: true,
  builder: (context, child) => MaterialApp.router(...),
);

// 业务代码中的排版换算陷阱
Text(
  'Hello',
  style: TextStyle(
    fontSize: 16.sp,
    // Web: font-size: 16px; line-height: 24px;
    // Flutter: height = 24 / 16 = 1.5
    height: 1.5, 
  ),
)
```

## 4. 路由转场动画拦截 (Route Transitions)
**问题**：Web SPA 切换页面时通常有平滑的过渡，而 Flutter 默认的 Material 路由动画可能与原 Web 体验不符。
**解决方案**：
- 在 `go_router` 或全局 `ThemeData` 中配置 `PageTransitionsBuilder`，统一劫持页面切换动画。

```dart
// lib/theme/app_theme.dart
ThemeData(
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      // 将所有平台的路由动画统一改为类似 Web 的 FadeUpwards 或 自定义 Slide
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
)
```

## 5. 跨平台交互差异抹平 (Interaction Polishing)
**问题**：Web 的 `:hover` 和 `:active` 效果在 Flutter 中需要手动实现，否则按钮点击会显得生硬。
**解决方案**：
- 基础原子组件必须预埋 `MaterialStateProperty` 处理状态。
- 使用 `AnimatedContainer` 替代 CSS 的 `transition`。

```dart
// lib/widgets/custom_button.dart
ElevatedButton(
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith((states) {
      // 完美还原 Web 的 :active 状态（点击时颜色加深）
      if (states.contains(MaterialState.pressed)) {
        return AppColors.primary.withOpacity(0.8);
      }
      return AppColors.primary;
    }),
  ),
  onPressed: () {},
  child: Text('Submit'),
)
```