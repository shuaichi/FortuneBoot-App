part of 'bill_editor_bloc.dart';

enum EditorStatus { loading, ready, error }

enum SubmitStatus { idle, submitting, success, failure }

/// 账单编辑校验错误（语义枚举；文案在展示层本地化）。
enum BillValidationError {
  transferAmountRequired,
  transferFromRequired,
  transferToRequired,
  transferSameAccount,
  categoryRequired,
  categorySelectRequired,
  categoryAmountPositive,
  amountRequired,
  accountRequired,
  orderRequired,
  orderUnavailable,
  writeOffReasonRequired,
  titleRequired,
  extraCategoryRequired,
  extraCategoryNotInSplit,
  transferExtraAccountSideInvalid,
}

class BillEditorState extends Equatable {
  final EditorStatus status;
  final String? loadError;
  final FxFailure? loadFailure;

  final String mode; // new | edit | copy
  final int? billId;
  final bool lockBillType;
  final FxBillType billType;

  final double transferAmount;
  final int singleAmountCents;
  final List<CategoryAmountRow> categoryRows;

  final int? accountId;
  final String? accountName;
  final int? toAccountId;
  final String? toAccountName;

  final int? payeeId;
  final String? payeeName;

  final DateTime tradeTime;
  final List<int> tagIds;
  final List<String> tagNames;
  final List<int> memberIds;
  final List<String> memberNames;

  final int? orderId;
  final String? orderTitle;
  final int? presetBookId;
  final FinanceOrderComponent? orderComponent;
  final int? expectedOrderVersion;
  final bool lockOrderContext;

  final List<ExtraRow> extras;
  final List<BillAttachment> attachments;

  final String title;
  final bool titleTouched;
  final String remark;
  final bool confirm;
  final bool include;

  final EditorOptions options;
  final SubmitStatus submitStatus;
  final String? submitError;
  final FxFailure? submitFailure;
  final BillValidationError? validationFailure;

  const BillEditorState({
    this.status = EditorStatus.loading,
    this.loadError,
    this.loadFailure,
    this.mode = 'new',
    this.billId,
    this.lockBillType = false,
    this.billType = FxBillType.expense,
    this.transferAmount = 0,
    this.singleAmountCents = 0,
    this.categoryRows = const [CategoryAmountRow()],
    this.accountId,
    this.accountName,
    this.toAccountId,
    this.toAccountName,
    this.payeeId,
    this.payeeName,
    required this.tradeTime,
    this.tagIds = const [],
    this.tagNames = const [],
    this.memberIds = const [],
    this.memberNames = const [],
    this.orderId,
    this.orderTitle,
    this.presetBookId,
    this.orderComponent,
    this.expectedOrderVersion,
    this.lockOrderContext = false,
    this.extras = const [],
    this.attachments = const [],
    this.title = '',
    this.titleTouched = false,
    this.remark = '',
    this.confirm = true,
    this.include = true,
    this.options = const EditorOptions(),
    this.submitStatus = SubmitStatus.idle,
    this.submitError,
    this.submitFailure,
    this.validationFailure,
  });

  int get billTypeValue => billType.value;

  bool get isTransfer => billType == FxBillType.transfer;
  bool get isExpense => billType == FxBillType.expense;
  bool get isIncome => billType == FxBillType.income;
  bool get isAdvanceOrReimburse =>
      billType == FxBillType.advance || billType == FxBillType.reimburse;
  bool get isPrincipalSingleAmount =>
      billType == FxBillType.loanOut ||
      billType == FxBillType.loanRecover ||
      billType == FxBillType.loanIn ||
      billType == FxBillType.loanRepay;
  bool get isWriteOff => orderComponent == FinanceOrderComponent.writeOff;

  /// 7—12，或由单据详情带入的 1/2 附属组件，都必须走 V2 写入口。
  bool get isOrderFlow =>
      isAdvanceOrReimburse ||
      isPrincipalSingleAmount ||
      orderComponent != null;

  bool get usesIncomeAssociations =>
      isIncome ||
      billType == FxBillType.reimburse ||
      billType == FxBillType.loanRecover ||
      billType == FxBillType.loanIn;

  bool get showSingleAmount => isPrincipalSingleAmount;
  bool get showCategorySplit => !isTransfer && !showSingleAmount;
  bool get showAccount => !isTransfer && !isWriteOff;
  bool get showPayee => !isTransfer && !isWriteOff;
  bool get showOrder => isOrderFlow;
  bool get showExtras =>
      (isExpense || isTransfer) && !isOrderFlow;
  bool get confirmLocked => isWriteOff;
  bool get includeLocked => isOrderFlow;

  /// 单据关联流水的服务端 include 规则：本金 false，附属组件 true。
  bool get effectiveInclude =>
      isOrderFlow
      ? !(orderComponent == FinanceOrderComponent.principal ||
            isPrincipalSingleAmount ||
            isAdvanceOrReimburse)
      : include;

