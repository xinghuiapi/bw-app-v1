import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  @JsonKey(name: 'real_name')
  final String? realName;
  final String? nickname;
  final String? email;
  final String? phone;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  final String? img; // 头像
  final dynamic balance; // string or double
  @JsonKey(name: 'lock_balance')
  final dynamic lockBalance;
  @JsonKey(name: 'vip_level')
  final dynamic vipLevel; // VIP1, VIP2... or int
  @JsonKey(name: 'vip')
  final dynamic vip; // fallback for vip_level
  final String? currency;
  final int? status;
  @JsonKey(name: 'fs_status')
  final int? fsStatus;
  @JsonKey(name: 'is_agent')
  final int? isAgent;
  final int? transfer; // 1手动免转
  final String? gender;
  @JsonKey(name: 'born_time')
  final String? bornTime;
  final String? qq;
  final String? telegram;
  final String? symbol;
  @JsonKey(name: 'total_recharge')
  final dynamic totalRecharge;
  @JsonKey(name: 'total_deposit')
  final dynamic totalDeposit;
  @JsonKey(name: 'recharge_amount')
  final dynamic rechargeAmount;
  @JsonKey(name: 'total_flow')
  final dynamic totalFlow;
  @JsonKey(name: 'flowing_amount')
  final dynamic flowingAmount;
  @JsonKey(name: 'total_bet')
  final dynamic totalBet;
  @JsonKey(name: 'pay_password')
  final dynamic payPassword; // 可能返回 boolean, int 或 string
  @JsonKey(name: 'sum_water')
  final dynamic sumWater; // 所需流水
  @JsonKey(name: 'ok_water')
  final dynamic okWater; // 已完成流水
  @JsonKey(name: 'level_data')
  final LevelData? levelData;

  User({
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

  /// 是否已设置支付密码
  bool get hasPayPassword {
    if (payPassword == null) return false;
    if (payPassword is bool) return payPassword;
    if (payPassword is int) return payPassword == 1;
    if (payPassword is String)
      return payPassword.isNotEmpty && payPassword != '0';
    return false;
  }

  /// 获取显示的 VIP 等级
  String get displayVipLevel {
    final v = vipLevel ?? vip;
    if (v == null) return 'VIP0';
    final s = v.toString();
    if (s.startsWith('VIP')) return s;
    return 'VIP$s';
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class LevelData {
  final dynamic recharge;
  final dynamic validBetAmount;
  @JsonKey(name: 'next_recharge')
  final dynamic nextRecharge;
  @JsonKey(name: 'next_validBetAmount')
  final dynamic nextValidBetAmount;
  @JsonKey(name: 'gap_recharge')
  final dynamic gapRecharge;
  @JsonKey(name: 'gap_validBetAmount')
  final dynamic gapValidBetAmount;
  @JsonKey(name: 'vip_level')
  final String? vipLevel;
  @JsonKey(name: 'next_vip_level')
  final String? nextVipLevel;

  LevelData({
    this.recharge,
    this.validBetAmount,
    this.nextRecharge,
    this.nextValidBetAmount,
    this.gapRecharge,
    this.gapValidBetAmount,
    this.vipLevel,
    this.nextVipLevel,
  });

  factory LevelData.fromJson(Map<String, dynamic> json) =>
      _$LevelDataFromJson(json);
  Map<String, dynamic> toJson() => _$LevelDataToJson(this);
}
