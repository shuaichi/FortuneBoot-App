import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/orders/data/finance_order_contract.dart';
import 'package:fortuneboot/features/orders/data/order_money.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';

void main() {
  late _StubAdapter adapter;
  late Dio dio;
  late OrdersService service;

  setUp(() {
    adapter = _StubAdapter();
    dio = Dio(BaseOptions(baseUrl: 'http://test'))..httpClientAdapter = adapter;
    service = OrdersService(dio: dio);
  });

  test('queries all V2 read endpoints with explicit parameters', () async {
    adapter.enqueuePage('rows', const []);
    await service.getPage(
      bookId: 20,
      pageNum: 3,
      pageSize: 50,
      type: 2,
      status: 200,
      settlementState: 'PARTIAL',
      keyword: '张三',
      overdueOnly: true,
    );
    expect(adapter.last.uri.path, '/fortune/finance/order/v2/page');
    expect(adapter.last.queryParameters['bookId'], 20);
    expect(adapter.last.queryParameters['pageNum'], 3);
    expect(adapter.last.queryParameters['pageSize'], 50);
    expect(adapter.last.queryParameters['type'], 2);
    expect(adapter.last.queryParameters['status'], 200);
    expect(adapter.last.queryParameters['settlementState'], 'PARTIAL');
    expect(adapter.last.queryParameters['keyword'], '张三');
    expect(adapter.last.queryParameters['overdueOnly'], true);

    adapter.enqueue(const {'orderId': 1, 'version': 0});
    await service.getDetail(bookId: 20, orderId: 1);
    expect(adapter.last.uri.path, '/fortune/finance/order/v2/20/1');

    adapter.enqueue(const {'currencyCode': 'CNY'});
    await service.getSummary(bookId: 20);
    expect(adapter.last.uri.path, '/fortune/finance/order/v2/20/summary');

    adapter.enqueuePage('rows', const []);
    await service.getOptions(
      bookId: 20,
      billType: 9,
      keyword: '张三',
      pageNum: 2,
      pageSize: 10,
    );
    expect(adapter.last.uri.path, '/fortune/finance/order/v2/20/options');
    expect(adapter.last.queryParameters['billType'], 9);
    expect(adapter.last.queryParameters['pageNum'], 2);

    adapter.enqueuePage('rows', const []);
    await service.getEntries(bookId: 20, orderId: 1, entryStatus: 'ALL');
    expect(
      adapter.last.uri.path,
      '/fortune/finance/order/v2/20/1/entries',
    );
    expect(adapter.last.queryParameters['entryStatus'], 'ALL');

    adapter.enqueuePage('rows', const []);
    await service.getAudit(bookId: 20, orderId: 1);
    expect(adapter.last.uri.path, '/fortune/finance/order/v2/20/1/audit');

    adapter.enqueuePage('rows', const []);
    await service.getReconciliation(bookId: 20);
    expect(
      adapter.last.uri.path,
      '/fortune/finance/order/v2/20/reconciliation',
    );
  });

  test('sends create, modify and lifecycle commands as JSON', () async {
    adapter.enqueue(const {'orderId': 1, 'version': 0});
    await service.create(
      const FinanceOrderCreateInput(
        bookId: 20,
        requestId: 'create-id',
        title: '张三借款',
        type: FinanceOrderType.receivable,
        counterpartyName: '张三',
      ),
    );
    expect(adapter.last.method, 'POST');
    expect(adapter.last.uri.path, '/fortune/finance/order/v2/create');
    expect(adapter.last.data, {
      'bookId': 20,
      'requestId': 'create-id',
      'title': '张三借款',
      'type': 2,
      'counterpartyName': '张三',
      'remark': '',
    });

    adapter.enqueue(const {'orderId': 1, 'version': 1});
    await service.modify(
      const FinanceOrderMetadataInput(
        bookId: 20,
        orderId: 1,
        requestId: 'modify-id',
        expectedVersion: 0,
        title: '张三借款',
        type: FinanceOrderType.receivable,
        counterpartyName: '张三',
      ),
    );
    expect(adapter.last.method, 'PUT');
    expect(adapter.last.uri.path, '/fortune/finance/order/v2/modify');
    expect((adapter.last.data as Map<String, dynamic>)['expectedVersion'], 0);

    adapter.enqueue(const {'orderId': 1, 'version': 2});
    await service.transition(
      bookId: 20,
      orderId: 1,
      action: FinanceOrderTransitionAction.close,
      requestId: 'close-id',
      expectedVersion: 1,
    );
    expect(adapter.last.method, 'POST');
    expect(adapter.last.uri.path, '/fortune/finance/order/v2/20/1/close');
    expect(adapter.last.data, {
      'bookId': 20,
      'orderId': 1,
      'requestId': 'close-id',
      'expectedVersion': 1,
    });
  });

  test('sends V2 multipart entry JSON and files to the exact endpoint', () async {
    final command = FinanceOrderEntryCommandInput(
      bookId: 20,
      orderId: 1,
      requestId: 'entry-id',
      expectedVersion: 7,
      orderComponent: FinanceOrderComponent.principal,
      title: '收回本金',
      tradeTime: DateTime(2026, 10, 2, 10, 30, 5),
      billType: FxBillType.loanRecover,
      confirm: true,
      include: false,
      amount: OrderMoney.fromCents(40000),
      accountId: 50,
    );
    final attachment = BytesBillAttachment(
      id: 'attachment-1',
      name: 'receipt.txt',
      bytes: Uint8List.fromList([104, 105]),
    );

    adapter.enqueue(const {'orderId': 1, 'billId': 9001, 'version': 8});
    final result = await service.createEntry(
      bookId: 20,
      orderId: 1,
      command: command,
      attachments: [attachment],
    );

    expect(result.billId, 9001);
    expect(adapter.last.method, 'POST');
    expect(
      adapter.last.uri.path,
      '/fortune/finance/order/v2/20/1/entries',
    );
    final form = adapter.last.data as FormData;
    final json = adapter.lastEntryJson();
    expect(json['bookId'], 20);
    expect(json['orderId'], 1);
    expect(json['billType'], 10);
    expect(json['orderComponent'], 'PRINCIPAL');
    expect(json['amount'], '400.00');
    expect(json['categoryAmountPair'], isEmpty);
    expect(json['requestId'], 'entry-id');
    expect(json['expectedVersion'], 7);
    expect(json['tradeTime'], '2026-10-02 10:30:05');
    expect(json.containsKey('ledgerVersion'), isFalse);
    expect(json.containsKey('pendingAmount'), isFalse);
    expect(form.files.map((entry) => entry.key), ['data', 'files']);

    final modified = command.copyWith(
      requestId: 'modify-entry-id',
      expectedVersion: 8,
      amount: OrderMoney.fromCents(30000),
    );
    adapter.enqueue(const {'orderId': 1, 'billId': 9001, 'version': 9});
    await service.modifyEntry(
      bookId: 20,
      orderId: 1,
      billId: 9001,
      command: modified,
    );
    expect(adapter.last.method, 'PUT');
    expect(
      adapter.last.uri.path,
      '/fortune/finance/order/v2/20/1/entries/9001',
    );
    final modifyForm = adapter.last.data as FormData;
    final modifyJson = adapter.lastEntryJson();
    expect(modifyJson['billId'], 9001);
    expect(modifyJson['amount'], '300.00');
    expect(modifyForm.files.map((entry) => entry.key), ['data']);
  });

  test('sends entry action JSON with path IDs and expected version', () async {
    adapter.enqueue(const {'orderId': 1, 'billId': 9001, 'version': 9});
    await service.entryAction(
      bookId: 20,
      orderId: 1,
      billId: 9001,
      action: FinanceOrderEntryAction.voidEntry,
      requestId: 'void-id',
      expectedVersion: 8,
    );

    expect(adapter.last.method, 'POST');
    expect(
      adapter.last.uri.path,
      '/fortune/finance/order/v2/20/1/entries/9001/void',
    );
    expect(adapter.last.data, {
      'bookId': 20,
      'orderId': 1,
      'billId': 9001,
      'requestId': 'void-id',
      'expectedVersion': 8,
    });
  });
}

class _StubAdapter implements HttpClientAdapter {
  final List<dynamic> _responses = [];
  final List<RequestOptions> requests = [];
  final List<String> bodies = [];

  void enqueue(dynamic data) => _responses.add(data);

  void enqueuePage(String rowsKey, List<Map<String, dynamic>> rows) =>
      _responses.add({'total': rows.length, rowsKey: rows});

  RequestOptions get last => requests.last;

  Map<String, dynamic> lastEntryJson() {
    final body = bodies.last;
    final nameIndex = body.indexOf('name="data"');
    final start = body.indexOf('{', nameIndex);
    final end = body.indexOf('\r\n--', start);
    return jsonDecode(body.substring(start, end)) as Map<String, dynamic>;
  }

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
    final body = utf8.decode(builder.takeBytes());
    bodies.add(body);
    final data = _responses.isEmpty
        ? const <String, dynamic>{}
        : _responses.removeAt(0);
    final responseBody = jsonEncode({'code': 0, 'msg': 'ok', 'data': data});
    return ResponseBody.fromString(
      responseBody,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
