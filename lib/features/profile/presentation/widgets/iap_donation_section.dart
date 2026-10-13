import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fortuneboot/features/profile/data/donation_models.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// Apple 平台捐赠区域：只展示内购项目，不出现外部收款二维码。
class IapDonationSection extends StatefulWidget {
  const IapDonationSection({super.key, required this.api});

  final DonationApi api;

  @override
  State<IapDonationSection> createState() => _IapDonationSectionState();
}

enum _LoadStatus { loading, ready, error }

class _IapDonationSectionState extends State<IapDonationSection> {
  StreamSubscription<DonationPurchaseEvent>? _subscription;
  _LoadStatus _status = _LoadStatus.loading;
  List<DonationProduct> _products = const [];
  String? _purchasingId;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _subscription = widget.api.purchaseStream.listen(_onPurchaseEvent);
    _loadProducts();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    widget.api.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() {
      _status = _LoadStatus.loading;
      _feedback = null;
    });
    try {
      final products = await widget.api.loadProducts();
      if (products.isEmpty) throw StateError('No donation products');
      if (!mounted) return;
      setState(() {
        _products = _ordered(products);
        _status = _LoadStatus.ready;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _status = _LoadStatus.error;
        _products = const [];
      });
    }
  }

  List<DonationProduct> _ordered(List<DonationProduct> products) {
    return [
      for (final id in appleDonationProductIds)
        ...products.where((product) => product.id == id),
    ];
  }

  void _onPurchaseEvent(DonationPurchaseEvent event) {
    if (!mounted) return;
    setState(() {
      _feedback = event is DonationPurchaseSucceeded
          ? S.current.profileDonateThanks
          : S.current.profileDonateIapStartFailed;
      if (_purchasingId == event.productId) {
        _purchasingId = null;
      }
    });
  }

  Future<void> _purchase(DonationProduct product) async {
    if (_purchasingId != null) return;
    var releasePurchase = true;
    setState(() {
      _purchasingId = product.id;
      _feedback = null;
    });
    try {
      final accepted = await widget.api.startPurchase(product);
      if (!mounted) return;
      if (!accepted) {
        setState(() {
          _feedback = S.current.profileDonateIapStartFailed;
        });
      } else {
        // StoreKit 的交易结果通过 purchaseStream 返回；请求成功前保持防重复状态。
        releasePurchase = false;
      }
    } on Object {
      if (!mounted) return;
      setState(() {
        _feedback = S.current.profileDonateIapStartFailed;
      });
    } finally {
      if (mounted && releasePurchase) {
        setState(() {
          _purchasingId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = FxFinanceColors.of(context);
    final strings = S.of(context);
    return switch (_status) {
      _LoadStatus.loading => const Center(child: CircularProgressIndicator()),
      _LoadStatus.error => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: finance.expense),
          const SizedBox(height: FxSpacing.sm),
          Text(
            strings.profileDonateIapUnavailable,
            style: FxTypography.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: FxSpacing.md),
          FxButton.tonal(
            label: strings.commonRetry,
            expand: true,
            onPressed: _loadProducts,
          ),
        ],
      ),
      _LoadStatus.ready => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_feedback != null) ...[
            Text(_feedback!, style: FxTypography.body),
            const SizedBox(height: FxSpacing.md),
          ],
          for (final product in _products)
            Padding(
              padding: const EdgeInsets.only(bottom: FxSpacing.sm),
              child: _ProductButton(
                product: product,
                loading: _purchasingId == product.id,
                enabled: _purchasingId == null,
                onPressed: () => _purchase(product),
              ),
            ),
        ],
      ),
    };
  }
}

class _ProductButton extends StatelessWidget {
  const _ProductButton({
    required this.product,
    required this.loading,
    required this.enabled,
    required this.onPressed,
  });

  final DonationProduct product;
  final bool loading;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return OutlinedButton.icon(
      key: ValueKey('donation-${product.id}'),
      onPressed: enabled ? onPressed : null,
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.favorite_rounded, color: palette.primary),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(product.title),
          Text(
            product.price,
            style: FxTypography.caption.copyWith(
              color: FxPalette.of(context).textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
