import '../base_provider.dart';
import '../../api/api_exception.dart';
import '../../api/dio_client.dart';
import '../../models/home/home_models.dart';
import '../../services/system/system_config_cache.dart';
import '../../services/system/system_service.dart';

class SystemProvider extends BaseProvider<HomeConfig> {
  SystemProvider({SystemService? service})
      : _service = service ?? SystemService(DioClient()),
        _cache = const SystemConfigCache();

  final SystemService _service;
  final SystemConfigCache _cache;

  bool _initialized = false;

  HomeConfig get config => data ?? const HomeConfig();
  bool get hasLoadedConfig => data != null;

  Future<void> loadConfig({bool refresh = false}) async {
    if (isLoading || (!refresh && _initialized)) return;

    if (!refresh && data == null) {
      await _loadCachedConfig();
    }

    isLoading = true;
    if (refresh) isRefreshing = true;
    notifyListeners();

    try {
      final config = await _service.fetchConfig();
      _initialized = true;
      data = config;
      await _cache.write(config);
      error = null;
    } on ApiException catch (exception) {
      _initialized = true;
      error = exception.message;
    } catch (exception) {
      _initialized = true;
      error = exception.toString();
    } finally {
      isLoading = false;
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> _loadCachedConfig() async {
    try {
      final cached = await _cache.read();
      if (cached == null) return;
      data = cached;
      error = null;
      notifyListeners();
    } catch (_) {
      await _cache.clear();
    }
  }
}
