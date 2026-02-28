// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameLoginResponse _$GameLoginResponseFromJson(Map<String, dynamic> json) =>
    GameLoginResponse(url: json['url'] as String?);

Map<String, dynamic> _$GameLoginResponseToJson(GameLoginResponse instance) =>
    <String, dynamic>{'url': instance.url};

GameListResponse _$GameListResponseFromJson(Map<String, dynamic> json) =>
    GameListResponse(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => GameItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: (json['current_page'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
      lastPage: (json['lastPage'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GameListResponseToJson(GameListResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'current_page': instance.currentPage,
      'total': instance.total,
      'lastPage': instance.lastPage,
    };

BalanceResponse _$BalanceResponseFromJson(Map<String, dynamic> json) =>
    BalanceResponse(balance: json['balance'] as String?);

Map<String, dynamic> _$BalanceResponseToJson(BalanceResponse instance) =>
    <String, dynamic>{'balance': instance.balance};
