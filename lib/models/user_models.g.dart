// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserMessage _$UserMessageFromJson(Map<String, dynamic> json) => UserMessage(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String?,
  content: json['text'] as String?,
  createdAt: json['created_at'] as String?,
  type: (json['type'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserMessageToJson(UserMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'text': instance.content,
      'created_at': instance.createdAt,
      'type': instance.type,
    };

UserProfileUpdateRequest _$UserProfileUpdateRequestFromJson(
  Map<String, dynamic> json,
) => UserProfileUpdateRequest(
  img: json['img'] as String?,
  telegram: json['telegram'] as String?,
  realName: json['real_name'] as String?,
  phone: json['phone'] as String?,
  areaCode: json['area_code'] as String?,
  gender: json['gender'] as String?,
  bornTime: json['born_time'] as String?,
  qq: json['qq'] as String?,
  email: json['email'] as String?,
  code: json['code'] as String?,
);

Map<String, dynamic> _$UserProfileUpdateRequestToJson(
  UserProfileUpdateRequest instance,
) => <String, dynamic>{
  'img': instance.img,
  'telegram': instance.telegram,
  'real_name': instance.realName,
  'phone': instance.phone,
  'area_code': instance.areaCode,
  'gender': instance.gender,
  'born_time': instance.bornTime,
  'qq': instance.qq,
  'email': instance.email,
  'code': instance.code,
};

SetPayPasswordRequest _$SetPayPasswordRequestFromJson(
  Map<String, dynamic> json,
) => SetPayPasswordRequest(payPassword: json['pay_password'] as String);

Map<String, dynamic> _$SetPayPasswordRequestToJson(
  SetPayPasswordRequest instance,
) => <String, dynamic>{'pay_password': instance.payPassword};

FavoriteToggleRequest _$FavoriteToggleRequestFromJson(
  Map<String, dynamic> json,
) => FavoriteToggleRequest(gameId: (json['game_id'] as num).toInt());

Map<String, dynamic> _$FavoriteToggleRequestToJson(
  FavoriteToggleRequest instance,
) => <String, dynamic>{'game_id': instance.gameId};

BetRecord _$BetRecordFromJson(Map<String, dynamic> json) => BetRecord(
  id: (json['id'] as num).toInt(),
  orderId: json['order_id'] as String?,
  gameName: json['game_name'] as String?,
  betAmount: json['bet_amount'] as String?,
  netAmount: json['net_amount'] as String?,
  status: json['status'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$BetRecordToJson(BetRecord instance) => <String, dynamic>{
  'id': instance.id,
  'order_id': instance.orderId,
  'game_name': instance.gameName,
  'bet_amount': instance.betAmount,
  'net_amount': instance.netAmount,
  'status': instance.status,
  'created_at': instance.createdAt,
};

UserTransaction _$UserTransactionFromJson(Map<String, dynamic> json) =>
    UserTransaction(
      id: (json['id'] as num).toInt(),
      typeName: json['money_type_name'] as String?,
      amount: json['amount'],
      beforeMoney: json['before_money'],
      afterMoney: json['after_money'],
      remark: json['remark'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$UserTransactionToJson(UserTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'money_type_name': instance.typeName,
      'amount': instance.amount,
      'before_money': instance.beforeMoney,
      'after_money': instance.afterMoney,
      'remark': instance.remark,
      'created_at': instance.createdAt,
    };

UserRebateInfo _$UserRebateInfoFromJson(Map<String, dynamic> json) =>
    UserRebateInfo(
      userSum: (json['user_sum'] as num).toInt(),
      userYouxiao: (json['user_youxiao'] as num).toInt(),
      dailingqu: json['dailingqu'],
      zuidi: json['zuidi'],
      userMax: (json['user_max'] as num).toInt(),
      userAmount: json['user_amount'],
    );

Map<String, dynamic> _$UserRebateInfoToJson(UserRebateInfo instance) =>
    <String, dynamic>{
      'user_sum': instance.userSum,
      'user_youxiao': instance.userYouxiao,
      'dailingqu': instance.dailingqu,
      'zuidi': instance.zuidi,
      'user_max': instance.userMax,
      'user_amount': instance.userAmount,
    };
