import 'package:flutter/material.dart';
import 'package:fortuneboot/features/accounts/data/account_models.dart';
import 'package:fortuneboot/features/accounts/data/bank_brand.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';

/// 统一银行 / 支付图标入口。
///
/// 有导出位图则显示品牌标，否则回退 [AccountTypeMeta] 类型图标。
class BankIcon extends StatelessWidget {
  const BankIcon({
    super.key,
    this.brand,
    this.accountType,
    this.size = 40,
    this.iconSize,
  });

  final BankBrand? brand;
  final int? accountType;
  final double size;
  final double? iconSize;

  factory BankIcon.resolve({
    Key? key,
    String? accountName,
    String? cardNo,
    int? accountType,
    double size = 40,
    double? iconSize,
  }) {
    return BankIcon(
      key: key,
      brand: BankBrand.resolve(accountName: accountName, cardNo: cardNo),
      accountType: accountType,
      size: size,
      iconSize: iconSize,
    );
  }

  factory BankIcon.fromAccount({
    Key? key,
    required FortuneAccountVo account,
    double size = 40,
    double? iconSize,
  }) {
    return BankIcon.resolve(
      key: key,
      accountName: account.accountName,
      cardNo: account.cardNo,
      accountType: account.accountType,
      size: size,
      iconSize: iconSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final asset = brand?.resolvedAssetPath;
    if (asset != null) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipOval(
          child: ColoredBox(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(size * 0.12),
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _fallback(context),
              ),
            ),
          ),
        ),
      );
    }
    return _fallback(context);
  }

  Widget _fallback(BuildContext context) {
    final meta = AccountTypeMeta.of(accountType);
    final tint = meta.tint(context);
    final glyph = iconSize ?? size * 0.55;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: size >= 36 ? FxRadius.tileBorder : BorderRadius.circular(size * 0.28),
      ),
      child: Icon(meta.icon, color: tint, size: glyph),
    );
  }
}
