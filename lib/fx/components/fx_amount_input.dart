import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/components/fx_text_field.dart';

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
    final pattern = allowNegative ? r'^-?\d*\.?\d{0,2}$' : r'^\d*\.?\d{0,2}$';
    return FxTextField(
      label: label,
      controller: controller,
      focusNode: focusNode,
      errorText: errorText,
      prefixIcon: currencySymbol == null
          ? null
          : Center(child: Text(currencySymbol!)),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(pattern))],
      textInputAction: TextInputAction.done,
      onChanged: (value) => onChanged?.call(double.tryParse(value)),
      onSubmitted: (value) => onSubmitted?.call(double.tryParse(value)),
      maxLines: 1,
    );
  }
}
