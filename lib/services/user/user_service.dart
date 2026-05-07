import 'package:dio/dio.dart';

import '../../config/api_endpoints.dart';
import '../../models/common/upload_models.dart';
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

  Future<void> updateProfile(UserProfileUpdateRequest request) {
    return client.post<void>(
      ApiEndpoints.userEdit,
      data: request.toJson(),
      decoder: (_) {},
    );
  }

  Future<UploadImageResult> uploadImage({
    required List<int> bytes,
    required String filename,
    String name = 'avatar',
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

  Future<void> changePassword(ChangePasswordRequest request) {
    return client.post<void>(
      ApiEndpoints.changePassword,
      data: request.toJson(),
      decoder: (_) {},
    );
  }

  Future<UserMessagePage> fetchMessages({int page = 1, int size = 10}) {
    return client.post<UserMessagePage>(
      ApiEndpoints.notifyList,
      data: {'page': page, 'size': size},
      decoder: UserMessagePage.fromResponse,
    );
  }

  Future<void> markMessageRead(int id) {
    return client.post<void>(
      ApiEndpoints.notifyStatus,
      data: {'id': id},
      decoder: (_) {},
    );
  }

  Future<List<FeedbackType>> fetchFeedbackTypes() {
    return client.post<List<FeedbackType>>(
      ApiEndpoints.feedbackTypeList,
      decoder: (json) {
        if (json is! List) return const [];
        return json
            .whereType<Map>()
            .map((item) =>
                FeedbackType.fromJson(Map<String, dynamic>.from(item)))
            .where((item) =>
                item.id > 0 && (item.title?.trim().isNotEmpty ?? false))
            .toList();
      },
    );
  }

  Future<void> submitFeedback(SubmitFeedbackRequest request) {
    return client.post<void>(
      ApiEndpoints.feedbackSubmit,
      data: request.toJson(),
      decoder: (_) {},
    );
  }

  Future<FeedbackRecordPage> fetchFeedbackRecords({
    int page = 1,
    int size = 10,
  }) {
    return client.post<FeedbackRecordPage>(
      ApiEndpoints.feedbackList,
      data: {'page': page, 'size': size},
      decoder: FeedbackRecordPage.fromResponse,
    );
  }

  Future<UserProfile?> setPayPassword(SetPayPasswordRequest request) {
    return client.post<UserProfile?>(
      ApiEndpoints.userPayPassword,
      data: request.toJson(),
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
}
