import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/components/fx_list_section.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

void main() {
  testWidgets(
    'rows share one surface with separators instead of card shadows',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: FxTheme.light,
          home: const Scaffold(
            body: FxListSection(children: [Text('甲'), Text('乙')]),
          ),
        ),
      );

      expect(find.byType(Divider), findsOneWidget);
      final material = tester.widget<Material>(
        find
            .ancestor(of: find.text('甲'), matching: find.byType(Material))
            .first,
      );
      expect(material.elevation, 0);
      expect(material.color, FxPalette.light.surface);
    },
  );
}
