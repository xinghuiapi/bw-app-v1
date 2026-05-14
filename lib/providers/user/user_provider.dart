import '../../api/api_exception.dart';
import '../../api/dio_client.dart';
import '../../models/auth/auth_models.dart';
import '../../models/user/user_models.dart';
import '../../services/auth/auth_service.dart';
import '../../services/user/user_service.dart';
import '../base_provider.dart';

class UserProvider extends BaseProvider<UserProfile> {
  UserProvider({UserService? service})
      : _service = service ?? UserService(DioClient()),
        _authService = AuthService(DioClient());

  UserService _service;
  AuthService _authService;

  VipOverview? vipOverview;
  DayRevenueSummary? dayRevenue;
  RebateInfo? rebateInfo;
  RebateClaimResult? lastRebateClaim;
  List<VipLevel> vipLevels = const [];
  bool isVipLevelsLoading = false;
  bool isVipLevelsRefreshing = false;
  bool isDayRevenueLoading = false;
  bool isRebateInfoLoading = false;
  bool isRebateClaiming = false;
  bool isRebateDisabled = false;
  String? vipLevelsError;
  String? dayRevenueError;
  String? rebateInfoError;
  String? rebateClaimError;
  bool isUploadingAvatar = false;

  UserProfile? get profile => data;

  void bindClient(DioClient client) {
    _service = UserService(client);
    _authService = AuthService(client);
  }

  void resetForLanguageChange() {
    vipOverview = null;
    dayRevenue = null;
    rebateInfo = null;
    lastRebateClaim = null;
    vipLevels = const [];
    isVipLevelsLoading = false;
    isVipLevelsRefreshing = false;
    isDayRevenueLoading = false;
    isRebateInfoLoading = false;
    isRebateClaiming = false;
    isRebateDisabled = false;
    vipLevelsError = null;
    dayRevenueError = null;
    rebateInfoError = null;
    rebateClaimError = null;
    isUploadingAvatar = false;
    notifyListeners();
  }

  Future<void> loadProfile({bool refresh = false}) async {
    if (isLoading || isRefreshing) return;

    if (refresh) {
      isRefreshing = true;
    } else {
      isLoading = true;
    }
    error = null;
    notifyListeners();

    try {
      data = await _service.fetchProfile();
      error = null;
    } on ApiException catch (exception) {
      error = exception.message;
      rethrow;
    } catch (exception) {
      error = exception.toString();
      rethrow;
    } finally {
      isLoading = false;
      isRefreshing = false;
      notifyListeners();
    }
  }

  void clearProfile() {
    data = null;
    error = null;
    isLoading = false;
    isRefreshing = false;
    notifyListeners();
  }

