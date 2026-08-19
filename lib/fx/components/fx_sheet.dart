import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 统一 bottom sheet 壳：圆角 + 拖拽条 + 可选标题。theme-aware，支持暗色。
class FxSheet extends StatelessWidget {
  /// 列表 / 树 / 多选类选择弹层的统一高度占屏比，保证记一笔各选择 sheet 一致。
  static const double pickerHeightFactor = 0.82;

  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? footer;
  final String? closeTooltip;
  final String? dragHandleLabel;

  /// 内容是否自身滚动。true 时 child 会被约束在最大高度内并可滚动。
  final bool scrollable;

  /// 最大高度占屏幕比例（scrollable 时生效）。
  final double maxHeightFactor;

  /// 最小高度占屏幕比例（scrollable 时生效）。
  final double minHeightFactor;

  const FxSheet({
    super.key,
    this.title,
    required this.child,
    this.actions,
    this.footer,
    this.closeTooltip,
    this.dragHandleLabel,
    this.scrollable = false,
    this.maxHeightFactor = 0.7,
    this.minHeightFactor = 0,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final usesAdaptiveHeight = scrollable && minHeightFactor > 0;
    Widget body = child;
    if (scrollable) {
      body = usesAdaptiveHeight
          ? SingleChildScrollView(child: child)
          : ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
              ),
              child: SingleChildScrollView(child: child),
            );
    }

    final bodySection = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: FxSpacing.sm),
        Semantics(
          label: dragHandleLabel,
          child: ExcludeSemantics(
            excluding: dragHandleLabel == null,
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        if (title != null) ...[
          const SizedBox(height: FxSpacing.md),
          Padding(
            padding: FxSpacing.pageH,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title!,
                  style: FxTypography.title.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (actions != null) ...actions!,
                    if (closeTooltip != null)
                      FxIconButton(
                        icon: Icons.close_rounded,
                        tooltip: closeTooltip!,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: FxSpacing.md),
        Flexible(child: body),
      ],
    );
    final content = footer == null
        ? bodySection
        : Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: usesAdaptiveHeight
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(child: bodySection),
              footer!,
            ],
          );

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: usesAdaptiveHeight
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final maxHeight = math.min(
                    constraints.maxHeight,
                    constraints.maxHeight * maxHeightFactor,
                  );
                  final minHeight = math.min(
                    maxHeight,
                    constraints.maxHeight * minHeightFactor,
                  );
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: minHeight,
                      maxHeight: maxHeight,
                    ),
                    child: content,
                  );
                },
              )
            : content,
      ),
    );
  }

  /// 便捷弹出方法。返回 sheet 的结果。
  static Future<R?> show<R>(
    BuildContext context, {
    String? title,
    required Widget child,
    List<Widget>? actions,
    Widget? footer,
    bool isScrollControlled = true,
    bool expand = false,
    bool scrollable = false,
    double maxHeightFactor = 0.7,
    double minHeightFactor = 0,
    double expandHeightFactor = 0.92,
  }) {
    final palette = FxPalette.of(context);
    return showModalBottomSheet<R>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: FxRadius.sheetRadius),
      ),
      builder: (ctx) {
        final sheet = FxSheet(
          title: title,
          actions: actions,
          footer: footer,
          scrollable: scrollable,
          maxHeightFactor: maxHeightFactor,
          minHeightFactor: minHeightFactor,
          child: child,
        );
        if (expand) {
          return FractionallySizedBox(
            heightFactor: expandHeightFactor,
            child: sheet,
          );
        }
        return sheet;
      },
    );
  }
}
