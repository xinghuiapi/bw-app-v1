import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/wallet/record_models.dart';
import '../../providers/record/record_provider.dart';
import '../../providers/localization/language_provider.dart';
import '../../providers/user/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_nav_bar.dart';

class FundManagementScreen extends StatefulWidget {
  const FundManagementScreen(
      {super.key, this.initialTab = FundRecordTab.deposit});

  final FundRecordTab initialTab;

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
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab.index,
    );
    _lastLoadedTabIndex = widget.initialTab.index;
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
    final languageCode = context.watch<LanguageProvider>().currentCode;
    if (_lastLanguageCode == null) {
      _lastLanguageCode = languageCode;
    } else if (_lastLanguageCode != languageCode) {
      _lastLanguageCode = languageCode;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadCurrentTab();
      });
    }
    final profile = context.watch<UserProvider>().profile;
    final symbol = profile?.symbol?.trim().isNotEmpty == true
        ? profile!.symbol!.trim()
        : '¥';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(title: _fundText('title')),
      body: KeyedSubtree(
        key: ValueKey(languageCode),
        child: Column(
          children: [
            _buildDateFilter(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTradeTab(FundRecordTab.deposit, symbol),
                  _buildTradeTab(FundRecordTab.withdraw, symbol),
                  _buildTransferTab(symbol),
                  _buildAccountTab(symbol),
                ],
              ),
            ),
          ],
        ),
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
                  _fundText('queryDate'),
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
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 14.sp),
          tabs: [
            Tab(text: _fundText('depositRecords'), height: 42),
            Tab(text: _fundText('withdrawRecords'), height: 42),
            Tab(text: _fundText('transferRecords'), height: 42),
            Tab(text: _fundText('accountDetails'), height: 42),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeTab(FundRecordTab tab, String symbol) {
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
                  ? _buildEmptyList(tab == FundRecordTab.deposit
                      ? _fundText('emptyDeposit')
                      : _fundText('emptyWithdraw'))
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
                        return _buildTradeItem(records[index], tab, symbol);
                      },
                    ),
        );
      },
    );
  }

  Widget _buildTransferTab(String symbol) {
    const tab = FundRecordTab.transfer;
    return Consumer<RecordProvider>(
      builder: (context, provider, child) {
        final records = provider.transferPage.records;
        return RefreshIndicator(
          onRefresh: _loadCurrentTab,
          child: provider.isLoading(tab) && records.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : records.isEmpty
                  ? _buildEmptyList(_fundText('emptyTransfer'))
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
                        return _buildTransferItem(records[index], symbol);
                      },
                    ),
        );
      },
    );
  }

  Widget _buildAccountTab(String symbol) {
    const tab = FundRecordTab.account;
    return Consumer<RecordProvider>(
      builder: (context, provider, child) {
        final records = provider.accountPage.records;
        return RefreshIndicator(
          onRefresh: _loadCurrentTab,
          child: provider.isLoading(tab) && records.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : records.isEmpty
                  ? _buildEmptyList(_fundText('emptyAccount'))
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
                          symbol,
                        );
                      },
                    ),
        );
      },
    );
  }

  Widget _buildTradeItem(TradeRecord item, FundRecordTab tab, String symbol) {
    final status = _tradeStatus(item.status, tab);
    return _buildRecordCard(
      title: item.title.isNotEmpty
          ? item.title
          : (tab == FundRecordTab.deposit
              ? _fundText('depositTitle')
              : _fundText('withdrawTitle')),
      status: status.$1,
      statusColor: status.$2,
      amount: _money(item.money, symbol),
      orderNo: item.order,
      time: item.createdAt,
      note: tab == FundRecordTab.withdraw && _isTradeFailed(item.status)
          ? item.note
          : '',
    );
  }

  Widget _buildTransferItem(TransferRecord item, String symbol) {
    final statusColor = item.status == 1 ? AppColors.success : AppColors.danger;
    return _buildRecordCard(
      title:
          '${item.code.isNotEmpty ? item.code : _fundText('venue')} ${item.isIn ? _fundText('transferIn') : _fundText('transferOut')}',
      status: item.status == 1 ? _fundText('success') : _fundText('failed'),
      statusColor: statusColor,
      amount: '${item.isIn ? '+' : '-'}${_money(item.money, symbol)}',
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            _fundText('orderNo', {'orderNo': orderNo.isEmpty ? '-' : orderNo}),
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

  Widget _buildAccountItem(
    MoneyLog item,
    List<MoneyLogType> types,
    String symbol,
  ) {
    final typeName = types
        .where((type) => type.id == item.moneyTypeId)
        .map((type) => type.name)
        .firstOrNull;
    final title = typeName ??
        (item.moneyTypeId > 0
            ? _fundText('typeNumber', {'type': '${item.moneyTypeId}'})
            : _fundText('accountChange'));
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
                          _maybeTranslate(item.note),
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
                '${item.isNegative ? '-' : '+'}${_money(item.money.abs(), symbol)}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: item.isNegative
                      ? AppColors.danger
                      : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _fundText(
                    'balance', {'amount': _money(item.afterMoney, symbol)}),
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
          startDate: _dateTimeText(_range.start, endOfDay: false),
          endDate: _dateTimeText(_range.end, endOfDay: true),
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
        'yesterday' => _yesterdayRange(),
        'thisWeek' => _weekRange(DateTime.now()),
        'thisMonth' => _monthRange(DateTime.now()),
        'lastMonth' => _lastMonthRange(),
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
    if (status == 1) return (_fundText('success'), AppColors.success);
    if (status == 0) return (_fundText('timeout'), AppColors.danger);
    if (status == 5) {
      return (
        tab == FundRecordTab.deposit
            ? _fundText('depositing')
            : _fundText('processing'),
        AppColors.warning
      );
    }
    if (status == 2) return (_fundText('manualConfirm'), AppColors.warning);
    if (status == 3) return (_fundText('userCanceled'), AppColors.danger);
    if (status == 4) return (_fundText('rejected'), AppColors.danger);
    return (_fundText('unknown'), AppColors.primary);
  }

  String _dateRangeLabel(String range) {
    return switch (range) {
      'yesterday' => _fundText('yesterday'),
      'thisWeek' => _fundText('thisWeek'),
      'thisMonth' => _fundText('thisMonth'),
      'lastMonth' => _fundText('lastMonth'),
      _ => _fundText('today'),
    };
  }

  bool _isTradeFailed(int status) => status == 0 || status == 3 || status == 4;

  String get _rangeText {
    final start = _monthDay(_range.start);
    final end = _monthDay(_range.end);
    return start == end ? start : '$start ~ $end';
  }

  String _money(double value, String symbol) {
    return '$symbol ${value.toStringAsFixed(2)}';
  }

  String _shortTime(String value) {
    if (value.isEmpty) return '-';
    return value.replaceFirst('T', ' ').substring(0, value.length.clamp(0, 16));
  }

  String _dateTimeText(DateTime date, {required bool endOfDay}) {
    final day = _dateText(date);
    return '$day ${endOfDay ? '23:59:59' : '00:00:00'}';
  }

  String _dateText(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _monthDay(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _fundText(String key, [Map<String, String> args = const {}]) {
    final fullKey = 'finance.fund.$key';
    final translated = fullKey.tr(namedArgs: args);
    if (translated != fullKey) return translated;
    return _fundFallbackText(key, args);
  }

  String _fundFallbackText(String key, Map<String, String> args) {
    final language = context.locale.languageCode.toLowerCase();
    final country = context.locale.countryCode?.toUpperCase();
    final map = switch ((language, country)) {
      ('my', _) => _fundTextMy,
      ('en', _) => _fundTextEn,
      ('zh', 'TW') => _fundTextTw,
      _ => _fundTextCn,
    };
    var text = map[key] ?? _fundTextCn[key] ?? 'finance.fund.$key';
    for (final entry in args.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  String _maybeTranslate(String value) {
    final text = value.trim();
    if (text.startsWith('finance.fund.')) {
      return _fundText(text.split('.').last);
    }
    return text;
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

const _fundTextCn = <String, String>{
  'title': '资金管理',
  'queryDate': '查询日期',
  'today': '今天',
  'yesterday': '昨日',
  'thisWeek': '本周',
  'thisMonth': '本月',
  'lastMonth': '上月',
  'depositRecords': '充值记录',
  'withdrawRecords': '提现记录',
  'transferRecords': '转账记录',
  'accountDetails': '账户明细',
  'emptyDeposit': '暂无充值记录',
  'emptyWithdraw': '暂无提现记录',
  'emptyTransfer': '暂无转账记录',
  'emptyAccount': '暂无账户明细',
  'venue': '场馆',
  'transferIn': '转入',
  'transferOut': '转出',
  'success': '成功',
  'failed': '失败',
  'orderNo': '订单号：{orderNo}',
  'typeNumber': '类型 {type}',
  'accountChange': '账户变动',
  'balance': '余额：{amount}',
  'timeout': '已超时',
  'depositing': '充值中',
  'processing': '处理中',
  'manualConfirm': '人工确认',
  'userCanceled': '用户取消',
  'rejected': '已拒绝',
  'unknown': '未知',
  'depositTitle': '充值',
  'withdrawTitle': '提现',
};

final _fundTextTw = <String, String>{
  ..._fundTextCn,
  'title': '資金管理',
  'queryDate': '查詢日期',
  'today': '今日',
  'thisWeek': '本週',
  'depositRecords': '充值記錄',
  'withdrawRecords': '提款記錄',
  'transferRecords': '轉帳記錄',
  'accountDetails': '帳戶明細',
  'emptyDeposit': '暫無充值記錄',
  'emptyWithdraw': '暫無提款記錄',
  'emptyTransfer': '暫無轉帳記錄',
  'emptyAccount': '暫無帳戶明細',
  'transferIn': '轉入',
  'transferOut': '轉出',
  'orderNo': '訂單號：{orderNo}',
  'accountChange': '帳戶變動',
  'userCanceled': '用戶取消',
  'depositTitle': '充值',
  'withdrawTitle': '提款',
};

const _fundTextEn = <String, String>{
  'title': 'Fund Management',
  'queryDate': 'Query Date',
  'today': 'Today',
  'yesterday': 'Yesterday',
  'thisWeek': 'This Week',
  'thisMonth': 'This Month',
  'lastMonth': 'Last Month',
  'depositRecords': 'Deposit Records',
  'withdrawRecords': 'Withdrawal Records',
  'transferRecords': 'Transfer Records',
  'accountDetails': 'Account Details',
  'emptyDeposit': 'No deposit records',
  'emptyWithdraw': 'No withdrawal records',
  'emptyTransfer': 'No transfer records',
  'emptyAccount': 'No account details',
  'venue': 'Venue',
  'transferIn': 'Transfer In',
  'transferOut': 'Transfer Out',
  'success': 'Success',
  'failed': 'Failed',
  'orderNo': 'Order No.: {orderNo}',
  'typeNumber': 'Type {type}',
  'accountChange': 'Account Change',
  'balance': 'Balance: {amount}',
  'timeout': 'Timed out',
  'depositing': 'Depositing',
  'processing': 'Processing',
  'manualConfirm': 'Manual Confirm',
  'userCanceled': 'Canceled',
  'rejected': 'Rejected',
  'unknown': 'Unknown',
  'depositTitle': 'Deposit',
  'withdrawTitle': 'Withdrawal',
};

const _fundTextMy = <String, String>{
  'title': 'ရန်ပုံငွေစီမံခန့်ခွဲမှု',
  'queryDate': 'ရှာဖွေသည့်နေ့',
  'today': 'ယနေ့',
  'yesterday': 'မနေ့က',
  'thisWeek': 'ယခုအပတ်',
  'thisMonth': 'ယခုလ',
  'lastMonth': 'ပြီးခဲ့သောလ',
  'depositRecords': 'ငွေသွင်းမှတ်တမ်း',
  'withdrawRecords': 'ငွေထုတ်မှတ်တမ်း',
  'transferRecords': 'လွှဲပြောင်းမှတ်တမ်း',
  'accountDetails': 'အကောင့်အသေးစိတ်',
  'emptyDeposit': 'ငွေသွင်းမှတ်တမ်းမရှိပါ',
  'emptyWithdraw': 'ငွေထုတ်မှတ်တမ်းမရှိပါ',
  'emptyTransfer': 'လွှဲပြောင်းမှတ်တမ်းမရှိပါ',
  'emptyAccount': 'အကောင့်အသေးစိတ်မရှိပါ',
  'venue': 'ဂိမ်းပလက်ဖောင်း',
  'transferIn': 'လွှဲဝင်',
  'transferOut': 'လွှဲထွက်',
  'success': 'အောင်မြင်',
  'failed': 'မအောင်မြင်',
  'orderNo': 'အော်ဒါနံပါတ်：{orderNo}',
  'typeNumber': 'အမျိုးအစား {type}',
  'accountChange': 'အကောင့်ပြောင်းလဲမှု',
  'balance': 'လက်ကျန်：{amount}',
  'timeout': 'အချိန်ကုန်ဆုံး',
  'depositing': 'ငွေသွင်းနေသည်',
  'processing': 'ဆောင်ရွက်နေသည်',
  'manualConfirm': 'လက်ဖြင့်အတည်ပြု',
  'userCanceled': 'အသုံးပြုသူပယ်ဖျက်',
  'rejected': 'ငြင်းပယ်ပြီး',
  'unknown': 'မသိရှိ',
  'depositTitle': 'ငွေသွင်း',
  'withdrawTitle': 'ငွေထုတ်',
};
