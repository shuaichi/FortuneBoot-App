import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hjproject/home/edit_bill/models/edit_select_item.dart';
import 'package:hjproject/home/edit_bill/models/attachment_item.dart';
import 'package:hjproject/home/edit_bill/viewmodel/edit_field_cell_viewmodel.dart';
import 'package:hjproject/home/bill_overview/models/bill_item.dart';
import 'package:hjproject/home/bill_overview/models/bill_item_add.dart';
import 'package:hjproject/login/model/login_model.dart';
import 'package:hjproject/request/account_request.dart';
import 'package:hjproject/request/bill_request.dart';
import 'package:hjproject/request/book_request.dart';
import 'package:hjproject/request/category_request.dart';
import 'package:hjproject/request/payee_request.dart';
import 'package:hjproject/request/tag_request.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';
import 'package:dio/dio.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

part 'edit_bill_event.dart';

part 'edit_bill_state.dart';

class EditBillBloc extends Bloc<EditBillEvent, EditBillState> {
  EditBillBloc({
    required BillsRepository billRepository,
    required BillItemAdd? initialBill,
    bool isCopyBill = false,
  })  : _billRepository = billRepository,
        super(
          EditBillState.init(
            bookId: billRepository.bookId() ?? 1,
            initialBill: initialBill,
            isNewBill: initialBill == null || isCopyBill,
          ),
        ) {
    on<EditBillSubmitted>(_onBillSubmitted);
    on<EditBillInitialized>(_onBillInitialized);
    on<EditBillTypeChange>(_onBillTypeChange);
    on<EditBillAttachmentsChanged>(_onAttachmentsChanged);
  }

  final BillsRepository _billRepository;

  FutureOr<void> _onBillSubmitted(
      EditBillSubmitted event, Emitter<EditBillState> emit) async {
    emit(state.copyWith(
        status: EditBillStatus.loading, isNewBill: state.isNewBill));
    final BillItemAddData data = state.editBill.data!;
    print('lxjtodo: _onBillSubmitted request: ${data.toJson()}');
    // 准备附件文件
    List<dynamic> attachmentFiles = [];
    for (final attachment in state.attachments) {
      if (attachment.file != null) {
        // 移动端文件
        attachmentFiles.add(attachment.file!);
      } else if (attachment.bytes != null) {
        // Web端文件
        attachmentFiles.add({
          'bytes': attachment.bytes!,
          'name': attachment.name,
        });
      }
    }

    final FromBillAddRequest request = FromBillAddRequest();
    Response? response = await request.submitBill(
      data.toJson(),
      modify: !state.isNewBill,
      attachmentFiles: attachmentFiles.isNotEmpty ? attachmentFiles : null,
    );
    if (response?.statusCode == 200) {
      print('lxjtodo _onBillSubmitte response: ${response?.data} ');
      final hjResponse = HJResponse.fromJson(
          Map<String, dynamic>.from(response?.data as Map? ?? {}));
      if (hjResponse.code == 0) {
        _billRepository.refreshBills();
        emit(state.copyWith(
            status: EditBillStatus.closed, isNewBill: state.isNewBill));
      } else {
        emit(state.copyWith(
            status: EditBillStatus.submitFailed, isNewBill: state.isNewBill));
      }
    } else {
      print('lxjtodo _onBillSubmitte response: $response ');
      emit(state.copyWith(
          status: EditBillStatus.submitFailed, isNewBill: state.isNewBill));
    }
  }

  FutureOr<void> _onBillInitialized(
      EditBillInitialized event, Emitter<EditBillState> emit) async {
    await refreshData(event.type, emit);
  }

