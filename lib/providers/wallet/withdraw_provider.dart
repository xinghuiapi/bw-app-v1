import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/models/wallet/finance_models.dart';
import 'package:my_flutter_app/services/wallet/finance_service.dart';
import 'package:my_flutter_app/providers/user/user_provider.dart';

class WithdrawState {
  final bool loading;
  final bool submitting;
  final bool balanceLoading;
  final bool allTransLoading;
  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? selectedMethod;
  final bool methodsExpanded;
  final String? error;

  List<PaymentMethod> get displayedMethods {
    if (methodsExpanded || paymentMethods.length <= 2) {
      return paymentMethods;
    }
    return paymentMethods.take(2).toList();
  }

  WithdrawState({
    this.loading = false,
    this.submitting = false,
    this.balanceLoading = false,
    this.allTransLoading = false,
    this.paymentMethods = const [],
    this.selectedMethod,
    this.methodsExpanded = false,
    this.error,
  });

  WithdrawState copyWith({
    bool? loading,
    bool? submitting,
    bool? balanceLoading,
    bool? allTransLoading,
    List<PaymentMethod>? paymentMethods,
    PaymentMethod? selectedMethod,
    bool? methodsExpanded,
    String? error,
  }) {
    return WithdrawState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      balanceLoading: balanceLoading ?? this.balanceLoading,
      allTransLoading: allTransLoading ?? this.allTransLoading,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      methodsExpanded: methodsExpanded ?? this.methodsExpanded,
      error: error ?? this.error,
    );
  }
}

class WithdrawNotifier extends Notifier<WithdrawState> {
  @override
  WithdrawState build() {
    return WithdrawState();
  }

  // 获取收款方式列表
  Future<void> fetchPaymentMethods() async {
    state = state.copyWith(loading: true);

    try {
      final response = await FinanceService.getPaymentMethods();
      if (response.code == 200 && response.data != null) {
        final methods = response.data!;
        PaymentMethod? selected = state.selectedMethod;
        if (methods.isNotEmpty && selected == null) {
          selected = methods.first;
        }
        state = state.copyWith(
          paymentMethods: methods,
          selectedMethod: selected,
          loading: false,
        );
      } else {
        state = state.copyWith(paymentMethods: [], loading: false);
      }
    } catch (e) {
      state = state.copyWith(paymentMethods: [], loading: false);
    }
  }

  // 选择收款方式
  void selectMethod(PaymentMethod method) {
    state = state.copyWith(selectedMethod: method);
  }

  // 切换收款方式展开状态
  void toggleMethodsExpanded() {
    state = state.copyWith(methodsExpanded: !state.methodsExpanded);
  }

  // 刷新余额
  Future<void> refreshBalance() async {
    state = state.copyWith(balanceLoading: true);
    try {
      await ref.read(userProvider.notifier).fetchUserInfo();
    } finally {
      state = state.copyWith(balanceLoading: false);
    }
  }

  // 一键回收
  Future<String?> recycleAll() async {
    state = state.copyWith(allTransLoading: true, error: null);
    try {
      final response = await FinanceService.allTrans();
      if (response.code == 200) {
        await refreshBalance();
        return null;
      } else {
        state = state.copyWith(error: response.msg);
        return response.msg;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return e.toString();
    } finally {
      state = state.copyWith(allTransLoading: false);
    }
  }

  // 提交提现
  Future<String?> submitWithdraw({
    required double amount,
    required String payPassword,
  }) async {
    if (state.selectedMethod == null) {
      state = state.copyWith(error: '请选择收款方式');
      return '请选择收款方式';
    }

    state = state.copyWith(submitting: true, error: null);

    try {
      final request = WithdrawRequest(
        id: state.selectedMethod!.id,
        money: amount,
        payPassword: payPassword,
      );
      final response = await FinanceService.submitWithdraw(request);

      if (response.code == 200) {
        state = state.copyWith(submitting: false);
        return null;
      } else {
        state = state.copyWith(submitting: false, error: response.msg);
        return response.msg;
      }
    } catch (e) {
      state = state.copyWith(submitting: false, error: e.toString());
      return e.toString();
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final withdrawProvider =
    NotifierProvider.autoDispose<WithdrawNotifier, WithdrawState>(
      WithdrawNotifier.new,
    );
