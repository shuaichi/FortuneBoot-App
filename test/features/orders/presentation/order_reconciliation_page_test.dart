import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/features/orders/presentation/order_reconciliation_page.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('retries a failed append without losing loaded rows', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final service = _FakeReconciliationService();
    await tester.pumpWidget(
      _wrap(OrderReconciliationPage(service: service, bookId: 7)),
    );
    await tester.pumpAndSettle();

    expect(find.text('单据 #101'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('reconciliation-load-more')));
    await tester.pumpAndSettle();

    expect(service.requestedPages, [1, 2]);
    expect(find.text('单据 #101'), findsOneWidget);
    expect(find.text(S.current.ordersLoadMoreFailed), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('reconciliation-load-more')));
    await tester.pumpAndSettle();

    expect(service.requestedPages, [1, 2, 2]);
    expect(find.text('单据 #101'), findsOneWidget);
    expect(find.text('单据 #102'), findsOneWidget);
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: FxTheme.light,
    locale: const Locale('zh'),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      S.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: child,
  );
}

class _FakeReconciliationService extends OrdersService {
  final requestedPages = <int>[];
  var _secondPageFailed = true;

  @override
  Future<FinanceOrderReconciliationPage> getReconciliation({
    required int bookId,
    int pageNum = 1,
    int pageSize = 20,
  }) async {
    requestedPages.add(pageNum);
    if (pageNum == 1) {
      return FinanceOrderReconciliationPage(rows: [_row(101)], total: 2);
    }
    if (_secondPageFailed) {
      _secondPageFailed = false;
      throw Exception('network error');
    }
    return FinanceOrderReconciliationPage(rows: [_row(102)], total: 2);
  }

  FinanceOrderReconciliation _row(int orderId) =>
      FinanceOrderReconciliation(orderId: orderId);
}
