import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:my_flutter_app/providers/user_provider.dart';
import 'package:my_flutter_app/providers/referral_provider.dart';
import 'package:my_flutter_app/theme/app_theme.dart';

class ShareInviteScreen extends ConsumerStatefulWidget {
  const ShareInviteScreen({super.key});

  @override
  ConsumerState<ShareInviteScreen> createState() => _ShareInviteScreenState();
}

class _ShareInviteScreenState extends ConsumerState<ShareInviteScreen> {
  bool _rulesExpanded = false;

  void _copyText(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).user;
    final referralState = ref.watch(referralProvider);
    final inviteCode = user?.id.toString() ?? 'N/A';
    // 假设 referralUrl 逻辑与 Vue 一致
    final referralUrl = 'https://yourdomain.com/home?refcode=$inviteCode';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          '全民返利',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.getTextPrimary(context),
        elevation: 0,
        centerTitle: true,
      ),
      body: referralState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark
                        ? const Color(0xFF1A1D21)
                        : AppTheme.getScaffoldBackgroundColor(context),
                    AppTheme.getScaffoldBackgroundColor(context),
                  ],
                  stops: const [0.0, 0.3],
                ),
              ),
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(referralProvider.notifier).fetchReferralData(),
                child: ListView(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 60,
                    left: 16,
                    right: 16,
                    bottom: 100,
                  ),
                  children: [
                    // 返利统计卡片
                    _buildStatsCard(referralState),
                    const SizedBox(height: 16),

                    // 邀请码与二维码卡片
                    _buildInviteCard(inviteCode, referralUrl),
                    const SizedBox(height: 16),

                    // 邀请链接卡片
                    _buildLinkCard(referralUrl),
                    const SizedBox(height: 16),

                    // 规则卡片
                    _buildRulesCard(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomBar(referralUrl),
    );
  }

  Widget _buildStatsCard(ReferralState state) {
    final rebateData = state.data;
    final dailingqu =
        double.tryParse(rebateData?.dailingqu.toString() ?? '0') ?? 0;
    final userYouxiao = rebateData?.userYouxiao ?? 0;
    final canClaim = dailingqu > 0 && userYouxiao >= 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getDividerColor(context)),
      ),
      child: Column(
        children: [
          Text(
            '待领返利金额',
            style: TextStyle(
              color: AppTheme.getTextSecondary(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                dailingqu.toStringAsFixed(2),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '元',
                style: TextStyle(color: AppTheme.primary, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (state.isClaiming || !canClaim)
                  ? null
                  : () => ref.read(referralProvider.notifier).claimRebate(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.white10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.isClaiming
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      '立即领取',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '总有效会员≥1人即可领取',
            style: TextStyle(
              color: AppTheme.getTextTertiary(context),
              fontSize: 12,
            ),
          ),

          if (rebateData != null && rebateData.userMax > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.getDividerColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: AppTheme.getTextSecondary(context),
                    fontSize: 12,
                  ),
                  children: [
                    const TextSpan(text: '再邀请 '),
                    TextSpan(
                      text:
                          '${(rebateData.userMax - rebateData.userYouxiao).clamp(0, 999999)}',
                      style: const TextStyle(
                        color: AppTheme.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: ' 人即可多领取 '),
                    TextSpan(
                      text: '${rebateData.userAmount}',
                      style: const TextStyle(
                        color: AppTheme.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: ' 元返利'),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatItem(
                '已领总额',
                '${rebateData?.userSum ?? 0}',
                AppTheme.getTextPrimary(context),
              ),
              Container(
                width: 1,
                height: 24,
                color: AppTheme.getDividerColor(context),
              ),
              _buildStatItem(
                '有效会员',
                '${rebateData?.userYouxiao ?? 0}',
                AppTheme.success,
              ),
              Container(
                width: 1,
                height: 24,
                color: AppTheme.getDividerColor(context),
              ),
              _buildStatItem(
                '邀请总人数',
                '${rebateData?.userSum ?? 0}',
                AppTheme.getTextPrimary(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.getTextTertiary(context),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCard(String inviteCode, String referralUrl) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getDividerColor(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 20, height: 1, color: AppTheme.primary),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '您的邀请码',
                  style: TextStyle(
                    color: AppTheme.getTextPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(width: 20, height: 1, color: AppTheme.primary),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            inviteCode,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: referralUrl,
              version: QrVersions.auto,
              size: 160.0,
              gapless: false,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 160,
            child: OutlinedButton(
              onPressed: () => _copyText(inviteCode, '邀请码已复制'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('复制邀请码'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(String referralUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getDividerColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '邀请链接',
            style: TextStyle(
              color: AppTheme.getTextSecondary(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.getDividerColor(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    referralUrl,
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(context),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _copyText(referralUrl, '邀请链接已复制'),
                  child: const Text(
                    '复制',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getDividerColor(context)),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _rulesExpanded = !_rulesExpanded),
            title: Text(
              '邀请规则',
              style: TextStyle(
                color: AppTheme.getTextPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(
              _rulesExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppTheme.getTextSecondary(context),
            ),
          ),
          if (_rulesExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _RuleItem(number: '1', text: '邀请好友注册并完成充值，即可获得返利奖励。'),
                  SizedBox(height: 8),
                  _RuleItem(number: '2', text: '返利金额根据好友的充值和投注情况计算。'),
                  SizedBox(height: 8),
                  _RuleItem(number: '3', text: '邀请人数越多，返利比例越高，奖励更丰厚。'),
                  SizedBox(height: 8),
                  _RuleItem(number: '4', text: '严禁通过不正当手段刷取返利，一经发现将取消资格。'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(String referralUrl) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        border: Border(
          top: BorderSide(color: AppTheme.getDividerColor(context)),
        ),
        // Removed BoxShadow for web optimization
      ),
      child: ElevatedButton(
        onPressed: () => _copyText(referralUrl, '邀请链接已复制'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          '立即分享',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  final String number;
  final String text;

  const _RuleItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppTheme.getTextSecondary(context),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
