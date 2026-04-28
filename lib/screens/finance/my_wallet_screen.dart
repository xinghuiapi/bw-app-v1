import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_nav_bar.dart';
import '../../widgets/custom_card.dart';

class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({super.key});

  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  bool _isAutoTransfer = true;

  final List<Map<String, dynamic>> _venues = [
    {'name': 'PA接口', 'balance': '0.00'},
    {'name': 'DG视讯', 'balance': '0.00'},
    {'name': '乐游棋牌', 'balance': '0.00'},
    {'name': '沙巴体育', 'balance': '0.00'},
    {'name': '三晟体育', 'balance': '0.00'},
    {'name': '雷火电竞', 'balance': '0.00'},
    {'name': '百盛棋牌', 'balance': '0.00'},
    {'name': '欧博视讯', 'balance': '0.00'},
    {'name': 'FB体育', 'balance': '0.00'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(
        title: '我的钱包',
        rightIcon: Text(
          '转账记录',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        onClickRight: () {
          context.push('/fund-management'); // Route to transfer records
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildWalletCard(),
            _buildVenueModeCard(),
            _buildVenueListCard(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5A9AF5), Color(0xFF3A7AF0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A8AF4).withValues(alpha: 0.3),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '钱包余额',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.visibility_outlined,
                      color: Colors.white.withValues(alpha: 0.9), size: 18.sp),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // TODO: refresh logic
                },
                child: Row(
                  children: [
                    Icon(Icons.refresh,
                        color: Colors.white.withValues(alpha: 0.9), size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '刷新',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '¥ ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '10100.00',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/deposit'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.currency_yen,
                              color: Colors.white, size: 14.sp),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '充值',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1.w,
                  height: 20.h,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/withdraw'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.account_balance_wallet,
                              color: Colors.white, size: 14.sp),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '提现',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueModeCard() {
    return CustomCard(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTitleWithDot('场馆模式'),
              CupertinoSwitch(
                value: _isAutoTransfer,
                activeTrackColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _isAutoTransfer = value;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '默认开启自动转账模式（余额自动携带进入场馆，关闭后需手动转入/转出）',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueListCard() {
    return CustomCard(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTitleWithDot('场馆列表'),
              GestureDetector(
                onTap: () {
                  // TODO: One-click return
                },
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: AppColors.primary, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '资金一键归户',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1.6, // Adjusted for typical width/height ratio
            ),
            itemCount: _venues.length,
            itemBuilder: (context, index) {
              final venue = _venues[index];
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      venue['name'],
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¥ ${venue['balance']}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.refresh,
                            color: AppColors.primary, size: 14.sp),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitleWithDot(String title) {
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: const BoxDecoration(
            color: Color(0xFF90C2FF),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
