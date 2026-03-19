import 'package:json_annotation/json_annotation.dart';

part 'finance_models.g.dart';

@JsonSerializable()
class DepositCategory {
  final int id;
  @JsonKey(name: 'title')
  final String? name;
  @JsonKey(name: 'img')
  final String? icon;
  final String? msg; // 角标信息
  final String? code;

  DepositCategory({
    required this.id,
    this.name,
    this.icon,
    this.msg,
    this.code,
  });

  factory DepositCategory.fromJson(Map<String, dynamic> json) =>
      _$DepositCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$DepositCategoryToJson(this);
}

@JsonSerializable()
class TransferCategory {
  final int id;
  @JsonKey(name: 'title')
  final String? name;
  final String? code;
  final String? icon;
  @JsonKey(name: 'pc_logo')
  final String? pcLogo; // 用于转账页面显示的 Logo

  TransferCategory({
    required this.id,
    this.name,
    this.code,
    this.icon,
    this.pcLogo,
  });

  factory TransferCategory.fromJson(Map<String, dynamic> json) =>
      _$TransferCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$TransferCategoryToJson(this);
}

@JsonSerializable()
class GameBalance {
  final int id;
  final dynamic money;
  final String? title;

  GameBalance({required this.id, this.money, this.title});

  double get balance => _stringToDouble(money);

  factory GameBalance.fromJson(Map<String, dynamic> json) =>
      _$GameBalanceFromJson(json);
  Map<String, dynamic> toJson() => _$GameBalanceToJson(this);
}

@JsonSerializable()
class TransferMoneyRequest {
  final int id; // 平台/分类 ID
  final int money; // 转账金额，通常为整数
  TransferMoneyRequest({required this.id, required this.money});

  factory TransferMoneyRequest.fromJson(Map<String, dynamic> json) =>
      _$TransferMoneyRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TransferMoneyRequestToJson(this);
}

@JsonSerializable()
class DepositChannel {
  final int id;
  @JsonKey(name: 'title')
  final String? name;
  final String? icon;
  @JsonKey(fromJson: _stringToDouble)
  final double min;
  @JsonKey(fromJson: _stringToDouble)
  final double max;
  final String? type; // 支付类型
  @JsonKey(name: 'bank_code')
  final String? bankCode;
  @JsonKey(name: 'amount_type')
  final int? amountType; // 1:任意金额, 2:固定金额
  final List<dynamic>? amount; // 固定金额列表 (API可能返回数字或字符串列表)
  @JsonKey(name: 'give_type')
  final int? giveType; // 赠送类型: 1金额, 2比例, 3固定金额
  @JsonKey(name: 'give_money', fromJson: _stringToDouble)
  final double? giveMoney; // 赠送金额或比例

  DepositChannel({
    required this.id,
    required this.name,
    this.icon,
    required this.min,
    required this.max,
    this.type,
    this.bankCode,
    this.amountType,
    this.amount,
    this.giveType,
    this.giveMoney,
  });

  factory DepositChannel.fromJson(Map<String, dynamic> json) =>
      _$DepositChannelFromJson(json);
  Map<String, dynamic> toJson() => _$DepositChannelToJson(this);
}

@JsonSerializable()
class DepositOrderRequest {
  final int id; // 通道ID
  final double money;

  DepositOrderRequest({required this.id, required this.money});

  factory DepositOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$DepositOrderRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DepositOrderRequestToJson(this);
}

@JsonSerializable()
class DepositOrderResponse {
  final String? url; // 支付链接
  final String? qrcode; // 二维码内容
  @JsonKey(name: 'order_no')
  final String? orderNo;
  final int? id; // 订单ID (用于跳转详情)
  @JsonKey(name: 'order_id')
  final int? orderId; // 某些接口可能返回 order_id
  final Map<String, dynamic>? data; // 兼容 {code: 200, data: {data: {...}}} 的嵌套结构
  DepositOrderResponse({
    this.url,
    this.qrcode,
    this.orderNo,
    this.id,
    this.orderId,
    this.data,
  });

  factory DepositOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$DepositOrderResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DepositOrderResponseToJson(this);
}

@JsonSerializable()
class WithdrawRequest {
  final int id; // 卡包ID
  final double money;
  @JsonKey(name: 'pay_password')
  final String? payPassword; // 支付密码

  WithdrawRequest({required this.id, required this.money, this.payPassword});

  factory WithdrawRequest.fromJson(Map<String, dynamic> json) =>
      _$WithdrawRequestFromJson(json);
  Map<String, dynamic> toJson() => _$WithdrawRequestToJson(this);
}

