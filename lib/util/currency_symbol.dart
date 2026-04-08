import 'package:money2/money2.dart';

// 初始化全局货币注册表（与 locale 无关）
final Currencies _currencies = Currencies()
  ..registerList(CommonCurrencies().asList());

// 一些扩展/修正可以在这里注册（若未来需要）
// 例如：_currencies.register(Currency.create('ABC', 2, symbol: 'ABC'));

// 规范化输入：trim + uppercase；特殊别名归一
String _normalizeCode(String code) {
  final c = code.trim().toUpperCase();
  if (c == 'RMB') {
    return 'CNY';
  }
  // 单独处理这个汇率类型
  if (c == 'currencyIdR' || c == 'CURRENCYIDR') {
    return 'IDR';
  }
  return c;
}

// 获取货币符号；未命中时回退返回原代码
// 纯函数：不读取 locale，不依赖 intl 的符号能力
String getCurrencySymbol(String code) {
  final normalized = _normalizeCode(code);
  if (normalized.isEmpty) return '';
  final currency = _currencies.find(normalized);
  if (currency != null && currency.symbol.isNotEmpty) {
    return currency.symbol;
  }
  // 未命中或无符号：返回原始代码
  return normalized;
}
