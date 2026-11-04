import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/bills/presentation/widgets/bill_tile.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/recent_bills_card.dart';
import 'package:fortuneboot/features/orders/data/order_money.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/presentation/widgets/order_card.dart';
import 'package:fortuneboot/features/orders/presentation/widgets/order_entry_tile.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/components/fx_ledger_row.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('ledger row stacks content at 320px and keeps a 44px target', (
    tester,
  ) async {
    await _pump(
      tester,
      const FxLedgerRow(
        title: '家庭共同账户的午餐与交通费用',
        subtitle: '餐饮 · 日常银行卡 · 2026年11月4日',
        amount: FxMoneyText(
          amount: -123456789.12,
          currencyCode: 'CNY',
          compactWhenNeeded: true,
        ),
      ),
      width: 320,
      textScale: 1.3,
    );

    expect(find.byKey(FxLedgerRow.stackedContentKey), findsOneWidget);
    expect(tester.takeException(), isNull);
    final row = tester.getRect(find.byType(FxLedgerRow));
    expect(row.left, greaterThanOrEqualTo(0));
    expect(row.right, lessThanOrEqualTo(320));
  });

  testWidgets('amount and caption share the row trailing edge', (tester) async {
    const firstAmount = FxMoneyText(
      amount: -100,
      currencyCode: 'CNY',
      key: ValueKey('first-amount'),
    );
    const secondAmount = FxMoneyText(
      amount: -99,
      currencyCode: 'CNY',
      key: ValueKey('second-amount'),
    );
    await _pump(
      tester,
      const Column(
        children: [
          FxLedgerRow(
            title: '循环记账测试',
            amount: firstAmount,
            amountCaption: '10:00',
          ),
          FxLedgerRow(
            title: '早餐',
            amount: secondAmount,
            amountCaption: '07:30',
          ),
        ],
      ),
    );

    final expectedRight =
        tester.getRect(find.byType(FxLedgerRow).first).right - 16;
    for (final finder in [
      find.byKey(const ValueKey('first-amount')),
      find.byKey(const ValueKey('second-amount')),
      find.text('10:00'),
      find.text('07:30'),
    ]) {
      expect(
        tester.getRect(finder).right,
        moreOrLessEquals(expectedRight, epsilon: 0.01),
        reason: '金额与时间的右缘必须共用同一条列表基线',
      );
    }
  });

  testWidgets('bill and order rows share the ledger component', (tester) async {
    await _pump(
      tester,
      const BillTile(
        bill: FortuneBillVo(
          title: '午餐',
          amount: 28,
          currencyCode: 'CNY',
          billType: 1,
        ),
      ),
    );
    expect(find.byType(FxLedgerRow), findsOneWidget);

    await _pump(
      tester,
      OrderCard(
        order: FinanceOrderDetail(
          orderId: 1,
          title: '借款',
          counterpartyName: '张三',
          pendingAmount: OrderMoney.fromCents(10000),
        ),
        currencyCode: 'CNY',
        hideAmounts: false,
      ),
    );
    expect(find.byType(FxLedgerRow), findsOneWidget);
  });

  testWidgets('recent bill preview reuses the standard ledger component', (
    tester,
  ) async {
    await _pump(
      tester,
      RecentBillPreviewRow(
        bill: const FortuneBillVo(
          title: '午餐',
          amount: 28,
          currencyCode: 'CNY',
          billType: 1,
        ),
        currencyCode: 'CNY',
        hidden: false,
        onTap: () {},
      ),
    );
    expect(find.byType(FxLedgerRow), findsOneWidget);
  });
  testWidgets('order entries reuse the ledger component and keep actions', (
    tester,
  ) async {
    var previewed = false;
    var edited = false;
    await _pump(
      tester,
      OrderEntryTile(
        entry: FinanceOrderEntry(
          billId: 1,
          title: '归还本金',
          amount: OrderMoney.fromCents(10000),
          billType: 12,
          allowedActions: const ['EDIT'],
        ),
        hideAmounts: false,
        onPreview: (_) => previewed = true,
        onEdit: (_) => edited = true,
      ),
    );

    expect(find.byType(FxLedgerRow), findsOneWidget);
    expect(find.byTooltip('编辑流水'), findsOneWidget);
    await tester.tap(find.byTooltip('编辑流水'));
    expect(edited, isTrue);
    expect(previewed, isFalse);
  });
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double width = 430,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width, 800);
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
        body: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Align(alignment: Alignment.topCenter, child: child),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
