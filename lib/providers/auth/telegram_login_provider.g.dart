// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telegram_login_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TelegramLoginNotifier)
final telegramLoginProvider = TelegramLoginNotifierProvider._();

final class TelegramLoginNotifierProvider
    extends $NotifierProvider<TelegramLoginNotifier, TelegramLoginState> {
  TelegramLoginNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'telegramLoginProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$telegramLoginNotifierHash();

  @$internal
  @override
  TelegramLoginNotifier create() => TelegramLoginNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TelegramLoginState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TelegramLoginState>(value),
    );
  }
}

String _$telegramLoginNotifierHash() =>
    r'eb25ed9ca61a12991ecfb49d4851e9f1fb44318d';

abstract class _$TelegramLoginNotifier extends $Notifier<TelegramLoginState> {
  TelegramLoginState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TelegramLoginState, TelegramLoginState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TelegramLoginState, TelegramLoginState>,
              TelegramLoginState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
