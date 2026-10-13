import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/profile/data/donation_models.dart';
import 'package:fortuneboot/features/profile/data/in_app_purchase_donation_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

ProductDetails _product(String id, String title, String price) {
  return ProductDetails(
    id: id,
    title: title,
    description: '',
    price: price,
    rawPrice: 1,
    currencyCode: 'USD',
  );
}

PurchaseDetails _purchase(String productId, PurchaseStatus status) {
  return PurchaseDetails(
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: '',
      serverVerificationData: '',
      source: 'test',
    ),
    transactionDate: '0',
    status: status,
  );
}

class _FakeStoreAdapter implements DonationStoreAdapter {
  final List<ProductDetails> products;
  final StreamController<List<PurchaseDetails>> _purchases =
      StreamController<List<PurchaseDetails>>.broadcast();
  final List<Set<String>> queriedIds = [];
  final List<ProductDetails> purchasedProducts = [];
  final List<PurchaseDetails> completedPurchases = [];

  _FakeStoreAdapter(this.products);

  @override
  Future<List<ProductDetails>> queryProducts(Set<String> identifiers) async {
    queriedIds.add(identifiers);
    return products;
  }

  @override
  Future<bool> buyConsumable(ProductDetails product) async {
    purchasedProducts.add(product);
    return true;
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _purchases.stream;

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completedPurchases.add(purchase);
  }

  void emit(PurchaseDetails purchase) {
    _purchases.add([purchase]);
  }

  @override
  void dispose() {
    _purchases.close();
  }
}

void main() {
  test('loads only configured donation products in App Store order', () async {
    final adapter = _FakeStoreAdapter([
      _product('other_product', 'Other', '¥1'),
      _product('fortuneboot_donation_large', '大额支持', '¥68'),
      _product('fortuneboot_donation_small', '小额支持', '¥6'),
    ]);
    final service = InAppPurchaseDonationService(adapter: adapter);
    addTearDown(service.dispose);

    final products = await service.loadProducts();

    expect(products.map((product) => product.id), [
      'fortuneboot_donation_small',
      'fortuneboot_donation_large',
    ]);
    expect(adapter.queriedIds.single, appleDonationProductIds.toSet());
  });

  test(
    'starts a consumable purchase with the loaded StoreKit product',
    () async {
      final adapter = _FakeStoreAdapter([
        _product('fortuneboot_donation_small', '小额支持', '¥6'),
      ]);
      final service = InAppPurchaseDonationService(adapter: adapter);
      addTearDown(service.dispose);

      final products = await service.loadProducts();
      final started = await service.startPurchase(products.single);

      expect(started, isTrue);
      expect(adapter.purchasedProducts.map((product) => product.id), [
        'fortuneboot_donation_small',
      ]);
    },
  );

  test('emits success and completes a purchased transaction', () async {
    final adapter = _FakeStoreAdapter([
      _product('fortuneboot_donation_small', '小额支持', '¥6'),
    ]);
    final service = InAppPurchaseDonationService(adapter: adapter);
    addTearDown(service.dispose);
    final eventFuture = service.purchaseStream.first;

    final purchase = _purchase(
      'fortuneboot_donation_small',
      PurchaseStatus.purchased,
    )..pendingCompletePurchase = true;
    adapter.emit(purchase);

    expect(await eventFuture, isA<DonationPurchaseSucceeded>());
    await Future<void>.delayed(Duration.zero);
    expect(adapter.completedPurchases, [purchase]);
  });

  test('emits failure and completes canceled or failed transactions', () async {
    final adapter = _FakeStoreAdapter([
      _product('fortuneboot_donation_small', '小额支持', '¥6'),
    ]);
    final service = InAppPurchaseDonationService(adapter: adapter);
    addTearDown(service.dispose);
    final eventFuture = service.purchaseStream.first;

    final purchase = _purchase(
      'fortuneboot_donation_small',
      PurchaseStatus.canceled,
    )..pendingCompletePurchase = true;
    adapter.emit(purchase);

    expect(await eventFuture, isA<DonationPurchaseFailed>());
    await Future<void>.delayed(Duration.zero);
    expect(adapter.completedPurchases, [purchase]);
  });
}
