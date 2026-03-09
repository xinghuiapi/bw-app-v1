// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'betting_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BettingRecord _$BettingRecordFromJson(Map<String, dynamic> json) =>
    BettingRecord(
      id: (json['id'] as num?)?.toInt(),
      rowid: json['rowid'] as String?,
      username: json['username'] as String?,
      betTime: json['betTime'] as String?,
      betAmount: json['betAmount'],
      validBetAmount: json['validBetAmount'],
      netAmount: json['netAmount'],
      status: (json['status'] as num?)?.toInt(),
      title: json['title'] as String?,
      code: json['code'] as String?,
      interfaceTitle: json['interface_title'] as String?,
      apiCode: (json['api_code'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BettingRecordToJson(BettingRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rowid': instance.rowid,
      'username': instance.username,
      'betTime': instance.betTime,
      'betAmount': instance.betAmount,
      'validBetAmount': instance.validBetAmount,
      'netAmount': instance.netAmount,
      'status': instance.status,
      'title': instance.title,
      'code': instance.code,
      'interface_title': instance.interfaceTitle,
      'api_code': instance.apiCode,
    };

BettingRecordsResponse _$BettingRecordsResponseFromJson(
  Map<String, dynamic> json,
) => BettingRecordsResponse(
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => BettingRecord.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num?)?.toInt(),
  currentPage: (json['current_page'] as num?)?.toInt(),
  totalBetAmount: json['total_betAmount'],
  totalNetAmount: json['total_netAmount'],
);

Map<String, dynamic> _$BettingRecordsResponseToJson(
  BettingRecordsResponse instance,
) => <String, dynamic>{
  'data': instance.data,
  'total': instance.total,
  'current_page': instance.currentPage,
  'total_betAmount': instance.totalBetAmount,
  'total_netAmount': instance.totalNetAmount,
};
