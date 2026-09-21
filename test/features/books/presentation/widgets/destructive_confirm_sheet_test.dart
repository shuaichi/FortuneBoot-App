import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/books/presentation/widgets/destructive_confirm_sheet.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('LOW uses a primary confirmation and returns false on cancel', (
    tester,
  ) async {
    final result = Completer<bool>();

    await tester.pumpWidget(
      _harness(
        onOpen: (context) async {
          result.complete(
            await DestructiveConfirmSheet.show(
              context,
              title: '发送邀请',
              message: '确认向小王发送邀请？',
              confirmLabel: '发送',
              cancelLabel: '取消',
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('打开确认'));
    await tester.pumpAndSettle();

    expect(find.byType(FxSheet), findsOneWidget);
    expect(find.text('发送邀请'), findsOneWidget);
    expect(find.text('确认向小王发送邀请？'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(_button('发送').variant, FxButtonVariant.filled);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(await result.future, isFalse);
  });

  testWidgets('MID renders risk copy and returns true on confirm', (
    tester,
  ) async {
    final result = Completer<bool>();

    await tester.pumpWidget(
      _harness(
        onOpen: (context) async {
          result.complete(
            await DestructiveConfirmSheet.show(
              context,
              title: '删除账单',
              message: '确认删除午餐吗？',
              subMessage: '删除后无法恢复。',
              confirmLabel: '删除',
              cancelLabel: '取消',
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('打开确认'));
    await tester.pumpAndSettle();

    expect(find.text('确认删除午餐吗？'), findsOneWidget);
    expect(find.text('删除后无法恢复。'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(_button('删除').variant, FxButtonVariant.critical);

    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(await result.future, isTrue);
  });

  testWidgets('HIGH unlocks only after checkbox and exact Chinese name match', (
    tester,
  ) async {
    final result = Completer<bool>();

    await tester.pumpWidget(
      _harness(
        onOpen: (context) async {
          result.complete(
            await DestructiveConfirmSheet.show(
              context,
              title: '永久删除账本',
              message: '此操作不可恢复。',
              nameToMatch: '家庭备用账本',
              checkboxLabel: '我已知晓风险',
              confirmLabel: '永久删除',
              cancelLabel: '取消',
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('打开确认'));
    await tester.pumpAndSettle();

    expect(find.text('永久删除账本'), findsOneWidget);
    expect(_button('永久删除').variant, FxButtonVariant.critical);
    expect(_button('永久删除').onPressed, isNull);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    expect(_button('永久删除').onPressed, isNull);

    await tester.enterText(find.byType(TextField), '家庭备用');
    await tester.pump();
    expect(_button('永久删除').onPressed, isNull);

    await tester.enterText(find.byType(TextField), '家庭备用账本');
    await tester.pump();
    expect(_button('永久删除').onPressed, isNotNull);

    await tester.tap(find.text('永久删除'));
    await tester.pumpAndSettle();

    expect(await result.future, isTrue);
    expect(find.byType(FxSheet), findsNothing);
  });
}

FxButton _button(String label) {
  return find
          .ancestor(of: find.text(label), matching: find.byType(FxButton))
          .evaluate()
          .single
          .widget
      as FxButton;
}

Widget _harness({required Future<void> Function(BuildContext context) onOpen}) {
  return MaterialApp(
    theme: FxTheme.light,
    locale: const Locale('zh'),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      S.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => onOpen(context),
            child: const Text('打开确认'),
          ),
        ),
      ),
    ),
  );
}
