import 'package:flutter/material.dart';
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
      context.read<GameProvider>().loadRecommendedGames();
    });
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
                      _buildDomainBadge(siteConfig),
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
              final banner = banners.where((item) {
                final image = item.img?.trim();
                return image != null && image.isNotEmpty;
              }).firstOrNull;

              if (banner == null) return _buildFallbackBanner();

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

  void _handleDownloadTap(SiteConfig? siteConfig) {
    final downloadUrl = (siteConfig?.appDownload?.trim().isNotEmpty ?? false)
        ? siteConfig!.appDownload!.trim()
        : siteConfig?.apkDownload?.trim();
    if (downloadUrl == null || downloadUrl.isEmpty) return;
    debugPrint('[app-download] link tapped: $downloadUrl');
  }

  void _handleBannerTap(BannerModel banner) {
    final openUrl = banner.openUrl?.trim();
    if (banner.open != 1 || openUrl == null || openUrl.isEmpty) return;

    final uri = Uri.tryParse(openUrl);
    if (uri == null) return;

    if (uri.scheme == 'http' || uri.scheme == 'https') {
      debugPrint('[home-banner] external link tapped: $openUrl');
      return;
    }
    context.push(openUrl.startsWith('/') ? openUrl : '/$openUrl');
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
    final isWideScreen = MediaQuery.sizeOf(context).width >= 600;
    final mainCardHeight = isWideScreen ? 360.0 : 180.h;
    final rightCardPadding = isWideScreen
        ? EdgeInsets.symmetric(horizontal: 12.w, vertical: 8)
        : EdgeInsets.all(12.w);
    final smallCardHeight = isWideScreen ? 112.0 : 80.h;
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: mainCardHeight,
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: isWideScreen ? 10 : 12.h,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                  height: mainCardHeight,
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
                                  padding: rightCardPadding,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
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
                                  padding: rightCardPadding,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
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
              _buildSmallGameCard('体育赛事', AppImages.ty, smallCardHeight),
              SizedBox(width: 10.w),
              _buildSmallGameCard('捕鱼游戏', AppImages.by, smallCardHeight),
              SizedBox(width: 10.w),
              _buildSmallGameCard('棋牌游戏', AppImages.qp, smallCardHeight),
              SizedBox(width: 10.w),
              _buildSmallGameCard('电竞游戏', AppImages.dj, smallCardHeight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallGameCard(String title, String image, double height) {
    return Expanded(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: Image.asset(image, width: 40.w, height: 40.w)),
            SizedBox(height: 4.h.clamp(2.0, 4.0)),
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
    final gameProvider = context.watch<GameProvider>();
    final remoteGames = gameProvider.recommendedGames;
    final hasRemoteData = remoteGames.isNotEmpty;

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
            _buildRecoGameList(remoteGames, hasRemoteData: hasRemoteData),
        ],
      ),
    );
  }

  Widget _buildRecoGameList(
    List<RecommendedGame> games, {
    required bool hasRemoteData,
  }) {
    final cardSize = _recoGameCardSize;
    return SizedBox(
      height: cardSize + 34,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: hasRemoteData
              ? games.map(_buildRemoteRecoGameCard).toList()
              : List.generate(
                  _fallbackRecoGameCount, _buildFallbackRecoGameCard),
        ),
      ),
    );
  }

  Widget _buildRemoteRecoGameCard(RecommendedGame game) {
    final isLaunching = context.select<GameProvider, bool>(
      (provider) => provider.launchingGameId == game.id,
    );
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
            Stack(
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
            SizedBox(height: 8.h),
            Text(
              game.title,
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF333333)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
          Container(
            width: cardSize,
            height: cardSize,
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
            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF333333)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
