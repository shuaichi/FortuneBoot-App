import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/accounts/data/bank_brand.dart';

void main() {
  group('BankBrand.resolve', () {
    test('matches huabei before alipay', () {
      expect(
        BankBrand.resolve(accountName: '花呗')?.id,
        BankBrand.huabei.id,
      );
      expect(
        BankBrand.resolve(accountName: '支付宝')?.id,
        BankBrand.alipay.id,
      );
    });

    test('matches common Chinese bank names', () {
      expect(
        BankBrand.resolve(accountName: '招行储蓄卡')?.id,
        BankBrand.cmb.id,
      );
      expect(
        BankBrand.resolve(accountName: '工商银行工资卡')?.id,
        BankBrand.icbc.id,
      );
    });

    test('matches policy banks before similar commercial names', () {
      expect(
        BankBrand.resolve(accountName: '中国农业发展银行')?.id,
        BankBrand.adbc.id,
      );
      expect(
        BankBrand.resolve(accountName: '农业银行储蓄')?.id,
        BankBrand.abc.id,
      );
      expect(
        BankBrand.resolve(accountName: '中国人民银行')?.id,
        BankBrand.pbc.id,
      );
      expect(
        BankBrand.resolve(accountName: '洛阳银行')?.id,
        BankBrand.lyb.id,
      );
    });

    test('falls back to card BIN prefix', () {
      expect(
        BankBrand.resolve(accountName: '日常卡', cardNo: '6225881234567890')?.id,
        BankBrand.cmb.id,
      );
    });

    test('returns null when unknown', () {
      expect(BankBrand.resolve(accountName: '现金钱包'), isNull);
    });

    test('every brand with assetPath points to banks/{id}.png', () {
      for (final brand in BankBrand.known) {
        final path = brand.resolvedAssetPath;
        if (path == null) continue;
        expect(path, 'assets/images/banks/${brand.id}.png');
      }
    });
  });
}
