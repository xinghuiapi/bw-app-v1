import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_flutter_app/utils/constants.dart';

// 使用条件导入来处理多平台
import 'web_safe_image_stub.dart'
    if (dart.library.js_util) 'web_safe_image_web.dart'
    if (dart.library.html) 'web_safe_image_web.dart';

class WebSafeImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Alignment alignment;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const WebSafeImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
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
    final bool isAsset =
        imageUrl.startsWith('assets/') || !imageUrl.contains('://');

    if (isAsset) {
      return _buildAssetImage();
    }

    final String correctedUrl = _optimizeUrl(
      _normalizeUrl(_correctProtocol(imageUrl)).trim(),
    );

    if (!kIsWeb) {
      return _buildMobileImage(correctedUrl);
    }

    // Web 端处理：通过平台特定的实现来处理
    return buildWebImage(
      url: correctedUrl,
      fit: fit,
      alignment: alignment,
      width: width,
      height: height,
      borderRadius: borderRadius,
      errorWidget: errorWidget,
    );
  }

  String _optimizeUrl(String url) {
    // 1. 检查是否为网络图片
    if (!url.startsWith('http')) return url;

    // 2. 检查是否为 svg，svg 不进行优化
    if (url.toLowerCase().endsWith('.svg')) return url;

    // 3. 解析 URL
    try {
      final uri = Uri.parse(url);
      final queryParams = Map<String, String>.from(uri.queryParameters);

      // 4. 添加优化参数 (复刻原项目 imageOptimizer.js 逻辑)
      // 如果已经有 _opt 参数，说明已经处理过，跳过
      if (queryParams.containsKey('_opt')) return url;

      // 自动计算宽高 (如果有指定)
      // 如果指定了宽高，则使用指定值 * 2 (高分屏优化)
      // 如果未指定，则不传 w/h 参数，让后端返回原尺寸（或者后续通过 LayoutBuilder 动态获取，但比较重）
      if (width != null && width!.isFinite && width! > 0) {
        queryParams['w'] = (width! * 2).toInt().toString();
      }

      if (height != null && height!.isFinite && height! > 0) {
        queryParams['h'] = (height! * 2).toInt().toString();
      }

      // 质量默认 85
      if (!queryParams.containsKey('q')) {
        queryParams['q'] = '85';
      }

      // 裁剪模式
      if (!queryParams.containsKey('m')) {
        String mode = 'contain';
        if (fit == BoxFit.cover)
          mode = 'cover';
        else if (fit == BoxFit.fill)
          mode = 'fill';
        else if (fit == BoxFit.contain)
          mode = 'contain';
        queryParams['m'] = mode;
      }

      // 格式 WebP (优先)
      if (!queryParams.containsKey('f')) {
        queryParams['f'] = 'webp';
      }

      // 优化标记
      queryParams['_opt'] = '1';

      return uri.replace(queryParameters: queryParams).toString();
    } catch (e) {
      // 解析失败返回原 URL
      return url;
    }
  }

  String _correctProtocol(String url) {
    String processedUrl = url;
    // 处理协议相对路径 //
    if (processedUrl.startsWith('//')) {
      processedUrl = 'https:$processedUrl';
    }
    // 如果没有协议且不带基础 URL 且不是本地资源，补全资源路径
    else if (!processedUrl.startsWith('http') &&
        !processedUrl.startsWith('assets/') &&
        !processedUrl.contains('://')) {
      final baseUrl = AppConstants.resourceBaseUrl.endsWith('/')
          ? AppConstants.resourceBaseUrl.substring(
              0,
              AppConstants.resourceBaseUrl.length - 1,
            )
          : AppConstants.resourceBaseUrl;
      final path = processedUrl.startsWith('/')
          ? processedUrl
          : '/$processedUrl';
      processedUrl = '$baseUrl$path';
    }
    return processedUrl;
  }

  String _normalizeUrl(String url) {
    if (url.isEmpty) return url;
    if (url.contains('://')) {
      final parts = url.split('://');
      final protocol = parts[0];
      final rest = parts.sublist(1).join('://');
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
      alignment: alignment,
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
      alignment: alignment,
      width: width,
      height: height,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
    );
    return _applyBorderRadius(image);
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
  }

  Widget _applyBorderRadius(Widget child) {
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}
