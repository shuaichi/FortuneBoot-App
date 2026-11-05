import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/components/fx_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';

/// 卡片表面语义；嵌套内容优先使用无边框的 filled 或 inset。
enum FxCardVariant { outlined, filled, inset }

/// 单一 Material 表面的内容容器；按压、焦点与边框在同一表面上绘制。
class FxCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accent;
  final VoidCallback? onTap;
  final Color? background;
  final double radius;

  /// 数据面板允许轻阴影；连续业务列表关闭阴影以降低视觉噪声。
  final bool elevated;

  /// 独立容器默认微边框，内部内容可选平面或凹进表面。
  final FxCardVariant variant;

  const FxCard({
    super.key,
    required this.child,
    this.padding = FxSpacing.cardPad,
    this.accent,
    this.onTap,
    this.background,
    this.radius = FxRadius.card,
    this.elevated = false,
    this.variant = FxCardVariant.outlined,
  });

  @override
  State<FxCard> createState() => _FxCardState();
}

class _FxCardState extends State<FxCard> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final borderRadius = BorderRadius.circular(widget.radius);
    Widget content = widget.child;

    if (widget.accent != null) {
      // ListView 子项高度无界时，Row.stretch 会把卡片高度压成 0。
      // IntrinsicHeight 让色条跟着内容高度走。
      content = IntrinsicHeight(
        child: Row(
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
        ),
      );
    }

    final background =
        widget.background ??
        (widget.variant == FxCardVariant.inset
            ? palette.surfaceMuted
            : palette.surface);
    // 品牌实色卡不能继续叠同色墨水；选择可与当前表面区分的前景。
    final primaryLuminance = palette.primary.computeLuminance();
    final backgroundLuminance = background.computeLuminance();
    final primaryContrast =
        (primaryLuminance > backgroundLuminance
            ? primaryLuminance + 0.05
            : backgroundLuminance + 0.05) /
        (primaryLuminance > backgroundLuminance
            ? backgroundLuminance + 0.05
            : primaryLuminance + 0.05);
    final interactionColor = primaryContrast >= 3
        ? palette.primary
        : backgroundLuminance > 0.179
        ? Colors.black
        : Colors.white;
    final side = _focused
        ? BorderSide(color: interactionColor, width: FxSpacing.focusWidth)
        : widget.variant == FxCardVariant.outlined
        ? BorderSide(color: palette.border, width: FxSpacing.hairline)
        : BorderSide.none;
    final paddedContent = Padding(padding: widget.padding, child: content);
    return Semantics(
      button: widget.onTap == null ? null : true,
      child: Material(
        color: background,
        surfaceTintColor: Colors.transparent,
        elevation: widget.elevated ? 1 : 0,
        shadowColor: palette.shadow,
        shape: RoundedRectangleBorder(borderRadius: borderRadius, side: side),
        clipBehavior: Clip.antiAlias,
        child: widget.onTap == null
            ? paddedContent
            : InkWell(
                overlayColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return interactionColor.withValues(alpha: 0.12);
                  }
                  if (states.contains(WidgetState.focused) ||
                      states.contains(WidgetState.hovered)) {
                    return interactionColor.withValues(alpha: 0.08);
                  }
                  return null;
                }),
                customBorder: RoundedRectangleBorder(
                  borderRadius: borderRadius,
                ),
                onFocusChange: (focused) => setState(() => _focused = focused),
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onTap!();
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: FxSpacing.touchTarget,
                    minHeight: FxSpacing.touchTarget,
                  ),
                  child: paddedContent,
                ),
              ),
      ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FxText(
            text,
            role: FxTextRole.label,
            tone: FxTextTone.secondary,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: FxSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}
