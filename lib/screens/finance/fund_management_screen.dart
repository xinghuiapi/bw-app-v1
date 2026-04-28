import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_nav_bar.dart';
import '../../widgets/custom_card.dart';

class FundManagementScreen extends StatefulWidget {
  const FundManagementScreen({super.key});

  @override
  State<FundManagementScreen> createState() => _FundManagementScreenState();
}

class _FundManagementScreenState extends State<FundManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDateRange = '本月';
  final List<String> _dateRanges = ['今天', '昨日', '本月', '上月'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      appBar: const CustomNavBar(title: '资金管理'),
      body: Column(
        children: [
          _buildDateFilter(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDepositTab(),
                _buildWithdrawTab(), // using similar to deposit for now, or maybe they have different mock data
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
                '04-01 ~ 04-25',
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
        decoration: const BoxDecoration(
          color: AppColors.surface,
          // Removed border radius and shadow to match the screenshot more closely (no card around tabbar in screenshots, wait, actually in screenshot 1 it seems it's flat on the background)
          // Let's check screenshot 1 again. The TabBar has a white background, no visible rounded corners or margin, it spans full width of its container. Wait, in my skeleton I said it's wrapped in a Container. Let's make it flat.
        ),
        // Wait, the DateFilter card has margin. The TabBar in the screenshot is edge-to-edge white or has margins?
        // Looking at the screenshot, the TabBar is full width (no horizontal margin) or very small. Wait, there's a slight gap on left/right. It seems it has no margin, it's just a white block.
        child: TabBar(
          controller: _tabController,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent, // 移除 TabBar 下方的默认黑线/灰线
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 14.sp),
          tabs: const [
            Tab(text: '充值记录', height: 44),
            Tab(text: '提现记录', height: 44),
            Tab(text: '转账记录', height: 44),
            Tab(text: '账户明细', height: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildDepositTab() {
    return _buildListWithFooter([
      _buildRecordItem(
        title: 'USDT-TRC20',
        status: '处理中',
        statusColor: AppColors.warning,
        amount: '¥ 100.00',
        orderNo: '202604222227551776868075',
        time: '2026-04-22 22:27:55',
      ),
    ]);
  }

  Widget _buildWithdrawTab() {
    return _buildListWithFooter([
      _buildRecordItem(
        title: '银行卡提现',
        status: '处理中',
        statusColor: AppColors.warning,
        amount: '¥ 500.00',
        orderNo: '202604222227551776868076',
        time: '2026-04-22 23:10:00',
      ),
    ]);
  }

  Widget _buildTransferTab() {
    return _buildListWithFooter([
      _buildRecordItem(
        title: 'AGS 转入',
        status: '成功',
        statusColor: AppColors.success,
        amount: '¥ 10,100.00',
        orderNo: '202604232242301776955350',
        time: '2026-04-23 22:42:30',
      ),
      _buildRecordItem(
        title: 'FB 转出',
        status: '成功',
        statusColor: AppColors.success,
        amount: '¥ 10,100.00',
        orderNo: '202604232242291776955349',
        time: '2026-04-23 22:42:29',
      ),
      _buildRecordItem(
        title: 'FB 转入',
        status: '成功',
        statusColor: AppColors.success,
        amount: '¥ 10,100.00',
        orderNo: '202604232242131776955333',
        time: '2026-04-23 22:42:13',
      ),
      _buildRecordItem(
        title: 'KYTY 转出',
        status: '成功',
        statusColor: AppColors.success,
        amount: '¥ 10,100.00',
        orderNo: '202604232242121776955332',
        time: '2026-04-23 22:42:12',
      ),
    ]);
  }

  Widget _buildAccountTab() {
    return _buildListWithFooter([
      _buildAccountItem(
        title: '周红包',
        subtitle: '每周红包到账了！',
        amount: '¥ 3.00',
        balance: '¥ 8.00',
        time: '2026-04-18 23:48:16',
        isNegative: false,
      ),
      _buildAccountItem(
        title: '生日礼金',
        subtitle: '今天您生日了，祝您生日快乐',
        amount: '¥ 5.00',
        balance: '¥ 5.00',
        time: '2026-04-18 23:48:16',
        isNegative: false,
      ),
      _buildAccountItem(
        title: '后台扣除',
        subtitle: '1',
        amount: '¥ -10,000.00',
        balance: '¥ 112.00',
        time: '2026-04-12 18:02:13',
        isNegative: true,
      ),
      _buildAccountItem(
        title: '后台扣除',
        subtitle: '1',
        amount: '¥ -1,000.00',
        balance: '¥ 10,112.00',
        time: '2026-04-12 18:01:30',
        isNegative: true,
      ),
    ]);
  }

  Widget _buildListWithFooter(List<Widget> items) {
    return ListView(
      padding: EdgeInsets.only(bottom: 32.h),
      children: [
        ...items,
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Center(
            child: Text(
              '没有更多了',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordItem({
    required String title,
    required String status,
    required Color statusColor,
    required String amount,
    required String orderNo,
    required String time,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '订单号：$orderNo',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            time,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountItem({
    required String title,
    required String subtitle,
    required String amount,
    required String balance,
    required String time,
    required bool isNegative,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isNegative ? AppColors.danger : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '余额：$balance',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
