import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/finance_service.dart';
import '../../models/finance_models.dart';
import '../../widgets/common/state_widgets.dart';
import '../../theme/app_theme.dart';

class TransactionRecordsScreen extends ConsumerStatefulWidget {
  const TransactionRecordsScreen({super.key});

  @override
  ConsumerState<TransactionRecordsScreen> createState() => _TransactionRecordsScreenState();
}

class _TransactionRecordsScreenState extends ConsumerState<TransactionRecordsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['充值', '提现', '转账', '账变'];
  
  // 筛选相关
  String _activeQuickDate = 'today';
  DateTimeRange? _selectedDateRange;
  
  // 数据状态
  final Map<int, List<dynamic>> _records = {};
  final Map<int, int> _currentPage = {};
  final Map<int, bool> _isLoading = {};
  final Map<int, bool> _hasMore = {};
  final Map<int, String?> _error = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // 初始化各标签状态
    for (int i = 0; i < _tabs.length; i++) {
      _records[i] = [];
      _currentPage[i] = 1;
      _isLoading[i] = false;
      _hasMore[i] = true;
      _error[i] = null;
    }
    
    // 默认加载第一个标签
    _loadData(0);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    if (_records[_tabController.index]!.isEmpty && _hasMore[_tabController.index]!) {
      _loadData(_tabController.index);
    }
  }

  Future<void> _loadData(int index, {bool isRefresh = false}) async {
    if (_isLoading[index]!) return;

    setState(() {
      _isLoading[index] = true;
      if (isRefresh) {
        _currentPage[index] = 1;
        _records[index] = [];
        _hasMore[index] = true;
      }
      _error[index] = null;
    });

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
          response = await FinanceService.getTradeRecord(TradeRecordRequest(
            page: page,
            type: 'recharge',
            startDate: startDate,
            endDate: endDate,
          ));
          break;
        case 1: // 提现
          response = await FinanceService.getTradeRecord(TradeRecordRequest(
            page: page,
            type: 'drawing',
            startDate: startDate,
            endDate: endDate,
          ));
          break;
        case 2: // 转账
          response = await FinanceService.getTransferRecords(page: page);
          break;
        case 3: // 账变
          response = await FinanceService.getMoneyLogList(page: page);
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
        return DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));
      case 'week':
        return DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 7)));
      case 'month':
        return DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('往来记录'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(_tabs.length, (index) => _buildRecordList(index)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: AppTheme.surface,
      child: SingleChildScrollView(
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
              icon: const Icon(Icons.calendar_today, size: 20, color: AppTheme.textSecondary),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.cardBackground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
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
        backgroundColor: AppTheme.cardBackground,
        selectedColor: AppTheme.primary.withValues(alpha: 0.1),
        labelStyle: TextStyle(
          color: isActive ? AppTheme.primary : AppTheme.textSecondary,
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
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.surface,
              onSurface: AppTheme.textPrimary,
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
        padding: const EdgeInsets.all(16),
        itemCount: dates.length + (hasMore ? 1 : 0),
        itemBuilder: (context, dateIndex) {
          if (dateIndex == dates.length) {
            _loadData(index);
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
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
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

  Widget _buildRecordItem(int index, dynamic item) {
    String title = '';
    String subtitle = '';
    String amount = '';
    Color amountColor = AppTheme.textPrimary;
    String status = '';
    Color statusColor = AppTheme.textSecondary;
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
        case 2:
          status = '失败';
          statusColor = AppTheme.error;
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
      title = item.remark ?? '资金流水';
      subtitle = item.createdAt?.split(' ')[1] ?? '';
      final money = double.tryParse(item.money?.toString() ?? '0') ?? 0;
      amount = '${money >= 0 ? '+' : ''}¥${money.toStringAsFixed(2)}';
      amountColor = money >= 0 ? AppTheme.success : AppTheme.error;
      status = item.typeName ?? item.type ?? '账变';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
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
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
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
                      style: const TextStyle(color: AppTheme.textTertiary, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
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
