import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/components/fx_bar_chart.dart';
import 'package:fortuneboot/fx/components/fx_chart_palette.dart';
import 'package:fortuneboot/fx/components/fx_donut_chart.dart';
import 'package:fortuneboot/fx/components/fx_line_chart.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('chart grids use separator instead of control border', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        locale: const Locale('zh'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: const Scaffold(
          body: Column(
            children: [
              FxLineChart(
                series: [
                  FxLineSeries(
                    color: Colors.blue,
                    points: [FxLinePoint(name: '11月', value: 12)],
                  ),
                ],
              ),
              FxBarChart(items: [FxBarItem(name: '餐饮', value: 12)]),
            ],
          ),
        ),
      ),
    );

    final line = tester.widget<LineChart>(find.byType(LineChart));
    final lineGrid = line.data.gridData.getDrawingHorizontalLine(0);
    expect(lineGrid.color, FxPalette.light.separator);
    final bar = tester.widget<BarChart>(find.byType(BarChart));
    final barGrid = bar.data.gridData.getDrawingHorizontalLine(0);
    expect(barGrid.color, FxPalette.light.separator);
  });

  testWidgets('donut center amount uses primary body size', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        locale: const Locale('zh'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: const Scaffold(
          body: FxDonutChart(
            centerAmount: 1234,
            centerLabel: '总资产',
            currencyCode: 'CNY',
            showList: false,
            slices: [FxDonutSlice(name: '现金', value: 1234, percent: 100)],
          ),
        ),
      ),
    );

    final amount = tester.widget<FxMoneyText>(find.byType(FxMoneyText));
    expect(amount.fontSize, 17);
    final label = tester.widget<Text>(find.text('总资产'));
    expect(label.style?.fontSize, 13);
  });

  test('chart categorical fills adapt to dark brightness', () {
    final light = FxChartPalette.colorAt(0);
    final dark = FxChartPalette.colorAt(0, brightness: Brightness.dark);

    expect(dark, isNot(light));
  });
}
