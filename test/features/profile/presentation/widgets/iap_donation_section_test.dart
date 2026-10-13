import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/profile/data/donation_models.dart';
import 'package:fortuneboot/features/profile/presentation/widgets/iap_donation_section.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

class _FakeDonationApi implements DonationApi {
  _FakeDonationApi({this.products = const [], this.failPurchase = false});

  final List<DonationProduct> products;
  final bool failPurchase;
  final StreamController<DonationPurchaseEvent> _events =
      StreamController<DonationPurchaseEvent>.broadcast();
  final List<String> purchasedIds = [];
  Completer<bool>? purchaseCompleter;

  @override
  Future<List<DonationProduct>> loadProducts() async => products;

  @override
  Future<bool> startPurchase(DonationProduct product) {
    purchasedIds.add(product.id);
    if (failPurchase) return Future.value(false);
    purchaseCompleter = Completer<bool>();
    return purchaseCompleter!.future;
  }

  @override
  Stream<DonationPurchaseEvent> get purchaseStream => _events.stream;

  void emitSuccess(String productId) {
    _events.add(DonationPurchaseSucceeded(productId));
  }

  @override
  void dispose() {
    _events.close();
  }
}

Widget _testApp({required DonationApi api}) {
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
    home: Scaffold(
      body: Center(child: IapDonationSection(api: api)),
    ),
  );
}

void main() {
  test('uses stable App Store product identifiers', () {
    expect(appleDonationProductIds, const [
      'fortuneboot_donation_small',
      'fortuneboot_donation_medium',
      'fortuneboot_donation_large',
    ]);
  });

  testWidgets('renders In-App Purchase options without external payment QRs', (
    tester,
  ) async {
    final api = _FakeDonationApi(
      products: const [
        DonationProduct(
          id: 'fortuneboot_donation_small',
          title: '小额支持',
          price: '¥6',
        ),
        DonationProduct(
          id: 'fortuneboot_donation_medium',
          title: '中额支持',
          price: '¥18',
        ),
        DonationProduct(
          id: 'fortuneboot_donation_large',
          title: '大额支持',
          price: '¥68',
        ),
      ],
    );

    await tester.pumpWidget(_testApp(api: api));
    await tester.pumpAndSettle();

    expect(find.text('小额支持'), findsOneWidget);
    expect(find.text('¥6'), findsOneWidget);
    expect(find.text('中额支持'), findsOneWidget);
    expect(find.text('大额支持'), findsOneWidget);
    expect(find.text('微信'), findsNothing);
    expect(find.text('支付宝'), findsNothing);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('starts a purchase and shows success after StoreKit completes', (
    tester,
  ) async {
    final api = _FakeDonationApi(
      products: const [
        DonationProduct(
          id: 'fortuneboot_donation_small',
          title: '小额支持',
          price: '¥6',
        ),
      ],
    );

    await tester.pumpWidget(_testApp(api: api));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('donation-fortuneboot_donation_small')),
    );
    await tester.pump();

    expect(api.purchasedIds, ['fortuneboot_donation_small']);
    await tester.tap(
      find.byKey(const ValueKey('donation-fortuneboot_donation_small')),
    );
    await tester.pump();
    expect(api.purchasedIds, hasLength(1));

    api.purchaseCompleter!.complete(true);
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('donation-fortuneboot_donation_small')),
    );
    await tester.pump();
    expect(api.purchasedIds, hasLength(1));

    api.emitSuccess('fortuneboot_donation_small');
    await tester.pumpAndSettle();

    expect(find.text('感谢支持！'), findsOneWidget);
  });

  testWidgets('shows a retryable error when products cannot be loaded', (
    tester,
  ) async {
    final api = _FakeDonationApi();

    await tester.pumpWidget(_testApp(api: api));
    await tester.pumpAndSettle();

    expect(find.text('暂无法获取捐赠项目，请稍后重试'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
  });

  testWidgets('shows feedback when the purchase cannot start', (tester) async {
    final api = _FakeDonationApi(
      products: const [
        DonationProduct(
          id: 'fortuneboot_donation_small',
          title: '小额支持',
          price: '¥6',
        ),
      ],
      failPurchase: true,
    );

    await tester.pumpWidget(_testApp(api: api));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('donation-fortuneboot_donation_small')),
    );
    await tester.pumpAndSettle();

    expect(api.purchasedIds, ['fortuneboot_donation_small']);
    expect(find.text('无法发起捐赠，请稍后重试'), findsOneWidget);
  });
}
