import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

/// 余额/预算占比条。
class FxProgressBar extends StatelessWidget {
  /// 0.0 ~ 1.0
  final double value;
  final Color color;
  final Color? background;
  final double height;

  const FxProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.background,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Stack(
        children: [
          Container(
            height: height,
            color: background ?? FxPalette.of(context).surfaceMuted,
          ),
          FractionallySizedBox(
            widthFactor: clamped,
            child: Container(height: height, color: color),
          ),
        ],
      ),
    );
  }
}
