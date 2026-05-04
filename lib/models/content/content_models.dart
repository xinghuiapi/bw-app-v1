import '../core/json_utils.dart';

class SinglePageCategory {
  final int id;
  final String? title;

  const SinglePageCategory({required this.id, this.title});

  factory SinglePageCategory.fromJson(Map<String, dynamic> json) {
    return SinglePageCategory(
      id: jsonInt(json['id']) ?? 0,
      title: jsonString(json['title']),
    );
  }

  Map<String, dynamic> toJson() =>
      {'id': id, if (title != null) 'title': title};
}

class SinglePageContent {
  final int? id;
  final String? title;
  final String? content;

  const SinglePageContent({this.id, this.title, this.content});

  factory SinglePageContent.fromJson(Map<String, dynamic> json) {
    return SinglePageContent(
      id: jsonInt(json['id']),
      title: jsonString(json['title']),
      content: jsonString(json['content'] ?? json['text']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (title != null) 'title': title,
        if (content != null) 'content': content,
      };
}
