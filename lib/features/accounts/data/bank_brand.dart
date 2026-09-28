import 'package:flutter/material.dart';

/// 本地银行 / 支付品牌：关键词、卡 BIN、导出后的位图路径。
///
/// 图标管理约定（方案 A）：
/// - 源文件：`assets/icons/banks/{id}.svg`（不进 App 包）
/// - 运行时：`assets/images/banks/{id}.png`（由 tool/export_bank_icons.py 导出）
class BankBrand {
  const BankBrand({
    required this.id,
    required this.shortLabel,
    required this.color,
    required this.keywords,
    this.binPrefixes = const [],
    this.assetPath,
  });

  final String id;
  final String shortLabel;
  final Color color;
  final List<String> keywords;
  final List<String> binPrefixes;

  /// 导出后的位图；为 null 表示尚未投放图标，UI 回退账户类型图标。
  final String? assetPath;

  static String assetFor(String id) => 'assets/images/banks/$id.png';

  static const BankBrand icbc = BankBrand(
    id: 'icbc',
    shortLabel: '工商',
    color: Color(0xFFC8102E),
    keywords: ['工商银行', '工商', '工行', 'ICBC'],
    binPrefixes: ['622202', '622208', '621226'],
    assetPath: 'assets/images/banks/icbc.png',
  );

  static const BankBrand ccb = BankBrand(
    id: 'ccb',
    shortLabel: '建设',
    color: Color(0xFF003B70),
    keywords: ['建设银行', '建设', '建行', 'CCB'],
    binPrefixes: ['621700', '622280', '436742'],
    assetPath: 'assets/images/banks/ccb.png',
  );

  static const BankBrand abc = BankBrand(
    id: 'abc',
    shortLabel: '农业',
    color: Color(0xFF319C8B),
    keywords: ['农业银行', '农行', 'ABC'],
    binPrefixes: ['622848', '622845'],
    assetPath: 'assets/images/banks/abc.png',
  );

  static const BankBrand boc = BankBrand(
    id: 'boc',
    shortLabel: '中国',
    color: Color(0xFFA71E32),
    keywords: ['中国银行', '中行', 'BOC'],
    binPrefixes: ['621661', '621660', '456351'],
    assetPath: 'assets/images/banks/boc.png',
  );

  static const BankBrand bocom = BankBrand(
    id: 'bocom',
    shortLabel: '交通',
    color: Color(0xFF1D2088),
    keywords: ['交通银行', '交行', 'BOCOM', 'BCM'],
    binPrefixes: ['622260', '621002'],
    assetPath: 'assets/images/banks/bocom.png',
  );

  static const BankBrand cmb = BankBrand(
    id: 'cmb',
    shortLabel: '招商',
    color: Color(0xFFE60012),
    keywords: ['招商银行', '招商', '招行', 'CMB'],
    binPrefixes: ['622588', '622580', '622576', '439225'],
    assetPath: 'assets/images/banks/cmb.png',
  );

  static const BankBrand spdb = BankBrand(
    id: 'spdb',
    shortLabel: '浦发',
    color: Color(0xFF002B5C),
    keywords: ['浦发银行', '浦发', 'SPDB'],
    binPrefixes: ['622521', '622516'],
    assetPath: null,
  );

  static const BankBrand citic = BankBrand(
    id: 'citic',
    shortLabel: '中信',
    color: Color(0xFFD7000F),
    keywords: ['中信银行', '中信', 'CITIC'],
    binPrefixes: ['622690', '622680'],
    assetPath: null,
  );

  static const BankBrand ceb = BankBrand(
    id: 'ceb',
    shortLabel: '光大',
    color: Color(0xFF6A1B9A),
    keywords: ['光大银行', '中国光大银行', '光大', 'CEB'],
    binPrefixes: ['622666', '622655'],
    assetPath: 'assets/images/banks/ceb.png',
  );

  static const BankBrand cmbc = BankBrand(
    id: 'cmbc',
    shortLabel: '民生',
    color: Color(0xFF00A0E9),
    keywords: ['民生银行', '民生', 'CMBC'],
    binPrefixes: ['622622', '622615'],
    assetPath: null,
  );

  static const BankBrand cib = BankBrand(
    id: 'cib',
    shortLabel: '兴业',
    color: Color(0xFF004B87),
    keywords: ['兴业银行', '兴业', 'CIB'],
    binPrefixes: ['622909', '622908'],
    assetPath: null,
  );

  static const BankBrand pab = BankBrand(
    id: 'pab',
    shortLabel: '平安',
    color: Color(0xFFEA5404),
    keywords: ['平安银行', '平安', 'PAB'],
    binPrefixes: ['622155', '622156'],
    assetPath: null,
  );

  static const BankBrand hxb = BankBrand(
    id: 'hxb',
    shortLabel: '华夏',
    color: Color(0xFFD7000F),
    keywords: ['华夏银行', '华夏', 'HXB'],
    binPrefixes: ['622630', '622631'],
    assetPath: null,
  );

  static const BankBrand cgb = BankBrand(
    id: 'cgb',
    shortLabel: '广发',
    color: Color(0xFFE60012),
    keywords: ['广发银行', '广发', 'CGB'],
    binPrefixes: ['622568', '622558'],
    assetPath: null,
  );

