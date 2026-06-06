# 品牌 Logo 目录

这里存放批量打包使用的品牌 PNG logo。

维护方式：

1. 把每个品牌的 PNG logo 放到本目录，例如 `brand_a.png`。
2. 在 `brand_release/BRAND_RELEASE_INDEX.md` 的 `logo_path` 中填写对应路径。
3. 将该品牌的 `enabled` 改为 `true` 后执行批量打包命令。

示例：

```text
brand_release/logos/brand_a.png
```
