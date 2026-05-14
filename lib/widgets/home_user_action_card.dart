import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

class HomeUserActionCard extends StatelessWidget {
  const HomeUserActionCard({
    super.key,
    required this.isLoggedIn,
    required this.username,
    required this.vipText,
    required this.symbol,
    required this.balance,
    required this.showBalance,
    required this.welcomeText,
    required this.loginText,
    required this.registerText,
    required this.depositText,
    required this.withdrawText,
    required this.serviceText,
    required this.onToggleBalance,
    required this.onRefresh,
    required this.onLogin,
    required this.onRegister,
    required this.onDeposit,
    required this.onWithdraw,
    required this.onService,
  });

  final bool isLoggedIn;
  final String username;
  final String vipText;
  final String symbol;
  final String balance;
  final bool showBalance;
  final String welcomeText;
  final String loginText;
  final String registerText;
  final String depositText;
  final String withdrawText;
  final String serviceText;
  final VoidCallback onToggleBalance;
  final VoidCallback onRefresh;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;
  final VoidCallback onService;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: isLoggedIn ? _AccountInfo(card: this) : _GuestActions(card: this),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: const Color(0xFFEEEEEE),
            margin: EdgeInsets.symmetric(horizontal: 6.w),
          ),
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Expanded(
                  child: _ActionItem(
                    icon: Icons.monetization_on_outlined,
                    text: depositText,
                    highlight: true,
                    onTap: onDeposit,
                  ),
                ),
                Expanded(
                  child: _ActionItem(
                    icon: Icons.account_balance_wallet_outlined,
                    text: withdrawText,
                    highlight: false,
                    onTap: onWithdraw,
                  ),
                ),
                Expanded(
                  child: _ActionItem(
                    icon: Icons.headset_mic_outlined,
                    text: serviceText,
                    highlight: false,
                    onTap: onService,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountInfo extends StatelessWidget {
  const _AccountInfo({required this.card});

  final HomeUserActionCard card;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 50.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  card.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Container(
                height: 16.h,
                constraints: BoxConstraints(maxWidth: 48.w),
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFBCC3D4),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  card.vipText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9.sp, height: 1, color: Colors.white),
                ),
              ),
              SizedBox(width: 4.w),
              GestureDetector(
                onTap: card.onToggleBalance,
                child: Icon(
                  card.showBalance ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 15.sp,
                  color: const Color(0xFF999999),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                card.symbol,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
              Expanded(
                child: Text(
                  card.showBalance ? card.balance : '***',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    height: 1,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: card.onRefresh,
                child: Icon(Icons.refresh, size: 15.sp, color: const Color(0xFF999999)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuestActions extends StatelessWidget {
  const _GuestActions({required this.card});

  final HomeUserActionCard card;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          card.welcomeText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
            height: 1,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Flexible(
              child: _CompactAuthButton(text: card.loginText, filled: true, onTap: card.onLogin),
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: _CompactAuthButton(text: card.registerText, filled: false, onTap: card.onRegister),
            ),
          ],
        ),
      ],
    );
  }
}

class _CompactAuthButton extends StatelessWidget {
  const _CompactAuthButton({required this.text, required this.filled, required this.onTap});

  final String text;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 22.h,
        constraints: BoxConstraints(minWidth: 52.w),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: filled ? null : Border.all(color: AppColors.primary),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.sp,
            height: 1,
            color: filled ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.icon, required this.text, required this.highlight, required this.onTap});

  final IconData icon;
  final String text;
  final bool highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 18.sp),
          ),
          SizedBox(height: 6.h),
          SizedBox(
            width: double.infinity,
            height: 16.h,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                text,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  height: 1.1,
                  color:
                      highlight ? AppColors.primary : const Color(0xFF666666),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
