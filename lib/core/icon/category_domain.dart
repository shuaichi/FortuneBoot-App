import 'package:flutter/material.dart';

/// 智能图标引擎的纯数据类型定义（不依赖任何旧 UI 代码）。
///
/// - [CategoryMatch]：引擎对外返回的最终图标 + 颜色结果。
/// - [CategoryDomain]：一个类别领域（如餐饮、购物），带唯一 id。
/// - [CategoryRule]：一条规则，把 domain 与商户库 / 关键词库关联。
/// - [CategoryScore]：调试用打分明细。

/// 引擎对外返回的匹配结果：一个图标 + 一种配色。
class CategoryMatch {
  final IconData icon;
  final Color color;

  const CategoryMatch({required this.icon, required this.color});
}

/// 类别领域实体（带唯一 id，按 id 判等，便于作为 Map 的 key）。
class CategoryDomain {
  final String id; // 例如: 'food_general', 'shopping_online'
  final IconData icon;
  final Color color;

  const CategoryDomain({
    required this.id,
    required this.icon,
    required this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryDomain &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 强类型规则：把一个 domain 与其商户特征 / 关键词特征绑定。
class CategoryRule {
  final CategoryDomain domain;
  final List<String> merchants; // 商户特征（强特征，权重最高）
  final List<String> keywords; // 关键词特征（中等特征）

  const CategoryRule({
    required this.domain,
    this.merchants = const [],
    this.keywords = const [],
  });
}

/// 调试用打分明细：某个 domain 命中后累计的分数。
class CategoryScore {
  final String domainId;
  final int score;

  const CategoryScore({required this.domainId, required this.score});
}
