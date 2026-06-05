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
  FyRecordPage fyPage = const FyRecordPage();
  GameRecordPage gamePage = const GameRecordPage();

  bool isRebateLoading = false;
  bool isRebateLoadingMore = false;
  bool isFyLoading = false;
  bool isFyLoadingMore = false;
  bool isGameLoading = false;
  bool isGameLoadingMore = false;
  bool isClaimingRebates = false;
  bool isClaimingFy = false;
  String? rebateError;
  String? fyError;
  String? gameError;
  String? claimRebateError;
  String? claimFyError;

  String _startDate = '';
  String _endDate = '';
  int _rebateRequestSerial = 0;
  int _fyRequestSerial = 0;
  int _gameRequestSerial = 0;

  void bindClient(DioClient client) {
    _service = GameManagementService(client);
  }

  void resetForLanguageChange() {
    rebatePage = const RebateRecordPage();
    fyPage = const FyRecordPage();
    gamePage = const GameRecordPage();
    isRebateLoading = false;
    isRebateLoadingMore = false;
    isFyLoading = false;
    isFyLoadingMore = false;
    isGameLoading = false;
    isGameLoadingMore = false;
    isClaimingRebates = false;
    isClaimingFy = false;
    rebateError = null;
    fyError = null;
    gameError = null;
    claimRebateError = null;
    claimFyError = null;
    _startDate = '';
    _endDate = '';
    _rebateRequestSerial++;
    _fyRequestSerial++;
    _gameRequestSerial++;
    notifyListeners();
  }

  bool get hasMoreRebate => rebatePage.currentPage < rebatePage.lastPage;
  bool get hasMoreFy => fyPage.currentPage < fyPage.lastPage;
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
      _startDate = startDate;
      _endDate = endDate;
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

  Future<void> loadFy({
    required String startDate,
    required String endDate,
    bool refresh = false,
  }) async {
    if (isFyLoading || isFyLoadingMore) return;
    final nextPage = refresh ? 1 : fyPage.currentPage + 1;
    if (!refresh && !hasMoreFy) return;
    final serial = ++_fyRequestSerial;

    if (refresh) {
      isFyLoading = true;
      fyPage = const FyRecordPage();
    } else {
      isFyLoadingMore = true;
    }
    fyError = null;
    notifyListeners();

    try {
      final next = await _service.fetchFyRecords(
        GameManageQuery(
          page: nextPage,
          size: pageSize,
          startDate: startDate,
          endDate: endDate,
        ),
      );
      if (serial != _fyRequestSerial) return;
      _startDate = startDate;
      _endDate = endDate;
      fyPage = refresh
          ? next
          : next.copyWith(records: [...fyPage.records, ...next.records]);
    } on ApiException catch (exception) {
      fyError = exception.message;
    } catch (exception) {
      fyError = exception.toString();
    } finally {
      if (serial == _fyRequestSerial) {
        isFyLoading = false;
        isFyLoadingMore = false;
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
      _startDate = startDate;
      _endDate = endDate;
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

  Future<void> loadMoreFy() {
    return loadFy(startDate: _startDate, endDate: _endDate);
  }

  Future<void> loadMoreGames() {
    return loadGames(startDate: _startDate, endDate: _endDate);
  }

  Future<void> claimAllRebates() async {
    if (isClaimingRebates) return;
    isClaimingRebates = true;
    claimRebateError = null;
    notifyListeners();

    try {
      await _service.claimAllRebates();
      await loadRebates(
        startDate: _startDate,
        endDate: _endDate,
        refresh: true,
      );
    } on ApiException catch (exception) {
      claimRebateError = exception.message;
      rethrow;
    } catch (exception) {
      claimRebateError = exception.toString();
      rethrow;
    } finally {
      isClaimingRebates = false;
      notifyListeners();
    }
  }

  Future<void> claimAllFy() async {
    if (isClaimingFy) return;
    isClaimingFy = true;
    claimFyError = null;
    notifyListeners();

    try {
      await _service.claimAllFy();
      await loadFy(
        startDate: _startDate,
        endDate: _endDate,
        refresh: true,
      );
    } on ApiException catch (exception) {
      claimFyError = exception.message;
      rethrow;
    } catch (exception) {
      claimFyError = exception.toString();
      rethrow;
    } finally {
      isClaimingFy = false;
      notifyListeners();
    }
  }
}
