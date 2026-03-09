import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/models/finance_models.dart';
import 'package:my_flutter_app/services/finance_service.dart';

class RechargeState {
  final bool isLoadingCategories;
  final bool isLoadingChannels;
  final bool isSubmitting;
  final List<DepositCategory> categories;
  final List<DepositChannel> channels;
  final DepositCategory? selectedCategory;
  final DepositChannel? selectedChannel;
  final double? inputAmount;
  final String? errorMsg;

  RechargeState({
    this.isLoadingCategories = false,
    this.isLoadingChannels = false,
    this.isSubmitting = false,
    this.categories = const [],
    this.channels = const [],
    this.selectedCategory,
    this.selectedChannel,
    this.inputAmount,
    this.errorMsg,
  });

  RechargeState copyWith({
    bool? isLoadingCategories,
    bool? isLoadingChannels,
    bool? isSubmitting,
    List<DepositCategory>? categories,
    List<DepositChannel>? channels,
    DepositCategory? selectedCategory,
    DepositChannel? selectedChannel,
    double? inputAmount,
    String? errorMsg,
  }) {
    return RechargeState(
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      isLoadingChannels: isLoadingChannels ?? this.isLoadingChannels,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      categories: categories ?? this.categories,
      channels: channels ?? this.channels,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedChannel: selectedChannel ?? this.selectedChannel,
      inputAmount: inputAmount ?? this.inputAmount,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }

  // 快捷金额列表（从选中的通道中获取）
  List<double> get quickAmounts {
    if (selectedChannel?.amount == null) return [];
    
    return selectedChannel!.amount!.map((e) {
      if (e is num) return e.toDouble();
      if (e is String) return double.tryParse(e) ?? 0.0;
      return 0.0;
    }).where((e) => e > 0).toList();
  }
}

class RechargeNotifier extends Notifier<RechargeState> {
  @override
  RechargeState build() {
    return RechargeState();
  }

  // 获取充值分类
  Future<void> fetchCategories() async {
    state = state.copyWith(isLoadingCategories: true, errorMsg: null);

    try {
      final response = await FinanceService.getDepositCategories();
      if (response.isSuccess) {
        final categories = response.data ?? [];
        state = state.copyWith(categories: categories);
        
        // 默认选中第一个分类
        if (categories.isNotEmpty) {
          // 优先选中包含“推荐”或“热门”的分类
          final recommended = categories.firstWhere(
            (c) => (c.name?.contains('推荐') ?? false) || (c.name?.contains('热门') ?? false),
            orElse: () => categories.first,
          );
          await selectCategory(recommended);
        }
      } else {
        state = state.copyWith(errorMsg: response.msg);
      }
    } catch (e) {
      state = state.copyWith(errorMsg: e.toString());
    } finally {
      state = state.copyWith(isLoadingCategories: false);
    }
  }

  // 选择分类并加载通道
  Future<void> selectCategory(DepositCategory category) async {
    if (state.selectedCategory?.id == category.id) return;
    
    state = state.copyWith(
      selectedCategory: category, 
      isLoadingChannels: true,
      channels: [],
      selectedChannel: null,
      errorMsg: null,
    );

    try {
      final response = await FinanceService.getDepositChannels(category.id);
      if (response.isSuccess) {
        final channels = response.data ?? [];
        state = state.copyWith(channels: channels);
        
        // 默认选中第一个通道
        if (channels.isNotEmpty) {
          selectChannel(channels.first);
        }
      } else {
        state = state.copyWith(errorMsg: response.msg);
      }
    } catch (e) {
      state = state.copyWith(errorMsg: e.toString());
    } finally {
      state = state.copyWith(isLoadingChannels: false);
    }
  }

  // 选择通道
  void selectChannel(DepositChannel channel) {
    state = state.copyWith(selectedChannel: channel, errorMsg: null);
  }

  // 设置输入金额
  void setAmount(double amount) {
    state = state.copyWith(inputAmount: amount, errorMsg: null);
  }

  // 提交充值申请
  Future<DepositOrderResponse?> submitRecharge() async {
    if (state.selectedChannel == null) {
      state = state.copyWith(errorMsg: '请选择充值通道');
      return null;
    }

    final amount = state.inputAmount ?? 0.0;
    final min = state.selectedChannel!.min;
    final max = state.selectedChannel!.max;

    if (amount < min || (max > 0 && amount > max)) {
      state = state.copyWith(errorMsg: '充值金额范围: $min - $max');
      return null;
    }

    state = state.copyWith(isSubmitting: true, errorMsg: null);

    try {
      final request = DepositOrderRequest(
        id: state.selectedChannel!.id,
        money: amount,
      );
      final response = await FinanceService.submitRecharge(request);

      if (response.isSuccess && response.data != null) {
        return response.data; // 返回订单详情
      } else {
        state = state.copyWith(errorMsg: response.msg);
        return null;
      }
    } catch (e) {
      state = state.copyWith(errorMsg: e.toString());
      return null;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  void clearError() {
    state = state.copyWith(errorMsg: null);
  }
}

final rechargeProvider = NotifierProvider.autoDispose<RechargeNotifier, RechargeState>(RechargeNotifier.new);
