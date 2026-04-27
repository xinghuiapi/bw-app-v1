// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 推广返利 Notifier

@ProviderFor(ReferralNotifier)
final referralProvider = ReferralNotifierProvider._();

/// 推广返利 Notifier
final class ReferralNotifierProvider
    extends $NotifierProvider<ReferralNotifier, ReferralState> {
  /// 推广返利 Notifier
  ReferralNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'referralProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$referralNotifierHash();

  @$internal
  @override
  ReferralNotifier create() => ReferralNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReferralState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReferralState>(value),
    );
  }
}

String _$referralNotifierHash() => r'5ef074df248f049ab3a95c53b4571260ed970cad';

/// 推广返利 Notifier

abstract class _$ReferralNotifier extends $Notifier<ReferralState> {
  ReferralState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ReferralState, ReferralState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReferralState, ReferralState>,
              ReferralState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
