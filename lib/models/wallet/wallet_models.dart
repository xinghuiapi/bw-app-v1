import '../core/json_utils.dart';

class WalletCard {
  final int id;
  final String? card;
  final String? img;
  final String? qrcode;
  final String? alias;
  final String? title;
  final dynamic rate;
  final int? type;
  final int? status;
  final String? bankName;
  final String? cardNumber;
  final String? name;
  final String? address;

  const WalletCard({
    required this.id,
    this.card,
    this.img,
    this.qrcode,
    this.alias,
    this.title,
    this.rate,
    this.type,
    this.status,
    this.bankName,
    this.cardNumber,
    this.name,
    this.address,
  });

  factory WalletCard.fromJson(Map<String, dynamic> json) => WalletCard(
        id: jsonInt(json['id']) ?? 0,
        card: jsonString(json['card']),
        img: jsonString(json['img']),
        qrcode: jsonString(json['qrcode']),
        alias: jsonString(json['alias']),
        title: jsonString(json['title']),
        rate: json['rete'] ?? json['rate'],
        type: jsonInt(json['type']),
        status: jsonInt(json['status']),
        bankName: jsonString(json['bank_name']),
        cardNumber: jsonString(json['card_number']),
        name: jsonString(json['name']),
        address: jsonString(json['address'] ?? json['addres']),
      );

  String get displayCard => card ?? cardNumber ?? '';
  String get displayTitle => title ?? bankName ?? '';
  String get displayAlias => alias ?? name ?? '';
  String get imageUrl => img?.trim() ?? '';
  String get qrCodeUrl => qrcode?.trim() ?? '';
  bool get isBankCard => type == 1;
  bool get isCrypto => type == 2;
  bool get isAlipay => type == 3;

  String get typeName {
    if (isBankCard) return '银行卡';
    if (isCrypto) return '虚拟币';
    if (isAlipay) return '支付宝';
    final titleValue = displayTitle;
    if (RegExp(r'USDT|TRC20|ERC20|BTC|ETH', caseSensitive: false)
        .hasMatch(titleValue)) {
      return '虚拟币';
    }
    if (titleValue.contains('支付宝')) return '支付宝';
    return '收款账户';
  }

  String get maskedCard {
    final value = displayCard.trim();
    if (value.isEmpty) return '';
    if (value.length <= 4) return value;
    if (isCrypto || typeName == '虚拟币') {
      final head = value.length > 6 ? value.substring(0, 6) : value;
      final tailLength = value.length >= 6 ? 6 : value.length;
      final tail = value.substring(value.length - tailLength);
      return value.length <= 12 ? value : '$head...$tail';
    }
    return '**** **** **** ${value.substring(value.length - 4)}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (card != null) 'card': card,
        if (img != null) 'img': img,
        if (qrcode != null) 'qrcode': qrcode,
        if (alias != null) 'alias': alias,
        if (title != null) 'title': title,
        if (rate != null) 'rete': rate,
        if (type != null) 'type': type,
        if (status != null) 'status': status,
        if (bankName != null) 'bank_name': bankName,
        if (cardNumber != null) 'card_number': cardNumber,
        if (name != null) 'name': name,
        if (address != null) 'address': address,
      };
}

class VenueBalance {
  final int id;
  final String title;
  final String code;
  final double money;

  const VenueBalance({
    required this.id,
    required this.title,
    required this.code,
    required this.money,
  });

  factory VenueBalance.fromJson(Map<String, dynamic> json) => VenueBalance(
        id: jsonInt(json['id']) ?? 0,
        title: jsonString(json['title']) ?? '',
        code: jsonString(json['code']) ?? '',
        money: jsonDouble(json['money']) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'code': code,
        'money': money,
      };
}

class UserRealtimeBalance {
  final double balance;

  const UserRealtimeBalance({this.balance = 0});

  factory UserRealtimeBalance.fromJson(Map<String, dynamic> json) =>
      UserRealtimeBalance(balance: jsonDouble(json['balance']) ?? 0);

  Map<String, dynamic> toJson() => {'balance': balance};
}

class CardType {
  final int id;
  final String? name;
  final String? title;
  final String? code;
  final String? img;
  final int? type;

  const CardType(
      {required this.id,
      this.name,
      this.title,
      this.code,
      this.img,
      this.type});

