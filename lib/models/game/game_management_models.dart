import '../core/json_utils.dart';

class GameManageQuery {
  const GameManageQuery({
    required this.page,
    required this.size,
    required this.startDate,
    required this.endDate,
    this.code = '',
    this.apiCode = '',
    this.status = '',
  });

  final int page;
  final int size;
  final String startDate;
  final String endDate;
  final String code;
  final String apiCode;
  final String status;

  Map<String, dynamic> toRebateJson() => {
        'page': page,
        'size': size,
        'code': code,
        'api_code': apiCode,
        'status': status,
        'start_date': startDate,
        'end_date': endDate,
      };

  Map<String, dynamic> toFyJson() => {
        'page': page,
        'size': size,
        'username': '',
        'code': code,
        'api_code': apiCode,
        'status': status,
        'start_date': startDate,
        'end_date': endDate,
      };

  Map<String, dynamic> toGameJson() => {
        'page': page,
        'size': size,
        'api_code_title': apiCode,
        'status': status,
        'code': code,
        'start_date': startDate,
        'end_date': endDate,
      };
}

class RebateRecordPage {
  const RebateRecordPage({
    this.records = const [],
    this.currentPage = 1,
    this.total = 0,
    this.lastPage = 1,
    this.notFsMoney = 0,
    this.yesFsMoney = 0,
    this.totalFsMoney = 0,
  });

  final List<RebateRecord> records;
  final int currentPage;
  final int total;
  final int lastPage;
  final double notFsMoney;
  final double yesFsMoney;
  final double totalFsMoney;

  factory RebateRecordPage.fromJson(Map<String, dynamic> json) {
    final rows = json['data'] is List ? json['data'] as List : const [];
    return RebateRecordPage(
      records: rows
          .whereType<Map>()
          .where(RebateRecord.isRebatePayload)
          .map((item) => RebateRecord.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      currentPage: jsonInt(json['current_page'] ?? json['currentPage']) ?? 1,
      total: jsonInt(json['total']) ?? 0,
      lastPage: jsonInt(json['lastPage'] ?? json['last_page']) ?? 1,
      notFsMoney: jsonDouble(json['not_fs_money']) ?? 0,
      yesFsMoney: jsonDouble(json['yes_fs_money']) ?? 0,
      totalFsMoney: jsonDouble(json['total_fs_money']) ?? 0,
    );
  }

  RebateRecordPage copyWith({List<RebateRecord>? records}) {
    return RebateRecordPage(
      records: records ?? this.records,
      currentPage: currentPage,
      total: total,
      lastPage: lastPage,
      notFsMoney: notFsMoney,
      yesFsMoney: yesFsMoney,
      totalFsMoney: totalFsMoney,
    );
  }
}

class RebateClaimAllResult {
  const RebateClaimAllResult({
    this.amount = 0,
    this.balance,
    this.raw = const <String, dynamic>{},
  });

  final double amount;
  final double? balance;
  final Map<String, dynamic> raw;

  factory RebateClaimAllResult.fromJson(Map<String, dynamic> json) {
    return RebateClaimAllResult(
      amount:
          jsonDouble(json['amount'] ?? json['money'] ?? json['fs_money']) ?? 0,
      balance: jsonDouble(json['balance']),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        if (balance != null) 'balance': balance,
        ...raw,
      };
}

class RebateRecord {
  const RebateRecord({
    required this.id,
    this.username = '',
    this.money = 0,
    this.apiCode = '',
    this.apiCodeTitle = '',
    this.code = '',
    this.ratio = '',
    this.fsMoney = 0,
    this.status = 0,
    this.createdAt = '',
  });

  final int id;
  final String username;
  final double money;
  final String apiCode;
  final String apiCodeTitle;
  final String code;
  final String ratio;
  final double fsMoney;
  final int status;
  final String createdAt;

