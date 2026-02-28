// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgentInfo _$AgentInfoFromJson(Map<String, dynamic> json) => AgentInfo(
  userId: (json['user_id'] as num).toInt(),
  username: json['username'] as String?,
  agentLevel: (json['agent_level'] as num?)?.toInt(),
  totalCommission: json['total_commission'] as String?,
  availableCommission: json['available_commission'] as String?,
  inviteCode: json['invite_code'] as String?,
  subAgentCount: (json['sub_agent_count'] as num?)?.toInt(),
  subUserCount: (json['sub_user_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$AgentInfoToJson(AgentInfo instance) => <String, dynamic>{
  'user_id': instance.userId,
  'username': instance.username,
  'agent_level': instance.agentLevel,
  'total_commission': instance.totalCommission,
  'available_commission': instance.availableCommission,
  'invite_code': instance.inviteCode,
  'sub_agent_count': instance.subAgentCount,
  'sub_user_count': instance.subUserCount,
};

TeamReport _$TeamReportFromJson(Map<String, dynamic> json) => TeamReport(
  totalDeposit: json['total_deposit'] as String?,
  totalWithdraw: json['total_withdraw'] as String?,
  totalBet: json['total_bet'] as String?,
  totalNetAmount: json['total_net_amount'] as String?,
  totalCommission: json['total_commission'] as String?,
  activeUserCount: (json['active_user_count'] as num?)?.toInt(),
  newUserCount: (json['new_user_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$TeamReportToJson(TeamReport instance) =>
    <String, dynamic>{
      'total_deposit': instance.totalDeposit,
      'total_withdraw': instance.totalWithdraw,
      'total_bet': instance.totalBet,
      'total_net_amount': instance.totalNetAmount,
      'total_commission': instance.totalCommission,
      'active_user_count': instance.activeUserCount,
      'new_user_count': instance.newUserCount,
    };
