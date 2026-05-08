import '../core/json_utils.dart';

class RecordQuery {
  const RecordQuery({
    required this.page,
    required this.size,
    required this.startDate,
    required this.endDate,
    this.type = '',
    this.status = '',
    this.apiCode = '',
    this.order = '',
    this.moneyTypeId = '',
  });

  final int page;
  final int size;
  final String startDate;
  final String endDate;
  final String type;
  final String status;
  final String apiCode;
  final String order;
  final String moneyTypeId;

  Map<String, dynamic> toTradeJson(String tradeType) => {
        'page': page,
        'size': size,
        'type': tradeType,
        'status': status,
        'start_date': startDate,
        'end_date': endDate,
      };

  Map<String, dynamic> toTransferJson() => {
        'page': page,
        'size': size,
        'api_code': apiCode,
        'status': status,
        'type': type,
        'start_date': startDate,
        'end_date': endDate,
      };

  Map<String, dynamic> toMoneyLogJson() => {
        'page': page,
        'size': size,
        'order': order,
        'type': type,
        'money_type_id': moneyTypeId,
        'start_date': startDate,
        'end_date': endDate,
      };
}

class RecordPage<T> {
  const RecordPage({
    this.records = const [],
    this.currentPage = 1,
    this.total = 0,
    this.lastPage = 1,
  });

  final List<T> records;
  final int currentPage;
  final int total;
  final int lastPage;

  factory RecordPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final rows = json['data'] is List ? json['data'] as List : const [];
    return RecordPage<T>(
      records: rows
          .whereType<Map>()
          .map((item) => fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      currentPage: jsonInt(json['current_page'] ?? json['currentPage']) ?? 1,
      total: jsonInt(json['total']) ?? 0,
      lastPage: jsonInt(json['lastPage'] ?? json['last_page']) ?? 1,
    );
  }

  RecordPage<T> copyWith({List<T>? records}) {
    return RecordPage<T>(
      records: records ?? this.records,
      currentPage: currentPage,
      total: total,
      lastPage: lastPage,
    );
  }
}

class TradeRecord {
  const TradeRecord({
    required this.id,
    this.title = '',
    this.order = '',
    this.money = 0,
    this.status = 0,
    this.createdAt = '',
    this.note = '',
  });

  final int id;
  final String title;
  final String order;
  final double money;
  final int status;
  final String createdAt;
  final String note;

  factory TradeRecord.fromJson(Map<String, dynamic> json) => TradeRecord(
        id: jsonInt(json['id']) ?? 0,
        title: jsonString(json['title']) ?? '',
        order: jsonString(json['order'] ?? json['order_no'] ?? json['rowid']) ??
            '',
        money: jsonDouble(json['money']) ?? 0,
        status: jsonInt(json['status']) ?? 0,
        createdAt: jsonString(json['created_at']) ?? '',
        note: jsonString(json['note'] ?? json['remark']) ?? '',
      );
}

class TransferRecord {
  const TransferRecord({
    required this.id,
    this.order = '',
    this.code = '',
    this.money = 0,
    this.type = 0,
    this.status = 0,
    this.createdAt = '',
  });

  final int id;
  final String order;
  final String code;
  final double money;
  final int type;
  final int status;
  final String createdAt;

  factory TransferRecord.fromJson(Map<String, dynamic> json) => TransferRecord(
        id: jsonInt(json['id']) ?? 0,
        order: jsonString(json['order']) ?? '',
        code: jsonString(json['code'] ?? json['api_code']) ?? '',
        money: jsonDouble(json['money']) ?? 0,
        type: jsonInt(json['type']) ?? 0,
        status: jsonInt(json['status']) ?? 0,
        createdAt: jsonString(json['created_at']) ?? '',
      );

  bool get isIn => type == 1;
}

class MoneyLogType {
  const MoneyLogType({required this.id, required this.name});

  final int id;
  final String name;

  factory MoneyLogType.fromJson(Map<String, dynamic> json) => MoneyLogType(
        id: jsonInt(json['id']) ?? 0,
        name: jsonString(json['name']) ?? '',
      );
}

class MoneyLogPage extends RecordPage<MoneyLog> {
  const MoneyLogPage({
    super.records = const [],
    super.currentPage = 1,
    super.total = 0,
    super.lastPage = 1,
    this.types = const [],
  });

  final List<MoneyLogType> types;

  factory MoneyLogPage.fromJson(Map<String, dynamic> json) {
    final page = RecordPage.fromJson(json, MoneyLog.fromJson);
    final types = json['money_type'] is List
        ? (json['money_type'] as List)
            .whereType<Map>()
            .map((item) =>
                MoneyLogType.fromJson(Map<String, dynamic>.from(item)))
            .where((item) => item.id > 0 && item.name.isNotEmpty)
            .toList()
        : const <MoneyLogType>[];
    return MoneyLogPage(
      records: page.records,
      currentPage: page.currentPage,
      total: page.total,
      lastPage: page.lastPage,
      types: types,
    );
  }

  @override
  MoneyLogPage copyWith({List<MoneyLog>? records}) {
    return MoneyLogPage(
      records: records ?? this.records,
      currentPage: currentPage,
      total: total,
      lastPage: lastPage,
      types: types,
    );
  }
}

class MoneyLog {
  const MoneyLog({
    this.order = '',
    this.beforeMoney = 0,
    this.money = 0,
    this.afterMoney = 0,
    this.type = 0,
    this.moneyTypeId = 0,
    this.note = '',
    this.createdAt = '',
  });

  final String order;
  final double beforeMoney;
  final double money;
  final double afterMoney;
  final int type;
  final int moneyTypeId;
  final String note;
  final String createdAt;

  factory MoneyLog.fromJson(Map<String, dynamic> json) => MoneyLog(
        order: jsonString(json['order'] ?? json['rowid']) ?? '',
        beforeMoney: jsonDouble(json['before_money'] ?? json['before']) ?? 0,
        money: jsonDouble(json['money']) ?? 0,
        afterMoney: jsonDouble(json['after_money'] ?? json['after']) ?? 0,
        type: jsonInt(json['type']) ?? 0,
        moneyTypeId: jsonInt(json['money_type_id']) ?? 0,
        note: jsonString(json['note'] ?? json['remark']) ?? '',
        createdAt: jsonString(json['created_at']) ?? '',
      );

  bool get isNegative => type == 2 || money < 0;
}
