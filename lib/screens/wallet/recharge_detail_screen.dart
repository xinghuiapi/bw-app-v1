import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:my_flutter_app/providers/recharge_detail_provider.dart';
import 'package:my_flutter_app/models/finance_models.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/utils/toast_utils.dart';

class RechargeDetailScreen extends ConsumerWidget {
  const RechargeDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderIdStr = GoRouterState.of(context).uri.queryParameters['id'];
    final orderId = int.tryParse(orderIdStr ?? '') ?? 0;

    if (orderId == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('充值详情')),
        body: const Center(child: Text('无效的订单ID')),
      );
    }

    // Initialize fetching detail
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rechargeDetailProvider.notifier).fetchDetail(orderId);
    });

    return const _RechargeDetailContent();
  }
}

class _RechargeDetailContent extends ConsumerWidget {
  const _RechargeDetailContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rechargeDetailProvider);
    final detail = state.detail;

    return Scaffold(
      appBar: AppBar(
        title: const Text('充值详情'),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading && detail == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (detail == null) {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(state.errorMsg ?? '加载失败'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                       final orderIdStr = GoRouterState.of(context).uri.queryParameters['id'];
                       final orderId = int.tryParse(orderIdStr ?? '') ?? 0;
                       if(orderId != 0) ref.read(rechargeDetailProvider.notifier).fetchDetail(orderId);
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAmountInfo(context, detail),
                const SizedBox(height: 24),
                if (detail.bankCard != null && detail.bankCard!.isNotEmpty) ...[
                  _buildBankInfo(context, detail),
                  const SizedBox(height: 24),
                ],
                if (detail.qrcode != null && detail.qrcode!.isNotEmpty) ...[
                  _buildQRCode(context, detail),
                  const SizedBox(height: 24),
                ],
                _buildUploadSection(context, ref, state),
                const SizedBox(height: 32),
                _buildActionButtons(context, ref, state, detail),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmountInfo(BuildContext context, RechargeDetail detail) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getDividerColor(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '充值金额: ',
                style: TextStyle(color: AppTheme.error, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                '¥${detail.money.toStringAsFixed(4)}',
                style: TextStyle(
                  color: AppTheme.error,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Monospace',
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: detail.money.toStringAsFixed(4)));
                  ToastUtils.showSuccess('已复制金额');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '复制',
                    style: TextStyle(color: AppTheme.error, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          if (detail.usdtMoney != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '虚拟币数量: ',
                  style: TextStyle(color: AppTheme.error, fontSize: 14),
                ),
                Text(
                  '${detail.usdtMoney!.toStringAsFixed(4)}USDT',
                  style: TextStyle(
                    color: AppTheme.error,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.error.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              detail.msg ?? '请按此金额复制支付！转错金额会导致支付失败！',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.error,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfo(BuildContext context, RechargeDetail detail) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getDividerColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                '收款账户信息',
                style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(context, '收款银行', detail.bankName ?? '-'),
          _buildInfoRow(context, '收款人', detail.bankUser ?? '-'),
          _buildInfoRow(context, '银行卡号', detail.bankCard ?? '-'),
          _buildInfoRow(context, '开户网点', detail.bankAddr ?? '-'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: Icon(Icons.copy, size: 16, color: Theme.of(context).primaryColor),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ToastUtils.showSuccess('已复制到剪贴板');
            },
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCode(BuildContext context, RechargeDetail detail) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getDividerColor(context)),
      ),
      child: Column(
        children: [
          Text(
            '支付二维码',
            style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: detail.qrcode!,
              version: QrVersions.auto,
              size: 160,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '请在有效期内完成支付',
            style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(BuildContext context, WidgetRef ref, RechargeDetailState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getDividerColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '上传支付凭证',
            style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => ref.read(rechargeDetailProvider.notifier).pickImage(),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.getScaffoldBackgroundColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.getDividerColor(context)),
              ),
              child: state.localImageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(state.localImageBytes!, fit: BoxFit.contain),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, color: AppTheme.getTextSecondary(context), size: 32),
                        const SizedBox(height: 8),
                        Text('点击上传支付凭证截图', style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 12)),
                      ],
                    ),
            ),
          ),
          if (state.errorMsg != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                state.errorMsg!,
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, RechargeDetailState state, RechargeDetail detail) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: state.isUploading 
                ? null 
                : () async {
                    final success = await ref.read(rechargeDetailProvider.notifier).uploadReceipt(detail.id);
                    if (success) {
                      ToastUtils.showSuccess('凭证提交成功');
                      if (context.mounted) context.pop();
                    } else if (state.errorMsg != null) {
                      ToastUtils.showError(state.errorMsg!);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: state.isUploading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('提交凭证', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppTheme.getCardColor(context),
                title: Text('取消订单', style: TextStyle(color: AppTheme.getTextPrimary(context))),
                content: Text('确定要取消该充值订单吗？', style: TextStyle(color: AppTheme.getTextSecondary(context))),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('再想想')),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true), 
                    child: Text('确定取消', style: TextStyle(color: Theme.of(context).colorScheme.error))
                  ),
                ],
              ),
            );
            
            if (confirm == true) {
              final success = await ref.read(rechargeDetailProvider.notifier).cancelOrder(detail.id);
              if (success) {
                ToastUtils.showSuccess('订单已取消');
                if (context.mounted) context.pop();
              } else if (state.errorMsg != null) {
                ToastUtils.showError(state.errorMsg!);
              }
            }
          },
          child: Text('取消充值订单', style: TextStyle(color: AppTheme.getTextSecondary(context))),
        ),
      ],
    );
  }
}
