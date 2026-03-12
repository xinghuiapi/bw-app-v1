import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/models/finance_models.dart';
import 'package:my_flutter_app/services/finance_service.dart';
import 'package:my_flutter_app/providers/user_provider.dart';

class TransferState {
  final bool loading;
  final bool balanceLoading;
  final bool recoveryLoading;
  final List<DepositCategory> primaryCategories;
  final DepositCategory? selectedPrimary;
  final List<TransferCategory> subCategories;
  final Map<int, double> platformBalances;
  final String? error;

  TransferState({
    this.loading = false,
    this.balanceLoading = false,
    this.recoveryLoading = false,
    this.primaryCategories = const [],
    this.selectedPrimary,
    this.subCategories = const [],
    this.platformBalances = const {},
    this.error,
  });

  TransferState copyWith({
    bool? loading,
    bool? balanceLoading,
    bool? recoveryLoading,
    List<DepositCategory>? primaryCategories,
    DepositCategory? selectedPrimary,
    List<TransferCategory>? subCategories,
    Map<int, double>? platformBalances,
    String? error,
  }) {
    return TransferState(
      loading: loading ?? this.loading,
      balanceLoading: balanceLoading ?? this.balanceLoading,
      recoveryLoading: recoveryLoading ?? this.recoveryLoading,
      primaryCategories: primaryCategories ?? this.primaryCategories,
      selectedPrimary: selectedPrimary ?? this.selectedPrimary,
      subCategories: subCategories ?? this.subCategories,
      platformBalances: platformBalances ?? this.platformBalances,
      error: error ?? this.error,
    );
  }
}

class TransferNotifier extends Notifier<TransferState> {
  @override
  TransferState build() {
    return TransferState();
  }

  /// 初始化转账页面数据
  Future<void> init() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final response = await FinanceService.getPrimaryCategories();
      if (response.code == 200) {
        final raw = response.data ?? [];
        final primaries = raw.where((item) => item.name != '推荐').toList();
        
        state = state.copyWith(
          primaryCategories: primaries,
          loading: false,
        );

        if (primaries.isNotEmpty) {
          await selectPrimaryCategory(primaries.first);
        }
      } else {
        state = state.copyWith(loading: false, error: response.msg);
      }
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  /// 选择一级分类
  Future<void> selectPrimaryCategory(DepositCategory primary) async {
    state = state.copyWith(selectedPrimary: primary, balanceLoading: true);
    try {
      // 获取二级分类 (平台列表)
      final subResponse = await FinanceService.getTransferCategories(primary.code ?? '');
      if (subResponse.code == 200) {
        state = state.copyWith(subCategories: subResponse.data ?? []);
        
        // 获取所有平台的余额
        await refreshPlatformBalances(primary.code ?? '');
      } else {
        state = state.copyWith(balanceLoading: false, error: subResponse.msg);
      }
    } catch (e) {
      state = state.copyWith(balanceLoading: false, error: e.toString());
    } finally {
      state = state.copyWith(balanceLoading: false);
    }
  }

  /// 刷新所有平台余额
  Future<void> refreshPlatformBalances(String primaryCode) async {
    state = state.copyWith(balanceLoading: true);
    try {
      final balancesResponse = await FinanceService.getGameBalance(primaryCode);
      if (balancesResponse.code == 200) {
        final Map<int, double> balancesMap = {};
        for (var item in (balancesResponse.data ?? [])) {
          balancesMap[item.id] = item.balance;
        }
        state = state.copyWith(platformBalances: balancesMap);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(balanceLoading: false);
    }
  }

  /// 一键回收
  Future<String?> recoveryAll() async {
    state = state.copyWith(recoveryLoading: true, error: null);
    try {
      final response = await FinanceService.allTrans();
      if (response.code == 200) {
        // 回收成功后刷新总余额和当前选中的平台余额
        await ref.read(userProvider.notifier).fetchUserInfo();
        if (state.selectedPrimary != null) {
          await refreshPlatformBalances(state.selectedPrimary!.code ?? '');
        }
        return null;
      } else {
        state = state.copyWith(error: response.msg);
        return response.msg;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return e.toString();
    } finally {
      state = state.copyWith(recoveryLoading: false);
    }
  }

  /// 转入游戏平台
  Future<String?> depositToGame(int platformId, double amount) async {
    return _doTransfer(platformId, amount, true);
  }

  /// 从游戏平台转出
  Future<String?> withdrawFromGame(int platformId, double amount) async {
    return _doTransfer(platformId, amount, false);
  }

  /// 转账操作
  Future<String?> _doTransfer(int platformId, double amount, bool toPlatform) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final response = toPlatform 
        ? await FinanceService.depositToGame(platformId, amount)
        : await FinanceService.withdrawFromGame(platformId, amount);

      if (response.code == 200) {
        // 转账成功后刷新余额
        await ref.read(userProvider.notifier).fetchUserInfo();
        if (state.selectedPrimary != null) {
          await refreshPlatformBalances(state.selectedPrimary!.code ?? '');
        }
        return null;
      } else {
        state = state.copyWith(error: response.msg);
        return response.msg;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return e.toString();
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  /// 设置转账模式
  Future<String?> setTransferMode(int mode) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final response = await FinanceService.transferMode(mode);
      if (response.code == 200) {
        await ref.read(userProvider.notifier).fetchUserInfo();
        return null;
      } else {
        state = state.copyWith(error: response.msg);
        return response.msg;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return e.toString();
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final transferProvider = NotifierProvider.autoDispose<TransferNotifier, TransferState>(TransferNotifier.new);
