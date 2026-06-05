import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../api/api_exception.dart';
import '../../models/user/user_models.dart';
import '../../providers/user/user_provider.dart';
import '../../router/route_paths.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_loading.dart';
import '../../widgets/common/localized_text.dart';
import '../../widgets/custom_nav_bar.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<UserProvider>()
          .loadDayRevenue(refresh: true)
          .catchError((_) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final revenue = provider.dayRevenue ?? const DayRevenueSummary();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: CustomNavBar(
        title: _incomeText(context, 'title'),
        leftHitTargetWidth: 72.w,
        onClickLeft: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RoutePaths.profile);
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<UserProvider>().loadDayRevenue(refresh: true),
        child: ListView(
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 24.h),
          children: [
            _IncomePanel(
              title: _incomeText(context, 'rebateTitle'),
              hint: _incomeText(context, 'rebateHint'),
              amount: revenue.totalNoRebate,
              isClaiming: provider.isIncomeRebateClaiming,
              isBusy: provider.isDayRevenueLoading ||
                  provider.isIncomeRebateClaiming ||
                  provider.isIncomeCommissionClaiming,
              onHintTap: () => _pushIfAvailable(RoutePaths.vip),
              onClaim: () => _claimRebate(provider, revenue),
              rows: [
                _MetricRowData(
                  label: _incomeText(context, 'rebateRecord'),
                  onTap: () => context.push('/game-manage?tab=rebate'),
                ),
              ],
              settlementTitle: _incomeText(context, 'rebateSettlement'),
              settlements: [
                _SettlementData(
                  label: _incomeText(context, 'dayTotalRebate'),
                  value: revenue.totalRebate,
                ),
                _SettlementData(
                  label: _incomeText(context, 'dayClaimedRebate'),
                  value: revenue.claimedRebate,
                ),
                _SettlementData(
                  label: _incomeText(context, 'dayUnclaimedRebate'),
                  value: revenue.unclaimedRebate,
                  emphasis: true,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _IncomePanel(
              title: _incomeText(context, 'commissionTitle'),
              hint: _incomeText(context, 'commissionHint'),
              amount: revenue.totalNoCommission,
              isClaiming: provider.isIncomeCommissionClaiming,
              isBusy: provider.isDayRevenueLoading ||
                  provider.isIncomeRebateClaiming ||
                  provider.isIncomeCommissionClaiming,
              onHintTap: () => _pushIfAvailable(RoutePaths.fyLevel),
              onClaim: () => _claimCommission(provider, revenue),
              rows: [
                _MetricRowData(
                  label: _incomeText(context, 'commissionRecord'),
                  onTap: () => context.push('/game-manage?tab=fy'),
                ),
                _MetricRowData(
                  label: _incomeText(context, 'myTeam'),
                  onTap: () => context.push(RoutePaths.team),
                ),
              ],
              settlementTitle: _incomeText(context, 'commissionSettlement'),
              settlements: [
                _SettlementData(
                  label: _incomeText(context, 'dayTotalCommission'),
                  value: revenue.totalCommission,
                ),
                _SettlementData(
                  label: _incomeText(context, 'dayClaimedCommission'),
                  value: revenue.claimedCommission,
                ),
                _SettlementData(
                  label: _incomeText(context, 'dayUnclaimedCommission'),
                  value: revenue.unclaimedCommission,
                  emphasis: true,
                ),
              ],
            ),
            if (provider.isDayRevenueLoading && provider.dayRevenue == null)
              Padding(
                padding: EdgeInsets.only(top: 14.h),
                child: AppLoading(message: 'common.loading'.tr()),
              ),
          ],
        ),
      ),
    );
  }

  void _pushIfAvailable(String path) {
    try {
      context.push(path);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.comingSoon'.tr())),
      );
    }
  }

  Future<void> _claimRebate(
    UserProvider provider,
    DayRevenueSummary revenue,
  ) async {
    if (revenue.totalNoRebate <= 0) {
      _showMessage(_incomeText(context, 'noClaimable'));
      return;
    }
    try {
      await provider.claimIncomeRebate();
      if (!mounted) return;
      _showMessage(_incomeText(context, 'claimSuccess'));
    } on ApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    }
  }

  Future<void> _claimCommission(
    UserProvider provider,
    DayRevenueSummary revenue,
  ) async {
    if (revenue.totalNoCommission <= 0) {
      _showMessage(_incomeText(context, 'noClaimable'));
      return;
    }
    try {
      await provider.claimIncomeCommission();
      if (!mounted) return;
      _showMessage(_incomeText(context, 'claimSuccess'));
    } on ApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _IncomePanel extends StatelessWidget {
  const _IncomePanel({
    required this.title,
    required this.hint,
    required this.amount,
    required this.isClaiming,
    required this.isBusy,
    required this.onHintTap,
    required this.onClaim,
    required this.rows,
    required this.settlementTitle,
    required this.settlements,
  });

  final String title;
  final String hint;
  final double amount;
  final bool isClaiming;
  final bool isBusy;
  final VoidCallback onHintTap;
  final VoidCallback onClaim;
  final List<_MetricRowData> rows;
  final String settlementTitle;
  final List<_SettlementData> settlements;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: isBurmeseLocale(context) ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: localizedFontSize(context, 16, myScale: 0.86),
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onHintTap,
                child: Text(
                  hint,
                  maxLines: isBurmeseLocale(context) ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: localizedFontSize(context, 12, myScale: 0.86),
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '¥',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  _moneyValue(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              _ClaimButton(
                text: _incomeText(context, 'claim'),
                isLoading: isClaiming,
                onPressed: isBusy || amount <= 0 ? null : onClaim,
              ),
            ],
          ),
          SizedBox(height: 6.h),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: Colors.black.withValues(alpha: 0.06),
              ),
            _MetricRow(data: rows[i]),
          ],
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  settlementTitle,
                  maxLines: isBurmeseLocale(context) ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: localizedFontSize(context, 15, myScale: 0.86),
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                _incomeText(context, 'todayData'),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: localizedFontSize(context, 12, myScale: 0.86),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < settlements.length; i++) ...[
                Expanded(child: _SettlementItem(data: settlements[i])),
                if (i != settlements.length - 1) SizedBox(width: 10.w),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _moneyValue(double value) {
    return value.toStringAsFixed(2);
  }
}

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({
    required this.text,
    required this.isLoading,
    required this.onPressed,
  });

  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return Opacity(
      opacity: enabled || isLoading ? 1 : 0.5,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onPressed : null,
        child: Container(
          width: 92.w,
          height: 34.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.22),
            ),
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: isLoading
                ? SizedBox(
                    key: const ValueKey('loading'),
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : LocalizedOneLineText(
                    key: const ValueKey('text'),
                    text: text,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                    ),
                    myScale: 0.82,
                    minSp: 9,
                  ),
          ),
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.data});

  final _MetricRowData data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: data.onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                data.label,
                maxLines: isBurmeseLocale(context) ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: localizedFontSize(context, 14, myScale: 0.86),
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              _incomeText(context, 'view'),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: localizedFontSize(context, 13, myScale: 0.86),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.18),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.chevron_right,
                size: 16.sp,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettlementItem extends StatelessWidget {
  const _SettlementItem({required this.data});

  final _SettlementData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 86.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label,
            maxLines: isBurmeseLocale(context) ? 3 : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF667085),
              fontSize: localizedFontSize(context, 12, myScale: 0.82),
              height: 1.4,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            data.value.toStringAsFixed(2),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color:
                  data.emphasis ? AppColors.primary : const Color(0xFF111111),
              fontSize: localizedFontSize(context, 16, myScale: 0.82),
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRowData {
  const _MetricRowData({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;
}

class _SettlementData {
  const _SettlementData({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  final String label;
  final double value;
  final bool emphasis;
}

String _incomeText(BuildContext context, String key) {
  final language = context.locale.languageCode.toLowerCase();
  final country = context.locale.countryCode?.toUpperCase();
  final localeMap = switch (language) {
    'my' => _incomeFallbacksMy,
    'en' => _incomeFallbacksEn,
    'zh' when country == 'TW' => _incomeFallbacksTw,
    _ => _incomeFallbacksCn,
  };
  return localeMap[key] ?? _incomeFallbacksCn[key] ?? 'income.$key';
}

const _incomeFallbacksCn = <String, String>{
  'title': '我的收入',
  'rebateTitle': '可领返水',
  'rebateHint': '查看投注返水比例',
  'commissionTitle': '可领返佣',
  'commissionHint': '投注返佣奖励比例',
  'claim': '领取',
  'claimSuccess': '领取成功',
  'noClaimable': '暂无可领取',
  'rebateRecord': '返水记录',
  'commissionRecord': '返佣记录',
  'myTeam': '我的团队',
  'view': '查看',
  'rebateSettlement': '返水结算',
  'commissionSettlement': '佣金结算',
  'todayData': '今日数据',
  'dayTotalRebate': '今日总反水',
  'dayClaimedRebate': '今日已领取',
  'dayUnclaimedRebate': '今日未领取',
  'dayTotalCommission': '今日总返佣',
  'dayClaimedCommission': '今日领取佣金',
  'dayUnclaimedCommission': '今日未领取佣金',
};

const _incomeFallbacksTw = <String, String>{
  'title': '我的收入',
  'rebateTitle': '可領返水',
  'rebateHint': '查看投注返水比例',
  'commissionTitle': '可領返佣',
  'commissionHint': '投注返佣獎勵比例',
  'claim': '領取',
  'claimSuccess': '領取成功',
  'noClaimable': '暫無可領取',
  'rebateRecord': '返水記錄',
  'commissionRecord': '返佣記錄',
  'myTeam': '我的團隊',
  'view': '查看',
  'rebateSettlement': '返水結算',
  'commissionSettlement': '佣金結算',
  'todayData': '今日數據',
  'dayTotalRebate': '今日總返水',
  'dayClaimedRebate': '今日已領取',
  'dayUnclaimedRebate': '今日未領取',
  'dayTotalCommission': '今日總返佣',
  'dayClaimedCommission': '今日領取佣金',
  'dayUnclaimedCommission': '今日未領取佣金',
};

const _incomeFallbacksEn = <String, String>{
  'title': 'My Income',
  'rebateTitle': 'Claimable Rebate',
  'rebateHint': 'View betting rebate rate',
  'commissionTitle': 'Claimable Commission',
  'commissionHint': 'Betting commission reward rate',
  'claim': 'Claim',
  'claimSuccess': 'Claimed successfully',
  'noClaimable': 'No claimable amount',
  'rebateRecord': 'Rebate Records',
  'commissionRecord': 'Commission Records',
  'myTeam': 'My Team',
  'view': 'View',
  'rebateSettlement': 'Rebate Settlement',
  'commissionSettlement': 'Commission Settlement',
  'todayData': "Today's Data",
  'dayTotalRebate': "Today's Total Rebate",
  'dayClaimedRebate': "Today's Claimed Rebate",
  'dayUnclaimedRebate': "Today's Unclaimed Rebate",
  'dayTotalCommission': "Today's Total Commission",
  'dayClaimedCommission': "Today's Claimed Commission",
  'dayUnclaimedCommission': "Today's Unclaimed Commission",
};

const _incomeFallbacksMy = <String, String>{
  'title': 'ကျွန်ုပ်၏ ဝင်ငွေ',
  'rebateTitle': 'ရယူနိုင်သော ပြန်အမ်းငွေ',
  'rebateHint': 'ဘတ် ပြန်အမ်းနှုန်း ကြည့်ရန်',
  'commissionTitle': 'ရယူနိုင်သော ကော်မရှင်',
  'commissionHint': 'ဘတ် ကော်မရှင်ဆု နှုန်း',
  'claim': 'ရယူရန်',
  'claimSuccess': 'ရယူပြီးပါပြီ',
  'noClaimable': 'ရယူနိုင်သော ပမာဏမရှိပါ',
  'rebateRecord': 'ပြန်အမ်းမှတ်တမ်း',
  'commissionRecord': 'ကော်မရှင်မှတ်တမ်း',
  'myTeam': 'ကျွန်ုပ်၏အဖွဲ့',
  'view': 'ကြည့်ရန်',
  'rebateSettlement': 'ပြန်အမ်းစာရင်းချုပ်',
  'commissionSettlement': 'ကော်မရှင်စာရင်းချုပ်',
  'todayData': 'ယနေ့ဒေတာ',
  'dayTotalRebate': 'ယနေ့ စုစုပေါင်း ပြန်အမ်း',
  'dayClaimedRebate': 'ယနေ့ ရယူပြီး ပြန်အမ်း',
  'dayUnclaimedRebate': 'ယနေ့ မယူရသေးသော ပြန်အမ်း',
  'dayTotalCommission': 'ယနေ့ စုစုပေါင်း ကော်မရှင်',
  'dayClaimedCommission': 'ယနေ့ ရယူပြီး ကော်မရှင်',
  'dayUnclaimedCommission': 'ယနေ့ မယူရသေးသော ကော်မရှင်',
};