  int get categoryTotalCents =>
      categoryRows.fold<int>(0, (sum, row) => sum + row.amountCents);

  /// 分类拆分总额（支出/收入/垫付/报销）。
  double get categoryTotal =>
      isOrderFlow ? categoryTotalCents / 100 : categoryRows.fold<double>(
        0,
        (sum, row) => sum + row.amount,
      );

  /// 展示大金额。仅用于 UI，不参与新单据提交计算。
  double get displayAmount =>
      showSingleAmount
      ? singleAmountCents / 100
      : isTransfer
      ? transferAmount
      : categoryTotal;

  List<CategoryAmountRow> get extraCategoryRows => categoryRows
      .where(
        (row) =>
            row.categoryId != null &&
            extraCategoryIds.contains(row.categoryId),
      )
      .toList(growable: false);

  Set<int> get extraCategoryIds => categoryRows
      .where((row) => row.categoryId != null)
      .map((row) => row.categoryId!)
      .toSet();

  Set<int> get _extraCategoryIds => extraCategoryRows
      .map((row) => row.categoryId!)
      .toSet();

  bool get hasExtraCategories => extraCategoryRows.isNotEmpty;

  static bool isValidTransferAccountSide(int accountSide) =>
      accountSide == 1 || accountSide == 2;

  String get firstCategoryName {
    for (final row in categoryRows) {
      final name = row.categoryName;
      if (name != null && name.isNotEmpty) return name;
    }
    return '';
  }

  int? _accountTypeOf(int? id) => _accountOf(id)?.accountType;

  AccountOption? _accountOf(int? id) {
    if (id == null) return null;
    for (final account in options.accounts) {
      if (account.accountId == id) return account;
    }
    return null;
  }

  String get suggestedTransferTitle {
    final toType = _accountTypeOf(toAccountId);
    if (toType == AccountTypeMeta.credit.id) return '还款';
    final from = _accountOf(accountId);
    final brand = BankBrand.resolve(
      accountName: from?.accountName,
      cardNo: from?.cardNo,
    );
    if (brand?.id == BankBrand.wechat.id) return '微信提现';
    if (brand?.id == BankBrand.alipay.id) return '支付宝提现';
    final fromType = from?.accountType;
    if (fromType == AccountTypeMeta.credit.id) return '提现';
    if (fromType == AccountTypeMeta.cash.id) return '转账';
    return '转账';
  }

  String get suggestedTitle {
    if (isTransfer) return suggestedTransferTitle;
    if (showSingleAmount) return billType.label;
    return firstCategoryName;
  }

  FinanceOrderType? get orderTypeOfSelection {
    for (final order in options.orders) {
      if (order.orderId == orderId) {
        return FinanceOrderType.fromValue(order.type);
      }
    }
    return null;
  }

  bool get _selectedOrderEnabled => options.orders.any(
    (order) => order.orderId == orderId && order.enabled,
  );

  BillValidationError? get validationError {
    if (isTransfer) {
      if (transferAmount == 0) {
        return BillValidationError.transferAmountRequired;
      }
      if (accountId == null) return BillValidationError.transferFromRequired;
      if (toAccountId == null) return BillValidationError.transferToRequired;
      if (accountId == toAccountId) {
        return BillValidationError.transferSameAccount;
      }
      for (final extra in extras.where((extra) => extra.amount != 0)) {
        if (!isValidTransferAccountSide(extra.accountSide)) {
          return BillValidationError.transferExtraAccountSideInvalid;
        }
      }
    } else if (showSingleAmount) {
      if (singleAmountCents <= 0) return BillValidationError.amountRequired;
      if (orderId == null) return BillValidationError.orderRequired;
    } else {
      if (isWriteOff && remark.trim().isEmpty) {
        return BillValidationError.writeOffReasonRequired;
      }
      if (categoryRows.isEmpty) return BillValidationError.categoryRequired;
      for (final row in categoryRows) {
        if (row.categoryId == null) {
          return BillValidationError.categorySelectRequired;
        }
        final amountInvalid = isOrderFlow
            ? row.amountCents <= 0
            : row.amount == 0;
        if (amountInvalid) {
          return BillValidationError.categoryAmountPositive;
        }
      }
      if (showAccount && accountId == null) {
        return BillValidationError.accountRequired;
      }
      if (showOrder && orderId == null) {
        return BillValidationError.orderRequired;
      }
      if (showOrder && orderId != null && !_selectedOrderEnabled) {
        return BillValidationError.orderUnavailable;
      }
      final categoryIds = _extraCategoryIds;
      for (final extra in extras.where((extra) => extra.amount != 0)) {
        if (extra.categoryId == null) {
          return BillValidationError.extraCategoryRequired;
        }
        if (!categoryIds.contains(extra.categoryId)) {
          return BillValidationError.extraCategoryNotInSplit;
        }
      }
    }
    final effectiveTitleValue = effectiveTitle;
    if (effectiveTitleValue.isEmpty) return BillValidationError.titleRequired;
    return null;
  }

