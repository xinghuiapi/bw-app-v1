import 'package:easy_localization/easy_localization.dart';

import '../core/json_utils.dart';

class ActivityCategory {
  final int id;
  final String title;

  const ActivityCategory({required this.id, required this.title});

  factory ActivityCategory.fromJson(Map<String, dynamic> json) {
    return ActivityCategory(
      id: jsonInt(json['id']) ?? 0,
      title: jsonString(json['title'])?.trim() ?? '',
    );
  }
}

class ActivityItem {
  final int id;
  final String title;
  final String? img;
  final String? content;
  final int? type;
  final int? lasting;
  final String? startTime;
  final String? endTime;
  final double? multiple;

  const ActivityItem({
    required this.id,
    required this.title,
    this.img,
    this.content,
    this.type,
    this.lasting,
    this.startTime,
    this.endTime,
    this.multiple,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: jsonInt(json['id']) ?? 0,
      title: jsonString(json['title'])?.trim() ?? '',
      img: jsonString(json['img'])?.trim(),
      content: jsonString(json['content'])?.trim(),
      type: jsonInt(json['type']),
      lasting: jsonInt(json['lasting']),
      startTime: jsonString(json['start_time'])?.trim(),
      endTime: jsonString(json['end_time'])?.trim(),
      multiple: jsonDouble(json['multiple']),
    );
  }

  String get typeText => type == 2
      ? 'activity.type.manual'.tr()
      : 'activity.type.system'.tr();

  String get multipleText {
    final value = multiple;
    if (value == null || value <= 0) return '';
    final normalized = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
    return 'activity.multiple'.tr(namedArgs: {'value': normalized});
  }

  String get timeText {
    if (lasting == 1) return 'activity.longTerm'.tr();
    final start = startTime ?? '';
    final end = endTime ?? '';
    if (start.isNotEmpty && end.isNotEmpty) return '$start ~ $end';
    return start.isNotEmpty ? start : end;
  }

  bool get isManualApply => type == 2 && id > 0;
}

class ActivityRecordPage {
  final List<ActivityApplyRecord> data;
  final int currentPage;
  final int lastPage;
  final int? total;

  const ActivityRecordPage({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    this.total,
  });

  factory ActivityRecordPage.fromResponse(dynamic json) {
    final payload = jsonMap(json) ?? const <String, dynamic>{};
    final rows = payload['data'] is List ? payload['data'] as List : const [];
    return ActivityRecordPage(
      data: rows
          .whereType<Map>()
          .map((item) =>
              ActivityApplyRecord.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      currentPage: jsonInt(payload['current_page']) ?? 1,
      lastPage: jsonInt(payload['lastPage'] ?? payload['last_page']) ?? 1,
      total: jsonInt(payload['total']),
    );
  }
}

class ActivityApplyRecord {
  final String username;
  final int status;
  final String applyTime;
  final String title;

  const ActivityApplyRecord({
    required this.username,
    required this.status,
    required this.applyTime,
    required this.title,
  });

  factory ActivityApplyRecord.fromJson(Map<String, dynamic> json) {
    return ActivityApplyRecord(
      username: jsonString(json['username'])?.trim() ?? '',
      status: jsonInt(json['status']) ?? 0,
      applyTime: jsonString(json['apply_time'])?.trim() ?? '',
      title: jsonString(json['title'])?.trim() ?? '',
    );
  }

  String get statusText {
    if (status == 1) return 'activity.status.applying'.tr();
    if (status == 2) return 'activity.status.approved'.tr();
    if (status == 3) return 'activity.status.rejected'.tr();
    return 'activity.status.unknown'.tr();
  }

  bool get isApproved => status == 2;
  bool get isRejected => status == 3;
}
