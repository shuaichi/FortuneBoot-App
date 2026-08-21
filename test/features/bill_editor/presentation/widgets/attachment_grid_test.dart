import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/attachment_grid.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('renders a named file card for a non-image attachment', (
    tester,
  ) async {
    const file = PathBillAttachment(
      name: 'invoice.pdf',
      sizeBytes: 1024,
      path: '/tmp/invoice.pdf',
    );

    await tester.pumpWidget(
      _app(AttachmentGrid(files: [file], onAdd: () {}, onRemove: (_) {})),
    );

    expect(find.text('invoice.pdf'), findsOneWidget);
    expect(find.byIcon(Icons.insert_drive_file_rounded), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'invoice.pdf',
      ),
      findsOneWidget,
    );
  });

  testWidgets('disables attachment removal while submitting', (tester) async {
    var removeCalls = 0;

    await tester.pumpWidget(
      _app(
        AttachmentGrid(
          files: const [
            PathBillAttachment(
              name: 'document.txt',
              sizeBytes: 1024,
              path: '/tmp/document.txt',
            ),
          ],
          enabled: false,
          onAdd: () {},
          onRemove: (_) => removeCalls += 1,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    expect(removeCalls, 0);
  });
}

Widget _app(Widget child) {
  return MaterialApp(
    theme: FxTheme.light,
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      S.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: Scaffold(body: child),
  );
}
