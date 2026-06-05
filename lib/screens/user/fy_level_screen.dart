import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/user/user_models.dart';
import '../../providers/user/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_empty.dart';
import '../../widgets/common/app_error.dart';
import '../../widgets/common/app_loading.dart';
import '../../widgets/common/localized_text.dart';
import '../../widgets/custom_nav_bar.dart';

class FyLevelScreen extends StatefulWidget {
  const FyLevelScreen({super.key});

  @override
  State<FyLevelScreen> createState() => _FyLevelScreenState();
}

class _FyLevelScreenState extends State<FyLevelScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = <_FyLevelTab>[
    _FyLevelTab('lottery_bl', 'tabLottery'),
    _FyLevelTab('games_bl', 'tabGames'),
    _FyLevelTab('poker_bl', 'tabPoker'),
    _FyLevelTab('live_bl', 'tabLive'),
    _FyLevelTab('sport_bl', 'tabSport'),
    _FyLevelTab('fishing_bl', 'tabFishing'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<UserProvider>()
          .loadFyLevels(refresh: true)
          .catchError((_) {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final levels = provider.fyLevelPage.levels;
    final currentVip = provider.profile?.displayVipLevel ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: CustomNavBar(
        title: _fyText(context, 'title'),
        leftHitTargetWidth: 72.w,
        onClickLeft: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/income');
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<UserProvider>().loadFyLevels(refresh: true),
        child: Column(
          children: [
            Container(
              color: const Color(0xFFF4F6F9),
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 0),
              child: _buildTabs(),
            ),
            Expanded(
              child: provider.isFyLevelLoading && levels.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 220.h),
                        AppLoading(message: 'common.loading'.tr()),
                      ],
                    )
                  : provider.fyLevelError != null && levels.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: 160.h),
                            AppError(
                              message: provider.fyLevelError,
                              onRetry: () => context
                                  .read<UserProvider>()
                                  .loadFyLevels(refresh: true),
                            ),
                          ],
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            for (final tab in _tabs)
                              _FyLevelTable(
                                levels: levels,
                                field: tab.field,
                                currentVip: currentVip,
                              ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800),
        unselectedLabelStyle: TextStyle(fontSize: 15.sp),
        tabs: [
          for (final tab in _tabs)
            Tab(text: _fyText(context, tab.labelKey), height: 42.h),
        ],
      ),
    );
  }
}

class _FyLevelTable extends StatelessWidget {
  const _FyLevelTable({
    required this.levels,
    required this.field,
    required this.currentVip,
  });

  final List<FyLevelItem> levels;
  final String field;
  final String currentVip;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 24.h),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border:
                Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              if (currentVip.isNotEmpty) _buildCurrentLine(context),
              _buildHead(context),
              if (levels.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 36.h),
                  child: AppEmpty(title: _fyText(context, 'empty')),
                )
              else
                for (var i = 0; i < levels.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                  _buildRow(context, levels[i]),
                ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentLine(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _fyText(context, 'currentVip'),
              maxLines: isBurmeseLocale(context) ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.62),
                fontSize: localizedFontSize(context, 13, myScale: 0.86),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            currentVip,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHead(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.02),
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _headText(context, _fyText(context, 'colVip'))),
          SizedBox(width: 12.w),
          Expanded(
            child: _headText(
                context, _fyText(context, 'colRate'), TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, FyLevelItem item) {
    final isCurrent = currentVip.isNotEmpty && item.vipName == currentVip;
    return Container(
      color: isCurrent ? AppColors.primary.withValues(alpha: 0.06) : null,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.vipName.isEmpty ? '-' : item.vipName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.72),
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              _percentText(item.valueFor(field)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headText(BuildContext context, String text,
      [TextAlign textAlign = TextAlign.left]) {
    return Text(
      text,
      maxLines: isBurmeseLocale(context) ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: TextStyle(
        color: Colors.black.withValues(alpha: 0.72),
        fontSize: localizedFontSize(context, 15, myScale: 0.86),
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _FyLevelTab {
  const _FyLevelTab(this.field, this.labelKey);

  final String field;
  final String labelKey;
}

String _fyText(BuildContext context, String key) {
  final language = context.locale.languageCode.toLowerCase();
  final country = context.locale.countryCode?.toUpperCase();
  final map = switch ((language, country)) {
    ('my', _) => _fyFallbacksMy,
    ('en', _) => _fyFallbacksEn,
    ('zh', 'TW') => _fyFallbacksTw,
    _ => _fyFallbacksCn,
  };
  return map[key] ?? _fyFallbacksCn[key] ?? key;
}

String _percentText(dynamic value) {
  final n = value is num ? value.toDouble() : double.tryParse('$value');
  final safe = n == null || !n.isFinite ? 0.0 : n;
  final fixed = safe.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  final out = fixed.contains('.') ? fixed : '$fixed.0';
  return '$out%';
}

const _fyFallbacksCn = <String, String>{
  'title': '返佣等级',
  'tabLottery': '彩票',
  'tabGames': '电子',
  'tabPoker': '棋牌',
  'tabLive': '真人',
  'tabSport': '体育',
  'tabFishing': '捕鱼',
  'currentVip': '当前等级',
  'colVip': '下级vip等级',
  'colRate': '您的返佣比例',
  'empty': '暂无数据',
};

const _fyFallbacksTw = <String, String>{
  'title': '返佣等級',
  'tabLottery': '彩票',
  'tabGames': '電子',
  'tabPoker': '棋牌',
  'tabLive': '真人',
  'tabSport': '體育',
  'tabFishing': '捕魚',
  'currentVip': '當前等級',
  'colVip': '下級 VIP 等級',
  'colRate': '您的返佣比例',
  'empty': '暫無數據',
};

const _fyFallbacksEn = <String, String>{
  'title': 'Commission Level',
  'tabLottery': 'Lottery',
  'tabGames': 'Slots',
  'tabPoker': 'Chess',
  'tabLive': 'Live',
  'tabSport': 'Sports',
  'tabFishing': 'Fishing',
  'currentVip': 'Current Level',
  'colVip': 'Subordinate VIP Level',
  'colRate': 'Your Commission Rate',
  'empty': 'No data',
};

const _fyFallbacksMy = <String, String>{
  'title': 'ကော်မရှင်အဆင့်',
  'tabLottery': 'ထီ',
  'tabGames': 'စလော့',
  'tabPoker': 'ကတ်ဂိမ်း',
  'tabLive': 'တိုက်ရိုက်',
  'tabSport': 'အားကစား',
  'tabFishing': 'ငါးဖမ်း',
  'currentVip': 'လက်ရှိအဆင့်',
  'colVip': 'အောက်အဖွဲ့ VIP အဆင့်',
  'colRate': 'သင့်ကော်မရှင်နှုန်း',
  'empty': 'ဒေတာမရှိပါ',
};
