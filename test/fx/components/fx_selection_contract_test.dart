import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/components/fx_option_picker.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tree/fx_tree_picker.dart';
import 'package:fortuneboot/generated/l10n.dart';

Widget _app(Widget child) => MaterialApp(
  theme: FxTheme.light,
  locale: const Locale('zh'),
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    S.delegate,
  ],
  supportedLocales: S.delegate.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('single option picker distinguishes selected clear and cancel', (
    tester,
  ) async {
    final results = <FxSelectionResult<int>>[];
    Future<void> open(BuildContext context) async {
      results.add(
        await showFxOptionPickerResult<int>(
          context,
          title: '交易对象',
          options: const [1, 2],
          labelOf: (value) => '对象 $value',
          idOf: (value) => value,
          selectedId: 1,
          allowClear: true,
          clearLabel: '清空交易对象',
        ),
      );
    }

    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => open(context),
            child: const Text('打开'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('对象 2'));
    await tester.pumpAndSettle();
    expect(results.single.kind, FxSelectionKind.selected);
    expect(results.single.value, 2);

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('清空交易对象'));
    await tester.pumpAndSettle();
    expect(results.last.kind, FxSelectionKind.cleared);
    expect(results.last.value, isNull);

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(results.last.kind, FxSelectionKind.cancelled);
    expect(results.last.value, isNull);
  });

  testWidgets('single tree picker returns empty selection only for clear', (
    tester,
  ) async {
    List<String>? result;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await FxTreePicker.show<String>(
                context,
                roots: const ['餐饮'],
                childrenOf: (_) => const [],
                labelOf: (value) => value,
                idOf: (value) => value,
                initialSelected: const {'餐饮'},
              );
            },
            child: const Text('打开'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('清空'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result, isEmpty);
  });
}
