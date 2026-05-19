import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/user/user_models.dart';
import '../../providers/user/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_nav_bar.dart';

class RedemptionCodeScreen extends StatefulWidget {
  const RedemptionCodeScreen({super.key});

  @override
  State<RedemptionCodeScreen> createState() => _RedemptionCodeScreenState();
}

class _RedemptionCodeScreenState extends State<RedemptionCodeScreen> {
  final _controller = TextEditingController();
  bool _hasCodeText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onCodeChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserProvider>().loadRedemptionRecords().catchError((_) {});
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onCodeChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final records =
        provider.redemptionRecords?.data ?? const <RedemptionRecord>[];
    final loading = provider.isRedemptionLoading;
    final submitting = provider.isRedemptionSubmitting;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      appBar: CustomNavBar(title: _redemptionText('title', '兑换码')),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<UserProvider>().loadRedemptionRecords(refresh: true),
        child: ListView(
          padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 28.h),
          children: [
            _buildHero(),
            SizedBox(height: 14.h),
            _buildRedeemCard(submitting),
            SizedBox(height: 18.h),
            _buildSectionHeader(loading),
            if (loading && records.isEmpty)
              _buildLoadingState()
            else if (records.isEmpty)
              _buildEmptyState()
            else
              ...records.map(_buildRecordCard),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.24),
            blurRadius: 24.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20.w,
            top: -28.h,
            child: Container(
              width: 118.w,
              height: 118.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            right: 20.w,
            bottom: -30.h,
            child: Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 54.w,
                height: 54.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(Icons.card_giftcard_outlined,
                    size: 30.sp, color: Colors.white),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _redemptionText('title', '兑换码'),
                      style: TextStyle(
                        fontSize: 22.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _redemptionText('placeholder', '请输入兑换码，支持粘贴'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white.withValues(alpha: 0.86),
                        height: 1.35,
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

  Widget _buildRedeemCard(bool submitting) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.confirmation_number_outlined,
                  size: 18.sp, color: const Color(0xFF2563EB)),
              SizedBox(width: 8.w),
              Text(
                _redemptionText('code', '请输入兑换码'),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 58.h,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  if (!_hasCodeText)
                    Positioned.fill(
                      right: 94.w,
                      child: IgnorePointer(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 14.w),
                            child: Text(
                              _redemptionText('code', '请输入兑换码'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xFF94A3B8),
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w400,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    right: 94.w,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: _controller,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          height: 1,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 14.w),
                          isCollapsed: true,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8.w,
                    top: 8.h,
                    bottom: 8.h,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999.r),
                      onTap: _pasteCode,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.content_paste_rounded,
                                size: 15.sp, color: const Color(0xFF2563EB)),
                            SizedBox(width: 4.w),
                            Text(
                              _redemptionText('paste', '粘贴'),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFF2563EB),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: submitting
                    ? const LinearGradient(
                        colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                borderRadius: BorderRadius.circular(999.r),
                boxShadow: submitting
                    ? null
                    : [
                        BoxShadow(
                          color:
                              const Color(0xFF2563EB).withValues(alpha: 0.26),
                          blurRadius: 18.r,
                          offset: Offset(0, 8.h),
                        ),
                      ],
              ),
              child: ElevatedButton.icon(
                onPressed: submitting ? null : _submit,
                icon: Icon(Icons.redeem_outlined, size: 19.sp),
                label: Text(
                  submitting
                      ? 'common.submitting'.tr()
                      : _redemptionText('submit', '确认兑换'),
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(bool loading) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 10.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              _redemptionText('records', '兑换记录'),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          if (loading)
            SizedBox(
              width: 16.w,
              height: 16.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 120.h,
      alignment: Alignment.center,
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.only(top: 6.h),
      padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 18.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Icon(Icons.inbox_outlined,
                size: 30.sp, color: const Color(0xFF2563EB)),
          ),
          SizedBox(height: 12.h),
          Text(
            _redemptionText('empty', '暂无兑换记录'),
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(RedemptionRecord record) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.confirmation_number_outlined,
                    color: const Color(0xFF2563EB), size: 21.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.code ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      record.time ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  record.balance ?? '—',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF7C3AED),
                  ),
                ),
              ),
            ],
          ),
          if ((record.desc ?? '').trim().isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Text(
                record.desc ?? '',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pasteCode() async {
    try {
      final value = await Clipboard.getData(Clipboard.kTextPlain);
      final text = value?.text?.trim() ?? '';
      if (text.isEmpty) return;
      setState(() => _controller.text = text);
    } catch (_) {}
  }

  void _onCodeChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText == _hasCodeText) return;
    setState(() => _hasCodeText = hasText);
  }

  Future<void> _submit() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      _showSnack(_redemptionText('needCode', '请输入兑换码'));
      return;
    }
    final provider = context.read<UserProvider>();
    try {
      await provider.redeemCode(code);
      if (!mounted) return;
      _controller.clear();
      _showSnack(_redemptionText('redeemSuccess', '兑换成功'));
    } catch (_) {
      if (!mounted) return;
      _showSnack(
          provider.redemptionError ?? _redemptionText('redeemFailed', '兑换失败'));
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _redemptionText(String key, String fallback) {
    final candidates = <String>[
      if (key == 'title') 'page.redemptionCode',
      'user.redemption.$key',
      'user.redemption.toast.$key',
    ];
    for (final candidate in candidates) {
      final value = candidate.tr();
      if (value != candidate) return value;
    }
    return fallback;
  }
}
