import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 统一 bottom sheet 壳：圆角 + 拖拽条 + 可选标题。theme-aware，支持暗色。
class FxSheet extends StatelessWidget {
  /// 选择器 / Picker 类 sheet：列表选择、日期选择等。
  static const double pickerHeightFactor = 0.82;

  /// 表单类 sheet：新建 / 编辑，接近全屏以保证键盘升起后仍有空间。
  static const double formHeightFactor = 0.92;

  /// 详情 / 确认类 sheet：详情、删除确认等默认高度。
  static const double detailHeightFactor = 0.7;

  /// 中型 sheet：筛选、轻量列表等介于详情和引导之间的内容。
  static const double mediumHeightFactor = 0.5;

  /// 小型引导 sheet：空态提示、引导卡等。
  static const double hintHeightFactor = 0.4;

  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? footer;
  final String? submitLabel;
  final FutureOr<void> Function()? onSubmit;
  final bool submitLoading;
  final String? secondaryLabel;
  final FutureOr<void> Function()? onSecondary;
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
    this.submitLabel,
    this.onSubmit,
    this.submitLoading = false,
    this.secondaryLabel,
    this.onSecondary,
    this.closeTooltip,
    this.dragHandleLabel,
    this.scrollable = false,
    this.maxHeightFactor = FxSheet.detailHeightFactor,
    this.minHeightFactor = 0,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;
    final usesAdaptiveHeight = scrollable && minHeightFactor > 0;
    final keyboardInset = viewInsets.bottom;
    Widget body = child;
    if (scrollable) {
      body = usesAdaptiveHeight
          ? SingleChildScrollView(padding: EdgeInsets.zero, child: child)
          : ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: child,
              ),
            );
    } else {
      assert(() {
        if (keyboardInset > 0) {
          debugPrint(
            '⚠️ FxSheet with scrollable=false may be obscured by keyboard. '
            'Consider scrollable: true or use footer.',
          );
        }
        return true;
      }());
    }

    final effectiveFooter = footer ?? _buildActionFooter(context);
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
    final content = effectiveFooter == null
        ? bodySection
        : Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: usesAdaptiveHeight
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(child: bodySection),
              effectiveFooter,
            ],
          );

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardInset),
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

  Widget? _buildActionFooter(BuildContext context) {
    if (submitLabel == null && secondaryLabel == null) return null;
    return _FxSheetActionFooter(
      submitLabel: submitLabel,
      onSubmit: onSubmit,
      submitLoading: submitLoading,
      secondaryLabel: secondaryLabel,
      onSecondary: onSecondary,
    );
  }

  /// 便捷弹出方法。返回 sheet 的结果。
  static Future<R?> show<R>(
    BuildContext context, {
    String? title,
    required Widget child,
    List<Widget>? actions,
    Widget? footer,
    String? submitLabel,
    FutureOr<void> Function()? onSubmit,
    bool submitLoading = false,
    String? secondaryLabel,
    FutureOr<void> Function()? onSecondary,
    bool isScrollControlled = true,
    bool expand = false,
    bool scrollable = false,
    double maxHeightFactor = FxSheet.detailHeightFactor,
    double minHeightFactor = 0,
    double expandHeightFactor = FxSheet.formHeightFactor,
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
          submitLabel: submitLabel,
          onSubmit: onSubmit,
          submitLoading: submitLoading,
          secondaryLabel: secondaryLabel,
          onSecondary: onSecondary,
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

class _FxSheetActionFooter extends StatefulWidget {
  const _FxSheetActionFooter({
    this.submitLabel,
    this.onSubmit,
    this.submitLoading = false,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String? submitLabel;
  final FutureOr<void> Function()? onSubmit;
  final bool submitLoading;
  final String? secondaryLabel;
  final FutureOr<void> Function()? onSecondary;

  @override
  State<_FxSheetActionFooter> createState() => _FxSheetActionFooterState();
}

class _FxSheetActionFooterState extends State<_FxSheetActionFooter> {
  bool _submitting = false;
  bool _secondarySubmitting = false;

  bool get _submitBusy => widget.submitLoading || _submitting;

  Future<void> _runSubmit() async {
    final onSubmit = widget.onSubmit;
    if (onSubmit == null || _submitBusy) return;
    setState(() => _submitting = true);
    try {
      await onSubmit();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _runSecondary() async {
    final onSecondary = widget.onSecondary;
    if (onSecondary == null || _secondarySubmitting) return;
    setState(() => _secondarySubmitting = true);
    try {
      await onSecondary();
    } finally {
      if (mounted) setState(() => _secondarySubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FxSpacing.lg,
          FxSpacing.md,
          FxSpacing.lg,
          FxSpacing.lg,
        ),
        child: Row(
          children: [
            if (widget.secondaryLabel != null) ...[
              Expanded(
                child: FxButton.text(
                  label: widget.secondaryLabel!,
                  loading: _secondarySubmitting,
                  onPressed: widget.onSecondary == null || _secondarySubmitting
                      ? null
                      : _runSecondary,
                ),
              ),
              const SizedBox(width: FxSpacing.md),
            ],
            if (widget.submitLabel != null)
              Expanded(
                flex: widget.secondaryLabel == null ? 1 : 2,
                child: FxButton(
                  label: widget.submitLabel!,
                  expand: true,
                  loading: _submitBusy,
                  onPressed: widget.onSubmit == null || _submitBusy
                      ? null
                      : _runSubmit,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
