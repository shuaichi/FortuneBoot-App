import 'dart:async';

import 'package:fortuneboot/features/profile/data/donation_models.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// 只暴露捐赠内购需要的 StoreKit/Google Play 能力，便于服务层可测试。
abstract interface class DonationStoreAdapter {
  Future<List<ProductDetails>> queryProducts(Set<String> identifiers);

  Future<bool> buyConsumable(ProductDetails product);

  Stream<List<PurchaseDetails>> get purchaseStream;

  Future<void> completePurchase(PurchaseDetails purchase);

  void dispose();
}

/// 生产环境适配器，委托官方 in_app_purchase 插件。
final class InAppPurchaseStoreAdapter implements DonationStoreAdapter {
  InAppPurchaseStoreAdapter([InAppPurchase? store])
    : _store = store ?? InAppPurchase.instance;

  final InAppPurchase _store;

  @override
  Future<List<ProductDetails>> queryProducts(Set<String> identifiers) async {
    final response = await _store.queryProductDetails(identifiers);
    if (response.error != null) throw response.error!;
    return response.productDetails;
  }

  @override
  Future<bool> buyConsumable(ProductDetails product) {
    return _store.buyConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _store.purchaseStream;

  @override
  Future<void> completePurchase(PurchaseDetails purchase) {
    return _store.completePurchase(purchase);
  }

  @override
  void dispose() {
    // InAppPurchase.instance 由插件持有，这里不关闭其全局流。
  }
}

/// Apple 捐赠内购服务：查询产品、发起消耗型购买、监听并完成交易。
final class InAppPurchaseDonationService implements DonationApi {
  InAppPurchaseDonationService({DonationStoreAdapter? adapter})
    : _adapter = adapter ?? InAppPurchaseStoreAdapter() {
    _purchaseSubscription = _adapter.purchaseStream.listen(_handlePurchases);
  }

  final DonationStoreAdapter _adapter;
  final StreamController<DonationPurchaseEvent> _events =
      StreamController<DonationPurchaseEvent>.broadcast();
  final Map<String, ProductDetails> _storeProducts = {};

  late final StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;

  @override
  Stream<DonationPurchaseEvent> get purchaseStream => _events.stream;

  @override
  Future<List<DonationProduct>> loadProducts() async {
    final details = await _adapter.queryProducts(
      appleDonationProductIds.toSet(),
    );
    _storeProducts
      ..clear()
      ..addEntries(
        details
            .where((detail) => appleDonationProductIds.contains(detail.id))
            .map((detail) => MapEntry(detail.id, detail)),
      );
    if (_storeProducts.isEmpty) {
      throw StateError('No configured donation products are available');
    }

    return [
      for (final id in appleDonationProductIds)
        if (_storeProducts.containsKey(id))
          DonationProduct(
            id: id,
            title: _storeProducts[id]!.title,
            price: _storeProducts[id]!.price,
          ),
    ];
  }

  @override
  Future<bool> startPurchase(DonationProduct product) async {
    final detail = _storeProducts[product.id];
    if (detail == null) return false;
    return _adapter.buyConsumable(detail);
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _finish(purchase);
          _events.add(DonationPurchaseSucceeded(purchase.productID));
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          await _finish(purchase);
          _events.add(DonationPurchaseFailed(purchase.productID));
        case PurchaseStatus.pending:
          break;
      }
    }
  }

  Future<void> _finish(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase) return;
    try {
      await _adapter.completePurchase(purchase);
      purchase.pendingCompletePurchase = false;
    } on Object {
      // 下次启动仍会重新收到未完成交易；这里保留 pending 状态。
      rethrow;
    }
  }

  @override
  void dispose() {
    _purchaseSubscription.cancel();
    _events.close();
    _adapter.dispose();
  }
}
