import '../../config/api_endpoints.dart';
import '../../models/home/home_models.dart';
import '../base_service.dart';

class SystemService extends BaseService {
  const SystemService(super.client);

  Future<HomeConfig> fetchConfig() {
    return client.post<HomeConfig>(
      ApiEndpoints.systemConfig,
      decoder: (json) {
        final payload = Map<String, dynamic>.from(json as Map);
        final config = payload['data'] is Map ? payload['data'] : payload;
        return HomeConfig.fromJson(Map<String, dynamic>.from(config as Map));
      },
    );
  }
}
