# flutter_ui_project

`flutter_ui_project` 是当前最终落地的 Flutter 业务前端工程。本项目的核心目标是：在已经按 m1 项目制作完成的高仿 Flutter UI 上，接入 m1 的页面业务逻辑和真实接口，同时补齐一个合格 Flutter 项目应具备的工程能力。

## 项目定位

- 当前项目是主工程，不是 m1 Web 项目或旧 Flutter 项目的复制品。
- UI 来源是 m1 项目：当前 Flutter 页面应保持 m1 高仿 UI 的视觉、结构和交互体验。
- 页面业务逻辑来源是 m1 项目：接口调用时机、入参、跳转、登录态、弹窗、分页、状态处理按 m1 页面映射。
- 工程能力参考旧 Flutter 项目：网络层、Provider/Service/Model 分层、缓存、错误处理、平台能力等可参考旧 Flutter 的成熟经验。
- 最终实现落在当前 Flutter 项目：按当前项目的 `api/`、`services/`、`providers/`、`models/`、`router/` 分层继续实现，不整包复制任何旧项目。

## 当前进度

- 已完成核心页面的高仿 UI 复刻与主要业务对接。
- 已接入 `easy_localization`，并扩展到多套 locale：`zh-CN`、`zh-TW`、`en-US`、`ja-JP`、`ko-KR`、`th-TH`、`vi-VN`、`my-MM`。
- 已补齐全局字体回退，统一修复中文、英文和混排场景的字体缺失问题。
- 已完成前端静态 UI 文案多语言收口：`common`、`auth`、`home`、`game`、`activity`、`service`、`settings`、`about`、`account`、`wallet`、`message`、`security`、`finance`、`deposit`、`share`、`feedback`、`vip`、`gameManagement`、`maintenance` 等模块均由 locale 提供。
- 已完成非英语语言包混合语言清理：`ja-JP`、`ko-KR`、`th-TH`、`vi-VN`、`my-MM` 不再保留明显英文/中文占位；`CN.json` 已同步为 `zh-CN.json`，避免旧简体包回退导致英文显示。
- 静态 UI 多语言已收尾：locale JSON/key 对齐、生成 key 对齐、直接 `.tr()` key 检查、动态 helper key 检查、`flutter analyze` 和 Web 构建均已通过。
- 已清理会误导用户的静态业务 mock/fallback 数据；接口失败或空数据时展示空态/错误提示，不再展示假消息、假活动、假游戏、假场馆或假反馈记录。
- 语言切换时会同步清理语言敏感缓存，并让相关页面重新加载最新文案。
- 后续剩余工作集中在 m1 剩余交互与写操作闭环：提现提交、分享返利、返水领取、找回密码、Telegram 登录、首页公告弹窗、游戏最小化浮窗、银行卡删除和今日收益数据等，详见 `docs/UI_REPLICA_PROGRESS.md`。

## 多语言边界

- 前端只翻译静态 UI 文案，例如按钮、标题、表单提示、空态、toast、弹窗、页面说明和本地状态文案。
- 接口返回的动态数据不在前端翻译，例如游戏名称、活动标题/内容、公告内容、站点名称、客服名称、支付渠道名称、用户昵称、订单号、金额、时间和后端错误 message。
- 如需动态数据多语言，应由后端根据当前语言返回对应内容，或返回稳定 `code/type/status` 后由前端映射到静态 key。
- 专有名词和产品名可保留原文，例如 `Telegram`、`Alipay`、`USDT`、`VIP`、`QR Code`、`WeChat Pay`、`UnionPay`、`QuickPass`。

## 多语言校验口径

- 所有 `assets/i18n/*.json` 必须是合法 JSON。
- 所有语言包 key 结构必须与 `assets/i18n/en-US.json` 完全一致。
- `lib/generated/locale_keys.g.dart` 必须与 `en-US.json` key 集合一致。
- 所有直接 `.tr()` 使用的静态 key 必须存在于 `en-US.json`。
- 非英语语言包不得保留明显英文原文占位；日语允许正常日文汉字，繁中允许繁体汉字。
- `ko-KR`、`th-TH`、`vi-VN`、`my-MM` 不得残留中文占位。
- 完整验证至少运行：`flutter analyze`、`flutter build web --no-web-resources-cdn`、locale key 对齐脚本和 mixed-language 审计脚本。
- 截至当前收尾版本，上述静态 UI 多语言校验已通过；后续新增文案或页面时继续按本口径复验。

## 参考源边界

**m1 术语约定**：在本项目所有对话、任务、文档和代码评审中，只要提到“m1”“m1 项目”或“517 参考项目”，均固定指向 `/Users/john/Documents/trae_projects/bw-v3-517/src/projects/m1`。不得用 517 的 m2/m3/m4、旧 `bw-v3-504`、旧 Flutter 项目或其他相似目录替代。

| 参考源 | 角色 | 用途 | 禁止事项 |
| --- | --- | --- | --- |
| 当前 `flutter_ui_project` | 最终实现主工程 | 承载 Flutter UI、工程架构、业务对接和上线能力 | 不推倒重做已完成 UI |
| `/Users/john/Documents/trae_projects/bw-v3-517/src/projects/m1` | UI 和页面逻辑来源 | 高仿 UI 对齐、页面生命周期、接口调用、表单入参、跳转规则、状态处理、多语言 key；游戏一级分类图片布局以 `views/main/Game.vue` 的 `.provider-grid` / `.provider-cover` 为准 | 不直接复制 Vue template/CSS 到 Flutter；不得用 517 的 m2/m3/m4 或旧 `bw-v3-504` 替代 |
| `/Users/john/Documents/trae_projects/flutter-v1` | Flutter 工程能力参考 | 网络封装、Provider/Service/Model 组织、缓存、错误处理、平台适配、踩坑经验 | 不作为页面对接逻辑来源，不整包复制 |

