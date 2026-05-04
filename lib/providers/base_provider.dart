import 'package:flutter/foundation.dart';

class BaseProvider<T> extends ChangeNotifier {
  bool isLoading = false;
  bool isRefreshing = false;
  bool isSubmitting = false;
  String? error;
  T? data;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setData(T? value) {
    data = value;
    error = null;
    notifyListeners();
  }

  void setError(Object? value) {
    error = value?.toString();
    notifyListeners();
  }
}
