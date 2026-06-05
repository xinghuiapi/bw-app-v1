import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import '../../localization/app_language.dart';
import '../../localization/language_storage.dart';

class LanguageProvider extends ChangeNotifier {
  LanguageProvider({
    LanguageStorage storage = const LanguageStorage(),
    String? initialCode,
  })  : _storage = storage,
        _currentCode = AppLanguage.normalize(initialCode),
        _initialized = initialCode != null && initialCode.trim().isNotEmpty,
        _hasStoredLanguage =
            initialCode != null && initialCode.trim().isNotEmpty;

  final LanguageStorage _storage;

  String _currentCode;
  bool _initialized;
  bool _hasStoredLanguage;

  String get currentCode => _currentCode;
  bool get initialized => _initialized;
  bool get hasStoredLanguage => _hasStoredLanguage;

  Future<void> init() async {
    final stored = await _storage.read();
    _hasStoredLanguage = stored != null && stored.trim().isNotEmpty;
    _currentCode = AppLanguage.normalize(stored);
    _initialized = true;
    notifyListeners();
  }

  Future<void> changeLanguage(BuildContext context, String code) async {
    final next = AppLanguage.normalize(code);
    if (context.mounted) {
      await context.setLocale(AppLanguage.toLocale(next));
    }
    await setCode(next);
  }

  Future<void> setCode(String code) async {
    final next = AppLanguage.normalize(code);
    await _storage.write(next);
    _hasStoredLanguage = true;
    if (next == _currentCode && _initialized) return;
    _currentCode = next;
    _initialized = true;
    notifyListeners();
  }
}
