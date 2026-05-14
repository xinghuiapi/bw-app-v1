import 'package:flutter/foundation.dart';

class FloatingGameProvider extends ChangeNotifier {
  String? _url;
  String? _title;

  String? get url => _url;
  String? get title => _title;
  bool get hasGame => _url?.trim().isNotEmpty == true;

  void minimize({required String url, required String title}) {
    final normalizedUrl = url.trim();
    if (normalizedUrl.isEmpty) return;
    _url = normalizedUrl;
    _title = title.trim();
    notifyListeners();
  }

  void close() {
    if (!hasGame) return;
    _url = null;
    _title = null;
    notifyListeners();
  }
}
