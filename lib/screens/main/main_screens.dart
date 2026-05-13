import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/activity/activity_models.dart';
import '../../models/home/home_models.dart';
import '../../models/user/user_models.dart';
import '../../providers/providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/custom_nav_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<ActivityProvider>();
      provider.loadCategories();
      provider.loadActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = context.watch<ActivityProvider>();
    final systemProvider = context.watch<SystemProvider>();
    final site = systemProvider.config.siteConfig;
    final activities = activityProvider.activities;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await activityProvider.loadCategories(refresh: true);
          await activityProvider.loadActivities(refresh: true);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _ActivityHeader(site: site)),
            SliverToBoxAdapter(
                child: _ActivityCategoryTabs(provider: activityProvider)),
            if (activityProvider.isLoading &&
                !activityProvider.hasRemoteActivities)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (activities.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'activity.empty'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 16.h),
                sliver: SliverList.separated(
                  itemCount: activities.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final item = activities[index];
                    return _ActivityCard(
                      item: item,
                      onTap: () =>
                          context.push('/activity-detail?id=${item.id}'),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActivityHeader extends StatelessWidget {
  const _ActivityHeader({required this.site});

  final SiteConfig? site;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      color: Colors.white,
      child: Row(
        children: [
          AppNetworkImage(
            url: site?.logo,
            width: 28.w,
            height: 28.w,
            borderRadius: BorderRadius.circular(14.r),
            errorWidget: CircleAvatar(
              radius: 14.r,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                'home.siteFallbackName'.tr().characters.first,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _siteText(site?.title,
                      fallback: 'home.siteFallbackName'.tr()),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _siteText(site?.domain, fallback: 'xh-bet.com'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => context.push('/search'),
            icon: Icon(Icons.search, size: 22.sp, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  String _siteText(String? value, {required String fallback}) {
    final text = value?.trim();
    return text == null || text.isEmpty ? fallback : text;
  }
}

class _ActivityCategoryTabs extends StatelessWidget {
  const _ActivityCategoryTabs({required this.provider});

  final ActivityProvider provider;

  @override
  Widget build(BuildContext context) {
    final categories = provider.categories;
    return Container(
      height: 44.h,
      color: Colors.white,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 18.w),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category.id == provider.selectedCategoryId;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context
                .read<ActivityProvider>()
                .loadActivities(categoryId: category.id),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: selected ? 24.w : 0,
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2.r),
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

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item, required this.onTap});

  final ActivityItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _ActivityImage(item: item, height: 150.h),
                Positioned(
                  left: 10.w,
                  top: 10.h,
                  right: 10.w,
                  child: Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: [
                      _ActivityTag(
                          text: item.typeText, color: AppColors.primary),
                      if (item.multipleText.isNotEmpty)
                        _ActivityTag(
                            text: item.multipleText, color: Colors.orange),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14.sp, color: AppColors.textSecondary),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          item.timeText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
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

class _ActivityImage extends StatelessWidget {
  const _ActivityImage({required this.item, required this.height});

  final ActivityItem item;
  final double height;

  @override
  Widget build(BuildContext context) {
    final img = item.img?.trim();
    if (img != null && img.startsWith('assets/')) {
      return Image.asset(
        img,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
      );
    }
    return AppNetworkImage(
      url: img,
      width: double.infinity,
      height: height,
      errorWidget: Container(
        width: double.infinity,
        height: height,
        alignment: Alignment.center,
        padding: EdgeInsets.all(16.w),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F7FF), Color(0xFFEAF2FF)],
          ),
        ),
        child: Text(
          item.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ActivityTag extends StatelessWidget {
  const _ActivityTag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ActivityDetailScreen extends StatefulWidget {
  const ActivityDetailScreen({super.key, this.id});

  final int? id;

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.id;
      if (!mounted || id == null || id <= 0) return;
      context.read<ActivityProvider>().loadActivityDetail(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = context.watch<ActivityProvider>();
    final activity = _currentActivity(activityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(
        title: 'activity.detail'.tr(),
        rightIcon: Text(
          'activity.records'.tr(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
      body: activityProvider.isLoading && activity == null
          ? const Center(child: CircularProgressIndicator())
          : activity == null
              ? Center(
                  child: Text(
                    'activity.emptyContent'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : Column(
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
                                    activity.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                                          color: AppColors.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(100.r),
                                          border: Border.all(
                                              color: AppColors.primary),
                                        ),
                                        child: Text(
                                          activity.typeText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ),
                                      if (activity.multipleText.isNotEmpty) ...[
                                        SizedBox(width: 8.w),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w, vertical: 2.h),
                                          decoration: BoxDecoration(
                                            color: Colors.orange
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(100.r),
                                            border: Border.all(
                                                color: Colors.orange),
                                          ),
                                          child: Text(
                                            activity.multipleText,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    activity.timeText,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                                            colors: [
                                              Colors.lightBlueAccent,
                                              Colors.blue
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'activity.description'.tr(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 24.h),
                                  _ActivityContent(content: activity.content),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (activity.isManualApply)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
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
                            text: activityProvider.isApplying
                                ? 'activity.applying'.tr()
                                : 'activity.apply'.tr(),
                            onPressed: activityProvider.isApplying
                                ? null
                                : () => _applyActivity(context, activity),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  ActivityItem? _currentActivity(ActivityProvider provider) {
    final id = widget.id;
    if (provider.selectedDetail != null &&
        (id == null || provider.selectedDetail!.id == id)) {
      return provider.selectedDetail;
    }
    if (id != null && id > 0) {
      return provider.activities.where((item) => item.id == id).firstOrNull;
    }
    return provider.activities.firstOrNull;
  }

  Future<void> _applyActivity(
    BuildContext context,
    ActivityItem activity,
  ) async {
    if (activity.id <= 0) return;
    final provider = context.read<ActivityProvider>();
    try {
      await provider.applyActivity(activity.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('activity.applySuccess'.tr())),
      );
    } catch (_) {
      if (!context.mounted) return;
      final message = provider.applyError?.trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message?.isNotEmpty == true
                ? message!
                : 'activity.applyFailed'.tr())),
      );
    }
  }
}

class _ActivityContent extends StatelessWidget {
  const _ActivityContent({required this.content});

  final String? content;

  @override
  Widget build(BuildContext context) {
    final raw = content?.trim() ?? '';
    if (raw.isEmpty) return _plainText(context, 'activity.emptyContent'.tr());

    final sanitized = _sanitizeHtml(raw);
    if (!_looksLikeHtml(sanitized)) {
      return _plainText(context, _decodeHtml(sanitized));
    }

    final blocks = _parseHtmlBlocks(sanitized);
    if (blocks.isEmpty) return _plainText(context, _htmlToPlainText(sanitized));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks) _ActivityHtmlBlock(block: block),
      ],
    );
  }

  Widget _plainText(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        color: AppColors.textSecondary,
        height: 1.6,
      ),
    );
  }

  bool _looksLikeHtml(String value) {
    return RegExp(r'</?[a-z][\s\S]*>', caseSensitive: false).hasMatch(value);
  }

  String _sanitizeHtml(String value) {
    return value
        .replaceAll(
            RegExp(r'<script[\s\S]*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), '')
        .replaceAll(RegExp(r'\son\w+\s*=\s*"[^"]*"', caseSensitive: false), '')
        .replaceAll(RegExp(r"\son\w+\s*=\s*'[^']*'", caseSensitive: false), '')
        .replaceAll(
            RegExp(r'\s(href|src)\s*=\s*"\s*javascript:[^"]*"',
                caseSensitive: false),
            '')
        .replaceAll(
            RegExp(r"\s(href|src)\s*=\s*'\s*javascript:[^']*'",
                caseSensitive: false),
            '');
  }

  List<_ActivityHtmlBlockData> _parseHtmlBlocks(String html) {
    final normalized = html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(
            RegExp(r'</(p|div|section|article|h[1-6])>', caseSensitive: false),
            '\n')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</tr>', caseSensitive: false), '\n');
    final blocks = <_ActivityHtmlBlockData>[];
    var cursor = 0;
    final imageRegex = RegExp(
      r'''<img\b[^>]*\bsrc\s*=\s*(["'])(.*?)\1[^>]*>''',
      caseSensitive: false,
    );

    for (final match in imageRegex.allMatches(normalized)) {
      final before = normalized.substring(cursor, match.start);
      _appendTextBlocks(blocks, before);
      final src = _decodeHtml(match.group(2) ?? '').trim();
      if (src.isNotEmpty) blocks.add(_ActivityHtmlImageBlock(src));
      cursor = match.end;
    }

    _appendTextBlocks(blocks, normalized.substring(cursor));
    return blocks;
  }

  void _appendTextBlocks(List<_ActivityHtmlBlockData> blocks, String html) {
    final text = _htmlToPlainText(html);
    for (final line in text.split(RegExp(r'\n{2,}'))) {
      final normalized = line.trim();
      if (normalized.isNotEmpty) {
        blocks.add(_ActivityHtmlTextBlock(normalized));
      }
    }
  }

  String _htmlToPlainText(String html) {
    return _decodeHtml(html
            .replaceAll(RegExp(r'<li\b[^>]*>', caseSensitive: false), '\n• ')
            .replaceAll(RegExp(r'</t[dh]>', caseSensitive: false), '  ')
            .replaceAll(RegExp(r'<[^>]+>'), ''))
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r' *\n *'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  String _decodeHtml(String value) {
    return value
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");
  }
}

abstract class _ActivityHtmlBlockData {
  const _ActivityHtmlBlockData();
}

class _ActivityHtmlTextBlock extends _ActivityHtmlBlockData {
  const _ActivityHtmlTextBlock(this.text);

  final String text;
}

class _ActivityHtmlImageBlock extends _ActivityHtmlBlockData {
  const _ActivityHtmlImageBlock(this.url);

  final String url;
}

class _ActivityHtmlBlock extends StatelessWidget {
  const _ActivityHtmlBlock({required this.block});

  final _ActivityHtmlBlockData block;

  @override
  Widget build(BuildContext context) {
    final data = block;
    if (data is _ActivityHtmlImageBlock) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: AppNetworkImage(
          url: data.url,
          width: double.infinity,
          height: 180.h,
          fit: BoxFit.contain,
          borderRadius: BorderRadius.circular(12.r),
          optimize: false,
        ),
      );
    }

    final text = data is _ActivityHtmlTextBlock ? data.text : '';
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }
}

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final systemProvider = context.watch<SystemProvider>();
    final userProvider = context.watch<UserProvider>();
    final site = systemProvider.config.siteConfig;
    final profile = userProvider.profile;
    final cards = _supportCards(site);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(
        title: 'service.title'.tr(),
        showLeftArrow: false,
        border: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => systemProvider.loadConfig(refresh: true),
        child: ListView(
          padding: EdgeInsets.all(12.w),
          children: [
            _ServiceHeroCard(profile: profile),
            SizedBox(height: 12.h),
            if (cards.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 28.h),
                child: Text(
                  systemProvider.isLoading
                      ? 'service.loading'.tr()
                      : 'service.empty'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 1.72,
                ),
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return _ServiceSupportCard(
                    card: card,
                    onTap: () => _openService(context, card.url),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  List<_ServiceCardData> _supportCards(SiteConfig? site) {
    final serviceLinks = _parseServiceLinks(site?.serviceLink);
    final tgLinks = _parseServiceLinks(site?.tgLink);
    return [
      for (var i = 0; i < serviceLinks.length; i++)
        _ServiceCardData(
          kind: _ServiceCardKind.service,
          titleCn: serviceLinks.length > 1
              ? 'service.onlineNumbered'.tr(namedArgs: {'index': '${i + 1}'})
              : 'service.online'.tr(),
          titleEn: 'service.onlineSubtitle'.tr(),
          url: serviceLinks[i],
        ),
      for (var i = 0; i < tgLinks.length; i++)
        _ServiceCardData(
          kind: _ServiceCardKind.telegram,
          titleCn: tgLinks.length > 1 ? 'Telegram${i + 1}' : 'Telegram',
          titleEn: 'service.telegramSubtitle'.tr(),
          url: tgLinks[i],
        ),
    ];
  }

  List<String> _parseServiceLinks(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw.map(_normalizeUrl).where((url) => url.isNotEmpty).toList();
    }
    final value = raw.toString().replaceAll('`', '').trim();
    if (value.isEmpty) return const [];

    var normalized = value;
    if (normalized.startsWith('[') && normalized.endsWith(']')) {
      normalized = normalized.substring(1, normalized.length - 1);
    }

    return normalized
        .split(RegExp(r'[\n,，\s]+'))
        .map(_normalizeUrl)
        .where((url) => url.isNotEmpty)
        .toList();
  }

  String _normalizeUrl(dynamic raw) {
    var value = raw.toString().replaceAll('`', '').trim();
    value = value.replaceAll(RegExp(r'''^['"]|['"]$'''), '').trim();
    value = value.replaceAll(RegExp(r'\s+'), '');
    return value;
  }

  Future<void> _openService(BuildContext context, String url) async {
    final value = _normalizeUrl(url);
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('service.empty'.tr())),
      );
      return;
    }

    final uri = Uri.tryParse(value);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('service.invalidLink'.tr())),
      );
      return;
    }

    bool opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on MissingPluginException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('service.externalPluginMissing'.tr())),
      );
      return;
    }

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('service.openFailed'.tr())),
      );
    }
  }
}

class _ServiceHeroCard extends StatelessWidget {
  const _ServiceHeroCard({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final username = _profileName(profile);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          _ServiceAvatar(profile: profile),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi，$username',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'service.welcome'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _profileName(UserProfile? profile) {
    final username = profile?.username.trim();
    if (username != null && username.isNotEmpty) return username;
    final nickname = profile?.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) return nickname;
    return 'service.guest'.tr();
  }
}

class _ServiceAvatar extends StatelessWidget {
  const _ServiceAvatar({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final image = profile?.img?.trim();
    final placeholder = Container(
      width: 48.w,
      height: 48.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDBEAFE), Color(0xFFBFDBFE)],
        ),
      ),
    );
    return ClipOval(
      child: image == null || image.isEmpty
          ? placeholder
          : AppNetworkImage(
              url: image,
              width: 48.w,
              height: 48.w,
              borderRadius: BorderRadius.circular(24.r),
              errorWidget: placeholder,
            ),
    );
  }
}

