import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/util/currency_symbol.dart';

/// 大金额输入（tabular figures，两位小数）。用于转账单金额与分类拆分行。
class AmountField extends StatefulWidget {
  const AmountField({
    super.key,
    this.label,
    required this.value,
    required this.onChanged,
    this.currencyCode,
    this.tint,
    this.large = true,
  });

  final String? label;
  final double value;
  final ValueChanged<double> onChanged;
  final String? currencyCode;
  final Color? tint;
  final bool large;

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _fmt(widget.value));
  }

  @override
  void didUpdateWidget(AmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部值变化（如切换类型清零）且与当前文本不一致时同步。
    final current = double.tryParse(_controller.text) ?? 0;
    if ((current - widget.value).abs() > 0.0001) {
      _controller.text = _fmt(widget.value);
    }
  }

  static String _fmt(double v) => v == 0 ? '' : _trim(v);

  static String _trim(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('.00') ? s.substring(0, s.length - 3) : s;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final symbol = (widget.currencyCode == null || widget.currencyCode!.isEmpty)
        ? ''
        : getCurrencySymbol(widget.currencyCode!);
    final color = widget.tint ?? palette.textPrimary;
    final fontSize = widget.large ? 34.0 : 20.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: FxTypography.label.copyWith(
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: FxSpacing.sm),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (symbol.isNotEmpty)
              Text(
                symbol,
                style: FxTypography.money.copyWith(
                  fontSize: fontSize * 0.6,
                  color: color,
                ),
              ),
            if (symbol.isNotEmpty) const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                style: FxTypography.money.copyWith(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: FxTypography.money.copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: palette.textTertiary,
                  ),
                ),
                onChanged: (t) => widget.onChanged(double.tryParse(t) ?? 0),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
