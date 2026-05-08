import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/wallet/record_models.dart';
import '../../providers/record/record_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_nav_bar.dart';

class FundManagementScreen extends StatefulWidget {
  const FundManagementScreen({super.key});

  @override
  State<FundManagementScreen> createState() => _FundManagementScreenState();
}

class _FundManagementScreenState extends State<FundManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _depositScrollController = ScrollController();
  final ScrollController _withdrawScrollController = ScrollController();
  final ScrollController _transferScrollController = ScrollController();
  final ScrollController _accountScrollController = ScrollController();

  String _selectedDateRange = '本月';
  DateTimeRange _range = _monthRange(DateTime.now());
  final List<String> _dateRanges = ['今天', '昨日', '本月', '上月'];
  int _lastLoadedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChanged);
    _depositScrollController.addListener(
        () => _handleScroll(_depositScrollController, FundRecordTab.deposit));
    _withdrawScrollController.addListener(
        () => _handleScroll(_withdrawScrollController, FundRecordTab.withdraw));
    _transferScrollController.addListener(
        () => _handleScroll(_transferScrollController, FundRecordTab.transfer));
    _accountScrollController.addListener(
        () => _handleScroll(_accountScrollController, FundRecordTab.account));
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurrentTab());
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _depositScrollController.dispose();
    _withdrawScrollController.dispose();
    _transferScrollController.dispose();
    _accountScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '资金管理'),
      body: Column(
        children: [
          _buildDateFilter(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTradeTab(FundRecordTab.deposit),
                _buildTradeTab(FundRecordTab.withdraw),
                _buildTransferTab(),
                _buildAccountTab(),
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
                          ),
                        ),
                        child: Text(
                          range,
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
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 14.sp),
          tabs: const [
            Tab(text: '充值记录', height: 42),
            Tab(text: '提现记录', height: 42),
            Tab(text: '转账记录', height: 42),
            Tab(text: '账户明细', height: 42),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeTab(FundRecordTab tab) {
    return Consumer<RecordProvider>(
      builder: (context, provider, child) {
        final page = tab == FundRecordTab.deposit
            ? provider.depositPage
            : provider.withdrawPage;
        final records = page.records;
        return RefreshIndicator(
          onRefresh: _loadCurrentTab,
          child: provider.isLoading(tab) && records.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : records.isEmpty
                  ? _buildEmptyList(
                      tab == FundRecordTab.deposit ? '暂无充值记录' : '暂无提现记录')
                  : ListView.builder(
                      controller: _controllerFor(tab),
                      padding: EdgeInsets.only(bottom: 20.h),
                      itemCount: records.length + 1,
                      itemBuilder: (context, index) {
                        if (index == records.length) {
                          return _buildListFooter(
                            provider.isLoadingMore(tab),
                            provider.hasMore(tab),
                          );
                        }
                        return _buildTradeItem(records[index], tab);
                      },
                    ),
        );
      },
    );
  }

  Widget _buildTransferTab() {
    const tab = FundRecordTab.transfer;
    return Consumer<RecordProvider>(
      builder: (context, provider, child) {
        final records = provider.transferPage.records;
        return RefreshIndicator(
          onRefresh: _loadCurrentTab,
          child: provider.isLoading(tab) && records.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : records.isEmpty
                  ? _buildEmptyList('暂无转账记录')
                  : ListView.builder(
                      controller: _transferScrollController,
                      padding: EdgeInsets.only(bottom: 20.h),
                      itemCount: records.length + 1,
                      itemBuilder: (context, index) {
                        if (index == records.length) {
                          return _buildListFooter(
                            provider.isLoadingMore(tab),
                            provider.hasMore(tab),
                          );
                        }
                        return _buildTransferItem(records[index]);
                      },
                    ),
        );
      },
    );
  }

  Widget _buildAccountTab() {
    const tab = FundRecordTab.account;
    return Consumer<RecordProvider>(
      builder: (context, provider, child) {
        final records = provider.accountPage.records;
        return RefreshIndicator(
          onRefresh: _loadCurrentTab,
          child: provider.isLoading(tab) && records.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : records.isEmpty
                  ? _buildEmptyList('暂无账户明细')
                  : ListView.builder(
                      controller: _accountScrollController,
                      padding: EdgeInsets.only(bottom: 20.h),
                      itemCount: records.length + 1,
                      itemBuilder: (context, index) {
                        if (index == records.length) {
                          return _buildListFooter(
                            provider.isLoadingMore(tab),
                            provider.hasMore(tab),
                          );
                        }
                        return _buildAccountItem(
                          records[index],
                          provider.accountPage.types,
                        );
                      },
                    ),
        );
      },
    );
  }

  Widget _buildTradeItem(TradeRecord item, FundRecordTab tab) {
    final status = _tradeStatus(item.status, tab);
    final sign = tab == FundRecordTab.withdraw ? '-' : '+';
    return _buildRecordCard(
      title: item.title.isNotEmpty
          ? item.title
          : (tab == FundRecordTab.deposit ? '充值' : '提现'),
      status: status.$1,
      statusColor: status.$2,
      amount: '$sign${_money(item.money)}',
      orderNo: item.order,
      time: item.createdAt,
      note: item.note,
    );
  }

  Widget _buildTransferItem(TransferRecord item) {
    final statusColor = item.status == 1 ? AppColors.success : AppColors.danger;
    return _buildRecordCard(
      title:
          '${item.code.isNotEmpty ? item.code : '场馆'} ${item.isIn ? '转入' : '转出'}',
      status: item.status == 1 ? '成功' : '失败',
      statusColor: statusColor,
      amount: '${item.isIn ? '+' : '-'}${_money(item.money)}',
      orderNo: item.order,
      time: item.createdAt,
    );
  }

  Widget _buildRecordCard({
    required String title,
    required String status,
    required Color statusColor,
    required String amount,
    required String orderNo,
    required String time,
    String note = '',
  }) {
    return CustomCard(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h),
      padding: EdgeInsets.all(16.w),
      borderRadius: 16.r,
      hasShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _buildStatusTag(status, statusColor),
                  ],
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: amount.startsWith('-')
                      ? AppColors.danger
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '订单号：${orderNo.isEmpty ? '-' : orderNo}',
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
          if (note.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              note,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            _shortTime(time),
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountItem(MoneyLog item, List<MoneyLogType> types) {
    final typeName = types
        .where((type) => type.id == item.moneyTypeId)
        .map((type) => type.name)
        .firstOrNull;
    final title =
        typeName ?? (item.moneyTypeId > 0 ? '类型 ${item.moneyTypeId}' : '账户变动');
    return CustomCard(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h),
      padding: EdgeInsets.all(16.w),
      borderRadius: 16.r,
      hasShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.note.isNotEmpty) ...[
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          item.note,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '${item.isNegative ? '-' : '+'}${_money(item.money.abs())}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: item.isNegative
                      ? AppColors.danger
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '余额：${_money(item.afterMoney)}',
                style:
                    TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
              ),
              Text(
                _shortTime(item.createdAt),
                style:
                    TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10.sp)),
    );
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
        SizedBox(height: 90.h),
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

  Future<void> _loadCurrentTab() {
    return context.read<RecordProvider>().loadTab(
          _currentTab,
          startDate: _dateText(_range.start),
          endDate: _dateText(_range.end),
          refresh: true,
        );
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_lastLoadedTabIndex == _tabController.index) return;
    _lastLoadedTabIndex = _tabController.index;
    _loadCurrentTab();
  }

  void _handleScroll(ScrollController controller, FundRecordTab tab) {
    if (!_nearBottom(controller)) return;
    context.read<RecordProvider>().loadMore(tab);
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
    _loadCurrentTab();
  }

  FundRecordTab get _currentTab => FundRecordTab.values[_tabController.index];

  ScrollController _controllerFor(FundRecordTab tab) {
    return switch (tab) {
      FundRecordTab.deposit => _depositScrollController,
      FundRecordTab.withdraw => _withdrawScrollController,
      FundRecordTab.transfer => _transferScrollController,
      FundRecordTab.account => _accountScrollController,
    };
  }

  (String, Color) _tradeStatus(int status, FundRecordTab tab) {
    if (status == 1 || status == 2) return ('成功', AppColors.success);
    if (status == 5) return ('处理中', AppColors.warning);
    if (status == 3) return ('已取消', AppColors.textSecondary);
    if (status == 4) return ('已拒绝', AppColors.danger);
    return ('失败', AppColors.danger);
  }

  String get _rangeText {
    final start = _monthDay(_range.start);
    final end = _monthDay(_range.end);
    return start == end ? start : '$start ~ $end';
  }

  String _money(double value) {
    return '¥ ${value.toStringAsFixed(2)}';
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