  factory CardType.fromJson(Map<String, dynamic> json) => CardType(
        id: jsonInt(json['id']) ?? 0,
        name: jsonString(json['name']),
        title: jsonString(json['title']),
        code: jsonString(json['code']),
        img: jsonString(json['img']),
        type: jsonInt(json['type']),
      );

  String get displayName => name ?? title ?? '';

  Map<String, dynamic> toJson() => {
        'id': id,
        if (name != null) 'name': name,
        if (title != null) 'title': title,
        if (code != null) 'code': code,
        if (img != null) 'img': img,
        if (type != null) 'type': type,
      };
}

class BindCardRequest {
  final int id;
  final String card;
  final String? address;
  final String? alias;
  final String? name;
  final String? img;
  final String? payPassword;

  const BindCardRequest({
    required this.id,
    required this.card,
    this.address,
    this.alias,
    this.name,
    this.img,
    this.payPassword,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'card': card,
        'addres': address ?? '',
        if (alias != null) 'alias': alias,
        if (name != null) 'name': name,
        'img': img ?? '',
        if (payPassword != null) 'pay_password': payPassword,
      };
}

class DepositCategory {
  final int id;
  final String? title;
  final String? img;
  final String? msg;
  final String? code;

  const DepositCategory(
      {required this.id, this.title, this.img, this.msg, this.code});

  factory DepositCategory.fromJson(Map<String, dynamic> json) =>
      DepositCategory(
        id: jsonInt(json['id']) ?? 0,
        title: jsonString(json['title']),
        img: jsonString(json['img']),
        msg: jsonString(json['msg']),
        code: jsonString(json['code']),
      );

  String get displayTitle => title?.trim() ?? '';

  bool get hasBadge => msg?.trim().isNotEmpty == true;

  Map<String, dynamic> toJson() => {
        'id': id,
        if (title != null) 'title': title,
        if (img != null) 'img': img,
        if (msg != null) 'msg': msg,
        if (code != null) 'code': code,
      };
}

class DepositChannel {
  final int id;
  final String? title;
  final String? icon;
  final double min;
  final double max;
  final String? type;
  final String? bankCode;
  final int? amountType;
  final List<dynamic> amount;
  final String? rate;
  final int? giveType;
  final double? giveMoney;

  const DepositChannel({
    required this.id,
    this.title,
    this.icon,
    this.min = 0,
    this.max = 0,
    this.type,
    this.bankCode,
    this.amountType,
    this.amount = const [],
    this.rate,
    this.giveType,
    this.giveMoney,
  });

  factory DepositChannel.fromJson(Map<String, dynamic> json) => DepositChannel(
        id: jsonInt(json['id']) ?? 0,
        title: jsonString(json['title']),
        icon: jsonString(json['icon'] ?? json['img']),
        min: jsonDouble(json['min']) ?? 0,
        max: jsonDouble(json['max']) ?? 0,
        type: jsonString(json['type']),
        bankCode: jsonString(json['bank_code']),
        amountType: jsonInt(json['amount_type']),
        amount: json['amount'] is List
            ? List<dynamic>.from(json['amount'])
            : const [],
        rate: jsonString(json['rete'] ?? json['rate']),
        giveType: jsonInt(json['give_type']),
        giveMoney: jsonDouble(json['give_money']),
      );

  String get displayTitle => title?.trim() ?? '';

  int get normalizedAmountType {
    final value = amountType ?? 3;
    return value == 1 || value == 2 || value == 3 ? value : 3;
  }

  bool get manualAmountEnabled =>
      normalizedAmountType == 1 || normalizedAmountType == 3;

  bool get fixedAmountOnly => normalizedAmountType == 2;

  List<double> get quickAmounts => amount
      .map((value) => jsonDouble(value))
      .whereType<double>()
      .where((value) => value > 0)
      .toList(growable: false);

  bool get shouldShowRate =>
      displayTitle.toUpperCase().contains('USDT') &&
      (rate?.trim().isNotEmpty ?? false);

  Map<String, dynamic> toJson() => {
        'id': id,
        if (title != null) 'title': title,
        if (icon != null) 'icon': icon,
        'min': min,
        'max': max,
        if (type != null) 'type': type,
        if (bankCode != null) 'bank_code': bankCode,
        if (amountType != null) 'amount_type': amountType,
        'amount': amount,
        if (rate != null) 'rete': rate,
        if (giveType != null) 'give_type': giveType,
        if (giveMoney != null) 'give_money': giveMoney,
      };
}

class DepositOrderRequest {
  final int id;
  final double money;

