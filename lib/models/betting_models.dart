import 'package:json_annotation/json_annotation.dart';

part 'betting_models.g.dart';

@JsonSerializable()
class BettingRecord {
  final int? id;
  final String? rowid;
  final String? username;
  @JsonKey(name: 'betTime')
  final String? betTime;
  @JsonKey(name: 'betAmount')
  final dynamic betAmount;
  @JsonKey(name: 'validBetAmount')
  final dynamic validBetAmount;
  @JsonKey(name: 'netAmount')
  final dynamic netAmount;
  final int? status;
  final String? title;
  final String? code;
  @JsonKey(name: 'interface_title')
  final String? interfaceTitle;
  @JsonKey(name: 'api_code')
  final dynamic apiCode;
  @JsonKey(name: 'gameCode')
  final String? gameCode;

  BettingRecord({
    this.id,
    this.rowid,
    this.username,
    this.betTime,
    this.betAmount,
    this.validBetAmount,
    this.netAmount,
    this.status,
    this.title,
    this.code,
    this.interfaceTitle,
    this.apiCode,
    this.gameCode,
  });

  factory BettingRecord.fromJson(Map<String, dynamic> json) =>
      _$BettingRecordFromJson(json);
  Map<String, dynamic> toJson() => _$BettingRecordToJson(this);
}

@JsonSerializable()
class BettingRecordsResponse {
  final List<BettingRecord>? data;
  final int? total;
  @JsonKey(name: 'current_page')
  final int? currentPage;
  @JsonKey(name: 'total_betAmount')
  final dynamic totalBetAmount;
  @JsonKey(name: 'total_netAmount')
  final dynamic totalNetAmount;
  @JsonKey(name: 'total_validBetAmount')
  final dynamic totalValidBetAmount;
  final int? lastPage;

  BettingRecordsResponse({
    this.data,
    this.total,
    this.currentPage,
    this.totalBetAmount,
    this.totalNetAmount,
    this.totalValidBetAmount,
    this.lastPage,
  });

  factory BettingRecordsResponse.fromJson(Map<String, dynamic> json) {
    return BettingRecordsResponse(
      data: (json['data'] as List?)
          ?.map((e) => BettingRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int?,
      currentPage: json['current_page'] as int?,
      totalBetAmount: json['total_betAmount'],
      totalNetAmount: json['total_netAmount'],
      totalValidBetAmount: json['total_validBetAmount'],
      lastPage: json['lastPage'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((e) => e.toJson()).toList(),
      'total': total,
      'current_page': currentPage,
      'total_betAmount': totalBetAmount,
      'total_netAmount': totalNetAmount,
      'total_validBetAmount': totalValidBetAmount,
      'lastPage': lastPage,
    };
  }
}

// @JsonSerializable()
class BettingCategory {
  final int? id;
  final String? title;
  final String? code;

  BettingCategory({this.id, this.title, this.code});

  factory BettingCategory.fromJson(Map<String, dynamic> json) {
    return BettingCategory(
      id: json['id'] as int?,
      title: json['title'] as String?,
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'code': code};
  }
}