  factory RebateRecord.fromJson(Map<String, dynamic> json) => RebateRecord(
        id: jsonInt(json['id']) ?? 0,
        username: jsonString(json['username']) ?? '',
        money: jsonDouble(json['money']) ?? 0,
        apiCode: jsonString(json['api_code']) ?? '',
        apiCodeTitle: jsonString(json['api_code_title']) ?? '',
        code: jsonString(json['code']) ?? '',
        ratio: jsonString(json['bl']) ?? '',
        fsMoney: jsonDouble(json['fs_money']) ?? 0,
        status: jsonInt(json['status']) ?? 0,
        createdAt: jsonString(json['created_at']) ?? '',
      );

  static bool isRebatePayload(Map<dynamic, dynamic> json) {
    return json.containsKey('fs_money') ||
        json.containsKey('bl') ||
        json.containsKey('created_at') ||
        json.containsKey('api_code_title') && json.containsKey('money');
  }

  bool get claimed => status == 1;
}

class FyRecordPage {
  const FyRecordPage({
    this.records = const [],
    this.currentPage = 1,
    this.total = 0,
    this.lastPage = 1,
    this.unreceivedMoney = 0,
    this.receivedMoney = 0,
    this.totalMoney = 0,
  });

  final List<FyRecord> records;
  final int currentPage;
  final int total;
  final int lastPage;
  final double unreceivedMoney;
  final double receivedMoney;
  final double totalMoney;

  factory FyRecordPage.fromJson(Map<String, dynamic> json) {
    final rows = json['data'] is List ? json['data'] as List : const [];
    return FyRecordPage(
      records: rows
          .whereType<Map>()
          .map((item) => FyRecord.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      currentPage: jsonInt(json['current_page']) ?? 1,
      total: jsonInt(json['total']) ?? 0,
      lastPage: jsonInt(json['lastPage']) ?? 1,
      unreceivedMoney: jsonDouble(
              json['unreceivedFsMoney'] ?? json['unreceived_fs_money']) ??
          0,
      receivedMoney:
          jsonDouble(json['receivedFsMoney'] ?? json['received_fs_money']) ?? 0,
      totalMoney:
          jsonDouble(json['totalFsMoney'] ?? json['total_fs_money']) ?? 0,
    );
  }

  FyRecordPage copyWith({List<FyRecord>? records}) {
    return FyRecordPage(
      records: records ?? this.records,
      currentPage: currentPage,
      total: total,
      lastPage: lastPage,
      unreceivedMoney: unreceivedMoney,
      receivedMoney: receivedMoney,
      totalMoney: totalMoney,
    );
  }
}

class FyClaimAllResult {
  const FyClaimAllResult({
    this.amount = 0,
    this.balance,
    this.raw = const <String, dynamic>{},
  });

  final double amount;
  final double? balance;
  final Map<String, dynamic> raw;

  factory FyClaimAllResult.fromJson(Map<String, dynamic> json) {
    return FyClaimAllResult(
      amount: jsonDouble(json['amount'] ?? json['money']) ?? 0,
      balance: jsonDouble(json['balance']),
      raw: json,
    );
  }
}

class FyRecord {
  const FyRecord({
    required this.id,
    this.username = '',
    this.code = '',
    this.apiCode = '',
    this.apiCodeTitle = '',
    this.gameType = '',
    this.createdAt = '',
    this.ratio = '',
    this.money = 0,
    this.betAmount = 0,
    this.status = 0,
  });

  final int id;
  final String username;
  final String code;
  final String apiCode;
  final String apiCodeTitle;
  final String gameType;
  final String createdAt;
  final String ratio;
  final double money;
  final double betAmount;
  final int status;

  factory FyRecord.fromJson(Map<String, dynamic> json) => FyRecord(
        id: jsonInt(json['id']) ?? 0,
        username: jsonString(json['username']) ?? '',
        code: jsonString(json['code']) ?? '',
        apiCode: jsonString(json['api_code']) ?? '',
        apiCodeTitle: jsonString(json['api_code_title']) ?? '',
        gameType: jsonString(json['game_type']) ?? '',
        createdAt: jsonString(json['created_at']) ?? '',
        ratio: jsonString(json['bl']) ?? '',
        money: jsonDouble(json['fs_money']) ?? 0,
        betAmount: jsonDouble(json['money']) ?? 0,
        status: jsonInt(json['status']) ?? 0,
      );

