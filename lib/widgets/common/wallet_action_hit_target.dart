import 'package:flutter/material.dart';

class WalletActionHitTarget extends StatelessWidget {
  const WalletActionHitTarget({
    super.key,
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox.expand(child: child),
    );
  }
}
