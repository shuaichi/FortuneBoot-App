import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/components/fx_confirm_sheet.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
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

Future<void> _openGuardedSheet(
  WidgetTester tester, {
  required bool dirty,
  bool busy = false,
}) async {
  await tester.pumpWidget(
    _app(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => FxSheet.show<void>(
            context,
            title: '编辑账单',
            child: FxSheetPopGuard(
              hasUnsavedChanges: dirty,
              isBusy: busy,
              child: const Text('账单内容'),
            ),
          ),
          child: const Text('打开'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('unchanged sheet closes without a confirmation', (tester) async {
    await _openGuardedSheet(tester, dirty: false);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(FxSheet), findsNothing);
  });

  testWidgets('dirty sheet can keep editing or explicitly discard', (
    tester,
  ) async {
    await _openGuardedSheet(tester, dirty: true);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('继续编辑'), findsOneWidget);

    await tester.tap(find.text('继续编辑'));
    await tester.pumpAndSettle();
    expect(find.byType(FxSheet), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('放弃修改'));
    await tester.pumpAndSettle();
    expect(find.byType(FxSheet), findsNothing);
  });

  testWidgets('busy guarded sheet cannot be dismissed from the barrier', (
    tester,
  ) async {
    await _openGuardedSheet(tester, dirty: false, busy: true);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byType(FxSheet), findsOneWidget);
  });

  testWidgets('confirm sheet stays open while pending and explains failure', (
    tester,
  ) async {
    final pending = Completer<bool>();
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => FxConfirmSheet.show(
              context,
              title: '删除账单',
              message: '删除后不可恢复',
              confirmLabel: '删除',
              cancelLabel: '取消',
              onConfirm: () => pending.future,
            ),
            child: const Text('打开'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pump();
    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(FxSheet), findsOneWidget);

    pending.complete(false);
    await tester.pumpAndSettle();
    expect(find.text('操作未完成，请重试'), findsOneWidget);
    expect(find.byType(FxSheet), findsOneWidget);
  });
}
