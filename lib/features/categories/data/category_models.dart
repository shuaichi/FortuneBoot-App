import 'package:fortuneboot/core/network/fx_api.dart';

/// 分类 VO（FortuneCategoryVo）——树形。
/// categoryType：支出1 / 收入2。children 为子分类。
class FortuneCategoryVo {
  final int? categoryId;
  final int? parentId;
  final String? categoryName;
  final int? categoryType; // 1支出 2收入
  final int? sort;
  final String? remark;
  final bool enable;
  final bool recycleBin;
  final List<FortuneCategoryVo> children;

  const FortuneCategoryVo({
    this.categoryId,
    this.parentId,
    this.categoryName,
    this.categoryType,
    this.sort,
    this.remark,
    this.enable = true,
    this.recycleBin = false,
    this.children = const [],
  });

  factory FortuneCategoryVo.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    final children = <FortuneCategoryVo>[];
    if (rawChildren is List) {
      for (final c in rawChildren) {
        if (c is Map) {
          children.add(
            FortuneCategoryVo.fromJson(Map<String, dynamic>.from(c)),
          );
        }
      }
    }
    return FortuneCategoryVo(
      categoryId: FxApi.asId(json['categoryId']),
      parentId: FxApi.asId(json['parentId']),
      categoryName: json['categoryName']?.toString(),
      categoryType: FxApi.asId(json['categoryType']),
      sort: FxApi.asId(json['sort']),
      remark: json['remark']?.toString(),
      enable: FxApi.asBool(json['enable'], orElse: true),
      recycleBin: FxApi.asBool(json['recycleBin']),
      children: children,
    );
  }

  bool get isExpense => categoryType != 2;
  bool get isIncome => categoryType == 2;

  FortuneCategoryVo copyWith({bool? enable, List<FortuneCategoryVo>? children}) {
    return FortuneCategoryVo(
      categoryId: categoryId,
      parentId: parentId,
      categoryName: categoryName,
      categoryType: categoryType,
      sort: sort,
      remark: remark,
      enable: enable ?? this.enable,
      recycleBin: recycleBin,
      children: children ?? this.children,
    );
  }
}
