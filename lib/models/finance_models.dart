import 'package:json_annotation/json_annotation.dart';

part 'finance_models.g.dart';

@JsonSerializable()
class DepositCategory {
  final int id;
  final String name;
  final String? icon;

  DepositCategory({
    required this.id,
    required this.name,
    this.icon,
  });

  factory DepositCategory.fromJson(Map<String, dynamic> json) => _$DepositCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$DepositCategoryToJson(this);
}

@JsonSerializable()
class DepositChannel {
  final int id;
  final String name;
  final String? icon;
  final double min;
  final double max;
  final String? type; // 支付类型
  @JsonKey(name: 'bank_code')
  final String? bankCode;

  DepositChannel({
    required this.id,
    required this.name,
    this.icon,
    required this.min,
    required this.max,
    this.type,
    this.bankCode,
  });

  factory DepositChannel.fromJson(Map<String, dynamic> json) => _$DepositChannelFromJson(json);
  Map<String, dynamic> toJson() => _$DepositChannelToJson(this);
}

@JsonSerializable()
class DepositOrderRequest {
  final int id; // 通道ID
  final double money;

  DepositOrderRequest({
    required this.id,
    required this.money,
  });

  factory DepositOrderRequest.fromJson(Map<String, dynamic> json) => _$DepositOrderRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DepositOrderRequestToJson(this);
}

@JsonSerializable()
class DepositOrderResponse {
  final String? url; // 支付链接
  final String? qrcode; // 二维码内容
  @JsonKey(name: 'order_no')
  final String? orderNo;

  DepositOrderResponse({
    this.url,
    this.qrcode,
    this.orderNo,
  });

  factory DepositOrderResponse.fromJson(Map<String, dynamic> json) => _$DepositOrderResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DepositOrderResponseToJson(this);
}

@JsonSerializable()
class WithdrawRequest {
  final int id; // 卡包ID
  final double money;
  @JsonKey(name: 'pay_password')
  final String? payPassword; // 支付密码

  WithdrawRequest({
    required this.id,
    required this.money,
    this.payPassword,
  });

  factory WithdrawRequest.fromJson(Map<String, dynamic> json) => _$WithdrawRequestFromJson(json);
  Map<String, dynamic> toJson() => _$WithdrawRequestToJson(this);
}

@JsonSerializable()
class PaymentMethod {
  final int id;
  @JsonKey(name: 'bank_name')
  final String bankName;
  @JsonKey(name: 'card_number')
  final String cardNumber;
  final String? name; // 持卡人姓名
  final String? address; // 开户行地址

  PaymentMethod({
    required this.id,
    required this.bankName,
    required this.cardNumber,
    this.name,
    this.address,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => _$PaymentMethodFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);
}

@JsonSerializable()
class TradeRecord {
  final int id;
  final String? title;
  final String? order;
  @JsonKey(name: 'order_no')
  final String? orderNo;
  final String? rowid;
  final dynamic money;
  final int? status; // 0待处理，1成功，2失败
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final String? note;
  final String? remark;
  @JsonKey(name: 'interface_title')
  final String? interfaceTitle;

  TradeRecord({
    required this.id,
    this.title,
    this.order,
    this.orderNo,
    this.rowid,
    this.money,
    this.status,
    this.createdAt,
    this.note,
    this.remark,
    this.interfaceTitle,
  });

  factory TradeRecord.fromJson(Map<String, dynamic> json) => _$TradeRecordFromJson(json);
  Map<String, dynamic> toJson() => _$TradeRecordToJson(this);
}

@JsonSerializable()
class TransferRecord {
  final int id;
  final String? order;
  final dynamic money;
  final int? type; // 1: 转入, 2: 转出
  @JsonKey(name: 'from_plat')
  final String? fromPlat;
  @JsonKey(name: 'to_plat')
  final String? toPlat;
  final int? status;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'interface_title')
  final String? interfaceTitle;

  TransferRecord({
    required this.id,
    this.order,
    this.money,
    this.type,
    this.fromPlat,
    this.toPlat,
    this.status,
    this.createdAt,
    this.interfaceTitle,
  });