@JsonSerializable()
class PaymentMethod {
  final int id;
  final String? card;
  final String? img;
  final String? qrcode;
  final String? alias;
  final String? title;
  final dynamic rete;
  final int? type;
  final int? status; // 0: 禁用, 1: 正常, 2: 待审核
  @JsonKey(name: 'bank_name')
  final String? bankName;
  @JsonKey(name: 'card_number')
  final String? cardNumber;
  final String? name; // 持卡人姓名
  final String? address; // 开户行地址

  PaymentMethod({
    required this.id,
    this.card,
    this.img,
    this.qrcode,
    this.alias,
    this.title,
    this.rete,
    this.type,
    this.status,
    this.bankName,
    this.cardNumber,
    this.name,
    this.address,
  });

  String get displayCard => card ?? cardNumber ?? '';
  String get displayTitle => title ?? bankName ?? '';

  factory PaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodFromJson(json);
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

  factory TradeRecord.fromJson(Map<String, dynamic> json) =>
      _$TradeRecordFromJson(json);
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

  factory TransferRecord.fromJson(Map<String, dynamic> json) =>
      _$TransferRecordFromJson(json);
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
  final int? status; // 0: 未领取 1: 已领取
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

  factory RebateRecord.fromJson(Map<String, dynamic> json) =>
      _$RebateRecordFromJson(json);
  Map<String, dynamic> toJson() => _$RebateRecordToJson(this);
}

@JsonSerializable()
class RebateData {
  @JsonKey(name: 'user_sum')
  final int userSum;
  @JsonKey(name: 'user_youxiao')
  final int userYouxiao;
  final double dailingqu;
  final String zuidi;
  @JsonKey(name: 'user_max')
  final int userMax;
  @JsonKey(name: 'user_amount')
  final double userAmount;

  RebateData({
    required this.userSum,
    required this.userYouxiao,
    required this.dailingqu,
    required this.zuidi,
    required this.userMax,
    required this.userAmount,
  });

  factory RebateData.fromJson(Map<String, dynamic> json) =>
      _$RebateDataFromJson(json);
  Map<String, dynamic> toJson() => _$RebateDataToJson(this);
}

@JsonSerializable()
class RechargeParams {
  final String? merchant;
  @JsonKey(name: 'pay_key')
  final String? payKey;
  @JsonKey(name: 'pay_url')
  final String? payUrl;
  @JsonKey(name: 'pay_code')
  final String? payCode;
  final String? code;
  final String? name; // 持卡人姓名
  final String? account; // 银行卡号
  final String? addres; // 可能的拼写错误
  @JsonKey(name: 'bank_name')
  final String? bankName; // 银行名称
  final String? bank;
  final String? card;
  final String? address; // 开户行地址

  RechargeParams({
    this.merchant,
    this.payKey,
    this.payUrl,
    this.payCode,
    this.code,
    this.name,
    this.account,
    this.addres,
    this.bankName,
    this.bank,
    this.card,
    this.address,
  });

  factory RechargeParams.fromJson(Map<String, dynamic> json) =>
      _$RechargeParamsFromJson(json);
  Map<String, dynamic> toJson() => _$RechargeParamsToJson(this);
}

@JsonSerializable()
class RechargeDetail {
  @JsonKey(includeFromJson: false)
  final int id; // 默认 0，Provider 负责填充

  final RechargeParams? params;

  @JsonKey(fromJson: _stringToDouble)
  final double money;

  @JsonKey(fromJson: _stringToDoubleNullable)
  final double? hl; // 汇率?

  @JsonKey(name: 'usdt_money', fromJson: _stringToDoubleNullable)
  final double? usdtMoney;

  final String? img; // 二维码图片链接
  final String? currency;
  final String? msg; // 提示语
  @JsonKey(fromJson: _stringToIntNullable)
  final int? type; // 支付类型

  // 兼容旧字段 of Getter
  String? get order => null; // 订单号未知
  int? get status => 0; // 默认状态
  String? get createdAt => null;
  String? get qrcode => img; // UI 使用 qrcode
  String? get bankName => params?.bankName ?? params?.bank;
  String? get bankCard => params?.account ?? params?.card;
  String? get bankUser => params?.name;
  String? get bankAddr => params?.address ?? params?.addres;
  String? get remark => msg; // 提示语兼容旧字段

