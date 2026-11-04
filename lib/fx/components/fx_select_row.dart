import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 表单属性选择行：左侧字段名、右侧当前值、尾部箭头。
///
/// 用于分类 / 标签 / 账户 / 成员等属性入口，统一替代各页面自行实现的
/// ListTile 或大块 chip 云。低频说明和排序等字段应留在编辑表单，不进入本行。
class FxSelectRow extends StatelessWidget {
  const FxSelectRow({
    super.key,
    required this.label,
    required this.onTap,
    this.value,
    this.placeholder,
    this.required = false,
    this.onClear,
    this.labelWidth = 96,
    this.padding = const EdgeInsets.symmetric(
      horizontal: FxSpacing.lg,
      vertical: FxSpacing.md,
    ),
  });

  final String label;
  final String? value;
  final String? placeholder;
  final bool required;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final double labelWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final hasValue = value != null && value!.isNotEmpty;
    final display = hasValue ? value! : placeholder ?? '';

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: hasValue ? '$label, $display' : label,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!.call();
              },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: padding,
            child: Row(
              children: [
                SizedBox(
                  width: labelWidth,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FxTypography.label.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                      ),
                      if (required)
                        Text(
                          ' *',
                          style: FxTypography.label.copyWith(
                            color: palette.danger,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    display,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FxTypography.body.copyWith(
                      color: hasValue
                          ? palette.textPrimary
                          : palette.textTertiary,
                    ),
                  ),
                ),
                if (hasValue && onClear != null) ...[
                  const SizedBox(width: FxSpacing.xs),
                  Semantics(
                    button: true,
                    label: S.of(context).fxTreePickerClear,
                    child: InkResponse(
                      onTap: onClear,
                      radius: 18,
                      child: SizedBox(
                        width: 32,
                        height: 48,
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: palette.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: FxSpacing.sm),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: palette.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
