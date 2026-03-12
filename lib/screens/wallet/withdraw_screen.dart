import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/providers/user_provider.dart';
import 'package:my_flutter_app/providers/withdraw_provider.dart';
import 'package:my_flutter_app/utils/toast_utils.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  final _amountController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // 初始化数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(withdrawProvider.notifier).fetchPaymentMethods();
      ref.read(userProvider.notifier).fetchUserInfo();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  double _parseWater(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final withdrawState = ref.watch(withdrawProvider);

    // 计算流水进度
    final sumWater = _parseWater(userState.user?.sumWater);
    final okWater = _parseWater(userState.user?.okWater);
    final isWaterReached = sumWater <= 0 || okWater >= sumWater;
    final progress = sumWater <= 0 ? 1.0 : (okWater / sumWater).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('钱包提现'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.pushNamed(
                'personal-center-transaction-records',
                queryParameters: {'index': '1'},
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(withdrawProvider.notifier).refreshBalance();
          await ref.read(withdrawProvider.notifier).fetchPaymentMethods();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 余额卡片
              _buildBalanceCard(context, userState, withdrawState),
              const SizedBox(height: 16),

              if (!isWaterReached)
                // 流水未达标提示
                _buildWaterProgressCard(context, sumWater, okWater, progress)
              else
                // 提现表单
                _buildWithdrawForm(context, userState, withdrawState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, UserState userState, WithdrawState withdrawState) {
    final theme = Theme.of(context);
    final balance = userState.user?.balance?.toString() ?? '0.00';
    final symbol = userState.user?.symbol ?? 'CNY';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '主账户余额',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (withdrawState.balanceLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    InkWell(
                      onTap: () => ref.read(withdrawProvider.notifier).refreshBalance(),
                      child: Icon(Icons.refresh, size: 18, color: theme.hintColor),
                    ),
                ],
              ),
              OutlinedButton(
                onPressed: withdrawState.allTransLoading
                    ? null
                    : () async {
                        final error = await ref.read(withdrawProvider.notifier).recycleAll();
                        if (error == null) {
                          ToastUtils.showSuccess('归户成功');
                        }
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                  side: BorderSide(color: theme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: withdrawState.allTransLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('一键归户'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                balance,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                symbol,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterProgressCard(BuildContext context, double sum, double ok, double progress) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.primaryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.bar_chart,
              size: 40,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '还需要完成流水 ¥${(sum - ok).toStringAsFixed(2)} 才能提现',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            color: theme.primaryColor,
            minHeight: 12,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 12),
          Text(
            '当前进度: ¥${ok.toStringAsFixed(2)} / ¥${sum.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawForm(BuildContext context, UserState userState, WithdrawState withdrawState) {
    final theme = Theme.of(context);
    final hasPayPassword = userState.user?.hasPayPassword ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 提现金额
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withAlpha(26)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '提现金额',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      final balance = userState.user?.balance?.toString() ?? '0';
                      _amountController.text = balance;
                    },
                    child: Text(
                      '全部提现',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    userState.user?.symbol ?? '¥',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: '请输入提现金额',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '单笔最低 ¥1.00',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                  ),
                  // 如果有手续费逻辑可以在这里显示
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 收款方式
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withAlpha(26)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择收款方式',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 16),
              if (withdrawState.loading)
                const Center(child: CircularProgressIndicator())
              else if (withdrawState.paymentMethods.isEmpty)
                _buildEmptyPaymentMethod(context)
              else
                _buildPaymentMethodList(context, withdrawState),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 支付密码
        if (!hasPayPassword)
          _buildNoPasswordNotice(context)
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withAlpha(26)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '支付密码',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: '请输入6位支付密码',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: theme.hintColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 32),

        // 提交按钮
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: withdrawState.submitting || !hasPayPassword
                ? null
                : () => _handleSubmit(context, ref.read(withdrawProvider.notifier)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: withdrawState.submitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    '立即提现',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEmptyPaymentMethod(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            '暂无收款方式',
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.push('/personal-center-card-packages'),
            icon: const Icon(Icons.add),
            label: const Text('添加收款方式'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodList(BuildContext context, WithdrawState state) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        ...state.displayedMethods.map((method) {
          final isSelected = state.selectedMethod?.id == method.id;
          return InkWell(
            onTap: () => ref.read(withdrawProvider.notifier).selectMethod(method),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
              color: isSelected ? theme.primaryColor.withAlpha(13) : theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? theme.primaryColor : Colors.transparent,
              ),
            ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.credit_card, color: Colors.blue), // 暂时用图标代替图片
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.displayTitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          method.displayCard,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: theme.primaryColor),
                ],
              ),
            ),
          );
        }),
        if (state.paymentMethods.length > 3)
          TextButton.icon(
            onPressed: () => ref.read(withdrawProvider.notifier).toggleMethodsExpanded(),
            icon: Icon(
              state.methodsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 16,
            ),
            label: Text(state.methodsExpanded ? '收起' : '展开更多'),
          ),
      ],
    );
  }

  Widget _buildNoPasswordNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withAlpha(77)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '未设置支付密码',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '为了资金安全，提现前请先设置支付密码',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/personal-center-profile-paypassword'),
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context, WithdrawNotifier notifier) async {
    final amountText = _amountController.text;
    final password = _passwordController.text;
    
    if (amountText.isEmpty) {
      ToastUtils.showWarning('请输入提现金额');
      return;
    }
    
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ToastUtils.showWarning('请输入有效的金额');
      return;
    }
    
    if (password.length != 6) {
      ToastUtils.showWarning('请输入6位支付密码');
      return;
    }
    
    final error = await notifier.submitWithdraw(amount: amount, payPassword: password);
    if (error == null) {
      ToastUtils.showSuccess('提现申请已提交');
      _amountController.clear();
      _passwordController.clear();
    } else {
      ToastUtils.showError(error);
    }
  }
}
