import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/providers/transfer_provider.dart';
import 'package:my_flutter_app/providers/user_provider.dart';
import 'package:my_flutter_app/widgets/common/web_safe_image.dart';
import 'package:my_flutter_app/utils/constants.dart';
import 'package:my_flutter_app/utils/toast_utils.dart';
import 'package:my_flutter_app/models/finance_models.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(transferProvider.notifier).init();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transferProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('额度转账'),
        centerTitle: true,
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(transferProvider.notifier).init();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 主账户余额卡片
                    _buildMainBalanceCard(user, state),
                    const SizedBox(height: 16),
                    
                    // 分类 Tabs
                    _buildPrimaryTabs(state),
                    const SizedBox(height: 16),
                    
                    // 平台网格
                    _buildPlatformGrid(state),
                    const SizedBox(height: 80), // 为底部留白
                  ],
                ),
              ),
            ),
      bottomSheet: _buildModeSelector(user, state),
    );
  }

  Widget _buildMainBalanceCard(UserState user, TransferState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '主账户余额',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => ref.read(userProvider.notifier).fetchUserInfo(),
                    child: Icon(
                      Icons.refresh,
                      size: 16,
                      color: user.isLoading ? Colors.blue : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    user.user?.balance?.toString() ?? '0.00',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '元',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: state.recoveryLoading
                ? null
                : () async {
                    final error = await ref.read(transferProvider.notifier).recoveryAll();
                    if (error != null) {
                      ToastUtils.showError(error);
                    } else {
                      ToastUtils.showSuccess('一键归户成功');
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: state.recoveryLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                  )
                : const Text('一键归户'),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryTabs(TransferState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: state.primaryCategories.map((cat) {
          final isSelected = state.selectedPrimary?.id == cat.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat.name ?? ''),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(transferProvider.notifier).selectPrimaryCategory(cat);
                }
              },
              backgroundColor: Colors.grey.withAlpha(26),
              selectedColor: Colors.red,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
              ),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlatformGrid(TransferState state) {
    if (state.balanceLoading && state.subCategories.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(40.0),
        child: CircularProgressIndicator(),
      ));
    }

    if (state.subCategories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text('暂无游戏平台', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: state.subCategories.length,
      itemBuilder: (context, index) {
        final platform = state.subCategories[index];
        final balance = state.platformBalances[platform.id] ?? 0.00;
        
        return InkWell(
          onTap: () => _showTransferDialog(platform),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withAlpha(26)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (platform.pcLogo != null)
                  WebSafeImage(
                    imageUrl: platform.pcLogo!.startsWith('http') 
                        ? platform.pcLogo! 
                        : '${AppConstants.resourceBaseUrl}${platform.pcLogo}',
                    width: 40,
                    height: 40,
                    errorWidget: _buildDefaultLogo(platform),
                  )
                else
                  _buildDefaultLogo(platform),
                const SizedBox(height: 8),
                Text(
                  platform.name ?? '',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${balance.toStringAsFixed(2)}元',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultLogo(TransferCategory platform) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        platform.name?.characters.first ?? '?',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showTransferDialog(TransferCategory platform) {
    _amountController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransferDialog(
        platform: platform,
        controller: _amountController,
        onTransfer: (isDeposit, amount) async {
          final notifier = ref.read(transferProvider.notifier);
          final error = isDeposit 
            ? await notifier.depositToGame(platform.id, amount)
            : await notifier.withdrawFromGame(platform.id, amount);
          
          if (error != null) {
            ToastUtils.showError(error);
          } else {
            ToastUtils.showSuccess(isDeposit ? '转入成功' : '转出成功');
            if (context.mounted) Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildModeSelector(UserState user, TransferState state) {
    final mode = user.user?.transfer ?? 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey.withAlpha(26))),
      ),
      child: Row(
        children: [
          const Text('转账模式:', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                _buildModeRadio(2, '自动转账', mode),
                const SizedBox(width: 16),
                _buildModeRadio(1, '手动转账', mode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeRadio(int value, String label, int currentMode) {
    final isSelected = currentMode == value;
    return GestureDetector(
      onTap: () async {
        if (!isSelected) {
          final error = await ref.read(transferProvider.notifier).setTransferMode(value);
          if (error != null) {
            ToastUtils.showError(error);
          } else {
            ToastUtils.showSuccess('模式切换成功');
          }
        }
      },
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 18,
            color: isSelected ? Colors.red : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? Colors.red : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferDialog extends ConsumerWidget {
  final TransferCategory platform;
  final TextEditingController controller;
  final Function(bool isDeposit, double amount) onTransfer;

  const _TransferDialog({
    required this.platform,
    required this.controller,
    required this.onTransfer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final balanceStr = userState.user?.balance?.toString() ?? '0.00';
    final balance = double.tryParse(balanceStr) ?? 0.00;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E), // 深色背景
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${platform.name} 钱包',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(8),
      ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: '最低1元，只能为整数',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // 转入全部余额，向下取整
                    controller.text = balance.floor().toString();
                  },
                  child: const Text('全部转入', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleTransfer(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('转出'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleTransfer(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('转入'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleTransfer(bool isDeposit) {
    final amount = double.tryParse(controller.text);
    if (amount == null || amount <= 0) {
      ToastUtils.showError('请输入正确的金额');
      return;
    }
    if (amount != amount.truncateToDouble()) {
      ToastUtils.showError('转账金额只能为整数');
      return;
    }
    onTransfer(isDeposit, amount);
  }
}
