import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/game/game_management_models.dart';
import '../../providers/game/game_management_provider.dart';
import '../../providers/localization/language_provider.dart';
import '../../router/route_paths.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_nav_bar.dart';

class GameManagementScreen extends StatefulWidget {
  const GameManagementScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<GameManagementScreen> createState() => _GameManagementScreenState();
}

class _GameManagementScreenState extends State<GameManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _rebateScrollController = ScrollController();
  final ScrollController _fyScrollController = ScrollController();
  final ScrollController _gameScrollController = ScrollController();

  String _selectedDateRange = 'today';
  DateTimeRange _range = _todayRange();
  final List<String> _dateRanges = [
    'today',
    'yesterday',
    'thisWeek',
    'thisMonth',
    'lastMonth'
  ];
  int _lastLoadedTabIndex = 0;
  String? _lastLanguageCode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
    _lastLoadedTabIndex = _tabController.index;
    _tabController.addListener(_handleTabChanged);
    _rebateScrollController.addListener(_handleRebateScroll);
    _fyScrollController.addListener(_handleFyScroll);
    _gameScrollController.addListener(_handleGameScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecords());
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _fyScrollController.removeListener(_handleFyScroll);
    _rebateScrollController.dispose();
    _fyScrollController.dispose();
    _gameScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = context.watch<LanguageProvider>().currentCode;
    if (_lastLanguageCode == null) {
      _lastLanguageCode = languageCode;
    } else if (_lastLanguageCode != languageCode) {
      _lastLanguageCode = languageCode;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadRecords();
      });
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(
        title: _gm('title'),
        leftHitTargetWidth: 72.w,
        onClickLeft: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RoutePaths.profile);
          }
        },
      ),
      body: Column(
        children: [
          _buildDateFilter(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRebateTab(),
                _buildFyTab(),
                _buildGameRecordTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return CustomCard(
      margin: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      borderRadius: 16.r,
      hasShadow: true,
      child: Row(
        children: [
          SizedBox(
            width: 92.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _gm('queryDate'),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  _rangeText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _dateRanges.map((range) {
                  final isSelected = _selectedDateRange == range;
                  return Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: GestureDetector(
                      onTap: () => _setDateRange(range),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 13.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _dateRangeLabel(range),
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
          labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 16.sp),
          tabs: [
            Tab(text: _gm('rebateRecords'), height: 42),
            Tab(text: _gm('fyRecords'), height: 42),
            Tab(text: _gm('gameRecords'), height: 42),
          ],
        ),
      ),
    );
  }

  Widget _buildRebateTab() {
    return Consumer<GameManagementProvider>(
      builder: (context, provider, child) {
        final page = provider.rebatePage;
        final records = page.records;
        final isEmpty = records.isEmpty;
        return Column(
          children: [
            _buildRebateSummary(page),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadRecords,
                child: provider.isRebateLoading && records.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : records.isEmpty
                        ? _buildEmptyList(_gm('emptyRebate'))
                        : ListView.builder(
                            controller: _rebateScrollController,
                            padding: EdgeInsets.only(bottom: 16.h),
                            itemCount: records.length + (isEmpty ? 0 : 1),
                            itemBuilder: (context, index) {
                              if (index == records.length) {
                                return _buildListFooter(
                                  provider.isRebateLoadingMore,
                                  provider.hasMoreRebate,
                                );
                              }
                              return _buildRebateItem(records[index]);
                            },
                          ),
              ),
            ),
            _buildRebateBottomBar(provider, page.notFsMoney),
          ],
        );
      },
    );
  }

  Widget _buildRebateSummary(RebateRecordPage page) {
    return CustomCard(
      margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      padding: EdgeInsets.symmetric(vertical: 17.h),
      borderRadius: 16.r,
      hasShadow: true,
      child: Row(
        children: [
          Expanded(
              child: _buildSummaryItem(
                  _gm('totalRebate'), _money(page.totalFsMoney))),
          _buildVerticalDivider(),
          Expanded(
              child:
                  _buildSummaryItem(_gm('claimed'), _money(page.yesFsMoney))),
          _buildVerticalDivider(),
          Expanded(
              child:
                  _buildSummaryItem(_gm('unclaimed'), _money(page.notFsMoney))),
        ],
      ),
    );
  }

  Widget _buildRebateItem(RebateRecord item) {
    return CustomCard(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
      padding: EdgeInsets.all(16.w),
      borderRadius: 16.r,
      hasShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTag(_typeLabel(item.code)),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _shortTime(item.createdAt),
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildTag(item.claimed ? _gm('claimed') : _gm('pendingClaim'),
                  color: item.claimed ? AppColors.success : AppColors.primary),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '${item.apiCodeTitle.isNotEmpty ? item.apiCodeTitle : item.apiCode}${item.ratio.isNotEmpty ? ' · ${item.ratio}%' : ''}',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                  child: _buildRecordItem(_gm('rebate'), _money(item.fsMoney),
                      alignCenter: true)),
              Expanded(
                  child: _buildRecordItem(_gm('valid'), _money(item.money),
                      alignCenter: true)),
              Expanded(
                  child: _buildRecordItem(_gm('profitLoss'), _money(0),
                      alignCenter: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRebateBottomBar(GameManagementProvider provider, double amount) {
    return _buildClaimBottomBar(
      amount: amount,
      loading: provider.isClaimingRebates,
      buttonText: _gm('claimRebate'),
      onPressed: _claimAllRebates,
    );
  }

  Widget _buildFyTab() {
    return Consumer<GameManagementProvider>(
      builder: (context, provider, child) {
        final page = provider.fyPage;
        final records = page.records;
        final isEmpty = records.isEmpty;
        return Column(
          children: [
            _buildFySummary(page),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadRecords,
                child: provider.isFyLoading && records.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : records.isEmpty
                        ? _buildEmptyList(_gm('emptyFy'))
                        : ListView.builder(
                            controller: _fyScrollController,
                            padding: EdgeInsets.only(bottom: 16.h),
                            itemCount: records.length + (isEmpty ? 0 : 1),
                            itemBuilder: (context, index) {
                              if (index == records.length) {
                                return _buildListFooter(
                                  provider.isFyLoadingMore,
                                  provider.hasMoreFy,
                                );
                              }
                              return _buildFyItem(records[index]);
                            },
                          ),
              ),
            ),
            _buildFyBottomBar(provider, page.unreceivedMoney),
          ],
        );
      },
    );
  }

  Widget _buildFySummary(FyRecordPage page) {
    return CustomCard(
      margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      padding: EdgeInsets.symmetric(vertical: 17.h),
      borderRadius: 16.r,
      hasShadow: true,
      child: Row(
        children: [
          Expanded(
              child:
                  _buildSummaryItem(_gm('totalFy'), _money(page.totalMoney))),
          _buildVerticalDivider(),
          Expanded(
              child: _buildSummaryItem(
                  _gm('claimed'), _money(page.receivedMoney))),
          _buildVerticalDivider(),
          Expanded(
              child: _buildSummaryItem(
                  _gm('unclaimed'), _money(page.unreceivedMoney))),
        ],
      ),
    );
  }

  Widget _buildFyItem(FyRecord item) {
    final title =
        item.apiCodeTitle.isNotEmpty ? item.apiCodeTitle : item.apiCode;
    return CustomCard(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
      padding: EdgeInsets.all(16.w),
      borderRadius: 16.r,
      hasShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTag(
                item.gameType.isNotEmpty
                    ? item.gameType
                    : _typeLabel(item.code),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _shortTime(item.createdAt),
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildTag(item.claimed ? _gm('claimed') : _gm('pendingClaim'),
                  color: item.claimed ? AppColors.success : AppColors.primary),
            ],
          ),
          SizedBox(height: 10.h),
          if (title.isNotEmpty || item.ratio.isNotEmpty)
            Text(
              '$title${item.ratio.isNotEmpty ? ' · ${item.ratio}%' : ''}',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (title.isNotEmpty || item.ratio.isNotEmpty) SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                  child: _buildRecordItem(
                      _gm('flowAmount'), _money(item.betAmount),
                      alignCenter: true)),
              Expanded(
                  child: _buildRecordItem(
                      _gm('fyRate'), _percentText(item.ratio),
                      alignCenter: true)),
              Expanded(
                  child: _buildRecordItem(_gm('fyAmount'), _money(item.money),
                      alignCenter: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFyBottomBar(GameManagementProvider provider, double amount) {
    return _buildClaimBottomBar(
      amount: amount,
      loading: provider.isClaimingFy,
      buttonText: _gm('claimFy'),
      onPressed: _claimAllFy,
    );
  }

  Widget _buildClaimBottomBar({
    required double amount,
    required bool loading,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    final canClaim = amount > 0 && !loading;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _gm('claimable'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _money(amount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            ElevatedButton(
              onPressed: canClaim ? onPressed : null,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 128.w),
                child: Text(
                  loading ? 'common.submitting'.tr() : buttonText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameRecordTab() {
    return Consumer<GameManagementProvider>(
      builder: (context, provider, child) {
        final page = provider.gamePage;
        final records = page.records;
        final isEmpty = records.isEmpty;
        return Column(
          children: [
            _buildGameRecordSummary(page),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadRecords,
                child: provider.isGameLoading && records.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : records.isEmpty
                        ? _buildEmptyList(_gm('emptyGame'))
                        : ListView.builder(
                            controller: _gameScrollController,
                            itemCount: records.length + (isEmpty ? 0 : 1),
                            itemBuilder: (context, index) {
                              if (index == records.length) {
                                return _buildListFooter(
                                  provider.isGameLoadingMore,
                                  provider.hasMoreGame,
                                );
                              }
                              return _buildGameRecordItem(records[index]);
                            },
                          ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGameRecordSummary(GameRecordPage page) {
    return CustomCard(
      margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      padding: EdgeInsets.symmetric(vertical: 17.h),
      borderRadius: 16.r,
      hasShadow: true,
      child: Row(
        children: [
          Expanded(child: _buildSummaryItem(_gm('betCount'), '${page.total}')),
          _buildVerticalDivider(),
          Expanded(
              child: _buildSummaryItem(
                  _gm('betAmount'), _money(page.totalBetAmount))),
          _buildVerticalDivider(),
          Expanded(
              child: _buildSummaryItem(
                  _gm('validAmount'), _money(page.totalValidBetAmount))),
          _buildVerticalDivider(),
          Expanded(
            child: _buildSummaryItem(
              _gm('profitLoss'),
              _money(page.totalNetAmount),
              valueColor: page.totalNetAmount < 0 ? AppColors.danger : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameRecordItem(GameBetRecord item) {
    return CustomCard(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
      padding: EdgeInsets.all(16.w),
      borderRadius: 16.r,
      hasShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTag(_typeLabel(item.code)),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _shortTime(item.betTime),
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_statusLabel(item.status).isNotEmpty)
                _buildTag(_statusLabel(item.status)),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '${item.apiCodeTitle}${item.apiCodeTitle.isNotEmpty && item.gameCode.isNotEmpty ? ' · ' : ''}${item.gameCode}',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                  child: _buildRecordItem(_gm('bet'), _money(item.betAmount),
                      alignCenter: true)),
              Expanded(
                  child: _buildRecordItem(
                      _gm('valid'), _money(item.validBetAmount),
                      alignCenter: true)),
              Expanded(
                child: _buildRecordItem(
                  _gm('profitLoss'),
                  _money(item.netAmount),
                  valueColor: item.netAmount < 0 ? AppColors.danger : null,
                  alignCenter: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, {Color color = AppColors.primary}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          height: 1.05,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, {Color? valueColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
        SizedBox(height: 7.h),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildRecordItem(String title, String value,
      {Color? valueColor, bool alignCenter = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          alignCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 30.h, color: AppColors.border);
  }

  Widget _buildListFooter(bool loading, bool hasMore) {
    if (loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Text(
        hasMore ? '' : 'common.noMore'.tr(),
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
      ),
    );
  }

  Widget _buildEmptyList(String text) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 86.h),
        Icon(
          Icons.inbox_outlined,
          size: 42.sp,
          color: AppColors.textSecondary.withValues(alpha: 0.7),
        ),
        SizedBox(height: 12.h),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
        ),
      ],
    );
  }

  Future<void> _loadRecords() {
    final provider = context.read<GameManagementProvider>();
    final startDate = _dateTimeText(_range.start);
    final endDate = _dateTimeText(_range.end.add(const Duration(days: 1)));
    if (_tabController.index == 2) {
      return provider.loadGames(
        startDate: startDate,
        endDate: endDate,
        refresh: true,
      );
    }
    if (_tabController.index == 1) {
      return provider.loadFy(
        startDate: startDate,
        endDate: endDate,
        refresh: true,
      );
    }
    return provider.loadRebates(
      startDate: startDate,
      endDate: endDate,
      refresh: true,
    );
  }

  Future<void> _claimAllRebates() async {
    final provider = context.read<GameManagementProvider>();
    if (provider.rebatePage.notFsMoney <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_gm('noClaimable'))),
      );
      return;
    }
    try {
      await provider.claimAllRebates();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_gm('claimSuccess'))),
      );
    } catch (_) {
      if (!mounted) return;
      final error = context.read<GameManagementProvider>().claimRebateError ??
          'common.loadFailed'.tr();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _claimAllFy() async {
    final provider = context.read<GameManagementProvider>();
    if (provider.fyPage.unreceivedMoney <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_gm('noClaimableFy'))),
      );
      return;
    }
    try {
      await provider.claimAllFy();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_gm('claimSuccess'))),
      );
    } catch (_) {
      if (!mounted) return;
      final error = context.read<GameManagementProvider>().claimFyError ??
          'common.loadFailed'.tr();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_lastLoadedTabIndex == _tabController.index) return;
    _lastLoadedTabIndex = _tabController.index;
    _loadRecords();
  }

  void _handleRebateScroll() {
    if (_nearBottom(_rebateScrollController)) {
      context.read<GameManagementProvider>().loadMoreRebates();
    }
  }

  void _handleFyScroll() {
    if (_nearBottom(_fyScrollController)) {
      context.read<GameManagementProvider>().loadMoreFy();
    }
  }

  void _handleGameScroll() {
    if (_nearBottom(_gameScrollController)) {
      context.read<GameManagementProvider>().loadMoreGames();
    }
  }

  bool _nearBottom(ScrollController controller) {
    if (!controller.hasClients) return false;
    final position = controller.position;
    return position.pixels >= position.maxScrollExtent - 120;
  }

  void _setDateRange(String range) {
    setState(() {
      _selectedDateRange = range;
      _range = switch (range) {
        'yesterday' => _yesterdayRange(),
        'thisWeek' => _weekRange(DateTime.now()),
        'thisMonth' => _monthRange(DateTime.now()),
        'lastMonth' => _lastMonthRange(),
        _ => _todayRange(),
      };
    });
    _lastLoadedTabIndex = _tabController.index;
    _loadRecords();
  }

  String get _rangeText {
    final start = _monthDay(_range.start);
    final end = _monthDay(_range.end);
    return start == end ? start : '$start ~ $end';
  }

  String _money(double value) {
    return '¥ ${value.toStringAsFixed(2)}';
  }

  String _percentText(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '-';
    final parsed = double.tryParse(trimmed);
    if (parsed == null) return '-';
    return '$parsed%';
  }

  String _dateRangeLabel(String range) {
    return switch (range) {
      'yesterday' => _gm('yesterday'),
      'thisWeek' => _gm('thisWeek'),
      'thisMonth' => _gm('thisMonth'),
      'lastMonth' => _gm('lastMonth'),
      _ => _gm('today'),
    };
  }

  String _typeLabel(String code) {
    final key = switch (code) {
      'sports' => 'types.sports',
      'live' => 'types.live',
      'slots' => 'types.slots',
      'game' => 'types.game',
      'chess' => 'types.chess',
      'poker' => 'types.chess',
      'fishing' => 'types.fishing',
      'esports' => 'types.esports',
      _ => '',
    };
    if (key.isEmpty) return code.isNotEmpty ? code : _gm('unknown');
    return _gm(key);
  }

  String _statusLabel(int status) {
    return switch (status) {
      1 => _gm('status.settled'),
      2 => _gm('status.unsettled'),
      3 => _gm('status.invalid'),
      4 => _gm('status.refunded'),
      _ => '',
    };
  }

  String _gm(String key) {
    final language = context.locale.languageCode.toLowerCase();
    final country = context.locale.countryCode?.toUpperCase();
    final map = switch ((language, country)) {
      ('my', _) => _gameManagementTextMy,
      ('en', _) => _gameManagementTextEn,
      ('zh', 'TW') => _gameManagementTextTw,
      _ => _gameManagementTextCn,
    };
    return map[key] ?? _gameManagementTextCn[key] ?? key;
  }

  String _shortTime(String value) {
    if (value.isEmpty) return '-';
    return value.replaceFirst('T', ' ').substring(0, value.length.clamp(0, 16));
  }

  String _dateTimeText(DateTime date) {
    final day = _dateText(date);
    return '$day 00:00:00';
  }

  String _dateText(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _monthDay(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static DateTimeRange _todayRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return DateTimeRange(start: start, end: start);
  }

  static DateTimeRange _yesterdayRange() {
    final day = DateTime.now().subtract(const Duration(days: 1));
    final start = DateTime(day.year, day.month, day.day);
    return DateTimeRange(start: start, end: start);
  }

  static DateTimeRange _weekRange(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final start = day.subtract(Duration(days: day.weekday - DateTime.monday));
    return DateTimeRange(start: start, end: day);
  }

  static DateTimeRange _monthRange(DateTime date) {
    return DateTimeRange(
      start: DateTime(date.year, date.month),
      end: DateTime(date.year, date.month + 1, 0),
    );
  }

  static DateTimeRange _lastMonthRange() {
    final now = DateTime.now();
    return _monthRange(DateTime(now.year, now.month - 1));
  }
}

const _gameManagementTextCn = <String, String>{
  'title': '游戏管理',
  'queryDate': '查询日期',
  'today': '今日',
  'yesterday': '昨日',
  'thisWeek': '本周',
  'thisMonth': '本月',
  'lastMonth': '上月',
  'rebateRecords': '返水记录',
  'fyRecords': '返佣记录',
  'gameRecords': '游戏记录',
  'emptyRebate': '暂无返水记录',
  'emptyFy': '暂无返佣记录',
  'emptyGame': '暂无游戏记录',
  'totalRebate': '总返水',
  'totalFy': '总返佣',
  'claimed': '已领取',
  'unclaimed': '未领取',
  'pendingClaim': '待领取',
  'rebate': '返水',
  'valid': '有效',
  'profitLoss': '盈亏',
  'claimable': '可领取',
  'claimRebate': '领取返水',
  'claimFy': '领取返佣',
  'noClaimable': '暂无可领取返水',
  'noClaimableFy': '暂无可领取返佣',
  'claimSuccess': '领取成功',
  'betCount': '注单笔数',
  'betAmount': '投注金额',
  'validAmount': '有效金额',
  'bet': '投注',
  'flowAmount': '流水金额',
  'fyRate': '返佣',
  'fyAmount': '佣金',
  'unknown': '未知',
  'types.sports': '体育',
  'types.live': '真人',
  'types.slots': '电子',
  'types.game': '游戏',
  'types.chess': '棋牌',
  'types.fishing': '捕鱼',
  'types.esports': '电竞',
  'status.settled': '已结算',
  'status.unsettled': '未结算',
  'status.invalid': '无效注单',
  'status.refunded': '已退款',
};

final _gameManagementTextTw = <String, String>{
  ..._gameManagementTextCn,
  'title': '遊戲管理',
  'today': '今日',
  'yesterday': '昨日',
  'thisWeek': '本周',
  'thisMonth': '本月',
  'lastMonth': '上月',
  'rebateRecords': '返水記錄',
  'fyRecords': '返佣記錄',
  'gameRecords': '遊戲記錄',
  'emptyRebate': '暫無返水記錄',
  'emptyFy': '暫無返佣記錄',
  'emptyGame': '暫無遊戲記錄',
};

const _gameManagementTextEn = <String, String>{
  'title': 'Game Management',
  'queryDate': 'Query Date',
  'today': 'Today',
  'yesterday': 'Yesterday',
  'thisWeek': 'This Week',
  'thisMonth': 'This Month',
  'lastMonth': 'Last Month',
  'rebateRecords': 'Rebate Records',
  'fyRecords': 'Commission Records',
  'gameRecords': 'Game Records',
  'emptyRebate': 'No rebate records',
  'emptyFy': 'No commission records',
  'emptyGame': 'No game records',
  'totalRebate': 'Total Rebate',
  'totalFy': 'Total Commission',
  'claimed': 'Claimed',
  'unclaimed': 'Unclaimed',
  'pendingClaim': 'Pending Claim',
  'rebate': 'Rebate',
  'valid': 'Valid',
  'profitLoss': 'P/L',
  'claimable': 'Claimable',
  'claimRebate': 'Claim Rebate',
  'claimFy': 'Claim Commission',
  'noClaimable': 'No claimable rebate',
  'noClaimableFy': 'No claimable commission',
  'claimSuccess': 'Claim successful',
  'betCount': 'Bet Count',
  'betAmount': 'Bet Amount',
  'validAmount': 'Valid Amount',
  'bet': 'Bet',
  'flowAmount': 'Flow Amount',
  'fyRate': 'Commission',
  'fyAmount': 'Commission',
  'unknown': 'Unknown',
  'types.sports': 'Sports',
  'types.live': 'Live Casino',
  'types.slots': 'Slots',
  'types.game': 'Game',
  'types.chess': 'Chess',
  'types.fishing': 'Fishing',
  'types.esports': 'Esports',
  'status.settled': 'Settled',
  'status.unsettled': 'Unsettled',
  'status.invalid': 'Invalid Bet',
  'status.refunded': 'Refunded',
};

const _gameManagementTextMy = <String, String>{
  'title': 'ဂိမ်းစီမံခန့်ခွဲမှု',
  'queryDate': 'ရှာဖွေသည့်နေ့',
  'today': 'ယနေ့',
  'yesterday': 'မနေ့က',
  'thisWeek': 'ယခုအပတ်',
  'thisMonth': 'ယခုလ',
  'lastMonth': 'ပြီးခဲ့သောလ',
  'rebateRecords': 'ပြန်အမ်းမှတ်တမ်း',
  'fyRecords': 'ကော်မရှင်မှတ်တမ်း',
  'gameRecords': 'ဂိမ်းမှတ်တမ်း',
  'emptyRebate': 'ပြန်အမ်းမှတ်တမ်းမရှိပါ',
  'emptyFy': 'ကော်မရှင်မှတ်တမ်းမရှိပါ',
  'emptyGame': 'ဂိမ်းမှတ်တမ်းမရှိပါ',
  'totalRebate': 'စုစုပေါင်းပြန်အမ်း',
  'totalFy': 'စုစုပေါင်းကော်မရှင်',
  'claimed': 'ရယူပြီး',
  'unclaimed': 'မရယူရသေး',
  'pendingClaim': 'ရယူရန်စောင့်ဆိုင်း',
  'rebate': 'ပြန်အမ်း',
  'valid': 'မှန်ကန်',
  'profitLoss': 'အမြတ်/အရှုံး',
  'claimable': 'ရယူနိုင်',
  'claimRebate': 'ပြန်အမ်းငွေရယူရန်',
  'claimFy': 'ကော်မရှင်ရယူရန်',
  'noClaimable': 'ရယူနိုင်သောပြန်အမ်းငွေမရှိပါ',
  'noClaimableFy': 'ရယူနိုင်သောကော်မရှင်မရှိပါ',
  'claimSuccess': 'ရယူပြီးပါပြီ',
  'betCount': 'လောင်းကြေးအရေအတွက်',
  'betAmount': 'လောင်းကြေးငွေ',
  'validAmount': 'မှန်ကန်သောငွေ',
  'bet': 'လောင်းကြေး',
  'flowAmount': 'လောင်းကြေးလည်ပတ်ငွေ',
  'fyRate': 'ကော်မရှင်',
  'fyAmount': 'ကော်မရှင်ငွေ',
  'unknown': 'မသိပါ',
  'types.sports': 'အားကစား',
  'types.live': 'တိုက်ရိုက်ကာစီနို',
  'types.slots': 'စလော့',
  'types.game': 'ဂိမ်း',
  'types.chess': 'ဘုတ်ဂိမ်း',
  'types.fishing': 'ငါးဖမ်း',
  'types.esports': 'အီလက်ထရောနစ်အားကစား',
  'status.settled': 'စာရင်းချုပ်ပြီး',
  'status.unsettled': 'စာရင်းမချုပ်ရသေး',
  'status.invalid': 'မမှန်သောလောင်းကြေး',
  'status.refunded': 'ပြန်အမ်းပြီး',
};
