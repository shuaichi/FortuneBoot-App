import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/preferences/dashboard_display_preferences.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_detail_sheet.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_flow_amount.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  test('bill flow semantics keep settled amount and direction', () {
    expect(BillFlowAmount(bill: _bill).signedAmount, -98);
    expect(BillFlowAmount(bill: _bill).label(const Locale('zh')), '-¥98.00');
    expect(
      BillFlowAmount(bill: _bill, masked: true).label(const Locale('zh')),
      '••••',
    );
  });

  testWidgets('detail shows settled amount and verifies all reading metadata', (
    tester,
  ) async {
    await tester.pumpWidget(_detailHarness(_bill));
    await tester.pumpAndSettle();

    expect(find.text('实付'), findsOneWidget);
    expect(find.bySemanticsLabel('-¥98.00'), findsOneWidget);
    expect(find.textContaining('原额'), findsWidgets);
    expect(find.textContaining('100.00'), findsWidgets);
    expect(find.textContaining('3.00'), findsWidgets);
    expect(find.textContaining('5.00'), findsWidgets);
    expect(find.text('标签一'), findsOneWidget);
    expect(find.text('标签四'), findsOneWidget);
    final position = tester
        .state<ScrollableState>(find.byType(Scrollable).last)
        .position;
    position.jumpTo(position.maxScrollExtent);
    await tester.pump();
    expect(find.text('附加分类 #8 · 机场停车费'), findsOneWidget);
    expect(find.text('第一段说明。\n\n第二段需要独立成行。'), findsOneWidget);
    expect(find.text('计入统计'), findsOneWidget);
    expect(find.text('待确认'), findsOneWidget);
    expect(find.text('手续费'), findsWidgets);
  });

  testWidgets('masked detail hides settled amounts from text and semantics', (
    tester,
  ) async {
    await tester.pumpWidget(_detailHarness(_bill, masked: true));
    await tester.pumpAndSettle();

    expect(find.textContaining('98.00'), findsNothing);
    expect(find.textContaining('100.00'), findsNothing);
    expect(find.bySemanticsLabel(RegExp('98.00|100.00')), findsNothing);
    expect(find.byTooltip(RegExp('98.00|100.00')), findsNothing);
  });

  testWidgets('long title and metadata reflow at 320 and 2x', (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_detailHarness(_bill, textScale: 2));
    await tester.pumpAndSettle();

    final title = tester.widget<Text>(find.text(_bill.title!));
    expect(title.maxLines, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('non-image attachment shows name, type and open/save actions', (
    tester,
  ) async {
    await tester.pumpWidget(_detailHarness(_bill));
    await tester.pumpAndSettle();

    expect(find.text('报销说明.pdf'), findsOneWidget);
    expect(find.textContaining('PDF'), findsOneWidget);
    expect(find.text('打开'), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
  });

  testWidgets('image preview uses a high contrast close action on black', (
    tester,
  ) async {
    await tester.pumpWidget(_detailHarness(_bill));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('bill-attachment-image')),
      300,
      scrollable: find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('bill-attachment-image')));
    await tester.pumpAndSettle();

    final close = tester.widget<FilledButton>(
      find.byKey(const ValueKey('bill-image-preview-close')),
    );
    final colors = close.style?.backgroundColor?.resolve({});
    final foreground = close.style?.foregroundColor?.resolve({});
    expect(colors, Colors.white);
    expect(foreground, Colors.black);
    expect(tester.takeException(), isNull);
  });

  testWidgets('source read-only actions stay disabled', (tester) async {
    await tester.pumpWidget(_detailHarness(_bill));
    await tester.pumpAndSettle();

    expect(find.text('编辑'), findsNothing);
    expect(find.text('取消确认'), findsNothing);
    expect(find.textContaining('单据已锁定'), findsOneWidget);
    expect(find.byTooltip('更多操作'), findsNothing);
    expect(find.byType(BillDetailActions), findsNothing);
    expect(find.text('复制'), findsNothing);
    expect(find.text('删除'), findsNothing);
  });
}

final _bill = FortuneBillVo(
  billId: 1,
  bookId: 7,
  orderId: 9,
  orderComponent: FinanceOrderComponent.fee,
  orderLedgerVersion: 4,
  title: '跨年夜酒店与手续费核对——标题需要在详情完整阅读',
  tradeTime: DateTime(2026, 11, 3, 21, 14),
  amount: 100,
  billType: 1,
  currencyCode: 'CNY',
  accountName: '日常银行卡',
  confirm: false,
  remark: '第一段说明。\n\n第二段需要独立成行。',
  readOnlyReason: '单据已锁定，不能修改',
  allowedActions: [],
  hasFile: true,
  categoryAmountPair: const [
    BillCategoryAmount(categoryName: '住宿', amount: 100),
  ],
  tagList: const [
    BillTag(tagName: '标签一'),
    BillTag(tagName: '标签二'),
    BillTag(tagName: '标签三'),
    BillTag(tagName: '标签四'),
  ],
  extras: const [
    BillExtra(extraType: 1, amount: 3, categoryId: 8, remark: '机场停车费'),
    BillExtra(extraType: 2, amount: 5, remark: '会员优惠'),
  ],
);

Widget _detailHarness(
  FortuneBillVo bill, {
  bool masked = false,
  double textScale = 1,
}) {
  return BlocProvider<PreferencesCubit>(
    create: (_) => PreferencesCubit()
      ..emit(
        const PreferencesState().copyWith(
          dashboard: DashboardDisplayPreferences(hideAmounts: masked),
        ),
      ),
    child: MaterialApp(
      theme: FxTheme.light,
      locale: const Locale('zh'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        S.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: SingleChildScrollView(
            child: BillDetailSheet(bill: bill, service: _DetailService()),
          ),
        ),
      ),
    ),
  );
}

class _DetailService extends BillService {
  @override
  Future<List<BillFileVo>> getFiles(int billId) async => [
    BillFileVo(
      fileId: 1,
      originalName: 'photo.png',
      contentType: 'image/png',
      fileData: base64Encode(List<int>.filled(8, 0)),
    ),
    BillFileVo(
      fileId: 2,
      originalName: '报销说明.pdf',
      contentType: 'application/pdf',
      fileData: base64Encode(utf8.encode('%PDF-1.4 test')),
    ),
  ];
}
