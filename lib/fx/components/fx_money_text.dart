import 'package:flutter/widgets.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/util/currency_symbol.dart';
import 'package:intl/intl.dart';

/// 等宽金额文本：tabular figures + 正负色 + 币种符号 + 千分位。
///
/// [billType] 提供时按业务语义色渲染（1支出红 2收入绿 3转账紫 4调整橙 7/8支出红）。
/// 否则按 [signed] 与金额正负决定颜色（正绿负红），或用 [color] 强制。
class FxMoneyText extends StatelessWidget {
  final double amount;
  final String? currencyCode;
  final int? billType;
  final Color? color;
  final double fontSize;
  final FontWeight fontWeight;

  /// 是否显示正负号。转账/调整通常不显示；收支列表显示。
  final bool showSign;

  /// 是否按正负着色（无 billType 时生效）。
  final bool colorBySign;

  const FxMoneyText({
    super.key,
    required this.amount,
    this.currencyCode,
    this.billType,
    this.color,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.showSign = false,
    this.colorBySign = false,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = currencyCode == null || currencyCode!.isEmpty
        ? ''
        : getCurrencySymbol(currencyCode!);

    final formatter = NumberFormat('#,##0.00');
    final absText = formatter.format(amount.abs());

    String signPrefix = '';
    if (showSign) {
      if (amount > 0) {
        signPrefix = '+';
      } else if (amount < 0) {
        signPrefix = '-';
      }
    } else if (amount < 0) {
      signPrefix = '-';
    }

    final text = '$signPrefix$symbol$absText';

    Color resolved;
    if (color != null) {
      resolved = color!;
    } else if (billType != null) {
      resolved = FxFinanceColors.of(context).forBillType(billType);
    } else if (colorBySign) {
      final fin = FxFinanceColors.of(context);
      resolved = amount >= 0 ? fin.income : fin.expense;
    } else {
      resolved = FxColors.textPrimary;
    }

    return Text(
      text,
      style: FxTypography.money.copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: resolved,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
