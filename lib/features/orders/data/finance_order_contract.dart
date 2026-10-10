import 'package:fortuneboot/features/orders/data/order_money.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:intl/intl.dart';

/// C08 V2 流水状态动作。
enum FinanceOrderEntryAction {
  confirm('confirm'),
  unconfirm('unconfirm'),
  voidEntry('void'),
  restore('restore');

  const FinanceOrderEntryAction(this.value);

  final String value;
}

/// 新建单据请求。
class FinanceOrderCreateInput {
  final int bookId;
  final String requestId;
  final String title;
  final FinanceOrderType type;
  final int? counterpartyId;
  final String counterpartyName;
  final DateTime? dueDate;
  final String remark;

  const FinanceOrderCreateInput({
    required this.bookId,
    required this.requestId,
    required this.title,
    required this.type,
    this.counterpartyId,
    required this.counterpartyName,
    this.dueDate,
    this.remark = '',
  });

  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'requestId': requestId,
    'title': title,
    'type': type.value,
    if (counterpartyId != null) 'counterpartyId': counterpartyId,
    'counterpartyName': counterpartyName,
    if (dueDate != null) 'dueDate': DateFormat('yyyy-MM-dd').format(dueDate!),
    'remark': remark,
  };
}

/// 修改单据元数据请求。
class FinanceOrderMetadataInput {
  final int bookId;
  final int orderId;
  final String requestId;
  final int expectedVersion;
  final String title;
  final FinanceOrderType type;
  final int? counterpartyId;
  final String counterpartyName;
  final DateTime? dueDate;
  final String remark;

  const FinanceOrderMetadataInput({
    required this.bookId,
    required this.orderId,
    required this.requestId,
    required this.expectedVersion,
    required this.title,
    required this.type,
    this.counterpartyId,
    required this.counterpartyName,
    this.dueDate,
    this.remark = '',
  });

  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'orderId': orderId,
    'requestId': requestId,
    'expectedVersion': expectedVersion,
    'title': title,
    'type': type.value,
    if (counterpartyId != null) 'counterpartyId': counterpartyId,
    'counterpartyName': counterpartyName,
    if (dueDate != null) 'dueDate': DateFormat('yyyy-MM-dd').format(dueDate!),
    'remark': remark,
  };
}

/// V2 分类金额请求项。金额始终以两位字符串提交。
class FinanceOrderCategoryAmountInput {
  final int categoryId;
  final OrderMoney amount;

  const FinanceOrderCategoryAmountInput({
    required this.categoryId,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'categoryId': categoryId,
    'amount': amount.toApiString(),
  };
}

/// V2 单据关联流水 multipart data 请求。
class FinanceOrderEntryCommandInput {
  static final DateFormat _tradeTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  final int bookId;
  final int orderId;
  final int? billId;
  final String requestId;
  final int expectedVersion;
  final FinanceOrderComponent? orderComponent;
  final String title;
  final DateTime tradeTime;
  final FxBillType billType;
  final bool confirm;
  final bool? include;
  final int? accountId;
  final int? toAccountId;
  final int? payeeId;
  final OrderMoney? amount;
  final List<FinanceOrderCategoryAmountInput> categoryAmountPair;
  final List<int> tagIdList;
  final List<int> memberIdList;
  final String remark;

  const FinanceOrderEntryCommandInput({
    required this.bookId,
    required this.orderId,
    this.billId,
    required this.requestId,
    required this.expectedVersion,
    this.orderComponent,
    required this.title,
    required this.tradeTime,
    required this.billType,
    required this.confirm,
    this.include,
    this.accountId,
    this.toAccountId,
    this.payeeId,
    this.amount,
    this.categoryAmountPair = const [],
    this.tagIdList = const [],
    this.memberIdList = const [],
    this.remark = '',
  });

  FinanceOrderEntryCommandInput copyWith({
    int? bookId,
    int? orderId,
    int? billId,
    String? requestId,
    int? expectedVersion,
    FinanceOrderComponent? orderComponent,
    String? title,
    DateTime? tradeTime,
    FxBillType? billType,
    bool? confirm,
    bool? include,
    int? accountId,
    int? toAccountId,
    int? payeeId,
    OrderMoney? amount,
    List<FinanceOrderCategoryAmountInput>? categoryAmountPair,
    List<int>? tagIdList,
    List<int>? memberIdList,
    String? remark,
  }) => FinanceOrderEntryCommandInput(
    bookId: bookId ?? this.bookId,
    orderId: orderId ?? this.orderId,
    billId: billId ?? this.billId,
    requestId: requestId ?? this.requestId,
    expectedVersion: expectedVersion ?? this.expectedVersion,
    orderComponent: orderComponent ?? this.orderComponent,
    title: title ?? this.title,
    tradeTime: tradeTime ?? this.tradeTime,
    billType: billType ?? this.billType,
    confirm: confirm ?? this.confirm,
    include: include ?? this.include,
    accountId: accountId ?? this.accountId,
    toAccountId: toAccountId ?? this.toAccountId,
    payeeId: payeeId ?? this.payeeId,
    amount: amount ?? this.amount,
    categoryAmountPair: categoryAmountPair ?? this.categoryAmountPair,
    tagIdList: tagIdList ?? this.tagIdList,
    memberIdList: memberIdList ?? this.memberIdList,
    remark: remark ?? this.remark,
  );

  Map<String, dynamic> toJson({bool includeBillId = false}) => {
    'bookId': bookId,
    'orderId': orderId,
    if (includeBillId || billId != null) 'billId': billId,
    'requestId': requestId,
    'expectedVersion': expectedVersion,
    if (orderComponent != null) 'orderComponent': orderComponent!.value,
    'title': title,
    'tradeTime': _tradeTimeFormat.format(tradeTime),
    'billType': billType.value,
    'confirm': confirm,
    if (include != null) 'include': include,
    if (accountId != null) 'accountId': accountId,
    if (toAccountId != null) 'toAccountId': toAccountId,
    if (payeeId != null) 'payeeId': payeeId,
    if (amount != null) 'amount': amount!.toApiString(),
    'categoryAmountPair': categoryAmountPair
        .map((category) => category.toJson())
        .toList(),
    if (tagIdList.isNotEmpty) 'tagIdList': tagIdList,
    if (memberIdList.isNotEmpty) 'memberIdList': memberIdList,
    if (remark.isNotEmpty) 'remark': remark,
  };
}
