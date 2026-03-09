import 'package:json_annotation/json_annotation.dart';

part 'user_models.g.dart';

@JsonSerializable()
class UserMessage {
  final int id;
  final String? title;
  @JsonKey(name: 'text')
  final String? content;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final int? type; // 1未读，2已读

  UserMessage({
    required this.id,
    this.title,
    this.content,
    this.createdAt,
    this.type,
  });

  UserMessage copyWith({
    int? id,
    String? title,
    String? content,
    String? createdAt,
    int? type,
  }) {
    return UserMessage(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
    );
  }

  bool get isRead => type == 2;

  factory UserMessage.fromJson(Map<String, dynamic> json) => _$UserMessageFromJson(json);
  Map<String, dynamic> toJson() => _$UserMessageToJson(this);
}

@JsonSerializable()
class UserProfileUpdateRequest {
  final String? img;
  final String? telegram;
  @JsonKey(name: 'real_name')
  final String? realName;
  final String? phone;
  @JsonKey(name: 'area_code')
  final String? areaCode;
  final String? gender;
  @JsonKey(name: 'born_time')
  final String? bornTime;
  final String? qq;
  final String? email;
  final String? code;

  UserProfileUpdateRequest({
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

  factory UserProfileUpdateRequest.fromJson(Map<String, dynamic> json) => _$UserProfileUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileUpdateRequestToJson(this);
}

@JsonSerializable()
class SetPayPasswordRequest {
  @JsonKey(name: 'pay_password')
  final String payPassword;

  SetPayPasswordRequest({required this.payPassword});

  factory SetPayPasswordRequest.fromJson(Map<String, dynamic> json) => _$SetPayPasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SetPayPasswordRequestToJson(this);
}

@JsonSerializable()
class BetRecord {
  final int id;
  @JsonKey(name: 'order_id')
  final String? orderId;
  @JsonKey(name: 'game_name')
  final String? gameName;
  @JsonKey(name: 'bet_amount')
  final String? betAmount;
  @JsonKey(name: 'net_amount')
  final String? netAmount;
  final String? status;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  BetRecord({
    required this.id,
    this.orderId,
    this.gameName,
    this.betAmount,
    this.netAmount,
    this.status,
    this.createdAt,
  });

  factory BetRecord.fromJson(Map<String, dynamic> json) => _$BetRecordFromJson(json);
  Map<String, dynamic> toJson() => _$BetRecordToJson(this);
}

@JsonSerializable()
class UserTransaction {
  final int id;
  @JsonKey(name: 'money_type_name')
  final String? typeName;
  final dynamic amount;
  @JsonKey(name: 'before_money')
  final dynamic beforeMoney;
  @JsonKey(name: 'after_money')
  final dynamic afterMoney;
  final String? remark;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  UserTransaction({
    required this.id,
    this.typeName,
    this.amount,
    this.beforeMoney,
    this.afterMoney,
    this.remark,
    this.createdAt,
  });

  factory UserTransaction.fromJson(Map<String, dynamic> json) => _$UserTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$UserTransactionToJson(this);
}

@JsonSerializable()
class UserRebateInfo {
  @JsonKey(name: 'user_sum')
  final int userSum;
  @JsonKey(name: 'user_youxiao')
  final int userYouxiao;
  final dynamic dailingqu;
  final dynamic zuidi;
  @JsonKey(name: 'user_max')
  final int userMax;
  @JsonKey(name: 'user_amount')
  final dynamic userAmount;

  UserRebateInfo({
    required this.userSum,
    required this.userYouxiao,
    this.dailingqu,
    this.zuidi,
    required this.userMax,
    this.userAmount,
  });

  factory UserRebateInfo.fromJson(Map<String, dynamic> json) {
    return UserRebateInfo(
      userSum: json['user_sum'] as int? ?? 0,
      userYouxiao: json['user_youxiao'] as int? ?? 0,
      dailingqu: json['dailingqu'],
      zuidi: json['zuidi'],
      userMax: json['user_max'] as int? ?? 0,
      userAmount: json['user_amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_sum': userSum,
      'user_youxiao': userYouxiao,
      'dailingqu': dailingqu,
      'zuidi': zuidi,
      'user_max': userMax,
      'user_amount': userAmount,
    };
  }
}

// @JsonSerializable()
class VipLevel {
  final int id;
  final String title;
  @JsonKey(name: 'charge_level')
  final dynamic chargeLevel;
  @JsonKey(name: 'flowing_level')
  final dynamic flowingLevel;
  @JsonKey(name: 'level_give')
  final dynamic levelGive;
  @JsonKey(name: 'week_red')
  final dynamic weekRed;
  @JsonKey(name: 'birthday_give')
  final dynamic birthdayGive;
  @JsonKey(name: 'day_count_drawing')
  final dynamic dayCountDrawing;
  @JsonKey(name: 'day_amount_drawing')
  final dynamic dayAmountDrawing;
  @JsonKey(name: 'min_drawing')
  final dynamic minDrawing;
  @JsonKey(name: 'min_recharge')
  final dynamic minRecharge;
  @JsonKey(name: 'max_recharge')
  final dynamic maxRecharge;
  @JsonKey(name: 'sport_bl')
  final dynamic sportBl;
  @JsonKey(name: 'live_bl')
  final dynamic liveBl;
  @JsonKey(name: 'games_bl')
  final dynamic gamesBl;
  @JsonKey(name: 'poker_bl')
  final dynamic pokerBl;
  @JsonKey(name: 'fishing_bl')
  final dynamic fishingBl;
  @JsonKey(name: 'lottery_bl')
  final dynamic lotteryBl;
  @JsonKey(name: 'gaming_bl')
  final dynamic gamingBl;

  VipLevel({
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
    this.sportBl,
    this.liveBl,
    this.gamesBl,
    this.pokerBl,
    this.fishingBl,
    this.lotteryBl,
    this.gamingBl,
  });

  factory VipLevel.fromJson(Map<String, dynamic> json) {
    return VipLevel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
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
      sportBl: json['sport_bl'],
      liveBl: json['live_bl'],
      gamesBl: json['games_bl'],
      pokerBl: json['poker_bl'],
      fishingBl: json['fishing_bl'],
      lotteryBl: json['lottery_bl'],
      gamingBl: json['gaming_bl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'charge_level': chargeLevel,
      'flowing_level': flowingLevel,
      'level_give': levelGive,
      'week_red': weekRed,
      'birthday_give': birthdayGive,
      'day_count_drawing': dayCountDrawing,
      'day_amount_drawing': dayAmountDrawing,
      'min_drawing': minDrawing,
      'min_recharge': minRecharge,
      'max_recharge': maxRecharge,
      'sport_bl': sportBl,
      'live_bl': liveBl,
      'games_bl': gamesBl,
      'poker_bl': pokerBl,
      'fishing_bl': fishingBl,
      'lottery_bl': lotteryBl,
      'gaming_bl': gamingBl,
    };
  }
}
