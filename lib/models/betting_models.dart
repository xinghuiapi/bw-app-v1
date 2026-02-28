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
  final int? apiCode;

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
  });

  factory BettingRecord.fromJson(Map<String, dynamic> json) => _$BettingRecordFromJson(json);
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

  BettingRecordsResponse({
    this.data,
    this.total,
    this.currentPage,
    this.totalBetAmount,
    this.totalNetAmount,
  });

  factory BettingRecordsResponse.fromJson(Map<String, dynamic> json) => _$BettingRecordsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BettingRecordsResponseToJson(this);
}

@JsonSerializable()
class BettingCategory {
  final int? id;
  final String? title;
  final String? code;

  BettingCategory({this.id, this.title, this.code});

  factory BettingCategory.fromJson(Map<String, dynamic> json) => _$BettingCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$BettingCategoryToJson(this);
}
