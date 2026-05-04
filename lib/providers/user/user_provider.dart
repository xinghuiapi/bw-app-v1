import '../../api/api_exception.dart';
import '../../api/dio_client.dart';
import '../../models/user/user_models.dart';
import '../../services/user/user_service.dart';
import '../base_provider.dart';

class UserProvider extends BaseProvider<UserProfile> {
  UserProvider({UserService? service})
      : _service = service ?? UserService(DioClient());

  UserService _service;

  VipOverview? vipOverview;
  List<VipLevel> vipLevels = const [];
  bool isVipLevelsLoading = false;
  bool isVipLevelsRefreshing = false;
  String? vipLevelsError;

  UserProfile? get profile => data;

  void bindClient(DioClient client) {
    _service = UserService(client);
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
}
