import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_app/services/finance_service.dart';
import 'package:my_flutter_app/models/finance_models.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/widgets/common/state_widgets.dart';

class CapitalRecordsScreen extends ConsumerStatefulWidget {
  const CapitalRecordsScreen({super.key});

  @override
  ConsumerState<CapitalRecordsScreen> createState() => _CapitalRecordsScreenState();
}

class _CapitalRecordsScreenState extends ConsumerState<CapitalRecordsScreen> {
  final List<MoneyLog> _records = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  // 筛选相关
  String _activeQuickDate = 'today';
  DateTimeRange? _selectedDateRange;
  int? _selectedType; // 账变类型

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool isRefresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (isRefresh) {
        _currentPage = 1;
        _records.clear();
        _hasMore = true;
      }
      _error = null;
    });

    try {
      String? startDate;
      String? endDate;
      final now = DateTime.now();
      
      if (_selectedDateRange != null) {
        startDate = DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start);
        endDate = DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end);
      } else {
        switch (_activeQuickDate) {
          case 'today':
            startDate = endDate = DateFormat('yyyy-MM-dd').format(now);
            break;
          case 'yesterday':
            startDate = endDate = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));
            break;
          case 'week':
            startDate = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 7)));
            endDate = DateFormat('yyyy-MM-dd').format(now);
            break;
          case 'month':
            startDate = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 30)));
            endDate = DateFormat('yyyy-MM-dd').format(now);
            break;
        }
      }

      final response = await FinanceService.getMoneyLogList(
        page: _currentPage,
        size: 20,
        startDate: startDate,
        endDate: endDate,
        type: _selectedType?.toString(),
      );

      if (mounted) {
        setState(() {
          if (response.code == 200) {
            final List<MoneyLog> newItems = response.data ?? [];
            if (newItems.isEmpty) {
              _hasMore = false;
            } else {
              _records.addAll(newItems);
              _currentPage++;
              if (newItems.length < 20) {
                _hasMore = false;
              }
            }
          } else {
            _error = response.msg ?? '加载失败';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        title: const Text('资金记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDrawer,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatistics(),
          Expanded(
            child: _buildRecordList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    // 这里可以添加统计信息，例如今日总账变等
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getDividerColor(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: '账变总额', value: '¥0.00', color: AppTheme.primary),
          _StatItem(label: '今日笔数', value: '0', color: AppTheme.secondary),
        ],
      ),
    );
  }

  Widget _buildRecordList() {
    if (_records.isEmpty) {
      if (_isLoading) return const LoadingStateWidget();
      if (_error != null) return ErrorStateWidget(message: _error!, onRetry: () => _loadData(isRefresh: true));
      return const EmptyStateWidget(message: '暂无资金记录');
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(isRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _records.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _records.length) {
            _loadData();
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildRecordCard(_records[index]);
        },
      ),
    );
  }

  Widget _buildRecordCard(MoneyLog record) {
    final amount = double.tryParse(record.money.toString()) ?? 0;
    final isPositive = amount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getDividerColor(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.typeName ?? '资金变动',
                style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${isPositive ? "+" : ""}¥${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isPositive ? AppTheme.success : AppTheme.error,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppTheme.getDividerColor(context), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('前余额', '¥${double.tryParse(record.beforeMoney.toString())?.toStringAsFixed(2) ?? "0.00"}'),
              _buildInfoItem('后余额', '¥${double.tryParse(record.afterMoney.toString())?.toStringAsFixed(2) ?? "0.00"}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.createdAt ?? '',
                style: TextStyle(color: AppTheme.getTextTertiary(context), fontSize: 12),
              ),
              Text(
                '单号: ${record.rowid ?? "---"}',
                style: TextStyle(color: AppTheme.getTextTertiary(context), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppTheme.getTextTertiary(context), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _showFilterDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.getCardColor(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('筛选', style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.close, color: AppTheme.getTextTertiary(context)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('快速时间选择', style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 14)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickDateOption('today', '今日', setModalState),
                      _buildQuickDateOption('yesterday', '昨日', setModalState),
                      _buildQuickDateOption('week', '近七日', setModalState),
                      _buildQuickDateOption('month', '近三十日', setModalState),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('自定义时间段', style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 14)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
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
                      if (picked != null) {
                        setModalState(() {
                          _selectedDateRange = picked;
                          _activeQuickDate = '';
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.getInputFillColor(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _selectedDateRange != null ? AppTheme.primary : AppTheme.getDividerColor(context)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDateRange == null
                                ? '请选择时间范围'
                                : '${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)}',
                            style: TextStyle(
                              color: _selectedDateRange == null ? AppTheme.getTextTertiary(context) : AppTheme.getTextPrimary(context),
                              fontSize: 14,
                            ),
                          ),
                          Icon(Icons.calendar_today, size: 16, color: AppTheme.getTextTertiary(context)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _loadData(isRefresh: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('应用筛选', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        setModalState(() {
                          _activeQuickDate = 'today';
                          _selectedDateRange = null;
                          _selectedType = null;
                        });
                        setState(() {
                          _activeQuickDate = 'today';
                          _selectedDateRange = null;
                          _selectedType = null;
                        });
                      },
                      child: const Text('重置筛选', style: TextStyle(color: AppTheme.textTertiary)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickDateOption(String value, String label, StateSetter setModalState) {
    final isActive = _activeQuickDate == value;
    return GestureDetector(
      onTap: () {
        setModalState(() {
          _activeQuickDate = value;
          _selectedDateRange = null;
        });
        setState(() {
          _activeQuickDate = value;
          _selectedDateRange = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary.withAlpha(25) : AppTheme.getInputFillColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppTheme.primary : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.primary : AppTheme.getTextSecondary(context),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 12)),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
