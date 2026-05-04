import '../core/json_utils.dart';

class ActivityCategory {
  final int id;
  final String? title;
  final String? img;

  const ActivityCategory({required this.id, this.title, this.img});

  factory ActivityCategory.fromJson(Map<String, dynamic> json) {
    return ActivityCategory(
      id: jsonInt(json['id']) ?? 0,
      title: jsonString(json['title']),
      img: jsonString(json['img']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (title != null) 'title': title,
        if (img != null) 'img': img,
      };
}

class ActivityItem {
  final int id;
  final String? title;
  final String? img;
  final String? appImg;
  final String? h5Img;
  final String? pcImg;
  final String? content;
  final String? startAt;
  final String? endAt;
  final int? status;

  const ActivityItem({
    required this.id,
    this.title,
    this.img,
    this.appImg,
    this.h5Img,
    this.pcImg,
    this.content,
    this.startAt,
    this.endAt,
    this.status,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) => ActivityItem(
        id: jsonInt(json['id']) ?? 0,
        title: jsonString(json['title']),
        img: jsonString(json['img']),
        appImg: jsonString(json['app_img']),
        h5Img: jsonString(json['h5_img']),
        pcImg: jsonString(json['pc_img']),
        content: jsonString(json['content']),
        startAt: jsonString(json['start_at'] ?? json['start_time']),
        endAt: jsonString(json['end_at'] ?? json['end_time']),
        status: jsonInt(json['status']),
      );

  String? get displayImg => img ?? h5Img ?? appImg ?? pcImg;

  Map<String, dynamic> toJson() => {
        'id': id,
        if (title != null) 'title': title,
        if (img != null) 'img': img,
        if (appImg != null) 'app_img': appImg,
        if (h5Img != null) 'h5_img': h5Img,
        if (pcImg != null) 'pc_img': pcImg,
        if (content != null) 'content': content,
        if (startAt != null) 'start_at': startAt,
        if (endAt != null) 'end_at': endAt,
        if (status != null) 'status': status,
      };
}

class ActivityApplyRequest {
  final int id;
  final String? remark;

  const ActivityApplyRequest({required this.id, this.remark});

  Map<String, dynamic> toJson() => {
        'id': id,
        if (remark != null) 'remark': remark,
      };
}

class ActivityApplyRecord {
  final int id;
  final String? title;
  final int? status;
  final String? remark;
  final String? createdAt;

  const ActivityApplyRecord({
    required this.id,
    this.title,
    this.status,
    this.remark,
    this.createdAt,
  });

  factory ActivityApplyRecord.fromJson(Map<String, dynamic> json) {
    return ActivityApplyRecord(
      id: jsonInt(json['id']) ?? 0,
      title: jsonString(json['title'] ?? json['activity_title']),
      status: jsonInt(json['status']),
      remark: jsonString(json['remark']),
      createdAt: jsonString(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (title != null) 'title': title,
        if (status != null) 'status': status,
        if (remark != null) 'remark': remark,
        if (createdAt != null) 'created_at': createdAt,
      };
}
