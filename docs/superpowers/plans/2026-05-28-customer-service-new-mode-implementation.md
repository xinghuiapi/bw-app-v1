# 客服新模式实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 Flutter 项目的客服页切换到纯 `config_kefu` 新模式，移除旧 `service_link/tg_link` 客服页回退，并把页面结构对齐到新模式列表形态。

**Architecture:** 保持现有 `SystemProvider -> HomeConfig -> ServiceScreen` 数据链路不变，只在系统配置模型上补齐 `config_kefu`，并将客服页渲染逻辑改为只消费结构化客服项。页面保留现有 `UrlPolicy` 安全外链打开能力，但彻底移除客服页对旧字段的依赖。

**Tech Stack:** Flutter, Provider, Easy Localization, Flutter Test

---

## 文件结构

本次实现预计涉及以下文件：

- 修改：`lib/models/home/home_models.dart`
  - 责任：为系统配置模型补齐 `config_kefu` 和客服项模型，提供基础解析能力。
- 修改：`lib/screens/main/main_screens.dart`
  - 责任：把 `ServiceScreen` 从旧双列卡片 + `service_link/tg_link` 模式切到纯 `config_kefu` 纵向列表模式。
- 修改：`assets/i18n/zh-CN.json`
  - 责任：补齐客服页新模式必需文案键。
- 修改：`assets/i18n/zh-TW.json`
  - 责任：补齐繁体环境下客服页新模式必需文案键。
- 修改：`assets/i18n/en-US.json`
  - 责任：补齐英文环境下客服页新模式必需文案键。
- 按需修改：`assets/i18n/ja-JP.json`
- 按需修改：`assets/i18n/ko-KR.json`
- 按需修改：`assets/i18n/th-TH.json`
- 按需修改：`assets/i18n/vi-VN.json`
- 按需修改：`assets/i18n/my-MM.json`
  - 责任：如果新模式缺少对应标题或动作文案，则一起补齐，避免运行时缺 key。
- 新增：`test/service_screen_new_mode_test.dart`
  - 责任：覆盖 `config_kefu` 渲染优先级、空态、旧模式忽略、标题回退等核心行为。
- 修改：`docs/superpowers/specs/2026-05-28-m1-customer-service-design.md`
  - 责任：如实现中发现设计需要微调，只允许做一致性修正，不改需求方向。

## Task 1: 补齐系统配置模型与 `config_kefu`

**Files:**
- Modify: `lib/models/home/home_models.dart`
- Test: `test/widget_test.dart`

- [ ] **Step 1: 先写失败测试，锁定 `config_kefu` 模型行为**

在 `test/widget_test.dart` 末尾附近追加一个解析测试，先验证当前 `HomeConfig` 还不支持 `config_kefu`。

```dart
test('system config parses config_kefu customer service items', () {
  final config = HomeConfig.fromJson({
    'config_kefu': [
      {
        'title': '专属客服',
        'link': ' https://support.example.com ',
        'icon': 'https://cdn.example.com/icon.png',
      },
      {
        'title': '',
        'link': '   ',
        'icon': '',
      },
    ],
  });

  expect(config.customerServiceItems.length, 1);
  expect(config.customerServiceItems.single.title, '专属客服');
  expect(
    config.customerServiceItems.single.link,
    'https://support.example.com',
  );
  expect(
    config.customerServiceItems.single.icon,
    'https://cdn.example.com/icon.png',
  );
});
```

- [ ] **Step 2: 运行单测确认失败**

Run: `flutter test test/widget_test.dart --plain-name "system config parses config_kefu customer service items"`
Expected: FAIL，提示 `HomeConfig` 没有 `customerServiceItems` 或 `config_kefu` 未被解析。

- [ ] **Step 3: 在模型层新增客服项模型与解析逻辑**

在 `lib/models/home/home_models.dart` 中做最小实现，新增 `CustomerServiceItem` 并把它挂到 `HomeConfig`。

