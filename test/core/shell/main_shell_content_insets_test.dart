import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/shell/main_shell.dart';

void main() {
  testWidgets('shell reserves room for mobile navigation and floating action', (
    tester,
  ) async {
    late double inset;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(bottom: 20)),
          child: ShellContentInsets(
            bottom: 116,
            child: Builder(
              builder: (context) {
                inset = ShellContentInsets.bottomOf(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    expect(inset, 116);
  });
}
