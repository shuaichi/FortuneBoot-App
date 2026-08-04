import 'package:fortuneboot/core/network/fx_api.dart';

/// 归物（物品保管）状态。
///
/// TODO(后端确认): status/statusDesc 的 int 值文档未定义，此处为经验映射
/// （在役=1 / 退役=2 / 已出售=3）。UI 展示优先使用后端返回的 [FortuneGoodsKeeperVo.statusDesc]；
/// 仅在“新增”缺省时用本枚举提供选项与初值。若后端提供状态枚举接口应改为动态消费。
enum GoodsStatus {
  active(1, '在役'),
  retired(2, '退役'),
  sold(3, '已出售');

  const GoodsStatus(this.value, this.label);

  final int value;
  final String label;

  static GoodsStatus? fromValue(int? v) {
    if (v == null) return null;
    for (final s in GoodsStatus.values) {
      if (s.value == v) return s;
    }
    return null;
  }
}

/// 归物条目 VO。
class FortuneGoodsKeeperVo {
  final int? goodsKeeperId;
  final int? bookId;
  final String? goodsName;
  final int? categoryId;
  final String? categoryName;
  final int? tagId;
  final String? tagName;
  final double? price;
  final String? purchaseDate; // yyyy-MM-dd
  final int? holdingTime; // 持有天数（后端算）
  final String? warrantyDate; // yyyy-MM-dd
  final String? isOverWarranty; // 已过保/未过保/空
  final bool useByTimes;
  final int? usageNum;
  final int? status;
  final String? statusDesc;
  final String? retiredDate; // yyyy-MM-dd
  final double? soldPrice;
  final String? remark;
  final double? dailyAverageCost; // 日均成本（后端算）

  const FortuneGoodsKeeperVo({
    this.goodsKeeperId,
    this.bookId,
    this.goodsName,
    this.categoryId,
    this.categoryName,
    this.tagId,
    this.tagName,
    this.price,
    this.purchaseDate,
    this.holdingTime,
    this.warrantyDate,
    this.isOverWarranty,
    this.useByTimes = false,
    this.usageNum,
    this.status,
    this.statusDesc,
    this.retiredDate,
    this.soldPrice,
    this.remark,
    this.dailyAverageCost,
  });

  /// 出售盈亏（有 soldPrice 时 = 售价 - 购买价）。
  double? get profit {
    if (soldPrice == null || price == null) return null;
    return soldPrice! - price!;
  }

  bool get isOverWarrantyFlag => isOverWarranty == '已过保';

  factory FortuneGoodsKeeperVo.fromJson(Map<String, dynamic> json) {
    return FortuneGoodsKeeperVo(
      goodsKeeperId: FxApi.asId(json['goodsKeeperId']),
      bookId: FxApi.asId(json['bookId']),
      goodsName: json['goodsName']?.toString(),
      categoryId: FxApi.asId(json['categoryId']),
      categoryName: json['categoryName']?.toString(),
      tagId: FxApi.asId(json['tagId']),
      tagName: json['tagName']?.toString(),
      price: FxApi.asDouble(json['price']),
      purchaseDate: json['purchaseDate']?.toString(),
      holdingTime: FxApi.asId(json['holdingTime']),
      warrantyDate: json['warrantyDate']?.toString(),
      isOverWarranty: json['isOverWarranty']?.toString(),
      useByTimes: FxApi.asBool(json['useByTimes']),
      usageNum: FxApi.asId(json['usageNum']),
      status: FxApi.asId(json['status']),
      statusDesc: json['statusDesc']?.toString(),
      retiredDate: json['retiredDate']?.toString(),
      soldPrice: FxApi.asDouble(json['soldPrice']),
      remark: json['remark']?.toString(),
      dailyAverageCost: FxApi.asDouble(json['dailyAverageCost']),
    );
  }
}

/// 归物统计（顶部统计条）。
class GoodsStatistics {
  final double allPrice;
  final double allDailyPrice;
  final double activePrice;
  final double activeDailyPrice;

  const GoodsStatistics({
    this.allPrice = 0,
    this.allDailyPrice = 0,
    this.activePrice = 0,
    this.activeDailyPrice = 0,
  });

  factory GoodsStatistics.fromJson(Map<String, dynamic> json) =>
      GoodsStatistics(
        allPrice: FxApi.asDouble(json['allPrice']) ?? 0,
        allDailyPrice: FxApi.asDouble(json['allDailyPrice']) ?? 0,
        activePrice: FxApi.asDouble(json['activePrice']) ?? 0,
        activeDailyPrice: FxApi.asDouble(json['activeDailyPrice']) ?? 0,
      );
}

/// 分页结果。
class GoodsPage {
  final List<FortuneGoodsKeeperVo> rows;
  final int total;
  const GoodsPage({this.rows = const [], this.total = 0});
}

/// 分类/标签下拉选项（归物表单用）。
class GoodsOption {
  final int id;
  final String name;
  const GoodsOption({required this.id, required this.name});
}