  FutureOr<void> refreshData(BillType type, Emitter<EditBillState> emit) async {
    final groupId = _billRepository.groupId();
    final bookId = _billRepository.bookId();
    final billType = type.value;
    BookService bookService = BookService();
    final bookResponse =
        await bookService.getEnableList(groupId ?? 1, type: type.value);
    List<DropdownItem<BookSelectItem>>? books;
    int? defaultExpenseAccountId;
    int? defaultIncomeAccountId;
    int? defaultTransferOutAccountId;
    int? defaultTransferInAccountId;
    if (bookResponse.code == 0) {
      books = (bookResponse.data as List? ?? []).map((element) {
        final name = element['bookName'] as String? ?? '';
        final id = element['bookId'] as int? ?? 0;
        if (id == bookId) {
          defaultExpenseAccountId =
              element['defaultExpenseAccountId'] as int? ?? 0;
          defaultIncomeAccountId =
              element['defaultIncomeAccountId'] as int? ?? 0;
          defaultTransferOutAccountId =
              element['defaultTransferOutAccountId'] as int? ?? 0;
          defaultTransferInAccountId =
              element['defaultTransferInAccountId'] as int? ?? 0;
        }
        return DropdownItem<BookSelectItem>(
          label: name,
          value: BookSelectItem(name, id),
        );
      }).toList();
    }
    final AccountService service = AccountService();
    final accountRes = await service.getEnableList(groupId ?? 0);
    final List<DropdownItem<AccountSelectItem>> expenseAccountList = [];
    final List<DropdownItem<AccountSelectItem>> incomeAccountList = [];
    final List<DropdownItem<AccountSelectItem>> transferAccountList = [];
    final List<DropdownItem<AccountSelectItem>> transferOutAccountList = [];
    if (accountRes.code == 0) {
      accountRes.data?.forEach((element) {
        final String accountName = element['accountName'] as String? ?? '';
        final String? accountIcon = element['icon'] as String?;
        final DropdownItem<AccountSelectItem> account = DropdownItem(
            label: accountName,
            value: AccountSelectItem(
                accountName, element['accountId'] as int? ?? 0,
                icon: accountIcon));
        if ((element['canExpense'] as bool? ?? false)) {
          expenseAccountList.add(account);
        }
        if ((element['canIncome'] as bool? ?? false)) {
          incomeAccountList.add(account);
        }
        if ((element['canTransferIn'] as bool? ?? false)) {
          transferAccountList.add(account);
        }
        if ((element['canTransferOut'] as bool? ?? false)) {
          transferOutAccountList.add(account);
        }
      });
    }
    final payees = await payeeItems(PayeeService(), id: bookId, type: billType);
    final categories = await categoryFutureItems(type, bookId ?? 1);
    final tags = await tagFutureItems(type, bookId ?? 1);
    emit(state.copyWith(
      bookList: books,
      payeeList: payees,
      expenseAccountList: expenseAccountList,
      incomeAccountList: incomeAccountList,
      transferAccountList: transferAccountList,
      transferOutAccountList: transferOutAccountList,
      defaultExpenseAccountId: defaultExpenseAccountId,
      defaultIncomeAccountId: defaultIncomeAccountId,
      defaultTransferOutAccountId: defaultTransferOutAccountId,
      defaultTransferInAccountId: defaultTransferInAccountId,
      categoryList: categories,
      tagList: tags,
      status: EditBillStatus.success,
      isNewBill: state.isNewBill,
    ));
  }

  FutureOr<void> _onBillTypeChange(
      EditBillTypeChange event, Emitter<EditBillState> emit) async {
    final editedBill = state.editBill.copyWith(
        data: state.editBill.data?.copyWith(
      billType: event.type.value,
      categoryAmountPair: [],
      tagIdList: [],
      accountId: -1,
      accountToId: -1,
      payeeId: -1,
    ));
    print('lxjtodo: _onBillTypeChange: ${editedBill}');
    emit(state.copyWith(
      editBill: editedBill,
      status: EditBillStatus.loading,
      isNewBill: state.isNewBill,
    ));
    await refreshData(event.type, emit);
  }

  FutureOr<void> _onAttachmentsChanged(
      EditBillAttachmentsChanged event, Emitter<EditBillState> emit) async {
    emit(state.copyWith(
      attachments: event.attachments,
    ));
  }
}

Future<List<CategorySelectItem>> categoryFutureItems(
    BillType billType, int bookId) async {
  final CategoryService categoryService = CategoryService();
  final response =
      await categoryService.getEnableList(bookId, type: billType.value);
  final List<CategorySelectItem> categoryItems = [];
  if (response.code == 0) {
    final list = response.data as List? ?? [];
    for (final item in list) {
      categoryItems.add(CategorySelectItem.fromJson(
          Map<String, dynamic>.from(item as Map? ?? {})));
    }
  }
  return categoryItems;
}

Future<List<TagSelectItem>> tagFutureItems(
    BillType billType, int bookId) async {
  final TagService tagService = TagService();
  final response = await tagService.getEnableList(bookId, type: billType.value);
  final List<TagSelectItem> tagItems = [];
  if (response.code == 0) {
    final list = response.data as List? ?? [];
    for (final item in list) {
      tagItems.add(TagSelectItem.fromJson(
          Map<String, dynamic>.from(item as Map? ?? {})));
    }
  }
  return tagItems;
}
