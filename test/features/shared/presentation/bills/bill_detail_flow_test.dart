import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_detail_flow.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_detail_sheet.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('shows the shared bill detail sheet for a selected bill', (
    tester,
  ) async {
    const bill = FortuneBillVo(billId: 1, title: '午餐', amount: 28, billType: 1);

    await tester.pumpWidget(_detailHarness(bill));

    await tester.tap(find.text('打开详情'));
    await tester.pumpAndSettle();

    expect(find.byType(BillDetailSheet), findsOneWidget);
    expect(find.text('午餐'), findsOneWidget);
    expect(find.text('编辑'), findsOneWidget);
    expect(find.text('复制'), findsOneWidget);
    expect(find.text('删除'), findsOneWidget);

    final sheetHeight = tester.getSize(find.byType(FxSheet)).height;
    final viewportHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(sheetHeight, greaterThanOrEqualTo(viewportHeight * 0.4));
    expect(sheetHeight, lessThanOrEqualTo(viewportHeight * 0.72));
    expect(
      tester.getBottomLeft(find.byType(BillDetailActions)).dy,
      closeTo(tester.getBottomLeft(find.byType(FxSheet)).dy, 1),
    );
  });

  testWidgets('invokes only the copy callback when copy is tapped', (
    tester,
  ) async {
    var copyCount = 0;
    var editCount = 0;
    var deleteCount = 0;
    var confirmCount = 0;

    await tester.pumpWidget(
      MaterialApp(
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
          body: BillDetailActions(
            bill: const FortuneBillVo(billType: 1),
            onCopy: () => copyCount += 1,
            onEdit: () => editCount += 1,
            onDelete: () => deleteCount += 1,
            onConfirmToggle: (_) => confirmCount += 1,
          ),
        ),
      ),
    );

    await tester.tap(find.text('复制'));

    expect(copyCount, 1);
    expect(editCount, 0);
    expect(deleteCount, 0);
    expect(confirmCount, 0);
  });

  testWidgets('hides edit and copy actions for balance adjustments', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
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
          body: BillDetailActions(
            bill: const FortuneBillVo(billType: 4),
            onCopy: () {},
            onEdit: () {},
            onDelete: () {},
            onConfirmToggle: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('编辑'), findsNothing);
    expect(find.text('复制'), findsNothing);
    expect(find.text('删除'), findsOneWidget);
  });

  testWidgets('uses compact actions at 414 pixels without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
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
          body: BillDetailActions(
            bill: const FortuneBillVo(billType: 1),
            onCopy: () {},
            onEdit: () {},
            onDelete: () {},
            onConfirmToggle: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('复制'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps bill detail actions fixed on a small viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bill = FortuneBillVo(
      billId: 1,
      title: '小屏账单',
      amount: 28,
      billType: 1,
      remark: List.filled(40, '这是需要滚动查看的账单备注').join(),
    );

    await tester.pumpWidget(_detailHarness(bill));
    await tester.tap(find.text('打开详情'));
    await tester.pumpAndSettle();

    final editButton = find.text('编辑');
    final copyButton = find.text('复制');
    final editTop = tester.getTopLeft(editButton).dy;
    final copyTop = tester.getTopLeft(copyButton).dy;
    final sheetHeight = tester.getSize(find.byType(FxSheet)).height;

    expect(tester.takeException(), isNull);
    expect(sheetHeight, lessThanOrEqualTo(568 * 0.72));
    expect(find.byType(SingleChildScrollView), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(editButton).dy, editTop);
    expect(tester.getTopLeft(copyButton).dy, copyTop);
    expect(tester.takeException(), isNull);
  });
}

Widget _detailHarness(FortuneBillVo bill) {
  return BlocProvider(
    create: (_) => PreferencesCubit(),
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
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () =>
                BillDetailFlow().show(context, bookId: 1, bill: bill),
            child: const Text('打开详情'),
          ),
        ),
      ),
    ),
  );
}
