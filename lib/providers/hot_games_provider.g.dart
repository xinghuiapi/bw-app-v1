// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hot_games_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HotGames)
final hotGamesProvider = HotGamesProvider._();

final class HotGamesProvider
    extends $NotifierProvider<HotGames, PaginationState<GameItem>> {
  HotGamesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hotGamesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hotGamesHash();

  @$internal
  @override
  HotGames create() => HotGames();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginationState<GameItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginationState<GameItem>>(value),
    );
  }
}

String _$hotGamesHash() => r'7d9de3073d19d2738bb6c26bfc4d3c821e0f8434';

abstract class _$HotGames extends $Notifier<PaginationState<GameItem>> {
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