  bool get claimed => status == 1;
}

class GameRecordPage {
  const GameRecordPage({
    this.records = const [],
    this.currentPage = 1,
    this.total = 0,
    this.lastPage = 1,
    this.totalBetAmount = 0,
    this.totalValidBetAmount = 0,
    this.totalNetAmount = 0,
  });

  final List<GameBetRecord> records;
  final int currentPage;
  final int total;
  final int lastPage;
  final double totalBetAmount;
  final double totalValidBetAmount;
  final double totalNetAmount;

  factory GameRecordPage.fromJson(Map<String, dynamic> json) {
    final rows = json['data'] is List ? json['data'] as List : const [];
    return GameRecordPage(
      records: rows
          .whereType<Map>()
          .where(GameBetRecord.isGameRecordPayload)
          .map(
              (item) => GameBetRecord.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      currentPage: jsonInt(json['current_page'] ?? json['currentPage']) ?? 1,
      total: jsonInt(json['total']) ?? 0,
      lastPage: jsonInt(json['lastPage'] ?? json['last_page']) ?? 1,
      totalBetAmount: jsonDouble(json['total_betAmount']) ?? 0,
      totalValidBetAmount: jsonDouble(json['total_validBetAmount']) ?? 0,
      totalNetAmount: jsonDouble(json['total_netAmount']) ?? 0,
    );
  }

  GameRecordPage copyWith({List<GameBetRecord>? records}) {
    return GameRecordPage(
      records: records ?? this.records,
      currentPage: currentPage,
      total: total,
      lastPage: lastPage,
      totalBetAmount: totalBetAmount,
      totalValidBetAmount: totalValidBetAmount,
      totalNetAmount: totalNetAmount,
    );
  }
}

class GameBetRecord {
  const GameBetRecord({
    required this.id,
    this.rowId = '',
    this.code = '',
    this.apiCode = '',
    this.apiCodeTitle = '',
    this.gameCode = '',
    this.betTime = '',
    this.betAmount = 0,
    this.validBetAmount = 0,
    this.netAmount = 0,
    this.status = 0,
  });

  final int id;
  final String rowId;
  final String code;
  final String apiCode;
  final String apiCodeTitle;
  final String gameCode;
  final String betTime;
  final double betAmount;
  final double validBetAmount;
  final double netAmount;
  final int status;

  factory GameBetRecord.fromJson(Map<String, dynamic> json) {
    final betAmount = jsonDouble(json['betAmount']) ?? 0;
    return GameBetRecord(
      id: jsonInt(json['id']) ?? 0,
      rowId: jsonString(json['rowid']) ?? '',
      code: jsonString(json['code']) ?? '',
      apiCode: jsonString(json['api_code']) ?? '',
      apiCodeTitle: jsonString(json['api_code_title'] ??
              json['interface_title'] ??
              json['api_code']) ??
          '',
      gameCode: jsonString(json['gameCode'] ?? json['game_code']) ?? '',
      betTime: jsonString(json['betTime']) ?? '',
      betAmount: betAmount,
      validBetAmount: jsonDouble(json['validBetAmount'] ??
              json['valid_bet_amount'] ??
              json['validAmount']) ??
          betAmount,
      netAmount: jsonDouble(json['netAmount']) ?? 0,
      status: jsonInt(json['status']) ?? 0,
    );
  }

  static bool isGameRecordPayload(Map<dynamic, dynamic> json) {
    return json.containsKey('betAmount') ||
        json.containsKey('validBetAmount') ||
        json.containsKey('netAmount') ||
        json.containsKey('betTime') ||
        json.containsKey('rowid');
  }
}
