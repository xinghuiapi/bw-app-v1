import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:my_flutter_app/models/finance_models.dart';
import 'package:my_flutter_app/services/finance_service.dart';
import 'package:my_flutter_app/utils/toast_utils.dart';

part 'referral_provider.g.dart';

/// 推广返利状态
class ReferralState {
  final RebateData? data;
  final bool isLoading;
  final bool isClaiming;
  final String? error;

  ReferralState({
    this.data,
    this.isLoading = false,
    this.isClaiming = false,
    this.error,
  });

  ReferralState copyWith({
    RebateData? data,
    bool? isLoading,
    bool? isClaiming,
    String? error,
  }) {
    return ReferralState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isClaiming: isClaiming ?? this.isClaiming,
      error: error ?? this.error,
    );
  }
}

/// 推广返利 Notifier
@riverpod
class ReferralNotifier extends _$ReferralNotifier {
  @override
  ReferralState build() {
    // 初始获取数据
    Future.microtask(() => fetchReferralData());
    return ReferralState();
  }

  /// 获取返利数据
  Future<void> fetchReferralData() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);

    final response = await FinanceService.getReferralRebateData();
    if (response.isSuccess && response.data != null) {
      state = state.copyWith(data: response.data, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: response.msg);
    }
  }

  /// 领取返利
  Future<bool> claimRebate() async {
    if (state.isClaiming || state.data == null) return false;
    if (state.data!.dailingqu <= 0) {
      ToastUtils.showInfo('没有可领取的返利');
      return false;
    }

    state = state.copyWith(isClaiming: true);
    final response = await FinanceService.claimReferralRebate();
    
    if (response.isSuccess) {
      ToastUtils.showSuccess(response.msg ?? '领取成功');
      // 领取成功后刷新数据
      await fetchReferralData();
      state = state.copyWith(isClaiming: false);
      return true;
    } else {
      ToastUtils.showError(response.msg ?? '领取失败');
      state = state.copyWith(isClaiming: false);
      return false;
    }
  }
}
