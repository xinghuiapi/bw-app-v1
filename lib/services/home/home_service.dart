import '../../config/api_endpoints.dart';
import '../base_service.dart';

class HomeService extends BaseService {
  const HomeService(super.client);

  Future<Map<String, dynamic>> fetchSystemConfig() {
    return client.get<Map<String, dynamic>>(
      ApiEndpoints.systemConfig,
      cache: true,
      decoder: (json) => Map<String, dynamic>.from(json as Map),
    );
  }
}
