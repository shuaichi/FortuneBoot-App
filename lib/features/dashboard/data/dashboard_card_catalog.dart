import 'package:fortuneboot/fx/layout/fx_bento_grid.dart';

/// 仪表盘可自定义卡片标识。
enum DashboardCardId {
  netWorth,
  monthExpense,
  monthIncome,
  trend,
  recentBills,
  categoryTop,
  quickAdd,
}

/// 单张卡片的默认栅格规格与数据门槛。
class DashboardCardSpec {
  const DashboardCardSpec({
    required this.id,
    this.colSpan = 1,
    this.rowSpan = 1,
    this.requiresNonEmptyUser = false,
    this.hideWhenCategoryEmpty = false,
  });

  final DashboardCardId id;
  final int colSpan;
  final int rowSpan;
  final bool requiresNonEmptyUser;
  final bool hideWhenCategoryEmpty;
}

/// 仪表盘卡片目录：默认顺序、隐藏集、持久化 ID 归一化。
abstract final class DashboardCardCatalog {
  static const List<DashboardCardId> defaultOrder = [
    DashboardCardId.netWorth,
    DashboardCardId.monthExpense,
    DashboardCardId.monthIncome,
    DashboardCardId.trend,
    DashboardCardId.recentBills,
    DashboardCardId.categoryTop,
  ];

  /// 快捷记账默认不展示，用户可自行「放置」。
  static const Set<DashboardCardId> defaultHidden = {
    DashboardCardId.quickAdd,
  };

  static const List<DashboardCardId> allIds = [
    ...defaultOrder,
    DashboardCardId.quickAdd,
  ];

  static const Map<DashboardCardId, DashboardCardSpec> specs = {
    DashboardCardId.netWorth: DashboardCardSpec(
      id: DashboardCardId.netWorth,
      colSpan: 2,
      rowSpan: 2,
    ),
    DashboardCardId.monthExpense: DashboardCardSpec(
      id: DashboardCardId.monthExpense,
      requiresNonEmptyUser: true,
    ),
    DashboardCardId.monthIncome: DashboardCardSpec(
      id: DashboardCardId.monthIncome,
      requiresNonEmptyUser: true,
    ),
    DashboardCardId.trend: DashboardCardSpec(
      id: DashboardCardId.trend,
      colSpan: FxBentoTile.fullSpan,
      rowSpan: 2,
      requiresNonEmptyUser: true,
    ),
    DashboardCardId.recentBills: DashboardCardSpec(
      id: DashboardCardId.recentBills,
      colSpan: FxBentoTile.fullSpan,
      rowSpan: 2,
    ),
    DashboardCardId.categoryTop: DashboardCardSpec(
      id: DashboardCardId.categoryTop,
      colSpan: FxBentoTile.fullSpan,
      rowSpan: 2,
      requiresNonEmptyUser: true,
      hideWhenCategoryEmpty: true,
    ),
    DashboardCardId.quickAdd: DashboardCardSpec(
      id: DashboardCardId.quickAdd,
    ),
  };

  static String toStorageId(DashboardCardId id) => id.name;

  static DashboardCardId? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final id in allIds) {
      if (id.name == raw) return id;
    }
    return null;
  }

  static DashboardCardSpec specOf(DashboardCardId id) =>
      specs[id] ?? DashboardCardSpec(id: id);

  /// 空存储 → 默认顺序；非法 ID 丢弃；缺省 ID 追加到末尾。
  static List<DashboardCardId> normalizeOrder(Iterable<String> stored) {
    final seen = <DashboardCardId>{};
    final order = <DashboardCardId>[];
    for (final raw in stored) {
      final id = tryParse(raw);
      if (id == null || !seen.add(id)) continue;
      order.add(id);
    }
    for (final id in allIds) {
      if (seen.add(id)) order.add(id);
    }
    return order;
  }

  /// 未配置布局时用默认隐藏；已配置时允许空集（全部展示）。
  static Set<DashboardCardId> normalizeHidden(
    Iterable<String> stored, {
    required bool layoutConfigured,
  }) {
    if (!layoutConfigured) return Set<DashboardCardId>.of(defaultHidden);
    final hidden = <DashboardCardId>{};
    for (final raw in stored) {
      final id = tryParse(raw);
      if (id != null) hidden.add(id);
    }
    return hidden;
  }

  /// 用户勾选可见的顺序（不含数据门槛过滤）。
  static List<DashboardCardId> visibleOrder({
    required Iterable<String> storedOrder,
    required Iterable<String> storedHidden,
    required bool layoutConfigured,
  }) {
    final order = normalizeOrder(storedOrder);
    final hidden = normalizeHidden(
      storedHidden,
      layoutConfigured: layoutConfigured,
    );
    return order.where((id) => !hidden.contains(id)).toList();
  }

  static bool _isNarrow(DashboardCardId id) {
    final span = specOf(id).colSpan;
    return span == 1;
  }

  static bool _isWide(DashboardCardId id) {
    final span = specOf(id).colSpan;
    return span >= 2 || span >= FxBentoTile.fullSpan;
  }

  /// 把 [from] 挪到 [to] 之前或之后，用于拖拽时挤开其他卡片。
  /// 大卡拖到连续小卡上时，锚定到该小卡组的开头，整组被挤到大卡下方。
  static List<DashboardCardId> relocate({
    required List<DashboardCardId> visible,
    required DashboardCardId from,
    required DashboardCardId to,
    bool after = false,
  }) {
    if (from == to) return List<DashboardCardId>.of(visible);
    final fromIndex = visible.indexOf(from);
    var toIndex = visible.indexOf(to);
    if (fromIndex < 0 || toIndex < 0) return List<DashboardCardId>.of(visible);

    var insertAfter = after;
    var target = to;
    if (_isWide(from) && _isNarrow(to)) {
      var groupStart = toIndex;
      while (groupStart > 0 && _isNarrow(visible[groupStart - 1])) {
        groupStart--;
      }
      target = visible[groupStart];
      // 大卡挤上/挤入小卡行：整组小卡都到大卡后面。
      insertAfter = false;
    }

    final next = List<DashboardCardId>.of(visible);
    next.removeAt(fromIndex);
    var insertAt = next.indexOf(target);
    if (insertAt < 0) return List<DashboardCardId>.of(visible);
    if (insertAfter) insertAt += 1;
    next.insert(insertAt, from);
    return next;
  }

  static List<DashboardCardId> hiddenOrder({
    required Iterable<String> storedOrder,
    required Iterable<String> storedHidden,
    required bool layoutConfigured,
  }) {
    final order = normalizeOrder(storedOrder);
    final hidden = normalizeHidden(
      storedHidden,
      layoutConfigured: layoutConfigured,
    );
    return order.where(hidden.contains).toList();
  }
}
