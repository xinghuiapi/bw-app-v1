import '../core/json_utils.dart';

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
  final String? symbol;
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
    this.symbol,
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
        symbol: jsonString(json['symbol']),
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
        if (symbol != null) 'symbol': symbol,
        if (levelData != null) 'level_data': levelData!.toJson(),
      };
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
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'old_password': oldPassword,
        'password': newPassword,
        'o_password': confirmPassword,
      };
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

class FeedbackRecord {
  final int id;
  final String? title;
  final String? content;
  final String? reply;
  final int? status;
  final String? createdAt;

  const FeedbackRecord({
    required this.id,
    this.title,
    this.content,
    this.reply,
    this.status,
    this.createdAt,
  });

  factory FeedbackRecord.fromJson(Map<String, dynamic> json) {
    return FeedbackRecord(
      id: jsonInt(json['id']) ?? 0,
      title: jsonString(json['title']),
      content: jsonString(json['content'] ?? json['text']),
      reply: jsonString(json['reply']),
      status: jsonInt(json['status']),
      createdAt: jsonString(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (reply != null) 'reply': reply,
        if (status != null) 'status': status,
        if (createdAt != null) 'created_at': createdAt,
      };
}
