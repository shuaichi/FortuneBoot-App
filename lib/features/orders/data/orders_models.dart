import 'package:fortuneboot/core/errors/fx_failure.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/orders/data/order_money.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';

/// C08 单据类型：1 费用报销单、2 债权单、3 债务单。
enum FinanceOrderType {
  reimbursement(1),
  receivable(2),
  payable(3);

  const FinanceOrderType(this.value);

  final int value;

  static FinanceOrderType? fromValue(int? value) {
    for (final type in FinanceOrderType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

/// C08 单据状态：100 草稿、200 进行中、1000 已归档。
enum FinanceOrderStatus {
  draft(100),
  using(200),
  closed(1000);

  const FinanceOrderStatus(this.value);

  final int value;

  static FinanceOrderStatus? fromValue(int? value) {
    for (final status in FinanceOrderStatus.values) {
      if (status.value == value) return status;
    }
    return null;
  }
}

/// C08 V2 单据生命周期动作；using 同时保留旧页面适配。
enum FinanceOrderTransitionAction {
  using('using'),
  close('close'),
  reopen('reopen');

  const FinanceOrderTransitionAction(this.value);

  final String value;
}

/// C08 单据流水组件白名单。
enum FinanceOrderComponent {
  principal('PRINCIPAL'),
  interest('INTEREST'),
  fee('FEE'),
  writeOff('WRITE_OFF');

  const FinanceOrderComponent(this.value);

  final String value;

  static FinanceOrderComponent? fromValue(String? value) {
    for (final component in FinanceOrderComponent.values) {
      if (component.value == value) return component;
    }
    return null;
  }
}

/// V2 分页结果。ID 兼容数字和数字字符串。
class FinanceOrderPage {
  final List<FinanceOrderDetail> rows;
  final int total;
  const FinanceOrderPage({this.rows = const [], this.total = 0});

  factory FinanceOrderPage.fromJson(dynamic data) {
    final map = _asMap(data);
    final rows = _mapList(map?['rows'], FinanceOrderDetail.fromJson);
    return FinanceOrderPage(
      rows: rows,
      total: FxApi.asId(map?['total']) ?? rows.length,
    );
  }
}

/// 单据详情 / 列表行。
class FinanceOrderDetail {
  final int? orderId;
  final int? bookId;
  final String? title;
  final FinanceOrderType? type;
  final String? typeDesc;
  final int? status;
  final String? statusDesc;
  final int? counterpartyId;
  final String? counterpartyName;
  final String? currencyCode;
  final DateTime? dueDate;
  final DateTime? submitTime;
  final DateTime? closeTime;
  final String? remark;
  final int? version;
  final String? reconciliationStatus;
  final String? reconciliationNote;
  final OrderMoney? outAmount;
  final OrderMoney? inAmount;
  final OrderMoney? issuedAmount;
  final OrderMoney? settledAmount;
  final OrderMoney? adjustedAmount;
  final OrderMoney? pendingAmount;
  final OrderMoney? interestIncome;
  final OrderMoney? interestExpense;
  final OrderMoney? feeAmount;
  final OrderMoney? netCostOrIncome;
  final String? settlementState;
  final int pendingEntryCount;
  final bool overdue;
  final bool canEdit;
  final bool canDelete;
  final bool canClose;
  final bool canReopen;
  final List<String> allowedEntryActions;
  final String? readOnlyReason;

  const FinanceOrderDetail({
    this.orderId,
    this.bookId,
    this.title,
    this.type,
    this.typeDesc,
    this.status,
    this.statusDesc,
    this.counterpartyId,
    this.counterpartyName,
    this.currencyCode,
    this.dueDate,
    this.submitTime,
    this.closeTime,
    this.remark,
    this.version,
    this.reconciliationStatus,
    this.reconciliationNote,
    this.outAmount,
    this.inAmount,
    this.issuedAmount,
    this.settledAmount,
    this.adjustedAmount,
    this.pendingAmount,
    this.interestIncome,
    this.interestExpense,
    this.feeAmount,
    this.netCostOrIncome,
    this.settlementState,
    this.pendingEntryCount = 0,
    this.overdue = false,
    this.canEdit = false,
    this.canDelete = false,
    this.canClose = false,
    this.canReopen = false,
    this.allowedEntryActions = const [],
    this.readOnlyReason,
  });

  factory FinanceOrderDetail.fromJson(Map<String, dynamic> json) {
    final typeValue = FxApi.asId(json['type']);
    final type = FinanceOrderType.fromValue(typeValue);
    if (typeValue != null && type == null) {
      throw const FxFailure(kind: FxFailureKind.invalidResponse);
    }
    return FinanceOrderDetail(
      orderId: FxApi.asId(json['orderId']),
      bookId: FxApi.asId(json['bookId']),
      title: _string(json['title']),
      type: type,
      typeDesc: _string(json['typeDesc']),
      status: FxApi.asId(json['status']),
      statusDesc: _string(json['statusDesc']),
      counterpartyId: FxApi.asId(json['counterpartyId']),
      counterpartyName: _string(json['counterpartyName']),
      currencyCode: _string(json['currencyCode']),
      dueDate: _date(json['dueDate']),
      submitTime: _dateTime(json['submitTime']),
      closeTime: _dateTime(json['closeTime']),
      remark: _string(json['remark']),
      version: FxApi.asId(json['version']),
      reconciliationStatus: _string(json['reconciliationStatus']),
      reconciliationNote: _string(json['reconciliationNote']),
      outAmount: _amount(json['outAmount']),
      inAmount: _amount(json['inAmount']),
      issuedAmount: _amount(json['issuedAmount']),
      settledAmount: _amount(json['settledAmount']),
      adjustedAmount: _amount(json['adjustedAmount']),
      pendingAmount: _amount(json['pendingAmount']),
      interestIncome: _amount(json['interestIncome']),
      interestExpense: _amount(json['interestExpense']),
      feeAmount: _amount(json['feeAmount']),
      netCostOrIncome: _amount(json['netCostOrIncome']),
      settlementState: _string(json['settlementState']),
      pendingEntryCount: FxApi.asId(json['pendingEntryCount']) ?? 0,
      overdue: FxApi.asBool(json['overdue']),
      canEdit: FxApi.asBool(json['canEdit']),
      canDelete: FxApi.asBool(json['canDelete']),
      canClose: FxApi.asBool(json['canClose']),
      canReopen: FxApi.asBool(json['canReopen']),
      allowedEntryActions: _stringList(json['allowedEntryActions']),
      readOnlyReason: _string(json['readOnlyReason']),
    );
  }

  bool get isDraft => status == FinanceOrderStatus.draft.value;
  bool get isUsing => status == FinanceOrderStatus.using.value;
  bool get isClosed => status == FinanceOrderStatus.closed.value;
  bool get isReimbursementOrder => type == FinanceOrderType.reimbursement;
  bool get isReviewRequired =>
      reconciliationStatus == 'REVIEW_REQUIRED';
}

/// 旧订单页面兼容 VO。新代码必须使用 [FinanceOrderDetail]。
class FortuneFinanceOrderVo {
  final int? orderId;
  final int? bookId;
  final String? title;
  final FinanceOrderType? type;
  final String? typeDesc;
  final double? outAmount;
  final double? inAmount;
  final int? status;
  final String? statusDesc;
  final String? submitTime;
  final String? closeTime;
  final String? remark;

  const FortuneFinanceOrderVo({
    this.orderId,
    this.bookId,
    this.title,
    this.type,
    this.typeDesc,
    this.outAmount,
    this.inAmount,
    this.status,
    this.statusDesc,
    this.submitTime,
    this.closeTime,
    this.remark,
  });

  bool get isInitial => status == FinanceOrderStatus.draft.value;
  bool get isUsing => status == FinanceOrderStatus.using.value;
  bool get isClosed => status == FinanceOrderStatus.closed.value;
  bool get isReimbursementOrder => type == FinanceOrderType.reimbursement;

  FinanceOrderTransitionAction? get nextTransitionAction {
    if (isInitial) return FinanceOrderTransitionAction.using;
    if (isUsing) return FinanceOrderTransitionAction.close;
    if (isClosed) return FinanceOrderTransitionAction.reopen;
    return null;
  }

  factory FortuneFinanceOrderVo.fromJson(Map<String, dynamic> json) {
    final outAmount = _amount(json['outAmount']);
    final inAmount = _amount(json['inAmount']);
    return FortuneFinanceOrderVo(
      orderId: FxApi.asId(json['orderId']),
      bookId: FxApi.asId(json['bookId']),
      title: _string(json['title']),
      type: FinanceOrderType.fromValue(FxApi.asId(json['type'])),
      typeDesc: _string(json['typeDesc']),
      outAmount: outAmount == null ? null : outAmount.cents / 100,
      inAmount: inAmount == null ? null : inAmount.cents / 100,
      status: FxApi.asId(json['status']),
      statusDesc: _string(json['statusDesc']),
      submitTime: _string(json['submitTime']),
      closeTime: _string(json['closeTime']),
      remark: _string(json['remark']),
    );
  }

  factory FortuneFinanceOrderVo.fromDetail(FinanceOrderDetail detail) =>
      FortuneFinanceOrderVo(
        orderId: detail.orderId,
        bookId: detail.bookId,
        title: detail.title,
        type: detail.type,
        typeDesc: detail.typeDesc,
        outAmount: detail.outAmount?.cents == null
            ? null
            : detail.outAmount!.cents / 100,
        inAmount: detail.inAmount?.cents == null
            ? null
            : detail.inAmount!.cents / 100,
        status: detail.status,
        statusDesc: detail.statusDesc,
        submitTime: detail.submitTime?.toString(),
        closeTime: detail.closeTime?.toString(),
        remark: detail.remark,
      );
}

/// 旧订单页面分页兼容类型。
class OrdersPage {
  final List<FortuneFinanceOrderVo> rows;
  final int total;
  const OrdersPage({this.rows = const [], this.total = 0});
}

/// 单据看板汇总。
class FinanceOrderSummary {
  final String? currencyCode;
  final OrderMoney? receivableAmount;
  final OrderMoney? payableAmount;
  final OrderMoney? reimbursementAmount;
  final OrderMoney? overdueReceivableAmount;
  final OrderMoney? overduePayableAmount;
  final OrderMoney? overdueReimbursementAmount;
  final int receivableCount;
  final int payableCount;
  final int reimbursementCount;
  final int pendingEntryCount;
  final int reviewRequiredCount;
  final int orphanLegacyBillCount;
  final DateTime? asOfDate;

  const FinanceOrderSummary({
    this.currencyCode,
    this.receivableAmount,
    this.payableAmount,
    this.reimbursementAmount,
    this.overdueReceivableAmount,
    this.overduePayableAmount,
    this.overdueReimbursementAmount,
    this.receivableCount = 0,
    this.payableCount = 0,
    this.reimbursementCount = 0,
    this.pendingEntryCount = 0,
    this.reviewRequiredCount = 0,
    this.orphanLegacyBillCount = 0,
    this.asOfDate,
  });

  factory FinanceOrderSummary.fromJson(Map<String, dynamic> json) =>
      FinanceOrderSummary(
        currencyCode: _string(json['currencyCode']),
        receivableAmount: _amount(json['receivableAmount']),
        payableAmount: _amount(json['payableAmount']),
        reimbursementAmount: _amount(json['reimbursementAmount']),
        overdueReceivableAmount: _amount(json['overdueReceivableAmount']),
        overduePayableAmount: _amount(json['overduePayableAmount']),
        overdueReimbursementAmount: _amount(json['overdueReimbursementAmount']),
        receivableCount: FxApi.asId(json['receivableCount']) ?? 0,
        payableCount: FxApi.asId(json['payableCount']) ?? 0,
        reimbursementCount: FxApi.asId(json['reimbursementCount']) ?? 0,
        pendingEntryCount: FxApi.asId(json['pendingEntryCount']) ?? 0,
        reviewRequiredCount: FxApi.asId(json['reviewRequiredCount']) ?? 0,
        orphanLegacyBillCount: FxApi.asId(json['orphanLegacyBillCount']) ?? 0,
        asOfDate: _date(json['asOfDate']),
      );
}

/// 单据写操作结果。
class FinanceOrderMutationResult {
  final int? orderId;
  final int? billId;
  final int? version;
  final bool replayed;

  const FinanceOrderMutationResult({
    this.orderId,
    this.billId,
    this.version,
    this.replayed = false,
  });

  factory FinanceOrderMutationResult.fromJson(Map<String, dynamic> json) =>
      FinanceOrderMutationResult(
        orderId: FxApi.asId(json['orderId']),
        billId: FxApi.asId(json['billId']),
        version: FxApi.asId(json['version']),
        replayed: FxApi.asBool(json['replayed']),
      );
}

/// V2 分类金额。
class FinanceOrderCategoryAmount {
  final int? categoryId;
  final String? categoryName;
  final OrderMoney? amount;

  const FinanceOrderCategoryAmount({
    this.categoryId,
    this.categoryName,
    this.amount,
  });

  factory FinanceOrderCategoryAmount.fromJson(Map<String, dynamic> json) =>
      () {
        final rawAmount = json['amount'];
        if (rawAmount == null) {
          throw const FxFailure(kind: FxFailureKind.invalidResponse);
        }
        return FinanceOrderCategoryAmount(
          categoryId: FxApi.asId(json['categoryId']),
          categoryName: _string(json['categoryName']),
          amount: OrderMoney.fromJson(rawAmount),
        );
      }();
}

/// 单据关联流水分页。
class FinanceOrderEntryPage {
  final List<FinanceOrderEntry> rows;
  final int total;
  const FinanceOrderEntryPage({this.rows = const [], this.total = 0});

  factory FinanceOrderEntryPage.fromJson(dynamic data) {
    final map = _asMap(data);
    final rows = _mapList(map?['rows'], FinanceOrderEntry.fromJson);
    return FinanceOrderEntryPage(
      rows: rows,
      total: FxApi.asId(map?['total']) ?? rows.length,
    );
  }
}

/// 单据关联流水。
class FinanceOrderEntry {
  final int? billId;
  final int? bookId;
  final String? bookName;
  final String? title;
  final DateTime? tradeTime;
  final int? accountId;
  final String? accountName;
  final int? orderId;
  final OrderMoney? amount;
  final String? currencyCode;
  final String? toCurrencyCode;
  final OrderMoney? convertedAmount;
  final int? payeeId;
  final String? payeeName;
  final int? billType;
  final int? toAccountId;
  final String? toAccountName;
  final bool confirm;
  final bool include;
  final String? remark;
  final bool hasFile;
  final List<FinanceOrderCategoryAmount> categoryAmountPair;
  final List<BillTag> tagList;
  final List<BillMember> memberList;
  final List<BillExtra> extras;
  final FinanceOrderComponent? orderComponent;
  final int? orderLedgerVersion;
  final bool recycleBin;
  final List<String> allowedActions;
  final String? readOnlyReason;

  const FinanceOrderEntry({
    this.billId,
    this.bookId,
    this.bookName,
    this.title,
    this.tradeTime,
    this.accountId,
    this.accountName,
    this.orderId,
    this.amount,
    this.currencyCode,
    this.toCurrencyCode,
    this.convertedAmount,
    this.payeeId,
    this.payeeName,
    this.billType,
    this.toAccountId,
    this.toAccountName,
    this.confirm = true,
    this.include = true,
    this.remark,
    this.hasFile = false,
    this.categoryAmountPair = const [],
    this.tagList = const [],
    this.memberList = const [],
    this.extras = const [],
    this.orderComponent,
    this.orderLedgerVersion,
    this.recycleBin = false,
    this.allowedActions = const [],
    this.readOnlyReason,
  });

  factory FinanceOrderEntry.fromJson(Map<String, dynamic> json) =>
      FinanceOrderEntry(
        billId: FxApi.asId(json['billId']),
        bookId: FxApi.asId(json['bookId']),
        bookName: _string(json['bookName']),
        title: _string(json['title']),
        tradeTime: _dateTime(json['tradeTime']),
        accountId: FxApi.asId(json['accountId']),
        accountName: _string(json['accountName']),
        orderId: FxApi.asId(json['orderId']),
        amount: _amount(json['amount']),
        currencyCode: _string(json['currencyCode']),
        toCurrencyCode: _string(json['toCurrencyCode']),
        convertedAmount: _amount(json['convertedAmount']),
        payeeId: FxApi.asId(json['payeeId']),
        payeeName: _string(json['payeeName']),
        billType: FxApi.asId(json['billType']),
        toAccountId: FxApi.asId(json['toAccountId']),
        toAccountName: _string(json['toAccountName']),
        confirm: FxApi.asBool(json['confirm'], orElse: true),
        include: FxApi.asBool(json['include'], orElse: true),
        remark: _string(json['remark']),
        hasFile: FxApi.asBool(json['hasFile']),
        categoryAmountPair: _mapList(
          json['categoryAmountPair'],
          FinanceOrderCategoryAmount.fromJson,
        ),
        tagList: _mapList(json['tagList'], BillTag.fromJson),
        memberList: _mapList(json['memberList'], BillMember.fromJson),
        extras: _mapList(json['extras'], BillExtra.fromJson),
        orderComponent: FinanceOrderComponent.fromValue(
          _string(json['orderComponent']),
        ),
        orderLedgerVersion: FxApi.asId(json['orderLedgerVersion']),
        recycleBin: FxApi.asBool(json['recycleBin']),
        allowedActions: _stringList(json['allowedActions']),
        readOnlyReason: _string(json['readOnlyReason']),
      );

  FortuneBillVo toBillVo() => FortuneBillVo(
    billId: billId,
    bookId: bookId,
    title: title,
    tradeTime: tradeTime,
    accountId: accountId,
    accountName: accountName,
    orderId: orderId,
    amountMoney: amount,
    currencyCode: currencyCode,
    toCurrencyCode: toCurrencyCode,
    convertedAmountMoney: convertedAmount,
    payeeId: payeeId,
    payeeName: payeeName,
    billType: billType,
    toAccountId: toAccountId,
    toAccountName: toAccountName,
    confirm: confirm,
    include: include,
    remark: remark,
    hasFile: hasFile,
    categoryAmountPair: categoryAmountPair
        .map(
          (category) => BillCategoryAmount(
            categoryId: category.categoryId,
            categoryName: category.categoryName,
            amountMoney: category.amount,
          ),
        )
        .toList(),
    tagList: tagList,
    memberList: memberList,
    extras: extras,
    orderComponent: orderComponent,
    orderLedgerVersion: orderLedgerVersion,
    recycleBin: recycleBin,
    allowedActions: allowedActions,
    readOnlyReason: readOnlyReason,
  );
}

/// 单据审计分页。
class FinanceOrderAuditPage {
  final List<FinanceOrderAudit> rows;
  final int total;
  const FinanceOrderAuditPage({this.rows = const [], this.total = 0});

  factory FinanceOrderAuditPage.fromJson(dynamic data) {
    final map = _asMap(data);
    final rows = _mapList(map?['rows'], FinanceOrderAudit.fromJson);
    return FinanceOrderAuditPage(
      rows: rows,
      total: FxApi.asId(map?['total']) ?? rows.length,
    );
  }
}

/// 单据操作审计。
class FinanceOrderAudit {
  final int? id;
  final int? orderId;
  final int? billId;
  final String action;
  final int? creatorId;
  final DateTime? createTime;
  final String? beforeJson;
  final String? afterJson;

  const FinanceOrderAudit({
    this.id,
    this.orderId,
    this.billId,
    this.action = '',
    this.creatorId,
    this.createTime,
    this.beforeJson,
    this.afterJson,
  });

  factory FinanceOrderAudit.fromJson(Map<String, dynamic> json) =>
      FinanceOrderAudit(
        id: FxApi.asId(json['id']),
        orderId: FxApi.asId(json['orderId']),
        billId: FxApi.asId(json['billId']),
        action: _string(json['action']) ?? '',
        creatorId: FxApi.asId(json['creatorId']),
        createTime: _dateTime(json['createTime']),
        beforeJson: _string(json['beforeJson']),
        afterJson: _string(json['afterJson']),
      );
}

/// 历史核对报告分页。
class FinanceOrderReconciliationPage {
  final List<FinanceOrderReconciliation> rows;
  final int total;
  const FinanceOrderReconciliationPage({
    this.rows = const [],
    this.total = 0,
  });

  factory FinanceOrderReconciliationPage.fromJson(dynamic data) {
    final map = _asMap(data);
    final rows = _mapList(
      map?['rows'],
      FinanceOrderReconciliation.fromJson,
    );
    return FinanceOrderReconciliationPage(
      rows: rows,
      total: FxApi.asId(map?['total']) ?? rows.length,
    );
  }
}

/// 历史核对报告。
class FinanceOrderReconciliation {
  final int? orderId;
  final int? billId;
  final int? bookId;
  final List<String> issueCodes;
  final int? originalStatus;
  final OrderMoney? originalOutAmount;
  final OrderMoney? originalInAmount;
  final OrderMoney? candidateIssuedAmount;
  final OrderMoney? candidateSettledAmount;
  final OrderMoney? candidatePendingAmount;
  final List<int> accountIds;
  final List<String> currencyCodes;
  final bool cashEffectKnown;
  final String? note;

  const FinanceOrderReconciliation({
    this.orderId,
    this.billId,
    this.bookId,
    this.issueCodes = const [],
    this.originalStatus,
    this.originalOutAmount,
    this.originalInAmount,
    this.candidateIssuedAmount,
    this.candidateSettledAmount,
    this.candidatePendingAmount,
    this.accountIds = const [],
    this.currencyCodes = const [],
    this.cashEffectKnown = false,
    this.note,
  });

  factory FinanceOrderReconciliation.fromJson(Map<String, dynamic> json) =>
      FinanceOrderReconciliation(
        orderId: FxApi.asId(json['orderId']),
        billId: FxApi.asId(json['billId']),
        bookId: FxApi.asId(json['bookId']),
        issueCodes: _stringList(json['issueCodes']),
        originalStatus: FxApi.asId(json['originalStatus']),
        originalOutAmount: _amount(json['originalOutAmount']),
        originalInAmount: _amount(json['originalInAmount']),
        candidateIssuedAmount: _amount(json['candidateIssuedAmount']),
        candidateSettledAmount: _amount(json['candidateSettledAmount']),
        candidatePendingAmount: _amount(json['candidatePendingAmount']),
        accountIds: (json['accountIds'] as List? ?? [])
            .map((id) => FxApi.asId(id))
            .whereType<int>()
            .toList(),
        currencyCodes: _stringList(json['currencyCodes']),
        cashEffectKnown: FxApi.asBool(json['cashEffectKnown']),
        note: _string(json['note']),
      );
}

Map<String, dynamic>? _asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return null;
}

List<T> _mapList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data is! List) return const [];
  return data
      .whereType<Map<dynamic, dynamic>>()
      .map((item) => fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

String? _string(dynamic value) => value?.toString();

List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList();
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

DateTime? _dateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString().replaceFirst(' ', 'T'));
}

OrderMoney? _amount(dynamic value) {
  if (value == null) return null;
  return OrderMoney.fromJson(value);
}