### m1 项目参考重点

页面初始化、接口调用顺序、表单入参、跳转规则、登录态处理、loading/error/empty 状态等业务逻辑，以 m1 项目为准：

```text
/Users/john/Documents/trae_projects/bw-v3-517/src/projects/m1
```

重点参考：

- `views/**`: 页面生命周期、用户操作、跳转和状态处理。
- `api/**`: 接口路径、请求方法、入参字段和响应字段处理。
- `router/index.js`: 路由路径、页面参数、登录拦截和重定向规则。
- `i18n/messages/**`: 页面文案和多语言 key。
- 游戏一级分类图片布局参考 `views/main/Game.vue` 的 `.provider-grid` / `.provider-cover`：一级分类图片容器不设置固定高度或正方形比例；不要套用 `GameSubList.vue` 的子游戏正方形规则。

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

App 打包发布流程见：`docs/PACKAGING_GUIDE.md`。

### 当前打包命令速查

Android 测试分发优先使用旧 Flutter 项目同款分架构 release APK 命令：

```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols
```

如果需要在命令中显式注入生产域名和外链 allowlist，可使用扩展形式：

```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols \
  --dart-define=APP_ENV=production \
  --dart-define=API_BASE_URL=https://api.example.com/api \
  --dart-define=ASSET_BASE_URL=https://api.example.com \
  --dart-define=ALLOWED_EXTERNAL_HOSTS=example.com,cdn.example.com \
  --dart-define=PAYMENT_ALLOWED_HOSTS=pay.example.com \
  --dart-define=GAME_ALLOWED_HOSTS=game-vendor.com \
  --dart-define=SERVICE_ALLOWED_HOSTS=t.me,telegram.me \
  --dart-define=DOWNLOAD_ALLOWED_HOSTS=download.example.com
```

应用市场需要 AAB 时使用：

```bash
flutter build appbundle \
  --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols \
  --dart-define=APP_ENV=production \
  --dart-define=API_BASE_URL=https://api.example.com/api \
  --dart-define=ASSET_BASE_URL=https://api.example.com \
  --dart-define=ALLOWED_EXTERNAL_HOSTS=example.com,cdn.example.com \
  --dart-define=PAYMENT_ALLOWED_HOSTS=pay.example.com \
  --dart-define=GAME_ALLOWED_HOSTS=game-vendor.com \
  --dart-define=SERVICE_ALLOWED_HOSTS=t.me,telegram.me \
  --dart-define=DOWNLOAD_ALLOWED_HOSTS=download.example.com
```

临时 Web 构建使用：

```bash
dart run tool/prepare_web_fallback_fonts.dart
flutter build web \
  --release \
  --no-web-resources-cdn \
  --dart-define=APP_ENV=production \
  --dart-define=API_BASE_URL=https://api.example.com/api \
  --dart-define=ASSET_BASE_URL=https://api.example.com
```

正式打包前必须先确认 Android release 签名配置。使用扩展形式时，还要把示例域名替换成真实生产域名。

### 启动项目

当用户说“启动项目”时，默认使用以下命令启动 Chrome 调试：

```bash
./run_web.sh
```

`run_web.sh` 会先运行 `tool/prepare_web_fallback_fonts.dart`，为 Flutter Web CanvasKit 准备本地 fallback 字体映射，然后执行 `flutter run -d chrome --no-web-resources-cdn`，用于避免 Flutter Web 默认访问 Google CDN 资源导致 CanvasKit 资源或字体 fallback 加载失败。`web/flutter_bootstrap.js` 通过 `engineInitializer.initializeEngine` 配置了 `fontFallbackBaseUrl: 'assets/fallback_fonts/'`，用于阻止 CanvasKit 字体 fallback 默认请求 `https://fonts.gstatic.com/s/`。启动后仍支持 `r` 热重载、`R` 热重启和 `q` 退出。

### 外链安全配置

项目通过 `lib/security/url_policy.dart` 统一校验外链、支付链接、客服链接、游戏下载/承载链接和 Banner/公告跳转。默认会允许当前 `API_BASE_URL` 与 `ASSET_BASE_URL` 的域名，并阻止 `javascript:`、`data:`、`file:`、带 userInfo 的 URL、生产环境 `http:` 等危险链接。

上线时建议按业务域名补充 allowlist：

```bash
flutter build web \
  --dart-define=APP_ENV=production \
  --dart-define=ALLOWED_EXTERNAL_HOSTS=example.com,example-cdn.com \
  --dart-define=PAYMENT_ALLOWED_HOSTS=pay.example.com \
  --dart-define=GAME_ALLOWED_HOSTS=game-vendor.com \
  --dart-define=SERVICE_ALLOWED_HOSTS=t.me,telegram.me \
  --dart-define=DOWNLOAD_ALLOWED_HOSTS=download.example.com
```

未配置业务 allowlist 时，策略仍会做 scheme 和 URL 结构校验，但不会阻断现有第三方游戏/支付域名，避免开发联调被直接打断。
