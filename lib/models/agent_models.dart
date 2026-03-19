import 'package:json_annotation/json_annotation.dart';

part 'agent_models.g.dart';

@JsonSerializable()
class AgentInfo {
  @JsonKey(name: 'user_id')
  final int userId;
  final String? username;
  @JsonKey(name: 'agent_level')
  final int? agentLevel;
  @JsonKey(name: 'total_commission')
  final String? totalCommission;
  @JsonKey(name: 'available_commission')
  final String? availableCommission;
  @JsonKey(name: 'invite_code')
  final String? inviteCode;
  @JsonKey(name: 'sub_agent_count')
  final int? subAgentCount;
  @JsonKey(name: 'sub_user_count')
  final int? subUserCount;

  AgentInfo({
    required this.userId,
    this.username,
    this.agentLevel,
    this.totalCommission,
    this.availableCommission,
    this.inviteCode,
    this.subAgentCount,
    this.subUserCount,
  });

  factory AgentInfo.fromJson(Map<String, dynamic> json) =>
      _$AgentInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AgentInfoToJson(this);
}

@JsonSerializable()
class TeamReport {
  @JsonKey(name: 'total_deposit')
  final String? totalDeposit;
  @JsonKey(name: 'total_withdraw')
  final String? totalWithdraw;
  @JsonKey(name: 'total_bet')
  final String? totalBet;
  @JsonKey(name: 'total_net_amount')
  final String? totalNetAmount;
  @JsonKey(name: 'total_commission')
  final String? totalCommission;
  @JsonKey(name: 'active_user_count')
  final int? activeUserCount;
  @JsonKey(name: 'new_user_count')
  final int? newUserCount;

  TeamReport({
    this.totalDeposit,
    this.totalWithdraw,
    this.totalBet,
    this.totalNetAmount,
    this.totalCommission,
    this.activeUserCount,
    this.newUserCount,
  });

  factory TeamReport.fromJson(Map<String, dynamic> json) =>
      _$TeamReportFromJson(json);
  Map<String, dynamic> toJson() => _$TeamReportToJson(this);
}
