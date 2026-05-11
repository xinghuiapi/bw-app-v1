import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/game/game_models.dart';
import '../models/home/home_models.dart';
import '../providers/auth/auth_provider.dart';
import '../providers/game/game_provider.dart';
import '../providers/system/system_provider.dart';
import '../providers/user/user_provider.dart';
import '../providers/wallet/wallet_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_images.dart';
import '../widgets/common/app_network_image.dart';
import '../widgets/notice_bar.dart';
import '../widgets/app_download_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _fallbackNoticeText = '欢迎体验基于 Flutter 构建的全新 UI，极致性能、多端支持！';
  static const int _fallbackRecoGameCount = 5;

  bool _showDownloadBar = true;
  bool _showBalance = true;
  final PageController _bannerController = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  double get _recoGameCardSize {
    final scaled = 100.w;
    if (scaled < 86) return 86;
    if (scaled > 120) return 120;
    return scaled;
  }

  double get _recoGameCardGap {
    final scaled = 12.w;
    if (scaled < 8) return 8;
    if (scaled > 12) return 12;
    return scaled;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final gameProvider = context.read<GameProvider>();
      gameProvider.loadCategories();
      gameProvider.loadRecommendedGames();
      gameProvider.loadHotGames();
      _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted || !_bannerController.hasClients) return;
        final banners =
            _visibleBanners(context.read<SystemProvider>().config.banners);
        if (banners.length <= 1) return;
        final next = (_bannerIndex + 1) % banners.length;
        _bannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: _buildHomeBody(),
    );
  }

  Widget _buildHomeBody() {
    return Column(
      children: [
        if (_showDownloadBar)
          SafeArea(
            bottom: false,
            child: Selector<SystemProvider, SiteConfig?>(
              selector: (_, provider) => provider.config.siteConfig,
              builder: (context, siteConfig, child) {
                return AppDownloadBar(
                  title:
                      _siteText(siteConfig?.title, fallback: 'Flutter UI 应用'),
                  description: _siteText(
                    siteConfig?.appDesc ?? siteConfig?.desc,
                    fallback: '体验极致原生性能',
                  ),
                  buttonText: '立即下载',
                  logo: _buildSiteIcon(siteConfig?.logo),
                  onDownload: () => _handleDownloadTap(siteConfig),
                  onClose: () {
                    setState(() {
                      _showDownloadBar = false;
                    });
                  },
                );
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
                      const SizedBox(height: 12),
                      Selector<SystemProvider, List<NoticeModel>>(
                        selector: (_, provider) => provider.config.notices,
                        builder: (context, notices, child) {
                          return NoticeBar(
                            text: _noticeText(notices),
                            leftIcon: const Icon(Icons.volume_up_outlined),
                            backgroundColor: Colors.white,
                            color: AppColors.primary,
                          );
                        },
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
              Selector<SystemProvider, SiteConfig?>(
                selector: (_, provider) => provider.config.siteConfig,
                builder: (context, siteConfig, child) {
                  return _buildSiteBrand(siteConfig);
                },
              ),
              Selector<SystemProvider, SiteConfig?>(
                selector: (_, provider) => provider.config.siteConfig,
                builder: (context, siteConfig, child) {
                  return Row(
                    children: [
                      GestureDetector(
                        onTap: () => _copySafeDomain(siteConfig),
                        child: _buildDomainBadge(siteConfig),
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
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Selector<SystemProvider, List<BannerModel>>(
            selector: (_, provider) => provider.config.banners,
            builder: (context, banners, child) {
              final visibleBanners = _visibleBanners(banners);
              if (visibleBanners.isEmpty) return _buildFallbackBanner();
              return _buildBannerCarousel(visibleBanners);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      height: 140.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        image: const DecorationImage(
          image: AssetImage(AppImages.aft5),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  List<BannerModel> _visibleBanners(List<BannerModel> banners) {
    return banners.where((item) {
      final image = item.img?.trim();
      if (image == null || image.isEmpty) return false;
      final terminal = item.terminal ?? 2;
      if (terminal != 2) return false;
      if (item.languages.isEmpty) return true;
      return item.languages.contains('CN');
    }).toList();
  }

  Widget _buildBannerCarousel(List<BannerModel> banners) {
    final count = banners.length;
    return SizedBox(
      height: 140.h,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            itemCount: count,
            onPageChanged: (index) => setState(() => _bannerIndex = index),
            itemBuilder: (context, index) {
              final banner = banners[index];
              return GestureDetector(
                onTap: () => _handleBannerTap(banner),
                child: AppNetworkImage(
                  url: banner.img,
                  width: double.infinity,
                  height: 140.h,
                  borderRadius: BorderRadius.circular(12.r),
                  errorWidget: _buildFallbackBanner(),
                ),
              );
            },
          ),
          if (count > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 8.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(count, (index) {
                  final selected = index == _bannerIndex % count;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: selected ? 14.w : 6.w,
                    height: 6.h,
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSiteBrand(SiteConfig? siteConfig) {
    return Row(
      children: [
        _buildSiteLogo(siteConfig?.logo, size: 28.w, circular: true),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _siteText(siteConfig?.title, fallback: '星汇演示'),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Transform.scale(
              scale: 0.9,
              alignment: Alignment.centerLeft,
              child: Text(
                _siteText(siteConfig?.domain, fallback: 'xh-bet.com'),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF333333),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDomainBadge(SiteConfig? siteConfig) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
            _siteText(siteConfig?.domain, fallback: 'flutter.dev'),
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFFF80000),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteLogo(
    String? logoUrl, {
    required double size,
    bool circular = false,
  }) {
    final fallback = SizedBox(width: size, height: size);
    if (logoUrl == null || logoUrl.trim().isEmpty) return fallback;

    return AppNetworkImage(
      url: logoUrl,
      width: size,
      height: size,
      borderRadius: circular
          ? BorderRadius.circular(size / 2)
          : BorderRadius.circular(8.r),
      errorWidget: fallback,
    );
  }

  Widget _buildSiteIcon(String? iconUrl) {
    if (iconUrl == null || iconUrl.trim().isEmpty) {
      return SizedBox(width: 36.w, height: 36.w);
    }
    return AppNetworkImage(
      url: iconUrl,
      width: 36.w,
      height: 36.w,
      borderRadius: BorderRadius.circular(8.r),
      errorWidget: SizedBox(width: 36.w, height: 36.w),
    );
  }

  String _siteText(String? value, {required String fallback}) {
    final text = value?.trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  String _amountText(dynamic value, {required String fallback}) {
    if (value == null) return fallback;
    final amount = num.tryParse(value.toString());
    if (amount == null) return value.toString();
    return amount.toStringAsFixed(2);
  }

  Future<void> _handleDownloadTap(SiteConfig? siteConfig) async {
    final downloadUrl = (siteConfig?.appDownload?.trim().isNotEmpty ?? false)
        ? siteConfig!.appDownload!.trim()
        : siteConfig?.apkDownload?.trim();
    if (downloadUrl == null || downloadUrl.isEmpty) return;
    await _openUrl(downloadUrl);
  }

  Future<void> _handleBannerTap(BannerModel banner) async {
    final openUrl = banner.openUrl?.trim();
    if (openUrl == null || openUrl.isEmpty) return;

    final uri = Uri.tryParse(openUrl);
    if (uri == null) return;

    if (uri.scheme == 'http' || uri.scheme == 'https') {
      await _openUrl(openUrl, external: banner.open == 1);
      return;
    }
    context.push(openUrl.startsWith('/') ? openUrl : '/$openUrl');
  }

  Future<void> _openUrl(String url, {bool external = false}) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return;
    final opened = await launchUrl(
      uri,
      mode: external
          ? LaunchMode.externalApplication
          : LaunchMode.platformDefault,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法打开链接')),
      );
    }
  }

  String _noticeText(List<NoticeModel> notices) {
    final text = notices
        .map((notice) => _stripHtml(notice.content ?? notice.title ?? ''))
        .where((content) => content.isNotEmpty)
        .join('   |   ');
    return text.isEmpty ? _fallbackNoticeText : text;
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '').trim();
  }

  Widget _buildUserActionCard() {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    final isLoggedIn = authProvider.isAuthenticated;
    final username = _siteText(
      profile?.nickname ?? profile?.username,
      fallback: '会员用户',
    );
    final vipText = profile?.displayVipLevel ?? 'VIP0';
    final symbol = _siteText(profile?.symbol, fallback: '¥');
    final balance = _amountText(profile?.balance, fallback: '0.00');

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
            child: isLoggedIn
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              username,
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
                              vipText,
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
                            symbol,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          Text(
                            _showBalance ? balance : '***',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: _refreshAccount,
                            child: Icon(Icons.refresh,
                                size: 16.sp, color: const Color(0xFF999999)),
                          ),
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

  Future<void> _copySafeDomain(SiteConfig? siteConfig) async {
    final domain = siteConfig?.domain?.trim();
    if (domain == null || domain.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: domain));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制安全域名')),
    );
  }

  Future<void> _refreshAccount() async {
    if (!context.read<AuthProvider>().isAuthenticated) return;
    await Future.wait([
      context
          .read<UserProvider>()
          .loadProfile(refresh: true)
          .catchError((_) {}),
      context
          .read<WalletProvider>()
          .loadRealtimeBalance(refresh: true)
          .catchError((_) {}),
    ]);
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
    final categories = context.watch<GameProvider>().categories;
    final live = _homeCategory(categories, 'live', '真人视讯');
    final lottery = _homeCategory(categories, 'lottery', '彩票游戏');
    final game = _homeCategory(categories, 'game', '电子游戏');
    final sport = _homeCategory(categories, 'sport', '体育赛事');
    final fishing = _homeCategory(categories, 'fishing', '捕鱼游戏');
    final poker = _homeCategory(categories, 'poker', '棋牌游戏');
    final esports = _homeCategory(categories, 'esports', '电竞游戏');
    final largeImageHeight = 148.h;
    final largeTextHeight = 92.h;
    final largeCardHeight = largeImageHeight + largeTextHeight;
    final mediumCardHeight = (largeCardHeight - 10.h) / 2;
    final smallCardHeight = 86.h;
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildLargeCategoryCard(
                  live,
                  height: largeCardHeight,
                  imageHeight: largeImageHeight,
                  image: AppImages.zr,
                  englishTitle: 'Live',
                  description: '异国美女荷官沉浸式体验\n在线真人互动',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: SizedBox(
                  height: largeCardHeight,
                  child: Column(
                    children: [
                      _buildMediumCategoryCard(
                        lottery,
                        height: mediumCardHeight,
                        image: AppImages.cp,
                        englishTitle: 'Lottery',
                        description: '正宗彩种应有尽有，提供各类热门彩票',
                      ),
                      SizedBox(height: 10.h),
                      _buildMediumCategoryCard(
                        game,
                        height: mediumCardHeight,
                        image: AppImages.dz,
                        englishTitle: 'Slot',
                        description: '百万奖池\n一触即发',
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
              _buildSmallGameCard(sport, AppImages.ty, smallCardHeight),
              SizedBox(width: 10.w),
              _buildSmallGameCard(fishing, AppImages.by, smallCardHeight),
              SizedBox(width: 10.w),
              _buildSmallGameCard(poker, AppImages.qp, smallCardHeight),
              SizedBox(width: 10.w),
              _buildSmallGameCard(esports, AppImages.dj, smallCardHeight),
            ],
          ),
        ],
      ),
    );
  }

  GameLobbyCategory _homeCategory(
    List<GameLobbyCategory> categories,
    String code,
    String fallbackTitle,
  ) {
    return categories.firstWhere(
      (item) => item.code == code,
      orElse: () => GameLobbyCategory(id: 0, title: fallbackTitle, code: code),
    );
  }

  void _openGameCategory(GameLobbyCategory category) {
    final code = category.code.trim();
    if (code.isEmpty) return;
    context.go('/game?code=${Uri.encodeQueryComponent(code)}');
  }

  Widget _buildLargeCategoryCard(
    GameLobbyCategory category, {
    required double height,
    required double imageHeight,
    required String image,
    required String englishTitle,
    required String description,
  }) {
    return GestureDetector(
      onTap: () => _openGameCategory(category),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.02),
              blurRadius: 8,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              height: imageHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
            SizedBox(
              height: height - imageHeight,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 4.h,
                    child: Text(
                      englishTitle,
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFFC8DCFF).withValues(alpha: 0.4),
                        letterSpacing: 2,
                        height: 1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 6.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCategoryTitle(
                          _shortCategoryTitle(category.title),
                          fontSize: 18.sp,
                          centered: true,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF666666),
                            height: 1.18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediumCategoryCard(
    GameLobbyCategory category, {
    required double height,
    required String image,
    required String englishTitle,
    required String description,
  }) {
    return GestureDetector(
      onTap: () => _openGameCategory(category),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.02),
              blurRadius: 8,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 12.w,
                    child: Text(
                      englishTitle,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFFC8DCFF).withValues(alpha: 0.4),
                        height: 1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 8.h, 8.w, 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCategoryTitle(
                          _shortCategoryTitle(category.title),
                          fontSize: 17.sp,
                          lineWidth: 4.w,
                          lineHeight: 16.h,
                        ),
                        SizedBox(height: 6.h),
                        Flexible(
                          child: Text(
                            description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: const Color(0xFF666666),
                              height: 1.12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 70.w,
              height: double.infinity,
              child: Align(
                alignment: Alignment.centerRight,
                child: Image.asset(image, width: 70.w, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTitle(
    String title, {
    required double fontSize,
    double? lineWidth,
    double? lineHeight,
    bool centered = false,
  }) {
    return Row(
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      mainAxisSize: centered ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Container(
          width: lineWidth ?? 5.w,
          height: lineHeight ?? 18.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF333333),
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  String _shortCategoryTitle(String title) {
    return title
        .replaceAll('真人视讯', '视讯')
        .replaceAll('彩票游戏', '彩票')
        .replaceAll('电子游戏', '电子')
        .replaceAll('体育赛事', '体育')
        .replaceAll('捕鱼游戏', '捕鱼')
        .replaceAll('棋牌游戏', '棋牌')
        .replaceAll('电竞游戏', '电竞');
  }

  Widget _buildSmallGameCard(
      GameLobbyCategory category, String image, double height) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _openGameCategory(category),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Image.asset(
                  image,
                  width: 52.w,
                  height: 52.w,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 3.h.clamp(1.0, 3.0)),
              SizedBox(
                height: 18.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    _shortCategoryTitle(category.title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecoGamesSection() {
    final gameProvider = context.watch<GameProvider>();
    final remoteGames = gameProvider.recommendedGames;
    final hasRemoteData = remoteGames.isNotEmpty;
    final launchingGameId = gameProvider.launchingGameId;

    return Container(
      margin: EdgeInsets.only(top: 20.h),
      child: Column(
        children: [
          _buildSectionHeader('推荐游戏', onMoreTap: () => context.go('/game')),
          SizedBox(height: 12.h),
          if (gameProvider.isRecommendedLoading && !hasRemoteData)
            SizedBox(
              height: 128.h,
              child: const Center(child: CircularProgressIndicator()),
            )
          else
            _buildRecoGameList(
              remoteGames,
              hasRemoteData: hasRemoteData,
              launchingGameId: launchingGameId,
            ),
        ],
      ),
    );
  }

  Widget _buildRecoGameList(
    List<RecommendedGame> games, {
    required bool hasRemoteData,
    required int? launchingGameId,
  }) {
    final cardSize = _recoGameCardSize;
    return SizedBox(
      height: cardSize + 58,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: hasRemoteData
              ? games
                  .map((game) => _buildRemoteRecoGameCard(
                        game,
                        isLaunching: launchingGameId == game.id,
                      ))
                  .toList()
              : List.generate(
                  _fallbackRecoGameCount, _buildFallbackRecoGameCard),
        ),
      ),
    );
  }

  Widget _buildRemoteRecoGameCard(
    RecommendedGame game, {
    required bool isLaunching,
  }) {
    final cardSize = _recoGameCardSize;

    return GestureDetector(
      onTap: () {
        if (game.isMaintaining || isLaunching) return;
        if (game.opensSubList) {
          _openRecommendedSubList(game);
          return;
        }
        _launchRecommendedGame(game.launchTarget);
      },
      child: Container(
        width: cardSize,
        margin: EdgeInsets.only(right: _recoGameCardGap),
        child: Column(
          children: [
            SizedBox(
              width: cardSize,
              height: cardSize,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: AppNetworkImage(
                      url: game.img ?? '',
                      width: cardSize,
                      height: cardSize,
                      errorWidget: Image.asset(
                        AppImages.dz,
                        width: cardSize,
                        height: cardSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (game.isMaintaining)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '维护中',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (isLaunching)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.48),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              '启动中...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 22,
              child: Center(
                child: Text(
                  game.title,
                  style: TextStyle(
                      fontSize: 13.sp, color: const Color(0xFF333333)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openRecommendedSubList(RecommendedGame game) {
    final code = game.subListCode.trim();
    final gameCode = game.subListGame.trim();
    if (code.isEmpty || gameCode.isEmpty) return;
    context.push(
      '/game-sub?code=${Uri.encodeQueryComponent(code)}&game=${Uri.encodeQueryComponent(gameCode)}&title=${Uri.encodeQueryComponent(game.title)}',
    );
  }

  Future<void> _launchRecommendedGame(GameLaunchTarget target) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!context.read<AuthProvider>().isAuthenticated) {
      context.push('/login');
      return;
    }

    try {
      final result = await context.read<GameProvider>().launchGame(target);
      if (!mounted) return;
      final urlText = result.url?.trim();
      if (urlText == null || urlText.isEmpty) {
        messenger.showSnackBar(const SnackBar(content: Text('进入游戏失败')));
        return;
      }
      final uri = Uri.tryParse(urlText);
      if (uri == null) {
        messenger.showSnackBar(const SnackBar(content: Text('游戏地址无效')));
        return;
      }
      if (result.nesting == false) {
        final opened =
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!opened && mounted) {
          messenger.showSnackBar(const SnackBar(content: Text('无法打开游戏')));
        }
        return;
      }
      context.push('/game-view', extra: {
        'url': urlText,
        'title': target.title,
      });
    } catch (error) {
      if (!mounted) return;
      final message = context.read<GameProvider>().launchError;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            message?.trim().isNotEmpty == true ? message! : '进入游戏失败',
          ),
        ),
      );
    }
  }

  Widget _buildFallbackRecoGameCard(int index) {
    final cardSize = _recoGameCardSize;
    return Container(
      width: cardSize,
      margin: EdgeInsets.only(right: _recoGameCardGap),
      child: Column(
        children: [
          SizedBox(
            width: cardSize,
            height: cardSize,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                image: const DecorationImage(
                  image: AssetImage(AppImages.dz),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 22,
            child: Center(
              child: Text(
                '推荐游戏 ${index + 1}',
                style:
                    TextStyle(fontSize: 13.sp, color: const Color(0xFF333333)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotGamesSection() {
    final gameProvider = context.watch<GameProvider>();
    final hotGames = gameProvider.hotGames;
    final hasRemoteData = hotGames.isNotEmpty;
    final launchingGameId = gameProvider.launchingGameId;

    return Container(
      margin: EdgeInsets.only(top: 20.h),
      child: Column(
        children: [
          _buildSectionHeader('热门游戏', onMoreTap: () => context.go('/game')),
          SizedBox(height: 12.h),
          if (gameProvider.isHotGamesLoading && !hasRemoteData)
            SizedBox(
              height: 180.h,
              child: const Center(child: CircularProgressIndicator()),
            )
          else
            _buildHotGameGrid(
              hotGames,
              hasRemoteData: hasRemoteData,
              launchingGameId: launchingGameId,
            ),
        ],
      ),
    );
  }

  Widget _buildHotGameGrid(
    List<GameItem> games, {
    required bool hasRemoteData,
    required int? launchingGameId,
  }) {
    final itemCount = hasRemoteData ? games.length : 6;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.8,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (!hasRemoteData) return _buildFallbackHotGameCard(index);
        final game = games[index];
        return _buildRemoteHotGameCard(
          game,
          isLaunching: launchingGameId == game.id,
        );
      },
    );
  }

  Widget _buildRemoteHotGameCard(
    GameItem game, {
    required bool isLaunching,
  }) {
    return GestureDetector(
      onTap: () {
        if (game.isMaintaining || isLaunching) return;
        _launchRecommendedGame(game.launchTarget);
      },
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: AppNetworkImage(
                    url: game.img ?? '',
                    width: double.infinity,
                    height: double.infinity,
                    errorWidget: _buildHotFallbackImage(),
                  ),
                ),
                if (game.isMaintaining) _buildGameMask('维护中'),
                if (isLaunching) _buildLaunchingMask(),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            game.title ?? '',
            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF333333)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackHotGameCard(int index) {
    return Column(
      children: [
        Expanded(child: _buildHotFallbackImage()),
        SizedBox(height: 8.h),
        Text(
          '热门游戏 ${index + 1}',
          style: TextStyle(fontSize: 13.sp, color: const Color(0xFF333333)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildHotFallbackImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: const DecorationImage(
          image: AssetImage(AppImages.by),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildGameMask(String text) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLaunchingMask() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.48),
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22.w,
              height: 22.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              '启动中...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onMoreTap}) {
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
        GestureDetector(
          onTap: onMoreTap,
          child: Text(
            '更多',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF999999),
            ),
          ),
        ),
      ],
    );
  }
}
