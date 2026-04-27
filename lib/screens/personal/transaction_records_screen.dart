import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_app/services/wallet/finance_service.dart';
import 'package:my_flutter_app/models/wallet/finance_models.dart';
import 'package:my_flutter_app/widgets/common/state_widgets.dart';
import 'package:my_flutter_app/theme/app_theme.dart';

class TransactionRecordsScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const TransactionRecordsScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<TransactionRecordsScreen> createState() =>
      _TransactionRecordsScreenState();
}

class _TransactionRecordsScreenState
    extends ConsumerState<TransactionRecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['充值', '提现', '转账', '返水', '下注', '账变'];

  // 筛选相关
  String _activeQuickDate = 'today';
  DateTimeRange? _selectedDateRange;

  // 返水筛选相关
  String? _rebateCode; // 游戏类型 (live, egame, etc)
  int? _rebateStatus; // 0: 未领取 1: 已领取
  // 下注记录筛选相关
  String? _betCode; // 游戏类型
  int? _betStatus; // 状态
  // 账变记录筛选相关
  String? _moneyLogType;
  String? _moneyLogMoneyTypeId;
  // 数据状态
  final Map<int, List<dynamic>> _records = {};
  final Map<int, int> _currentPage = {};
  final Map<int, bool> _isLoading = {};
  final Map<int, bool> _hasMore = {};
  final Map<int, String?> _error = {};
  final Map<int, ScrollController> _scrollControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(_handleTabChange);

    // 初始化各标签状态
    for (int i = 0; i < _tabs.length; i++) {
      _records[i] = [];
      _currentPage[i] = 1;
      _isLoading[i] = false;
      _hasMore[i] = true;
      _error[i] = null;
      _scrollControllers[i] = ScrollController();
      _scrollControllers[i]!.addListener(() => _onScroll(i));
    }

    // 默认加载初始标签
    _loadData(widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onScroll(int index) {
    if (!_scrollControllers[index]!.hasClients) return;

    final maxScroll = _scrollControllers[index]!.position.maxScrollExtent;
    final currentScroll = _scrollControllers[index]!.offset;

    // 距离底部 200 像素时预加载
    if (maxScroll - currentScroll < 200) {
      if (_hasMore[index]! && !_isLoading[index]! && _error[index] == null) {
        _loadData(index);
      }
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
      if (_records[_tabController.index]!.isEmpty) {
        _loadData(_tabController.index);
      }
    }
  }

  Future<void> _loadData(int index, {bool isRefresh = false}) async {
    if (_isLoading[index]! && !isRefresh) return;

    if (mounted) {
      setState(() {
        _isLoading[index] = true;
        if (isRefresh) {
          _currentPage[index] = 1;
          _records[index] = [];
          _hasMore[index] = true;
          _error[index] = null;
        }
      });
    }

    try {
      final page = _currentPage[index]!;
      dynamic response;

      final startDate = _selectedDateRange?.start != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start)
          : _getQuickDateStart(_activeQuickDate);
      final endDate = _selectedDateRange?.end != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)
          : DateFormat('yyyy-MM-dd').format(DateTime.now());

      switch (index) {
        case 0: // 充值
          response = await FinanceService.getTradeRecord(
            TradeRecordRequest(
              page: page,
              type: 'recharge',
              startDate: startDate,
              endDate: endDate,
            ),
          );
          break;
        case 1: // 提现
          response = await FinanceService.getTradeRecord(
            TradeRecordRequest(
              page: page,
              type: 'drawing',
              startDate: startDate,
              endDate: endDate,
            ),
          );
          break;
        case 2: // 转账
          response = await FinanceService.getTransferRecords(page: page);
          break;
        case 3: // 返水
          response = await FinanceService.getRebateRecords(
            page: page,
            startDate: startDate,
            endDate: endDate,
            code: _rebateCode,
            status: _rebateStatus,
          );
          break;
        case 4: // 下注
          response = await FinanceService.getBettingRecords(
            page: page,
            startDate: startDate,
            endDate: endDate,
            code: _betCode,
            status: _betStatus,
          );
          break;
        case 5: // 账变
          response = await FinanceService.getMoneyLogList(
            page: page,
            startDate: startDate,
            endDate: endDate,
            type: _moneyLogType,
            moneyTypeId: _moneyLogMoneyTypeId,
          );
          break;
      }

      if (mounted) {
        setState(() {
          if (response.code == 200) {
            final List<dynamic> newItems = response.data ?? [];
            if (newItems.isEmpty) {
              _hasMore[index] = false;
            } else {
              _records[index]!.addAll(newItems);
              _currentPage[index] = page + 1;
              if (newItems.length < 20) {
                _hasMore[index] = false;
              }
            }
          } else {
            _error[index] = response.msg ?? '加载失败';
          }
          _isLoading[index] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error[index] = e.toString();
          _isLoading[index] = false;
        });
      }
    }
  }

  String _getQuickDateStart(String type) {
    final now = DateTime.now();
    switch (type) {
      case 'today':
        return DateFormat('yyyy-MM-dd').format(now);
      case 'yesterday':
        return DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 1)));
      case 'week':
        return DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 6)));
      case 'month':
        return DateFormat('yyyy-MM-01').format(now);
      default:
        return DateFormat('yyyy-MM-dd').format(now);
    }
  }

  void _applyQuickDate(String type) {
    setState(() {
      _activeQuickDate = type;
      _selectedDateRange = null;
    });
    _loadData(_tabController.index, isRefresh: true);
  }

  bool _isClaiming = false;

  Future<void> _claimAllRebate() async {
    if (_isClaiming) return;

    setState(() => _isClaiming = true);
    try {
      final response = await FinanceService.claimAllRebate();
      if (response.code == 200) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('领取成功')));
          _loadData(3, isRefresh: true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.msg ?? '领取失败')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isClaiming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        title: const Text('往来记录'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelPadding: const EdgeInsets.symmetric(horizontal: 20),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.getTextSecondary(context),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(
                _tabs.length,
                (index) => _buildRecordList(index),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _tabController.index == 3
          ? Builder(
              builder: (context) {
                final hasUnclaimed =
                    _records[3]?.any(
                      (r) => r is RebateRecord && r.status == 0,
                    ) ??
                    false;
                if (hasUnclaimed) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.getDividerColor(context),
                        ),
                      ),
                      // Removed BoxShadow for web optimization
                    ),
                    child: SafeArea(
                      child: ElevatedButton(
                        onPressed: _isClaiming ? null : _claimAllRebate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isClaiming
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                '一键领取全部返水',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: AppTheme.getCardColor(context),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('今日', 'today'),
                _buildFilterChip('昨日', 'yesterday'),
                _buildFilterChip('近七日', 'week'),
                _buildFilterChip('本月', 'month'),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showDateRangePicker,
                  icon: Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: AppTheme.getTextSecondary(context),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.getInputFillColor(context),
                    padding: const EdgeInsets.all(8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_tabController.index == 3) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildRebateFilterDropdown(
                    label: _rebateCode ?? '所有类型',
                    options: {
                      null: '所有类型',
                      'live': '真人',
                      'game': '电子',
                      'sport': '体育',
                      'chess': '棋牌',
                      'lottery': '彩票',
                      'fish': '捕鱼',
                    },
                    value: _rebateCode,
                    onChanged: (val) => setState(() {
                      _rebateCode = val;
                      _loadData(3, isRefresh: true);
                    }),
                  ),
                  const SizedBox(width: 8),
                  _buildRebateFilterDropdown(
                    label: _rebateStatus == null
                        ? '所有状态'
                        : (_rebateStatus == 1 ? '已领取' : '未领取'),
                    options: {null: '所有状态', 1: '已领取', 0: '未领取'},
                    value: _rebateStatus,
                    onChanged: (val) => setState(() {
                      _rebateStatus = val;
                      _loadData(3, isRefresh: true);
                    }),
                  ),
                ],
              ),
            ),
          ],
          if (_tabController.index == 4) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildRebateFilterDropdown(
                    label: _betCode ?? '所有类型',
                    options: {
                      null: '所有类型',
                      'live': '真人',
                      'game': '电子',
                      'sport': '体育',
                      'chess': '棋牌',
                      'lottery': '彩票',
                      'fish': '捕鱼',
                    },
                    value: _betCode,
                    onChanged: (val) => setState(() {
                      _betCode = val;
                      _loadData(4, isRefresh: true);
                    }),
                  ),
                  const SizedBox(width: 8),
                  _buildRebateFilterDropdown(
                    label: _betStatus == null
                        ? '所有状态'
                        : (_betStatus == 1 ? '已结算' : '未结算'),
                    options: {null: '所有状态', 1: '已结算', 0: '未结算'},
                    value: _betStatus,
                    onChanged: (val) => setState(() {
                      _betStatus = val;
                      _loadData(4, isRefresh: true);
                    }),
                  ),
                ],
              ),
            ),
          ],
          if (_tabController.index == 5) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildRebateFilterDropdown(
                    label: _moneyLogType == null
                        ? '所有类型'
                        : (_moneyLogType == '1' ? '增加' : '减少'),
                    options: {null: '所有类型', '1': '增加', '2': '减少'},
                    value: _moneyLogType,
                    onChanged: (val) => setState(() {
                      _moneyLogType = val;
                      _loadData(5, isRefresh: true);
                    }),
                  ),
                  const SizedBox(width: 8),
                  _buildRebateFilterDropdown(
                    label: _getMoneyLogTypeName(_moneyLogMoneyTypeId),
                    options: {
                      null: '所有账变类型',
                      '9': '后台增加',
                      '10': '后台扣除',
                      '11': '反水',
                      '12': '升级赠送',
                      '13': '生日礼金',
                      '14': '周红包',
                      '15': '月红包',
                      '16': '流水佣金',
                      '17': '盈亏佣金',
                      '18': '全民返利',
                    },
                    value: _moneyLogMoneyTypeId,
                    onChanged: (val) => setState(() {
                      _moneyLogMoneyTypeId = val;
                      _loadData(5, isRefresh: true);
                    }),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getMoneyLogTypeName(String? id) {
    if (id == null) return '所有账变类型';
    switch (id) {
      case '9': return '后台增加';
      case '10': return '后台扣除';
      case '11': return '反水';
      case '12': return '升级赠送';
      case '13': return '生日礼金';
      case '14': return '周红包';
      case '15': return '月红包';
      case '16': return '流水佣金';
      case '17': return '盈亏佣金';
      case '18': return '全民返利';
      default: return '未知类型';
    }
  }

  Widget _buildRebateFilterDropdown<T>({
    required String label,
    required Map<T, String> options,
    required T value,
    required Function(T) onChanged,
  }) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.getInputFillColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value != null ? AppTheme.primary : Colors.transparent,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: value != null
                  ? AppTheme.primary
                  : AppTheme.getTextSecondary(context),
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: value != null
                ? AppTheme.primary
                : AppTheme.getTextSecondary(context),
          ),
          items: options.entries.map((e) {
            return DropdownMenuItem<T>(
              value: e.key,
              child: Text(e.value, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null || (val == null && value != null)) {
              onChanged(val as T);
            }
          },
          dropdownColor: AppTheme.getCardColor(context),
          style: TextStyle(
            color: value != null
                ? AppTheme.primary
                : AppTheme.getTextPrimary(context),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String type) {
    final isActive = _activeQuickDate == type && _selectedDateRange == null;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isActive,
        onSelected: (selected) {
          if (selected) _applyQuickDate(type);
        },
        backgroundColor: AppTheme.getInputFillColor(context),
        selectedColor: AppTheme.primary.withAlpha(25),
        labelStyle: TextStyle(
          color: isActive
              ? AppTheme.primary
              : AppTheme.getTextSecondary(context),
          fontSize: 13,
        ),
        side: BorderSide(
          color: isActive ? AppTheme.primary : Colors.transparent,
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.isDark(context)
                ? ColorScheme.dark(
                    primary: AppTheme.primary,
                    onPrimary: Colors.white,
                    surface: AppTheme.getCardColor(context),
                    onSurface: AppTheme.getTextPrimary(context),
                  )
                : ColorScheme.light(
                    primary: AppTheme.primary,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      setState(() {
        _selectedDateRange = range;
        _activeQuickDate = '';
      });
      _loadData(_tabController.index, isRefresh: true);
    }
  }

  Widget _buildRecordList(int index) {
    final records = _records[index]!;
    final isLoading = _isLoading[index]!;
    final error = _error[index];
    final hasMore = _hasMore[index]!;

    if (isLoading && records.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && records.isEmpty) {
      return ErrorStateWidget(
        message: error,
        onRetry: () => _loadData(index, isRefresh: true),
      );
    }

    if (records.isEmpty) {
      return const EmptyStateWidget(message: '暂无记录');
    }

    // 按日期分组
    final groupedRecords = _groupRecordsByDate(records);
    final dates = groupedRecords.keys.toList();

    return RefreshIndicator(
      onRefresh: () => _loadData(index, isRefresh: true),
      child: ListView.builder(
        controller: _scrollControllers[index],
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: dates.length + (hasMore ? 1 : 0),
        itemBuilder: (context, dateIndex) {
          if (dateIndex == dates.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final date = dates[dateIndex];
          final items = groupedRecords[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _formatGroupDate(date),
                  style: TextStyle(
                    color: AppTheme.getTextSecondary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...items.map((item) => _buildRecordItem(index, item)),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Map<String, List<dynamic>> _groupRecordsByDate(List<dynamic> records) {
    final Map<String, List<dynamic>> grouped = {};
    for (final record in records) {
      String? dateStr;
      if (record is TradeRecord) dateStr = record.createdAt;
      if (record is TransferRecord) dateStr = record.createdAt;
      if (record is RebateRecord) dateStr = record.createdAt;
      if (record is BettingRecord) dateStr = record.betTime;
      if (record is MoneyLog) dateStr = record.createdAt;

      if (dateStr != null) {
        final date = dateStr.split(' ')[0];
        if (!grouped.containsKey(date)) {
          grouped[date] = [];
        }
        grouped[date]!.add(record);
      }
    }
    return grouped;
  }

  String _formatGroupDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return '今日';
    if (date == yesterday) return '昨日';

    return DateFormat('MM月dd日').format(date);
  }

  String _getBetCategoryName(String? code) {
    switch (code) {
      case 'live':
        return '真人';
      case 'game':
        return '电子';
      case 'sport':
        return '体育';
      case 'chess':
        return '棋牌';
      case 'lottery':
        return '彩票';
      case 'fish':
        return '捕鱼';
      default:
        return code ?? '游戏';
    }
  }

  String _formatAmount(double value) {
    if (value == 0) return '0.00';
    String str = value.toStringAsFixed(4);
    str = str.replaceAll(RegExp(r'0*$'), '');
    if (str.endsWith('.')) {
      str += '00';
    } else if (str.contains('.') && str.split('.').last.length == 1) {
      str += '0';
    }
    return str;
  }

  Widget _buildRecordItem(int index, dynamic item) {
    String title = '';
    String subtitle = '';
    String amount = '';
    Color amountColor = AppTheme.getTextPrimary(context);
    String status = '';
    Color statusColor = AppTheme.getTextSecondary(context);
    String? orderNo;

    if (item is TradeRecord) {
      title = item.title ?? (index == 0 ? '充值' : '提现');
      subtitle = item.createdAt?.split(' ')[1] ?? '';
      final money = double.tryParse(item.money?.toString() ?? '0') ?? 0;
      amount = '${index == 0 ? '+' : '-'}¥${money.toStringAsFixed(2)}';
      amountColor = index == 0 ? AppTheme.success : AppTheme.error;
      orderNo = item.order ?? item.orderNo ?? item.rowid;

      switch (item.status) {
        case 1:
          status = '成功';
          statusColor = AppTheme.success;
          break;
        case 0:
          status = '失败';
          statusColor = AppTheme.error;
          break;
        case 5:
          status = '处理中';
          statusColor = AppTheme.warning;
          break;
        default:
          status = '处理中';
          statusColor = AppTheme.warning;
      }
    } else if (item is TransferRecord) {
      title = item.interfaceTitle ?? '平台转账';
      subtitle = item.createdAt?.split(' ')[1] ?? '';
      final money = double.tryParse(item.money?.toString() ?? '0') ?? 0;
      amount = '${item.type == 1 ? '+' : '-'}¥${money.toStringAsFixed(2)}';
      amountColor = item.type == 1 ? AppTheme.success : AppTheme.error;
      orderNo = item.order;

      switch (item.status) {
        case 1:
          status = '成功';
          statusColor = AppTheme.success;
          break;
        case 0:
          status = '失败';
          statusColor = AppTheme.error;
          break;
        default:
          status = '处理中';
          statusColor = AppTheme.warning;
      }
    } else if (item is MoneyLog) {
      final noteStr = item.note?.toString() ?? '';
      final remarkStr = item.remark?.toString() ?? '';
      
      if (noteStr.isNotEmpty && noteStr != 'null') {
        title = noteStr;
      } else if (remarkStr.isNotEmpty && remarkStr != 'null') {
        title = remarkStr;
      } else {
        title = '资金流水';
      }
      
      final String createdAtStr = item.createdAt?.toString() ?? '';
      final timeStr = createdAtStr.contains(' ') ? createdAtStr.split(' ')[1] : createdAtStr;
      
      final beforeMoneyVal = double.tryParse(item.beforeMoney?.toString() ?? item.before?.toString() ?? '0') ?? 0;
      final afterMoneyVal = double.tryParse(item.afterMoney?.toString() ?? item.after?.toString() ?? '0') ?? 0;
       
      subtitle = '$timeStr | 变前: ¥${_formatAmount(beforeMoneyVal)} | 变后: ¥${_formatAmount(afterMoneyVal)}';
      
      final money = double.tryParse(item.money?.toString() ?? '0') ?? 0;
      amount = '${money >= 0 ? '+' : ''}¥${_formatAmount(money)}';
      amountColor = money >= 0 ? AppTheme.success : AppTheme.error;
      
      final typeName = _getMoneyLogTypeName(item.moneyTypeId?.toString());
      status = typeName != '所有账变类型' ? typeName : (item.typeName?.toString() ?? item.type?.toString() ?? '账变');
      
      final orderStr = item.order?.toString() ?? item.rowid?.toString();
      orderNo = (orderStr != null && orderStr.isNotEmpty && orderStr != 'null') ? orderStr : null;
    } else if (item is RebateRecord) {
      final name = item.apiCodeTitle ?? item.apiCode ?? item.code ?? '返水';
      title = '返水 - $name';
      
      final moneyVal = double.tryParse(item.money?.toString() ?? '0') ?? 0;
      subtitle = '${item.createdAt?.split(' ')[1] ?? ''} | 投注: ¥${_formatAmount(moneyVal)} | 比例: ${item.bl}%';
      
      final fsMoney = double.tryParse(item.fsMoney?.toString() ?? '0') ?? 0;
      amount = '+¥${_formatAmount(fsMoney)}';
      amountColor = AppTheme.success;

      switch (item.status) {
        case 1:
          status = '已领取';
          statusColor = AppTheme.success;
          break;
        case 0:
          status = '未领取';
          statusColor = AppTheme.warning;
          break;
        default:
          status = '未知';
          statusColor = AppTheme.getTextSecondary(context);
      }
    } else if (item is BettingRecord) {
      final categoryName = item.interfaceTitle ?? _getBetCategoryName(item.code);
      final subTitle = item.gameName ?? item.title ?? '未知游戏';
      title = '$categoryName - $subTitle';
      subtitle = item.betTime?.split(' ')[1] ?? '';

      final netAmount = double.tryParse(item.netAmount.toString()) ?? 0;
      final betAmount = double.tryParse(item.betAmount.toString()) ?? 0;

      amount = '${netAmount >= 0 ? '+' : ''}¥${netAmount.toStringAsFixed(2)}';
      amountColor = netAmount > 0
          ? AppTheme.success
          : (netAmount < 0 ? AppTheme.error : AppTheme.getTextPrimary(context));

      status = '投注: ¥${betAmount.toStringAsFixed(2)}';
      orderNo = item.rowid;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onLongPress: orderNo != null ? () => _copyOrder(orderNo!) : null,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppTheme.getTextPrimary(context),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppTheme.getTertiaryTextColor(context),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: TextStyle(
                        color: amountColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status,
                      style: TextStyle(color: statusColor, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            if (orderNo != null) ...[
              const SizedBox(height: 8),
              const Divider(height: 1, color: AppTheme.divider),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '订单号: $orderNo',
                      style: const TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _copyOrder(orderNo!),
                    child: const Text(
                      '复制',
                      style: TextStyle(color: AppTheme.primary, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _copyOrder(String orderNo) {
    Clipboard.setData(ClipboardData(text: orderNo));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('订单号已复制'), duration: Duration(seconds: 1)),
    );
  }
}