  Future<void> loadVipLevels({bool refresh = false}) async {
    if (isVipLevelsLoading || isVipLevelsRefreshing) return;
    if (!refresh && vipLevels.isNotEmpty) return;

    if (refresh) {
      isVipLevelsRefreshing = true;
    } else {
      isVipLevelsLoading = true;
    }
    vipLevelsError = null;
    notifyListeners();

    try {
      vipOverview = await _service.fetchVipOverview();
      vipLevels = vipOverview!.levels;
      vipLevelsError = null;
    } on ApiException catch (exception) {
      vipLevelsError = exception.message;
      rethrow;
    } catch (exception) {
      vipLevelsError = exception.toString();
      rethrow;
    } finally {
      isVipLevelsLoading = false;
      isVipLevelsRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadDayRevenue({bool refresh = false}) async {
    if (isDayRevenueLoading) return;
    if (!refresh && dayRevenue != null) return;

    isDayRevenueLoading = true;
    dayRevenueError = null;
    notifyListeners();

    try {
      dayRevenue = await _service.fetchDayRevenue();
    } on ApiException catch (exception) {
      dayRevenueError = exception.message;
      rethrow;
    } catch (exception) {
      dayRevenueError = exception.toString();
      rethrow;
    } finally {
      isDayRevenueLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRebateInfo({bool refresh = false}) async {
    if (isRebateInfoLoading) return;
    if (!refresh && rebateInfo != null) return;

    isRebateInfoLoading = true;
    rebateInfoError = null;
    isRebateDisabled = false;
    notifyListeners();

    try {
      rebateInfo = await _service.fetchRebateInfo();
    } on ApiException catch (exception) {
      rebateInfoError = exception.message;
      if (_isNoInvitePolicy(exception.message)) {
        isRebateDisabled = true;
        rebateInfo = null;
        return;
      }
      rethrow;
    } catch (exception) {
      rebateInfoError = exception.toString();
      rethrow;
    } finally {
      isRebateInfoLoading = false;
      notifyListeners();
    }
  }

  Future<void> claimRebateAmount() async {
    if (isRebateClaiming) return;

    isRebateClaiming = true;
    rebateClaimError = null;
    notifyListeners();

    try {
      lastRebateClaim = await _service.claimRebateAmount();
      await loadRebateInfo(refresh: true);
      await loadProfile(refresh: true).catchError((_) {});
    } on ApiException catch (exception) {
      rebateClaimError = exception.message;
      rethrow;
    } catch (exception) {
      rebateClaimError = exception.toString();
      rethrow;
    } finally {
      isRebateClaiming = false;
      notifyListeners();
    }
  }

  bool _isNoInvitePolicy(String message) {
    return message.trim().contains('无可用邀请策略');
  }

  Future<void> updateProfile(UserProfileUpdateRequest request) async {
    if (isSubmitting) return;
    isSubmitting = true;
    error = null;
    notifyListeners();

    try {
      await _service.updateProfile(request);
      data = await _service.fetchProfile();
      error = null;
    } on ApiException catch (exception) {
      error = exception.message;
      rethrow;
    } catch (exception) {
      error = exception.toString();
      rethrow;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> uploadAvatar({
    required List<int> bytes,
    required String filename,
  }) async {
    if (isUploadingAvatar || isSubmitting) return;
    isUploadingAvatar = true;
    error = null;
    notifyListeners();

    try {
      final result = await _service.uploadImage(
        bytes: bytes,
        filename: filename,
        name: 'avatar',
      );
      final image = (result.url?.trim().isNotEmpty ?? false)
          ? result.url!.trim()
          : result.path?.trim();
      if (image == null || image.isEmpty) {
        throw const ApiException(
          type: ApiExceptionType.parse,
          message: 'Upload response missing image url',
        );
      }
      await _service.updateProfile(UserProfileUpdateRequest(img: image));
      data = await _service.fetchProfile();
      error = null;
    } on ApiException catch (exception) {
      error = exception.message;
      rethrow;
    } catch (exception) {
      error = exception.toString();
      rethrow;
    } finally {
      isUploadingAvatar = false;
      notifyListeners();
    }
  }

  Future<void> submitRealName(String realName) {
    return updateProfile(UserProfileUpdateRequest(realName: realName));
  }

  Future<VerificationCodeData> sendPhoneCode({
    required String phone,
    String areaCode = '+86',
  }) async {
    return _authService.sendSmsCode(
      phone: phone,
      areaCode: areaCode,
      type: 2,
    );
  }

  Future<VerificationCodeData> sendEmailCode({required String email}) async {
    return _authService.sendEmailCode(
      email: email,
      type: 2,
    );
  }

  Future<void> setPayPassword(SetPayPasswordRequest request) async {
    if (isSubmitting) return;
    isSubmitting = true;
    error = null;
    notifyListeners();

    try {
      final updatedProfile = await _service.setPayPassword(request);
      data = updatedProfile ?? await _service.fetchProfile();
      error = null;
    } on ApiException catch (exception) {
      error = exception.message;
      rethrow;
    } catch (exception) {
      error = exception.toString();
      rethrow;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    if (isSubmitting) return;
    isSubmitting = true;
    error = null;
    notifyListeners();

    try {
      await _service.changePassword(request);
      error = null;
    } on ApiException catch (exception) {
      error = exception.message;
      rethrow;
    } catch (exception) {
      error = exception.toString();
      rethrow;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
