import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_images.dart';

class GameSubListScreen extends StatefulWidget {
  const GameSubListScreen({super.key});

  @override
  State<GameSubListScreen> createState() => _GameSubListScreenState();
}

class _GameSubListScreenState extends State<GameSubListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock Data: 根据截图提取的游戏列表
  final List<Map<String, dynamic>> _allGames = [
    {'id': '1', 'title': '赏金大对决', 'image': AppImages.dz, 'isFavorite': true},
    {'id': '2', 'title': '双囍临门', 'image': AppImages.aft5, 'isFavorite': false},
    {'id': '3', 'title': '赏金女王', 'image': AppImages.dz, 'isFavorite': false},
    {'id': '4', 'title': '赏金船长', 'image': AppImages.by, 'isFavorite': false},
    {'id': '5', 'title': '麻将胡了2', 'image': AppImages.qp, 'isFavorite': false},
    {'id': '6', 'title': '芝麻开门', 'image': AppImages.dz, 'isFavorite': false},
    {'id': '7', 'title': '宝石热潮', 'image': AppImages.ty, 'isFavorite': false},
    {'id': '8', 'title': '法老牌', 'image': AppImages.cp, 'isFavorite': false},
    {'id': '9', 'title': '海怪传说', 'image': AppImages.dz, 'isFavorite': false},
    {'id': '10', 'title': '天竺王朝', 'image': AppImages.aft5, 'isFavorite': false},
    {'id': '11', 'title': '格林赏金', 'image': AppImages.dj, 'isFavorite': false},
    {'id': '12', 'title': '银河宝藏', 'image': AppImages.dz, 'isFavorite': false},
    {'id': '13', 'title': '汉堡大亨', 'image': AppImages.dz, 'isFavorite': false},
    {'id': '14', 'title': '魔豆传奇', 'image': AppImages.dz, 'isFavorite': false},
    {'id': '15', 'title': '拳击玫瑰', 'image': AppImages.dz, 'isFavorite': false},
    {'id': '16', 'title': '狂暴少女', 'image': AppImages.dz, 'isFavorite': false},
  ];

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

  void _toggleFavorite(int index) {
    setState(() {
      _allGames[index]['isFavorite'] =
          !(_allGames[index]['isFavorite'] as bool);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // 贴合截图的淡灰色背景
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, // M3 取消滚动阴影
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.primary, size: 24.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'PG电子',
          style: TextStyle(
            color: const Color(0xFF1F1F1F),
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.primary, size: 24.sp),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGrid(_allGames),
                _buildGrid(
                    _allGames.where((g) => g['isFavorite'] as bool).toList(),
                    isFavoriteTab: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h, bottom: 8.h),
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r), // 截图中的大圆角
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3.h,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: const Color(0xFF333333),
        unselectedLabelColor: const Color(0xFF999999),
        labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal),
        dividerColor: Colors.transparent, // 去除 M3 默认底部分割线
        tabs: const [
          Tab(text: '全部'),
          Tab(text: '收藏'),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> games,
      {bool isFavoriteTab = false}) {
    if (games.isEmpty) {
      return Center(
        child: Text(
          '暂无收藏游戏',
          style: TextStyle(color: const Color(0xFF999999), fontSize: 14.sp),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 一行 4 个游戏
        mainAxisSpacing: 16.h, // 垂直间距较大
        crossAxisSpacing: 12.w, // 水平间距较小
        childAspectRatio: 0.65, // 适配：上图片(方形) + 下文字
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        final isFavorite = game['isFavorite'] as bool;
        // 需要从全局列表中找到真实索引，以确保在收藏 Tab 点击取消时能正确修改源数据
        final originalIndex =
            _allGames.indexWhere((g) => g['id'] == game['id']);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              // Expanded 约束图片容器高度，防止溢出
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.asset(
                      game['image'] as String,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // 右下角 PG 标识 (白底黑字)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.r),
                          bottomRight: Radius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'PG',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                  // 右上角心形收藏按钮
                  Positioned(
                    top: 6.h,
                    right: 6.w,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(originalIndex),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: isFavorite
                              ? AppColors.primary
                              : Colors.black.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              game['title'] as String,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF333333),
              ),
              maxLines: 1, // 防溢出：单行截断
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
