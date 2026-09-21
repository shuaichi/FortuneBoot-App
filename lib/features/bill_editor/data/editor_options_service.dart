import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';

/// 账户选项（按 can* 过滤可用性）。
class AccountOption {
  final int? accountId;
  final String? accountName;
  final bool canExpense;
  final bool canIncome;
  final bool canTransferOut;
  final bool canTransferIn;
  final String? currencyCode;

  /// 账户类型（AccountTypeEnum：1现金 2信用卡 3资产 4贷款）。
  final int? accountType;

  /// 同类型内排序权重。
  final int? sort;

  const AccountOption({
    this.accountId,
    this.accountName,
    this.canExpense = false,
    this.canIncome = false,
    this.canTransferOut = false,
    this.canTransferIn = false,
    this.currencyCode,
    this.accountType,
    this.sort,
  });

  factory AccountOption.fromJson(Map<String, dynamic> json) => AccountOption(
    accountId: FxApi.asId(json['accountId']),
    accountName: json['accountName']?.toString(),
    canExpense: FxApi.asBool(json['canExpense']),
    canIncome: FxApi.asBool(json['canIncome']),
    canTransferOut: FxApi.asBool(json['canTransferOut']),
    canTransferIn: FxApi.asBool(json['canTransferIn']),
    currencyCode: json['currencyCode']?.toString(),
    accountType: FxApi.asId(json['accountType']),
    sort: FxApi.asId(json['sort']),
  );
}

/// 分类树节点（categoryType 1支出/2收入）。
class CategoryNode {
  final int? categoryId;
  final String? categoryName;
  final int? categoryType;
  final List<CategoryNode> children;

  const CategoryNode({
    this.categoryId,
    this.categoryName,
    this.categoryType,
    this.children = const [],
  });

  bool get isLeaf => children.isEmpty;

  factory CategoryNode.fromJson(Map<String, dynamic> json) => CategoryNode(
    categoryId: FxApi.asId(json['categoryId']),
    categoryName: json['categoryName']?.toString(),
    categoryType: FxApi.asId(json['categoryType']),
    children: _mapNodes(json['children'], CategoryNode.fromJson),
  );

  /// 扁平化（含分组与叶子），供选择器铺开展示。
  List<CategoryNode> flatten() {
    final out = <CategoryNode>[];
    void walk(CategoryNode n) {
      out.add(n);
      for (final c in n.children) {
        walk(c);
      }
    }

    for (final c in children) {
      walk(c);
    }
    return out;
  }
}

/// 标签树节点。
class TagNode {
  final int? tagId;
  final String? tagName;
  final bool canExpense;
  final bool canIncome;
  final bool canTransfer;
  final List<TagNode> children;

  const TagNode({
    this.tagId,
    this.tagName,
    this.canExpense = true,
    this.canIncome = true,
    this.canTransfer = true,
    this.children = const [],
  });

  factory TagNode.fromJson(Map<String, dynamic> json) => TagNode(
    tagId: FxApi.asId(json['tagId']),
    tagName: json['tagName']?.toString(),
    canExpense: FxApi.asBool(json['canExpense'], orElse: true),
    canIncome: FxApi.asBool(json['canIncome'], orElse: true),
    canTransfer: FxApi.asBool(json['canTransfer'], orElse: true),
    children: _mapNodes(json['children'], TagNode.fromJson),
  );

  /// 扁平化所有节点（含分组），供多选铺开。
  List<TagNode> flattenAll() {
    final out = <TagNode>[];
    void walk(TagNode n) {
      out.add(n);
      for (final c in n.children) {
        walk(c);
      }
    }

    walk(this);
    return out;
  }
}

/// 成员选项。
class MemberOption {
  final int? memberId;
  final String? memberName;

  const MemberOption({this.memberId, this.memberName});

  factory MemberOption.fromJson(Map<String, dynamic> json) => MemberOption(
    memberId: FxApi.asId(json['memberId']),
    memberName: json['memberName']?.toString(),
  );
}

/// 交易对象选项。
class PayeeOption {
  final int? payeeId;
  final String? payeeName;
  final bool canExpense;
  final bool canIncome;

  const PayeeOption({
    this.payeeId,
    this.payeeName,
    this.canExpense = true,
    this.canIncome = true,
  });

