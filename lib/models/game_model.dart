import 'package:json_annotation/json_annotation.dart';
import 'home_data.dart';

part 'game_model.g.dart';

@JsonSerializable()
class GameLoginResponse {
  final String? url;

  GameLoginResponse({this.url});

  factory GameLoginResponse.fromJson(Map<String, dynamic> json) => _$GameLoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GameLoginResponseToJson(this);
}

@JsonSerializable()
class GameListResponse {
  final List<GameItem>? data;
  @JsonKey(name: 'current_page')
  final int? currentPage;
  final int? total;
  @JsonKey(name: 'last_page')
  final int? lastPage;

  GameListResponse({this.data, this.currentPage, this.total, this.lastPage});

  factory GameListResponse.fromJson(Map<String, dynamic> json) => _$GameListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GameListResponseToJson(this);
}

@JsonSerializable()
class BalanceResponse {
  final String? balance;

  BalanceResponse({this.balance});

  factory BalanceResponse.fromJson(Map<String, dynamic> json) => _$BalanceResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BalanceResponseToJson(this);
}
