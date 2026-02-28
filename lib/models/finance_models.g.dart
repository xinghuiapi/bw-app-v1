// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepositCategory _$DepositCategoryFromJson(Map<String, dynamic> json) =>
    DepositCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$DepositCategoryToJson(DepositCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
    };

DepositChannel _$DepositChannelFromJson(Map<String, dynamic> json) =>
    DepositChannel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      icon: json['icon'] as String?,
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      type: json['type'] as String?,
      bankCode: json['bank_code'] as String?,
    );

Map<String, dynamic> _$DepositChannelToJson(DepositChannel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'min': instance.min,
      'max': instance.max,
      'type': instance.type,
      'bank_code': instance.bankCode,
    };

DepositOrderRequest _$DepositOrderRequestFromJson(Map<String, dynamic> json) =>
    DepositOrderRequest(
      id: (json['id'] as num).toInt(),
      money: (json['money'] as num).toDouble(),
    );

Map<String, dynamic> _$DepositOrderRequestToJson(
  DepositOrderRequest instance,
) => <String, dynamic>{'id': instance.id, 'money': instance.money};

DepositOrderResponse _$DepositOrderResponseFromJson(
  Map<String, dynamic> json,
) => DepositOrderResponse(
  url: json['url'] as String?,
  qrcode: json['qrcode'] as String?,
  orderNo: json['order_no'] as String?,
);

Map<String, dynamic> _$DepositOrderResponseToJson(
  DepositOrderResponse instance,
) => <String, dynamic>{
  'url': instance.url,
  'qrcode': instance.qrcode,
  'order_no': instance.orderNo,
};

WithdrawRequest _$WithdrawRequestFromJson(Map<String, dynamic> json) =>
    WithdrawRequest(
      id: (json['id'] as num).toInt(),
      money: (json['money'] as num).toDouble(),
      payPassword: json['pay_password'] as String?,
    );

Map<String, dynamic> _$WithdrawRequestToJson(WithdrawRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'money': instance.money,
      'pay_password': instance.payPassword,
    };

PaymentMethod _$PaymentMethodFromJson(Map<String, dynamic> json) =>
    PaymentMethod(
      id: (json['id'] as num).toInt(),
      bankName: json['bank_name'] as String,
      cardNumber: json['card_number'] as String,
      name: json['name'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$PaymentMethodToJson(PaymentMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bank_name': instance.bankName,
      'card_number': instance.cardNumber,
      'name': instance.name,
      'address': instance.address,
    };

TradeRecord _$TradeRecordFromJson(Map<String, dynamic> json) => TradeRecord(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String?,
  order: json['order'] as String?,
  orderNo: json['order_no'] as String?,
  rowid: json['rowid'] as String?,
  money: json['money'],
  status: (json['status'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
  note: json['note'] as String?,
  remark: json['remark'] as String?,
  interfaceTitle: json['interface_title'] as String?,
);

Map<String, dynamic> _$TradeRecordToJson(TradeRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'order': instance.order,
      'order_no': instance.orderNo,
      'rowid': instance.rowid,
      'money': instance.money,
      'status': instance.status,
      'created_at': instance.createdAt,
      'note': instance.note,
      'remark': instance.remark,
      'interface_title': instance.interfaceTitle,
    };

TransferRecord _$TransferRecordFromJson(Map<String, dynamic> json) =>
    TransferRecord(
      id: (json['id'] as num).toInt(),
      order: json['order'] as String?,
      money: json['money'],
      type: (json['type'] as num?)?.toInt(),
      fromPlat: json['from_plat'] as String?,
      toPlat: json['to_plat'] as String?,
      status: (json['status'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      interfaceTitle: json['interface_title'] as String?,
    );

Map<String, dynamic> _$TransferRecordToJson(TransferRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order': instance.order,
      'money': instance.money,
      'type': instance.type,
      'from_plat': instance.fromPlat,
      'to_plat': instance.toPlat,
      'status': instance.status,
      'created_at': instance.createdAt,
      'interface_title': instance.interfaceTitle,
    };

RebateRecord _$RebateRecordFromJson(Map<String, dynamic> json) => RebateRecord(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String?,
  apiCode: json['api_code'] as String?,
  fsMoney: json['fs_money'],
  money: json['money'],
  bl: json['bl'],
  status: (json['status'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$RebateRecordToJson(RebateRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'api_code': instance.apiCode,
      'fs_money': instance.fsMoney,
      'money': instance.money,
      'bl': instance.bl,
      'status': instance.status,
      'created_at': instance.createdAt,
    };

BankType _$BankTypeFromJson(Map<String, dynamic> json) => BankType(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String?,
);

Map<String, dynamic> _$BankTypeToJson(BankType instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
};

BindPaymentRequest _$BindPaymentRequestFromJson(Map<String, dynamic> json) =>
    BindPaymentRequest(
      id: (json['id'] as num).toInt(),
      card: json['card'] as String,
      address: json['address'] as String?,
      alias: json['alias'] as String?,
      name: json['name'] as String?,
      payPassword: json['pay_password'] as String?,
    );

Map<String, dynamic> _$BindPaymentRequestToJson(BindPaymentRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'card': instance.card,
      'address': instance.address,
      'alias': instance.alias,
      'name': instance.name,
      'pay_password': instance.payPassword,
    };

TradeRecordRequest _$TradeRecordRequestFromJson(Map<String, dynamic> json) =>
    TradeRecordRequest(
      page: (json['page'] as num?)?.toInt() ?? 1,
      size: (json['size'] as num?)?.toInt() ?? 20,
      type: json['type'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
    );

Map<String, dynamic> _$TradeRecordRequestToJson(TradeRecordRequest instance) =>
    <String, dynamic>{
      'page': instance.page,
      'size': instance.size,
      'type': instance.type,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
    };

MoneyLog _$MoneyLogFromJson(Map<String, dynamic> json) => MoneyLog(
  id: (json['id'] as num?)?.toInt(),
  money: json['money'],
  before: json['before'],
  after: json['after'],
  beforeMoney: json['before_money'],
  afterMoney: json['after_money'],
  type: json['type'] as String?,
  typeName: json['type_name'] as String?,
  remark: json['remark'] as String?,
  createdAt: json['created_at'] as String?,
  rowid: json['rowid'] as String?,
);

Map<String, dynamic> _$MoneyLogToJson(MoneyLog instance) => <String, dynamic>{
  'id': instance.id,
  'money': instance.money,
  'before': instance.before,
  'after': instance.after,
  'before_money': instance.beforeMoney,
  'after_money': instance.afterMoney,
  'type': instance.type,
  'type_name': instance.typeName,
  'remark': instance.remark,
  'created_at': instance.createdAt,
  'rowid': instance.rowid,
};

BettingRecord _$BettingRecordFromJson(Map<String, dynamic> json) =>
    BettingRecord(
      id: (json['id'] as num).toInt(),
      gameName: json['game_name'] as String,
      betAmount: (json['bet_amount'] as num).toDouble(),
      winAmount: (json['win_amount'] as num).toDouble(),
      netAmount: (json['net_amount'] as num).toDouble(),
      betTime: json['bet_time'] as String,
      status: (json['status'] as num).toInt(),
    );

Map<String, dynamic> _$BettingRecordToJson(BettingRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'game_name': instance.gameName,
      'bet_amount': instance.betAmount,
      'win_amount': instance.winAmount,
      'net_amount': instance.netAmount,
      'bet_time': instance.betTime,
      'status': instance.status,
    };
