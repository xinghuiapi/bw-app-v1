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
  bool isIncomeRebateClaiming = false;
  bool isIncomeCommissionClaiming = false;
  FyLevelPage fyLevelPage = const FyLevelPage();
  bool isFyLevelLoading = false;
  String? fyLevelError;
  TeamMemberPage teamMembers = const TeamMemberPage();
  bool isTeamLoading = false;
  bool isTeamLoadingMore = false;
  String? teamError;
  bool isRebateDisabled = false;
  String? vipLevelsError;
  String? dayRevenueError;
  String? rebateInfoError;
  String? rebateClaimError;
  String? incomeClaimError;
  bool isUploadingAvatar = false;
  RedemptionRecordPage? redemptionRecords;
  bool isRedemptionLoading = false;
  bool isRedemptionSubmitting = false;
  String? redemptionError;

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
    isIncomeRebateClaiming = false;
    isIncomeCommissionClaiming = false;
    fyLevelPage = const FyLevelPage();
    isFyLevelLoading = false;
    fyLevelError = null;
    teamMembers = const TeamMemberPage();
    isTeamLoading = false;
    isTeamLoadingMore = false;
    teamError = null;
    isRebateDisabled = false;
    vipLevelsError = null;
    dayRevenueError = null;
    rebateInfoError = null;
    rebateClaimError = null;
    incomeClaimError = null;
    isUploadingAvatar = false;
    redemptionRecords = null;
    isRedemptionLoading = false;
    isRedemptionSubmitting = false;
    redemptionError = null;
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

  Future<void> claimIncomeRebate() async {
    if (isIncomeRebateClaiming || isIncomeCommissionClaiming) return;

    isIncomeRebateClaiming = true;
    incomeClaimError = null;
    notifyListeners();

    try {
      await _service.claimMemberFsLog();
      await loadDayRevenue(refresh: true);
    } on ApiException catch (exception) {
      incomeClaimError = exception.message;
      rethrow;
    } catch (exception) {
      incomeClaimError = exception.toString();
      rethrow;
    } finally {
      isIncomeRebateClaiming = false;
      notifyListeners();
    }
  }

  Future<void> claimIncomeCommission() async {
    if (isIncomeRebateClaiming || isIncomeCommissionClaiming) return;

    isIncomeCommissionClaiming = true;
    incomeClaimError = null;
    notifyListeners();

    try {
      await _service.claimFy();
      await loadDayRevenue(refresh: true);
    } on ApiException catch (exception) {
      incomeClaimError = exception.message;
      rethrow;
    } catch (exception) {
      incomeClaimError = exception.toString();
      rethrow;
    } finally {
      isIncomeCommissionClaiming = false;
      notifyListeners();
    }
  }

  Future<void> loadFyLevels({bool refresh = false}) async {
    if (isFyLevelLoading) return;
    if (!refresh && fyLevelPage.levels.isNotEmpty) return;

    isFyLevelLoading = true;
    fyLevelError = null;
    notifyListeners();

    try {
      fyLevelPage = await _service.fetchFyLevels();
    } on ApiException catch (exception) {
      fyLevelError = exception.message;
      rethrow;
    } catch (exception) {
      fyLevelError = exception.toString();
      rethrow;
    } finally {
      isFyLevelLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTeamMembers({bool refresh = false}) async {
    if (isTeamLoading || isTeamLoadingMore) return;
    if (!refresh && teamMembers.records.isNotEmpty) return;

    isTeamLoading = true;
    teamError = null;
    notifyListeners();

    try {
      teamMembers = await _service.fetchTeamMembers(page: 1, size: 10);
    } on ApiException catch (exception) {
      teamError = exception.message;
      rethrow;
    } catch (exception) {
      teamError = exception.toString();
      rethrow;
    } finally {
      isTeamLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreTeamMembers() async {
    if (isTeamLoading || isTeamLoadingMore || !teamMembers.hasMore) return;

    isTeamLoadingMore = true;
    teamError = null;
    notifyListeners();

    try {
      final next = await _service.fetchTeamMembers(
        page: teamMembers.currentPage + 1,
        size: 10,
      );
      teamMembers = teamMembers.append(next);
    } on ApiException catch (exception) {
      teamError = exception.message;
      rethrow;
    } catch (exception) {
      teamError = exception.toString();
      rethrow;
    } finally {
      isTeamLoadingMore = false;
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

  Future<void> loadRedemptionRecords({bool refresh = false}) async {
    if (isRedemptionLoading) return;
    if (!refresh && redemptionRecords != null) return;

    isRedemptionLoading = true;
    redemptionError = null;
    notifyListeners();

    try {
      redemptionRecords = await _service.fetchRedemptionRecords();
    } on ApiException catch (exception) {
      redemptionError = exception.message;
      rethrow;
    } catch (exception) {
      redemptionError = exception.toString();
      rethrow;
    } finally {
      isRedemptionLoading = false;
      notifyListeners();
    }
  }

  Future<void> redeemCode(String code) async {
    if (isRedemptionSubmitting) return;
    isRedemptionSubmitting = true;
    redemptionError = null;
    notifyListeners();

    try {
      await _service.submitRedemptionCode(code);
      await loadRedemptionRecords(refresh: true);
    } on ApiException catch (exception) {
      redemptionError = exception.message;
      rethrow;
    } catch (exception) {
      redemptionError = exception.toString();
      rethrow;
    } finally {
      isRedemptionSubmitting = false;
      notifyListeners();
    }
  }
}
