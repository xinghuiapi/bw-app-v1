---
name: "flutter-layout-fixer"
description: "提供 Flutter RenderFlex 布局溢出 (如黄黑警告条) 的修复策略与代码模板。当遇到 UI 错位、文本溢出或 Flex 比例失调时调用此 Skill。"
---

# Flutter 布局与溢出修复指南 (Layout Fixer)

在 Flutter 开发中，当遇到 `RIGHT OVERFLOWED BY X PIXELS` 等黄黑相间的警告条，或者由于多语言文本过长导致的组件错位时，请参考以下实战修复经验：

## 1. 约束 Row/Column 子组件的宽度分配
- **场景**: `Row` 或 `Column` 中的内容宽度/高度总和超出了父容器的限制。
- **修复**: 使用 `Expanded` 或 `Flexible` 包裹子组件，强制它们在可用空间内弹性分配比例，而不是任由其内容撑开。
  ```dart
  // 错误示范：内容过长会导致溢出
  Row(
    children: [
      Text('超长文本...'),
      Icon(Icons.add),
    ],
  )

  // 正确示范：使用 Expanded 约束文字宽度
  Row(
    children: [
      Expanded(
        child: Text('超长文本...'),
      ),
      Icon(Icons.add),
    ],
  )
  ```

## 2. 文本溢出截断 (Text Overflow)
- **场景**: 国际化翻译后的文本比原设计稿长，导致布局被挤压破裂。
- **修复**: 配合 `Expanded` 等约束边界的组件，给 `Text` 增加最大行数和省略号属性。
  ```dart
  Text(
    '长文本长文本长文本长文本',
    maxLines: 1, // 限制单行
    overflow: TextOverflow.ellipsis, // 溢出显示省略号
    textAlign: TextAlign.center, // 结合需要可配置居中
  )
  ```

## 3. 屏幕自适应与 Flex 比例
- **场景**: 使用了 `flutter_screenutil` (如 `100.w`) 但在极小屏幕上依然溢出。
- **修复**: 
  - 不要绝对依赖 `.w` 来保证不溢出，对于并排的多个操作按钮，应当使用 `Expanded` + `flex` 属性按比例瓜分。
  - 使用 `MainAxisAlignment.spaceAround` 或 `spaceBetween` 配合 `Expanded`，让内部组件的间距弹性收缩。
  - 必要时，适当缩小导致溢出的固定宽高图标（如 `size: 20.sp` -> `18.sp`）。

## 4. 滚动视图无边界错误
- **场景**: 将 `ListView` 或 `SingleChildScrollView` 嵌套在 `Column` 中，报 Unbounded height 错误。
- **修复**: 必须用 `Expanded` 将滚动视图包裹起来，给它一个明确的高度边界。
  ```dart
  Column(
    children: [
      HeaderWidget(),
      Expanded( // 必须有 Expanded 否则 ListView 无限高报错
        child: ListView(...),
      ),
    ],
  )
  ```
