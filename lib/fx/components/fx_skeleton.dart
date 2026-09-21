import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';

/// Placeholder surface that respects system reduced-motion preferences.
class FxSkeleton extends StatefulWidget {
  const FxSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
    this.circular = false,
    this.animate = true,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final bool circular;
  final bool animate;

  @override
  State<FxSkeleton> createState() => _FxSkeletonState();
}

class _FxSkeletonState extends State<FxSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: FxMotion.slow,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final shape = widget.circular ? BoxShape.circle : BoxShape.rectangle;
    final decoration = BoxDecoration(
      color: palette.surfaceMuted,
      shape: shape,
      borderRadius: widget.circular
          ? null
          : widget.borderRadius ?? FxRadius.tileBorder,
    );
    final child = Container(
      width: widget.width,
      height: widget.height,
      decoration: decoration,
    );
    if (reduceMotion || !widget.animate) return child;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.5, end: 1).animate(_controller),
      child: child,
    );
  }
}

class FxShimmer extends FxSkeleton {
  const FxShimmer({
    super.key,
    super.width,
    super.height,
    super.borderRadius,
    super.circular,
    super.animate,
  });
}
