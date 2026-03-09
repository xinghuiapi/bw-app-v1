// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  realName: json['real_name'] as String?,
  nickname: json['nickname'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  img: json['img'] as String?,
  balance: json['balance'],
  lockBalance: json['lock_balance'],
  vipLevel: json['vip_level'],
  vip: json['vip'],
  currency: json['currency'] as String?,
  status: (json['status'] as num?)?.toInt(),
  fsStatus: (json['fs_status'] as num?)?.toInt(),
  isAgent: (json['is_agent'] as num?)?.toInt(),
  transfer: (json['transfer'] as num?)?.toInt(),
  gender: json['gender'] as String?,
  bornTime: json['born_time'] as String?,
  qq: json['qq'] as String?,
  telegram: json['telegram'] as String?,
  symbol: json['symbol'] as String?,
  totalRecharge: json['total_recharge'],
  totalDeposit: json['total_deposit'],
  rechargeAmount: json['recharge_amount'],
  totalFlow: json['total_flow'],
  flowingAmount: json['flowing_amount'],
  totalBet: json['total_bet'],
  payPassword: json['pay_password'],
  sumWater: json['sum_water'],
  okWater: json['ok_water'],
  levelData: json['level_data'] == null
      ? null
      : LevelData.fromJson(json['level_data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'real_name': instance.realName,
  'nickname': instance.nickname,
  'email': instance.email,
  'phone': instance.phone,
  'avatar_url': instance.avatarUrl,
  'img': instance.img,
  'balance': instance.balance,
  'lock_balance': instance.lockBalance,
  'vip_level': instance.vipLevel,
  'vip': instance.vip,
  'currency': instance.currency,
  'status': instance.status,
  'fs_status': instance.fsStatus,
  'is_agent': instance.isAgent,
  'transfer': instance.transfer,
  'gender': instance.gender,
  'born_time': instance.bornTime,
  'qq': instance.qq,
  'telegram': instance.telegram,
  'symbol': instance.symbol,
  'total_recharge': instance.totalRecharge,
  'total_deposit': instance.totalDeposit,
  'recharge_amount': instance.rechargeAmount,
  'total_flow': instance.totalFlow,
  'flowing_amount': instance.flowingAmount,
  'total_bet': instance.totalBet,
  'pay_password': instance.payPassword,
  'sum_water': instance.sumWater,
  'ok_water': instance.okWater,
  'level_data': instance.levelData,
};

LevelData _$LevelDataFromJson(Map<String, dynamic> json) => LevelData(
  recharge: json['recharge'],
  validBetAmount: json['validBetAmount'],
  nextRecharge: json['next_recharge'],
  nextValidBetAmount: json['next_validBetAmount'],
  gapRecharge: json['gap_recharge'],
  gapValidBetAmount: json['gap_validBetAmount'],
  vipLevel: json['vip_level'] as String?,
  nextVipLevel: json['next_vip_level'] as String?,
);

Map<String, dynamic> _$LevelDataToJson(LevelData instance) => <String, dynamic>{
  'recharge': instance.recharge,
  'validBetAmount': instance.validBetAmount,
  'next_recharge': instance.nextRecharge,
  'next_validBetAmount': instance.nextValidBetAmount,
  'gap_recharge': instance.gapRecharge,
  'gap_validBetAmount': instance.gapValidBetAmount,
  'vip_level': instance.vipLevel,
  'next_vip_level': instance.nextVipLevel,
};
