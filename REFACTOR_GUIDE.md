# Vue 3 (Vant 4) 到 Flutter 重构指南

本项目旨在将成熟的 Vue 3 移动端 Web 应用 `bw-m1-225(clone)` 重构为高性能的 Flutter 原生应用。本指南为 AI 辅助重构提供详细的架构映射、逻辑对标及迁移步骤。

---

## 1. 核心技术栈对标 (Mapping Table)

在 AI 辅助重构时，请参考下表进行逻辑转换：

| 功能模块 | Vue 3 (现有) | Flutter (目标) | 推荐库 / 方案 |
| :--- | :--- | :--- | :--- |
| **编程语言** | JavaScript (ES6+) | Dart 3.x | 强类型，空安全 |
| **UI 框架** | Vue 3 (Composition API) | Flutter (Declarative UI) | Widget-based UI |
| **UI 组件库** | **Vant 4** | **Material 3 / Custom** | 可参考 `flant` 或 `tdesign_flutter` |
| **状态管理** | **Vuex 4** / Pinia | **Riverpod** | 模块化、类型安全的状态管理 |
| **网络请求** | **Axios** | **Dio** | 支持拦截器、请求取消、FormData |
| **路由管理** | **Vue Router 4** | **go_router** | 支持 Deep Link 和声明式路由 |
| **国际化** | **Vue I18n** | **slang** | 类型安全的 i18n 方案 |
| **本地存储** | JS Cookie / LocalStorage | **shared_preferences** | 用于持久化 Token 和配置 |

---

## 2. 目录结构与开发约定 (Project Structure & Conventions)

请按照以下结构组织代码，并遵循相关开发约定：

| 目录路径 (lib/) | 职责说明 | 开发约定 |
| :--- | :--- | :--- |
| `api/` | 底层网络请求封装 | 使用 `DioClient` 单例，拦截器处理 Token/语言 |
| `models/` | 数据模型定义 | 必须使用 `json_serializable`，严禁使用 `dynamic` |
| `services/` | 业务接口封装 | 调用 `DioClient`，返回 `ApiResponse<T>` |
| `providers/` | 状态管理 (Riverpod) | 统一使用 `Notifier` / `AsyncNotifier` |
| `screens/` | 页面级 UI | 优先使用 `ConsumerWidget` |
| `widgets/` | 可复用 UI 组件 | 遵循原子化设计，复杂逻辑抽离至 Provider |
| `gen/` | 自动生成代码 | **禁止手动修改**，包含 i18n 生成代码 |

### 核心开发流程 (Core Workflow)

1.  **新增接口**: 在 `models/` 定义模型 -> 运行 `build_runner` -> 在 `services/` 封装调用。
2.  **状态流转**: 在 `providers/` 创建 Notifier -> 在 `screens/` 通过 `ref.watch` 监听。
3.  **多语言**: 在 `assets/translations/*.i18n.json` 修改文案 -> 运行 `dart run slang` -> 使用 `t.xxx` 调用。

---

## 3. 代码生成与版本管理 (Code Generation & Git)

为了保证团队协作的一致性，请遵循以下版本管理策略：

-   **生成文件策略**: `lib/gen/` (i18n) 和 `*.g.dart` (models) **建议纳入版本控制**，以确保 CI/CD 环境直接编译。
-   **禁止手动修改**: 任何 `*.g.dart` 或 `lib/gen/` 下的文件严禁手动编辑。
-   **清理仓库**: 严禁将 `.apk`、临时日志或个人配置文件提交至根目录。请定期检查 `git status` 保持环境整洁。

---

## 4. 国际化 (i18n) 配置说明

本项目使用 `slang` 方案，配置位于 `i18n.yaml`：
-   **输入目录**: `assets/translations/`
-   **输出目录**: `lib/gen/` (统一存放自动生成代码)
-   **调用方式**: 导入 `lib/gen/strings.g.dart`，使用全局变量 `t` 或 `TranslationProvider`。

---

## 3. 核心逻辑重构细节 (Refactoring Details)

### A. 网络请求与鉴权 (Dio Interceptors)
**原逻辑位置**: `src/api/index.js`, `src/utils/auth.js`
**Flutter 实现要点**:
1.  使用 `Dio` 创建全局单例。
2.  在 `onRequest` 拦截器中注入 `Authorization` Header。
3.  在 `onResponse` 或 `onError` 中处理 **401 状态码**，实现 Token 自动刷新逻辑（对标 `tokenRefreshManager.js`）。

### B. 首页逻辑 (Home Logic)
**原逻辑位置**: `src/views/basic/Home.vue`, `src/components/Home/`
**Flutter 实现要点**:
1.  **Banner**: 使用 `carousel_slider` 库。
2.  **Notices**: 使用 `marquee` 或自定义动画实现垂直滚动通知。
3.  **GameCategories**: 使用 `GridView` 配合 `TabBarView` 实现分类切换。

### C. 国际化 (i18n)
**原逻辑位置**: `src/i18n/locales/` (BR.js, CN.js, etc.)
**Flutter 实现要点**:
1.  将 `.js` 中的 JSON 对象转为 `i18n/strings_zh.i18n.json` 等文件。
2.  使用 `slang` 库运行生成代码，通过 `t.home.title` 这种强类型方式调用。

### D. 游戏 WebView 接入
**原逻辑位置**: `src/views/basic/GameView.vue`
**Flutter 实现要点**:
1.  使用 `webview_flutter` 库。
2.  处理全屏切换（横屏游戏）、加载进度条、以及 JS 与 原生的通信（JavascriptChannel）。

---

## 4. AI 辅助重构 Prompt (Prompt Templates)

你可以直接使用以下 Prompt 模板，将 Vue 代码交给 AI 进行转换：

### 场景 1：数据模型转换 (Model)
> "请根据以下 Vue 项目中的 API 响应数据/类型定义，生成对应的 Flutter Dart 模型类。要求使用 json_serializable 格式，包含 toJson 和 fromJson 方法：
> [粘贴 Vue 中的接口定义或 API 返回示例]"

### 场景 2：组件转换 (Component)
> "请按照重构指南，将以下使用 Vant 4 编写的 Vue 组件转换为 Flutter 的 StatelessWidget/StatefulWidget。
> 注意：样式请尽量使用 Material 3 属性复刻，状态逻辑请适配为 Riverpod 的模式。
> [粘贴 .vue 文件内容]"

### 场景 3：API 请求转换 (Service)
> "请将以下 Vue 项目中的 Axios 请求逻辑转换为 Flutter 中使用 Dio 的 Service 类。
> [粘贴 src/api/ 下的代码内容]"

---

## 5. 迁移优先级建议 (Roadmap)

1.  **基础框架 (Priority: P0)**: 引入 `dio`, `riverpod`, `go_router`, `slang`。
2.  **用户模块 (Priority: P0)**: 实现登录、Token 管理、个人中心。
3.  **首页展示 (Priority: P1)**: 实现 Banner、公告、游戏分类列表。
4.  **资金模块 (Priority: P1)**: 实现充值流程、余额展示。
5.  **核心功能 (Priority: P2)**: 游戏 WebView 嵌入、消息通知。

---

*加速 bw-m1-225 项目向 Flutter 原生平台的迁移。*
