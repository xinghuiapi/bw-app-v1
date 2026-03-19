// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_games_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FavoriteGames)
final favoriteGamesProvider = FavoriteGamesProvider._();

final class FavoriteGamesProvider
    extends $NotifierProvider<FavoriteGames, PaginationState<GameItem>> {
  FavoriteGamesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteGamesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteGamesHash();

  @$internal
  @override
  FavoriteGames create() => FavoriteGames();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginationState<GameItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginationState<GameItem>>(value),
    );
  }
}

String _$favoriteGamesHash() => r'4a4d60e78b060750f9ed5c86d60b9f04a41fc734';

abstract class _$FavoriteGames extends $Notifier<PaginationState<GameItem>> {
  PaginationState<GameItem> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<PaginationState<GameItem>, PaginationState<GameItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PaginationState<GameItem>, PaginationState<GameItem>>,
              PaginationState<GameItem>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
