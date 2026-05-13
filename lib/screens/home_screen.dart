import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/game/game_models.dart';
import '../models/home/home_models.dart';
import '../localization/app_language.dart';
import '../providers/localization/language_provider.dart';
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
  static const _noticeSuppressDateKey = 'm1_notice_suppress_date';
  static const int _fallbackRecoGameCount = 5;

  bool _showDownloadBar = true;
  bool _showBalance = true;
  bool _didTryOpenNotice = false;
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
        final banners = _visibleBanners(
          context.read<SystemProvider>().config.banners,
          context.read<LanguageProvider>().currentCode,
        );
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
    _scheduleNoticeModal();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: _buildHomeBody(),
    );
  }

  void _scheduleNoticeModal() {
    if (_didTryOpenNotice) return;
    final systemProvider = context.watch<SystemProvider>();
    if (!systemProvider.hasLoadedConfig) return;
    final notices = _popupNotices(systemProvider.config.notices);
    if (notices.isEmpty) return;
    _didTryOpenNotice = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showNoticeModalIfAllowed(notices);
    });
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
                  title: _siteText(siteConfig?.title,
                      fallback: 'home.appTitle'.tr()),
                  description: _siteText(
                    siteConfig?.appDesc ?? siteConfig?.desc,
                    fallback: 'home.appDescription'.tr(),
                  ),
                  buttonText: 'home.downloadNow'.tr(),
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
              Expanded(
                child: Selector<SystemProvider, SiteConfig?>(
                  selector: (_, provider) => provider.config.siteConfig,
                  builder: (context, siteConfig, child) {
                    return _buildSiteBrand(siteConfig);
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Selector<SystemProvider, SiteConfig?>(
                  selector: (_, provider) => provider.config.siteConfig,
                  builder: (context, siteConfig, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () => _copySafeDomain(siteConfig),
                            child: _buildDomainBadge(siteConfig),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: _showLanguageSheet,
                          child: _buildLanguageButton(),
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
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Selector<SystemProvider, List<BannerModel>>(
            selector: (_, provider) => provider.config.banners,
            builder: (context, banners, child) {
              final languageCode =
                  context.watch<LanguageProvider>().currentCode;
              final visibleBanners = _visibleBanners(banners, languageCode);
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD7E9FF), Color(0xFFF2F8FF)],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.primary.withValues(alpha: 0.5),
        size: 32.sp,
      ),
    );
  }

  List<BannerModel> _visibleBanners(
    List<BannerModel> banners,
    String languageCode,
  ) {
    return banners.where((item) {
      final image = item.img?.trim();
      if (image == null || image.isEmpty) return false;
      final terminal = item.terminal ?? 2;
      if (terminal != 2) return false;
      if (item.languages.isEmpty) return true;
      return item.languages.contains(languageCode);
    }).toList();
  }

  Widget _buildLanguageButton() {
    final languageCode = context.watch<LanguageProvider>().currentCode;
    final languages = context.watch<SystemProvider>().config.languages;
    final active = languages.where(
      (item) => (item.code ?? '').trim().toUpperCase() == languageCode,
    );
    final icon = active.isEmpty ? null : active.first.img?.trim();
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: icon == null || icon.isEmpty
          ? Icon(Icons.language, size: 16.sp, color: AppColors.primary)
          : AppNetworkImage(
              url: icon,
              width: 18.w,
              height: 18.w,
              fit: BoxFit.cover,
              errorWidget:
                  Icon(Icons.language, size: 16.sp, color: AppColors.primary),
            ),
    );
  }

  Future<void> _showLanguageSheet() async {
    final systemProvider = context.read<SystemProvider>();
    final languages = _availableLanguages(systemProvider.config.languages);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.sizeOf(context).height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(sheetContext).pop(),
                      child: Text(
                        'common.cancel'.tr(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: const Color(0xFF999999),
                        ),
                      ),
                    ),
                    Text(
                      'home.selectLanguage'.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    SizedBox(width: 30.w),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF5F6F8)),
              Expanded(
                child: ListView.separated(
                  itemCount: languages.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 56,
                    color: Color(0xFFF5F6F8),
                  ),
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    final code = AppLanguage.normalize(language.code);
                    final selected =
                        code == context.read<LanguageProvider>().currentCode;
                    return ListTile(
                      leading: _buildLanguageIcon(language.img),
                      title: Text(
                        language.title ?? code,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      trailing: selected
                          ? Icon(Icons.check,
                              color: AppColors.primary, size: 20.sp)
                          : null,
                      onTap: () async {
                        final rootContext = this.context;
                        final gameProvider = rootContext.read<GameProvider>();
                        final currentSystemProvider =
                            rootContext.read<SystemProvider>();
                        final currentLanguageProvider =
                            rootContext.read<LanguageProvider>();
                        Navigator.of(sheetContext).pop();
                        if (selected) return;
                        gameProvider.resetForLanguageChange();
                        await currentLanguageProvider.changeLanguage(
                          rootContext,
                          code,
                        );
                        if (!mounted) return;
                        await currentSystemProvider.loadConfig(refresh: true);
                        if (!mounted) return;
                        _didTryOpenNotice = false;
                        await Future.wait([
                          gameProvider.loadCategories(refresh: true),
                          gameProvider.loadRecommendedGames(refresh: true),
                          gameProvider.loadHotGames(refresh: true),
                        ]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<LanguageConfig> _availableLanguages(List<LanguageConfig> languages) {
    final normalized = languages
        .where((item) => (item.code ?? '').trim().isNotEmpty)
        .map(
          (item) => LanguageConfig(
            title: item.title,
            code: AppLanguage.normalize(item.code),
            img: item.img,
            requiredStatus: item.requiredStatus,
          ),
        )
        .toList();
    if (normalized.isNotEmpty) return normalized;
    return const [
      LanguageConfig(title: '中文简体', code: 'CN'),
      LanguageConfig(title: '繁體中文', code: 'TW'),
      LanguageConfig(title: 'English', code: 'EN'),
      LanguageConfig(title: '日本語', code: 'JP'),
      LanguageConfig(title: '한국어', code: 'KR'),
      LanguageConfig(title: 'ไทย', code: 'TH'),
      LanguageConfig(title: 'Tiếng Việt', code: 'VN'),
      LanguageConfig(title: 'မြန်မာ', code: 'MY'),
    ];
  }

  Widget _buildLanguageIcon(String? image) {
    final url = image?.trim();
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: 10.r,
        backgroundColor: const Color(0xFFE4EFFF),
        child: Icon(Icons.language, size: 14.sp, color: AppColors.primary),
      );
    }
    return ClipOval(
      child: AppNetworkImage(
        url: url,
        width: 20.w,
        height: 20.w,
        fit: BoxFit.cover,
        errorWidget: CircleAvatar(
          radius: 10.r,
          backgroundColor: const Color(0xFFE4EFFF),
          child: Icon(Icons.language, size: 14.sp, color: AppColors.primary),
        ),
      ),
    );
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _siteText(siteConfig?.title,
                    fallback: 'home.siteFallbackName'.tr()),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined,
              size: 14.sp, color: const Color(0xFFF80000)),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              _siteText(siteConfig?.domain, fallback: 'flutter.dev'),
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFFF80000),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
        SnackBar(content: Text('common.openLinkFailed'.tr())),
      );
    }
  }

  String _noticeText(List<NoticeModel> notices) {
    final text = notices
        .map((notice) => _stripHtml(notice.content ?? notice.title ?? ''))
        .where((content) => content.isNotEmpty)
        .join('   |   ');
    return text.isEmpty ? 'home.fallbackNotice'.tr() : text;
  }

  List<NoticeModel> _popupNotices(List<NoticeModel> notices) {
    final list = notices.where((notice) {
      if (notice.popUp != 1) return false;
      final terminal = notice.terminal ?? 1;
      if (terminal != 1 && terminal != 3) return false;
      final title = notice.title?.trim() ?? '';
      final content = notice.content?.trim() ?? '';
      return title.isNotEmpty || content.isNotEmpty;
    }).toList();
    list.sort((a, b) {
      final topCompare = (b.top ?? 0).compareTo(a.top ?? 0);
      if (topCompare != 0) return topCompare;
      return b.id.compareTo(a.id);
    });
    return list;
  }

  String _localYmd(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  Future<void> _showNoticeModalIfAllowed(List<NoticeModel> notices) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _localYmd(DateTime.now());
    if (prefs.getString(_noticeSuppressDateKey) == today) return;
    if (!mounted) return;
    final todayNoMore = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _NoticeDialog(notices: notices),
    );
    if (todayNoMore == true) {
      await prefs.setString(_noticeSuppressDateKey, today);
    } else {
      await prefs.remove(_noticeSuppressDateKey);
    }
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '')
        .trim();
  }

  Widget _buildUserActionCard() {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    final isLoggedIn = authProvider.isAuthenticated;
    final username = _siteText(
      profile?.nickname ?? profile?.username,
      fallback: 'home.memberUser'.tr(),
    );
    final vipText = profile?.displayVipLevel ?? 'VIP0';
    final symbol = _siteText(profile?.symbol, fallback: '¥');
    final balance = _amountText(profile?.balance, fallback: '0.00');

    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(10.w),
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
                ? SizedBox(
                    height: 46.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                username,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF333333),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Container(
                              height: 16.h,
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFBCC3D4),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                vipText,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  height: 1,
                                  color: Colors.white,
                                ),
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
                                size: 15.sp,
                                color: const Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Text(
                              symbol,
                              style: TextStyle(
                                fontSize: 14.sp,
                                height: 1,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF333333),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _showBalance ? balance : '***',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  height: 1,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: _refreshAccount,
                              child: Icon(Icons.refresh,
                                  size: 15.sp, color: const Color(0xFF999999)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'home.welcome'.tr(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333333),
                          height: 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Flexible(
                            child: _buildCompactAuthButton(
                              text: 'common.login'.tr(),
                              filled: true,
                              onTap: () => context.push('/login'),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: _buildCompactAuthButton(
                              text: 'common.register'.tr(),
                              filled: false,
                              onTap: () => context.push('/register'),
                            ),
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
                  child: _buildActionItem(
                      Icons.monetization_on_outlined,
                      'common.deposit'.tr(),
                      true,
                      () => context.push('/deposit')),
                ),
                Expanded(
                  child: _buildActionItem(
                      Icons.account_balance_wallet_outlined,
                      'common.withdraw'.tr(),
                      false,
                      () => context.push('/withdraw')),
                ),
                Expanded(
                  child: _buildActionItem(
                      Icons.headset_mic_outlined,
                      'common.service'.tr(),
                      false,
                      () => context.push('/service')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactAuthButton({
    required String text,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 22.h,
        constraints: BoxConstraints(minWidth: 52.w),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: filled ? null : Border.all(color: AppColors.primary),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.sp,
            height: 1,
            color: filled ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }

  Future<void> _copySafeDomain(SiteConfig? siteConfig) async {
    final domain = siteConfig?.domain?.trim();
    if (domain == null || domain.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: domain));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('home.safeDomainCopied'.tr())),
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
    final live = _homeCategory(categories, 'live', 'home.category.live'.tr());
    final lottery =
        _homeCategory(categories, 'lottery', 'home.category.lottery'.tr());
    final game = _homeCategory(categories, 'game', 'home.category.slot'.tr());
    final sport =
        _homeCategory(categories, 'sport', 'home.category.sport'.tr());
    final fishing =
        _homeCategory(categories, 'fishing', 'home.category.fishing'.tr());
    final poker =
        _homeCategory(categories, 'poker', 'home.category.poker'.tr());
    final esports =
        _homeCategory(categories, 'esports', 'home.category.esports'.tr());
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
                  description: 'home.category.liveDesc'.tr(),
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
                        description: 'home.category.lotteryDesc'.tr(),
                      ),
                      SizedBox(height: 10.h),
                      _buildMediumCategoryCard(
                        game,
                        height: mediumCardHeight,
                        image: AppImages.dz,
                        englishTitle: 'Slot',
                        description: 'home.category.slotDesc'.tr(),
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
                    padding: EdgeInsets.fromLTRB(16.w, 5.h, 16.w, 5.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCategoryTitle(
                          _shortCategoryTitleByCode(category),
                          fontSize: 16.sp,
                          centered: true,
                        ),
                        SizedBox(height: 1.h),
                        Flexible(
                          child: Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
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
                          _shortCategoryTitleByCode(category),
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
    return title;
  }

  String _shortCategoryTitleByCode(GameLobbyCategory category) {
    final localized = switch (category.code) {
      'live' => 'home.category.liveShort'.tr(),
      'lottery' => 'home.category.lotteryShort'.tr(),
      'game' => 'home.category.slotShort'.tr(),
      'sport' => 'home.category.sportShort'.tr(),
      'fishing' => 'home.category.fishingShort'.tr(),
      'poker' => 'home.category.pokerShort'.tr(),
      'esports' => 'home.category.esportsShort'.tr(),
      _ => '',
    };
    if (localized.isNotEmpty && !localized.startsWith('home.')) {
      return localized;
    }
    return _shortCategoryTitle(category.title);
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
                    _shortCategoryTitleByCode(category),
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
          _buildSectionHeader('home.recommendedGames'.tr(),
              onMoreTap: () => context.go('/game')),
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
                          'common.maintaining'.tr(),
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
                              'common.launching'.tr(),
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
        messenger.showSnackBar(
          SnackBar(content: Text('common.enterGameFailed'.tr())),
        );
        return;
      }
      final uri = Uri.tryParse(urlText);
      if (uri == null) {
        messenger.showSnackBar(
          SnackBar(content: Text('common.invalidGameUrl'.tr())),
        );
        return;
      }
      if (result.nesting == false) {
        final opened =
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!opened && mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text('common.openGameFailed'.tr())),
          );
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
            message?.trim().isNotEmpty == true
                ? message!
                : 'common.enterGameFailed'.tr(),
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
                'home.fallbackRecommendedGame'.tr(namedArgs: {
                  'index': '${index + 1}',
                }),
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
          _buildSectionHeader('home.hotGames'.tr(),
              onMoreTap: () => context.go('/game')),
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
                if (game.isMaintaining)
                  _buildGameMask('common.maintaining'.tr()),
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
          'home.fallbackHotGame'.tr(namedArgs: {
            'index': '${index + 1}',
          }),
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
              'common.launching'.tr(),
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
            'common.more'.tr(),
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

class _NoticeDialog extends StatefulWidget {
  const _NoticeDialog({required this.notices});

  final List<NoticeModel> notices;

  @override
  State<_NoticeDialog> createState() => _NoticeDialogState();
}

class _NoticeDialogState extends State<_NoticeDialog> {
  int _index = 0;
  bool _todayNoMore = false;

  NoticeModel get _current => widget.notices[_index];

  bool get _hasNext => _index < widget.notices.length - 1;

  void _close() {
    if (_todayNoMore || !_hasNext) {
      Navigator.of(context).pop(_todayNoMore);
      return;
    }
    setState(() => _index += 1);
  }

  @override
  Widget build(BuildContext context) {
    final title = (_current.title?.trim().isNotEmpty ?? false)
        ? _current.title!.trim()
        : 'home.notice.titleFallback'.tr();
    final content = _stripHtml(_current.content ?? '');
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 360.w),
        child: Padding(
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111111),
                      ),
                    ),
                  ),
                  if (widget.notices.length > 1) ...[
                    SizedBox(width: 8.w),
                    Text(
                      '${_index + 1} / ${widget.notices.length}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                  SizedBox(width: 6.w),
                  GestureDetector(
                    onTap: _close,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Icon(
                        Icons.close,
                        size: 18.sp,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 360.h),
                child: SingleChildScrollView(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF333333),
                        height: 1.55,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              InkWell(
                onTap: () => setState(() => _todayNoMore = !_todayNoMore),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: Checkbox(
                        value: _todayNoMore,
                        onChanged: (value) =>
                            setState(() => _todayNoMore = value ?? false),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        side: const BorderSide(color: Color(0xFF999999)),
                        activeColor: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'home.notice.todayNoMore'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF444444),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '')
        .trim();
  }
}