enum _ServiceCardKind { service, telegram }

class _ServiceCardData {
  const _ServiceCardData({
    required this.kind,
    required this.titleCn,
    required this.titleEn,
    required this.url,
  });

  final _ServiceCardKind kind;
  final String titleCn;
  final String titleEn;
  final String url;
}

class _ServiceSupportCard extends StatelessWidget {
  const _ServiceSupportCard({required this.card, required this.onTap});

  final _ServiceCardData card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isTelegram = card.kind == _ServiceCardKind.telegram;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isTelegram
                ? const [Color(0xFF4FD1C5), Color(0xFF2F90FF)]
                : const [Color(0xFF7AA2FF), Color(0xFF5B7BFF)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              card.titleCn,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              card.titleEn,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityRecordScreen extends StatefulWidget {
  const ActivityRecordScreen({super.key});

  @override
  State<ActivityRecordScreen> createState() => _ActivityRecordScreenState();
}

class _ActivityRecordScreenState extends State<ActivityRecordScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ActivityProvider>().loadRecords();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 120.h) return;
    context.read<ActivityProvider>().loadMoreRecords();
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = context.watch<ActivityProvider>();
    final records = activityProvider.records;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(title: 'activity.records'.tr()),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<ActivityProvider>().loadRecords(refresh: true),
        child: activityProvider.isRecordsLoading &&
                !activityProvider.hasRemoteRecords
            ? const Center(child: CircularProgressIndicator())
            : records.isEmpty
                ? ListView(
                    padding: EdgeInsets.all(16.w),
                    children: [
                      SizedBox(height: 180.h),
                      Text(
                        'activity.emptyRecords'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(12.w),
                    itemCount: records.length +
                        (activityProvider.isRecordsLoadingMore ? 1 : 1),
                    itemBuilder: (context, index) {
                      if (index >= records.length) {
                        if (activityProvider.isRecordsLoadingMore) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return Padding(
                          padding: EdgeInsets.only(top: 16.h),
                          child: Center(
                            child: Text(
                              'common.noMore'.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }
                      return _ActivityRecordCard(record: records[index]);
                    },
                  ),
      ),
    );
  }
}

class _ActivityRecordCard extends StatelessWidget {
  const _ActivityRecordCard({required this.record});

  final ActivityApplyRecord record;

  @override
  Widget build(BuildContext context) {
    final statusColor = record.isApproved
        ? Colors.green
        : record.isRejected
            ? AppColors.danger
            : AppColors.primary;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _fallbackText(record.title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                  border:
                      Border.all(color: statusColor.withValues(alpha: 0.55)),
                ),
                child: Text(
                  record.statusText,
                  style: TextStyle(color: statusColor, fontSize: 12.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _ActivityRecordRow(
              label: 'activity.account'.tr(),
              value: _fallbackText(record.username)),
          SizedBox(height: 10.h),
          _ActivityRecordRow(
              label: 'activity.time'.tr(),
              value: _fallbackText(record.applyTime)),
        ],
      ),
    );
  }

  String _fallbackText(String value) {
    final text = value.trim();
    return text.isEmpty ? '-' : text;
  }
}

class _ActivityRecordRow extends StatelessWidget {
  const _ActivityRecordRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
