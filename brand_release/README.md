# 多品牌发版工作区

这个目录集中维护多品牌批量打包相关文件。

## 文件说明

- `BRAND_RELEASE_INDEX.md`：品牌索引表，维护 `domain / logo / app_name`。
- `package_all_brands.dart`：批量打包脚本，循环调用项目现有统一单品牌命令。
- `test_brand_on_iphone.dart`：按品牌索引准备 logo、App 名和域名，并用 `flutter run` 安装运行到已连接 iPhone。
- `IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md`：单品牌 iOS unsigned IPA 打包说明和排错参考。
- `logos/`：品牌 PNG logo 存放目录。
- `release_artifacts/`：批量打包产物目录，已加入 `.gitignore`。

## 常用命令

批量打包所有启用品牌：

```bash
dart run brand_release/package_all_brands.dart
```

只打包指定品牌：

```bash
dart run brand_release/package_all_brands.dart --brand demo_brand
```

默认产物：

```text
brand_release/release_artifacts/品牌ID/品牌ID-v8.apk
brand_release/release_artifacts/品牌ID/品牌ID-unsigned.ipa
```

真机测试指定品牌：

```bash
dart run brand_release/test_brand_on_iphone.dart --brand demo_brand
```

指定 iPhone：

```bash
dart run brand_release/test_brand_on_iphone.dart --brand demo_brand --device 00008030-001479602198802E
```

真机测试使用 `flutter run` 和开发签名路径，不安装 `*-unsigned.ipa`。
