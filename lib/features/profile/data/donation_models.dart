/// Apple 捐赠内购产品 ID。必须在 App Store Connect 中创建同名消耗型产品。
const appleDonationProductIds = [
  'fortuneboot_donation_small',
  'fortuneboot_donation_medium',
  'fortuneboot_donation_large',
];

final class DonationProduct {
  const DonationProduct({
    required this.id,
    required this.title,
    required this.price,
  });

  final String id;
  final String title;
  final String price;
}

sealed class DonationPurchaseEvent {
  const DonationPurchaseEvent(this.productId);

  final String productId;
}

final class DonationPurchaseSucceeded extends DonationPurchaseEvent {
  const DonationPurchaseSucceeded(super.productId);
}

final class DonationPurchaseFailed extends DonationPurchaseEvent {
  const DonationPurchaseFailed(super.productId);
}

/// 捐赠内购边界，便于 UI 与 StoreKit 实现解耦测试。
abstract interface class DonationApi {
  Future<List<DonationProduct>> loadProducts();

  Future<bool> startPurchase(DonationProduct product);

  Stream<DonationPurchaseEvent> get purchaseStream;

  void dispose();
}
