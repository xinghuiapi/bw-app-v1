import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;
import 'dart:js_interop';

final Set<String> _registeredFactories = {};

Widget buildWebImage({
  required String url,
  required BoxFit fit,
  Alignment alignment = Alignment.center,
  double? width,
  double? height,
  BorderRadius? borderRadius,
  Widget? errorWidget,
}) {
  // 解析圆角 (将其转化为 CSS 属性以避免使用 Flutter 的 ClipRRect，这在 Web 上极其耗费性能)
  String borderRadiusCss = '';
  if (borderRadius != null) {
    final tl = borderRadius.topLeft.x;
    final tr = borderRadius.topRight.x;
    final br = borderRadius.bottomRight.x;
    final bl = borderRadius.bottomLeft.x;
    borderRadiusCss = '${tl}px ${tr}px ${br}px ${bl}px';
  }

  // 使用 Base64 或简单的 URL 清理作为 ID，确保其在 DOM 中唯一且稳定
  final String encodedUrl = Uri.encodeComponent(url).replaceAll('%', '');
  final String viewId =
      'img-$encodedUrl-${fit.name}-${alignment.x}-${alignment.y}-$borderRadiusCss';

  if (!_registeredFactories.contains(viewId)) {
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final web.HTMLImageElement element =
          web.document.createElement('img') as web.HTMLImageElement;
      element.src = url;
      element.style.width = '100%';
      element.style.height = '100%';
      element.style.objectFit = _getFitString(fit);
      element.style.objectPosition = _getAlignmentString(alignment);
      element.style.pointerEvents = 'none'; // 防止 HTML 图片拦截 Flutter 层的点击事件

      if (borderRadiusCss.isNotEmpty) {
        element.style.borderRadius = borderRadiusCss;
      }

      element.onerror = (web.Event event) {
        debugPrint('WebSafeImage: Failed to load image: $url');
      }.toJS;

      return element;
    });
    _registeredFactories.add(viewId);
  }

  return SizedBox(
    width: width,
    height: height,
    child: HtmlElementView(viewType: viewId),
  );
}

String _getFitString(BoxFit fit) {
  switch (fit) {
    case BoxFit.cover:
      return 'cover';
    case BoxFit.contain:
      return 'contain';
    case BoxFit.fill:
      return 'fill';
    case BoxFit.fitHeight:
      return 'scale-down';
    case BoxFit.fitWidth:
      return 'scale-down';
    case BoxFit.none:
      return 'none';
    case BoxFit.scaleDown:
      return 'scale-down';
  }
}

String _getAlignmentString(Alignment alignment) {
  if (alignment == Alignment.topLeft) return '0% 0%';
  if (alignment == Alignment.topCenter) return '50% 0%';
  if (alignment == Alignment.topRight) return '100% 0%';
  if (alignment == Alignment.centerLeft) return '0% 50%';
  if (alignment == Alignment.center) return '50% 50%';
  if (alignment == Alignment.centerRight) return '100% 50%';
  if (alignment == Alignment.bottomLeft) return '0% 100%';
  if (alignment == Alignment.bottomCenter) return '50% 100%';
  if (alignment == Alignment.bottomRight) return '100% 100%';

  // 自定义对齐处理
  final double x = (alignment.x + 1) / 2 * 100;
  final double y = (alignment.y + 1) / 2 * 100;
  return '${x.toStringAsFixed(0)}% ${y.toStringAsFixed(0)}%';
}
