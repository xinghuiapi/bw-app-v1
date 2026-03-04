import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;
import 'dart:js_interop';

final Set<String> _registeredFactories = {};

Widget buildWebImage({
  required String url,
  required BoxFit fit,
  double? width,
  double? height,
  BorderRadius? borderRadius,
  Widget? errorWidget,
}) {
  final String viewId = 'img-${url.hashCode}-${fit.index}';

  if (!_registeredFactories.contains(viewId)) {
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final web.HTMLImageElement element =
          web.document.createElement('img') as web.HTMLImageElement;
      element.src = url;
      element.style.width = '100%';
      element.style.height = '100%';
      element.style.objectFit = _getFitString(fit);

      element.onerror = (web.Event event) {
        debugPrint('WebSafeImage: Failed to load image: $url');
      }.toJS;

      return element;
    });
    _registeredFactories.add(viewId);
  }

  Widget image = SizedBox(
    width: width,
    height: height,
    child: HtmlElementView(viewType: viewId),
  );

  if (borderRadius != null) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: image,
    );
  }
  return image;
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
