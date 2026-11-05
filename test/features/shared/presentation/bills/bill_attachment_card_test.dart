import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment_reader.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_attachment_card.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('attachment card reports a real saved result from reader', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(const _FakeReader()));
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.textContaining('已保存：/tmp/report.txt'), findsOneWidget);
  });

  testWidgets('unsupported attachment action is not reported as success', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(const _UnsupportedReader()));
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    expect(find.textContaining('暂不支持打开或保存'), findsOneWidget);
    expect(find.textContaining('已交给系统查看器'), findsNothing);
  });
}

Widget _harness(BillAttachmentReader reader) {
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
    home: Scaffold(
      body: BillAttachmentCard(
        file: const BillFileVo(
          fileId: 1,
          originalName: 'report.txt',
          contentType: 'text/plain',
          fileData: 'dGVzdA==',
        ),
        reader: reader,
      ),
    ),
  );
}

class _FakeReader extends BillAttachmentReader {
  const _FakeReader();

  @override
  Future<BillAttachmentActionResult> open(BillFileVo file) async =>
      const BillAttachmentActionResult(BillAttachmentActionStatus.opened);

  @override
  Future<BillAttachmentActionResult> save(BillFileVo file) async =>
      const BillAttachmentActionResult(
        BillAttachmentActionStatus.saved,
        path: '/tmp/report.txt',
      );
}

class _UnsupportedReader extends BillAttachmentReader {
  const _UnsupportedReader();

  @override
  Future<BillAttachmentActionResult> open(BillFileVo file) async =>
      const BillAttachmentActionResult(BillAttachmentActionStatus.unsupported);
}
