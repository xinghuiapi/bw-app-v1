import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_env.dart';

enum ExternalUrlType {
  generic,
  banner,
  service,
  payment,
  game,
  appDownload,
  image,
}

class UrlPolicy {
  static const _globalHosts = String.fromEnvironment(
    'ALLOWED_EXTERNAL_HOSTS',
    defaultValue: '',
  );
  static const _paymentHosts = String.fromEnvironment(
    'PAYMENT_ALLOWED_HOSTS',
    defaultValue: '',
  );
  static const _gameHosts = String.fromEnvironment(
    'GAME_ALLOWED_HOSTS',
    defaultValue: '',
  );
  static const _serviceHosts = String.fromEnvironment(
    'SERVICE_ALLOWED_HOSTS',
    defaultValue: '',
  );
  static const _downloadHosts = String.fromEnvironment(
    'DOWNLOAD_ALLOWED_HOSTS',
    defaultValue: '',
  );

  static Uri? externalUri(String raw,
      {ExternalUrlType type = ExternalUrlType.generic}) {
    final normalized = normalize(raw);
    if (normalized.isEmpty) return null;

    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasScheme || uri.host.trim().isEmpty) return null;
    if (uri.userInfo.isNotEmpty) return null;
    if (!_isAllowedScheme(uri)) return null;
    if (!_isAllowedHost(uri, type)) return null;
    return uri;
  }

  static Uri? gameUri(String raw) =>
      externalUri(raw, type: ExternalUrlType.game);

  static bool isAllowedGameNavigation(String raw) => gameUri(raw) != null;

  static Future<bool> launchExternal(
    String raw, {
    ExternalUrlType type = ExternalUrlType.generic,
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    final uri = externalUri(raw, type: type);
    if (uri == null) return false;
    return launchUrl(uri, mode: mode);
  }

  static String normalize(String raw) {
    var value = raw.replaceAll('`', '').trim();
    value = value.replaceAll(RegExp(r'''^[\'\"]|[\'\"]$'''), '').trim();
    value = value.replaceAll(RegExp(r'\s+'), '');
    if (value.startsWith('//')) return 'https:$value';
    return value;
  }

  static bool _isAllowedScheme(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'https') return true;
    if (scheme != 'http') return false;
    if (AppEnv.isProduction) return false;
    return _isLocalHost(uri.host) ||
        _matchesHost(uri.host, _configuredBaseHosts());
  }

  static bool _isAllowedHost(Uri uri, ExternalUrlType type) {
    final typedHosts = _parseHosts(_hostsForType(type));
    if (type == ExternalUrlType.game && typedHosts.isEmpty) {
      return true;
    }

    final configured = <String>{
      ..._configuredBaseHosts(),
      ..._parseHosts(_globalHosts),
      ...typedHosts,
    };

    // Without a deployment allowlist we still block dangerous schemes and malformed
    // URLs, but avoid breaking existing third-party payment/game integrations.
    if (configured.isEmpty) return true;
    return _matchesHost(uri.host, configured);
  }

  static String _hostsForType(ExternalUrlType type) {
    switch (type) {
      case ExternalUrlType.payment:
        return _paymentHosts;
      case ExternalUrlType.game:
        return _gameHosts;
      case ExternalUrlType.service:
        return _serviceHosts;
      case ExternalUrlType.appDownload:
        return _downloadHosts;
      case ExternalUrlType.generic:
      case ExternalUrlType.banner:
      case ExternalUrlType.image:
        return '';
    }
  }

  static Set<String> _configuredBaseHosts() {
    return {
      _hostFrom(AppEnv.baseUrl),
      _hostFrom(AppEnv.assetBaseUrl),
    }.whereType<String>().toSet();
  }

  static String? _hostFrom(String raw) {
    final uri = Uri.tryParse(raw.trim());
    final host = uri?.host.trim().toLowerCase();
    return host == null || host.isEmpty ? null : host;
  }

  static Set<String> _parseHosts(String raw) {
    return raw
        .split(',')
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toSet();
  }

  static bool _matchesHost(String rawHost, Set<String> allowedHosts) {
    final host = rawHost.trim().toLowerCase();
    if (host.isEmpty) return false;
    for (final allowed in allowedHosts) {
      if (host == allowed || host.endsWith('.$allowed')) return true;
    }
    return false;
  }

  static bool _isLocalHost(String host) {
    final value = host.trim().toLowerCase();
    return value == 'localhost' || value == '127.0.0.1' || value == '::1';
  }

  static void debugRejected(String raw, ExternalUrlType type) {
    if (!kDebugMode) return;
    debugPrint('Blocked unsafe ${type.name} URL: ${normalize(raw)}');
  }
}
