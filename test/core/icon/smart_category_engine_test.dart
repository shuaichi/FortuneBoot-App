import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/icon/smart_category_engine.dart';

void main() {
  final engine = SmartCategoryEngine();

  test('reimburse bills infer icons from income domains', () {
    final match = engine.match(
      const BillIconInput(billType: 8, title: '报销款'),
    );

    expect(match.icon, Icons.price_check_rounded);
  });

  test('advance bills keep expense domains and block income keywords', () {
    final match = engine.match(
      const BillIconInput(billType: 7, title: '报销款'),
    );

    expect(match.icon, Icons.payment_rounded);
  });
}
