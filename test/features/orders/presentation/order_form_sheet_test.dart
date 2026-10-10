import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/orders/data/finance_order_contract.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/features/orders/presentation/widgets/order_form_sheet.dart';
import 'package:fortuneboot/features/payees/data/payee_models.dart';
import 'package:fortuneboot/features/payees/data/payee_service.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('type 3 create submits the selected type, not type 1', (
    tester,
  ) async {
    final service = _FakeOrdersService();
    final key = GlobalKey<OrderFormSheetState>();

    await _pumpForm(tester, key: key, service: service);
    await tester.tap(find.text(S.current.ordersTypePayable));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('order-counterparty-field')),
      '李四',
    );
    await tester.pump();

    final result = await key.currentState!.submit(continueFlow: true);

    expect(result, isNotNull);
    expect(service.createCommands.single.type, FinanceOrderType.payable);
    expect(service.createCommands.single.counterpartyName, '李四');
    expect(service.removeCalls, 0);
  });

  testWidgets('continue flow keeps the created draft ID after cancel', (
    tester,
  ) async {
    final service = _FakeOrdersService();
    final key = GlobalKey<OrderFormSheetState>();

    await _pumpForm(tester, key: key, service: service);
    await tester.enterText(
      find.byKey(const ValueKey('order-counterparty-field')),
      '张三',
    );
    await tester.pump();

    final result = await key.currentState!.submit(continueFlow: true);
    // 模拟 BillEditor 第二步被用户取消：返回结果只携带 draft identity。
    expect(result!.orderId, 31);
    expect(service.removeCalls, 0);
  });

  testWidgets('metadata edit locks type and counterparty with history', (
    tester,
  ) async {
    final service = _FakeOrdersService();

    await _pumpForm(
      tester,
      service: service,
      order: FinanceOrderDetail(
        orderId: 31,
        bookId: 7,
        title: '张三借款',
        type: FinanceOrderType.payable,
        status: 200,
        counterpartyName: '张三',
        version: 3,
        canDelete: false,
      ),
    );

    expect(find.text(S.current.ordersTypePayable), findsOneWidget);
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('order-counterparty-field')),
          )
          .enabled,
      isFalse,
    );
    expect(find.text(S.current.ordersCounterpartyLockedReason), findsOneWidget);
  });

  testWidgets('date can be cleared and empty remark is sent as empty', (
    tester,
  ) async {
    final service = _FakeOrdersService();
    final key = GlobalKey<OrderFormSheetState>();

    await _pumpForm(
      tester,
      key: key,
      service: service,
      order: FinanceOrderDetail(
        orderId: 31,
        bookId: 7,
        title: '张三借款',
        type: FinanceOrderType.receivable,
        status: 200,
        counterpartyName: '张三',
        dueDate: DateTime(2026, 10, 7),
        version: 3,
        canDelete: true,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('order-due-date-clear')));
    await tester.pump();

    await key.currentState!.submit();

    expect(service.modifyCommands.single.dueDate, isNull);
    expect(service.modifyCommands.single.remark, '');
  });
}

Future<void> _pumpForm(
  WidgetTester tester, {
  GlobalKey<OrderFormSheetState>? key,
  required _FakeOrdersService service,
  FinanceOrderDetail? order,
}) {
  return tester.pumpWidget(
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
        body: OrderFormSheet(
          key: key,
          service: service,
          bookId: 7,
          order: order,
          payeeService: _FakePayeeService(),
          requestIdFactory: () => 'request-1',
        ),
      ),
    ),
  );
}

class _FakeOrdersService extends OrdersService {
  final createCommands = <FinanceOrderCreateInput>[];
  final modifyCommands = <FinanceOrderMetadataInput>[];
  var removeCalls = 0;

  @override
  Future<FinanceOrderMutationResult> create(
    FinanceOrderCreateInput command,
  ) async {
    createCommands.add(command);
    return const FinanceOrderMutationResult(orderId: 31, version: 0);
  }

  @override
  Future<FinanceOrderMutationResult> modify(
    FinanceOrderMetadataInput command,
  ) async {
    modifyCommands.add(command);
    return FinanceOrderMutationResult(orderId: 31, version: 4);
  }
}

class _FakePayeeService extends PayeeService {
  @override
  Future<PayeePage> getPage({
    required int bookId,
    required bool recycleBin,
    String? payeeName,
    int pageSize = 200,
  }) async => PayeePage(
    rows: [
      const FortunePayeeVo(payeeId: 5, payeeName: '张三'),
      const FortunePayeeVo(payeeId: 6, payeeName: '李四'),
    ],
    total: 2,
  );
}
