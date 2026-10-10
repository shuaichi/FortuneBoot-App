import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_args.dart';
import 'package:fortuneboot/features/orders/data/finance_order_contract.dart';
import 'package:fortuneboot/features/orders/data/order_money.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/features/orders/presentation/order_detail_page.dart';
import 'package:fortuneboot/features/orders/presentation/widgets/order_summary_strip.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('shows server pending amount and loads entries separately', (
    tester,
  ) async {
    final service = _FakeOrdersService();

    await _pumpDetail(tester, service: service);
    await tester.pumpAndSettle();

    expect(find.textContaining('600.00'), findsWidgets);
    expect(find.byType(OrderSummaryStrip), findsOneWidget);
    expect(find.textContaining('1,000.00'), findsOneWidget);
    expect(find.textContaining('400.00'), findsOneWidget);
    expect(service.detailCalls, greaterThanOrEqualTo(1));
    expect(service.entryCalls, greaterThanOrEqualTo(1));
  });

  testWidgets('shows archive only when server allows it', (tester) async {
    final allowed = _FakeOrdersService(canClose: true);
    await _pumpDetail(tester, service: allowed);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('order-archive')), findsOneWidget);
  });

  testWidgets('hides archive when the server does not allow it', (
    tester,
  ) async {
    final service = _FakeOrdersService(canClose: false);

    await _pumpDetail(tester, service: service);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('order-archive')), findsNothing);
  });

  testWidgets('WRITE_OFF requires a second confirmation with cash warning', (
    tester,
  ) async {
    final service = _FakeOrdersService();
    final args = <BillEditorArgs>[];

    await _pumpDetail(
      tester,
      service: service,
      editorLauncher: (arg) async {
        args.add(arg);
        return false;
      },
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('order-write-off')));
    await tester.pumpAndSettle();

    expect(find.text(S.current.ordersWriteOffConfirmTitle), findsOneWidget);
    expect(
      find.textContaining(S.current.ordersWriteOffNoCashChange),
      findsOneWidget,
    );
    await tester.tap(find.text(S.current.commonConfirm));
    await tester.pumpAndSettle();

    expect(args.single.presetOrderComponent, FinanceOrderComponent.writeOff);
  });

  testWidgets('void and restore refresh detail and bump bill mutations', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = _FakeOrdersService();
    await _pumpDetail(tester, service: service);
    await tester.pumpAndSettle();
    final revision = BillMutations.revision.value;

    await tester.ensureVisible(
      find.byKey(const ValueKey('order-entry-void-91')),
    );
    expect(find.byKey(const ValueKey('order-entry-void-91')), findsOneWidget);
    tester
        .widget<FxIconButton>(find.byKey(const ValueKey('order-entry-void-91')))
        .onPressed!();
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.commonConfirm));
    await tester.pumpAndSettle();

    expect(
      service.entryActions.map((action) => action.action),
      contains('void'),
    );
    expect(BillMutations.revision.value, revision + 1);
    expect(service.detailCalls, greaterThanOrEqualTo(2));
    expect(service.entryCalls, greaterThanOrEqualTo(2));

    await tester.ensureVisible(
      find.byKey(const ValueKey('order-entry-restore-92')),
    );
    tester
        .widget<FxIconButton>(
          find.byKey(const ValueKey('order-entry-restore-92')),
        )
        .onPressed!();
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.commonConfirm));
    await tester.pumpAndSettle();

    expect(
      service.entryActions.map((action) => action.action),
      contains('restore'),
    );
  });
}

Future<void> _pumpDetail(
  WidgetTester tester, {
  required _FakeOrdersService service,
  Future<bool> Function(BillEditorArgs args)? editorLauncher,
}) {
  final preferences = PreferencesCubit();
  addTearDown(preferences.close);
  return tester.pumpWidget(
    BlocProvider<PreferencesCubit>.value(
      value: preferences,
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
        home: OrderDetailPage(
          service: service,
          bookId: 7,
          orderId: 11,
          editorLauncher: editorLauncher,
        ),
      ),
    ),
  );
}

class _FakeOrdersService extends OrdersService {
  _FakeOrdersService({this.canClose = true});

  final bool canClose;
  var detailCalls = 0;
  var entryCalls = 0;
  var pendingCents = 60000;
  final entryActions = <({String action, int billId})>[];

  @override
  Future<FinanceOrderDetail> getDetail({
    required int bookId,
    required int orderId,
  }) async {
    detailCalls++;
    return FinanceOrderDetail(
      orderId: 11,
      bookId: 7,
      title: '张三借款',
      counterpartyName: '张三',
      type: FinanceOrderType.payable,
      status: 200,
      currencyCode: 'CNY',
      version: 4,
      issuedAmount: OrderMoney.fromCents(100000),
      settledAmount: OrderMoney.fromCents(40000),
      pendingAmount: OrderMoney.fromCents(pendingCents),
      adjustedAmount: OrderMoney.fromCents(0),
      allowedEntryActions: const [
        'LOAN_IN',
        'LOAN_REPAY',
        'INTEREST_OUT',
        'FEE',
        'WRITE_OFF',
      ],
      canEdit: true,
      canDelete: false,
      canClose: canClose,
      pendingEntryCount: 1,
    );
  }

  @override
  Future<FinanceOrderEntryPage> getEntries({
    required int bookId,
    required int orderId,
    int pageNum = 1,
    int pageSize = 20,
    String entryStatus = 'ACTIVE',
  }) async {
    entryCalls++;
    return FinanceOrderEntryPage(
      rows: [
        FinanceOrderEntry(
          billId: 91,
          bookId: 7,
          orderId: 11,
          title: '借入',
          amount: OrderMoney.fromCents(100000),
          billType: 11,
          orderComponent: FinanceOrderComponent.principal,
          allowedActions: const ['EDIT', 'VOID'],
        ),
        FinanceOrderEntry(
          billId: 92,
          bookId: 7,
          orderId: 11,
          title: '归还本金',
          amount: OrderMoney.fromCents(40000),
          billType: 12,
          orderComponent: FinanceOrderComponent.principal,
          recycleBin: true,
          allowedActions: const ['RESTORE'],
        ),
      ],
      total: 2,
    );
  }

  @override
  Future<FinanceOrderSummary> getSummary({required int bookId}) async =>
      FinanceOrderSummary(payableAmount: OrderMoney.fromCents(60000));

  @override
  Future<FinanceOrderMutationResult> entryAction({
    required int bookId,
    required int orderId,
    required int billId,
    required FinanceOrderEntryAction action,
    required String requestId,
    required int expectedVersion,
  }) async {
    entryActions.add((action: action.value, billId: billId));
    if (action == FinanceOrderEntryAction.voidEntry) {
      pendingCents = 100000;
    } else if (action == FinanceOrderEntryAction.restore) {
      pendingCents = 60000;
    }
    return FinanceOrderMutationResult(orderId: 11, version: 5);
  }
}
