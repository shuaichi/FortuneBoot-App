import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/components/fx_amount_input.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

void main() {
  testWidgets('amount input normalizes common pasted currency text', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    double? changed;
    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        home: Scaffold(
          body: FxAmountInput(
            label: '金额',
            controller: controller,
            onChanged: (value) => changed = value,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), '￥ 1,234.56');

    expect(controller.text, '1234.56');
    expect(changed, 1234.56);
  });

  testWidgets('done action finishes numeric editing', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        home: Scaffold(
          body: FxAmountInput(label: '金额', focusNode: focusNode),
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(focusNode.hasFocus, isFalse);
  });

  testWidgets(
    'tap outside finishes editing and keeps the field label semantic',
    (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: FxTheme.light,
          home: Scaffold(
            body: Column(
              children: [
                FxAmountInput(label: '金额', focusNode: focusNode),
                TextButton(
                  key: const Key('outside'),
                  onPressed: () {},
                  child: const Text('其他操作'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);
      await tester.tap(find.byKey(const Key('outside')));
      await tester.pump();

      expect(focusNode.hasFocus, isFalse);
      expect(find.bySemanticsLabel('金额'), findsWidgets);
    },
  );
}
