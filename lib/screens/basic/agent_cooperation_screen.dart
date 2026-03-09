import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/widgets/common/web_safe_image.dart';

class AgentCooperationScreen extends StatelessWidget {
  const AgentCooperationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('代理合作'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Hero Section
          _buildHeroSection(),
          
          // 八大优势让你不可抗拒 (Partnership Plan)
          _buildSection(
            title: '八大优势让你不可抗拒',
            description: '亚洲顶级线上博彩公司，最具公信力，更具高端品质，深受广大玩家喜爱及支持，同时致力于打造线上最高端的代理合作平台，零成本，高回报。为“微商、电商”争相选择之最佳创业投资项目。加入我们，开启您的财富梦想之路！',
          ),
          
          // 重新定义行业 (Industry Features)
          _buildIndustrySection(),
          
          // 强大应用 (App Features)
          _buildAppFeaturesSection(),

          // 合营待遇 (Partnership Benefits)
          _buildBenefitsSection(),

          // 介绍 (Introduction)
          _buildSection(
            title: '介绍',
            description: '本站是一家合法的在线博彩公司，拥有马恩岛、卡加延和自由港经济区的许可证。我们拥有超过1000万玩家的服务经验，在在线游戏市场中建立了稳固的地位，我们的专业团队提供高质量的产品和服务。\n\n我们的目标是确保公平性，展示我们的客观质量和能力。本站是亚洲市场最受信任和受欢迎的大型博彩网站，获得国际在线博彩协会认证，拥有全面的认证和许可证。',
          ),

          // 安全又可靠 (Security)
          _buildSection(
            title: '安全又可靠',
            description: '本站使用最高的数据加密标准（安全套接字(SSL) 128位加密）来保护客户个人信息，防止第三方泄露，确保数据不被公开访问。我们严格监控和管理所有数据，提供安全的用户体验。',
          ),
          
          // Footer / Join Button
          _buildJoinButton(context),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const WebSafeImage(
              imageUrl: 'assets/images/agent/sport-banner.png',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withAlpha(153),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomLeft,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '共创辉煌 赢在未来',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '全球领先的游戏合营平台',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
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

  Widget _buildSection({required String title, required String description}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(13)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              color: AppTheme.textSecondary.withAlpha(230),
              fontSize: 14,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndustrySection() {
    final List<Map<String, String>> items = [
      {
        'icon': '📊',
        'title': '会员统计',
        'description': '随时查看注册会员与有效会员',
      },
      {
        'icon': '🎫',
        'title': '会员游戏明细',
        'description': '会员参与游戏的盈亏详情',
      },
      {
        'icon': '📈',
        'title': '会员报表',
        'description': '各种会员信息一目了然',
      },
      {
        'icon': '📄',
        'title': '平台费用明细',
        'description': '平台流水，费用率，盈亏状况及总平台费用',
      },
    ];

    return _buildFeatureGrid('重新定义行业', '更方便的更多详细信息', items);
  }

  Widget _buildAppFeaturesSection() {
    final List<Map<String, String>> items = [
      {
        'icon': '🎮',
        'title': '更丰富',
        'description': '更多游戏产品我们拥有您想要的一切',
      },
      {
        'icon': '🚀',
        'title': '更稳定',
        'description': '强大的技术团队提供最稳定的产品',
      },
      {
        'icon': '🔒',
        'title': '更安全',
        'description': '独家网络技术超强防劫持',
      },
      {
        'icon': '🔐',
        'title': '更私密',
        'description': '三重数据加密保护您的数据安全',
      },
    ];

    return _buildFeatureGrid('强大应用', '更丰富，更稳定，更安全，更私密', items);
  }

  Widget _buildBenefitsSection() {
    final List<Map<String, String>> items = [
      {
        'title': '多功能',
        'description': '没有注册费，没有收入限制，随时随地赚钱。',
        'icon': '🛠️',
      },
      {
        'title': '稳定',
        'description': '介绍新客户可获得高达60%的佣金，维护老客户仍有可持续60%佣金。',
        'icon': '💹',
      },
      {
        'title': '客服',
        'description': '拥有强大而专注的客服人员，随时准备在您需要时24/7为您提供帮助。',
        'icon': '🎧',
      },
      {
        'title': '速度',
        'description': '在线博彩市场佣金率最高，月收入1亿以上不是梦。',
        'icon': '🚀',
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(13)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Column(
              children: [
                Text(
                  '合营待遇',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '更方便的更多详细信息',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withAlpha(102),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(8)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['icon']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['description']!,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(String title, String subtitle, List<Map<String, String>> items) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(13)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withAlpha(102),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(8)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        item['icon']!,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item['title']!,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['description']!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          context.push('/customer-service');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          '立即加入',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
