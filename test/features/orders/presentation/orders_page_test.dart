import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/preferences/dashboard_display_preferences.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/orders/data/order_money.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart'
    hide OrdersPage;
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/features/orders/orders_registration.dart';
import 'package:fortuneboot/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:fortuneboot/features/orders/presentation/orders_page.dart';
import 'package:fortuneboot/features/orders/presentation/widgets/order_card.dart';
import 'package:fortuneboot/features/orders/presentation/widgets/order_summary_strip.dart';
import 'package:fortuneboot/fx/components/fx_chip.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('renders C10 list, summary, and opens detail from card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = _FakeOrdersService();
    final session = _TestSessionCubit(roleType: 2);
    final preferences = _TestPreferencesCubit(hideAmounts: false);
    addTearDown(session.close);
    addTearDown(preferences.close);

    await _pumpPage(
      tester,
      service: service,
      session: session,
      preferences: preferences,
    );
    await tester.pumpAndSettle();

    expect(find.byType(OrderSummaryStrip), findsOneWidget);
    expect(find.byType(OrderCard), findsNWidgets(8));
    expect(find.text('张三'), findsOneWidget);
    expect(find.textContaining('600.00'), findsWidgets);

    await tester.tap(find.text('张三'));
    await tester.pumpAndSettle();

    expect(service.detailRequests, [11]);
  });

  testWidgets('visitor has no add or action controls', (tester) async {
    final service = _FakeOrdersService();
    final session = _TestSessionCubit(roleType: 3);
    final preferences = _TestPreferencesCubit(hideAmounts: false);
    addTearDown(session.close);
    addTearDown(preferences.close);

    await _pumpPage(
      tester,
      service: service,
      session: session,
      preferences: preferences,
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip(S.current.ordersAddTitle), findsNothing);
    expect(find.text(S.current.ordersArchive), findsNothing);
  });

  testWidgets('hidden amounts are also hidden from semantics', (tester) async {
    final service = _FakeOrdersService();
    final session = _TestSessionCubit(roleType: 2);
    final preferences = _TestPreferencesCubit(hideAmounts: true);
    addTearDown(session.close);
    addTearDown(preferences.close);

    await _pumpPage(
      tester,
      service: service,
      session: session,
      preferences: preferences,
    );
    await tester.pumpAndSettle();

    expect(find.text('600.00'), findsNothing);
    expect(find.textContaining('1,000.00'), findsNothing);
    expect(find.bySemanticsLabel(RegExp(r'600\.00')), findsNothing);
    expect(
      tester
          .widgetList<FxMoneyText>(find.byType(FxMoneyText))
          .every((widget) => widget.masked),
      isTrue,
    );
  });

  testWidgets('320px width renders without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final service = _FakeOrdersService();
    final session = _TestSessionCubit(roleType: 2);
    final preferences = _TestPreferencesCubit(hideAmounts: false);
    addTearDown(session.close);
    addTearDown(preferences.close);

    await _pumpPage(
      tester,
      service: service,
      session: session,
      preferences: preferences,
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
  testWidgets('keeps secondary filters collapsed and applies them from sheet', (
    tester,
  ) async {
    final service = _FakeOrdersService();
    final session = _TestSessionCubit(roleType: 2);
    final preferences = _TestPreferencesCubit(hideAmounts: false);
    addTearDown(session.close);
    addTearDown(preferences.close);
    await _pumpPage(
      tester,
      service: service,
      session: session,
      preferences: preferences,
    );
    await tester.pumpAndSettle();

    expect(find.byType(FxSegmented<FinanceOrderType>), findsOneWidget);
    expect(find.byType(FxSegmented<int>), findsNothing);
    expect(find.text(S.current.ordersOverdueOnly), findsNothing);

    await tester.tap(find.byKey(const ValueKey('orders-filter')));
    await tester.pumpAndSettle();
    expect(find.byType(FxSegmented<int>), findsOneWidget);
    await tester.tap(find.text(S.current.ordersStatusDraft));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final bloc = tester.element(find.byType(OrdersPage)).read<OrdersBloc>();
    expect(bloc.state.statusFilter, FinanceOrderStatus.draft.value);
    expect(bloc.state.overdueOnly, isTrue);
    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();
    expect(find.byType(FxSegmented<int>), findsNothing);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets(
    'uses readable order metadata without inert chips or raw decimals',
    (tester) async {
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
            body: OrderCard(
              order: FinanceOrderDetail(
                orderId: 1,
                type: FinanceOrderType.receivable,
                issuedAmount: OrderMoney.fromCents(1000000),
                settledAmount: OrderMoney.fromCents(0),
                pendingAmount: OrderMoney.fromCents(1000000),
                overdue: true,
              ),
              currencyCode: 'CNY',
              hideAmounts: false,
            ),
          ),
        ),
      );

      expect(find.text('未填写'), findsNothing);
      expect(find.textContaining('10000.00'), findsNothing);
      expect(find.textContaining('10,000.00'), findsWidgets);
      expect(find.text('累计借出 ¥10,000.00 · 已收回 ¥0.00'), findsOneWidget);
      expect(find.byType(FxChip), findsNothing);
    },
  );
  testWidgets('hides amounts in textual order metadata', (tester) async {
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
          body: OrderCard(
            order: FinanceOrderDetail(
              type: FinanceOrderType.receivable,
              issuedAmount: OrderMoney.fromCents(1000000),
              settledAmount: OrderMoney.fromCents(0),
              pendingAmount: OrderMoney.fromCents(1000000),
            ),
            currencyCode: 'CNY',
            hideAmounts: true,
          ),
        ),
      ),
    );

    expect(find.textContaining('10,000.00'), findsNothing);
    expect(find.text('累计借出 •••• · 已收回 ••••'), findsOneWidget);
  });
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required _FakeOrdersService service,
  required _TestSessionCubit session,
  required _TestPreferencesCubit preferences,
}) {
  registerOrdersFeature();
  return tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<SessionCubit>.value(value: session),
        BlocProvider<PreferencesCubit>.value(value: preferences),
      ],
      child: MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        theme: FxTheme.light,
        locale: const Locale('zh'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: BlocProvider<OrdersBloc>(
          create: (_) =>
              OrdersBloc(bookId: 7, service: service)
                ..add(const OrdersLoaded()),
          child: OrdersPage(service: service),
        ),
      ),
    ),
  );
}

