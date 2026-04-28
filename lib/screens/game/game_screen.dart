import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_images.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'lottery', 'name': '彩票'},
    {'id': 'live', 'name': '视讯'},
    {'id': 'game', 'name': '电子'},
    {'id': 'fishing', 'name': '捕鱼'},
    {'id': 'sport', 'name': '体育'},
    {'id': 'poker', 'name': '棋牌'},
    {'id': 'esports', 'name': '电竞'},
  ];

  final List<Map<String, dynamic>> _games = [
    {
      'title': 'PA视讯',
      'image': AppImages.zr,
      'maintaining': false,
      'loading': false
    },
    {
      'title': 'PA视讯',
      'image': AppImages.zr,
      'maintaining': false,
      'loading': false
    },
    {
      'title': 'BBIN视讯',
      'image': AppImages.zr,
      'maintaining': false,
      'loading': false
    },
    {
      'title': 'DG视讯',
      'image': AppImages.zr,
      'maintaining': false,
      'loading': false
    },
    {
      'title': '欧博视讯',
      'image': AppImages.zr,
      'maintaining': true,
      'loading': false
    },
    {
      'title': 'DB视讯',
      'image': AppImages.zr,
      'maintaining': false,
      'loading': false
    },
    {
      'title': '完美视讯',
      'image': AppImages.zr,
      'maintaining': false,
      'loading': false
    },
    {
      'title': 'SEXY视讯',
      'image': AppImages.zr,
      'maintaining': false,
      'loading': true
    },
    {
      'title': 'BG视讯',
      'image': AppImages.zr,
      'maintaining': false,
      'loading': false
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: _categories.length, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _categories.map((cat) {
                  return _buildGameGrid();
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  AppImages.hero, // placeholder for logo
                  width: 28.w,
                  height: 28.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '星汇演示',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      height: 1.1,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.9,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'xh-bet.com',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Icon(Icons.search, size: 24.sp, color: const Color(0xFF333333)),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3.h,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal),
        tabs: _categories.map((cat) {
          return Tab(text: cat['name'] as String);
        }).toList(),
      ),
    );
  }

  Widget _buildGameGrid() {
    return GridView.builder(
      padding:
          EdgeInsets.only(left: 12.w, right: 12.w, top: 12.h, bottom: 24.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12.w,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.72, // Adjust to fit cover and title nicely
      ),
      itemCount: _games.length,
      itemBuilder: (context, index) {
        final game = _games[index];
        final isMaintaining = game['maintaining'] as bool;
        final isLoading = game['loading'] as bool;

        return GestureDetector(
          onTap: () {
            if (isMaintaining || isLoading) return;
            // Simulated game entry or sublist
            context.push('/game-sub');
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.r),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          game['image'] as String,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                        if (isMaintaining)
                          Container(
                            color: Colors.black.withValues(alpha: 0.45),
                            alignment: Alignment.center,
                            child: Text(
                              '维护中',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (isLoading && !isMaintaining)
                          Container(
                            color: Colors.black.withValues(alpha: 0.45),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 24.w,
                                  height: 24.w,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  '加载中...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  alignment: Alignment.center,
                  child: Text(
                    game['title'] as String,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF1F1F1F),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
