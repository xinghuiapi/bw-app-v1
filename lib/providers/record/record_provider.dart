import 'package:flutter/foundation.dart';

import '../../api/api_exception.dart';
import '../../api/dio_client.dart';
import '../../models/wallet/record_models.dart';
import '../../services/record/record_service.dart';

enum FundRecordTab { deposit, withdraw, transfer, account }

class RecordProvider extends ChangeNotifier {
  RecordProvider({RecordService? service})
      : _service = service ?? RecordService(DioClient());

  static const int pageSize = 10;

  RecordService _service;

  RecordPage<TradeRecord> depositPage = const RecordPage<TradeRecord>();
  RecordPage<TradeRecord> withdrawPage = const RecordPage<TradeRecord>();
  RecordPage<TransferRecord> transferPage = const RecordPage<TransferRecord>();
  MoneyLogPage accountPage = const MoneyLogPage();

  final Map<FundRecordTab, bool> _loading = {};
  final Map<FundRecordTab, bool> _loadingMore = {};
  final Map<FundRecordTab, int> _serials = {};
  final Map<FundRecordTab, String?> _errors = {};

  String _startDate = '';
  String _endDate = '';

  void bindClient(DioClient client) {
    _service = RecordService(client);
  }

  void resetForLanguageChange() {
    depositPage = const RecordPage<TradeRecord>();
    withdrawPage = const RecordPage<TradeRecord>();
    transferPage = const RecordPage<TransferRecord>();
    accountPage = const MoneyLogPage();
    _loading.clear();
    _loadingMore.clear();
    _serials.updateAll((_, value) => value + 1);
    _errors.clear();
    _startDate = '';
    _endDate = '';
    notifyListeners();
  }

  bool isLoading(FundRecordTab tab) => _loading[tab] ?? false;
  bool isLoadingMore(FundRecordTab tab) => _loadingMore[tab] ?? false;
  String? error(FundRecordTab tab) => _errors[tab];

  bool hasMore(FundRecordTab tab) {
    final page = switch (tab) {
      FundRecordTab.deposit => depositPage,
      FundRecordTab.withdraw => withdrawPage,
      FundRecordTab.transfer => transferPage,
      FundRecordTab.account => accountPage,
    };
    return page.currentPage < page.lastPage;
  }

  Future<void> loadTab(
    FundRecordTab tab, {
    required String startDate,
    required String endDate,
    bool refresh = false,
  }) async {
    if (isLoading(tab) || isLoadingMore(tab)) return;
    if (!refresh && !hasMore(tab)) return;

    _startDate = startDate;
    _endDate = endDate;

    final currentPage = switch (tab) {
      FundRecordTab.deposit => depositPage.currentPage,
      FundRecordTab.withdraw => withdrawPage.currentPage,
      FundRecordTab.transfer => transferPage.currentPage,
      FundRecordTab.account => accountPage.currentPage,
    };
    final nextPage = refresh ? 1 : currentPage + 1;
    final serial = (_serials[tab] ?? 0) + 1;
    _serials[tab] = serial;

    if (refresh) {
      _loading[tab] = true;
      _resetPage(tab);
    } else {
      _loadingMore[tab] = true;
    }
    _errors[tab] = null;
    notifyListeners();

    try {
      final query = RecordQuery(
        page: nextPage,
        size: pageSize,
        startDate: startDate,
        endDate: endDate,
      );
      await switch (tab) {
        FundRecordTab.deposit => _loadTrade(tab, query, 'recharge'),
        FundRecordTab.withdraw => _loadTrade(tab, query, 'drawing'),
        FundRecordTab.transfer => _loadTransfer(refresh, query),
        FundRecordTab.account => _loadAccount(refresh, query),
      };
    } on ApiException catch (exception) {
      _errors[tab] = exception.message;
    } catch (exception) {
      _errors[tab] = exception.toString();
    } finally {
      if (_serials[tab] == serial) {
        _loading[tab] = false;
        _loadingMore[tab] = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore(FundRecordTab tab) {
    return loadTab(tab, startDate: _startDate, endDate: _endDate);
  }

  Future<void> _loadTrade(
    FundRecordTab tab,
    RecordQuery query,
    String type,
  ) async {
    final next = await _service.fetchTradeRecords(query, type: type);
    if (tab == FundRecordTab.deposit) {
      depositPage = query.page == 1
          ? next
          : next.copyWith(records: [...depositPage.records, ...next.records]);
    } else {
      withdrawPage = query.page == 1
          ? next
          : next.copyWith(records: [...withdrawPage.records, ...next.records]);
    }
  }

  Future<void> _loadTransfer(bool refresh, RecordQuery query) async {
    final next = await _service.fetchTransferRecords(query);
    transferPage = refresh
        ? next
        : next.copyWith(records: [...transferPage.records, ...next.records]);
  }

  Future<void> _loadAccount(bool refresh, RecordQuery query) async {
    final next = await _service.fetchMoneyLogs(query);
    accountPage = refresh
        ? next
        : next.copyWith(records: [...accountPage.records, ...next.records]);
  }

  void _resetPage(FundRecordTab tab) {
    switch (tab) {
      case FundRecordTab.deposit:
        depositPage = const RecordPage<TradeRecord>();
      case FundRecordTab.withdraw:
        withdrawPage = const RecordPage<TradeRecord>();
      case FundRecordTab.transfer:
        transferPage = const RecordPage<TransferRecord>();
      case FundRecordTab.account:
        accountPage = const MoneyLogPage();
    }
  }
}
