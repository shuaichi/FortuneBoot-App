class TagNode {
  final int tagId;
  final int id;
  final String tagName;
  final int bookId;
  final int parentId;
  final bool canExpense;
  final bool canIncome;
  final bool canTransfer;
  final bool enable;
  final int sort;
  final String? remark;
  final String? icon;
  final List<TagNode> children;

  TagNode({
    required this.tagId,
    required this.id,
    required this.tagName,
    required this.bookId,
    required this.parentId,
    required this.canExpense,
    required this.canIncome,
    required this.canTransfer,
    required this.enable,
    required this.sort,
    this.remark,
    this.icon,
    required this.children,
  });

  factory TagNode.fromJson(Map<String, dynamic> json) {
    return TagNode(
      tagId: (json['tagId'] as num?)?.toInt() ?? 0,
      id: (json['id'] as num?)?.toInt() ??
          (json['tagId'] as num?)?.toInt() ??
          0,
      tagName: json['tagName']?.toString() ?? '',
      bookId: (json['bookId'] as num?)?.toInt() ?? 0,
      parentId: (json['parentId'] as num?)?.toInt() ?? -1,
      canExpense: json['canExpense'] as bool? ?? false,
      canIncome: json['canIncome'] as bool? ?? false,
      canTransfer: json['canTransfer'] as bool? ?? false,
      enable: json['enable'] as bool? ?? true,
      sort: (json['sort'] as num?)?.toInt() ?? 0,
      remark: json['remark']?.toString(),
      icon: json['icon']?.toString(),
      children: (json['children'] as List? ?? [])
          .map((e) => TagNode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tagId': tagId,
      'id': id,
      'tagName': tagName,
      'bookId': bookId,
      'parentId': parentId,
      'canExpense': canExpense,
      'canIncome': canIncome,
      'canTransfer': canTransfer,
      'enable': enable,
      'sort': sort,
      'remark': remark,
      'icon': icon,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }

  TagNode copyWith({
    int? tagId,
    int? id,
    String? tagName,
    int? bookId,
    int? parentId,
    bool? canExpense,
    bool? canIncome,
    bool? canTransfer,
    bool? enable,
    int? sort,
    String? remark,
    String? icon,
    List<TagNode>? children,
  }) {
    return TagNode(
      tagId: tagId ?? this.tagId,
      id: id ?? this.id,
      tagName: tagName ?? this.tagName,
      bookId: bookId ?? this.bookId,
      parentId: parentId ?? this.parentId,
      canExpense: canExpense ?? this.canExpense,
      canIncome: canIncome ?? this.canIncome,
      canTransfer: canTransfer ?? this.canTransfer,
      enable: enable ?? this.enable,
      sort: sort ?? this.sort,
      remark: remark ?? this.remark,
      icon: icon ?? this.icon,
      children: children ?? this.children,
    );
  }
}

class TagPageData {
  final int total;
  final List<TagNode> rows;

  TagPageData({required this.total, required this.rows});

  factory TagPageData.fromJson(Map<String, dynamic> json) {
    final total = json['total'] as int? ?? 0;
    final rowsList = (json['rows'] as List? ?? [])
        .map((e) => TagNode.fromJson(e as Map<String, dynamic>))
        .toList();
    return TagPageData(total: total, rows: rowsList);
  }
}