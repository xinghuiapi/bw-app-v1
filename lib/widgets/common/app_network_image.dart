import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../config/app_env.dart';
import '../../theme/app_colors.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.optimize = true,
  });

  final String? url;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool optimize;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _normalizeUrl(url);
    final optimizedUrl = imageUrl == null
        ? null
        : _optimizeUrl(
            imageUrl,
            MediaQuery.devicePixelRatioOf(context),
          );
    final child = optimizedUrl == null
        ? _error()
        : _buildNetworkImage(
            optimizedUrl,
            MediaQuery.devicePixelRatioOf(context),
          );

    if (borderRadius == null) {
      return SizedBox(width: width, height: height, child: child);
    }
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }

  Widget _buildNetworkImage(String imageUrl, double devicePixelRatio) {
    if (kIsWeb) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        errorBuilder: (_, __, ___) => errorWidget ?? _error(),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: _targetPixels(width, devicePixelRatio),
      memCacheHeight: _targetPixels(height, devicePixelRatio),
      maxWidthDiskCache: _targetPixels(width, devicePixelRatio),
      maxHeightDiskCache: _targetPixels(height, devicePixelRatio),
      placeholder: (_, __) => placeholder ?? _placeholder(),
      errorWidget: (_, __, ___) => errorWidget ?? _error(),
    );
  }

  int? _targetPixels(double value, double devicePixelRatio) {
    if (!value.isFinite || value <= 0) return null;
    return (value * devicePixelRatio).round().clamp(1, 4096);
  }

  String _optimizeUrl(String value, double devicePixelRatio) {
    if (kIsWeb || !optimize || !value.startsWith('http')) return value;
    if (value.toLowerCase().endsWith('.svg')) return value;

    try {
      final uri = Uri.parse(value);
      final query = Map<String, String>.from(uri.queryParameters);
      if (query.containsKey('_opt')) return value;

      final targetWidth = _targetPixels(width, devicePixelRatio);
      final targetHeight = _targetPixels(height, devicePixelRatio);
      if (targetWidth != null) query['w'] = targetWidth.toString();
      if (targetHeight != null) query['h'] = targetHeight.toString();
      query.putIfAbsent('q', () => '85');
      query.putIfAbsent('m', () => _fitMode);
      query.putIfAbsent('f', () => 'webp');
      query['_opt'] = '1';

      return uri.replace(queryParameters: query).toString();
    } catch (_) {
      return value;
    }
  }

  String get _fitMode {
    switch (fit) {
      case BoxFit.cover:
        return 'cover';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.contain:
      case BoxFit.fitHeight:
      case BoxFit.fitWidth:
      case BoxFit.none:
      case BoxFit.scaleDown:
        return 'contain';
    }
  }

  Widget _placeholder() {
    return Container(
        width: width,
        height: height,
        color: AppColors.border.withValues(alpha: 0.55));
  }

  Widget _error() {
    return Container(
      width: width,
      height: height,
      color: AppColors.border.withValues(alpha: 0.45),
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined,
          color: AppColors.textSecondary),
    );
  }

  String? _normalizeUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.startsWith('//')) {
      return 'https:$trimmed';
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (AppEnv.assetBaseUrl.isEmpty) {
      return trimmed;
    }
    final base = AppEnv.assetBaseUrl.endsWith('/')
        ? AppEnv.assetBaseUrl.substring(0, AppEnv.assetBaseUrl.length - 1)
        : AppEnv.assetBaseUrl;
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$path';
  }
}
