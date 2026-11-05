import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/components/fx_text_field.dart';

class _FxAmountTextInputFormatter extends TextInputFormatter {
  const _FxAmountTextInputFormatter({required this.allowNegative});

  final bool allowNegative;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    const fullWidthDigits = '０１２３４５６７８９';
    var normalized = newValue.text.trim();
    for (var index = 0; index < fullWidthDigits.length; index++) {
      normalized = normalized.replaceAll(fullWidthDigits[index], '$index');
    }
    normalized = normalized
        .replaceAll('．', '.')
        .replaceAll('－', '-')
        .replaceAll(RegExp(r'[\s,，¥￥$€£]'), '');
    final pattern = allowNegative ? r'^-?\d*\.?\d{0,2}$' : r'^\d*\.?\d{0,2}$';
    if (!RegExp(pattern).hasMatch(normalized)) return oldValue;
    if (normalized == newValue.text) return newValue;
    return TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }
}

/// Numeric amount input for newly migrated forms.
class FxAmountInput extends StatelessWidget {
  const FxAmountInput({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.currencySymbol,
    this.errorText,
    this.allowNegative = false,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? currencySymbol;
  final String? errorText;
  final bool allowNegative;
  final ValueChanged<double?>? onChanged;
  final ValueChanged<double?>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return FxTextField(
      label: label,
      controller: controller,
      focusNode: focusNode,
      errorText: errorText,
      prefixIcon: currencySymbol == null
          ? null
          : Center(child: Text(currencySymbol!)),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        _FxAmountTextInputFormatter(allowNegative: allowNegative),
      ],
      textInputAction: TextInputAction.done,
      onChanged: (value) => onChanged?.call(double.tryParse(value)),
      onSubmitted: (value) {
        FocusManager.instance.primaryFocus?.unfocus();
        onSubmitted?.call(double.tryParse(value));
      },
      maxLines: 1,
    );
  }
}
