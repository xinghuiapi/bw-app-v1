import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../theme/app_images.dart';
import '../widgets/custom_tab_bar.dart';
import '../widgets/notice_bar.dart';
import '../widgets/app_download_bar.dart';
import '../screens/game/game_screen.dart';
import 'main/main_screens.dart';
import 'user/user_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _showDownloadBar = true;
  bool _showBalance = true;
  bool _isLoggedIn = true; // Mock state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeBody(),
          const GameScreen(),
          const ActivityScreen(),
          const ServiceScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomTabBar(
        currentIndex: _currentIndex,
        onChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          CustomTabBarItem(
            label: '首页',
            icon: Icon(Icons.home_outlined, size: 24.sp),
            activeIcon: Icon(Icons.home, size: 24.sp, color: AppColors.primary),
          ),
          CustomTabBarItem(
            label: '游戏大厅',
            icon: Icon(Icons.videogame_asset_outlined, size: 24.sp),
            activeIcon: Icon(Icons.videogame_asset,
                size: 24.sp, color: AppColors.primary),
          ),
          CustomTabBarItem(
            label: '活动',
            icon: Icon(Icons.card_giftcard_outlined, size: 24.sp),
            activeIcon: Icon(Icons.card_giftcard,
                size: 24.sp, color: AppColors.primary),
          ),
          CustomTabBarItem(
            label: '客服',
            icon: Icon(Icons.headset_mic_outlined, size: 24.sp),
            activeIcon:
                Icon(Icons.headset_mic, size: 24.sp, color: AppColors.primary),
          ),
          CustomTabBarItem(
            label: '我的',
            icon: Icon(Icons.person_outline, size: 24.sp),
            activeIcon:
                Icon(Icons.person, size: 24.sp, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBody() {
    return Column(
      children: [
        if (_showDownloadBar)
          SafeArea(
            bottom: false,
            child: AppDownloadBar(
              title: 'Flutter UI 应用',
              description: '体验极致原生性能',
              buttonText: '立即下载',
              logo: SvgPicture.asset(AppIcons.vite, width: 36.w, height: 36.w),
              onDownload: () {},
              onClose: () {
                setState(() {
                  _showDownloadBar = false;
                });
              },
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Column(
              children: [
                _buildTopBannerSection(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Column(
                    children: [
                      SizedBox(height: 12.h),
                      NoticeBar(
                        text: '欢迎体验基于 Flutter 构建的全新 UI，极致性能、多端支持！',
                        leftIcon: const Icon(Icons.volume_up_outlined),
                        backgroundColor: Colors.white,
                        color: AppColors.primary,
                      ),
                      _buildUserActionCard(),
                      _buildGameLobby(),
                      _buildRecoGamesSection(),
                      _buildHotGamesSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBannerSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE4EFFF), Color(0xFFF4F6F9)],
        ),
      ),
      padding: EdgeInsets.only(
        top:
            _showDownloadBar ? 12.h : MediaQuery.of(context).padding.top + 12.h,
        left: 12.w,
        right: 12.w,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(AppIcons.vite, width: 32.w, height: 32.w),
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.shield_outlined,
                            size: 14.sp, color: const Color(0xFFF80000)),
                        SizedBox(width: 4.w),
                        Text(
                          'flutter.dev',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFFF80000),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.language,
                        size: 16.sp, color: AppColors.primary),
                  ),
                  SizedBox(width: 6.w),
                  GestureDetector(
                    onTap: () => context.push('/search'),
                    child: Icon(Icons.search,
                        size: 20.sp, color: const Color(0xFF333333)),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            height: 140.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              image: const DecorationImage(
                image: AssetImage(AppImages.aft5),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserActionCard() {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: _isLoggedIn
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'flutter_user',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF333333),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBCC3D4),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              'VIP 1',
                              style: TextStyle(
                                  fontSize: 10.sp, color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _showBalance = !_showBalance),
                            child: Icon(
                              _showBalance
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 16.sp,
                              color: const Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Text(
                            '¥',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          Text(
                            _showBalance ? '8,888.00' : '***',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.refresh,
                              size: 16.sp, color: const Color(0xFF999999)),
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '欢迎来到 Flutter UI',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333333),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => context.push('/login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              minimumSize: Size(60.w, 28.h),
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r)),
                            ),
                            child: Text('登录',
                                style: TextStyle(
                                    fontSize: 12.sp, color: Colors.white)),
                          ),
                          SizedBox(width: 8.w),
                          OutlinedButton(
                            onPressed: () => context.push('/register'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              minimumSize: Size(60.w, 28.h),
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r)),
                            ),
                            child:
                                Text('注册', style: TextStyle(fontSize: 12.sp)),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: const Color(0xFFEEEEEE),
            margin: EdgeInsets.symmetric(horizontal: 10.w),
          ),
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildActionItem(Icons.monetization_on_outlined, '充值',
                      true, () => context.push('/deposit')),
                ),
                Expanded(
                  child: _buildActionItem(Icons.account_balance_wallet_outlined,
                      '提现', false, () => context.push('/withdraw')),
                ),
                Expanded(
                  child: _buildActionItem(Icons.headset_mic_outlined, '客服',
                      false, () => context.push('/service')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
      IconData icon, String text, bool highlight, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: highlight ? AppColors.primary : const Color(0xFF666666),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGameLobby() {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 180.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.02),
                          blurRadius: 8,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16.r)),
                            image: const DecorationImage(
                              image: AssetImage(AppImages.zr),
                              fit: BoxFit.cover,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    width: 5.w,
                                    height: 18.h,
                                    decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius:
                                            BorderRadius.circular(4.r))),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text('真人视讯',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF333333))),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text('沉浸式体验',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF666666))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: SizedBox(
                  height: 180.h,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(12.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                              width: 4.w,
                                              height: 14.h,
                                              decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.r))),
                                          SizedBox(width: 4.w),
                                          Expanded(
                                            child: Text('彩票游戏',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(
                                                        0xFF333333))),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h),
                                      Text('热门游戏',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              color: const Color(0xFF666666))),
                                    ],
                                  ),
                                ),
                              ),
                              Image.asset(AppImages.cp, width: 60.w),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(12.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                              width: 4.w,
                                              height: 14.h,
                                              decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.r))),
                                          SizedBox(width: 4.w),
                                          Expanded(
                                            child: Text('电子游戏',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(
                                                        0xFF333333))),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h),
                                      Text('千万奖池',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              color: const Color(0xFF666666))),
                                    ],
                                  ),
                                ),
                              ),
                              Image.asset(AppImages.dz, width: 60.w),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _buildSmallGameCard('体育赛事', AppImages.ty),
              SizedBox(width: 10.w),
              _buildSmallGameCard('捕鱼游戏', AppImages.by),
              SizedBox(width: 10.w),
              _buildSmallGameCard('棋牌游戏', AppImages.qp),
              SizedBox(width: 10.w),
              _buildSmallGameCard('电竞游戏', AppImages.dj),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallGameCard(String title, String image) {
    return Expanded(
      child: Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, width: 40.w, height: 40.w),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoGamesSection() {
    return Container(
      margin: EdgeInsets.only(top: 20.h),
      child: Column(
        children: [
          _buildSectionHeader('推荐游戏'),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(5, (index) {
                return Container(
                  width: 100.w,
                  margin: EdgeInsets.only(right: 12.w),
                  child: Column(
                    children: [
                      Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          image: const DecorationImage(
                            image: AssetImage(AppImages.dz),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '推荐游戏 ${index + 1}',
                        style: TextStyle(
                            fontSize: 13.sp, color: const Color(0xFF333333)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotGamesSection() {
    return Container(
      margin: EdgeInsets.only(top: 20.h),
      child: Column(
        children: [
          _buildSectionHeader('热门游戏'),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.8,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        image: const DecorationImage(
                          image: AssetImage(AppImages.by),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '热门游戏 ${index + 1}',
                    style: TextStyle(
                        fontSize: 13.sp, color: const Color(0xFF333333)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
          ],
        ),
        Text(
          '更多',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF999999),
          ),
        ),
      ],
    );
  }
}
