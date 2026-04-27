import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/providers/wallet/recharge_provider.dart';
import 'package:my_flutter_app/providers/user/user_provider.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/widgets/common/web_safe_image.dart';
import 'package:my_flutter_app/widgets/common/state_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class RechargeScreen extends ConsumerStatefulWidget {
  const RechargeScreen({super.key});

  @override
  ConsumerState<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends ConsumerState<RechargeScreen> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    final initialAmount = ref.read(rechargeProvider).inputAmount;
    final initialText = initialAmount != null && initialAmount > 0
        ? (initialAmount == initialAmount.truncateToDouble()
            ? initialAmount.toInt().toString()
            : initialAmount.toString())
        : '';
    _amountController = TextEditingController(text: initialText);

    Future.microtask(() {
      ref.read(rechargeProvider.notifier).fetchCategories();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RechargeState>(rechargeProvider, (previous, next) {
      final currentAmount = double.tryParse(_amountController.text) ?? 0.0;
      final nextAmount = next.inputAmount ?? 0.0;
      
      if (currentAmount != nextAmount) {
        if (nextAmount == 0) {
          _amountController.clear();
        } else {
          final newText = nextAmount == nextAmount.truncateToDouble()
              ? nextAmount.toInt().toString()
              : nextAmount.toString();
          _amountController.text = newText;
          _amountController.selection = TextSelection.fromPosition(
            TextPosition(offset: newText.length),
          );
        }
      }
    });

    final state = ref.watch(rechargeProvider);
    final userState = ref.watch(userProvider);
    final user = userState.user;
    final bool needsRealName = user != null && (user.realName == null || user.realName!.isEmpty);

    return Scaffold(
      appBar: AppBar(
        title: const Text('钱包充值'),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoadingCategories && state.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state.categories.isEmpty) {
            return ErrorStateWidget(
              message: state.errorMsg ?? '暂无充值方式',
              onRetry: () => ref.read(rechargeProvider.notifier).fetchCategories(),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (needsRealName)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.getCardColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.getDividerColor(context)),
                          // Removed BoxShadow for web optimization
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppTheme.error,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                '!',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '为了您的资金安全，请先完成实名认证',
                                style: TextStyle(fontSize: 12, color: AppTheme.getTextPrimary(context), fontWeight: FontWeight.w600),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.push('/personal-center-profile-realname');
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: AppTheme.error,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('去认证', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    _buildSectionTitle(context, '选择充值方式'),
                    const SizedBox(height: 12),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: _buildCategoryGrid(context, state),
              ),
              if (state.selectedCategory != null) ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20).copyWith(bottom: 12),
                  sliver: SliverToBoxAdapter(child: _buildSectionTitle(context, '选择充值通道')),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: _buildChannelList(context, state),
                ),
              ],
              if (state.selectedChannel != null) ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20).copyWith(bottom: 12),
                  sliver: SliverToBoxAdapter(child: _buildSectionTitle(context, '充值金额')),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: _buildAmountInput(context, state),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16).copyWith(top: 32),
                  sliver: SliverToBoxAdapter(child: _buildSubmitButton(context, state)),
                ),
              ],
            ],
          );
        }
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context, RechargeState state) {
    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: state.categories.length,
      itemBuilder: (context, index) {
        final category = state.categories[index];
        final isSelected = state.selectedCategory?.id == category.id;
        
        return GestureDetector(
          onTap: () => ref.read(rechargeProvider.notifier).selectCategory(category),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor.withAlpha(20) : Theme.of(context).cardColor,
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : AppTheme.getDividerColor(context),
                width: isSelected ? 1.5 : 1.0,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (category.icon != null && category.icon!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: WebSafeImage(
                              imageUrl: category.icon!,
                              width: 18,
                              height: 18,
                              errorWidget: const Icon(Icons.payment, size: 18),
                            ),
                          ),
                        Flexible(
                          child: Text(
                            category.name ?? '',
                            style: TextStyle(
                              color: isSelected ? Theme.of(context).primaryColor : null,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (category.msg != null && category.msg!.isNotEmpty)
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        category.msg!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChannelList(BuildContext context, RechargeState state) {
    if (state.isLoadingChannels) {
      return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
    }

    if (state.channels.isEmpty) {
      return const SliverToBoxAdapter(child: Center(child: Text('暂无可用通道')));
    }

    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: state.channels.length,
      itemBuilder: (context, index) {
        final channel = state.channels[index];
        final isSelected = state.selectedChannel?.id == channel.id;
        
        return GestureDetector(
          onTap: () => ref.read(rechargeProvider.notifier).selectChannel(channel),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor.withAlpha(20) : Theme.of(context).cardColor,
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : AppTheme.getDividerColor(context),
                width: isSelected ? 1.5 : 1.0,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  channel.name ?? '',
                  style: TextStyle(
                    color: isSelected ? Theme.of(context).primaryColor : null,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (channel.giveMoney != null && channel.giveMoney! > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '赠送${channel.giveMoney}${channel.giveType == 2 ? '%' : '元'}',
                      style: const TextStyle(
                        color: AppTheme.warning,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountInput(BuildContext context, RechargeState state) {
    final channel = state.selectedChannel!;
    final quickAmounts = state.quickAmounts;
    final isFixedAmount = channel.amountType == 2;

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: AppTheme.getDividerColor(context)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Text(
                      '¥',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        readOnly: isFixedAmount,
                        decoration: InputDecoration(
                          hintText: isFixedAmount ? '请选择下方金额' : '请输入充值金额',
                          border: InputBorder.none,
                          isDense: true,
                          errorText: state.errorMsg,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            ref.read(rechargeProvider.notifier).setAmount(double.tryParse(value) ?? 0);
                          } else {
                            ref.read(rechargeProvider.notifier).setAmount(0);
                          }
                        },
                        controller: _amountController,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '单笔限额: ¥${channel.min} - ¥${channel.max}',
                    style: TextStyle(color: AppTheme.getTertiaryTextColor(context), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        if (quickAmounts.isNotEmpty)
          SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: quickAmounts.length,
            itemBuilder: (context, index) {
              final amount = quickAmounts[index];
              final isSelected = state.inputAmount == amount;
              
              return GestureDetector(
                onTap: () => ref.read(rechargeProvider.notifier).setAmount(amount),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor : AppTheme.getDividerColor(context),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '¥${amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, RechargeState state) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: state.isSubmitting 
            ? null 
            : () async {
                final response = await ref.read(rechargeProvider.notifier).submitRecharge();
                if (response != null) {
                  if (context.mounted) {
                    if (response.url != null && response.url!.isNotEmpty) {
                      final uri = Uri.parse(response.url!);
                      final canLaunch = await canLaunchUrl(uri);
                      if (context.mounted) {
                        if (canLaunch) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('无法打开支付链接')),
                          );
                        }
                      }
                    } else if (response.id != null || response.orderId != null) {
                      final orderId = response.id ?? response.orderId;
                      context.push('/wallet-recharge-detail?id=$orderId');
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('订单创建成功，但无法跳转')),
                        );
                    }
                  }
                } else if (state.errorMsg != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMsg!)),
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: state.isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text('立即充值', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
