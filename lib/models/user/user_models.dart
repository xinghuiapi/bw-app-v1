import 'package:easy_localization/easy_localization.dart';

import '../core/json_utils.dart';
import '../core/paginated_response.dart';

class UserProfile {
  final int id;
  final String username;
  final String? realName;
  final String? nickname;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String? img;
  final dynamic balance;
  final dynamic lockBalance;
  final dynamic vipLevel;
  final dynamic vip;
  final String? currency;
  final int? status;
  final int? fsStatus;
  final int? isAgent;
  final int? transfer;
  final String? gender;
  final String? bornTime;
  final String? qq;
  final String? telegram;
  final String? weixin;
  final String? skype;
  final String? symbol;
  final dynamic recharge;
  final dynamic totalRecharge;
  final dynamic totalDeposit;
  final dynamic rechargeAmount;
  final dynamic totalFlow;
  final dynamic flowingAmount;
  final dynamic totalBet;
  final dynamic payPassword;
  final dynamic sumWater;
  final dynamic okWater;
  final VipProgress? levelData;

  const UserProfile({
    required this.id,
    required this.username,
    this.realName,
    this.nickname,
    this.email,
    this.phone,
    this.avatarUrl,
    this.img,
    this.balance,
    this.lockBalance,
    this.vipLevel,
    this.vip,
    this.currency,
    this.status,
    this.fsStatus,
    this.isAgent,
    this.transfer,
    this.gender,
    this.bornTime,
    this.qq,
    this.telegram,
    this.weixin,
    this.skype,
    this.symbol,
    this.recharge,
    this.totalRecharge,
    this.totalDeposit,
    this.rechargeAmount,
    this.totalFlow,
    this.flowingAmount,
    this.totalBet,
    this.payPassword,
    this.sumWater,
    this.okWater,
    this.levelData,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: jsonInt(json['id']) ?? 0,
        username: jsonString(json['username']) ?? '',
        realName: jsonString(json['real_name']),
        nickname: jsonString(json['nickname']),
        email: jsonString(json['email']),
        phone: jsonString(json['phone']),
        avatarUrl: jsonString(json['avatar_url']),
        img: jsonString(json['img']),
        balance: json['balance'],
        lockBalance: json['lock_balance'],
        vipLevel: json['vip_level'],
        vip: json['vip'],
        currency: jsonString(json['currency']),
        status: jsonInt(json['status']),
        fsStatus: jsonInt(json['fs_status']),
        isAgent: jsonInt(json['is_agent']),
        transfer: jsonInt(json['transfer']),
        gender: jsonString(json['gender']),
        bornTime: jsonString(json['born_time']),
        qq: jsonString(json['qq']),
        telegram: jsonString(json['telegram']),
        weixin: jsonString(json['weixin']),
        skype: jsonString(json['skype']),
        symbol: jsonString(json['symbol']),
        recharge: json['recharge'],
        totalRecharge: json['total_recharge'],
        totalDeposit: json['total_deposit'],
        rechargeAmount: json['recharge_amount'],
        totalFlow: json['total_flow'],
        flowingAmount: json['flowing_amount'],
        totalBet: json['total_bet'],
        payPassword: json['pay_password'],
        sumWater: json['sum_water'],
        okWater: json['ok_water'],
        levelData: jsonMap(json['level_data']) == null
            ? null
            : VipProgress.fromJson(jsonMap(json['level_data'])!),
      );

  bool get hasPayPassword {
    final value = payPassword;
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.isNotEmpty && value != '0';
    return false;
  }

  bool get hasRealName => _hasText(realName);

  bool get isPhoneBound => _hasText(phone);

  bool get isEmailBound => _hasText(email);

  String get realNameStatusText =>
      hasRealName ? 'common.verified'.tr() : 'common.unverified'.tr();

  String get payPasswordStatusText =>
      hasPayPassword ? 'common.set'.tr() : 'common.notSet'.tr();

  String get genderText {
    final text = gender?.trim();
    if (text == null || text.isEmpty) return 'common.notSet'.tr();
    if (text == 'male') return 'user.gender.male'.tr();
    if (text == 'female') return 'user.gender.female'.tr();
    if (text == 'secret') return 'user.gender.secret'.tr();
    return text;
  }

  String get birthdayText =>
      _hasText(bornTime) ? bornTime!.trim() : 'common.notSet'.tr();

  String get qqText => _hasText(qq) ? qq!.trim() : 'common.notFilled'.tr();

  String get telegramText =>
      _hasText(telegram) ? telegram!.trim() : 'common.notFilled'.tr();

  String get displayVipLevel {
    final value = vipLevel ?? vip;
    if (value == null) return 'VIP0';
    final text = value.toString();
    return text.startsWith('VIP') ? text : 'VIP$text';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        if (realName != null) 'real_name': realName,
        if (nickname != null) 'nickname': nickname,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (img != null) 'img': img,
        if (balance != null) 'balance': balance,
        if (lockBalance != null) 'lock_balance': lockBalance,
        if (vipLevel != null) 'vip_level': vipLevel,
        if (vip != null) 'vip': vip,
        if (currency != null) 'currency': currency,
        if (status != null) 'status': status,
        if (fsStatus != null) 'fs_status': fsStatus,
        if (isAgent != null) 'is_agent': isAgent,
        if (transfer != null) 'transfer': transfer,
        if (gender != null) 'gender': gender,
        if (bornTime != null) 'born_time': bornTime,
        if (qq != null) 'qq': qq,
        if (telegram != null) 'telegram': telegram,
        if (weixin != null) 'weixin': weixin,
        if (skype != null) 'skype': skype,
        if (symbol != null) 'symbol': symbol,
        if (recharge != null) 'recharge': recharge,
        if (totalRecharge != null) 'total_recharge': totalRecharge,
        if (totalDeposit != null) 'total_deposit': totalDeposit,
        if (rechargeAmount != null) 'recharge_amount': rechargeAmount,
        if (totalFlow != null) 'total_flow': totalFlow,
        if (flowingAmount != null) 'flowing_amount': flowingAmount,
        if (totalBet != null) 'total_bet': totalBet,
        if (payPassword != null) 'pay_password': payPassword,
        if (sumWater != null) 'sum_water': sumWater,
        if (okWater != null) 'ok_water': okWater,
        if (levelData != null) 'level_data': levelData!.toJson(),
      };

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;
}

class VipProgress {
  final dynamic recharge;
  final dynamic validBetAmount;
  final dynamic nextRecharge;
  final dynamic nextValidBetAmount;
  final dynamic gapRecharge;
  final dynamic gapValidBetAmount;
  final String? vipLevel;
  final String? nextVipLevel;

