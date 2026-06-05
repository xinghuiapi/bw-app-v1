import '../base_provider.dart';
import '../../api/api_exception.dart';
import '../../api/dio_client.dart';
import '../../localization/app_language.dart';
import '../../models/home/home_models.dart';
import '../../services/system/system_config_cache.dart';
import '../../services/system/system_service.dart';

class SystemProvider extends BaseProvider<HomeConfig> {
  SystemProvider({SystemService? service})
      : _service = service ?? SystemService(DioClient()),
        _cache = const SystemConfigCache();

  SystemService _service;
  final SystemConfigCache _cache;

  bool _initialized = false;
  bool _hasRemoteConfig = false;
  int _configRequestSerial = 0;
  String Function() _languageGetter = () => AppLanguage.fallbackCode;

  HomeConfig get config => data ?? const HomeConfig();
  bool get hasLoadedConfig => data != null;
  bool get hasRemoteConfig => _hasRemoteConfig;

  void bindClient(DioClient client) {
    _service = SystemService(client);
  }

  void bindLanguageGetter(String Function() languageGetter) {
    _languageGetter = languageGetter;
  }

  void resetForLanguageChange() {
    _configRequestSerial++;
    data = null;
    error = null;
    isLoading = false;
    isRefreshing = false;
    _initialized = false;
    _hasRemoteConfig = false;
    notifyListeners();
  }

  Future<void> loadConfig({bool refresh = false}) async {
    if (isLoading || (!refresh && _initialized)) return;
    final requestSerial = ++_configRequestSerial;

    if (!refresh && data == null) {
      await _loadCachedConfig();
    }

    isLoading = true;
    if (refresh) isRefreshing = true;
    notifyListeners();

    try {
      final config = await _service.fetchConfig();
      if (requestSerial != _configRequestSerial) return;
      _initialized = true;
      _hasRemoteConfig = true;
      data = config;
      await _cache.write(
        config,
        languageCode: _languageGetter(),
        terminal: SystemService.h5Terminal,
      );
      error = null;
    } on ApiException catch (exception) {
      if (requestSerial != _configRequestSerial) return;
      _initialized = true;
      error = exception.message;
    } catch (exception) {
      if (requestSerial != _configRequestSerial) return;
      _initialized = true;
      error = exception.toString();
    } finally {
      if (requestSerial == _configRequestSerial) {
        isLoading = false;
        isRefreshing = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadCachedConfig() async {
    try {
      final cached = await _cache.read(
        languageCode: _languageGetter(),
        terminal: SystemService.h5Terminal,
      );
      if (cached == null) return;
      data = cached;
      error = null;
      notifyListeners();
    } catch (_) {
      await _cache.clear();
    }
  }
}