  const DepositOrderRequest({required this.id, required this.money});

  Map<String, dynamic> toJson() => {'id': id, 'money': money};
}

class DepositOrderResult {
  final String? url;
  final String? qrcode;
  final String? orderNo;
  final int? id;
  final int? orderId;
  final Map<String, dynamic>? data;

  const DepositOrderResult(
      {this.url, this.qrcode, this.orderNo, this.id, this.orderId, this.data});

  factory DepositOrderResult.fromJson(Map<String, dynamic> json) {
    return DepositOrderResult(
      url: jsonString(json['url']),
      qrcode: jsonString(json['qrcode']),
      orderNo: jsonString(json['order_no']),
      id: jsonInt(json['id']),
      orderId: jsonInt(json['order_id']),
      data: jsonMap(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (url != null) 'url': url,
        if (qrcode != null) 'qrcode': qrcode,
        if (orderNo != null) 'order_no': orderNo,
        if (id != null) 'id': id,
        if (orderId != null) 'order_id': orderId,
        if (data != null) 'data': data,
      };
}

class RechargeDetail {
  final RechargeParams? params;
  final double money;
  final double? rate;
  final double? usdtMoney;
  final String? img;
  final String? currency;
  final String? msg;
  final int? type;

  const RechargeDetail({
    this.params,
    this.money = 0,
    this.rate,
    this.usdtMoney,
    this.img,
    this.currency,
    this.msg,
    this.type,
  });

  factory RechargeDetail.fromJson(Map<String, dynamic> json) => RechargeDetail(
        params: jsonMap(json['params']) == null
            ? null
            : RechargeParams.fromJson(jsonMap(json['params'])!),
        money: jsonDouble(json['money']) ?? 0,
        rate: jsonDouble(json['hl']),
        usdtMoney: jsonDouble(json['usdt_money']),
        img: jsonString(json['img']),
        currency: jsonString(json['currency']),
        msg: jsonString(json['msg']),
        type: jsonInt(json['type']),
      );

  Map<String, dynamic> toJson() => {
        if (params != null) 'params': params!.toJson(),
        'money': money,
        if (rate != null) 'hl': rate,
        if (usdtMoney != null) 'usdt_money': usdtMoney,
        if (img != null) 'img': img,
        if (currency != null) 'currency': currency,
        if (msg != null) 'msg': msg,
        if (type != null) 'type': type,
      };
}

class RechargeParams {
  final String? merchant;
  final String? payKey;
  final String? payUrl;
  final String? payCode;
  final String? code;
  final String? name;
  final String? account;
  final String? address;
  final String? bankName;
  final String? bank;
  final String? card;

  const RechargeParams({
    this.merchant,
    this.payKey,
    this.payUrl,
    this.payCode,
    this.code,
    this.name,
    this.account,
    this.address,
    this.bankName,
    this.bank,
    this.card,
  });

  factory RechargeParams.fromJson(Map<String, dynamic> json) => RechargeParams(
        merchant: jsonString(json['merchant']),
        payKey: jsonString(json['pay_key']),
        payUrl: jsonString(json['pay_url']),
        payCode: jsonString(json['pay_code']),
        code: jsonString(json['code']),
        name: jsonString(json['name']),
        account: jsonString(json['account']),
        address: jsonString(json['address'] ?? json['addres']),
        bankName: jsonString(json['bank_name']),
        bank: jsonString(json['bank']),
        card: jsonString(json['card']),
      );

  Map<String, dynamic> toJson() => {
        if (merchant != null) 'merchant': merchant,
        if (payKey != null) 'pay_key': payKey,
        if (payUrl != null) 'pay_url': payUrl,
        if (payCode != null) 'pay_code': payCode,
        if (code != null) 'code': code,
        if (name != null) 'name': name,
        if (account != null) 'account': account,
        if (address != null) 'address': address,
        if (bankName != null) 'bank_name': bankName,
        if (bank != null) 'bank': bank,
        if (card != null) 'card': card,
      };
}

class WithdrawRequest {
  final int id;
  final double money;
  final String? payPassword;

  const WithdrawRequest(
      {required this.id, required this.money, this.payPassword});

  Map<String, dynamic> toJson() => {
        'id': id,
        'money': money,
        if (payPassword != null) 'pay_password': payPassword,
      };
}
