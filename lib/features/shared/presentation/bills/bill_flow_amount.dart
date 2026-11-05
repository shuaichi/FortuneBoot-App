import 'package:flutter/material.dart';
import 'package:fortuneboot/core/money/fx_money_formatter.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/util/currency_symbol.dart';

/// 列表与详情共用的账单主金额口径、方向和隐私语义。
class BillFlowAmount extends StatelessWidget {
  const BillFlowAmount({
    super.key,
    required this.bill,
    this.masked = false,
    this.fontSize = 17,
  });

  final FortuneBillVo bill;
  final bool masked;
  final double fontSize;

  double get signedAmount {
    final amount = bill.hasExtrasAdjustment
        ? bill.settledAmount
        : bill.displayAmount;
    return FxBillType.fromValue(bill.billType)?.signedFlowAmount(amount) ??
        amount;
  }

  bool get _showSign =>
      bill.billType != FxBillType.transfer.value &&
      bill.billType != FxBillType.adjust.value;

  String label(Locale locale) {
    if (masked) return FxMoneyFormatter.hiddenPlaceholder;
    final currencyCode = bill.currencyCode;
    return FxMoneyFormatter.format(
      signedAmount,
      locale: locale.toString(),
      currencySymbol: currencyCode == null
          ? ''
          : getCurrencySymbol(currencyCode),
      showSign: _showSign,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final amount = signedAmount;
    final sign = masked || !_showSign || amount == 0
        ? ''
        : amount < 0
        ? '-'
        : '+';
    final style = FxTypography.money.copyWith(
      color: FxPalette.of(context).textPrimary,
      fontSize: fontSize,
    );
    return Semantics(
      label: label(locale),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sign.isNotEmpty) Text(sign, style: style),
            Flexible(
              child: FxMoneyText(
                amount: amount.abs(),
                currencyCode: bill.currencyCode,
                billType: bill.billType,
                fontSize: fontSize,
                masked: masked,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
