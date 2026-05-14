import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../widgets/search_input.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Default selected is the middle one "热门游戏" (Hot Games)
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEmpty('game.allGames'.tr()),
                  _buildEmpty('game.noGame'.tr()),
                  _buildEmpty('game.favorites'.tr()),
                ],
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Icon(
                Icons.arrow_back_ios,
                size: 20.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: SearchInput(
              hintText: 'search.hint'.tr(),
              autoFocus: true,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              // Handle search
            },
            child: Text(
              'common.search'.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
        ),
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 3.h,
        dividerColor: Colors.transparent, // 移除下划线防溢出和高保真
        tabAlignment: TabAlignment.fill,
        tabs: [
          Tab(text: 'game.all'.tr()),
          Tab(text: 'game.hotGames'.tr()),
          Tab(text: 'game.favorites'.tr()),
        ],
      ),
    );
  }

  Widget _buildEmpty(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
      ),
    );
  }
}
