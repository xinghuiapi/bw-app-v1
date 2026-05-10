# flutter_ui_project

`flutter_ui_project` 是当前最终落地的 Flutter 业务前端工程。本项目的核心目标是：在已经按 m1 项目制作完成的高仿 Flutter UI 上，接入 m1 的页面业务逻辑和真实接口，同时补齐一个合格 Flutter 项目应具备的工程能力。

## 项目定位

- 当前项目是主工程，不是 m1 Web 项目或旧 Flutter 项目的复制品。
- UI 来源是 m1 项目：当前 Flutter 页面应保持 m1 高仿 UI 的视觉、结构和交互体验。
- 页面业务逻辑来源是 m1 项目：接口调用时机、入参、跳转、登录态、弹窗、分页、状态处理按 m1 页面映射。
- 工程能力参考旧 Flutter 项目：网络层、Provider/Service/Model 分层、缓存、错误处理、平台能力等可参考旧 Flutter 的成熟经验。
- 最终实现落在当前 Flutter 项目：按当前项目的 `api/`、`services/`、`providers/`、`models/`、`router/` 分层继续实现，不整包复制任何旧项目。

## 参考源边界

| 参考源 | 角色 | 用途 | 禁止事项 |
| --- | --- | --- | --- |
| 当前 `flutter_ui_project` | 最终实现主工程 | 承载 Flutter UI、工程架构、业务对接和上线能力 | 不推倒重做已完成 UI |
| `/Users/john/Documents/trae_projects/bw-v3-504/src/projects/m1` | UI 和页面逻辑来源 | 高仿 UI 对齐、页面生命周期、接口调用、表单入参、跳转规则、状态处理、多语言 key | 不直接复制 Vue template/CSS 到 Flutter |
| `/Users/john/Documents/trae_projects/flutter-v1` | Flutter 工程能力参考 | 网络封装、Provider/Service/Model 组织、缓存、错误处理、平台适配、踩坑经验 | 不作为页面对接逻辑来源，不整包复制 |

### m1 项目参考重点

页面初始化、接口调用顺序、表单入参、跳转规则、登录态处理、loading/error/empty 状态等业务逻辑，以 m1 项目为准：

```text
/Users/john/Documents/trae_projects/bw-v3-504/src/projects/m1
```

重点参考：

- `views/**`: 页面生命周期、用户操作、跳转和状态处理。
- `api/**`: 接口路径、请求方法、入参字段和响应字段处理。
- `router/index.js`: 路由路径、页面参数、登录拦截和重定向规则。
- `i18n/messages/**`: 页面文案和多语言 key。

### 旧 Flutter 项目参考重点

旧 Flutter 项目只作为工程能力参考，例如网络层组织、Provider 拆分、模型解析、缓存策略、错误处理、平台适配和踩坑经验。不能按旧 Flutter 项目的页面逻辑作为当前页面对接依据，也不能整包复制旧实现。

```text
/Users/john/Documents/trae_projects/flutter-v1
```

## 实施原则

- 当前 Flutter UI 是 m1 高仿 UI，优先保留，只在业务状态接入所需范围内做最小改动。
- m1 的 Vue template/CSS 用于确认 UI 和交互意图，不用于直接复制代码。
- m1 的 script、api、router 是页面对接逻辑的主要依据。
- 旧 Flutter 项目用于补齐当前项目的 Flutter 工程能力，不决定页面业务逻辑。
- 数据模型按 m1 页面逐步校准：对接到哪个页面或业务闭环，就同步更新对应 `models/`，不要一次性全量迁移所有 m1 字段。
- m1 页面实际使用的字段优先进入模型；接口文档有但页面暂未使用的字段可以暂缓。
- 复杂 JSON 解析放在 Model/Service 层，不让 Screen 直接消费原始 `Map<String, dynamic>`。
- 每次对接一个页面或一个业务闭环，优先保证可验证、可回退。

## 常用命令

```bash
flutter pub get
./run_web.sh
dart format lib test
flutter analyze lib test
flutter test
```

### 启动项目

当用户说“启动项目”时，默认使用以下命令启动 Chrome 调试：

```bash
./run_web.sh
```

`run_web.sh` 内部使用 `flutter run -d chrome --no-web-resources-cdn`，用于避免 Flutter Web 默认访问 Google CDN 资源导致 CanvasKit/字体资源加载失败。启动后仍支持 `r` 热重载、`R` 热重启和 `q` 退出。
