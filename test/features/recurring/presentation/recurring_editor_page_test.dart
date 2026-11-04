import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/recurring/data/recurring_models.dart';
import 'package:fortuneboot/features/recurring/presentation/recurring_editor_page.dart';
import 'package:fortuneboot/features/recurring/presentation/widgets/cron_schedule_editor.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/util/dio_client.dart';

void main() {
  testWidgets('an unsupported legacy schedule becomes a visual daily rule', (
    tester,
  ) async {
    final dio = DioClient().dio;
    final previousAdapter = dio.httpClientAdapter;
    dio.httpClientAdapter = _RecurringAdapter();
    addTearDown(() => dio.httpClientAdapter = previousAdapter);

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
        home: const RecurringEditorPage(
          bookId: 1,
          groupId: 2,
          rule: RecurringRuleVo(
            ruleId: 3,
            ruleName: '旧规则',
            cronExpression: '0 0/5 * * * ?',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CronScheduleEditor), findsOneWidget);
    expect(find.text('每天 09:00'), findsOneWidget);
    expect(find.text('切换到自定义 cron'), findsNothing);
    expect(find.text('0 0/5 * * * ?'), findsNothing);
    expect(find.text('原调度无法通过可视化选项展示，已切换为每天 09:00，请确认后保存。'), findsOneWidget);
  });

  testWidgets('converted legacy schedule validates and saves the visual rule', (
    tester,
  ) async {
    final dio = DioClient().dio;
    final previousAdapter = dio.httpClientAdapter;
    final adapter = _RecurringAdapter();
    dio.httpClientAdapter = adapter;
    addTearDown(() => dio.httpClientAdapter = previousAdapter);

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
        home: const RecurringEditorPage(
          bookId: 1,
          groupId: 2,
          rule: RecurringRuleVo(
            ruleId: 3,
            ruleName: '旧规则',
            cronExpression: '0 0/5 * * * ?',
            billRequest: {
              'billType': 1,
              'title': '午餐',
              'accountId': 50,
              'tagIdList': [9],
              'categoryAmountPair': [
                {'categoryId': 101, 'amount': 12.0},
              ],
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('保存修改'));
    await tester.tap(find.text('保存修改'));
    await tester.pumpAndSettle();

    final validationIndex = adapter.requests.indexWhere(
      (request) => request.path.endsWith('/checkCronExpression'),
    );
    final modifyIndex = adapter.requests.indexWhere(
      (request) => request.path.endsWith('/modifyRule'),
    );
    expect(validationIndex, greaterThanOrEqualTo(0));
    expect(modifyIndex, greaterThan(validationIndex));
    expect(
      adapter.requests[validationIndex].queryParameters['cronExpression'],
      '0 0 9 * * ?',
    );

    final body = jsonDecode(adapter.bodies[modifyIndex]);
    expect(body['ruleId'], 3);
    expect(body['cronExpression'], '0 0 9 * * ?');
    expect(body['billRequest']['accountId'], 50);
    expect(body['billRequest']['tagIdList'], [9]);
    expect(body['billRequest']['categoryAmountPair'], [
      {'categoryId': 101, 'amount': 12.0},
    ]);
  });
}

class _RecurringAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  final bodies = <String>[];

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
    bodies.add(utf8.decode(builder.takeBytes()));
    final data = options.path.endsWith('/checkCronExpression')
        ? true
        : options.path.endsWith('/modifyRule')
        ? null
        : <dynamic>[];
    return ResponseBody.fromString(
      jsonEncode({'code': 0, 'msg': 'ok', 'data': data}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
