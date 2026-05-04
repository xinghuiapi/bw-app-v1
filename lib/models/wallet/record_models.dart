import '../core/json_utils.dart';

class TradeRecord {
  final int id;
  final String? title;
  final String? order;
  final String? orderNo;
  final String? rowid;
  final dynamic money;
  final int? status;
  final String? createdAt;
  final String? note;
  final String? remark;
  final String? interfaceTitle;

  const TradeRecord({
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

  factory TradeRecord.fromJson(Map<String, dynamic> json) => TradeRecord(
        id: jsonInt(json['id']) ?? 0,
        title: jsonString(json['title']),
        order: jsonString(json['order']),
        orderNo: jsonString(json['order_no']),
        rowid: jsonString(json['rowid']),
        money: json['money'],
        status: jsonInt(json['status']),
        createdAt: jsonString(json['created_at']),
        note: jsonString(json['note']),
        remark: jsonString(json['remark']),
        interfaceTitle: jsonString(json['interface_title']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (title != null) 'title': title,
        if (order != null) 'order': order,
        if (orderNo != null) 'order_no': orderNo,
        if (rowid != null) 'rowid': rowid,
        if (money != null) 'money': money,
        if (status != null) 'status': status,
        if (createdAt != null) 'created_at': createdAt,
        if (note != null) 'note': note,
        if (remark != null) 'remark': remark,
        if (interfaceTitle != null) 'interface_title': interfaceTitle,
      };
}

class TransferRecord {
  final int id;
  final String? order;
  final dynamic money;
  final int? type;
  final String? fromPlat;
  final String? toPlat;
  final int? status;
  final String? createdAt;
  final String? interfaceTitle;

  const TransferRecord({
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

  factory TransferRecord.fromJson(Map<String, dynamic> json) => TransferRecord(
        id: jsonInt(json['id']) ?? 0,
        order: jsonString(json['order']),
        money: json['money'],
        type: jsonInt(json['type']),
        fromPlat: jsonString(json['from_plat']),
        toPlat: jsonString(json['to_plat']),
        status: jsonInt(json['status']),
        createdAt: jsonString(json['created_at']),
        interfaceTitle: jsonString(json['interface_title']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (order != null) 'order': order,
        if (money != null) 'money': money,
        if (type != null) 'type': type,
        if (fromPlat != null) 'from_plat': fromPlat,
        if (toPlat != null) 'to_plat': toPlat,
        if (status != null) 'status': status,
        if (createdAt != null) 'created_at': createdAt,
        if (interfaceTitle != null) 'interface_title': interfaceTitle,
      };
}

class BetRecord {
  final int id;
  final String? gameName;
  final double betAmount;
  final double winAmount;
  final double netAmount;
  final String? betTime;
  final int status;
  final String? code;
  final String? interfaceTitle;
  final String? title;
  final String? rowid;
  final dynamic apiCode;

  const BetRecord({
    required this.id,
    this.gameName,
    this.betAmount = 0,
    this.winAmount = 0,
    this.netAmount = 0,
    this.betTime,
    this.status = 0,
    this.code,
    this.interfaceTitle,
    this.title,
    this.rowid,
    this.apiCode,
  });

  factory BetRecord.fromJson(Map<String, dynamic> json) => BetRecord(
        id: jsonInt(json['id']) ?? 0,
        gameName: jsonString(json['gameCode'] ?? json['game_name']),
        betAmount: jsonDouble(json['betAmount'] ?? json['bet_amount']) ?? 0,
        winAmount: jsonDouble(json['winAmount'] ?? json['win_amount']) ?? 0,
        netAmount: jsonDouble(json['netAmount'] ?? json['net_amount']) ?? 0,
        betTime: jsonString(json['betTime'] ?? json['bet_time']),
        status: jsonInt(json['status']) ?? 0,
        code: jsonString(json['code']),
        interfaceTitle:
            jsonString(json['interfaceTitle'] ?? json['interface_title']),
        title: jsonString(json['title']),
        rowid: jsonString(json['rowid']),
        apiCode: json['apiCode'] ?? json['api_code'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (gameName != null) 'game_name': gameName,
        'bet_amount': betAmount,
        'win_amount': winAmount,
        'net_amount': netAmount,
        if (betTime != null) 'bet_time': betTime,
        'status': status,
        if (code != null) 'code': code,
        if (interfaceTitle != null) 'interface_title': interfaceTitle,
        if (title != null) 'title': title,
        if (rowid != null) 'rowid': rowid,
        if (apiCode != null) 'api_code': apiCode,
      };
}

class RebateRecord {
  final int id;
  final String? username;
  final String? code;
  final String? apiCode;
  final String? apiCodeTitle;
  final dynamic fsMoney;
  final dynamic money;
  final dynamic rate;
  final int? status;
  final String? createdAt;

  const RebateRecord({
    required this.id,
    this.username,
    this.code,
    this.apiCode,
    this.apiCodeTitle,
    this.fsMoney,
    this.money,
    this.rate,
    this.status,
    this.createdAt,
  });

  factory RebateRecord.fromJson(Map<String, dynamic> json) => RebateRecord(
        id: jsonInt(json['id']) ?? 0,
        username: jsonString(json['username']),
        code: jsonString(json['code']),
        apiCode: jsonString(json['api_code']),
        apiCodeTitle: jsonString(json['api_code_title']),
        fsMoney: json['fs_money'],
        money: json['money'],
        rate: json['bl'],
        status: jsonInt(json['status']),
        createdAt: jsonString(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (username != null) 'username': username,
        if (code != null) 'code': code,
        if (apiCode != null) 'api_code': apiCode,
        if (apiCodeTitle != null) 'api_code_title': apiCodeTitle,
        if (fsMoney != null) 'fs_money': fsMoney,
        if (money != null) 'money': money,
        if (rate != null) 'bl': rate,
        if (status != null) 'status': status,
        if (createdAt != null) 'created_at': createdAt,
      };
}

class MoneyLog {
  final int id;
  final dynamic money;
  final dynamic before;
  final dynamic after;
  final dynamic beforeMoney;
  final dynamic afterMoney;
  final dynamic type;
  final dynamic typeName;
  final dynamic moneyTypeId;
  final dynamic remark;
  final dynamic note;
  final dynamic createdAt;
  final dynamic rowid;
  final dynamic order;

  const MoneyLog({
    required this.id,
    this.money,
    this.before,
    this.after,
    this.beforeMoney,
    this.afterMoney,
    this.type,
    this.typeName,
    this.moneyTypeId,
    this.remark,
    this.note,
    this.createdAt,
    this.rowid,
    this.order,
  });

  factory MoneyLog.fromJson(Map<String, dynamic> json) => MoneyLog(
        id: jsonInt(json['id']) ?? 0,
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

  Map<String, dynamic> toJson() => {
        'id': id,
        if (money != null) 'money': money,
        if (before != null) 'before': before,
        if (after != null) 'after': after,
        if (beforeMoney != null) 'before_money': beforeMoney,
        if (afterMoney != null) 'after_money': afterMoney,
        if (type != null) 'type': type,
        if (typeName != null) 'type_name': typeName,
        if (moneyTypeId != null) 'money_type_id': moneyTypeId,
        if (remark != null) 'remark': remark,
        if (note != null) 'note': note,
        if (createdAt != null) 'created_at': createdAt,
        if (rowid != null) 'rowid': rowid,
        if (order != null) 'order': order,
      };
}

class RebateSummary {
  final int userSum;
  final int validUserCount;
  final dynamic pendingAmount;
  final dynamic minimumAmount;
  final int maxUserCount;
  final dynamic userAmount;

  const RebateSummary({
    this.userSum = 0,
    this.validUserCount = 0,
    this.pendingAmount,
    this.minimumAmount,
    this.maxUserCount = 0,
    this.userAmount,
  });

  factory RebateSummary.fromJson(Map<String, dynamic> json) => RebateSummary(
        userSum: jsonInt(json['user_sum']) ?? 0,
        validUserCount: jsonInt(json['user_youxiao']) ?? 0,
        pendingAmount: json['dailingqu'],
        minimumAmount: json['zuidi'],
        maxUserCount: jsonInt(json['user_max']) ?? 0,
        userAmount: json['user_amount'],
      );

  Map<String, dynamic> toJson() => {
        'user_sum': userSum,
        'user_youxiao': validUserCount,
        if (pendingAmount != null) 'dailingqu': pendingAmount,
        if (minimumAmount != null) 'zuidi': minimumAmount,
        'user_max': maxUserCount,
        if (userAmount != null) 'user_amount': userAmount,
      };
}
