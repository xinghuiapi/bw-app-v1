import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_nav_bar.dart';
import '../../widgets/custom_card.dart';

class GameManagementScreen extends StatefulWidget {
  const GameManagementScreen({super.key});

  @override
  State<GameManagementScreen> createState() => _GameManagementScreenState();
}

class _GameManagementScreenState extends State<GameManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDateRange = '本月';
  final List<String> _dateRanges = ['今天', '昨日', '本月', '上月'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      borderRadius: 16.r,
      hasShadow: true,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '查询日期',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '04-01 ~ 04-30',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Wrap(
            spacing: 8.w,
            children: _dateRanges.map((range) {
              final isSelected = _selectedDateRange == range;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDateRange = range;
                  });
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    range,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
          dividerColor: Colors.transparent, // 移除 TabBar 下方的默认黑线/灰线
          labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 16.sp),
          tabs: const [
            Tab(text: '返水记录', height: 44),
            Tab(text: '游戏记录', height: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildRebateTab() {
    return Column(
      children: [
        _buildRebateSummary(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 16.h),
            itemCount: 3, // Mock data
            itemBuilder: (context, index) {
              return _buildRebateItem();
            },
          ),
        ),
        _buildRebateBottomBar(),
      ],
    );
  }

  Widget _buildRebateSummary() {
    return CustomCard(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.symmetric(vertical: 20.h),
      borderRadius: 16.r,
      hasShadow: true,
      child: Row(
        children: [
          Expanded(child: _buildSummaryItem('总返水', '¥ 0.00')),
          _buildVerticalDivider(),
          Expanded(child: _buildSummaryItem('已领取', '¥ 0.00')),
          _buildVerticalDivider(),
          Expanded(child: _buildSummaryItem('未领取', '¥ 0.00')),
        ],
      ),
    );
  }

  Widget _buildRebateItem() {
    return CustomCard(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      borderRadius: 16.r,
      hasShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'game',
                  style: TextStyle(color: AppColors.primary, fontSize: 10.sp),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '2026-04-10 01:23',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '待领取',
                  style: TextStyle(color: AppColors.primary, fontSize: 12.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'PG电子 · 0.25%',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                  child: _buildRecordItem('返水', '¥ 0.00', alignCenter: true)),
              Expanded(
                  child: _buildRecordItem('有效', '¥ 0.20', alignCenter: true)),
              Expanded(
                  child: _buildRecordItem('盈亏', '¥ 0.00', alignCenter: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRebateBottomBar() {
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
                Text(
                  '可领取',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  '¥ 0.00',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              ),
              child: Text(
                '领取返水',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameRecordTab() {
    return Column(
      children: [
        _buildGameRecordSummary(),
        Expanded(
          child: ListView.builder(
            itemCount: 3, // Mock data
            itemBuilder: (context, index) {
              return _buildGameRecordItem();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameRecordSummary() {
    return CustomCard(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.symmetric(vertical: 20.h),
      borderRadius: 16.r,
      hasShadow: true,
      child: Row(
        children: [
          Expanded(child: _buildSummaryItem('注单笔数', '6')),
          _buildVerticalDivider(),
          Expanded(child: _buildSummaryItem('投注金额', '¥ 0.80')),
          _buildVerticalDivider(),
          Expanded(child: _buildSummaryItem('有效金额', '¥ 0.80')),
          _buildVerticalDivider(),
          Expanded(
              child: _buildSummaryItem('盈亏', '¥ -0.40',
                  valueColor: AppColors.danger)),
        ],
      ),
    );
  }

  Widget _buildGameRecordItem() {
    return CustomCard(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      borderRadius: 16.r,
      hasShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'game',
                  style: TextStyle(color: AppColors.primary, fontSize: 10.sp),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '2026-04-08 17:42',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '已结算',
                  style: TextStyle(color: AppColors.primary, fontSize: 12.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'PG电子 · 麻将胡了',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                  child: _buildRecordItem('总统计', '¥ 0.20', alignCenter: true)),
              Expanded(
                  child: _buildRecordItem('总有效', '¥ 0.20', alignCenter: true)),
              Expanded(
                  child: _buildRecordItem('总盈亏', '¥ -0.20',
                      valueColor: AppColors.danger, alignCenter: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, {Color? valueColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
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
        Text(
          title,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 30.h,
      color: AppColors.border,
    );
  }
}
