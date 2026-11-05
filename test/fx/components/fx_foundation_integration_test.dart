import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/amount_field.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

void main() {
  testWidgets('theme preserves compact borderless ledger amount editing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 140,
            child: AmountField(value: 1234.56, large: false, onChanged: (_) {}),
          ),
        ),
      ),
    );
    for (final focused in [false, true]) {
      if (focused) {
        await tester.tap(find.byType(TextField));
        await tester.pump();
      }
      final decoration = tester
          .widget<InputDecorator>(find.byType(InputDecorator))
          .decoration;
      final border = focused
          ? decoration.focusedBorder ?? decoration.border
          : decoration.enabledBorder ?? decoration.border;
      expect(border, InputBorder.none);
      expect(decoration.filled ?? false, isFalse);
      expect(decoration.contentPadding?.horizontal ?? 0, 0);
    }
    expect(tester.takeException(), isNull);
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'solid ${brightness.name} cards have visible pressed and focused states',
      (tester) async {
        final theme = brightness == Brightness.light
            ? FxTheme.light
            : FxTheme.dark;
        final palette = brightness == Brightness.light
            ? FxPalette.light
            : FxPalette.dark;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: FxCard(
                background: palette.primary,
                onTap: () {},
                child: const Text('快捷记账'),
              ),
            ),
          ),
        );
        final ink = tester.widget<InkWell>(find.byType(InkWell));
        final overlay =
            ink.overlayColor?.resolve({WidgetState.pressed}) ??
            ink.highlightColor ??
            theme.highlightColor;
        final blended = Color.alphaBlend(overlay, palette.primary);
        final difference =
            (blended.computeLuminance() - palette.primary.computeLuminance())
                .abs();
        expect(difference, greaterThan(0.005));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        final material = tester.widget<Material>(
          find
              .descendant(
                of: find.byType(FxCard),
                matching: find.byType(Material),
              )
              .first,
        );
        final shape = material.shape! as RoundedRectangleBorder;
        expect(shape.side.width, greaterThanOrEqualTo(2));
        expect(shape.side.color, isNot(palette.primary));
      },
    );
  }
}
