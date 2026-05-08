import '../../config/api_endpoints.dart';
import '../../models/wallet/record_models.dart';
import '../base_service.dart';

class RecordService extends BaseService {
  const RecordService(super.client);

  Future<RecordPage<TradeRecord>> fetchTradeRecords(
    RecordQuery query, {
    required String type,
  }) {
    return client.post<RecordPage<TradeRecord>>(
      ApiEndpoints.tradeRecord,
      data: query.toTradeJson(type),
      decoder: (json) {
        if (json is Map) {
          return RecordPage.fromJson(
            Map<String, dynamic>.from(json),
            TradeRecord.fromJson,
          );
        }
        return const RecordPage<TradeRecord>();
      },
    );
  }

  Future<RecordPage<TransferRecord>> fetchTransferRecords(RecordQuery query) {
    return client.post<RecordPage<TransferRecord>>(
      ApiEndpoints.transferLogList,
      data: query.toTransferJson(),
      decoder: (json) {
        if (json is Map) {
          return RecordPage.fromJson(
            Map<String, dynamic>.from(json),
            TransferRecord.fromJson,
          );
        }
        return const RecordPage<TransferRecord>();
      },
    );
  }

  Future<MoneyLogPage> fetchMoneyLogs(RecordQuery query) {
    return client.post<MoneyLogPage>(
      ApiEndpoints.moneyLogList,
      data: query.toMoneyLogJson(),
      decoder: (json) {
        if (json is Map) {
          return MoneyLogPage.fromJson(Map<String, dynamic>.from(json));
        }
        return const MoneyLogPage();
      },
    );
  }
}
