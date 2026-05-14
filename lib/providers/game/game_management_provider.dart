import 'package:flutter/foundation.dart';

import '../../api/api_exception.dart';
import '../../api/dio_client.dart';
import '../../models/game/game_management_models.dart';
import '../../services/game/game_management_service.dart';

class GameManagementProvider extends ChangeNotifier {
  GameManagementProvider({GameManagementService? service})
      : _service = service ?? GameManagementService(DioClient());

  static const int pageSize = 10;

  GameManagementService _service;

  RebateRecordPage rebatePage = const RebateRecordPage();
  GameRecordPage gamePage = const GameRecordPage();

  bool isRebateLoading = false;
  bool isRebateLoadingMore = false;
  bool isGameLoading = false;
  bool isGameLoadingMore = false;
  String? rebateError;
  String? gameError;

  String _startDate = '';
  String _endDate = '';
  int _rebateRequestSerial = 0;
  int _gameRequestSerial = 0;

  void bindClient(DioClient client) {
    _service = GameManagementService(client);
  }

  void resetForLanguageChange() {
    rebatePage = const RebateRecordPage();
    gamePage = const GameRecordPage();
    isRebateLoading = false;
    isRebateLoadingMore = false;
    isGameLoading = false;
    isGameLoadingMore = false;
    rebateError = null;
    gameError = null;
    _startDate = '';
    _endDate = '';
    _rebateRequestSerial++;
    _gameRequestSerial++;
    notifyListeners();
  }

  bool get hasMoreRebate => rebatePage.currentPage < rebatePage.lastPage;
  bool get hasMoreGame => gamePage.currentPage < gamePage.lastPage;

  Future<void> loadRebates({
    required String startDate,
    required String endDate,
    bool refresh = false,
  }) async {
    if (isRebateLoading || isRebateLoadingMore) return;
    final nextPage = refresh ? 1 : rebatePage.currentPage + 1;
    if (!refresh && !hasMoreRebate) return;
    final serial = ++_rebateRequestSerial;

    if (refresh) {
      isRebateLoading = true;
      rebatePage = const RebateRecordPage();
    } else {
      isRebateLoadingMore = true;
    }
    rebateError = null;
    notifyListeners();

    try {
      final next = await _service.fetchRebateRecords(
        GameManageQuery(
          page: nextPage,
          size: pageSize,
          startDate: startDate,
          endDate: endDate,
        ),
      );
      if (serial != _rebateRequestSerial) return;
      rebatePage = refresh
          ? next
          : next.copyWith(records: [...rebatePage.records, ...next.records]);
    } on ApiException catch (exception) {
      rebateError = exception.message;
    } catch (exception) {
      rebateError = exception.toString();
    } finally {
      if (serial == _rebateRequestSerial) {
        isRebateLoading = false;
        isRebateLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadGames({
    required String startDate,
    required String endDate,
    bool refresh = false,
  }) async {
    if (isGameLoading || isGameLoadingMore) return;
    final nextPage = refresh ? 1 : gamePage.currentPage + 1;
    if (!refresh && !hasMoreGame) return;
    final serial = ++_gameRequestSerial;

    if (refresh) {
      isGameLoading = true;
      gamePage = const GameRecordPage();
    } else {
      isGameLoadingMore = true;
    }
    gameError = null;
    notifyListeners();

    try {
      final next = await _service.fetchGameRecords(
        GameManageQuery(
          page: nextPage,
          size: pageSize,
          startDate: startDate,
          endDate: endDate,
        ),
      );
      if (serial != _gameRequestSerial) return;
      gamePage = refresh
          ? next
          : next.copyWith(records: [...gamePage.records, ...next.records]);
    } on ApiException catch (exception) {
      gameError = exception.message;
    } catch (exception) {
      gameError = exception.toString();
    } finally {
      if (serial == _gameRequestSerial) {
        isGameLoading = false;
        isGameLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMoreRebates() {
    return loadRebates(startDate: _startDate, endDate: _endDate);
  }

  Future<void> loadMoreGames() {
    return loadGames(startDate: _startDate, endDate: _endDate);
  }
}