```dart
class HomeConfig {
  final List<BannerModel> banners;
  final List<NoticeModel> notices;
  final SiteConfig? siteConfig;
  final List<RegisterFieldConfig> registerConfig;
  final CaptchaConfig? captchaConfig;
  final VerifyConfig? mailConfig;
  final VerifyConfig? smsConfig;
  final List<LanguageConfig> languages;
  final List<CurrencyConfig> currencies;
  final List<CustomerServiceItem> customerServiceItems;

  const HomeConfig({
    this.banners = const [],
    this.notices = const [],
    this.siteConfig,
    this.registerConfig = const [],
    this.captchaConfig,
    this.mailConfig,
    this.smsConfig,
    this.languages = const [],
    this.currencies = const [],
    this.customerServiceItems = const [],
  });

  factory HomeConfig.fromJson(Map<String, dynamic> json) => HomeConfig(
        banners: jsonList(json['config_banner'], BannerModel.fromJson),
        notices: jsonList(json['config_notice'], NoticeModel.fromJson),
        siteConfig: jsonMap(json['config_site']) == null
            ? null
            : SiteConfig.fromJson(jsonMap(json['config_site'])!),
        registerConfig:
            jsonList(json['config_reg'], RegisterFieldConfig.fromJson),
        captchaConfig: jsonMap(json['config_pic']) == null
            ? null
            : CaptchaConfig.fromJson(jsonMap(json['config_pic'])!),
        mailConfig: jsonMap(json['config_mail']) == null
            ? null
            : VerifyConfig.fromJson(jsonMap(json['config_mail'])!),
        smsConfig: jsonMap(json['config_send']) == null
            ? null
            : VerifyConfig.fromJson(jsonMap(json['config_send'])!),
        languages: jsonList(json['config_lang'], LanguageConfig.fromJson),
        currencies: jsonList(json['config_curr'], CurrencyConfig.fromJson),
        customerServiceItems:
            jsonList(json['config_kefu'], CustomerServiceItem.fromJson)
                .where((item) => item.link.isNotEmpty)
                .toList(),
      );

  Map<String, dynamic> toJson() => {
        'config_banner': banners.map((item) => item.toJson()).toList(),
        'config_notice': notices.map((item) => item.toJson()).toList(),
        if (siteConfig != null) 'config_site': siteConfig!.toJson(),
        'config_reg': registerConfig.map((item) => item.toJson()).toList(),
        if (captchaConfig != null) 'config_pic': captchaConfig!.toJson(),
        if (mailConfig != null) 'config_mail': mailConfig!.toJson(),
        if (smsConfig != null) 'config_send': smsConfig!.toJson(),
        'config_lang': languages.map((item) => item.toJson()).toList(),
        'config_curr': currencies.map((item) => item.toJson()).toList(),
        'config_kefu': customerServiceItems.map((item) => item.toJson()).toList(),
      };
}

class CustomerServiceItem {
  final String title;
  final String link;
  final String icon;

  const CustomerServiceItem({
    required this.title,
    required this.link,
    required this.icon,
  });

  factory CustomerServiceItem.fromJson(Map<String, dynamic> json) {
    return CustomerServiceItem(
      title: _normalizeServiceText(json['title']),
      link: _normalizeServiceText(json['link']),
      icon: _normalizeServiceText(json['icon']),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'link': link,
        'icon': icon,
      };
}

String _normalizeServiceText(dynamic raw) {
  var value = raw?.toString() ?? '';
  value = value.replaceAll('`', '').trim();
  value = value.replaceAll(RegExp(r'''^['"]|['"]$'''), '').trim();
  value = value.replaceAll(RegExp(r'\s+'), '');
  return value;
}
```

- [ ] **Step 4: 运行单测确认模型测试通过**

Run: `flutter test test/widget_test.dart --plain-name "system config parses config_kefu customer service items"`
Expected: PASS

- [ ] **Step 5: 提交模型层改动**

```bash
git add test/widget_test.dart lib/models/home/home_models.dart
git commit -m "feat: add customer service config model"
```

## Task 2: 把客服页切到纯 `config_kefu` 新模式

**Files:**
- Modify: `lib/screens/main/main_screens.dart`
- Test: `test/service_screen_new_mode_test.dart`

- [ ] **Step 1: 先写客服页行为测试**

新建 `test/service_screen_new_mode_test.dart`，覆盖“只认 `config_kefu`、旧模式字段被忽略、空态展示”这 3 个核心场景。

```dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_ui_project/models/home/home_models.dart';
import 'package:flutter_ui_project/providers/system/system_provider.dart';
import 'package:flutter_ui_project/providers/user/user_provider.dart';
import 'package:flutter_ui_project/screens/main/main_screens.dart';

