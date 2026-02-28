import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;
import 'dart:js_interop';

class WebSafeImage extends StatelessWidget {
  static final Set<String> _registeredFactories = {};

  final String imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const WebSafeImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget();
    }

    // 判断是否为本地资源
    final bool isAsset = imageUrl.startsWith('assets/') || !imageUrl.contains('://');

    if (isAsset) {
      return _buildAssetImage();
    }

    final String correctedUrl = _normalizeUrl(_correctProtocol(imageUrl)).trim();
    
    if (!kIsWeb) {
      return _buildMobileImage(correctedUrl);
    }

    // Web 端处理：使用 HtmlElementView 绕过 CORS
    final String viewId = 'img-${correctedUrl.hashCode}-${fit.index}';
    
    // 注册视图工厂 (仅注册一次)
    if (!_registeredFactories.contains(viewId)) {
      debugPrint('WebSafeImage: Registering view for URL: $correctedUrl');
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
        final web.HTMLImageElement element = web.document.createElement('img') as web.HTMLImageElement;
        // 调试日志：打印实际加载的 URL
        debugPrint('WebSafeImage loading: $correctedUrl');
        element.src = correctedUrl;
        element.style.width = '100%';
        element.style.height = '100%';
        element.style.objectFit = _getFitString(fit);
        
        // 添加错误监听
        element.onerror = (web.Event event) {
          debugPrint('WebSafeImage: Failed to load image: $correctedUrl');
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

    return _applyBorderRadius(image);
  }

  String _correctProtocol(String url) {
    String processedUrl = url;
    // 处理协议相对路径 //
    if (processedUrl.startsWith('//')) {
      try {
        if (kIsWeb) {
          final String currentProtocol = web.window.location.protocol; // "http:" or "https:"
          processedUrl = '$currentProtocol$processedUrl';
        } else {
          processedUrl = 'https:$processedUrl'; // 移动端默认使用 https
        }
      } catch (e) {
        processedUrl = 'https:$processedUrl';
      }
    }

    if (!kIsWeb) return processedUrl;

    try {
      final String currentProtocol = web.window.location.protocol;
      if (currentProtocol == 'https:' && processedUrl.startsWith('http://')) {
        processedUrl = processedUrl.replaceFirst('http://', 'https://');
      }
    } catch (e) {
      debugPrint('Error getting protocol: $e');
    }
    return processedUrl;
  }

  /// 规范化 URL，处理路径中多余的斜杠 (例如: banner//image.jpg -> banner/image.jpg)
  String _normalizeUrl(String url) {
    if (url.isEmpty) return url;
    
    // 如果 URL 已经包含正确的协议，不要进行 URI 解析（避免端口丢失等问题）
    // 简单的字符串替换逻辑
    if (url.contains('://')) {
      final parts = url.split('://');
      final protocol = parts[0];
      final rest = parts.sublist(1).join('://');
      // 保持主机名之后的第一对 // 不变，替换路径中的 //
      // 注意：这里需要更精细的处理，避免破坏主机名和路径的连接
      final firstSlash = rest.indexOf('/');
      if (firstSlash != -1) {
        final host = rest.substring(0, firstSlash);
        final path = rest.substring(firstSlash).replaceAll(RegExp(r'/+'), '/');
        return '$protocol://$host$path';
      }
      return url;
    }
    return url.replaceAll(RegExp(r'/+'), '/');
  }

  Widget _buildAssetImage() {
    Widget image = Image.asset(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
    return _applyBorderRadius(image);
  }

  Widget _buildMobileImage(String url) {
    Widget image = CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) => placeholder ?? const SizedBox.shrink(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
    );
    return _applyBorderRadius(image);
  }

  Widget _buildErrorWidget() {
    return errorWidget ?? 
      Container(
        width: width,
        height: height,
        color: Colors.grey.withValues(alpha: 0.1),
        child: const Icon(Icons.error_outline, color: Colors.grey, size: 24),
      );
  }

  Widget _applyBorderRadius(Widget image) {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
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
        return 'contain'; // 近似
      case BoxFit.fitWidth:
        return 'contain'; // 近似
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scale-down';
    }
  }
}
