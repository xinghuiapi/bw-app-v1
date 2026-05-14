import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../providers/user/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_nav_bar.dart';
import '../../widgets/custom_card.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userProvider = context.read<UserProvider>();
      userProvider.loadProfile().catchError((_) {});
      userProvider.loadRebateInfo().catchError((_) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final rebate = userProvider.rebateInfo;
    final profile = userProvider.profile;
    final inviteCode = _inviteCode(profile);
    final shareUrl = _shareUrl(inviteCode);
    final currency = _textFallback(profile?.symbol, '¥');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(title: 'share.title'.tr()),
      body: RefreshIndicator(
        onRefresh: _refreshShareData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: userProvider.isRebateDisabled
              ? _buildDisabledState()
              : Column(
                  children: [
                    SizedBox(height: 16.h),
                    _buildRebateCard(context, userProvider, currency),
                    _buildMemberOverviewCard(context, userProvider),
                    _buildShareInfoCard(
                      context,
                      inviteCode: inviteCode,
                      shareUrl: shareUrl,
                    ),
                    if (userProvider.rebateInfoError != null && rebate == null)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          userProvider.rebateInfoError!,
                          style: TextStyle(
                            color: AppColors.danger,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    _buildRulesCard(context, userProvider),
                    SizedBox(height: 32.h),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _refreshShareData() async {
    final userProvider = context.read<UserProvider>();
    await Future.wait([
      userProvider.loadProfile(refresh: true).catchError((_) {}),
      userProvider.loadRebateInfo(refresh: true).catchError((_) {}),
    ]);
  }

  Widget _buildDisabledState() {
    return SizedBox(
      height: 0.72.sh,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 56.sp,
                color: AppColors.textSecondary.withValues(alpha: 0.65),
              ),
              SizedBox(height: 14.h),
              Text(
                'share.disabled'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(String title, {String? subtitle}) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: const Color(0xFF8AB6FF), // Light blue dot
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8AB6FF).withValues(alpha: 0.3),
                blurRadius: 4.r,
                spreadRadius: 1.r,
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(width: 8.w),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRebateCard(
    BuildContext context,
    UserProvider provider,
    String currency,
  ) {
    final rebate = provider.rebateInfo;
    final claimable = rebate?.claimableAmount ?? 0;
    final effectiveMembers = rebate?.effectiveMembers ?? 0;
    final minEffectiveMembers = rebate?.minEffectiveMembers ?? 1;
    final canClaim = effectiveMembers >= minEffectiveMembers &&
        claimable > 0 &&
        !provider.isRebateClaiming;
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader('share.rebateTitle'.tr(),
              subtitle: 'share.rebateSubtitle'.tr()),
          SizedBox(height: 24.h),
          Text(
            'share.claimable'.tr(),
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currency,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _money(claimable),
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: canClaim ? () => _claimRebate(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFACCCFF), // Light blue button
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: Text(
                  provider.isRebateClaiming
                      ? 'common.submitting'.tr()
                      : 'common.claim'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'share.claimRequirement'.tr().replaceAll(
                  '{n}',
                  minEffectiveMembers.toString(),
                ),
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberOverviewCard(BuildContext context, UserProvider provider) {
    final rebate = provider.rebateInfo;
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader('share.overview'.tr()),
          SizedBox(height: 24.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      (rebate?.totalMembers ?? 0).toString(),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'share.totalMembers'.tr(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 4.h),
                width: 1.w,
                height: 40.h,
                color: AppColors.border,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      (rebate?.effectiveMembers ?? 0).toString(),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'share.validMembers'.tr(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'share.validMemberRule'.tr().replaceAll(
                            '{amount}',
                            _compactNumber(rebate?.minRecharge ?? 1),
                          ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareInfoCard(
    BuildContext context, {
    required String inviteCode,
    required String shareUrl,
  }) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader('share.info'.tr()),
          SizedBox(height: 24.h),
          _buildInfoRow(
            context,
            label: 'share.inviteCode'.tr(),
            value: inviteCode,
            onCopy: () => _copyToClipboard(context, inviteCode),
          ),
          Divider(
            color: AppColors.border,
            height: 32.h,
          ),
          _buildInfoRow(
            context,
            label: 'share.shareUrl'.tr(),
            value: shareUrl,
            onCopy: () => _copyToClipboard(context, shareUrl),
          ),
          SizedBox(height: 32.h),
          Center(
            child: Text(
              'share.qrCode'.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Center(
            child: GestureDetector(
              onTap: shareUrl == '-'
                  ? null
                  : () => _previewQrCode(context, shareUrl),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.border,
                    width: 0.5,
                  ),
                ),
                child: _buildQrCode(shareUrl, size: 220.w),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Text(
              'share.qrPreviewHint'.tr(),
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context,
      {required String label,
      required String value,
      required VoidCallback onCopy}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        SizedBox(
          height: 28.h,
          child: OutlinedButton(
            onPressed: onCopy,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              'share.copy'.tr(),
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRulesCard(BuildContext context, UserProvider provider) {
    final rebate = provider.rebateInfo;
    final minRecharge = _compactNumber(rebate?.minRecharge ?? 1);
    final minEffectiveMembers = (rebate?.minEffectiveMembers ?? 1).toString();
    final rules = [
      'share.rule1'.tr(),
      'share.rule2'.tr(),
      'share.rule3'.tr(),
      'share.rule4'.tr(),
      'share.rule5'
          .tr()
          .replaceAll('{amount}', minRecharge)
          .replaceAll('{n}', minEffectiveMembers),
    ];

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader('share.rulesTitle'.tr()),
          SizedBox(height: 24.h),
          ...rules.map((rule) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Text(
                  rule,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) async {
    if (text == '-') return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('common.copied'.tr()),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  Widget _buildQrCode(String data, {required double size}) {
    if (data == '-') {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Icon(
            Icons.qr_code_2,
            size: size * 0.72,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: AppColors.textPrimary,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: AppColors.textPrimary,
      ),
    );
  }

  void _previewQrCode(BuildContext context, String data) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
        child: GestureDetector(
          onTap: () => Navigator.of(dialogContext).pop(),
          child: Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: _buildQrCode(data, size: 240.w),
          ),
        ),
      ),
    );
  }

  Future<void> _claimRebate(BuildContext context) async {
    final provider = context.read<UserProvider>();
    final rebate = provider.rebateInfo;
    if (rebate != null &&
        rebate.effectiveMembers < rebate.minEffectiveMembers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('share.claimRequirement'.tr().replaceAll(
                '{n}',
                rebate.minEffectiveMembers.toString(),
              )),
        ),
      );
      return;
    }
    if ((rebate?.claimableAmount ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('share.noReward'.tr())),
      );
      return;
    }
    try {
      await provider.claimRebateAmount();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('share.claimSuccess'.tr())),
      );
    } catch (_) {
      if (!context.mounted) return;
      final error = context.read<UserProvider>().rebateClaimError ??
          'common.loadFailed'.tr();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  String _money(num value) => value.toStringAsFixed(2);

  String _compactNumber(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toString();
  }

  String _inviteCode(profile) {
    if (profile == null) return '-';
    return profile.id.toString();
  }

  String _shareUrl(String inviteCode) {
    if (inviteCode == '-') return '-';
    final origin = Uri.base.origin;
    return '$origin/m1/register?invite=${Uri.encodeComponent(inviteCode)}';
  }

  String _textFallback(String? value, String fallback) {
    final text = value?.trim();
    return text == null || text.isEmpty ? fallback : text;
  }
}
