// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepositCategory _$DepositCategoryFromJson(Map<String, dynamic> json) =>
    DepositCategory(
      id: (json['id'] as num).toInt(),
      name: json['title'] as String?,
      icon: json['img'] as String?,
      msg: json['msg'] as String?,
      code: json['code'] as String?,
    );

Map<String, dynamic> _$DepositCategoryToJson(DepositCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.name,
      'img': instance.icon,
      'msg': instance.msg,
      'code': instance.code,
    };

TransferCategory _$TransferCategoryFromJson(Map<String, dynamic> json) =>
    TransferCategory(
      id: (json['id'] as num).toInt(),
      name: json['title'] as String?,
      code: json['code'] as String?,
      icon: json['icon'] as String?,
      pcLogo: json['pc_logo'] as String?,
    );

Map<String, dynamic> _$TransferCategoryToJson(TransferCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.name,
      'code': instance.code,
      'icon': instance.icon,
      'pc_logo': instance.pcLogo,
    };

GameBalance _$GameBalanceFromJson(Map<String, dynamic> json) => GameBalance(
  id: (json['id'] as num).toInt(),
  money: json['money'],
  title: json['title'] as String?,
);

Map<String, dynamic> _$GameBalanceToJson(GameBalance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'money': instance.money,
      'title': instance.title,
    };

TransferMoneyRequest _$TransferMoneyRequestFromJson(
  Map<String, dynamic> json,
) => TransferMoneyRequest(
  id: (json['id'] as num).toInt(),
  money: (json['money'] as num).toInt(),
);

Map<String, dynamic> _$TransferMoneyRequestToJson(
  TransferMoneyRequest instance,
) => <String, dynamic>{'id': instance.id, 'money': instance.money};

DepositChannel _$DepositChannelFromJson(Map<String, dynamic> json) =>
    DepositChannel(
      id: (json['id'] as num).toInt(),
      name: json['title'] as String?,
      icon: json['icon'] as String?,
      min: _stringToDouble(json['min']),
      max: _stringToDouble(json['max']),
      type: json['type'] as String?,
      bankCode: json['bank_code'] as String?,
      amountType: (json['amount_type'] as num?)?.toInt(),
      amount: json['amount'] as List<dynamic>?,
      giveType: (json['give_type'] as num?)?.toInt(),
      giveMoney: _stringToDouble(json['give_money']),
    );

