import 'package:flutter/material.dart';
import 'package:fortuneboot/core/money/fx_money_formatter.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/util/currency_symbol.dart';

/// 等宽金额文本：tabular figures + 正负色 + 币种符号 + 千分位。
///
/// [billType] 提供时按业务语义色渲染（1支出红 2收入绿 3转账紫 4调整橙 7垫付 8报销）。
/// 否则按 [signed] 与金额正负决定颜色（正绿负红），或用 [color] 强制。
/// [masked] 为 true 时隐藏真实金额，显示 [maskedText]（用于首页金额隐私）。
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

  /// 是否掩码显示（隐藏金额）。
  final bool masked;

  /// 掩码占位文本。
  final String maskedText;

  /// Overrides the locale derived from [Localizations] when supplied.
  final Locale? locale;

  /// 宽度不足时使用紧凑金额；完整值仍保留给 Tooltip 与无障碍语义。
  final bool compactWhenNeeded;

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
    this.masked = false,
    this.maskedText = FxMoneyFormatter.hiddenPlaceholder,
    this.locale,
    this.compactWhenNeeded = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    Color resolved;
    if (color != null) {
      resolved = color!;
    } else if (billType != null) {
      resolved = FxFinanceColors.of(context).forBillType(billType);
    } else if (colorBySign) {
      final fin = FxFinanceColors.of(context);
      resolved = amount >= 0 ? fin.income : fin.expense;
    } else {
      resolved = FxPalette.of(context).textPrimary;
    }

    final isMasked = masked;
    final symbol = currencyCode == null || currencyCode!.isEmpty
        ? ''
        : getCurrencySymbol(currencyCode!);
    final text = isMasked
        ? maskedText
        : FxMoneyFormatter.format(
            amount,
            locale: (locale ?? Localizations.localeOf(context)).toString(),
            currencySymbol: symbol,
            showSign: showSign,
          );
    final safeColor = isMasked && color == null
        ? palette.textPrimary
        : resolved;
    final localeName = (locale ?? Localizations.localeOf(context)).toString();
    final style = FxTypography.money.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: safeColor,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        var displayText = text;
        if (compactWhenNeeded && !isMasked && constraints.hasBoundedWidth) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            locale: Localizations.localeOf(context),
            maxLines: 1,
          )..layout(maxWidth: constraints.maxWidth);
          if (painter.didExceedMaxLines) {
            final sign = showSign && amount > 0
                ? '+'
                : amount < 0
                ? '-'
                : '';
            final compactNumber = FxMoneyFormatter.formatCompact(
              amount.abs(),
              locale: localeName,
            );
            displayText = '$sign$symbol$compactNumber';
          }
          painter.dispose();
        }

        final amountText = Semantics(
          label: text,
          child: ExcludeSemantics(
            child: Text(
              displayText,
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
        if (displayText == text) {
          return amountText;
        }
        return Tooltip(message: text, child: amountText);
      },
    );
  }
}
