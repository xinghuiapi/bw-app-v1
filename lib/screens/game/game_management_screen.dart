import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/game/game_management_models.dart';
import '../../providers/game/game_management_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_nav_bar.dart';

class GameManagementScreen extends StatefulWidget {
  const GameManagementScreen({super.key});

  @override
  State<GameManagementScreen> createState() => _GameManagementScreenState();
}

class _GameManagementScreenState extends State<GameManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _rebateScrollController = ScrollController();
  final ScrollController _gameScrollController = ScrollController();

  String _selectedDateRange = '今天';
  DateTimeRange _range = _todayRange();
  final List<String> _dateRanges = ['今天', '昨日', '本月', '上月'];
  int _lastLoadedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChanged);
    _rebateScrollController.addListener(_handleRebateScroll);
    _gameScrollController.addListener(_handleGameScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecords());
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _rebateScrollController.dispose();
    _gameScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '游戏管理'),
      body: Column(
        children: [
          _buildDateFilter(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRebateTab(),
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
                  '查询日期',
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
                          range,
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
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 16.sp),
          tabs: const [
            Tab(text: '返水记录', height: 42),
            Tab(text: '游戏记录', height: 42),
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
                        ? _buildEmptyList('暂无返水记录')
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
            _buildRebateBottomBar(page.notFsMoney),
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
          Expanded(child: _buildSummaryItem('总返水', _money(page.totalFsMoney))),
          _buildVerticalDivider(),
          Expanded(child: _buildSummaryItem('已领取', _money(page.yesFsMoney))),
          _buildVerticalDivider(),
          Expanded(child: _buildSummaryItem('未领取', _money(page.notFsMoney))),
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
              _buildTag(item.claimed ? '已领取' : '待领取',
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
                  child: _buildRecordItem('返水', _money(item.fsMoney),
                      alignCenter: true)),
              Expanded(
                  child: _buildRecordItem('有效', _money(item.money),
                      alignCenter: true)),
              Expanded(
                  child: _buildRecordItem('盈亏', _money(0), alignCenter: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRebateBottomBar(double amount) {
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('可领取',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12.sp)),
                SizedBox(height: 4.h),
                Text(
                  _money(amount),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              ),
              child: Text('领取返水', style: TextStyle(fontSize: 16.sp)),
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
                        ? _buildEmptyList('暂无游戏记录')
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
          Expanded(child: _buildSummaryItem('注单笔数', '${page.total}')),
          _buildVerticalDivider(),
          Expanded(
              child: _buildSummaryItem('投注金额', _money(page.totalBetAmount))),
          _buildVerticalDivider(),
          Expanded(
              child:
                  _buildSummaryItem('有效金额', _money(page.totalValidBetAmount))),
          _buildVerticalDivider(),
          Expanded(
            child: _buildSummaryItem(
              '盈亏',
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
                  child: _buildRecordItem('投注', _money(item.betAmount),
                      alignCenter: true)),
              Expanded(
                  child: _buildRecordItem('有效', _money(item.validBetAmount),
                      alignCenter: true)),
              Expanded(
                child: _buildRecordItem(
                  '盈亏',
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
        hasMore ? '' : '没有更多了',
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
    final startDate = _dateText(_range.start);
    final endDate = _dateText(_range.end);
    if (_tabController.index == 1) {
      return provider.loadGames(
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
        '昨日' => _yesterdayRange(),
        '本月' => _monthRange(DateTime.now()),
        '上月' => _lastMonthRange(),
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

  String _typeLabel(String code) {
    const map = {
      'sports': '体育',
      'live': '真人',
      'slots': '电子',
      'game': '游戏',
      'chess': '棋牌',
      'poker': '棋牌',
      'fishing': '捕鱼',
      'esports': '电竞',
    };
    return map[code] ?? (code.isNotEmpty ? code : '未知');
  }

  String _statusLabel(int status) {
    return switch (status) {
      1 => '已结算',
      2 => '未结算',
      3 => '无效注单',
      4 => '已退款',
      _ => '',
    };
  }

  String _shortTime(String value) {
    if (value.isEmpty) return '-';
    return value.replaceFirst('T', ' ').substring(0, value.length.clamp(0, 16));
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
