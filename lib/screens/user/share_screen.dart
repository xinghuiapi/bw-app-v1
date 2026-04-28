import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_nav_bar.dart';
import '../../widgets/custom_card.dart';

class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '分享'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16.h),
            _buildRebateCard(context),
            _buildMemberOverviewCard(context),
            _buildShareInfoCard(context),
            _buildRulesCard(context),
            SizedBox(height: 32.h),
          ],
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

  Widget _buildRebateCard(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader('分享返利', subtitle: '(分享奖励)'),
          SizedBox(height: 24.h),
          Text(
            '可领取',
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
                    '¥',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '0.00',
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFACCCFF), // Light blue button
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: Text(
                  '领取',
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
            '总有效会员≥5人即可领取',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberOverviewCard(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader('会员总览'),
          SizedBox(height: 24.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '1',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '会员总数',
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
                      '0',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '有效会员',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '充值≥1元为有效',
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

  Widget _buildShareInfoCard(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader('分享信息'),
          SizedBox(height: 24.h),
          _buildInfoRow(
            context,
            label: '分享邀请码',
            value: '810',
            onCopy: () => _copyToClipboard(context, '810'),
          ),
          Divider(
            color: AppColors.border,
            height: 32.h,
          ),
          _buildInfoRow(
            context,
            label: '分享URL',
            value: 'https://m.xh-demo.co...',
            onCopy: () => _copyToClipboard(context, 'https://m.xh-demo.com/'),
          ),
          SizedBox(height: 32.h),
          Center(
            child: Text(
              '二维码',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Center(
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
              child: Icon(
                Icons.qr_code_2,
                size: 160.w,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Text(
              '点击二维码可预览',
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

  Widget _buildInfoRow(BuildContext context, {required String label, required String value, required VoidCallback onCopy}) {
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
              '复制',
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

  Widget _buildRulesCard(BuildContext context) {
    final rules = [
      '1. 本活动全体用户皆可参与；用户点击推荐链接分享给新用户注册并进行充值后即可获得对应推荐礼金，被推荐用户无需填写推荐码。',
      '2. 每推荐一个新用户注册并完成首充，推荐人即可获得一次推荐礼金；推荐礼金以被推荐用户首充金额为准。',
      '3. 本活动与【返水优惠】共享，不与其他任何优惠共享。',
      '4. 被推荐用户需满足：每一个手机号码、电子邮箱、IP地址、相同银行卡、同一台电脑仅可注册一个会员账号；如发现违规用户，我们将保留无限期审核并扣回红利及产生利润的权利。',
      '5. 通过分享链接或邀请码注册的用户，将计入会员总数；邀请会员完成充值≥1元后，将计入有效会员；总有效会员≥5人后，可领取分享奖励。',
    ];

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader('邀请规则说明'),
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
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('已复制到剪贴板'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }
}
