import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_nav_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_cell.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  int _selectedType = 0;
  int _selectedChannel = 0;
  int _selectedAmount = -1;
  final TextEditingController _amountController = TextEditingController();

  final List<Map<String, dynamic>> _depositTypes = [
    {'name': '微信支付', 'icon': Icons.wechat, 'color': Colors.green},
    {'name': '支付宝', 'icon': Icons.payments, 'color': Colors.blue},
    {'name': '银联支付', 'icon': Icons.credit_card, 'color': Colors.redAccent},
    {'name': '云闪付', 'icon': Icons.contactless, 'color': Colors.red},
    {'name': '京东支付', 'icon': Icons.shopping_cart, 'color': Colors.redAccent},
    {'name': 'USDT-T...', 'icon': Icons.currency_bitcoin, 'color': Colors.teal},
  ];

  final List<String> _channels = ['USDT-TRC20'];

  final List<int> _quickAmounts = [100, 300, 500, 1000, 5000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC), // 浅灰蓝背景
      appBar: CustomNavBar(
        title: '充值',
        rightIcon: Text(
          '充值记录',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.primary,
          ),
        ),
        onClickRight: () {
          // Navigation to deposit records
          context.push('/fund-records');
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('充值类型'),
            SizedBox(height: 12.h),
            _buildTypeGrid(),
            SizedBox(height: 24.h),
            _buildSectionHeader('充值通道'),
            SizedBox(height: 12.h),
            _buildChannelGrid(),
            SizedBox(height: 24.h),
            _buildSectionHeader('充值信息'),
            SizedBox(height: 12.h),
            _buildAmountInput(),
            SizedBox(height: 12.h),
            Text(
              '汇率: 6.5176',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12.h),
            _buildAmountGrid(),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
                onPressed: () {
                  context.push('/deposit-success');
                },
                child: Text(
                  '确认充值',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeGrid() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: List.generate(_depositTypes.length, (index) {
        final type = _depositTypes[index];
        final isSelected = _selectedType == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = index),
          child: Container(
            width: (1.sw - 32.w - 24.w) / 3 - 0.1, // 3列, 减0.1防止浮点误差导致换行
            height: 44.h,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(type['icon'], color: type['color'], size: 18.sp),
                      SizedBox(width: 4.w),
                      Text(
                        type['name'],
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.r),
                          bottomRight: Radius.circular(8.r),
                        ),
                      ),
                      child: Icon(Icons.check, color: Colors.white, size: 12.sp),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildChannelGrid() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: List.generate(_channels.length, (index) {
        final channel = _channels[index];
        final isSelected = _selectedChannel == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedChannel = index),
          child: Container(
            width: (1.sw - 32.w - 12.w) / 2 - 0.1, // 2列, 减0.1防止换行
            height: 44.h,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    channel,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.r),
                          bottomRight: Radius.circular(8.r),
                        ),
                      ),
                      child: Icon(Icons.check, color: Colors.white, size: 12.sp),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '¥',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '请输入金额',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _selectedAmount = -1; // 重新输入时取消快捷金额的选中状态
                });
              },
            ),
          ),
          Text(
            '不限',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountGrid() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: List.generate(_quickAmounts.length, (index) {
        final amount = _quickAmounts[index];
        final isSelected = _selectedAmount == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAmount = index;
              _amountController.text = amount.toString();
            });
          },
          child: Container(
            width: (1.sw - 32.w - 24.w) / 3 - 0.1, // 3列, 减0.1防止换行
            height: 44.h,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '¥$amount',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class DepositOrderDetailScreen extends StatelessWidget {
  const DepositOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '订单详情'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            CustomCard(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  Text(
                    '充值金额',
                    style: TextStyle(
                        fontSize: 14.sp, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '¥ 10,000.00',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  const Divider(color: Color(0xFFEEEEEE)),
                  SizedBox(height: 24.h),
                  _buildDetailRow('订单状态', '处理中',
                      valueColor: const Color(0xFFFF9B00)),
                  _buildDetailRow('订单编号', 'DP20240424102345'),
                  _buildDetailRow('充值方式', '银行卡转账'),
                  _buildDetailRow('创建时间', '2024-04-24 10:23:45'),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            CustomButton(
              text: '返回首页',
              onPressed: () => context.go('/'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: valueColor ?? AppColors.textPrimary,
              fontWeight:
                  valueColor != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class DepositPaySuccessScreen extends StatelessWidget {
  const DepositPaySuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomNavBar(title: '支付结果', showLeftArrow: false),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle,
                  color: const Color(0xFF00B578), size: 80.sp),
              SizedBox(height: 24.h),
              Text(
                '充值成功',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '资金已到达您的钱包账户',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 48.h),
              CustomButton(
                text: '查看钱包',
                onPressed: () => context.go('/'),
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: '继续充值',
                isPrimary: false,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  final double _availableBalance = 8888.00;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '提现'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                '提现到',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            CustomCard(
              padding: EdgeInsets.zero,
              child: CustomCell(
                title: '招商银行 (尾号 8888)',
                label: '2小时内到账',
                icon: Icon(Icons.account_balance,
                    color: Colors.redAccent, size: 24.sp),
                isLink: true,
                onTap: () {
                  // TODO: Select bank card
                },
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                '提现金额',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '¥',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              fontSize: 32.sp,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.3),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _amountController.text =
                              _availableBalance.toStringAsFixed(2);
                        },
                        child: Text(
                          '全部',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: AppColors.border, height: 16.h),
                  Text(
                    '可提现余额: ¥$_availableBalance',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ),
                  onPressed: () {
                    context.push('/withdraw-success');
                  },
                  child: Text(
                    '确认提现',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WithdrawSuccessScreen extends StatelessWidget {
  const WithdrawSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomNavBar(title: '提现申请已提交', showLeftArrow: false),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle,
                  color: const Color(0xFF00B578), size: 80.sp),
              SizedBox(height: 24.h),
              Text(
                '提现申请已提交',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '预计 2 小时内到账，请留意资金变动',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 48.h),
              CustomButton(
                text: '查看提现记录',
                onPressed: () => context.go('/'),
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: '返回首页',
                isPrimary: false,
                onPressed: () => context.go('/'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnlinePayDetailScreen extends StatelessWidget {
  const OnlinePayDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '在线支付'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 24.h),
            Text(
              '正在跳转至支付网关...',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionRecordScreen extends StatelessWidget {
  const TransactionRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> records = [
      {
        'title': '游戏结算',
        'date': '2023-10-24 14:30',
        'amount': '+150.00',
        'status': '已完成',
        'isPositive': true
      },
      {
        'title': '充值到账',
        'date': '2023-10-23 09:15',
        'amount': '+1000.00',
        'status': '已完成',
        'isPositive': true
      },
      {
        'title': '购买道具',
        'date': '2023-10-22 18:45',
        'amount': '-50.00',
        'status': '已完成',
        'isPositive': false
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '交易记录'),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return CustomCard(
            padding: EdgeInsets.all(16.w),
            margin: EdgeInsets.only(bottom: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record['title'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      record['date'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      record['amount'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: record['isPositive']
                            ? Colors.green
                            : Colors.redAccent,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      record['status'],
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
        },
      ),
    );
  }
}

class FundRecordScreen extends StatelessWidget {
  const FundRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> records = [
      {
        'title': '微信充值',
        'date': '2023-10-24 10:20',
        'amount': '500.00',
        'status': '充值成功',
        'type': 'deposit'
      },
      {
        'title': '银行卡提现',
        'date': '2023-10-21 16:40',
        'amount': '2000.00',
        'status': '处理中',
        'type': 'withdraw'
      },
      {
        'title': '支付宝充值',
        'date': '2023-10-20 11:10',
        'amount': '100.00',
        'status': '充值成功',
        'type': 'deposit'
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '充提记录'),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          final isDeposit = record['type'] == 'deposit';
          return CustomCard(
            padding: EdgeInsets.all(16.w),
            margin: EdgeInsets.only(bottom: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: (isDeposit ? Colors.blue : Colors.orange)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isDeposit ? Colors.blue : Colors.orange,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record['title'],
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          record['date'],
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isDeposit ? '+' : '-'}${record['amount']}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      record['status'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: record['status'] == '处理中'
                            ? Colors.orange
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
