import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

void main() {
  testWidgets('application theme builds a material surface', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        home: const Scaffold(body: Text('FortuneBoot')),
      ),
    );

    expect(find.text('FortuneBoot'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
