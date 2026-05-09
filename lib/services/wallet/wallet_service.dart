import 'package:dio/dio.dart';

import '../../config/api_endpoints.dart';
import '../../models/common/upload_models.dart';
import '../../models/core/json_utils.dart';
import '../../models/wallet/wallet_models.dart';
import '../base_service.dart';

class WalletService extends BaseService {
  const WalletService(super.client);

  Future<List<WalletCard>> fetchCards() {
    return client.post<List<WalletCard>>(
      ApiEndpoints.drawingList,
      decoder: (json) => jsonList(json, WalletCard.fromJson),
    );
  }

  Future<UserRealtimeBalance> fetchRealtimeBalance() {
    return client.post<UserRealtimeBalance>(
      ApiEndpoints.userBalance,
      decoder: (json) {
        if (json is Map) {
          return UserRealtimeBalance.fromJson(Map<String, dynamic>.from(json));
        }
        return const UserRealtimeBalance();
      },
    );
  }

  Future<List<VenueBalance>> fetchVenueBalances() {
    return client.post<List<VenueBalance>>(
      ApiEndpoints.gameBalance,
      decoder: (json) => jsonList(json, VenueBalance.fromJson),
    );
  }

  Future<void> recycleVenueBalances() {
    return client.post<void>(
      ApiEndpoints.gameAllTrans,
      decoder: (_) {},
    );
  }

  Future<void> transferInVenue({required int id, required double money}) {
    return client.post<void>(
      ApiEndpoints.gameDeposit,
      data: {'id': id, 'money': money},
      decoder: (_) {},
    );
  }

  Future<void> transferOutVenue({required int id, required double money}) {
    return client.post<void>(
      ApiEndpoints.gameWithdrawal,
      data: {'id': id, 'money': money},
      decoder: (_) {},
    );
  }

  Future<void> setTransferMode(int type) {
    return client.post<void>(
      ApiEndpoints.gameTransfer,
      data: {'type': type},
      decoder: (_) {},
    );
  }

  Future<List<CardType>> fetchCardTypes(int type) {
    return client.post<List<CardType>>(
      ApiEndpoints.bankList,
      data: {'type': type},
      decoder: (json) => jsonList(json, CardType.fromJson),
    );
  }

  Future<void> bindCard(BindCardRequest request) {
    return client.post<void>(
      ApiEndpoints.memberBankBinding,
      data: request.toJson(),
      decoder: (_) {},
    );
  }

  Future<UploadImageResult> uploadCardImage({
    required List<int> bytes,
    required String filename,
  }) {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
      'name': 'member_bank',
    });
    return client.post<UploadImageResult>(
      ApiEndpoints.imageUpload,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
      decoder: (json) {
        final data = json is Map && json['data'] is Map ? json['data'] : json;
        if (data is Map) {
          return UploadImageResult.fromJson(Map<String, dynamic>.from(data));
        }
        return const UploadImageResult();
      },
    );
  }
}
