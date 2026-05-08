import '../../config/api_endpoints.dart';
import '../../models/game/game_management_models.dart';
import '../base_service.dart';

class GameManagementService extends BaseService {
  const GameManagementService(super.client);

  Future<RebateRecordPage> fetchRebateRecords(GameManageQuery query) {
    return client.post<RebateRecordPage>(
      ApiEndpoints.memberFsLogList,
      data: query.toRebateJson(),
      decoder: (json) {
        if (json is Map) {
          return RebateRecordPage.fromJson(Map<String, dynamic>.from(json));
        }
        return const RebateRecordPage();
      },
    );
  }

  Future<GameRecordPage> fetchGameRecords(GameManageQuery query) {
    return client.post<GameRecordPage>(
      ApiEndpoints.gameRecordList,
      data: query.toGameJson(),
      decoder: (json) {
        if (json is Map) {
          return GameRecordPage.fromJson(Map<String, dynamic>.from(json));
        }
        return const GameRecordPage();
      },
    );
  }
}
