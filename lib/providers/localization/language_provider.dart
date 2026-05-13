import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import '../../localization/app_language.dart';
import '../../localization/language_storage.dart';
import '../../models/home/home_models.dart';

class LanguageProvider extends ChangeNotifier {
  LanguageProvider({LanguageStorage storage = const LanguageStorage()})
      : _storage = storage;

  final LanguageStorage _storage;

  String _currentCode = AppLanguage.fallbackCode;
  bool _initialized = false;
  bool _hasStoredLanguage = false;

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

  Future<bool> applyBackendDefault(List<LanguageConfig> languages) async {
    if (_hasStoredLanguage || languages.isEmpty) return false;
    final defaultLanguage = languages.firstWhere(
      (item) => item.requiredStatus == 1 && (item.code ?? '').trim().isNotEmpty,
      orElse: () => languages.first,
    );
    final code = AppLanguage.normalize(defaultLanguage.code);
    if (code == _currentCode) {
      await _storage.write(code);
      _hasStoredLanguage = true;
      return false;
    }
    await setCode(code);
    return true;
  }

  Future<void> changeLanguage(BuildContext context, String code) async {
    final next = AppLanguage.normalize(code);
    if (next != _currentCode) {
      await setCode(next);
    }
    if (context.mounted) {
      await context.setLocale(AppLanguage.toLocale(next));
    }
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
