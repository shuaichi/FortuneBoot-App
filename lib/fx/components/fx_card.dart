import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// Bento 卡片基座：白底 + 圆角 + 柔和阴影。可选左色条 accent / 可点击。
class FxCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accent;
  final VoidCallback? onTap;
  final Color? background;
  final double radius;

  const FxCard({
    super.key,
    required this.child,
    this.padding = FxSpacing.cardPad,
    this.accent,
    this.onTap,
    this.background,
    this.radius = FxRadius.card,
  });

  @override
  State<FxCard> createState() => _FxCardState();
}

class _FxCardState extends State<FxCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final borderRadius = BorderRadius.circular(widget.radius);
    Widget content = widget.child;

    if (widget.accent != null) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: widget.accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: FxSpacing.md),
          Expanded(child: content),
        ],
      );
    }

    final card = AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.background ?? palette.surface,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: content,
      ),
    );

    if (widget.onTap == null) return card;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap!();
      },
      child: card,
    );
  }
}

/// 卡片内的小标题（如 "本月支出"）。
class FxCardLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const FxCardLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: FxTypography.label.copyWith(
            color: FxPalette.of(context).textSecondary,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