  static const BankBrand psbc = BankBrand(
    id: 'psbc',
    shortLabel: '邮储',
    color: Color(0xFF007A3D),
    keywords: ['邮储银行', '邮储', '邮政储蓄', 'PSBC'],
    binPrefixes: ['621799', '622150'],
    assetPath: 'assets/images/banks/psbc.png',
  );

  static const BankBrand bob = BankBrand(
    id: 'bob',
    shortLabel: '北京',
    color: Color(0xFFD7000F),
    keywords: ['北京银行', 'BOB'],
    binPrefixes: ['622163'],
    assetPath: null,
  );

  /// 政策 / 地方行（有导出图才入库）。
  static const BankBrand pbc = BankBrand(
    id: 'pbc',
    shortLabel: '人行',
    color: Color(0xFFC8102E),
    keywords: ['中国人民银行', '人民银行', '人行'],
    assetPath: 'assets/images/banks/pbc.png',
  );

  static const BankBrand cdb = BankBrand(
    id: 'cdb',
    shortLabel: '国开',
    color: Color(0xFF003B70),
    keywords: ['国家开发银行', '国开行', '国开'],
    assetPath: 'assets/images/banks/cdb.png',
  );

  static const BankBrand adbc = BankBrand(
    id: 'adbc',
    shortLabel: '农发',
    color: Color(0xFF319C8B),
    keywords: ['中国农业发展银行', '农业发展银行', '农发行', '农发'],
    assetPath: 'assets/images/banks/adbc.png',
  );

  static const BankBrand eximbank = BankBrand(
    id: 'eximbank',
    shortLabel: '进出口',
    color: Color(0xFF1D2088),
    keywords: ['中国进出口银行', '进出口银行', '进出口'],
    assetPath: 'assets/images/banks/eximbank.png',
  );

  static const BankBrand lyb = BankBrand(
    id: 'lyb',
    shortLabel: '洛阳',
    color: Color(0xFFE60012),
    keywords: ['洛阳银行'],
    assetPath: 'assets/images/banks/lyb.png',
  );

  /// 花呗独立于支付宝，关键词优先匹配。
  static const BankBrand huabei = BankBrand(
    id: 'huabei',
    shortLabel: '花呗',
    color: Color(0xFF1677FF),
    keywords: ['花呗', '借呗'],
    assetPath: 'assets/images/banks/huabei.png',
  );

  static const BankBrand alipay = BankBrand(
    id: 'alipay',
    shortLabel: '支付宝',
    color: Color(0xFF1677FF),
    keywords: ['支付宝', 'Alipay'],
    assetPath: 'assets/images/banks/alipay.png',
  );

  static const BankBrand yuebao = BankBrand(
    id: 'yuebao',
    shortLabel: '余额宝',
    color: Color(0xFF1677FF),
    keywords: ['余额宝'],
    assetPath: 'assets/images/banks/yuebao.png',
  );

  static const BankBrand mybank = BankBrand(
    id: 'mybank',
    shortLabel: '网商',
    color: Color(0xFF1677FF),
    keywords: ['网商银行', '网商'],
    assetPath: 'assets/images/banks/mybank.png',
  );

  static const BankBrand zhima = BankBrand(
    id: 'zhima',
    shortLabel: '芝麻',
    color: Color(0xFF1677FF),
    keywords: ['芝麻信用', '芝麻'],
    assetPath: 'assets/images/banks/zhima.png',
  );

  static const BankBrand wechat = BankBrand(
    id: 'wechat',
    shortLabel: '微信',
    color: Color(0xFF07C160),
    keywords: ['微信', '微信支付', 'WeChat'],
    assetPath: 'assets/images/banks/wechat.png',
  );

  static const BankBrand jd = BankBrand(
    id: 'jd',
    shortLabel: '京东',
    color: Color(0xFFE1251B),
    keywords: ['京东', '白条', 'JD'],
    assetPath: null,
  );

  static const BankBrand meituan = BankBrand(
    id: 'meituan',
    shortLabel: '美团',
    color: Color(0xFFFFD100),
    keywords: ['美团', '美团月付'],
    assetPath: null,
  );

  /// 匹配顺序：更具体的名称须排在泛化关键词之前（如农发在农行前、花呗在支付宝前）。
  static const List<BankBrand> known = [
    huabei,
    yuebao,
    mybank,
    zhima,
    alipay,
    wechat,
    jd,
    meituan,
    adbc,
    abc,
    pbc,
    cdb,
    eximbank,
    icbc,
    ccb,
    boc,
    bocom,
    cmb,
    lyb,
    spdb,
    citic,
    ceb,
    cmbc,
    cib,
    pab,
    hxb,
    cgb,
    psbc,
    bob,
  ];

  /// 运行时位图路径：显式配置优先，否则按 id 约定路径。
  String? get resolvedAssetPath {
    if (assetPath != null) return assetPath;
    return null;
  }

  static BankBrand? resolve({String? accountName, String? cardNo}) {
    final name = (accountName ?? '').trim();
    if (name.isNotEmpty) {
      final upper = name.toUpperCase();
      for (final brand in known) {
        for (final kw in brand.keywords) {
          if (name.contains(kw) || upper.contains(kw.toUpperCase())) {
            return brand;
          }
        }
      }
    }

    final digits = (cardNo ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 6) {
      final prefix = digits.substring(0, 6);
      for (final brand in known) {
        for (final bin in brand.binPrefixes) {
          if (prefix.startsWith(bin)) return brand;
        }
      }
    }
    return null;
  }
}
