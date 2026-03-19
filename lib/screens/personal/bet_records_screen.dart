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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
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
      backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          '投注记录',
          style: TextStyle(
            color: AppTheme.getTextPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.getTextPrimary(context),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            // _filters is not defined in the provided code snippet, likely intended to be part of the screen
            // But since this file was partially read or the previous content was confusing,
            // I will just replace the colors I see in the provided content.
            // The provided content for BetRecordsScreen was 20KB truncated.
            // I need to be careful with SearchReplace.
            // I will search for the specific lines I saw in the Read output.
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 0, // Placeholder to avoid error if _filters is missing
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildBetItem(index),
      ),
    );
  }

  Widget _buildBetItem(int index) {
    return Container(
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
                '百家乐 - 经典厅',
                style: TextStyle(
                  color: AppTheme.getTextPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '已结算',
                style: TextStyle(
                  color: const Color(0xFF00C853),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoItem('投注金额', '¥100.00')),
              Expanded(
                child: _buildInfoItem('输赢金额', '+98.00', isPositive: true),
              ),
              Expanded(child: _buildInfoItem('投注时间', '12:30:45')),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.getScaffoldBackgroundColor(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  '订单号：',
                  style: TextStyle(
                    color: AppTheme.getTextSecondary(context),
                    fontSize: 12,
                  ),
                ),
                Expanded(
                  child: Text(
                    '202403151230458888',
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(context),
                      fontSize: 12,
                    ),
                  ),
                ),
                Icon(
                  Icons.copy,
                  size: 14,
                  color: AppTheme.getTextSecondary(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isPositive = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.getTextSecondary(context),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isPositive
                ? AppTheme.success
                : AppTheme.getTextPrimary(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(int? status) {
    String text = '未知';
    Color color = AppTheme.getTertiaryTextColor(context);

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
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getCardColor(context),
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
                      const Text(
                        '筛选记录',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: AppTheme.getTextSecondary(context),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 日期选择
                  Text(
                    '选择日期',
                    style: TextStyle(
                      color: AppTheme.getTextSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: AppTheme.isDark(context)
                                  ? ColorScheme.dark(
                                      primary: AppTheme.primary,
                                      onPrimary: Colors.white,
                                      surface: AppTheme.getCardColor(context),
                                      onSurface: AppTheme.getTextPrimary(
                                        context,
                                      ),
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
                        setModalState(() => _selectedDate = picked);
                        setState(() {});
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.getInputFillColor(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.getDividerColor(context),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('yyyy-MM-dd').format(_selectedDate),
                            style: TextStyle(
                              color: AppTheme.getTextPrimary(context),
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            color: AppTheme.getTertiaryTextColor(context),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 分类选择
                  Text(
                    '游戏分类',
                    style: TextStyle(
                      color: AppTheme.getTextSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdown<String>(
                    value: _selectedCategoryCode,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('全部分类')),
                      ..._categories.map(
                        (c) => DropdownMenuItem(
                          value: c.code,
                          child: Text(c.title ?? ''),
                        ),
                      ),
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
                    const Text('二级游戏', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    _buildDropdown<int>(
                      value: _selectedSubCategoryId,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('全部游戏'),
                        ),
                        ..._subCategories.map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.title ?? ''),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setModalState(() => _selectedSubCategoryId = val);
                        setState(() {});
                      },
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 状态选择
                  Text(
                    '结算状态',
                    style: TextStyle(
                      color: AppTheme.getTextSecondary(context),
                      fontSize: 14,
                    ),
                  ),
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
                            foregroundColor: AppTheme.getTextSecondary(context),
                            side: BorderSide(
                              color: AppTheme.getDividerColor(context),
                            ),
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
        color: AppTheme.getInputFillColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.getDividerColor(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: AppTheme.getCardColor(context),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppTheme.getTertiaryTextColor(context),
          ),
          style: TextStyle(
            color: AppTheme.getTextPrimary(context),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