Map<String, dynamic> _$DepositChannelToJson(DepositChannel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.name,
      'icon': instance.icon,
      'min': instance.min,
      'max': instance.max,
      'type': instance.type,
      'bank_code': instance.bankCode,
      'amount_type': instance.amountType,
      'amount': instance.amount,
      'give_type': instance.giveType,
      'give_money': instance.giveMoney,
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
  id: (json['id'] as num?)?.toInt(),
  orderId: (json['order_id'] as num?)?.toInt(),
  data: json['data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$DepositOrderResponseToJson(
  DepositOrderResponse instance,
) => <String, dynamic>{
  'url': instance.url,
  'qrcode': instance.qrcode,
  'order_no': instance.orderNo,
  'id': instance.id,
  'order_id': instance.orderId,
  'data': instance.data,
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
      card: json['card'] as String?,
      img: json['img'] as String?,
      qrcode: json['qrcode'] as String?,
      alias: json['alias'] as String?,
      title: json['title'] as String?,
      rete: json['rete'],
      type: (json['type'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      bankName: json['bank_name'] as String?,
      cardNumber: json['card_number'] as String?,
      name: json['name'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$PaymentMethodToJson(PaymentMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'card': instance.card,
      'img': instance.img,
      'qrcode': instance.qrcode,
      'alias': instance.alias,
      'title': instance.title,
      'rete': instance.rete,
      'type': instance.type,
      'status': instance.status,
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
  username: json['username'] as String?,
  code: json['code'] as String?,
  apiCode: json['api_code'] as String?,
  apiCodeTitle: json['api_code_title'] as String?,
  fsMoney: json['fs_money'],
  money: json['money'],
  bl: json['bl'],
  status: (json['status'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$RebateRecordToJson(RebateRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'code': instance.code,
      'api_code': instance.apiCode,
      'api_code_title': instance.apiCodeTitle,
      'fs_money': instance.fsMoney,
      'money': instance.money,
      'bl': instance.bl,
      'status': instance.status,
      'created_at': instance.createdAt,
    };

RebateData _$RebateDataFromJson(Map<String, dynamic> json) => RebateData(
  userSum: (json['user_sum'] as num).toInt(),
  userYouxiao: (json['user_youxiao'] as num).toInt(),
  dailingqu: (json['dailingqu'] as num).toDouble(),
  zuidi: json['zuidi'] as String,
  userMax: (json['user_max'] as num).toInt(),
  userAmount: (json['user_amount'] as num).toDouble(),
);

Map<String, dynamic> _$RebateDataToJson(RebateData instance) =>
    <String, dynamic>{
      'user_sum': instance.userSum,
      'user_youxiao': instance.userYouxiao,
      'dailingqu': instance.dailingqu,
      'zuidi': instance.zuidi,
      'user_max': instance.userMax,
      'user_amount': instance.userAmount,
    };

RechargeParams _$RechargeParamsFromJson(Map<String, dynamic> json) =>
    RechargeParams(
      merchant: json['merchant'] as String?,
      payKey: json['pay_key'] as String?,
      payUrl: json['pay_url'] as String?,
      payCode: json['pay_code'] as String?,
      code: json['code'] as String?,
      name: json['name'] as String?,
      account: json['account'] as String?,
      addres: json['addres'] as String?,
      bankName: json['bank_name'] as String?,
      bank: json['bank'] as String?,
      card: json['card'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$RechargeParamsToJson(RechargeParams instance) =>
    <String, dynamic>{
      'merchant': instance.merchant,
      'pay_key': instance.payKey,
      'pay_url': instance.payUrl,
      'pay_code': instance.payCode,
      'code': instance.code,
      'name': instance.name,
      'account': instance.account,
      'addres': instance.addres,
      'bank_name': instance.bankName,
      'bank': instance.bank,
      'card': instance.card,
      'address': instance.address,
    };

RechargeDetail _$RechargeDetailFromJson(Map<String, dynamic> json) =>
    RechargeDetail(
      params: json['params'] == null
          ? null
          : RechargeParams.fromJson(json['params'] as Map<String, dynamic>),
      money: _stringToDouble(json['money']),
      hl: _stringToDoubleNullable(json['hl']),
      usdtMoney: _stringToDoubleNullable(json['usdt_money']),
      img: json['img'] as String?,
      currency: json['currency'] as String?,
      msg: json['msg'] as String?,
      type: _stringToIntNullable(json['type']),
    );

Map<String, dynamic> _$RechargeDetailToJson(RechargeDetail instance) =>
    <String, dynamic>{
      'params': instance.params,
      'money': instance.money,
      'hl': instance.hl,
      'usdt_money': instance.usdtMoney,
      'img': instance.img,
      'currency': instance.currency,
      'msg': instance.msg,
      'type': instance.type,
    };

BankType _$BankTypeFromJson(Map<String, dynamic> json) => BankType(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String?,
  title: json['title'] as String?,
  code: json['code'] as String?,
  img: json['img'] as String?,
);

Map<String, dynamic> _$BankTypeToJson(BankType instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'code': instance.code,
  'img': instance.img,
  'name': instance.name,
};

BindPaymentRequest _$BindPaymentRequestFromJson(Map<String, dynamic> json) =>
    BindPaymentRequest(
      id: (json['id'] as num).toInt(),
      card: json['card'] as String,
      address: json['addres'] as String?,
      alias: json['alias'] as String?,
      name: json['name'] as String?,
      img: json['img'] as String?,
      payPassword: json['pay_password'] as String?,
    );

Map<String, dynamic> _$BindPaymentRequestToJson(BindPaymentRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'card': instance.card,
      'addres': instance.address,
      'alias': instance.alias,
      'name': instance.name,
      'img': instance.img,
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
  type: json['type'],
  typeName: json['type_name'],
  moneyTypeId: json['money_type_id'],
  remark: json['remark'],
  note: json['note'],
  createdAt: json['created_at'],
  rowid: json['rowid'],
  order: json['order'],
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
  'money_type_id': instance.moneyTypeId,
  'remark': instance.remark,
  'note': instance.note,
  'created_at': instance.createdAt,
  'rowid': instance.rowid,
  'order': instance.order,
};