  factory TransferRecord.fromJson(Map<String, dynamic> json) => _$TransferRecordFromJson(json);
  Map<String, dynamic> toJson() => _$TransferRecordToJson(this);
}

@JsonSerializable()
class RebateRecord {
  final int id;
  final String? code;
  @JsonKey(name: 'api_code')
  final String? apiCode;
  @JsonKey(name: 'fs_money')
  final dynamic fsMoney;
  final dynamic money;
  final dynamic bl;
  final int? status; // 0: 未领取, 1: 已领取
  @JsonKey(name: 'created_at')
  final String? createdAt;

  RebateRecord({
    required this.id,
    this.code,
    this.apiCode,
    this.fsMoney,
    this.money,
    this.bl,
    this.status,
    this.createdAt,
  });

  factory RebateRecord.fromJson(Map<String, dynamic> json) => _$RebateRecordFromJson(json);
  Map<String, dynamic> toJson() => _$RebateRecordToJson(this);
}

@JsonSerializable()
class BankType {
  final int id;
  final String name;
  final String? code;

  BankType({
    required this.id,
    required this.name,
    this.code,
  });

  factory BankType.fromJson(Map<String, dynamic> json) => _$BankTypeFromJson(json);
  Map<String, dynamic> toJson() => _$BankTypeToJson(this);
}

@JsonSerializable()
class BindPaymentRequest {
  final int id; // 银行类型ID
  final String card; // 卡号/地址
  final String? address; // 开户地
  final String? alias; // 别名
  final String? name; // 持卡人姓名
  @JsonKey(name: 'pay_password')
  final String? payPassword;

  BindPaymentRequest({
    required this.id,
    required this.card,
    this.address,
    this.alias,
    this.name,
    this.payPassword,
  });

  factory BindPaymentRequest.fromJson(Map<String, dynamic> json) => _$BindPaymentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BindPaymentRequestToJson(this);
}

@JsonSerializable()
class TradeRecordRequest {
  final int page;
  final int size;
  final String? type; // recharge, drawing
  @JsonKey(name: 'start_date')
  final String? startDate;
  @JsonKey(name: 'end_date')
  final String? endDate;

  TradeRecordRequest({
    this.page = 1,
    this.size = 20,
    this.type,
    this.startDate,
    this.endDate,
  });

  factory TradeRecordRequest.fromJson(Map<String, dynamic> json) => _$TradeRecordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TradeRecordRequestToJson(this);
}

@JsonSerializable()
class MoneyLog {
  final int? id;
  final dynamic money;
  final dynamic before;
  final dynamic after;
  @JsonKey(name: 'before_money')
  final dynamic beforeMoney;
  @JsonKey(name: 'after_money')
  final dynamic afterMoney;
  final String? type;
  @JsonKey(name: 'type_name')
  final String? typeName;
  final String? remark;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final String? rowid;

  MoneyLog({
    this.id,
    this.money,
    this.before,
    this.after,
    this.beforeMoney,
    this.afterMoney,
    this.type,
    this.typeName,
    this.remark,
    this.createdAt,
    this.rowid,
  });

  factory MoneyLog.fromJson(Map<String, dynamic> json) => _$MoneyLogFromJson(json);
  Map<String, dynamic> toJson() => _$MoneyLogToJson(this);
}

@JsonSerializable()
class BettingRecord {
  final int id;
  @JsonKey(name: 'game_name')
  final String gameName;
  @JsonKey(name: 'bet_amount')
  final double betAmount;
  @JsonKey(name: 'win_amount')
  final double winAmount;
  @JsonKey(name: 'net_amount')
  final double netAmount;
  @JsonKey(name: 'bet_time')
  final String betTime;
  final int status;

  BettingRecord({
    required this.id,
    required this.gameName,
    required this.betAmount,
    required this.winAmount,
    required this.netAmount,
    required this.betTime,
    required this.status,
  });

  factory BettingRecord.fromJson(Map<String, dynamic> json) => _$BettingRecordFromJson(json);
  Map<String, dynamic> toJson() => _$BettingRecordToJson(this);
}
