import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_app/models/betting_models.dart';
import 'package:my_flutter_app/services/game_service.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/widgets/common/state_widgets.dart';

class BetRecordsScreen extends ConsumerStatefulWidget {
  const BetRecordsScreen({super.key});

  @override
  ConsumerState<BetRecordsScreen> createState() => _BetRecordsScreenState();
}

class _BetRecordsScreenState extends ConsumerState<BetRecordsScreen> {
  // 筛选相关
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryCode;
  int? _selectedSubCategoryId;
  int? _selectedStatus;

  // 数据列表相关
  final List<BettingRecord> _records = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  // 统计相关
  dynamic _totalBetAmount = 0;
  dynamic _totalNetAmount = 0;
  int _totalCount = 0;

  // 分类数据
  List<BettingCategory> _categories = [];
  List<BettingCategory> _subCategories = [];
  bool _isLoadingCategories = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadData(isRefresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadData();
      }
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final response = await GameService.getPrimaryCategories();
      if (mounted && response.code == 200) {
        setState(() {
          _categories = response.data ?? [];
        });
      }
    } catch (e) {
      debugPrint('加载分类失败: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  Future<void> _loadSubCategories(String code) async {
    try {
      final response = await GameService.getSubCategories(code);
      if (mounted && response.code == 200) {
        setState(() {
          _subCategories = response.data ?? [];
        });
      }
    } catch (e) {
      debugPrint('加载二级分类失败: $e');
    }
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
      final response = await GameService.getBettingRecords(
        page: _currentPage,
        code: _selectedCategoryCode,
        apiCode: _selectedSubCategoryId,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        status: _selectedStatus,
      );

      if (mounted) {
        setState(() {
          if (response.code == 200) {
            final data = response.data;
            if (data != null) {
              final newItems = data.data ?? [];
              _records.addAll(newItems);
              _totalBetAmount = data.totalBetAmount ?? 0;
              _totalNetAmount = data.totalNetAmount ?? 0;
              _totalCount = data.total ?? 0;
              _currentPage++;
              _hasMore = newItems.length >= 10;
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('投注记录'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
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
            child: _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Row(
        children: [
          _buildStatItem('总投注', '¥${double.tryParse(_totalBetAmount.toString())?.toStringAsFixed(2) ?? _totalBetAmount}', AppTheme.primary),
          Container(width: 1, height: 40, color: Colors.white10),
          _buildStatItem(
            '总输赢', 
            '¥${double.tryParse(_totalNetAmount.toString())?.toStringAsFixed(2) ?? _totalNetAmount}', 
            (double.tryParse(_totalNetAmount.toString()) ?? 0) >= 0 ? AppTheme.success : AppTheme.error
          ),
          Container(width: 1, height: 40, color: Colors.white10),
          _buildStatItem('记录数', _totalCount.toString(), AppTheme.secondary),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value, 
            style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_records.isEmpty && _isLoading) {
      return const LoadingStateWidget();
    }

    if (_records.isEmpty && _error != null) {
      return ErrorStateWidget(
        message: _error!,
        onRetry: () => _loadData(isRefresh: true),
      );
    }

    if (_records.isEmpty) {
      return const EmptyStateWidget(message: '暂无投注记录');
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(isRefresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _records.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _records.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return _buildRecordCard(_records[index]);
        },
      ),
    );
  }

  String _getCategoryName(String? code) {
    if (code == null || code.isEmpty) return '全部';
    const Map<String, String> categoryMap = {
      'live': '真人',
      'sport': '体育',
      'lottery': '彩票',
      'game': '电子',
      'fishing': '捕鱼',
      'poker': '棋牌',
    };
    return categoryMap[code] ?? code;
  }

  Widget _buildRecordCard(BettingRecord record) {
    final netAmount = double.tryParse(record.netAmount.toString()) ?? 0;
    final isWin = netAmount > 0;
    
    // 组合标题: 仿照 Vue 逻辑 getCategoryName(record.code) - getSubCategoryName(record.api_code, record.interface_title)
    final categoryName = _getCategoryName(record.code);
    final subCategoryName = record.interfaceTitle != null && record.interfaceTitle!.isNotEmpty
        ? record.interfaceTitle
        : (record.title ?? '未知游戏');
    
    final displayTitle = "$categoryName - $subCategoryName";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  displayTitle,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(record.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoItem('投注金额', '¥${double.tryParse(record.betAmount.toString())?.toStringAsFixed(2) ?? record.betAmount}'),
              _buildInfoItem('有效投注', '¥${double.tryParse(record.validBetAmount.toString())?.toStringAsFixed(2) ?? record.validBetAmount}'),
              _buildInfoItem(
                '盈亏金额', 
                '${isWin ? "+" : ""}¥${double.tryParse(record.netAmount.toString())?.toStringAsFixed(2) ?? record.netAmount}',
                valueColor: isWin ? AppTheme.success : (netAmount < 0 ? AppTheme.error : AppTheme.textPrimary)
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.betTime ?? '',
                style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
              ),
              Text(
                '单号: ${record.rowid}',
                style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {Color? valueColor}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(int? status) {
    String text = '未知';
    Color color = AppTheme.textTertiary;

    switch (status) {
      case 1:
        text = '已结算';
        color = AppTheme.success;
        break;
      case 2:
        text = '未结算';
        color = AppTheme.warning;
        break;
      case 3:
        text = '已取消';
        color = AppTheme.error;
        break;
      case 4:
        text = '已回滚';
        color = AppTheme.info;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('筛选记录', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // 日期选择
                  const Text('选择日期', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
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
                      if (picked != null) {
                        setModalState(() => _selectedDate = picked);
                        setState(() {});
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('yyyy-MM-dd').format(_selectedDate),
                            style: const TextStyle(color: AppTheme.textPrimary),
                          ),
                          const Icon(Icons.calendar_today, color: AppTheme.textTertiary, size: 18),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 分类选择
                  const Text('游戏分类', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  const SizedBox(height: 8),
                  _buildDropdown<String>(
                    value: _selectedCategoryCode,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('全部分类')),
                      ..._categories.map((c) => DropdownMenuItem(value: c.code, child: Text(c.title ?? ''))),
                    ],
                    onChanged: (val) {
                      setModalState(() {
                        _selectedCategoryCode = val;
                        _selectedSubCategoryId = null;
                        _subCategories = [];
                      });
                      setState(() {});
                      if (val != null) {
                        _loadSubCategories(val).then((_) {
                          if (mounted) setModalState(() {});
                        });
                      }
                    },
                  ),
                  
                  if (_subCategories.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('二级游戏', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    const SizedBox(height: 8),
                    _buildDropdown<int>(
                      value: _selectedSubCategoryId,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('全部游戏')),
                        ..._subCategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.title ?? ''))),
                      ],
                      onChanged: (val) {
                        setModalState(() => _selectedSubCategoryId = val);
                        setState(() {});
                      },
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  // 状态选择
                  const Text('结算状态', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  const SizedBox(height: 8),
                  _buildDropdown<int>(
                    value: _selectedStatus,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('全部状态')),
                      DropdownMenuItem(value: 1, child: Text('已结算')),
                      DropdownMenuItem(value: 2, child: Text('未结算')),
                      DropdownMenuItem(value: 3, child: Text('已取消')),
                      DropdownMenuItem(value: 4, child: Text('已回滚')),
                    ],
                    onChanged: (val) {
                      setModalState(() => _selectedStatus = val);
                      setState(() {});
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedDate = DateTime.now();
                              _selectedCategoryCode = null;
                              _selectedSubCategoryId = null;
                              _selectedStatus = null;
                              _subCategories = [];
                            });
                            setState(() {});
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textSecondary,
                            side: const BorderSide(color: Colors.white10),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('重置'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _loadData(isRefresh: true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('确认'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: AppTheme.surface,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textTertiary),
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        ),
      ),
    );
  }
}