  const VipProgress({
    this.recharge,
    this.validBetAmount,
    this.nextRecharge,
    this.nextValidBetAmount,
    this.gapRecharge,
    this.gapValidBetAmount,
    this.vipLevel,
    this.nextVipLevel,
  });

  factory VipProgress.fromJson(Map<String, dynamic> json) => VipProgress(
        recharge: json['recharge'],
        validBetAmount: json['validBetAmount'],
        nextRecharge: json['next_recharge'],
        nextValidBetAmount: json['next_validBetAmount'],
        gapRecharge: json['gap_recharge'],
        gapValidBetAmount: json['gap_validBetAmount'],
        vipLevel: jsonString(json['vip_level']),
        nextVipLevel: jsonString(json['next_vip_level']),
      );

  Map<String, dynamic> toJson() => {
        if (recharge != null) 'recharge': recharge,
        if (validBetAmount != null) 'validBetAmount': validBetAmount,
        if (nextRecharge != null) 'next_recharge': nextRecharge,
        if (nextValidBetAmount != null)
          'next_validBetAmount': nextValidBetAmount,
        if (gapRecharge != null) 'gap_recharge': gapRecharge,
        if (gapValidBetAmount != null) 'gap_validBetAmount': gapValidBetAmount,
        if (vipLevel != null) 'vip_level': vipLevel,
        if (nextVipLevel != null) 'next_vip_level': nextVipLevel,
      };
}

class VipLevel {
  final int id;
  final String title;
  final dynamic chargeLevel;
  final dynamic flowingLevel;
  final dynamic levelGive;
  final dynamic weekRed;
  final dynamic birthdayGive;
  final dynamic dayCountDrawing;
  final dynamic dayAmountDrawing;
  final dynamic minDrawing;
  final dynamic minRecharge;
  final dynamic maxRecharge;
  final dynamic minTransfer;
  final dynamic sportBl;
  final dynamic liveBl;
  final dynamic gamesBl;
  final dynamic pokerBl;
  final dynamic fishingBl;
  final dynamic lotteryBl;
  final dynamic gamingBl;

