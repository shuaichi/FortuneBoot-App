import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 统一 bottom sheet 壳：圆角 + 拖拽条 + 可选标题。
class FxSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final bool scrollable;

  const FxSheet({
    super.key,
    this.title,
    required this.child,
    this.actions,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: FxSpacing.sm),
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: FxColors.border,
              borderRadius: BorderRadius.circular(2),
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
                Text(title!, style: FxTypography.title),
                if (actions != null) Row(mainAxisSize: MainAxisSize.min, children: actions!),
              ],
            ),
          ),
        ],
        const SizedBox(height: FxSpacing.md),
        Flexible(child: child),
      ],
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: content,
      ),
    );
  }

  /// 便捷弹出方法。返回 sheet 的结果。
  static Future<R?> show<R>(
    BuildContext context, {
    String? title,
    required Widget child,
    List<Widget>? actions,
    bool isScrollControlled = true,
    bool expand = false,
  }) {
    return showModalBottomSheet<R>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: FxColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: FxRadius.sheetRadius),
      ),
      builder: (ctx) {
        final sheet = FxSheet(title: title, actions: actions, child: child);
        if (expand) {
          return FractionallySizedBox(heightFactor: 0.92, child: sheet);
        }
        return sheet;
      },
    );
  }
}
