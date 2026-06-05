---
name: "screenshot-to-flutter"
description: "通过截图与源码高保真复刻 UI 为 Flutter 代码。当用户提供截图并要求复刻、迁移或开发新 UI 页面时调用。"
---

# Screenshot to Flutter Workflow (高保真 UI 复刻工作流)

当用户提供 UI 截图（可选附带原项目源码）并要求复刻或转化为 Flutter 代码时，严格按照以下标准工作流执行，确保高保真转化：

## Workflow Steps (标准工作流)

### 1. 骨架拆解与预演 (Widget Tree Analysis)
- **动作**：仔细观察截图视觉层级（结合源码 DOM 结构，如有）。
- **输出**：不要急于写代码，先向用户输出一份基于 Markdown 的 Flutter Widget Tree 骨架结构设计。
  - 明确指出哪里使用 `Row`、`Column`、`Stack`、`Expanded`。
  - 识别出潜在的可复用组件（如 `CustomCard`, `CustomButton`）。
- **确认**：向用户简述布局思路，确认无误后进入代码编写。

### 2. 视觉规范逆向提取 (Design Tokens Extraction)
- **动作**：从截图（或原项目样式源码）中提取关键设计资产。
- **提取内容**：
  - **Colors**：主色调、背景色、文字颜色、渐变色（估算 Hex 色值或从源码提取）。
  - **Typography**：标题字号、正文字号、字重（如 `FontWeight.bold`）。
  - **Spacing & Radius**：标准边距（Padding/Margin）、圆角弧度（BorderRadius）。
- **执行**：在代码中统一使用这些 Token（优先复用工作区现有的 `theme` 或常量，若无则在代码中局部定义并注释）。

### 3. 代码生成 (Code Generation)
- **动作**：基于确认的 Widget Tree 和提取的设计规范，编写 Flutter 源码。
- **要求**：
  - 保持代码模块化，抽取独立的 Widget 以避免 `build` 方法过长。
  - 确保代码结构清晰，注释完备。

### 4. 强制高保真自检与纠错 (Fidelity Check & Layout Fix)
- **动作**：代码生成后，自动执行内部自检。
- **关联检查点**：
  - **还原度校验 (ui-fidelity-checker 思想)**：自行对照截图，检查“间距、颜色、排版、圆角、阴影”五个维度的还原度是否达到 80% 以上。
  - **防溢出校验 (flutter-layout-fixer 思想)**：检查是否存在容易导致 RenderFlex 溢出的隐患（如 `ListView`/`Column` 嵌套未加 `Expanded`，`Text` 溢出未加 `overflow` 属性等），并提前增加约束保护。

## 交互话术示例
当被调用时，请以类似以下的话术回应用户，展现专业的工作流：
> “已收到截图，正在启动 `screenshot-to-flutter` 高保真复刻工作流。
> 首先，为您拆解该页面的 Widget Tree 骨架如下...
> 同时，我提取了以下关键设计规范 (色值、间距)...
> 接下来我将开始为您生成 Flutter 代码。”