  const VipLevel({
    required this.id,
    required this.title,
    this.chargeLevel,
    this.flowingLevel,
    this.levelGive,
    this.weekRed,
    this.birthdayGive,
    this.dayCountDrawing,
    this.dayAmountDrawing,
    this.minDrawing,
    this.minRecharge,
    this.maxRecharge,
    this.minTransfer,
    this.sportBl,
    this.liveBl,
    this.gamesBl,
    this.pokerBl,
    this.fishingBl,
    this.lotteryBl,
    this.gamingBl,
  });

  factory VipLevel.fromJson(Map<String, dynamic> json) => VipLevel(
        id: jsonInt(json['id']) ?? 0,
        title: jsonString(json['title']) ?? '',
        chargeLevel: json['charge_level'],
        flowingLevel: json['flowing_level'],
        levelGive: json['level_give'],
        weekRed: json['week_red'],
        birthdayGive: json['birthday_give'],
        dayCountDrawing: json['day_count_drawing'],
        dayAmountDrawing: json['day_amount_drawing'],
        minDrawing: json['min_drawing'],
        minRecharge: json['min_recharge'],
        maxRecharge: json['max_recharge'],
        minTransfer: json['min_transfer'],
        sportBl: json['sport_bl'],
        liveBl: json['live_bl'],
        gamesBl: json['games_bl'],
        pokerBl: json['poker_bl'],
        fishingBl: json['fishing_bl'],
        lotteryBl: json['lottery_bl'],
        gamingBl: json['gaming_bl'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (chargeLevel != null) 'charge_level': chargeLevel,
        if (flowingLevel != null) 'flowing_level': flowingLevel,
        if (levelGive != null) 'level_give': levelGive,
        if (weekRed != null) 'week_red': weekRed,
        if (birthdayGive != null) 'birthday_give': birthdayGive,
        if (dayCountDrawing != null) 'day_count_drawing': dayCountDrawing,
        if (dayAmountDrawing != null) 'day_amount_drawing': dayAmountDrawing,
        if (minDrawing != null) 'min_drawing': minDrawing,
        if (minRecharge != null) 'min_recharge': minRecharge,
        if (maxRecharge != null) 'max_recharge': maxRecharge,
        if (minTransfer != null) 'min_transfer': minTransfer,
        if (sportBl != null) 'sport_bl': sportBl,
        if (liveBl != null) 'live_bl': liveBl,
        if (gamesBl != null) 'games_bl': gamesBl,
        if (pokerBl != null) 'poker_bl': pokerBl,
        if (fishingBl != null) 'fishing_bl': fishingBl,
        if (lotteryBl != null) 'lottery_bl': lotteryBl,
        if (gamingBl != null) 'gaming_bl': gamingBl,
      };

  int get levelNumber {
    return jsonInt(title.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }
}

class VipOverview {
  final List<VipLevel> levels;
  final dynamic totalDeposit;
  final dynamic totalBet;

  const VipOverview({
    required this.levels,
    this.totalDeposit,
    this.totalBet,
  });

  factory VipOverview.fromResponse(Object? json) {
    if (json is List) {
      return VipOverview(levels: _parseLevels(json));
    }

    if (json is Map) {
      final root = Map<String, dynamic>.from(json);
      final nested = root['data'];
      final source = nested is Map && nested['data'] is List
          ? nested['data']
          : root['data'] is List
              ? root['data']
              : const [];
      final totalSource = nested is Map ? nested : root;
      return VipOverview(
        levels: _parseLevels(source),
        totalDeposit: totalSource['total_deposit'],
        totalBet: totalSource['total_bet'],
      );
    }

    return const VipOverview(levels: []);
  }

  static List<VipLevel> _parseLevels(Object? source) {
    if (source is! List) return const [];
    final levels = source
        .whereType<Map>()
        .map((item) => VipLevel.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.title.isNotEmpty)
        .toList();
    levels.sort((a, b) => a.levelNumber.compareTo(b.levelNumber));
    return levels;
  }
}

class DayRevenueSummary {
  const DayRevenueSummary({
    this.betCount = 0,
    this.betAmount = 0,
    this.validBetAmount = 0,
    this.profitLoss = 0,
    this.totalNoRebate = 0,
    this.totalNoCommission = 0,
    this.unclaimedRebate = 0,
    this.totalRebate = 0,
    this.claimedRebate = 0,
    this.totalCommission = 0,
    this.claimedCommission = 0,
    this.unclaimedCommission = 0,
    this.revenue = 0,
    this.raw = const <String, dynamic>{},
  });

  final int betCount;
  final double betAmount;
  final double validBetAmount;
  final double profitLoss;
  final double totalNoRebate;
  final double totalNoCommission;
  final double unclaimedRebate;
  final double totalRebate;
  final double claimedRebate;
  final double totalCommission;
  final double claimedCommission;
  final double unclaimedCommission;
  final double revenue;
  final Map<String, dynamic> raw;

  factory DayRevenueSummary.fromJson(Map<String, dynamic> json) {
    return DayRevenueSummary(
      betCount: jsonInt(json['day_bet_count'] ??
              json['bet_count'] ??
              json['betCount'] ??
              json['total']) ??
          0,
      betAmount: jsonDouble(json['bet_amount'] ??
              json['betAmount'] ??
              json['total_betAmount']) ??
          0,
      validBetAmount: jsonDouble(
            json['valid_bet_amount'] ??
                json['validBetAmount'] ??
                json['total_validBetAmount'],
          ) ??
          0,
      profitLoss: jsonDouble(
            json['day_netAmount'] ??
                json['profit_loss'] ??
                json['profitLoss'] ??
                json['net_amount'] ??
                json['total_netAmount'],
          ) ??
          0,
      totalNoRebate: jsonDouble(json['total_no_fs']) ?? 0,
      totalNoCommission: jsonDouble(json['total_no_fy']) ?? 0,
      unclaimedRebate: jsonDouble(
            json['day_weiling'] ??
                json['not_fs_money'] ??
                json['unclaimed_rebate'] ??
                json['unclaimedRebate'],
          ) ??
          0,
      totalRebate: jsonDouble(json['day_zongfs'] ?? json['total_rebate']) ?? 0,
      claimedRebate:
          jsonDouble(json['day_lingqu'] ?? json['claimed_rebate']) ?? 0,
      totalCommission:
          jsonDouble(json['day_zongfy'] ?? json['total_commission']) ?? 0,
      claimedCommission: jsonDouble(
            json['day_lingqu_fy'] ?? json['claimed_commission'],
          ) ??
          0,
      unclaimedCommission: jsonDouble(
            json['day_weiling_fy'] ?? json['unclaimed_commission'],
          ) ??
          0,
      revenue: jsonDouble(
              json['revenue'] ?? json['day_revenue'] ?? json['income']) ??
          0,
      raw: json,
    );
  }

  factory DayRevenueSummary.fromResponse(Object? json) {
    if (json is List && json.isNotEmpty && json.first is Map) {
      return DayRevenueSummary.fromJson(
          Map<String, dynamic>.from(json.first as Map));
    }
    if (json is Map) {
      final map = Map<String, dynamic>.from(json);
      final nested = jsonMap(map['data']);
      return DayRevenueSummary.fromJson(nested ?? map);
    }
    return const DayRevenueSummary();
  }

  Map<String, dynamic> toJson() => {
        'bet_count': betCount,
        'bet_amount': betAmount,
        'valid_bet_amount': validBetAmount,
        'profit_loss': profitLoss,
        'total_no_fs': totalNoRebate,
        'total_no_fy': totalNoCommission,
        'not_fs_money': unclaimedRebate,
        'day_netAmount': profitLoss,
        'day_bet_count': betCount,
        'day_zongfs': totalRebate,
        'day_lingqu': claimedRebate,
        'day_weiling': unclaimedRebate,
        'day_zongfy': totalCommission,
        'day_lingqu_fy': claimedCommission,
        'day_weiling_fy': unclaimedCommission,
        'revenue': revenue,
        ...raw,
      };
}

class FyLevelItem {
  const FyLevelItem({
    this.vipName = '',
    this.lotteryBl,
    this.gamesBl,
    this.pokerBl,
    this.liveBl,
    this.sportBl,
    this.fishingBl,
  });

  final String vipName;
  final dynamic lotteryBl;
  final dynamic gamesBl;
  final dynamic pokerBl;
  final dynamic liveBl;
  final dynamic sportBl;
  final dynamic fishingBl;

  factory FyLevelItem.fromJson(Map<String, dynamic> json) => FyLevelItem(
        vipName: jsonString(json['vip_name']) ?? '',
        lotteryBl: json['lottery_bl'],
        gamesBl: json['games_bl'],
        pokerBl: json['poker_bl'],
        liveBl: json['live_bl'],
        sportBl: json['sport_bl'],
        fishingBl: json['fishing_bl'],
      );

  dynamic valueFor(String field) {
    return switch (field) {
      'lottery_bl' => lotteryBl,
      'games_bl' => gamesBl,
      'poker_bl' => pokerBl,
      'live_bl' => liveBl,
      'sport_bl' => sportBl,
      'fishing_bl' => fishingBl,
      _ => null,
    };
  }
}

class FyLevelPage {
  const FyLevelPage({this.levels = const []});

  final List<FyLevelItem> levels;

  factory FyLevelPage.fromResponse(Object? json) {
    final source = json is List
        ? json
        : json is Map && json['data'] is List
            ? json['data'] as List
            : const [];
    return FyLevelPage(
      levels: source
          .whereType<Map>()
          .map((item) => FyLevelItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class TeamMember {
  const TeamMember({
    required this.id,
    this.username = '',
    this.betAmount = 0,
  });

  final int id;
  final String username;
  final double betAmount;

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        id: jsonInt(json['id']) ?? 0,
        username: jsonString(json['username']) ?? '',
        betAmount: jsonDouble(json['betamount']) ?? 0,
      );
}

class TeamMemberPage {
  const TeamMemberPage({
    this.records = const [],
    this.currentPage = 1,
    this.total = 0,
    this.lastPage = 1,
  });

  final List<TeamMember> records;
  final int currentPage;
  final int total;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;

  factory TeamMemberPage.fromResponse(Object? json) {
    final map = jsonMap(json) ?? const <String, dynamic>{};
    final payload = jsonMap(map['data']) ?? map;
    final rows = payload['data'] is List ? payload['data'] as List : const [];
    return TeamMemberPage(
      records: rows
          .whereType<Map>()
          .map((item) => TeamMember.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      currentPage: jsonInt(payload['current_page']) ?? 1,
      total: jsonInt(payload['total']) ?? 0,
      lastPage: jsonInt(payload['lastPage']) ?? 1,
    );
  }

  TeamMemberPage append(TeamMemberPage next) {
    return TeamMemberPage(
      records: [...records, ...next.records],
      currentPage: next.currentPage,
      total: next.total,
      lastPage: next.lastPage,
    );
  }
}

class RebateInfo {
  const RebateInfo({
    this.totalMembers = 0,
    this.effectiveMembers = 0,
    this.claimableAmount = 0,
    this.minRecharge = 1,
    this.minEffectiveMembers = 1,
    this.nextLevelMinMembers = 0,
    this.nextLevelReward = 0,
    this.disabled = false,
    this.raw = const <String, dynamic>{},
  });

  final int totalMembers;
  final int effectiveMembers;
  final double claimableAmount;
  final double minRecharge;
  final int minEffectiveMembers;
  final int nextLevelMinMembers;
  final double nextLevelReward;
  final bool disabled;
  final Map<String, dynamic> raw;

  factory RebateInfo.fromJson(Map<String, dynamic> json) {
    return RebateInfo(
      totalMembers: jsonInt(json['user_sum']) ?? 0,
      effectiveMembers: jsonInt(json['user_youxiao']) ?? 0,
      claimableAmount: jsonDouble(json['dailingqu']) ?? 0,
      minRecharge: jsonDouble(json['zuidi']) ?? 1,
      minEffectiveMembers: jsonInt(json['user_max']) ?? 1,
      nextLevelMinMembers: jsonInt(json['user_max']) ?? 0,
      nextLevelReward: jsonDouble(json['user_amount']) ?? 0,
      disabled: jsonBool(json['disabled']) ?? false,
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_sum': totalMembers,
        'user_youxiao': effectiveMembers,
        'dailingqu': claimableAmount,
        'zuidi': minRecharge,
        'user_max': minEffectiveMembers,
        'user_amount': nextLevelReward,
        'disabled': disabled,
        ...raw,
      };
}

class RebateClaimResult {
  const RebateClaimResult({
    this.amount = 0,
    this.balance,
    this.raw = const <String, dynamic>{},
  });

  final double amount;
  final double? balance;
  final Map<String, dynamic> raw;

  factory RebateClaimResult.fromJson(Map<String, dynamic> json) {
    return RebateClaimResult(
      amount: jsonDouble(json['amount'] ?? json['money']) ?? 0,
      balance: jsonDouble(json['balance']),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        if (balance != null) 'balance': balance,
        ...raw,
      };
}

class UserProfileUpdateRequest {
  final String? img;
  final String? telegram;
  final String? realName;
  final String? phone;
  final String? areaCode;
  final String? gender;
  final String? bornTime;
  final String? qq;
  final String? email;
  final String? code;

  const UserProfileUpdateRequest({
    this.img,
    this.telegram,
    this.realName,
    this.phone,
    this.areaCode,
    this.gender,
    this.bornTime,
    this.qq,
    this.email,
    this.code,
  });

  Map<String, dynamic> toJson() => {
        if (img != null) 'img': img,
        if (telegram != null) 'telegram': telegram,
        if (realName != null) 'real_name': realName,
        if (phone != null) 'phone': phone,
        if (areaCode != null) 'area_code': areaCode,
        if (gender != null) 'gender': gender,
        if (bornTime != null) 'born_time': bornTime,
        if (qq != null) 'qq': qq,
        if (email != null) 'email': email,
        if (code != null) 'code': code,
      };
}

class SetPayPasswordRequest {
  final String payPassword;

  const SetPayPasswordRequest({required this.payPassword});

  Map<String, dynamic> toJson() => {'pay_password': payPassword};
}

class ChangePasswordRequest {
  final String currentPass;
  final String newPass;
  final String confirmPass;

  const ChangePasswordRequest({
    required this.currentPass,
    required this.newPass,
    required this.confirmPass,
  });

  Map<String, dynamic> toJson() => {
        'currentPass': currentPass,
        'newPass': newPass,
        'confirmpass': confirmPass,
      };
}

class RedemptionRecord {
  final String? code;
  final String? balance;
  final String? desc;
  final String? time;

  const RedemptionRecord({this.code, this.balance, this.desc, this.time});

  factory RedemptionRecord.fromJson(Map<String, dynamic> json) =>
      RedemptionRecord(
        code: jsonString(json['code']),
        balance: jsonString(json['balance']),
        desc: jsonString(json['desc'] ?? json['description']),
        time: jsonString(json['time'] ?? json['created_at']),
      );
}

class RedemptionRecordPage extends PaginatedData<RedemptionRecord> {
  const RedemptionRecordPage({
    super.data,
    super.total,
    super.currentPage,
    super.lastPage,
    super.perPage,
  });

  factory RedemptionRecordPage.fromResponse(Object? json) {
    if (json is Map) {
      final map = Map<String, dynamic>.from(json);
      final page = PaginatedData.fromJson(map, RedemptionRecord.fromJson);
      return RedemptionRecordPage(
        data: page.data,
        total: page.total,
        currentPage: page.currentPage,
        lastPage: page.lastPage,
        perPage: page.perPage,
      );
    }
    return const RedemptionRecordPage();
  }
}

class UserMessage {
  final int id;
  final String? title;
  final String? content;
  final String? createdAt;
  final int? type;

  const UserMessage({
    required this.id,
    this.title,
    this.content,
    this.createdAt,
    this.type,
  });

  factory UserMessage.fromJson(Map<String, dynamic> json) => UserMessage(
        id: jsonInt(json['id']) ?? 0,
        title: jsonString(json['title']),
        content: jsonString(json['text'] ?? json['content']),
        createdAt: jsonString(json['created_at']),
        type: jsonInt(json['type']),
      );

  bool get isRead => type == 2;

  Map<String, dynamic> toJson() => {
        'id': id,
        if (title != null) 'title': title,
        if (content != null) 'text': content,
        if (createdAt != null) 'created_at': createdAt,
        if (type != null) 'type': type,
      };
}

class UserMessagePage extends PaginatedData<UserMessage> {
  const UserMessagePage({
    super.data,
    super.total,
    super.currentPage,
    super.lastPage,
    super.perPage,
  });

  factory UserMessagePage.fromResponse(Object? json) {
    if (json is Map) {
      final map = Map<String, dynamic>.from(json);
      final page = PaginatedData.fromJson(map, UserMessage.fromJson);
      return UserMessagePage(
        data: page.data,
        total: page.total,
        currentPage: page.currentPage,
        lastPage: page.lastPage,
        perPage: page.perPage,
      );
    }
    return const UserMessagePage();
  }
}

class FeedbackType {
  final int id;
  final String? title;

  const FeedbackType({required this.id, this.title});

  factory FeedbackType.fromJson(Map<String, dynamic> json) => FeedbackType(
        id: jsonInt(json['id']) ?? 0,
        title: jsonString(json['title']),
      );

  Map<String, dynamic> toJson() =>
      {'id': id, if (title != null) 'title': title};
}

class SubmitFeedbackRequest {
  final int id;
  final String text;
  final String? img;

  const SubmitFeedbackRequest({
    required this.id,
    required this.text,
    this.img,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        if (img != null && img!.trim().isNotEmpty) 'img': img,
      };
}

class FeedbackRecord {
  final int id;
  final String? title;
  final String? content;
  final String? reply;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  const FeedbackRecord({
    required this.id,
    this.title,
    this.content,
    this.reply,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory FeedbackRecord.fromJson(Map<String, dynamic> json) {
    return FeedbackRecord(
      id: jsonInt(json['id']) ?? 0,
      title: jsonString(json['title']),
      content: jsonString(json['content'] ?? json['text']),
      reply: jsonString(json['reply'] ?? json['text_t']),
      image: jsonString(json['img']),
      createdAt: jsonString(json['created_at']),
      updatedAt: jsonString(json['updated_at']),
    );
  }

  bool get hasReply => reply != null && reply!.trim().isNotEmpty;

  String get statusText => hasReply
      ? 'feedback.status.processed'.tr()
      : 'feedback.status.processing'.tr();

  Map<String, dynamic> toJson() => {
        'id': id,
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (reply != null) 'reply': reply,
        if (image != null) 'img': image,
        if (createdAt != null) 'created_at': createdAt,
        if (updatedAt != null) 'updated_at': updatedAt,
      };
}

class FeedbackRecordPage extends PaginatedData<FeedbackRecord> {
  const FeedbackRecordPage({
    super.data,
    super.total,
    super.currentPage,
    super.lastPage,
    super.perPage,
  });

  factory FeedbackRecordPage.fromResponse(Object? json) {
    if (json is Map) {
      final page = PaginatedData.fromJson(
        Map<String, dynamic>.from(json),
        FeedbackRecord.fromJson,
      );
      return FeedbackRecordPage(
        data: page.data,
        total: page.total,
        currentPage: page.currentPage,
        lastPage: page.lastPage,
        perPage: page.perPage,
      );
    }
    return const FeedbackRecordPage();
  }
}
