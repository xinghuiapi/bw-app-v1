import 'package:json_annotation/json_annotation.dart';

part 'user_models.g.dart';

@JsonSerializable()
class UserMessage {
  final int id;
  final String title;
  final String content;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'is_read')
  final int isRead; // 0未读，1已读

  UserMessage({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isRead,
  });

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

  factory UserRebateInfo.fromJson(Map<String, dynamic> json) => _$UserRebateInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UserRebateInfoToJson(this);
}

@JsonSerializable()
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

  factory VipLevel.fromJson(Map<String, dynamic> json) => _$VipLevelFromJson(json);
  Map<String, dynamic> toJson() => _$VipLevelToJson(this);
}
