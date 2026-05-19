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

  Future<List<DepositCategory>> fetchDepositCategories() {
    return client.post<List<DepositCategory>>(
      ApiEndpoints.depositClass,
      decoder: (json) => jsonList(json, DepositCategory.fromJson)
          .where((category) => category.displayTitle.isNotEmpty)
          .toList(growable: false),
    );
  }

  Future<List<DepositChannel>> fetchDepositChannels(int categoryId) {
    return client.post<List<DepositChannel>>(
      ApiEndpoints.depositList,
      data: categoryId > 0 ? {'id': categoryId} : null,
      decoder: (json) => jsonList(json, DepositChannel.fromJson)
          .where((channel) => channel.displayTitle.isNotEmpty)
          .toList(growable: false),
    );
  }

  Future<DepositOrderResult> createRechargeOrder(DepositOrderRequest request) {
    return client.post<DepositOrderResult>(
      ApiEndpoints.rechargeOrder,
      data: request.toJson(),
      decoder: (json) {
        if (json is Map) {
          return DepositOrderResult.fromJson(Map<String, dynamic>.from(json));
        }
        return const DepositOrderResult();
      },
    );
  }

  Future<RechargeDetail> fetchRechargeDetail(dynamic id) {
    return client.post<RechargeDetail>(
      ApiEndpoints.rechargeDetails,
      data: {'id': id},
      decoder: (json) {
        if (json is Map) {
          return RechargeDetail.fromJson(Map<String, dynamic>.from(json));
        }
        return const RechargeDetail();
      },
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

  Future<void> deleteCard(DeleteBankCardRequest request) {
    return client.post<void>(
      ApiEndpoints.memberBankDelete,
      data: request.toJson(),
      decoder: (_) {},
    );
  }

  Future<WithdrawOrderResult> createWithdrawOrder(WithdrawRequest request) {
    return client.post<WithdrawOrderResult>(
      ApiEndpoints.drawingOrder,
      data: request.toJson(),
      decoder: WithdrawOrderResult.fromResponse,
    );
  }

  Future<void> submitRechargeProof(RechargeProofRequest request) {
    return client.post<void>(
      ApiEndpoints.rechargeProof,
      data: request.toJson(),
      decoder: (_) {},
    );
  }

  Future<void> cancelRechargeOrder(RechargeCancelRequest request) {
    return client.post<void>(
      ApiEndpoints.rechargeCancel,
      data: request.toJson(),
      decoder: (_) {},
    );
  }

  Future<UploadImageResult> uploadRechargeImage({
    required List<int> bytes,
    required String filename,
  }) {
    return _uploadImage(bytes: bytes, filename: filename, name: 'recharge');
  }

  Future<UploadImageResult> uploadCardImage({
    required List<int> bytes,
    required String filename,
  }) {
    return _uploadImage(bytes: bytes, filename: filename, name: 'recharge');
  }

  Future<UploadImageResult> _uploadImage({
    required List<int> bytes,
    required String filename,
    required String name,
  }) {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
      'name': name,
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