class _TestSessionCubit extends SessionCubit {
  _TestSessionCubit({required int roleType}) : super() {
    emit(
      SessionState(
        status: SessionStatus.ready,
        currentGroup: FortuneGroupVo(groupId: 1, roleType: roleType),
        currentBook: _book,
      ),
    );
  }

  static const _book = FortuneBookVo(bookId: 7, defaultCurrency: 'CNY');
}

class _TestPreferencesCubit extends PreferencesCubit {
  _TestPreferencesCubit({required bool hideAmounts}) : super() {
    emit(
      state.copyWith(
        dashboard: DashboardDisplayPreferences(hideAmounts: hideAmounts),
      ),
    );
  }
}

class _FakeOrdersService extends OrdersService {
  final detailRequests = <int>[];

  @override
  Future<FinanceOrderPage> getPage({
    required int bookId,
    int pageNum = 1,
    int pageSize = 20,
    int? type,
    int? status,
    String? settlementState,
    String? keyword,
    String? title,
    bool overdueOnly = false,
  }) async {
    return FinanceOrderPage(rows: _orders, total: _orders.length);
  }

  @override
  Future<FinanceOrderSummary> getSummary({required int bookId}) async =>
      FinanceOrderSummary(
        receivableAmount: OrderMoney.fromCents(60000),
        payableAmount: OrderMoney.fromCents(20000),
        reimbursementAmount: OrderMoney.fromCents(10000),
      );

  @override
  Future<FinanceOrderDetail> getDetail({
    required int bookId,
    required int orderId,
  }) async {
    detailRequests.add(orderId);
    return _orders.firstWhere((order) => order.orderId == orderId);
  }

  static final List<FinanceOrderDetail> _orders = [
    FinanceOrderDetail(
      orderId: 11,
      bookId: 7,
      title: '张三借款',
      counterpartyName: '张三',
      type: FinanceOrderType.receivable,
      status: 200,
      issuedAmount: OrderMoney.fromCents(100000),
      settledAmount: OrderMoney.fromCents(40000),
      pendingAmount: OrderMoney.fromCents(60000),
    ),
    FinanceOrderDetail(
      orderId: 12,
      bookId: 7,
      title: '李四借款',
      counterpartyName: '李四',
      type: FinanceOrderType.payable,
      status: 200,
      pendingAmount: OrderMoney.fromCents(20000),
    ),
    FinanceOrderDetail(
      orderId: 13,
      bookId: 7,
      title: '差旅报销',
      counterpartyName: '公司',
      type: FinanceOrderType.reimbursement,
      status: 200,
      pendingAmount: OrderMoney.fromCents(10000),
    ),
    FinanceOrderDetail(
      orderId: 14,
      bookId: 7,
      title: '已结清未归档',
      counterpartyName: '王五',
      type: FinanceOrderType.receivable,
      status: 200,
      issuedAmount: OrderMoney.fromCents(100000),
      settledAmount: OrderMoney.fromCents(100000),
      pendingAmount: OrderMoney.fromCents(0),
    ),
    FinanceOrderDetail(
      orderId: 15,
      bookId: 7,
      title: '已归档',
      counterpartyName: '赵六',
      type: FinanceOrderType.payable,
      status: 1000,
      pendingAmount: OrderMoney.fromCents(0),
    ),
    FinanceOrderDetail(
      orderId: 16,
      bookId: 7,
      title: '待确认',
      counterpartyName: '钱七',
      type: FinanceOrderType.reimbursement,
      status: 200,
      pendingAmount: OrderMoney.fromCents(80000),
      pendingEntryCount: 1,
    ),
    FinanceOrderDetail(
      orderId: 17,
      bookId: 7,
      title: '逾期',
      counterpartyName: '孙八',
      type: FinanceOrderType.receivable,
      status: 200,
      pendingAmount: OrderMoney.fromCents(50000),
      overdue: true,
    ),
    const FinanceOrderDetail(
      orderId: 18,
      bookId: 7,
      title: '待核对',
      counterpartyName: '周九',
      type: FinanceOrderType.payable,
      status: 200,
      reconciliationStatus: 'REVIEW_REQUIRED',
    ),
  ];
}
