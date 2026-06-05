import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/user/user_models.dart';
import '../../providers/user/user_provider.dart';
import '../../router/route_paths.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_empty.dart';
import '../../widgets/common/app_error.dart';
import '../../widgets/common/app_loading.dart';
import '../../widgets/common/localized_text.dart';
import '../../widgets/custom_nav_bar.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<UserProvider>()
          .loadTeamMembers(refresh: true)
          .catchError((_) {});
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final page = provider.teamMembers;
    final records = page.records;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: CustomNavBar(
        title: _teamText(context, 'title'),
        leftHitTargetWidth: 72.w,
        onClickLeft: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RoutePaths.income);
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<UserProvider>().loadTeamMembers(refresh: true),
        child: provider.isTeamLoading && records.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 220.h),
                  AppLoading(message: 'common.loading'.tr()),
                ],
              )
            : provider.teamError != null && records.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 160.h),
                      AppError(
                        message: provider.teamError,
                        onRetry: () => context
                            .read<UserProvider>()
                            .loadTeamMembers(refresh: true),
                      ),
                    ],
                  )
                : records.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 160.h),
                          AppEmpty(title: _teamText(context, 'empty')),
                        ],
                      )
                    : ListView(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 24.h),
                        children: [
                          _TeamTable(records: records),
                          if (provider.isTeamLoadingMore)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          else if (!page.hasMore)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: Text(
                                'common.noMore'.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                        ],
                      ),
      ),
    );
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.extentAfter > 160.h) return;
    context.read<UserProvider>().loadMoreTeamMembers().catchError((_) {});
  }
}

class _TeamTable extends StatelessWidget {
  const _TeamTable({required this.records});

  final List<TeamMember> records;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.04),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _HeaderText(text: _teamText(context, 'colName')),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: 120.w,
                  child: _HeaderText(
                    text: _teamText(context, 'colBet'),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < records.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            _TeamRow(member: records[i]),
          ],
        ],
      ),
    );
  }
}

String _teamText(BuildContext context, String key) {
  final localeKey = 'team.$key';
  final value = localeKey.tr();
  if (value != localeKey) return value;
  final language = context.locale.languageCode.toLowerCase();
  final country = context.locale.countryCode?.toUpperCase();
  final fallbacks = _teamFallbacks[key] ?? const <String, String>{};
  if (language == 'my') return fallbacks['MY'] ?? localeKey;
  if (language == 'en') return fallbacks['EN'] ?? localeKey;
  if (language == 'zh' && country == 'TW') return fallbacks['TW'] ?? localeKey;
  return fallbacks['CN'] ?? localeKey;
}

const _teamFallbacks = <String, Map<String, String>>{
  'title': {
    'CN': '我的团队',
    'TW': '我的團隊',
    'EN': 'My Team',
    'MY': 'ကျွန်ုပ်၏ အဖွဲ့',
  },
  'empty': {
    'CN': '暂无团队成员',
    'TW': '暫無團隊成員',
    'EN': 'No team members',
    'MY': 'အဖွဲ့ဝင်မရှိပါ',
  },
  'colName': {
    'CN': '名称',
    'TW': '名稱',
    'EN': 'Name',
    'MY': 'အမည်',
  },
  'colBet': {
    'CN': '个人流水',
    'TW': '個人流水',
    'EN': 'Personal Turnover',
    'MY': 'ကိုယ်ပိုင် လောင်းကြေးလည်ပတ်ငွေ',
  },
};

class _HeaderText extends StatelessWidget {
  const _HeaderText({required this.text, this.textAlign = TextAlign.left});

  final String text;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: isBurmeseLocale(context) ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: localizedFontSize(context, 14, myScale: 0.86),
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.member});

  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    final username = member.username.trim().isEmpty ? '-' : member.username;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: localizedFontSize(context, 14, myScale: 0.9),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          SizedBox(
            width: 120.w,
            child: Text(
              _numberText(member.betAmount),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: localizedFontSize(context, 14, myScale: 0.9),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _numberText(double value) {
    final rounded = value == value.truncateToDouble();
    if (rounded) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }
}