  factory PayeeOption.fromJson(Map<String, dynamic> json) => PayeeOption(
    payeeId: FxApi.asId(json['payeeId']),
    payeeName: json['payeeName']?.toString(),
    canExpense: FxApi.asBool(json['canExpense'], orElse: true),
    canIncome: FxApi.asBool(json['canIncome'], orElse: true),
  );
}

/// 使用中单据选项（垫付/报销关联）。
class OrderOption {
  final int? orderId;
  final String? title;
  final int? type;
  final String? typeDesc;

  const OrderOption({this.orderId, this.title, this.type, this.typeDesc});

  bool get isReimbursementOrder => type == FinanceOrderType.reimbursement.value;

  factory OrderOption.fromJson(Map<String, dynamic> json) => OrderOption(
    orderId: FxApi.asId(json['orderId']),
    title: json['title']?.toString(),
    type: FxApi.asId(json['type']),
    typeDesc: json['typeDesc']?.toString(),
  );
}

/// 一次并发拉取的全部选项数据集合。
class EditorOptions {
  final List<AccountOption> accounts;
  final List<CategoryNode> expenseCategories;
  final List<CategoryNode> incomeCategories;
  final List<TagNode> tags;
  final List<MemberOption> members;
  final List<PayeeOption> payees;
  final List<OrderOption> orders;

  const EditorOptions({
    this.accounts = const [],
    this.expenseCategories = const [],
    this.incomeCategories = const [],
    this.tags = const [],
    this.members = const [],
    this.payees = const [],
    this.orders = const [],
  });
}

List<T> _mapNodes<T>(dynamic v, T Function(Map<String, dynamic>) f) {
  if (v is List) {
    return v
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => f(Map<String, dynamic>.from(e)))
        .toList();
  }
  return const [];
}

/// BillEditor 选项数据服务：拉取分类/账户/标签/成员/交易对象/单据。
class EditorOptionsService {
  final FxApi _api = FxApi.instance;

  static List<OrderOption> reimbursementOrders(Iterable<OrderOption> orders) =>
      orders.where((order) => order.isReimbursementOrder).toList();

  static List<T> _list<T>(dynamic data, T Function(Map<String, dynamic>) f) {
    if (data is List) {
      return data
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => f(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  /// 分类树（billType: 1支出 / 2收入）。
  Future<List<CategoryNode>> getCategories({
    required int bookId,
    required int billType,
  }) async {
    final data = await _api.get(
      '/fortune/category/$bookId/getEnableList',
      query: {'billType': billType},
    );
    return _list(data, CategoryNode.fromJson);
  }

  Future<List<AccountOption>> getAccounts(int groupId) async {
    final data = await _api.get('/fortune/account/$groupId/getEnableList');
    return _list(data, AccountOption.fromJson);
  }

  Future<List<TagNode>> getTags(int bookId) async {
    final data = await _api.get(
      '/fortune/tag/$bookId/getEnableList',
      query: {'billType': ''},
    );
    return _list(data, TagNode.fromJson);
  }

  Future<List<MemberOption>> getMembers(int bookId) async {
    final data = await _api.get('/fortune/member/$bookId/getEnableList');
    return _list(data, MemberOption.fromJson);
  }

  Future<List<PayeeOption>> getPayees(int bookId) async {
    final data = await _api.get(
      '/fortune/payee/$bookId/getEnableList',
      query: {'billType': ''},
    );
    return _list(data, PayeeOption.fromJson);
  }

  Future<List<OrderOption>> getUsingOrders(int bookId) async {
    final data = await _api.get(
      '/fortune/finance/order/$bookId/getUsingFinanceOrderList',
    );
    return reimbursementOrders(_list(data, OrderOption.fromJson));
  }

  /// 并发拉取全部选项。
  Future<EditorOptions> loadAll({
    required int bookId,
    required int groupId,
  }) async {
    final results = await Future.wait([
      getAccounts(groupId),
      getCategories(bookId: bookId, billType: 1),
      getCategories(bookId: bookId, billType: 2),
      getTags(bookId),
      getMembers(bookId),
      getPayees(bookId),
      getUsingOrders(bookId),
    ]);
    return EditorOptions(
      accounts: results[0] as List<AccountOption>,
      expenseCategories: results[1] as List<CategoryNode>,
      incomeCategories: results[2] as List<CategoryNode>,
      tags: results[3] as List<TagNode>,
      members: results[4] as List<MemberOption>,
      payees: results[5] as List<PayeeOption>,
      orders: results[6] as List<OrderOption>,
    );
  }
}
