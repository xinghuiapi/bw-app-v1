import 'package:flutter/foundation.dart';

import '../../api/api_exception.dart';
import '../../api/dio_client.dart';
import '../../models/common/upload_models.dart';
import '../../models/wallet/wallet_models.dart';
import '../../services/wallet/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  WalletProvider({WalletService? service})
      : _service = service ?? WalletService(DioClient());

  WalletService _service;

  List<WalletCard> cards = const [];
  List<VenueBalance> venues = const [];
  List<DepositCategory> depositCategories = const [];
  List<DepositChannel> depositChannels = const [];
  final Map<int, List<CardType>> cardTypes = {};
  UserRealtimeBalance? realtimeBalance;
  RechargeDetail? rechargeDetail;
  int? selectedDepositCategoryId;
  int? selectedDepositChannelId;

  bool isCardsLoading = false;
  bool isCardsRefreshing = false;
  bool isBalanceLoading = false;
  bool isVenuesLoading = false;
  bool isRecyclingVenues = false;
  bool isVenueTransferSubmitting = false;
  bool isTransferModeSubmitting = false;
  bool isDepositCategoriesLoading = false;
  bool isDepositChannelsLoading = false;
  bool isRechargeDetailLoading = false;
  bool isBindingCard = false;
  bool isUploadingCardImage = false;
  final Map<int, bool> _cardTypeLoading = {};

  String? cardsError;
  String? balanceError;
  String? venuesError;
  String? venueActionError;
  String? transferModeError;
  String? depositCategoriesError;
  String? depositChannelsError;
  String? rechargeDetailError;
  String? bindCardError;
  String? cardImageUploadError;
  final Map<int, String?> _cardTypeErrors = {};

  double get venueBalanceTotal =>
      venues.fold(0, (total, venue) => total + venue.money);

  void bindClient(DioClient client) {
    _service = WalletService(client);
  }

  bool isCardTypeLoading(int type) => _cardTypeLoading[type] ?? false;
  String? cardTypeError(int type) => _cardTypeErrors[type];

  DepositCategory? get selectedDepositCategory {
    for (final category in depositCategories) {
      if (category.id == selectedDepositCategoryId) return category;
    }
    return null;
  }

  DepositChannel? get selectedDepositChannel {
    for (final channel in depositChannels) {
      if (channel.id == selectedDepositChannelId) return channel;
    }
    return null;
  }

  Future<void> loadCards({bool refresh = false}) async {
    if (isCardsLoading || isCardsRefreshing) return;
    if (!refresh && cards.isNotEmpty) return;

    if (refresh) {
      isCardsRefreshing = true;
    } else {
      isCardsLoading = true;
    }
    cardsError = null;
    notifyListeners();

    try {
      cards = await _service.fetchCards();
    } on ApiException catch (exception) {
      cardsError = exception.message;
    } catch (exception) {
      cardsError = exception.toString();
    } finally {
      isCardsLoading = false;
      isCardsRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadRealtimeBalance({bool refresh = false}) async {
    if (isBalanceLoading) return;
    if (!refresh && realtimeBalance != null) return;

    isBalanceLoading = true;
    balanceError = null;
    notifyListeners();

    try {
      realtimeBalance = await _service.fetchRealtimeBalance();
    } on ApiException catch (exception) {
      balanceError = exception.message;
    } catch (exception) {
      balanceError = exception.toString();
    } finally {
      isBalanceLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadVenueBalances({bool refresh = false}) async {
    if (isVenuesLoading) return;
    if (!refresh && venues.isNotEmpty) return;

    isVenuesLoading = true;
    venuesError = null;
    notifyListeners();

    try {
      venues = await _service.fetchVenueBalances();
    } on ApiException catch (exception) {
      venuesError = exception.message;
    } catch (exception) {
      venuesError = exception.toString();
    } finally {
      isVenuesLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWalletOverview({bool refresh = false}) async {
    await Future.wait([
      loadRealtimeBalance(refresh: refresh),
      loadVenueBalances(refresh: refresh),
    ]);
  }

  Future<void> recycleVenueBalances() async {
    if (isRecyclingVenues) return;

    isRecyclingVenues = true;
    venueActionError = null;
    notifyListeners();

    try {
      await _service.recycleVenueBalances();
      await loadWalletOverview(refresh: true);
    } on ApiException catch (exception) {
      venueActionError = exception.message;
      rethrow;
    } catch (exception) {
      venueActionError = exception.toString();
      rethrow;
    } finally {
      isRecyclingVenues = false;
      notifyListeners();
    }
  }

  Future<void> transferInVenue({required int id, required double money}) async {
    if (isVenueTransferSubmitting) return;

    isVenueTransferSubmitting = true;
    venueActionError = null;
    notifyListeners();

    try {
      await _service.transferInVenue(id: id, money: money);
      await loadWalletOverview(refresh: true);
    } on ApiException catch (exception) {
      venueActionError = exception.message;
      rethrow;
    } catch (exception) {
      venueActionError = exception.toString();
      rethrow;
    } finally {
      isVenueTransferSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> transferOutVenue(
      {required int id, required double money}) async {
    if (isVenueTransferSubmitting) return;

    isVenueTransferSubmitting = true;
    venueActionError = null;
    notifyListeners();

    try {
      await _service.transferOutVenue(id: id, money: money);
      await loadWalletOverview(refresh: true);
    } on ApiException catch (exception) {
      venueActionError = exception.message;
      rethrow;
    } catch (exception) {
      venueActionError = exception.toString();
      rethrow;
    } finally {
      isVenueTransferSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> setTransferMode(int type) async {
    if (isTransferModeSubmitting) return;

    isTransferModeSubmitting = true;
    transferModeError = null;
    notifyListeners();

    try {
      await _service.setTransferMode(type);
    } on ApiException catch (exception) {
      transferModeError = exception.message;
      rethrow;
    } catch (exception) {
      transferModeError = exception.toString();
      rethrow;
    } finally {
      isTransferModeSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> loadDepositBootstrap({bool refresh = false}) async {
    await loadDepositCategories(refresh: refresh);
    final categoryId = selectedDepositCategoryId;
    if (categoryId != null && categoryId > 0) {
      await loadDepositChannels(categoryId, refresh: refresh);
    }
  }

  Future<void> loadDepositCategories({bool refresh = false}) async {
    if (isDepositCategoriesLoading) return;
    if (!refresh && depositCategories.isNotEmpty) return;

    isDepositCategoriesLoading = true;
    depositCategoriesError = null;
    notifyListeners();

    try {
      depositCategories = await _service.fetchDepositCategories();
      if (depositCategories.isNotEmpty &&
          !depositCategories
              .any((item) => item.id == selectedDepositCategoryId)) {
        selectedDepositCategoryId = depositCategories.first.id;
      }
      if (depositCategories.isEmpty) {
        selectedDepositCategoryId = null;
        selectedDepositChannelId = null;
        depositChannels = const [];
      }
    } on ApiException catch (exception) {
      depositCategoriesError = exception.message;
    } catch (exception) {
      depositCategoriesError = exception.toString();
    } finally {
      isDepositCategoriesLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDepositChannels(int categoryId,
      {bool refresh = false}) async {
    if (isDepositChannelsLoading) return;
    if (!refresh &&
        selectedDepositCategoryId == categoryId &&
        depositChannels.isNotEmpty) {
      return;
    }

    selectedDepositCategoryId = categoryId;
    selectedDepositChannelId = null;
    depositChannels = const [];
    rechargeDetail = null;
    isDepositChannelsLoading = true;
    depositChannelsError = null;
    notifyListeners();

    try {
      depositChannels = await _service.fetchDepositChannels(categoryId);
      if (depositChannels.isNotEmpty) {
        selectedDepositChannelId = depositChannels.first.id;
      }
    } on ApiException catch (exception) {
      depositChannelsError = exception.message;
    } catch (exception) {
      depositChannelsError = exception.toString();
    } finally {
      isDepositChannelsLoading = false;
      notifyListeners();
    }
  }

  void selectDepositChannel(DepositChannel channel) {
    if (selectedDepositChannelId == channel.id) return;
    selectedDepositChannelId = channel.id;
    rechargeDetail = null;
    rechargeDetailError = null;
    notifyListeners();
  }

  Future<void> loadRechargeDetail(dynamic id) async {
    if (isRechargeDetailLoading) return;

    isRechargeDetailLoading = true;
    rechargeDetailError = null;
    notifyListeners();

    try {
      rechargeDetail = await _service.fetchRechargeDetail(id);
    } on ApiException catch (exception) {
      rechargeDetailError = exception.message;
    } catch (exception) {
      rechargeDetailError = exception.toString();
    } finally {
      isRechargeDetailLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCardTypes(int type, {bool refresh = false}) async {
    if (isCardTypeLoading(type)) return;
    if (!refresh && (cardTypes[type]?.isNotEmpty ?? false)) return;

    _cardTypeLoading[type] = true;
    _cardTypeErrors[type] = null;
    notifyListeners();

    try {
      cardTypes[type] = await _service.fetchCardTypes(type);
    } on ApiException catch (exception) {
      _cardTypeErrors[type] = exception.message;
    } catch (exception) {
      _cardTypeErrors[type] = exception.toString();
    } finally {
      _cardTypeLoading[type] = false;
      notifyListeners();
    }
  }

  Future<void> loadAllCardTypes({bool refresh = false}) async {
    await Future.wait([
      loadCardTypes(1, refresh: refresh),
      loadCardTypes(2, refresh: refresh),
      loadCardTypes(3, refresh: refresh),
    ]);
  }

  Future<void> bindCard(BindCardRequest request) async {
    if (isBindingCard) return;

    isBindingCard = true;
    bindCardError = null;
    notifyListeners();

    try {
      await _service.bindCard(request);
      await loadCards(refresh: true);
    } on ApiException catch (exception) {
      bindCardError = exception.message;
      rethrow;
    } catch (exception) {
      bindCardError = exception.toString();
      rethrow;
    } finally {
      isBindingCard = false;
      notifyListeners();
    }
  }

  Future<UploadImageResult> uploadCardImage({
    required List<int> bytes,
    required String filename,
  }) async {
    if (isUploadingCardImage) {
      throw const ApiException(
        type: ApiExceptionType.business,
        message: '图片上传中，请稍候',
      );
    }

    isUploadingCardImage = true;
    cardImageUploadError = null;
    notifyListeners();

    try {
      final result = await _service.uploadCardImage(
        bytes: bytes,
        filename: filename,
      );
      final image = result.path?.trim().isNotEmpty == true
          ? result.path!.trim()
          : result.url?.trim();
      if (image == null || image.isEmpty) {
        throw const ApiException(
          type: ApiExceptionType.parse,
          message: 'Upload response missing image path',
        );
      }
      return result;
    } on ApiException catch (exception) {
      cardImageUploadError = exception.message;
      rethrow;
    } catch (exception) {
      cardImageUploadError = exception.toString();
      rethrow;
    } finally {
      isUploadingCardImage = false;
      notifyListeners();
    }
  }
}
