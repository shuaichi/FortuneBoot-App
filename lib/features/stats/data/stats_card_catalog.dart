/// 统计页可自定义卡片标识。
enum StatsCardId {
  moreReports,
  overview,
  calendar,
  insight,
  dimensionPreview,
  trend,
  categoryShare,
  tags,
  payees,
}

/// 统计卡片目录：默认顺序与持久化 ID 归一化。
abstract final class StatsCardCatalog {
  static const List<StatsCardId> defaultOrder = [
    StatsCardId.overview,
    StatsCardId.calendar,
    StatsCardId.insight,
    StatsCardId.dimensionPreview,
    StatsCardId.trend,
    StatsCardId.categoryShare,
    StatsCardId.tags,
    StatsCardId.payees,
    StatsCardId.moreReports,
  ];

  static const Set<StatsCardId> defaultHidden = {};

  static const List<StatsCardId> allIds = defaultOrder;

  static String toStorageId(StatsCardId id) => id.name;

  static StatsCardId? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final id in allIds) {
      if (id.name == raw) return id;
    }
    return null;
  }

  static List<StatsCardId> normalizeOrder(Iterable<String> stored) {
    final seen = <StatsCardId>{};
    final order = <StatsCardId>[];
    for (final raw in stored) {
      final id = tryParse(raw);
      if (id == null || id == StatsCardId.moreReports || !seen.add(id)) {
        continue;
      }
      order.add(id);
    }
    for (final id in allIds) {
      if (id != StatsCardId.moreReports && seen.add(id)) order.add(id);
    }
    order.add(StatsCardId.moreReports);
    return order;
  }

  static Set<StatsCardId> normalizeHidden(
    Iterable<String> stored, {
    required bool layoutConfigured,
  }) {
    if (!layoutConfigured) return Set<StatsCardId>.of(defaultHidden);
    final hidden = <StatsCardId>{};
    for (final raw in stored) {
      final id = tryParse(raw);
      if (id != null) hidden.add(id);
    }
    return hidden;
  }

  static List<StatsCardId> visibleOrder({
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

  static List<StatsCardId> relocate({
    required List<StatsCardId> visible,
    required StatsCardId from,
    required StatsCardId to,
    bool after = false,
  }) {
    if (from == to) return List<StatsCardId>.of(visible);
    final next = List<StatsCardId>.of(visible);
    final fromIndex = next.indexOf(from);
    final toIndex = next.indexOf(to);
    if (fromIndex < 0 || toIndex < 0) return List<StatsCardId>.of(visible);
    next.removeAt(fromIndex);
    var insertAt = next.indexOf(to);
    if (insertAt < 0) return List<StatsCardId>.of(visible);
    if (after) insertAt += 1;
    next.insert(insertAt, from);
    return next;
  }
}
