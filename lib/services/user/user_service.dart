import '../../config/api_endpoints.dart';
import '../../models/user/user_models.dart';
import '../base_service.dart';

class UserService extends BaseService {
  const UserService(super.client);

  Future<UserProfile?> fetchProfile() {
    return client.post<UserProfile?>(
      ApiEndpoints.userToken,
      decoder: (json) {
        if (json is List && json.isNotEmpty && json.first is Map) {
          return UserProfile.fromJson(Map<String, dynamic>.from(json.first));
        }
        if (json is Map) {
          return UserProfile.fromJson(Map<String, dynamic>.from(json));
        }
        return null;
      },
    );
  }

  Future<VipOverview> fetchVipOverview() {
    return client.post<VipOverview>(
      ApiEndpoints.vipList,
      decoder: VipOverview.fromResponse,
    );
  }
}
