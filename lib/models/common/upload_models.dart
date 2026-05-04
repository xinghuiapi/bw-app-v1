import '../core/json_utils.dart';

class UploadImageResult {
  final String? path;
  final String? url;

  const UploadImageResult({this.path, this.url});

  factory UploadImageResult.fromJson(Map<String, dynamic> json) {
    return UploadImageResult(
      path: jsonString(json['path']),
      url: jsonString(json['url']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (path != null) 'path': path,
        if (url != null) 'url': url,
      };
}
