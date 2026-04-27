// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_reset_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PasswordResetNotifier)
final passwordResetProvider = PasswordResetNotifierProvider._();

final class PasswordResetNotifierProvider
    extends $NotifierProvider<PasswordResetNotifier, PasswordResetState> {
  PasswordResetNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passwordResetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passwordResetNotifierHash();

  @$internal
  @override
  PasswordResetNotifier create() => PasswordResetNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PasswordResetState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PasswordResetState>(value),
    );
  }
}

String _$passwordResetNotifierHash() =>
    r'a8dc7c58c18744154d4e2b513ace2c949a25463d';

abstract class _$PasswordResetNotifier extends $Notifier<PasswordResetState> {
  PasswordResetState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PasswordResetState, PasswordResetState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PasswordResetState, PasswordResetState>,
              PasswordResetState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