void main() {
  testWidgets('service screen renders config_kefu items only', (tester) async {
    final systemProvider = _FakeSystemProvider(
      const HomeConfig(
        customerServiceItems: [
          CustomerServiceItem(
            title: '专属客服',
            link: 'https://support.example.com',
            icon: '',
          ),
        ],
        siteConfig: SiteConfig(
          serviceLink: 'https://legacy.example.com',
          tgLink: 'https://t.me/legacy',
        ),
      ),
    );

    await tester.pumpWidget(_wrapWithApp(systemProvider: systemProvider));

    expect(find.text('专属客服'), findsOneWidget);
    expect(find.text('在线客服'), findsNothing);
    expect(find.text('暂无客服通道'), findsNothing);
  });

  testWidgets('service screen shows empty when config_kefu missing', (
    tester,
  ) async {
    final systemProvider = _FakeSystemProvider(
      const HomeConfig(
        siteConfig: SiteConfig(
          serviceLink: 'https://legacy.example.com',
          tgLink: 'https://t.me/legacy',
        ),
      ),
    );

    await tester.pumpWidget(_wrapWithApp(systemProvider: systemProvider));

    expect(find.text('暂无客服通道'), findsOneWidget);
    expect(find.text('在线客服'), findsNothing);
  });
}
```

测试辅助类放在同文件底部，最小实现如下：

```dart
class _FakeSystemProvider extends ChangeNotifier implements SystemProvider {
  _FakeSystemProvider(this._config);

  final HomeConfig _config;

  @override
  HomeConfig get config => _config;

  @override
  bool get isLoading => false;

