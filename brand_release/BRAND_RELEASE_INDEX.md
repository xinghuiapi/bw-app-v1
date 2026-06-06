# 多品牌打包索引

本文档维护批量打包脚本使用的品牌索引。每一行代表一个品牌，脚本会按表格顺序循环调用统一打包命令：

```bash
dart run scripts/package_release.dart --name "App名字" --domain https://example.com
```

## Logo 目录

品牌 logo 统一存放在：

```text
brand_release/logos/
```

每个 logo 必须是 PNG 文件。建议使用正方形高清图片，例如 `1024x1024`。

## 产物目录

批量打包产物统一输出到：

```text
brand_release/release_artifacts/
```

每个品牌会生成独立子目录，子目录内保留两个最终发版文件：

```text
brand_release/release_artifacts/品牌ID/品牌ID-v8.apk
brand_release/release_artifacts/品牌ID/品牌ID-unsigned.ipa
```

其中 `v8.apk` 来自 Flutter split APK 的 arm64-v8a 产物：

```text
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## 品牌索引表

维护规则：

- `enabled` 为 `true` 时参与批量打包，`false` 时跳过。
- `brand_id` 使用英文、数字、下划线或短横线，作为产物子目录名。
- `domain` 填客户生产资源域名，不要带 `/api`。
- `logo_path` 填项目内 PNG 路径，推荐放在 `brand_release/logos/`，脚本会在打包前复制到 `assets/logo/logo.png`。

| enabled | brand_id | app_name | domain | logo_path |
| --- | --- | --- | --- | --- |
| false | demo_brand | 演示品牌 | https://example.com | brand_release/logos/demo_brand.png |
| true | tyc | 太阳城 | https://api.0591.ceo| brand_release/logos/tyc.png |
| true | ydgj | 云鼎国际 | https://229382.xh-bw.com | brand_release/logos/ydgj.png |
| true | xuyl | 新U娱乐 | https://464898.xh-bw.com | brand_release/logos/xuyl.png |
| true | amjs | 澳门金沙 | https://js4197.xh-bw.com | brand_release/logos/amjs.png |
| true | jjyl | 玖玖娱乐 | https://007007.xh-bw.com | brand_release/logos/jjyl.png |
| true | kxty | 开星体育 | https://akk112255.xh-bw.com| brand_release/logos/kxty.png |
| true | myanmar | MYANMAR | https://api.myanmarn.xyz | brand_release/logos/myanmar.png |


## 批量打包命令

```bash
dart run brand_release/package_all_brands.dart
```

只打包某几个品牌时，可以传入品牌 ID：

```bash
dart run brand_release/package_all_brands.dart --brand demo_brand
```

也可以临时指定索引文档和产物目录：

```bash
dart run brand_release/package_all_brands.dart \
  --index brand_release/BRAND_RELEASE_INDEX.md \
  --output brand_release/release_artifacts
```

## 真机测试命令

选择索引表中的一个品牌，并安装运行到已连接 iPhone：

```bash
dart run brand_release/test_brand_on_iphone.dart --brand demo_brand
```

多台 iPhone 连接时指定设备：

```bash
dart run brand_release/test_brand_on_iphone.dart --brand demo_brand --device 00008030-001479602198802E
```

说明：真机测试使用 `flutter run` 和开发签名路径，不安装 `*-unsigned.ipa`。
