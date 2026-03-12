part of 'edit_bill_bloc.dart';

enum EditBillStatus { initial, loading, success, failure, closed, submitFailed }

extension EditBillStatusX on EditBillStatus {
  bool get isLoadingOrInit => [
        EditBillStatus.loading,
        EditBillStatus.initial,
      ].contains(this);
}

final class EditBillState extends Equatable {
  EditBillState({
    this.status = EditBillStatus.initial,
    this.initialBill,
    this.bookList = const [],
    this.expenseAccountList = const [],
    this.transferAccountList = const [],
    this.incomeAccountList = const [],
    this.transferOutAccountList = const [],
    this.payeeList = const [],
    this.tagList = const [],
    this.categoryList = const [],
    this.isNewBill = true,
    required this.editBill,
    this.defaultExpenseAccountId,
    this.defaultIncomeAccountId,
    this.defaultTransferOutAccountId,
    this.defaultTransferInAccountId,
    this.attachments = const [],
  });

  EditBillState.init({
    required int bookId,
    this.status = EditBillStatus.initial,
    this.initialBill,
    this.bookList = const [],
    this.expenseAccountList = const [],
    this.transferAccountList = const [],
    this.incomeAccountList = const [],
    this.transferOutAccountList = const [],
    this.payeeList = const [],
    this.tagList = const [],
    this.categoryList = const [],
    this.isNewBill = true,
    this.attachments = const [],
  }) {
    if (initialBill != null) {
      editBill = initialBill!.copyWith();
      // 复制账单时（isNewBill=true 且 initialBill 存在），重置交易日期为今天
      if (isNewBill) {
        editBill = editBill.copyWith(
          data: editBill.data?.copyWith(
            tradeTime: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
          ),
        );
      }
      if (initialBill!.files != null) {
        attachments = initialBill!.files!.map((fileItem) {
          return AttachmentItem(
              id: fileItem.fileId.toString(),
              name: fileItem.originalName ?? '',
              path: '',
              size: fileItem.size ?? 0,
              mimeType: '',
              type: AttachmentType.image,
              bytes: fileItem.decodeBase64ToImage(fileItem.fileData!));
        }).toList();
      }
    } else {
      editBill = BillItemAdd(data: BillItemAddData.init(bookId: bookId));
    }
  }

  final EditBillStatus status;
  final BillItemAdd? initialBill;
  late BillItemAdd editBill;
  // 账单类型
  List<DropdownItem<BookSelectItem>> bookList;
  // 支出账户
  List<DropdownItem<AccountSelectItem>> expenseAccountList;
  // 转入账户
  List<DropdownItem<AccountSelectItem>> transferAccountList;
  // 收入账户
  List<DropdownItem<AccountSelectItem>> incomeAccountList;
  // 转出账户
  List<DropdownItem<AccountSelectItem>> transferOutAccountList;
  // 收款人
  List<DropdownItem<PayeeSelectItem>> payeeList;
  // 标签
  List<TagSelectItem> tagList;
  // 类别
  List<CategorySelectItem> categoryList;

  int? defaultExpenseAccountId;
  int? defaultIncomeAccountId;
  int? defaultTransferOutAccountId;
  int? defaultTransferInAccountId;

  // 附件列表
  List<AttachmentItem> attachments;

  bool isNewBill;

  EditBillState copyWith({
    EditBillStatus? status,
    BillItemAdd? initialBill,
    List<DropdownItem<BookSelectItem>>? bookList,
    List<DropdownItem<AccountSelectItem>>? expenseAccountList,
    List<DropdownItem<AccountSelectItem>>? transferAccountList,
    List<DropdownItem<AccountSelectItem>>? incomeAccountList,
    List<DropdownItem<AccountSelectItem>>? transferOutAccountList,
    List<DropdownItem<PayeeSelectItem>>? payeeList,
    List<TagSelectItem>? tagList,
    List<CategorySelectItem>? categoryList,
    BillItemAdd? editBill,
    int? defaultExpenseAccountId,
    int? defaultIncomeAccountId,
    int? defaultTransferOutAccountId,
    int? defaultTransferInAccountId,
    List<AttachmentItem>? attachments,
    bool? isNewBill,
  }) {
    return EditBillState(
      status: status ?? this.status,
      initialBill: initialBill ?? this.initialBill,
      bookList: bookList ?? this.bookList,
      expenseAccountList: expenseAccountList ?? this.expenseAccountList,
      transferAccountList: transferAccountList ?? this.transferAccountList,
      incomeAccountList: incomeAccountList ?? this.incomeAccountList,
      transferOutAccountList:
          transferOutAccountList ?? this.transferOutAccountList,
      payeeList: payeeList ?? this.payeeList,
      tagList: tagList ?? this.tagList,
      categoryList: categoryList ?? this.categoryList,
      editBill: editBill ?? this.editBill,
      defaultExpenseAccountId:
          defaultExpenseAccountId ?? this.defaultExpenseAccountId,
      defaultIncomeAccountId:
          defaultIncomeAccountId ?? this.defaultIncomeAccountId,
      defaultTransferOutAccountId:
          defaultTransferOutAccountId ?? this.defaultTransferOutAccountId,
      defaultTransferInAccountId:
          defaultTransferInAccountId ?? this.defaultTransferInAccountId,
      attachments: attachments ?? this.attachments,
      isNewBill: isNewBill ?? this.isNewBill,
    );
  }

  @override
  List<Object?> get props => [
        status,
        initialBill,
        bookList,
        expenseAccountList,
        transferAccountList,
        incomeAccountList,
        transferOutAccountList,
        payeeList,
        tagList,
        categoryList,
        editBill,
        attachments,
      ];
}