  bool get canSubmit => validationError == null;

  String get effectiveTitle {
    if (title.isNotEmpty) return title;
    if (!titleTouched) {
      final suggested = suggestedTitle;
      if (suggested.isNotEmpty) return suggested;
    }
    return title;
  }

  BillEditorState copyWith({
    EditorStatus? status,
    String? loadError,
    FxFailure? loadFailure,
    String? mode,
    int? billId,
    bool? lockBillType,
    FxBillType? billType,
    double? transferAmount,
    int? singleAmountCents,
    List<CategoryAmountRow>? categoryRows,
    int? accountId,
    String? accountName,
    bool clearAccount = false,
    int? toAccountId,
    String? toAccountName,
    bool clearToAccount = false,
    int? payeeId,
    String? payeeName,
    bool clearPayee = false,
    DateTime? tradeTime,
    List<int>? tagIds,
    List<String>? tagNames,
    List<int>? memberIds,
    List<String>? memberNames,
    int? orderId,
    String? orderTitle,
    bool clearOrder = false,
    int? presetBookId,
    FinanceOrderComponent? orderComponent,
    bool clearOrderComponent = false,
    int? expectedOrderVersion,
    bool clearExpectedOrderVersion = false,
    bool? lockOrderContext,
    List<ExtraRow>? extras,
    List<BillAttachment>? attachments,
    String? title,
    bool? titleTouched,
    String? remark,
    bool? confirm,
    bool? include,
    EditorOptions? options,
    SubmitStatus? submitStatus,
    String? submitError,
    FxFailure? submitFailure,
    BillValidationError? validationFailure,
  }) {
    return BillEditorState(
      status: status ?? this.status,
      loadError: loadError,
      loadFailure: loadFailure,
      mode: mode ?? this.mode,
      billId: billId ?? this.billId,
      lockBillType: lockBillType ?? this.lockBillType,
      billType: billType ?? this.billType,
      transferAmount: transferAmount ?? this.transferAmount,
      singleAmountCents: singleAmountCents ?? this.singleAmountCents,
      categoryRows: categoryRows ?? this.categoryRows,
      accountId: clearAccount ? null : (accountId ?? this.accountId),
      accountName: clearAccount ? null : (accountName ?? this.accountName),
      toAccountId: clearToAccount ? null : (toAccountId ?? this.toAccountId),
      toAccountName: clearToAccount
          ? null
          : (toAccountName ?? this.toAccountName),
      payeeId: clearPayee ? null : (payeeId ?? this.payeeId),
      payeeName: clearPayee ? null : (payeeName ?? this.payeeName),
      tradeTime: tradeTime ?? this.tradeTime,
      tagIds: tagIds ?? this.tagIds,
      tagNames: tagNames ?? this.tagNames,
      memberIds: memberIds ?? this.memberIds,
      memberNames: memberNames ?? this.memberNames,
      orderId: clearOrder ? null : (orderId ?? this.orderId),
      orderTitle: clearOrder ? null : (orderTitle ?? this.orderTitle),
      presetBookId: presetBookId ?? this.presetBookId,
      orderComponent: clearOrderComponent
          ? null
          : (orderComponent ?? this.orderComponent),
      expectedOrderVersion: clearExpectedOrderVersion
          ? null
          : (expectedOrderVersion ?? this.expectedOrderVersion),
      lockOrderContext: lockOrderContext ?? this.lockOrderContext,
      extras: extras ?? this.extras,
      attachments: attachments ?? this.attachments,
      title: title ?? this.title,
      titleTouched: titleTouched ?? this.titleTouched,
      remark: remark ?? this.remark,
      confirm: confirm ?? this.confirm,
      include: include ?? this.include,
      options: options ?? this.options,
      submitStatus: submitStatus ?? this.submitStatus,
      submitError: submitError,
      submitFailure: submitFailure,
      validationFailure: validationFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    loadError,
    loadFailure,
    mode,
    billId,
    lockBillType,
    billType,
    transferAmount,
    singleAmountCents,
    categoryRows,
    accountId,
    accountName,
    toAccountId,
    toAccountName,
    payeeId,
    payeeName,
    tradeTime,
    tagIds,
    tagNames,
    memberIds,
    memberNames,
    orderId,
    orderTitle,
    presetBookId,
    orderComponent,
    expectedOrderVersion,
    lockOrderContext,
    extras,
    attachments,
    title,
    titleTouched,
    remark,
    confirm,
    include,
    options,
    submitStatus,
    submitError,
    submitFailure,
    validationFailure,
  ];
}