  RechargeDetail({
    this.id = 0,
    this.params,
    required this.money,
    this.hl,
    this.usdtMoney,
    this.img,
    this.currency,
    this.msg,
    this.type,
  });

  factory RechargeDetail.fromJson(Map<String, dynamic> json) =>
      _$RechargeDetailFromJson(json);
  Map<String, dynamic> toJson() => _$RechargeDetailToJson(this);

  RechargeDetail copyWith({
    int? id,
    RechargeParams? params,
    double? money,
    double? hl,
    double? usdtMoney,
    String? img,
    String? currency,
    String? msg,
    int? type,
  }) {
    return RechargeDetail(
      id: id ?? this.id,
      params: params ?? this.params,
      money: money ?? this.money,
      hl: hl ?? this.hl,
      usdtMoney: usdtMoney ?? this.usdtMoney,
      img: img ?? this.img,
      currency: currency ?? this.currency,
      msg: msg ?? this.msg,
      type: type ?? this.type,
    );
  }
}

@JsonSerializable()
class BankType {
  final int id;
  @JsonKey(name: 'name')
  final String? _name;
  @JsonKey(name: 'title')
  final String? title;
  final String? code;
  final String? img;

  String get name => _name ?? title ?? '';

  BankType({required this.id, String? name, this.title, this.code, this.img})
    : _name = name;

  factory BankType.fromJson(Map<String, dynamic> json) =>
      _$BankTypeFromJson(json);
  Map<String, dynamic> toJson() => _$BankTypeToJson(this);
}

@JsonSerializable()
class BindPaymentRequest {
  final int id; // 银行类型ID
  final String card; // 卡号/地址
  @JsonKey(name: 'addres')
  final String? address; // 接口拼写为 addres
  final String? alias; // 别名
  final String? name; // 持卡人姓名
  final String? img; // 二维码地址
  @JsonKey(name: 'pay_password')
  final String? payPassword;

  BindPaymentRequest({
    required this.id,
    required this.card,
    this.address,
    this.alias,
    this.name,
    this.img,
    this.payPassword,
  });

  factory BindPaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$BindPaymentRequestFromJson(json);
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

  factory TradeRecordRequest.fromJson(Map<String, dynamic> json) =>
      _$TradeRecordRequestFromJson(json);
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

  factory MoneyLog.fromJson(Map<String, dynamic> json) =>
      _$MoneyLogFromJson(json);
  Map<String, dynamic> toJson() => _$MoneyLogToJson(this);
}

// @JsonSerializable()
class BettingRecord {
  final int id;
  @JsonKey(name: 'game_name')
  final String? gameName;
  @JsonKey(name: 'bet_amount', fromJson: _stringToDouble)
  final double betAmount;
  @JsonKey(name: 'win_amount', fromJson: _stringToDouble)
  final double winAmount;
  @JsonKey(name: 'net_amount', fromJson: _stringToDouble)
  final double netAmount;
  @JsonKey(name: 'bet_time')
  final String? betTime;
  final int status;
  final String? code;
  @JsonKey(name: 'interface_title')
  final String? interfaceTitle;
  final String? title;
  final String? rowid;

  BettingRecord({
    required this.id,
    this.gameName,
    required this.betAmount,
    required this.winAmount,
    required this.netAmount,
    this.betTime,
    required this.status,
    this.code,
    this.interfaceTitle,
    this.title,
    this.rowid,
  });

  factory BettingRecord.fromJson(Map<String, dynamic> json) {
    return BettingRecord(
      id: json['id'] as int? ?? 0,
      gameName: json['game_name'] as String?,
      betAmount: _stringToDouble(json['bet_amount']),
      winAmount: _stringToDouble(json['win_amount']),
      netAmount: _stringToDouble(json['net_amount']),
      betTime: json['bet_time'] as String?,
      status: json['status'] as int? ?? 0,
      code: json['code'] as String?,
      interfaceTitle: json['interface_title'] as String?,
      title: json['title'] as String?,
      rowid: json['rowid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game_name': gameName,
      'bet_amount': betAmount,
      'win_amount': winAmount,
      'net_amount': netAmount,
      'bet_time': betTime,
      'status': status,
      'code': code,
      'interface_title': interfaceTitle,
      'title': title,
      'rowid': rowid,
    };
  }
}

// 辅助函数：将 String 或 num 转换为 double
double _stringToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

// 辅助函数：将 String 或 num 转换为 double (可空)
double? _stringToDoubleNullable(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

// 辅助函数：将 String 或 num 转换为 int (可空)
int? _stringToIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
