import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_args.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_detail_flow.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_detail_sheet.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  setUp(() {
    AppRouter.register(
      Routes.billEditor,
      (_) =>
          const Scaffold(body: SizedBox(key: ValueKey('editor-route-marker'))),
    );
  });

  testWidgets('shows the shared bill detail sheet for a selected bill', (
    tester,
  ) async {
    const bill = FortuneBillVo(
      billId: 1,
      title: '午餐',
      amount: 28,
      billType: 1,
      currencyCode: 'CNY',
    );

    await tester.pumpWidget(_detailHarness(bill));

    await tester.tap(find.text('打开详情'));
    await tester.pumpAndSettle();

    expect(find.byType(BillDetailSheet), findsOneWidget);
    expect(find.text('午餐'), findsOneWidget);
    expect(find.bySemanticsLabel('-¥28.00'), findsOneWidget);
    expect(find.text('编辑'), findsOneWidget);
    expect(find.text('复制'), findsNothing);
    expect(find.text('删除'), findsNothing);
    expect(find.byTooltip('更多操作'), findsOneWidget);

    final sheetHeight = tester.getSize(find.byType(FxSheet)).height;
    final viewportHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
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

    await tester.tap(find.byTooltip('更多操作'));
    await tester.pumpAndSettle();
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
    expect(find.text('删除'), findsNothing);
    expect(find.byTooltip('更多操作'), findsOneWidget);
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

    expect(find.text('复制'), findsNothing);
    expect(find.byTooltip('更多操作'), findsOneWidget);
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
    final moreButton = find.byTooltip('更多操作');
    final editTop = tester.getTopLeft(editButton).dy;
    final moreTop = tester.getTopLeft(moreButton).dy;
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
    expect(tester.getTopLeft(moreButton).dy, moreTop);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide viewport uses a bounded dialog instead of a bottom sheet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const bill = FortuneBillVo(
      billId: 1,
      title: '午餐',
      amount: 28,
      billType: 1,
      currencyCode: 'CNY',
    );
    await tester.pumpWidget(_detailHarness(bill));

    await tester.tap(find.text('打开详情'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(FxSheet), findsNothing);
    expect(find.byType(BillDetailSheet), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('bill-detail-dialog'))).width,
      560,
    );
    expect(
      find.byKey(const ValueKey('bill-detail-dialog-close')),
      findsOneWidget,
    );
  });

  testWidgets('confirm request exposes a busy action and prevents duplicates', (
    tester,
  ) async {
    final service = _PendingConfirmService();
    const bill = FortuneBillVo(
      billId: 1,
      title: '待确认账单',
      amount: 28,
      billType: 1,
      currencyCode: 'CNY',
      confirm: false,
      allowedActions: ['CONFIRM'],
    );
    await tester.pumpWidget(_detailHarness(bill, service: service));
    await tester.tap(find.text('打开详情'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('确认'));
    await tester.pump();
    expect(find.text('确认中…'), findsOneWidget);
    await tester.tap(find.text('确认中…'));
    await tester.pump();
    expect(service.confirmCount, 1);

    service.completer.complete();
    await tester.pumpAndSettle();
    expect(find.byType(BillDetailSheet), findsNothing);
  });

  testWidgets('source editor receives order component and version', (
    tester,
  ) async {
    const bill = FortuneBillVo(
      billId: 1,
      bookId: 7,
      orderId: 9,
      orderComponent: FinanceOrderComponent.fee,
      orderLedgerVersion: 4,
      title: '手续费',
      amount: 28,
      billType: 1,
      currencyCode: 'CNY',
      allowedActions: ['EDIT'],
    );
    await tester.pumpWidget(_detailHarness(bill));
    await tester.tap(find.text('打开详情'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('编辑'));
    await tester.pumpAndSettle();

    final editorRoute = ModalRoute.of(
      tester.element(find.byKey(const ValueKey('editor-route-marker'))),
    );
    final editorArgs = BillEditorArgs.fromRouteArgs(
      editorRoute?.settings.arguments,
    );
    expect(editorArgs.presetOrderComponent, FinanceOrderComponent.fee);
    expect(editorArgs.expectedOrderVersion, 4);
    expect(editorArgs.presetBookId, 7);
    expect(editorArgs.presetOrderId, 9);
  });

  testWidgets('cancelling deletion preserves the open bill detail', (
    tester,
  ) async {
    const bill = FortuneBillVo(
      billId: 1,
      title: '午餐',
      amount: 28,
      billType: 1,
      currencyCode: 'CNY',
    );
    await tester.pumpWidget(_detailHarness(bill));

    await tester.tap(find.text('打开详情'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('更多操作'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(find.text('取消'), findsOneWidget);
    expect(find.byType(BillDetailSheet), findsOneWidget);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(find.byType(BillDetailSheet), findsOneWidget);
    expect(find.text('午餐'), findsOneWidget);
    expect(find.text('编辑'), findsOneWidget);
  });

  testWidgets('wide deletion confirmation also uses a dialog', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const bill = FortuneBillVo(
      billId: 1,
      title: '午餐',
      amount: 28,
      billType: 1,
      currencyCode: 'CNY',
    );
    await tester.pumpWidget(_detailHarness(bill));
    await tester.tap(find.text('打开详情'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('更多操作'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(find.byType(FxSheet), findsNothing);
    expect(find.byType(Dialog), findsNWidgets(2));
    expect(
      tester.getSize(find.byKey(const ValueKey('destructive-dialog'))).width,
      440,
    );
  });

  testWidgets('dismissing detail during deletion never pops its host route', (
    tester,
  ) async {
    final service = _PendingBillService();
    const bill = FortuneBillVo(
      billId: 1,
      title: '午餐',
      amount: 28,
      billType: 1,
      currencyCode: 'CNY',
    );
    await tester.pumpWidget(
      _detailHarness(bill, service: service, pushHostRoute: true),
    );
    await tester.tap(find.text('打开宿主'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('打开详情'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('更多操作'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除').last);
    await tester.pump();

    final detailContext = tester.element(find.byType(BillDetailSheet));
    Navigator.of(detailContext).pop();
    await tester.pumpAndSettle();
    service.removeCompleter.complete();
    await tester.pumpAndSettle();

    expect(find.text('打开详情'), findsOneWidget);
    expect(find.text('打开宿主'), findsNothing);
  });
}

class _PendingBillService extends BillService {
  final removeCompleter = Completer<void>();

  @override
  Future<void> remove({required int bookId, required int billId}) {
    return removeCompleter.future;
  }
}

class _PendingConfirmService extends BillService {
  final completer = Completer<void>();
  int confirmCount = 0;

  @override
  Future<void> confirm({required int bookId, required int billId}) {
    confirmCount += 1;
    return completer.future;
  }
}

Widget _detailHarness(
  FortuneBillVo bill, {
  BillService? service,
  bool pushHostRoute = false,
}) {
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
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () {
              if (pushHostRoute) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (hostContext) => Scaffold(
                      body: ElevatedButton(
                        onPressed: () => BillDetailFlow(
                          service: service,
                        ).show(hostContext, bookId: 1, bill: bill),
                        child: const Text('打开详情'),
                      ),
                    ),
                  ),
                );
                return;
              }
              BillDetailFlow(
                service: service,
              ).show(context, bookId: 1, bill: bill);
            },
            child: Text(pushHostRoute ? '打开宿主' : '打开详情'),
          ),
        ),
      ),
    ),
  );
}
