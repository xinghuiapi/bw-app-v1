import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_images.dart';
import '../../widgets/custom_nav_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_cell.dart';
import '../../widgets/custom_button.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      {
        'title': '首充送 100%',
        'desc': '新用户首次充值可获得高达100%返利',
        'image': AppImages.cp
      },
      {'title': '周末狂欢', 'desc': '周末登录即送免费抽奖机会', 'image': AppImages.dz},
      {'title': 'VIP 专属福利', 'desc': 'VIP等级越高，返水比例越高', 'image': AppImages.zr},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '活动中心', showLeftArrow: false),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final item = activities[index];
          return GestureDetector(
            onTap: () {
              context.push('/activity-detail');
            },
            child: CustomCard(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.only(bottom: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Container(
                  height: 120.h,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(8.r)),
                    image: DecorationImage(
                      image: AssetImage(item['image']!),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item['desc']!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }
}

class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(
        title: '活动详情',
        rightIcon: Text(
          '申请记录',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        onClickRight: () {
          context.push('/activity-record');
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 头部卡片
                  CustomCard(
                    padding: EdgeInsets.all(16.w),
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'shoudong',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(100.r),
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: Text(
                                '手动申请',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(100.r),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: Text(
                                '2倍',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          '长期活动',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // 活动说明卡片
                  CustomCard(
                    padding: EdgeInsets.all(16.w),
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.lightBlueAccent, Colors.blue],
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '活动说明',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          '展开/收起 一般规则',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.asset(
                            AppImages.by,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          '1.会员需每日通过点击【立即申请】按钮参与活动，未点击立即申请按钮视为自动放弃参与该活动；\n\n'
                          '2.符合活动条件的会员，【每日存款 投注...',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 底部按钮
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: CustomButton(
                text: '申请参与活动',
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '客服中心'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 40.h),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary, AppColors.background],
                  stops: [0.0, 1.0],
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.headset_mic, size: 64.sp, color: Colors.white),
                  SizedBox(height: 16.h),
                  Text(
                    '24小时在线为您服务',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            CustomCard(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
              child: Column(
                children: [
                  CustomCell(
                    title: '在线客服',
                    label: '随时为您解答疑问',
                    icon: Icon(Icons.chat_bubble_outline,
                        color: AppColors.primary, size: 24.sp),
                    isLink: true,
                    onTap: () {},
                  ),
                  CustomCell(
                    title: 'Telegram',
                    label: '@flutter_ui_service',
                    icon: Icon(Icons.telegram, color: Colors.blue, size: 24.sp),
                    isLink: true,
                    onTap: () {},
                  ),
                  CustomCell(
                    title: 'WhatsApp',
                    label: '+1 234 567 8900',
                    icon: Icon(Icons.wechat,
                        color: Colors.green, size: 24.sp), // Mock icon
                    isLink: true,
                    onTap: () {},
                  ),
                  CustomCell(
                    title: '意见反馈',
                    label: '提出您的宝贵建议',
                    icon: Icon(Icons.feedback_outlined,
                        color: Colors.orange, size: 24.sp),
                    isLink: true,
                    border: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityRecordScreen extends StatelessWidget {
  const ActivityRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '申请记录'),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          CustomCard(
            padding: EdgeInsets.all(16.w),
            margin: EdgeInsets.only(bottom: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'shoudong',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100.r),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Text(
                        '申请中',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '账号',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'xhdemo',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '时间',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '2026-03-24 01:24:58',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Center(
              child: Text(
                '没有更多了',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
