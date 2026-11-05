import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 表单属性选择行：字段名、完整当前值、清除与选择入口。
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
    final labelStyle = FxTypography.label.copyWith(
      color: palette.textSecondary,
    );
    final labelText = Text(label, style: labelStyle);
    final reflowLabelText = Wrap(
      children: [
        for (final token in label.split(' '))
          Text(token, style: labelStyle, maxLines: 1, softWrap: false),
      ],
    );
    final valueText = Text(
      display,
      style: FxTypography.body.copyWith(
        color: hasValue ? palette.textPrimary : palette.textTertiary,
      ),
    );
    final clear = hasValue && onClear != null
        ? Semantics(
            container: true,
            button: true,
            label: '${S.of(context).fxClearLabel} $label',
            child: InkResponse(
              onTap: onClear,
              radius: 24,
              child: SizedBox(
                width: 44,
                height: 48,
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: palette.textTertiary,
                ),
              ),
            ),
          )
        : null;
    final chevron = Icon(
      Icons.chevron_right_rounded,
      size: 20,
      color: palette.textTertiary,
    );

    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: hasValue ? '$label, $display' : label,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: padding,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final labelPainter = TextPainter(
                  text: TextSpan(text: label, style: labelStyle),
                  textDirection: Directionality.of(context),
                  textScaler: MediaQuery.textScalerOf(context),
                  maxLines: 1,
                )..layout();
                final labelFitsInline = labelPainter.width <= labelWidth;
                labelPainter.dispose();
                final reflow =
                    constraints.maxWidth < 360 ||
                    MediaQuery.textScalerOf(context).scale(1) > 1.3 ||
                    !labelFitsInline;
                if (reflow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          reflowLabelText,
                          if (required)
                            Text(
                              ' *',
                              style: FxTypography.label.copyWith(
                                color: palette.danger,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: FxSpacing.xs),
                      valueText,
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (clear != null) clear,
                            const SizedBox(width: FxSpacing.xs),
                            chevron,
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: labelWidth,
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          labelText,
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
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: valueText,
                      ),
                    ),
                    if (clear != null) ...[
                      const SizedBox(width: FxSpacing.xs),
                      clear,
                    ],
                    const SizedBox(width: FxSpacing.sm),
                    chevron,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
