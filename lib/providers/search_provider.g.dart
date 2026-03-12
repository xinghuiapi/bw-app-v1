// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchGames)
final searchGamesProvider = SearchGamesProvider._();

final class SearchGamesProvider
    extends $NotifierProvider<SearchGames, PaginationState<GameItem>> {
  SearchGamesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchGamesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchGamesHash();

  @$internal
  @override
  SearchGames create() => SearchGames();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginationState<GameItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginationState<GameItem>>(value),
    );
  }
}

String _$searchGamesHash() => r'7aaa0b801876e5c5861d20621a60f5c592e2ed40';

abstract class _$SearchGames extends $Notifier<PaginationState<GameItem>> {
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