  @override
  Future<void> loadConfig({bool refresh = false}) async {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserProvider extends ChangeNotifier implements UserProvider {
  @override
  get profile => null;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrapWithApp({required SystemProvider systemProvider}) {
  return EasyLocalization(
    supportedLocales: const [Locale('zh', 'CN')],
    path: 'assets/i18n',
    fallbackLocale: const Locale('zh', 'CN'),
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider<SystemProvider>.value(value: systemProvider),
        ChangeNotifierProvider<UserProvider>(create: (_) => _FakeUserProvider()),
      ],
      child: const MaterialApp(home: ServiceScreen()),
    ),
  );
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `flutter test test/service_screen_new_mode_test.dart`
Expected: FAIL，原因是当前页面仍会渲染旧 `service_link/tg_link` 或结构不匹配。

- [ ] **Step 3: 最小改造 `ServiceScreen` 为新模式列表页**

在 `lib/screens/main/main_screens.dart` 中做以下调整：
- `_supportCards` 不再读取 `site.serviceLink` 和 `site.tgLink`
- 改为从 `systemProvider.config.customerServiceItems` 构建列表
- 客服项从双列 `GridView.builder` 改为纵向 `ListView` / `Column` 列表
- `titleEn` 等旧模式字段删除，改成贴近新模式的单主标题 + 操作文案

关键代码可按下面结构替换：

```dart
final cards = _supportCards(systemProvider.config.customerServiceItems);

List<_ServiceCardData> _supportCards(List<CustomerServiceItem> items) {
  return [
    for (var i = 0; i < items.length; i++)
      _ServiceCardData(
        titlePrimary: items[i].title.isNotEmpty
            ? items[i].title
            : items.length > 1
                ? 'service.onlineNumbered'.tr(namedArgs: {'index': '${i + 1}'})
                : 'service.online'.tr(),
        actionText: 'service.consult'.tr(),
        url: items[i].link,
        icon: items[i].icon,
      ),
  ];
}
```

`_ServiceCardData` 改成：

```dart
class _ServiceCardData {
  const _ServiceCardData({
    required this.titlePrimary,
    required this.actionText,
    required this.url,
    required this.icon,
  });

  final String titlePrimary;
  final String actionText;
  final String url;
  final String icon;
}
```

`_ServiceSupportCard` 改成纵向列表样式：

```dart
class _ServiceSupportCard extends StatelessWidget {
  const _ServiceSupportCard({required this.card, required this.onTap});

  final _ServiceCardData card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            if (card.icon.isNotEmpty)
              AppNetworkImage(
                url: card.icon,
                width: 32.w,
                height: 32.w,
                borderRadius: BorderRadius.circular(16.r),
              )
            else
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                card.titlePrimary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              card.actionText,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

列表渲染替换为：

```dart
if (cards.isEmpty)
  Padding(
    padding: EdgeInsets.only(top: 28.h),
    child: Text(
      systemProvider.isLoading ? 'service.loading'.tr() : 'service.empty'.tr(),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13.sp,
        color: AppColors.textSecondary,
      ),
    ),
  )
else
  Column(
    children: [
      for (final card in cards)
        _ServiceSupportCard(
          card: card,
          onTap: () => _openService(context, card.url),
        ),
    ],
  )
```

- [ ] **Step 4: 运行页面测试确认通过**

Run: `flutter test test/service_screen_new_mode_test.dart`
Expected: PASS

- [ ] **Step 5: 提交客服页新模式改动**

```bash
git add test/service_screen_new_mode_test.dart lib/screens/main/main_screens.dart
git commit -m "feat: switch service screen to new mode"
```

## Task 3: 补齐客服页文案并验证多语言键不缺失

**Files:**
- Modify: `assets/i18n/zh-CN.json`
- Modify: `assets/i18n/zh-TW.json`
- Modify: `assets/i18n/en-US.json`
- Modify: `assets/i18n/ja-JP.json`
- Modify: `assets/i18n/ko-KR.json`
- Modify: `assets/i18n/th-TH.json`
- Modify: `assets/i18n/vi-VN.json`
- Modify: `assets/i18n/my-MM.json`
- Test: `test/service_screen_new_mode_test.dart`

- [ ] **Step 1: 先补充新模式动作文案键**

在各语言 `service` 节点下增加 `consult`，避免新列表项右侧动作文字缺失。

中文示例：

```json
"service": {
  "title": "客服中心",
  "loading": "客服配置加载中...",
  "empty": "暂无客服通道",
  "online": "在线客服",
  "onlineNumbered": "在线客服{index}",
  "onlineSubtitle": "ONLINE SERVICE",
  "telegramSubtitle": "TELEGRAM SERVICE",
  "consult": "立即咨询",
  "invalidLink": "客服链接无效",
  "externalPluginMissing": "外链组件未加载，请完整重启应用后重试",
  "openFailed": "无法打开客服链接",
  "welcome": "欢迎来到客服中心",
  "guest": "游客"
}
```

英文示例：

```json
"service": {
  "title": "Support Center",
  "loading": "Loading support config...",
  "empty": "No support channels",
  "online": "Customer Service",
  "onlineNumbered": "Customer Service {index}",
  "onlineSubtitle": "ONLINE SERVICE",
  "telegramSubtitle": "TELEGRAM SERVICE",
  "consult": "Consult Now",
  "invalidLink": "Invalid support link",
  "externalPluginMissing": "External link plugin missing. Restart app and try again.",
  "openFailed": "Unable to open support link",
  "welcome": "Welcome to the support center",
  "guest": "Guest"
}
```

- [ ] **Step 2: 运行客服页测试确认文案键没有导致失败**

Run: `flutter test test/service_screen_new_mode_test.dart`
Expected: PASS

- [ ] **Step 3: 提交翻译改动**

```bash
git add assets/i18n/*.json test/service_screen_new_mode_test.dart
git commit -m "feat: add service new mode translations"
```

## Task 4: 跑回归验证并同步文档口径

**Files:**
- Modify: `docs/UI_REPLICA_PROGRESS.md`
- Modify: `docs/tasks.md`
- Test: `test/widget_test.dart`
- Test: `test/service_screen_new_mode_test.dart`

- [ ] **Step 1: 更新现有进度文档，去掉“旧客服模式已对齐”口径**

把旧描述改成明确的新模式状态，避免后续误读。

示例更新文案：

```md
- **客服页面** (`ServiceScreen`)：已切换到 `config_kefu` 新模式；客服页不再依赖 `config_site.service_link` 和 `tg_link`，当 `config_kefu` 为空时展示空态。
```

以及在 `docs/tasks.md` 中补一条完成记录：

```md
- [x] 客服页切换到 `config_kefu` 新模式：客服页仅消费结构化客服配置，不再回退旧站点链接字段。
```

- [ ] **Step 2: 运行模型与页面相关测试**

Run: `flutter test test/widget_test.dart --plain-name "system config parses config_kefu customer service items"`
Expected: PASS

Run: `flutter test test/service_screen_new_mode_test.dart`
Expected: PASS

- [ ] **Step 3: 运行基础 smoke test**

Run: `flutter test test/widget_test.dart`
Expected: PASS，或至少不新增与客服页改动相关的失败。

- [ ] **Step 4: 提交文档与验证收口改动**

```bash
git add docs/UI_REPLICA_PROGRESS.md docs/tasks.md test/widget_test.dart test/service_screen_new_mode_test.dart
git commit -m "docs: update service screen new mode progress"
```
