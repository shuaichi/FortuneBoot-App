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
  accountRequired,
  orderRequired,
  titleRequired,
}

class BillEditorState extends Equatable {
  final EditorStatus status;
  final String? loadError;
  final FxFailure? loadFailure;

  final String mode; // new | edit | copy
  final int? billId;
  final bool lockBillType;

  final FxBillType billType;

  /// 转账单一金额。
  final double transferAmount;

  /// 分类拆分行（支出/收入/垫付/报销）。
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

  final List<ExtraRow> extras;
  final List<BillAttachment> attachments;

  final String title;
  final bool titleTouched; // 用户是否手改过标题
  final String remark;
  final bool confirm;
  final bool include;

  /// 选项数据。
  final EditorOptions options;

  final SubmitStatus submitStatus;

  /// 后端/异常错误文案（仅保留兼容，不写入原始异常）。
  final String? submitError;
  final FxFailure? submitFailure;

  /// 本地校验失败（语义枚举，展示层本地化）。
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

  // ---- 派生 ----

  int get billTypeValue => billType.value;

  bool get isTransfer => billType == FxBillType.transfer;
  bool get isExpense => billType == FxBillType.expense;
  bool get isIncome => billType == FxBillType.income;
  bool get isAdvanceOrReimburse =>
      billType == FxBillType.advance || billType == FxBillType.reimburse;

  bool get usesCategorySplit => !isTransfer;
  bool get showSingleAccount => !isTransfer;
  bool get showPayee => isExpense || isIncome || isAdvanceOrReimburse;
  bool get showOrder => isAdvanceOrReimburse;
  bool get showExtras => isExpense || isTransfer;

  /// 分类拆分总额（支出/收入/垫付/报销）。
  double get categoryTotal =>
      categoryRows.fold<double>(0, (s, r) => s + r.amount);

  /// 展示大金额。
  double get displayAmount => isTransfer ? transferAmount : categoryTotal;

  /// 首个有效分类名（供默认标题）。
  String get firstCategoryName {
    for (final r in categoryRows) {
      final n = r.categoryName;
      if (n != null && n.isNotEmpty) return n;
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

  /// 转账默认标题：收款信用卡→还款；转出微信/支付宝→提现；转出信用卡→提现；其余→转账。
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

  /// 未手填时展示/提交的默认标题。
  String get suggestedTitle {
    if (isTransfer) return suggestedTransferTitle;
    return firstCategoryName;
  }

  /// 校验：可提交则返回 null，否则返回语义化错误（展示层本地化文案）。
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
    } else {
      if (categoryRows.isEmpty) return BillValidationError.categoryRequired;
      for (final r in categoryRows) {
        if (r.categoryId == null) {
          return BillValidationError.categorySelectRequired;
        }
        if (r.amount == 0) return BillValidationError.categoryAmountPositive;
      }
      if (accountId == null) return BillValidationError.accountRequired;
      if (showOrder && orderId == null) {
        return BillValidationError.orderRequired;
      }
    }
    final t = effectiveTitle;
    if (t.isEmpty) return BillValidationError.titleRequired;
    return null;
  }

  bool get canSubmit => validationError == null;

  /// 实际提交用标题（用户未改则回退分类名或转账默认标题）。
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
