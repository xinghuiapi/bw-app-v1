import 'package:flutter/material.dart';

const double backHitTargetSize = 56;

class BackHitTarget extends StatelessWidget {
  const BackHitTarget({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.iconSize = 20,
    this.backgroundColor,
    this.borderColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final double iconSize;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: backHitTargetSize,
        height: backHitTargetSize,
        child: Center(
          child: Container(
            width: 28,
            height: 28,
            decoration: backgroundColor == null && borderColor == null
                ? null
                : BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: borderColor == null
                        ? null
                        : Border.all(color: borderColor!, width: 0.5),
                  ),
            child: Icon(icon, color: color, size: iconSize),
          ),
        ),
      ),
    );
  }
}
