import 'package:flutter/material.dart';
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
                  _buildEmpty('全部游戏'),
                  _buildGameGrid(),
                  _buildEmpty('我的收藏'),
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
              hintText: '搜索游戏、活动...',
              autoFocus: true,
            ),
          ),
          SizedBox(width: 16.w),
          GestureDetector(
            onTap: () {
              // Handle search
            },
            child: Text(
              '搜索',
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
        tabs: const [
          Tab(text: '全部'),
          Tab(text: '热门游戏'),
          Tab(text: '我的收藏'),
        ],
      ),
    );
  }

  Widget _buildGameGrid() {
    // Mock data based on screenshot
    final games = [
      {'name': '加拿大P...', 'image': 'https://picsum.photos/200?1', 'isFav': false},
      {'name': '加拿大28', 'image': 'https://picsum.photos/200?2', 'isFav': false},
      {'name': '澳门六...', 'image': 'https://picsum.photos/200?3', 'isFav': false},
      {'name': '香港六...', 'image': 'https://picsum.photos/200?4', 'isFav': false},
      {'name': 'DB体育', 'image': 'https://picsum.photos/200?5', 'isFav': false},
      {'name': '竞速11选5', 'image': 'https://picsum.photos/200?6', 'isFav': false},
      {'name': '澳门六...', 'image': 'https://picsum.photos/200?7', 'isFav': false},
      {'name': '极速六...', 'image': 'https://picsum.photos/200?8', 'isFav': false},
      {'name': '香港六...', 'image': 'https://picsum.photos/200?9', 'isFav': false},
      {'name': '百家乐', 'image': 'https://picsum.photos/200?10', 'isFav': false},
      {'name': '星际水...', 'image': 'https://picsum.photos/200?11', 'isFav': false},
      {'name': '超级牛...', 'image': 'https://picsum.photos/200?12', 'isFav': false},
      {'name': '大三元', 'image': 'https://picsum.photos/200?13', 'isFav': false},
      {'name': '星际水...', 'image': '', 'isFav': false}, // mock error image
      {'name': '超级牛...', 'image': '', 'isFav': false},
      {'name': '大三元', 'image': '', 'isFav': false},
      {'name': '赏金猎人', 'image': '', 'isFav': false},
      {'name': '赏金猎人', 'image': 'https://picsum.photos/200?18', 'isFav': false},
      {'name': '赏金大...', 'image': 'https://picsum.photos/200?19', 'isFav': true}, // blue heart
      {'name': '双喜临门', 'image': 'https://picsum.photos/200?20', 'isFav': false},
    ];

    return Container(
      color: AppColors.background,
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 0.72, // Adjust to prevent overflow and match screenshot
        ),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return _buildGameItem(
            game['name'] as String,
            game['image'] as String,
            game['isFav'] as bool,
          );
        },
      ),
    );
  }

  Widget _buildGameItem(String name, String image, bool isFavorite) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r), // Rounded rectangle like in the screenshot
                  color: Colors.white,
                ),
                clipBehavior: Clip.antiAlias,
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImagePlaceholder(),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(color: Colors.grey[200]);
                          },
                        )
                      : _buildImagePlaceholder(),
                ),
                Positioned(
                  top: 4.h,
                  right: 4.w,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: isFavorite
                          ? Colors.white
                          : Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 12.sp,
                      color: isFavorite ? AppColors.primary : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
        ),
        SizedBox(height: 8.h),
        Text(
          name,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 24.sp, color: Colors.grey[400]),
            SizedBox(height: 4.h),
            Text(
              '游戏',
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[400]),
            )
          ],
        ),
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
