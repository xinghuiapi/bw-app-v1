import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/providers/user_provider.dart';
import 'package:my_flutter_app/services/user_service.dart';
import 'package:my_flutter_app/models/user_models.dart';
import 'package:my_flutter_app/models/user.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'dart:math' as math;

class VipScreen extends ConsumerStatefulWidget {
  const VipScreen({super.key});

  @override
  ConsumerState<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends ConsumerState<VipScreen> {
  bool _isLoading = true;
  List<VipLevel> _vipLevels = [];
  String? _selectedLevelTitle;
  VipLevel? _currentLevelData;

  @override
  void initState() {
    super.initState();
    _fetchVipData();
  }

  Future<void> _fetchVipData() async {
    setState(() => _isLoading = true);
    try {
      final response = await UserService.getVipLevels();
      if (response.isSuccess) {
        final data = response.data ?? [];
        data.sort((a, b) {
          final aNum = int.tryParse(a.title.replaceAll('VIP', '')) ?? 0;
          final bNum = int.tryParse(b.title.replaceAll('VIP', '')) ?? 0;
          return aNum.compareTo(bNum);
        });
        setState(() {
          _vipLevels = data;
          final user = ref.read(userProvider).user;
          _selectedLevelTitle = user?.displayVipLevel ?? 'VIP0';
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  VipLevel? get _displayLevelData {
    if (_vipLevels.isEmpty) return null;
    return _vipLevels.firstWhere(
      (l) => l.title == _selectedLevelTitle,
      orElse: () => _vipLevels.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).user;
    final levelData = user?.levelData;
    final displayData = _displayLevelData;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('VIP等级', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.cardBackground,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _fetchVipData();
                await ref.read(userProvider.notifier).fetchUserInfo();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // VIP卡片
                  _buildVipCard(user, levelData),
                  const SizedBox(height: 24),

                  // 等级选择
                  _buildLevelSelector(),
                  const SizedBox(height: 24),

                  if (displayData != null) ...[
                    // 专属权益
                    _buildBenefitsSection(displayData),
                    const SizedBox(height: 24),

                    // 返水比例
                    _buildRebateSection(displayData),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildVipCard(User? user, LevelData? levelData) {
    final currentLevel = user?.displayVipLevel ?? 'VIP0';
    final nextLevel = levelData?.nextVipLevel ?? 'VIP1';
    
    // 计算总进度(对标 Vue 逻辑)
    final recharge = double.tryParse(levelData?.recharge?.toString() ?? '0') ?? 0;
    final nextRecharge = double.tryParse(levelData?.nextRecharge?.toString() ?? '0') ?? 0;
    final validBet = double.tryParse(levelData?.validBetAmount?.toString() ?? '0') ?? 0;
    final nextValidBet = double.tryParse(levelData?.nextValidBetAmount?.toString() ?? '0') ?? 0;

    final rechargePercent = nextRecharge > 0 ? (recharge / nextRecharge).clamp(0.0, 1.0) : 1.0;
    final flowPercent = nextValidBet > 0 ? (validBet / nextValidBet).clamp(0.0, 1.0) : 1.0;
    final totalPercent = (rechargePercent + flowPercent) / 2;
    
    final isMaxLevel = nextVipLevelIsMax(currentLevel);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF4D4F), Color(0xFFF56A6C)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4D4F).withAlpha(77),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stars, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('当前等级', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(currentLevel, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          
          if (!isMaxLevel) ...[
            const SizedBox(height: 20),
            Container(height: 1, color: Colors.white24),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('升级进度', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(currentLevel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 10),
                      const SizedBox(width: 4),
                      Text(nextLevel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: totalPercent,
                      backgroundColor: Colors.white.withAlpha(77),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${(totalPercent * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(38),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildProgressStat('充值进度', '${recharge.toInt()}/${nextRecharge.toInt()}'),
                  ),
                  Container(width: 1, height: 24, color: Colors.white24),
                  Expanded(
                    child: _buildProgressStat('流水进度', '${validBet.toInt()}/${nextValidBet.toInt()}'),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('已达最高等级', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('选择等级查看权益', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _vipLevels.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final level = _vipLevels[index];
              final isSelected = _selectedLevelTitle == level.title;
              final user = ref.read(userProvider).user;
              final isCurrent = level.title == (user?.displayVipLevel ?? 'VIP0');
              
              return GestureDetector(
                onTap: () => setState(() => _selectedLevelTitle = level.title),
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary.withAlpha(26) : AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : Colors.white.withAlpha(13),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.stars, color: AppTheme.warning, size: 32),
                          if (isCurrent)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        level.title,
                        style: TextStyle(
                          color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (isCurrent)
                        const Text('当前', style: TextStyle(color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection(VipLevel level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${level.title} 专属权益', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: [
            _buildGiftCard('升级礼金', level.levelGive),
            _buildGiftCard('每周红包', level.weekRed),
            _buildGiftCard('生日礼金', level.birthdayGive),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(13)),
          ),
          child: Column(
            children: [
              _buildLimitItem('每日提现次数', '${level.dayCountDrawing ?? 0}次'),
              _buildLimitItem('每日提现额度', '${level.dayAmountDrawing ?? 0}'),
              _buildLimitItem('最低提现金额', '${level.minDrawing ?? 0}'),
              _buildLimitItem('最低充值金额', '${level.minRecharge ?? 0}'),
              _buildLimitItem('最高充值金额', '${level.maxRecharge ?? 0}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGiftCard(String label, dynamic value) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${value ?? '--'}',
            style: const TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildLimitItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRebateSection(VipLevel level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${level.title} 返水比例', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(13)),
          ),
          child: Wrap(
            spacing: 0,
            runSpacing: 16,
            children: [
              _buildRebateItem('体育', '${level.sportBl ?? 0}%'),
              _buildRebateItem('真人', '${level.liveBl ?? 0}%'),
              _buildRebateItem('电子', '${level.gamesBl ?? 0}%'),
              _buildRebateItem('棋牌', '${level.pokerBl ?? 0}%'),
              _buildRebateItem('捕鱼', '${level.fishingBl ?? 0}%'),
              _buildRebateItem('彩票', '${level.lotteryBl ?? 0}%'),
              _buildRebateItem('电竞', '${level.gamingBl ?? 0}%'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRebateItem(String label, String value) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 64) / 3,
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  bool nextVipLevelIsMax(String currentLevel) {
    if (_vipLevels.isEmpty) return false;
    final lastLevel = _vipLevels.last.title;
    return currentLevel == lastLevel;
  }
}
