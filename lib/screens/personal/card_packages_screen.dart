import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/widgets/common/web_safe_image.dart';
import 'package:my_flutter_app/widgets/common/state_widgets.dart';
import 'package:my_flutter_app/utils/constants.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/utils/toast_utils.dart';
import 'package:my_flutter_app/services/finance_service.dart';
import 'package:my_flutter_app/models/finance_models.dart';

final paymentMethodsProvider = FutureProvider.autoDispose<List<PaymentMethod>>((
  ref,
) async {
  final response = await FinanceService.getPaymentMethods();
  if (response.code == 200) {
    return response.data ?? [];
  } else {
    throw Exception(response.msg ?? '获取收款方式失败');
  }
});

class CardPackagesScreen extends ConsumerWidget {
  const CardPackagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentMethodsAsync = ref.watch(paymentMethodsProvider);

    return Scaffold(
      backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        title: const Text('我的卡包'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.getTextPrimary(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/personal-center-card-packages-add'),
          ),
        ],
      ),
      body: paymentMethodsAsync.when(
        data: (methods) => _buildContent(context, ref, methods),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorStateWidget(
          message: err.toString(),
          onRetry: () => ref.refresh(paymentMethodsProvider),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<PaymentMethod> methods,
  ) {
    if (methods.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(paymentMethodsProvider.future),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: methods.length + 1,
        itemBuilder: (context, index) {
          if (index == methods.length) {
            return const SizedBox(height: 80); // Bottom padding
          }
          return _buildCardItem(context, ref, methods[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: AppTheme.getTextTertiary(context),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无收款方式',
            style: TextStyle(
              color: AppTheme.getTextSecondary(context),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '添加收款方式后可用于提现',
            style: TextStyle(
              color: AppTheme.getTextTertiary(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/personal-center-card-packages-add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('立即添加'),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(
    BuildContext context,
    WidgetRef ref,
    PaymentMethod method,
  ) {
    final title = method.displayTitle;
    final cardNo = method.displayCard;
    final isBank = method.type == 1;
    final isCrypto = method.type == 2;
    final isThirdParty = method.type == 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getCardColors(title, method.type),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        // Removed BoxShadow for web optimization
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildMethodIcon(method),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(method.status),
                      if (method.alias != null && method.alias!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            method.alias!,
                            style: TextStyle(
                              color: Colors.white.withAlpha(179),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white70),
                  onPressed: () => _confirmDelete(context, ref, method),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBank ? '银行卡号' : (isCrypto ? '钱包地址' : '账号'),
                        style: TextStyle(
                          color: Colors.white.withAlpha(179),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCardNumber(cardNo, method.type),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCopyButton(cardNo, '卡号'),
              ],
            ),
            if (method.name != null && method.name!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '持卡人',
                          style: TextStyle(
                            color: Colors.white.withAlpha(179),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          method.name!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            if (method.address != null &&
                method.address!.isNotEmpty &&
                isBank) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '开户行',
                          style: TextStyle(
                            color: Colors.white.withAlpha(179),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          method.address!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildCopyButton(method.address!, '地址'),
                ],
              ),
            ],
            if (method.qrcode != null && method.qrcode!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    '收款二维码',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showQRCode(context, method.qrcode!),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.qr_code,
                        size: 24,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int? status) {
    String text = '正常';
    Color color = Colors.green;

    if (status == 0) {
      text = '已禁用';
      color = AppTheme.error;
    } else if (status == 2) {
      text = '待审核';
      color = AppTheme.warning;
    } else if (status == 1) {
      text = '正常';
      color = AppTheme.success;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(128)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMethodIcon(PaymentMethod method) {
    if (method.img != null && method.img!.isNotEmpty) {
      String iconUrl = method.img!;
      if (!iconUrl.startsWith('http')) {
        iconUrl = '${AppConstants.resourceBaseUrl}$iconUrl';
      }
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: WebSafeImage(
          imageUrl: iconUrl,
          width: 32,
          height: 32,
          errorWidget: Icon(
            _getTypeIcon(method.type),
            size: 24,
            color: AppTheme.primary,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
      ),
      child: Icon(_getTypeIcon(method.type), size: 24, color: Colors.white),
    );
  }

  Widget _buildCopyButton(String text, String label) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
        ToastUtils.showSuccess('$label已复制');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(51),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.copy, size: 14, color: Colors.white),
            SizedBox(width: 4),
            Text('复制', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(int? type) {
    switch (type) {
      case 1:
        return Icons.account_balance;
      case 2:
        return Icons.currency_bitcoin;
      case 3:
        return Icons.account_balance_wallet;
      default:
        return Icons.credit_card;
    }
  }

  List<Color> _getCardColors(String bankName, int? type) {
    if (type == 2)
      return [const Color(0xFF26A17B), const Color(0xFF53AE94)]; // Crypto Green
    if (type == 3) {
      if (bankName.contains('支付宝'))
        return [const Color(0xFF1677FF), const Color(0xFF4096FF)];
      if (bankName.contains('微信'))
        return [const Color(0xFF07C160), const Color(0xFF06AD56)];
    }

    if (bankName.contains('建设'))
      return [const Color(0xFF003B8F), const Color(0xFF005BAC)];
    if (bankName.contains('工商'))
      return [const Color(0xFFC7000B), const Color(0xFFE50012)];
    if (bankName.contains('农业'))
      return [const Color(0xFF009174), const Color(0xFF00A982)];
    if (bankName.contains('中国银行'))
      return [const Color(0xFFB81C22), const Color(0xFFD32027)];

    return [
      const Color(0xFF4B5563),
      const Color(0xFF1F2937),
    ]; // Default dark grey
  }

  String _formatCardNumber(String number, int? type) {
    if (number.length < 8) return number;
    if (type == 2) {
      // Crypto address - show start and end
      return '${number.substring(0, 6)}...${number.substring(number.length - 6)}';
    }
    return '${number.substring(0, 4)} **** **** ${number.substring(number.length - 4)}';
  }

  void _showQRCode(BuildContext context, String qrcode) {
    String imageUrl = qrcode;
    if (!imageUrl.startsWith('http')) {
      imageUrl = '${AppConstants.resourceBaseUrl}$imageUrl';
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '收款二维码',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              WebSafeImage(
                imageUrl: imageUrl,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PaymentMethod method,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除收款方式'),
        content: Text(
          '确定要删除 ${method.displayTitle} (${method.displayCard}) 吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final response = await FinanceService.deletePaymentMethod(
                method.id,
              );
              if (response.code == 200) {
                ToastUtils.showSuccess('删除成功');
                ref.refresh(paymentMethodsProvider);
              } else {
                ToastUtils.showError(response.msg ?? '删除失败');
              }
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
