import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/errors/fx_failure.dart';
import 'package:fortuneboot/features/bill_editor/data/editor_options_service.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_args.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_bloc.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_page.dart';
import 'package:fortuneboot/features/orders/data/finance_order_contract.dart';
import 'package:fortuneboot/features/orders/data/order_money.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  test('route parsing checks every order context value', () {
    final args = BillEditorArgs.fromRouteArgs({
      'mode': 'new',
      'billType': 10,
      'presetBookId': 20,
      'presetOrderId': 1001,
      'presetOrderComponent': 'PRINCIPAL',
      'expectedOrderVersion': 7,
      'lockOrderContext': true,
    });

    expect(args.presetBookId, 20);
    expect(args.presetOrderId, 1001);
    expect(args.presetOrderComponent, FinanceOrderComponent.principal);
    expect(args.expectedOrderVersion, 7);
    expect(args.lockOrderContext, isTrue);
    expect(args.lockBillType, isTrue);
  });

  test('option filtering maps each flow to one finance order type', () {
    int orderType(FxBillType type) =>
        EditorOptionsService.orderTypeForBillType(type)!.value;

    expect(orderType(FxBillType.advance), 1);
    expect(orderType(FxBillType.reimburse), 1);
    expect(orderType(FxBillType.loanOut), 2);
    expect(orderType(FxBillType.loanRecover), 2);
    expect(orderType(FxBillType.loanIn), 3);
    expect(orderType(FxBillType.loanRepay), 3);
    expect(
      EditorOptionsService.orderTypeForBillType(FxBillType.expense),
      isNull,
    );
  });

  test('submits principal flows as precise single-amount entries', () async {
    final cases = [
      (FxBillType.loanOut, '1000.00'),
      (FxBillType.loanRecover, '400.00'),
      (FxBillType.loanIn, '2000.00'),
      (FxBillType.loanRepay, '500.00'),
    ];

    for (final (type, amount) in cases) {
      final harness = _EditorHarness();
      addTearDown(harness.dispose);
      final state = await harness.initialize(
        BillEditorArgs(
          presetBillType: type.value,
          presetBookId: 20,
          presetOrderId: 1001,
          presetOrderComponent: FinanceOrderComponent.principal,
          expectedOrderVersion: 7,
          lockOrderContext: true,
          copyData: {'orderTitle': '张三借款'},
        ),
      );

      expect(state.showSingleAmount, isTrue);
      expect(state.showCategorySplit, isFalse);
      expect(state.showExtras, isFalse);
      harness.bloc.add(SingleAmountChanged(OrderMoney.parse(amount).cents));
      await Future<void>.delayed(Duration.zero);
      await harness.submit();

      final json = harness.lastEntryJson();
      expect(json['billType'], type.value);
      expect(json['orderComponent'], 'PRINCIPAL');
      expect(json['amount'], amount);
      expect(json['categoryAmountPair'], isEmpty);
      expect(json['include'], isFalse);
      expect(json.containsKey('ledgerVersion'), isFalse);
      expect(json.containsKey('toAccountId'), isFalse);
    }
  });

  test(
    'advance and reimburse still submit category splits as strings',
    () async {
      final harness = _EditorHarness();
      addTearDown(harness.dispose);
      final state = await harness.initialize(
        const BillEditorArgs(
          presetBillType: 7,
          presetBookId: 20,
          presetOrderId: 2001,
          expectedOrderVersion: 3,
          copyData: {'orderTitle': '报销单'},
        ),
      );
      final row = state.categoryRows.single;
      harness.bloc.add(CategoryRowCategoryChanged(row.rowId, 101, '垫付'));
      harness.bloc.add(OrderCategoryRowAmountChanged(row.rowId, 80000));
      harness.bloc.add(const AccountChanged(50, '现金'));
      await Future<void>.delayed(Duration.zero);
      await harness.submit();

      expect(harness.lastEntryJson()['categoryAmountPair'], [
        {'categoryId': 101, 'amount': '800.00'},
      ]);
      expect(harness.lastEntryJson()['include'], isFalse);

      final reimburseHarness = _EditorHarness();
      addTearDown(reimburseHarness.dispose);
      final reimburse = await reimburseHarness.initialize(
        const BillEditorArgs(
          presetBillType: 8,
          presetBookId: 20,
          presetOrderId: 2001,
          expectedOrderVersion: 3,
          copyData: {'orderTitle': '报销单'},
        ),
      );
      expect(reimburse.showCategorySplit, isTrue);
      expect(reimburse.usesIncomeAssociations, isTrue);
    },
  );

  test(
    'WRITE_OFF hides accounts, fixes confirm and requires a reason',
    () async {
      final harness = _EditorHarness();
      addTearDown(harness.dispose);
      final state = await harness.initialize(
        const BillEditorArgs(
          presetBillType: 1,
          presetBookId: 20,
          presetOrderId: 1001,
          presetOrderComponent: FinanceOrderComponent.writeOff,
          expectedOrderVersion: 7,
          lockOrderContext: true,
          copyData: {'orderTitle': '张三借款'},
        ),
      );

      expect(state.showAccount, isFalse);
      expect(state.showExtras, isFalse);
      expect(state.confirmLocked, isTrue);
      expect(state.confirm, isTrue);
      expect(state.validationError, BillValidationError.writeOffReasonRequired);

      harness.bloc.add(const RemarkChanged('确认无法收回'));
      final row = harness.bloc.state.categoryRows.single;
      harness.bloc.add(CategoryRowCategoryChanged(row.rowId, 101, '损失'));
      harness.bloc.add(OrderCategoryRowAmountChanged(row.rowId, 20000));
      await Future<void>.delayed(Duration.zero);
      await harness.submit();

      final json = harness.lastEntryJson();
      expect(json['orderComponent'], 'WRITE_OFF');
      expect(json['confirm'], isTrue);
      expect(json['remark'], '确认无法收回');
      expect(json.containsKey('accountId'), isFalse);
      expect(json.containsKey('toAccountId'), isFalse);
      expect(json['categoryAmountPair'], [
        {'categoryId': 101, 'amount': '200.00'},
      ]);
    },
  );

  test(
    'normal one, two and three forms do not use the V2 entry service',
    () async {
      for (final type in [
        FxBillType.expense,
        FxBillType.income,
        FxBillType.transfer,
      ]) {
        final harness = _EditorHarness();
        addTearDown(harness.dispose);
        final state = await harness.initialize(
          BillEditorArgs(presetBillType: type.value),
        );
        expect(state.isOrderFlow, isFalse);
        expect(state.showOrder, isFalse);
        expect(harness.ordersServiceUsed, isFalse);
      }
    },
  );

  test(
    'retries the same content with one UUID and changes it for new content',
    () async {
      final harness = _EditorHarness();
      addTearDown(harness.dispose);
      await harness.initialize(_principalArgs());
      harness.bloc.add(const SingleAmountChanged(100000));
      await Future<void>.delayed(Duration.zero);

      harness.enqueueError();
      await harness.submit();
      expect(harness.bloc.state.submitStatus, SubmitStatus.failure);
      expect(harness.bloc.state.singleAmountCents, 100000);

      harness.enqueueSuccess();
      await harness.submit();
      final first = harness.lastEntryJson()['requestId'];

      harness.bloc.add(const SingleAmountChanged(40000));
      await Future<void>.delayed(Duration.zero);
      harness.enqueueSuccess();
      await harness.submit();
      final second = harness.lastEntryJson()['requestId'];

      expect(first, 'request-1');
      expect(second, 'request-2');
      expect(harness.lastEntryJson()['amount'], '400.00');
    },
  );

  test('version conflict preserves input and refreshes order detail', () async {
    final harness = _EditorHarness();
    addTearDown(harness.dispose);
    final ready = await harness.initialize(_principalArgs());
    harness.bloc.add(const SingleAmountChanged(100000));
    await Future<void>.delayed(Duration.zero);

    harness.enqueueError(code: 30011);
    harness.enqueueDetail(version: 8);
    await harness.submit();

    expect(harness.bloc.state.submitStatus, SubmitStatus.failure);
    expect(harness.bloc.state.singleAmountCents, 100000);
    expect(harness.bloc.state.expectedOrderVersion, 8);
    expect(ready.orderId, 1001);
    expect(harness.bloc.state.orderId, 1001);
  });

  test('unknown bill types cannot fall back to expense editing', () async {
    final harness = _EditorHarness();
    addTearDown(harness.dispose);
    final state = await harness.initialize(
      const BillEditorArgs(
        mode: 'edit',
        sourceBill: FortuneBillVo(billType: 99),
      ),
    );

    expect(state.status, EditorStatus.error);
    expect(state.loadFailure?.kind, FxFailureKind.invalidResponse);
  });

  test('editing an order entry preserves its attachments', () async {
    final source = FortuneBillVo(
      billId: 9001,
      bookId: 20,
      orderId: 1001,
      billType: 10,
      orderComponent: FinanceOrderComponent.principal,
      amountMoney: OrderMoney.fromCents(40000),
      hasFile: true,
    );
    final harness = _EditorHarness();
    addTearDown(harness.dispose);
    final state = await harness.initialize(
      BillEditorArgs(
        mode: 'edit',
        sourceBill: source,
        presetBookId: 20,
        presetOrderId: 1001,
        expectedOrderVersion: 7,
        lockOrderContext: true,
      ),
    );

    expect(state.billId, 9001);
    expect(state.attachments.single.id, 'existing-attachment');
    expect(state.singleAmountCents, 40000);
  });

  test('copying an order entry clears the source bill identity', () async {
    final harness = _EditorHarness();
    addTearDown(harness.dispose);
    final state = await harness.initialize(
      BillEditorArgs(
        mode: 'copy',
        sourceBill: FortuneBillVo(
          billId: 9001,
          bookId: 20,
          orderId: 1001,
          billType: 10,
          orderComponent: FinanceOrderComponent.principal,
          amountMoney: OrderMoney.fromCents(40000),
        ),
        presetBookId: 20,
        presetOrderId: 1001,
        expectedOrderVersion: 7,
      ),
    );

    expect(state.billId, isNull);
    expect(state.orderId, 1001);
    await harness.submit();

    expect(harness.adapter.requests.last.method, 'POST');
    expect(harness.lastEntryJson()['requestId'], isNotEmpty);
  });

  testWidgets('category total uses a currency symbol instead of CNY', (
    tester,
  ) async {
    final harness = _EditorHarness();
    final state = await harness.initialize(
      const BillEditorArgs(presetBillType: 1, presetBookId: 20),
    );
    harness.bloc.add(const AccountChanged(50, '现金'));
    harness.bloc.add(
      CategoryRowAmountChanged(state.categoryRows.single.rowId, 123.45),
    );
    await tester.pump();
    expect(harness.bloc.state.accountId, 50);
    expect(harness.bloc.state.categoryTotal, 123.45);
    await tester.pumpWidget(_editorWidget(harness.bloc));

    expect(find.text('¥123.45'), findsOneWidget);
    expect(find.text('CNY 123.45'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('core editor fields share one continuous grouped form', (
    tester,
  ) async {
    final harness = _EditorHarness();
    await harness.initialize(
      const BillEditorArgs(presetBillType: 1, presetBookId: 20),
    );
    await tester.pumpWidget(_editorWidget(harness.bloc));

    final core = find.byKey(const ValueKey('bill-editor-core-section'));
    expect(core, findsOneWidget);
    expect(
      find.descendant(of: core, matching: find.text('备注')),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Widget _editorWidget(BillEditorBloc bloc) {
  return BlocProvider.value(
    value: bloc,
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
      home: const BillEditorPage(),
    ),
  );
}

BillEditorArgs _principalArgs() => const BillEditorArgs(
  presetBillType: 10,
  presetBookId: 20,
  presetOrderId: 1001,
  presetOrderComponent: FinanceOrderComponent.principal,
  expectedOrderVersion: 7,
  lockOrderContext: true,
  copyData: {'orderTitle': '张三借款'},
);

class _EditorHarness {
  _EditorHarness() {
    adapter = _QueueAdapter();
    dio = Dio(BaseOptions(baseUrl: 'http://test'))..httpClientAdapter = adapter;
    ordersService = _CountingOrdersService(dio: dio);
    bloc = BillEditorBloc(
      bookId: 20,
      groupId: 30,
      optionsService: _FakeOptionsService(),
      billService: _FakeBillService(),
      ordersService: ordersService,
      requestIdFactory: () => 'request-${++_requestSequence}',
    );
  }

  late final _QueueAdapter adapter;
  late final Dio dio;
  late final _CountingOrdersService ordersService;
  late final BillEditorBloc bloc;
  var _requestSequence = 0;

  bool get ordersServiceUsed => ordersService.used;

  Future<BillEditorState> initialize(BillEditorArgs args) {
    final ready = bloc.stream.firstWhere(
      (state) =>
          state.status == EditorStatus.ready ||
          state.status == EditorStatus.error,
    );
    bloc.add(BillEditorInitialized(args));
    return ready;
  }

  Future<void> submit() async {
    final done = bloc.stream.firstWhere(
      (state) =>
          state.submitStatus == SubmitStatus.success ||
          state.submitStatus == SubmitStatus.failure,
    );
    bloc.add(const BillEditorSubmitted());
    await done;
  }

  void enqueueSuccess() => adapter.enqueue(const {
    'orderId': 1001,
    'billId': 9001,
    'version': 8,
    'replayed': false,
  });

  void enqueueError({int code = 500}) => adapter.enqueue({
    'code': code,
    'msg': 'error',
    'data': null,
  }, wrapped: false);

  void enqueueDetail({required int version}) => adapter.enqueue({
    'orderId': 1001,
    'bookId': 20,
    'type': 2,
    'version': version,
    'title': '张三借款',
  });

  Map<String, dynamic> lastEntryJson() {
    final request = adapter.requests.lastWhere(
      (request) => request.data is FormData,
    );
    final index = adapter.requests.indexOf(request);
    final body = adapter.bodies[index];
    final nameIndex = body.indexOf('name="data"');
    final start = body.indexOf('{', nameIndex);
    final end = body.indexOf('\r\n--', start);
    return jsonDecode(body.substring(start, end)) as Map<String, dynamic>;
  }

  Future<void> dispose() => bloc.close();
}

class _CountingOrdersService extends OrdersService {
  _CountingOrdersService({required super.dio});

  bool used = false;

  @override
  Future<FinanceOrderMutationResult> createEntry({
    required int bookId,
    required int orderId,
    required FinanceOrderEntryCommandInput command,
    List<BillAttachment> attachments = const [],
  }) {
    used = true;
    return super.createEntry(
      bookId: bookId,
      orderId: orderId,
      command: command,
      attachments: attachments,
    );
  }
}

class _QueueAdapter implements HttpClientAdapter {
  final List<dynamic> _responses = [];
  final List<RequestOptions> requests = [];
  final List<String> bodies = [];

  void enqueue(dynamic data, {bool wrapped = true}) =>
      _responses.add(wrapped ? {'code': 0, 'msg': 'ok', 'data': data} : data);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final builder = BytesBuilder();
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        builder.add(chunk);
      }
    }
    final requestBody = utf8.decode(builder.takeBytes());
    bodies.add(requestBody);
    final data = _responses.isEmpty ? null : _responses.removeAt(0);
    return ResponseBody.fromString(
      jsonEncode(data ?? {'code': 0, 'msg': 'ok', 'data': null}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeOptionsService extends EditorOptionsService {
  @override
  Future<EditorOptions> loadAll({
    required int bookId,
    required int groupId,
    FxBillType? billType,
    int pageNum = 1,
    int pageSize = 20,
    int? presetOrderId,
    String? presetOrderTitle,
  }) async {
    return const EditorOptions(
      accounts: [
        AccountOption(
          accountId: 50,
          accountName: '现金',
          canExpense: true,
          currencyCode: 'CNY',
        ),
        AccountOption(accountId: 51, accountName: '收入账户', canIncome: true),
      ],
      expenseCategories: [CategoryNode(categoryId: 101, categoryName: '垫付')],
      incomeCategories: [CategoryNode(categoryId: 201, categoryName: '报销')],
      orders: [
        OrderOption(orderId: 1001, title: '张三借款', type: 2),
        OrderOption(orderId: 2001, title: '报销单', type: 1),
      ],
    );
  }
}

class _FakeBillService extends BillService {
  @override
  Future<List<BillAttachment>> getAttachments(int billId) async => [
    BytesBillAttachment(
      id: 'existing-attachment',
      name: 'receipt.txt',
      bytes: Uint8List.fromList([104, 105]),
    ),
  ];
}
