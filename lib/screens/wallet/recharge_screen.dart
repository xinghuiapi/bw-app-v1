import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/providers/recharge_provider.dart';
import 'package:my_flutter_app/providers/user_provider.dart';
import 'package:my_flutter_app/widgets/common/web_safe_image.dart';
import 'package:url_launcher/url_launcher.dart';

class RechargeScreen extends ConsumerStatefulWidget {
  const RechargeScreen({super.key});

  @override
  ConsumerState<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends ConsumerState<RechargeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(rechargeProvider.notifier).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(state.errorMsg ?? '暂无充值方式'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(rechargeProvider.notifier).fetchCategories(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (needsRealName)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '!',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            '为了您的资金安全，请先完成实名认证',
                            style: TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push('/personal-center-profile-realname');
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
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
                _buildCategoryGrid(context, state),
                
                if (state.selectedCategory != null) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, '选择充值通道'),
                  const SizedBox(height: 12),
                  _buildChannelList(context, state),
                ],

                if (state.selectedChannel != null) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, '充值金额'),
                  const SizedBox(height: 12),
                  _buildAmountInput(context, state),
                  const SizedBox(height: 24),
                  _buildSubmitButton(context, state),
                ],
              ],
            ),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context, RechargeState state) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
        
        return InkWell(
          onTap: () => ref.read(rechargeProvider.notifier).selectCategory(category),
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor.withAlpha(20) : Theme.of(context).cardColor,
                  border: Border.all(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withAlpha(26),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
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
                  top: 0,
                  right: 0,
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
        );
      },
    );
  }

  Widget _buildChannelList(BuildContext context, RechargeState state) {
    if (state.isLoadingChannels) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.channels.isEmpty) {
      return const Center(child: Text('暂无可用通道'));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
        
        return InkWell(
          onTap: () => ref.read(rechargeProvider.notifier).selectChannel(channel),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor.withAlpha(20) : Theme.of(context).cardColor,
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withAlpha(26),
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
                        color: Colors.orange,
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

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Colors.grey.withAlpha(51)),
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
                  controller: TextEditingController(
                    text: state.inputAmount != null && state.inputAmount! > 0 
                        ? state.inputAmount.toString() 
                        : ''
                  )..selection = TextSelection.fromPosition(
                      TextPosition(offset: state.inputAmount != null && state.inputAmount! > 0 
                          ? state.inputAmount.toString().length 
                          : 0)
                    ),
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
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        if (quickAmounts.isNotEmpty) ...[
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
              
              return InkWell(
                onTap: () => ref.read(rechargeProvider.notifier).setAmount(amount),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withAlpha(51),
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
