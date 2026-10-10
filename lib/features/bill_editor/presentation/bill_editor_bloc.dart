import 'dart:convert';
import 'dart:math';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/errors/fx_failure.dart';
import 'package:fortuneboot/core/errors/fx_failure_mapper.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/accounts/data/account_models.dart';
import 'package:fortuneboot/features/accounts/data/bank_brand.dart';
import 'package:fortuneboot/features/bill_editor/data/editor_options_service.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_args.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_models.dart';
import 'package:fortuneboot/features/orders/data/finance_order_contract.dart';
import 'package:fortuneboot/features/orders/data/order_money.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment_validator.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';

export 'package:fortuneboot/features/bill_editor/presentation/bill_editor_models.dart';

part 'bill_editor_event.dart';
part 'bill_editor_state.dart';

/// BillEditor 表单状态机。完整持有表单字段 + 选项加载 + 提交。
class BillEditorBloc extends Bloc<BillEditorEvent, BillEditorState> {
  BillEditorBloc({
    required int bookId,
    required int groupId,
    EditorOptionsService? optionsService,
    BillService? billService,
    OrdersService? ordersService,
    bool copyUsesCurrentTime = true,
    String Function()? requestIdFactory,
  }) : _bookId = bookId,
       _groupId = groupId,
       _optionsService = optionsService ?? EditorOptionsService(),
       _billService = billService ?? BillService(),
       _ordersService = ordersService ?? OrdersService(),
       _copyUsesCurrentTime = copyUsesCurrentTime,
       _requestIdFactory = requestIdFactory ?? _generateRequestId,
       super(BillEditorState(tradeTime: DateTime.now())) {
    on<BillEditorInitialized>(_onInitialized);
    on<BillEditorRetried>(_onRetried);
    on<BillTypeChanged>(_onBillTypeChanged);
    on<TransferAmountChanged>(_onTransferAmountChanged);
    on<SingleAmountChanged>(_onSingleAmountChanged);
    on<CategoryRowAdded>(_onCategoryRowAdded);
    on<CategoryRowRemoved>(_onCategoryRowRemoved);
    on<CategoryRowCategoryChanged>(_onCategoryRowCategoryChanged);
    on<CategoryRowAmountChanged>(_onCategoryRowAmountChanged);
    on<OrderCategoryRowAmountChanged>(_onOrderCategoryRowAmountChanged);
    on<AccountChanged>(_onAccountChanged);
    on<ToAccountChanged>(_onToAccountChanged);
    on<PayeeChanged>(_onPayeeChanged);
    on<TradeTimeChanged>(_onTradeTimeChanged);
    on<TagsChanged>(_onTagsChanged);
    on<MembersChanged>(_onMembersChanged);
    on<OrderChanged>(_onOrderChanged);
    on<ExtraRowAdded>(_onExtraRowAdded);
    on<ExtraRowRemoved>(_onExtraRowRemoved);
    on<ExtraRowChanged>(_onExtraRowChanged);
    on<AttachmentsAdded>(_onAttachmentsAdded);
    on<AttachmentRemoved>(_onAttachmentRemoved);
    on<RemarkChanged>(_onRemarkChanged);
    on<TitleChanged>(_onTitleChanged);
    on<ConfirmToggled>(_onConfirmToggled);
    on<IncludeToggled>(_onIncludeToggled);
    on<BillEditorSubmitted>(_onSubmitted, transformer: droppable());
  }

  final int _bookId;
  final int _groupId;
  final EditorOptionsService _optionsService;
  final BillService _billService;
  final OrdersService _ordersService;
  final bool _copyUsesCurrentTime;
  final String Function() _requestIdFactory;
  var _nextRowSequence = 0;
  var _optionsSequence = 0;
  String? _lastRequestId;
  String? _lastCommandSignature;

  static String _generateRequestId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return [
      hex.substring(0, 8),
      hex.substring(8, 12),
      hex.substring(12, 16),
      hex.substring(16, 20),
      hex.substring(20),
    ].join('-');
  }

  String _nextRowId() => 'editor-row-${_nextRowSequence++}';

  CategoryAmountRow _newCategoryRow({
    int? categoryId,
    String? categoryName,
    double amount = 0,
    int amountCents = 0,
  }) => CategoryAmountRow(
    rowId: _nextRowId(),
    categoryId: categoryId,
    categoryName: categoryName,
    amount: amount,
    amountCents: amountCents,
  );

  ExtraRow _newExtraRow({
    int extraType = 1,
    double amount = 0,
    int accountSide = 1,
    int? categoryId,
    String? remark,
  }) => ExtraRow(
    rowId: _nextRowId(),
    extraType: extraType,
    amount: amount,
    accountSide: accountSide,
    categoryId: categoryId,
    remark: remark,
  );

  ExtraRow _normalizeExtraRow(ExtraRow row, {required bool isTransfer}) {
    if (isTransfer) {
      return ExtraRow(
        rowId: row.rowId,
        extraType: row.extraType,
        amount: row.amount,
        accountSide: BillEditorState.isValidTransferAccountSide(row.accountSide)
            ? row.accountSide
            : 1,
        remark: row.remark,
      );
    }
    return ExtraRow(
      rowId: row.rowId,
      extraType: row.extraType,
      amount: row.amount,
        categoryId: row.categoryId,
      remark: row.remark,
    );
  }

  Future<void> _onInitialized(
    BillEditorInitialized event,
    Emitter<BillEditorState> emit,
  ) async {
    final args = event.args;
    final source = args.sourceBill;

    if (args.presetBookId != null && args.presetBookId != _bookId) {
      emit(
        state.copyWith(
          status: EditorStatus.error,
          loadFailure: const FxFailure(
            kind: FxFailureKind.invalidResponse,
          ),
        ),
      );
      return;
    }

    final billType = source == null
        ? FxBillType.fromValue(args.presetBillType) ?? FxBillType.expense
        : FxBillType.fromValue(source.billType);
    if (billType == null) {
      emit(
        state.copyWith(
          status: EditorStatus.error,
          loadFailure: const FxFailure(
            kind: FxFailureKind.invalidResponse,
          ),
        ),
      );
      return;
    }

    var next = _prefillFromArgs(state, args);
    emit(next.copyWith(status: EditorStatus.loading));

    final sequence = ++_optionsSequence;
    try {
      final options = await _optionsService.loadAll(
        bookId: _bookId,
        groupId: _groupId,
        billType: billType,
        presetOrderId: next.orderId,
        presetOrderTitle: next.orderTitle,
      );
      if (sequence != _optionsSequence) return;
      next = next.copyWith(status: EditorStatus.ready, options: options);
      if (source == null) {
        next = _applyDefaultAccount(next);
      }
      if (source?.hasFile == true && source?.billId != null) {
        next = next.copyWith(
          attachments: await _billService.getAttachments(source!.billId!),
        );
      }
      emit(next);
    } on Object catch (error) {
      emit(
        next.copyWith(
          status: EditorStatus.error,
          loadFailure: FxFailureMapper.map(error),
        ),
      );
    }
  }

  Future<void> _onRetried(
    BillEditorRetried event,
    Emitter<BillEditorState> emit,
  ) async {
    emit(state.copyWith(status: EditorStatus.loading));
    final sequence = ++_optionsSequence;
    try {
      final options = await _optionsService.loadAll(
        bookId: _bookId,
        groupId: _groupId,
        billType: state.billType,
        presetOrderId: state.orderId,
        presetOrderTitle: state.orderTitle,
      );
      if (sequence != _optionsSequence) return;
      var next = state.copyWith(status: EditorStatus.ready, options: options);
      if (state.mode == 'new' && state.accountId == null) {
        next = _applyDefaultAccount(next);
      }
      emit(next);
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: EditorStatus.error,
          loadFailure: FxFailureMapper.map(error),
        ),
      );
    }
  }

  BillEditorState _prefillFromArgs(BillEditorState base, BillEditorArgs args) {
    final source = args.sourceBill;

    if (source != null) {
      final billType = FxBillType.fromValue(source.billType);
      if (billType == null) {
        return base;
      }
      final isSingle = billType == FxBillType.loanOut ||
          billType == FxBillType.loanRecover ||
          billType == FxBillType.loanIn ||
          billType == FxBillType.loanRepay;
      final rows = isSingle
          ? const <CategoryAmountRow>[]
          : source.categoryAmountPair.isEmpty
          ? [_newCategoryRow()]
          : source.categoryAmountPair
                .map(
                  (category) => _newCategoryRow(
                    categoryId: category.categoryId,
                    categoryName: category.categoryName,
                    amount: category.amount,
                    amountCents:
                        category.amountMoney?.cents ??
                        _legacyCents(category.amount),
                  ),
                )
                .toList();
      final extras = (billType == FxBillType.expense ||
              billType == FxBillType.transfer)
          ? source.extras
                .map(
                  (extra) => _normalizeExtraRow(
                    _newExtraRow(
                      extraType: extra.extraType ?? 1,
                      amount: extra.amount,
                      accountSide: extra.accountSide ?? 1,
                      categoryId: extra.categoryId,
                      remark: extra.remark,
                    ),
                    isTransfer: billType == FxBillType.transfer,
                  ),
                )
                .toList()
          : const <ExtraRow>[];
      final orderComponent =
          args.presetOrderComponent ??
          source.orderComponent ??
          (isSingle ? FinanceOrderComponent.principal : null);

      return base.copyWith(
        mode: args.mode,
        billId: args.isEdit ? (args.billId ?? source.billId) : null,
        lockBillType: args.lockBillType,
        billType: billType,
        transferAmount: source.amount,
        singleAmountCents:
            source.amountMoney?.cents ?? _legacyCents(source.amount),
        categoryRows: rows,
        accountId: source.accountId,
        accountName: source.accountName,
        toAccountId: source.toAccountId,
        toAccountName: source.toAccountName,
        payeeId: source.payeeId,
        payeeName: source.payeeName,
        tradeTime: args.isCopy && _copyUsesCurrentTime
            ? DateTime.now()
            : (source.tradeTime ?? DateTime.now()),
        tagIds: source.tagList
            .map((tag) => tag.tagId)
            .whereType<int>()
            .toList(),
        tagNames: source.tagList
            .map((tag) => tag.tagName ?? '')
            .where((name) => name.isNotEmpty)
            .toList(),
        memberIds: source.memberList
            .map((member) => member.memberId)
            .whereType<int>()
            .toList(),
        memberNames: source.memberList
            .map((member) => member.memberName ?? '')
            .where((name) => name.isNotEmpty)
            .toList(),
        orderId: args.presetOrderId ?? source.orderId,
        orderTitle: args.copyData?['orderTitle']?.toString() ?? source.orderTitle,
        presetBookId: args.presetBookId,
        orderComponent: orderComponent,
        expectedOrderVersion: args.expectedOrderVersion,
        lockOrderContext: args.lockOrderContext,
        extras: extras,
        attachments: const [],
        title: source.title ?? '',
        titleTouched: (source.title ?? '').isNotEmpty,
        remark: source.remark ?? '',
        confirm: orderComponent == FinanceOrderComponent.writeOff ||
            source.confirm,
        include: source.include,
      );
    }

    final preset = FxBillType.fromValue(args.presetBillType);
    final isSingle = preset == FxBillType.loanOut ||
        preset == FxBillType.loanRecover ||
        preset == FxBillType.loanIn ||
        preset == FxBillType.loanRepay;
    return base.copyWith(
      mode: args.mode,
      billId: args.billId,
      lockBillType: args.lockBillType,
      billType: preset ?? FxBillType.expense,
      categoryRows: isSingle ? const [] : [_newCategoryRow()],
      orderId: args.presetOrderId,
      orderTitle: args.copyData?['orderTitle']?.toString(),
      presetBookId: args.presetBookId,
      orderComponent: args.presetOrderComponent,
      expectedOrderVersion: args.expectedOrderVersion,
      lockOrderContext: args.lockOrderContext,
    );
  }

  static int _legacyCents(double value) => (value * 100).round();

  BillEditorState _applyDefaultAccount(BillEditorState state) {
    final accounts = state.options.accounts;
    if (accounts.isEmpty) return state;

    AccountOption? pick(bool Function(AccountOption) test) {
      for (final account in accounts) {
        if (test(account)) return account;
      }
      return null;
    }

    if (state.isTransfer) {
      final out = pick((account) => account.canTransferOut);
      final income = pick(
        (account) =>
            account.canTransferIn && account.accountId != out?.accountId,
      );
      return state.copyWith(
        accountId: out?.accountId,
        accountName: out?.accountName,
        toAccountId: income?.accountId,
        toAccountName: income?.accountName,
      );
    }

    final test = state.usesIncomeAssociations
        ? (AccountOption account) => account.canIncome
        : (AccountOption account) => account.canExpense;
    final account = pick(test);
    if (account == null) return state;
    return state.copyWith(
      accountId: account.accountId,
      accountName: account.accountName,
    );
  }

  Future<void> _onBillTypeChanged(
    BillTypeChanged event,
    Emitter<BillEditorState> emit,
  ) async {
    if (state.lockBillType || event.billType == state.billType) return;

    final isSingle = event.billType == FxBillType.loanOut ||
        event.billType == FxBillType.loanRecover ||
        event.billType == FxBillType.loanIn ||
        event.billType == FxBillType.loanRepay;
    final next = state.copyWith(
      billType: event.billType,
      transferAmount: 0,
      singleAmountCents: 0,
      categoryRows: isSingle ? const [] : [_newCategoryRow()],
      clearAccount: true,
      clearToAccount: true,
      clearOrder: true,
      clearOrderComponent: true,
      clearExpectedOrderVersion: true,
      extras: const [],
      orderComponent: isSingle ? FinanceOrderComponent.principal : null,
    );
    emit(next);

    final sequence = ++_optionsSequence;
    try {
      final orders = await _optionsService.getOrderOptions(
        bookId: _bookId,
        billType: event.billType,
      );
      if (sequence != _optionsSequence) return;
      emit(
        state.copyWith(
          options: state.options.copyWith(orders: orders),
        ),
      );
    } on Object {
      // 选项加载失败不覆盖已输入内容；用户可重试加载。
    }
  }

  void _onTransferAmountChanged(
    TransferAmountChanged event,
    Emitter<BillEditorState> emit,
  ) {
    emit(state.copyWith(transferAmount: event.amount));
  }

  void _onSingleAmountChanged(
    SingleAmountChanged event,
    Emitter<BillEditorState> emit,
  ) {
    emit(state.copyWith(singleAmountCents: event.cents));
  }

  void _onCategoryRowAdded(
    CategoryRowAdded event,
    Emitter<BillEditorState> emit,
  ) {
    if (state.showSingleAmount) return;
    emit(
      state.copyWith(
        categoryRows: [...state.categoryRows, _newCategoryRow()],
      ),
    );
  }

  void _onCategoryRowRemoved(
    CategoryRowRemoved event,
    Emitter<BillEditorState> emit,
  ) {
    if (state.categoryRows.length <= 1) return;
    final rows = state.categoryRows
        .where((row) => row.rowId != event.rowId)
        .toList();
    if (rows.length == state.categoryRows.length) return;
    emit(state.copyWith(categoryRows: rows));
  }

  void _onCategoryRowCategoryChanged(
    CategoryRowCategoryChanged event,
    Emitter<BillEditorState> emit,
  ) {
    final index = state.categoryRows.indexWhere(
      (row) => row.rowId == event.rowId,
    );
    if (index < 0) return;
    final rows = [...state.categoryRows];
    rows[index] = rows[index].copyWith(
      categoryId: event.categoryId,
      categoryName: event.categoryName,
    );
    emit(state.copyWith(categoryRows: rows));
  }

  void _onCategoryRowAmountChanged(
    CategoryRowAmountChanged event,
    Emitter<BillEditorState> emit,
  ) {
    final index = state.categoryRows.indexWhere(
      (row) => row.rowId == event.rowId,
    );
    if (index < 0) return;
    final rows = [...state.categoryRows];
    rows[index] = rows[index].copyWith(
      amount: event.amount,
      amountCents: _legacyCents(event.amount),
    );
    emit(state.copyWith(categoryRows: rows));
  }

  void _onOrderCategoryRowAmountChanged(
    OrderCategoryRowAmountChanged event,
    Emitter<BillEditorState> emit,
  ) {
    final index = state.categoryRows.indexWhere(
      (row) => row.rowId == event.rowId,
    );
    if (index < 0) return;
    final rows = [...state.categoryRows];
    rows[index] = rows[index].copyWith(
      amount: event.cents / 100,
      amountCents: event.cents,
    );
    emit(state.copyWith(categoryRows: rows));
  }

  void _onAccountChanged(AccountChanged event, Emitter<BillEditorState> emit) {
    emit(
      state.copyWith(
        toAccountId: event.accountId,
        toAccountName: event.accountName,
      ),
    );
  }

  void _onToAccountChanged(
    ToAccountChanged event,
    Emitter<BillEditorState> emit,
  ) {
    emit(
      state.copyWith(
        accountId: event.accountId,
        accountName: event.accountName,
      ),
    );
  }

  void _onPayeeChanged(PayeeChanged event, Emitter<BillEditorState> emit) {
    if (event.payeeId == null) {
      emit(state.copyWith(clearPayee: true));
    } else {
      emit(state.copyWith(payeeId: event.payeeId, payeeName: event.payeeName));
    }
  }

  void _onTradeTimeChanged(
    TradeTimeChanged event,
    Emitter<BillEditorState> emit,
  ) {
    emit(state.copyWith(tradeTime: event.tradeTime));
  }

  void _onTagsChanged(TagsChanged event, Emitter<BillEditorState> emit) {
    emit(state.copyWith(tagIds: event.tagIds, tagNames: event.tagNames));
  }

  void _onMembersChanged(MembersChanged event, Emitter<BillEditorState> emit) {
    emit(
      state.copyWith(
        memberIds: event.memberIds,
        memberNames: event.memberNames,
      ),
    );
  }

  void _onOrderChanged(OrderChanged event, Emitter<BillEditorState> emit) {
    if (state.lockOrderContext) return;
    if (event.orderId == null) {
      emit(state.copyWith(clearOrder: true, clearExpectedOrderVersion: true));
    } else {
      emit(
        state.copyWith(
          orderId: event.orderId,
          orderTitle: event.orderTitle,
          clearExpectedOrderVersion: true,
        ),
      );
    }
  }

  void _onExtraRowAdded(ExtraRowAdded event, Emitter<BillEditorState> emit) {
    if (!state.isTransfer &&
        (event.categoryId == null ||
            !state.extraCategoryIds.contains(event.categoryId))) {
      return;
    }
    emit(
      state.copyWith(
        extras: [
          ...state.extras,
          _normalizeExtraRow(
            _newExtraRow(categoryId: event.categoryId),
            isTransfer: state.isTransfer,
          ),
        ],
      ),
    );
  }

  void _onExtraRowRemoved(
    ExtraRowRemoved event,
    Emitter<BillEditorState> emit,
  ) {
    final extras = state.extras
        .where((row) => row.rowId != event.rowId)
        .toList();
    if (extras.length == state.extras.length) return;
    emit(state.copyWith(extras: extras));
  }

  void _onExtraRowChanged(
    ExtraRowChanged event,
    Emitter<BillEditorState> emit,
  ) {
    final index = state.extras.indexWhere((row) => row.rowId == event.rowId);
    if (index < 0) return;
    final extras = [...state.extras];
    extras[index] = _normalizeExtraRow(
      ExtraRow(
        rowId: extras[index].rowId,
        extraType: event.row.extraType,
        amount: event.row.amount,
        accountSide: event.row.accountSide,
        categoryId: event.row.categoryId,
        remark: event.row.remark,
      ),
      isTransfer: state.isTransfer,
    );
    emit(state.copyWith(extras: extras));
  }

  void _onAttachmentsAdded(
    AttachmentsAdded event,
    Emitter<BillEditorState> emit,
  ) {
    if (state.submitStatus == SubmitStatus.submitting) return;
    final attachmentIds = state.attachments
        .map((attachment) => attachment.id)
        .toSet();
    final unique = event.attachments
        .where((attachment) => attachmentIds.add(attachment.id))
        .toList();
    if (unique.isEmpty) return;
    emit(state.copyWith(attachments: [...state.attachments, ...unique]));
  }

  void _onAttachmentRemoved(
    AttachmentRemoved event,
    Emitter<BillEditorState> emit,
  ) {
    if (state.submitStatus == SubmitStatus.submitting ||
        event.index < 0 ||
        event.index >= state.attachments.length) {
      return;
    }
    final files = [...state.attachments]..removeAt(event.index);
    emit(state.copyWith(attachments: files));
  }

  void _onRemarkChanged(RemarkChanged event, Emitter<BillEditorState> emit) {
    emit(state.copyWith(remark: event.remark));
  }

  void _onTitleChanged(TitleChanged event, Emitter<BillEditorState> emit) {
    emit(state.copyWith(title: event.title, titleTouched: true));
  }

  void _onConfirmToggled(ConfirmToggled event, Emitter<BillEditorState> emit) {
    if (state.confirmLocked) return;
    emit(state.copyWith(confirm: event.value));
  }

  void _onIncludeToggled(IncludeToggled event, Emitter<BillEditorState> emit) {
    if (state.includeLocked) return;
    emit(state.copyWith(include: event.value));
  }

  Future<void> _onSubmitted(
    BillEditorSubmitted event,
    Emitter<BillEditorState> emit,
  ) async {
    final error = state.validationError;
    if (error != null) {
      emit(
        state.copyWith(
          submitStatus: SubmitStatus.failure,
          validationFailure: error,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        submitStatus: SubmitStatus.submitting,
      ),
    );
    try {
      if (state.isOrderFlow) {
        await _submitOrderEntry(emit);
      } else {
        final json = _buildCommand(state);
        await _billService.submit(
          json,
          modify: state.mode == 'edit',
          attachments: state.attachments.isEmpty ? null : state.attachments,
        );
      }
      emit(state.copyWith(submitStatus: SubmitStatus.success));
    } on Object catch (error) {
      if (error is FxApiException &&
          (error.code == 30011 || error.code == 409)) {
        try {
          final detail = await _ordersService.getDetail(
            bookId: _bookId,
            orderId: state.orderId!,
          );
          emit(
            state.copyWith(
              submitStatus: SubmitStatus.failure,
              submitFailure: FxFailureMapper.map(error),
              expectedOrderVersion: detail.version,
              orderTitle: detail.title ?? state.orderTitle,
            ),
          );
          return;
        } on Object {
          // 保留原始冲突错误，避免用次要加载失败覆盖业务原因。
        }
      }
      final failure = error is BillAttachmentValidationException
          ? const FxFailure(kind: FxFailureKind.persistence)
          : FxFailureMapper.map(error);
      emit(
        state.copyWith(
          submitStatus: SubmitStatus.failure,
          submitFailure: failure,
        ),
      );
    }
  }

  Future<void> _submitOrderEntry(Emitter<BillEditorState> emit) async {
    var expectedVersion = state.expectedOrderVersion;
    var orderTitle = state.orderTitle;
    if (expectedVersion == null) {
      final detail = await _ordersService.getDetail(
        bookId: _bookId,
        orderId: state.orderId!,
      );
      expectedVersion = detail.version;
      orderTitle = detail.title ?? orderTitle;
      emit(
        state.copyWith(
          expectedOrderVersion: expectedVersion,
          orderTitle: orderTitle,
        ),
      );
    }

    var command = _buildOrderCommand(
      state,
      expectedVersion: expectedVersion!,
      requestId: '',
    );
    final signature = _commandSignature(command);
    if (_lastRequestId == null || _lastCommandSignature != signature) {
      _lastRequestId = _requestIdFactory();
      _lastCommandSignature = signature;
    }
    final requestId = _lastRequestId!;
    command = command.copyWith(requestId: requestId);

    if (state.mode == 'edit' && state.billId != null) {
      await _ordersService.modifyEntry(
        bookId: _bookId,
        orderId: state.orderId!,
        billId: state.billId!,
        command: command,
        attachments: state.attachments,
      );
    } else {
      await _ordersService.createEntry(
        bookId: _bookId,
        orderId: state.orderId!,
        command: command,
        attachments: state.attachments,
      );
    }
  }

  FinanceOrderEntryCommandInput _buildOrderCommand(
    BillEditorState state, {
    required int expectedVersion,
    required String requestId,
  }) {
    final component =
        state.orderComponent ??
        (state.isPrincipalSingleAmount ? FinanceOrderComponent.principal : null);
    return FinanceOrderEntryCommandInput(
      bookId: _bookId,
      orderId: state.orderId!,
      billId: state.mode == 'edit' ? state.billId : null,
      requestId: requestId,
      expectedVersion: expectedVersion,
      orderComponent: component,
      title: state.effectiveTitle,
      tradeTime: state.tradeTime,
      billType: state.billType,
      confirm: state.isWriteOff || state.confirm,
      include: state.effectiveInclude,
      accountId: state.showAccount ? state.accountId : null,
      payeeId: state.showPayee ? state.payeeId : null,
      amount: state.showSingleAmount
          ? OrderMoney.fromCents(state.singleAmountCents)
          : null,
      categoryAmountPair: state.showCategorySplit
          ? state.categoryRows
                .where((row) => row.categoryId != null)
                .map(
                  (row) => FinanceOrderCategoryAmountInput(
                    categoryId: row.categoryId!,
                    amount: OrderMoney.fromCents(row.amountCents),
                  ),
                )
                .toList()
          : const [],
      tagIdList: state.tagIds,
      memberIdList: state.memberIds,
      remark: state.remark,
    );
  }

  String _commandSignature(FinanceOrderEntryCommandInput command) {
    final json = command.toJson();
    json
      ..remove('requestId')
      ..remove('expectedVersion');
    return jsonEncode(json);
  }

  /// 构造普通无关联 FortuneBillAddCommand JSON。
  Map<String, dynamic> _buildCommand(BillEditorState state) {
    final json = <String, dynamic>{
      'bookId': _bookId,
      'title': state.effectiveTitle,
      'tradeTime': BillService.dateTimeFormat.format(state.tradeTime),
      'billType': state.billTypeValue,
      'confirm': state.confirm,
      'include': state.effectiveInclude,
    };

    if (state.isTransfer) {
      json['amount'] = state.transferAmount;
      json['accountId'] = state.accountId;
      json['toAccountId'] = state.toAccountId;
      json['categoryAmountPair'] = const <Map<String, dynamic>>[];
    } else {
      json['accountId'] = state.accountId;
      json['categoryAmountPair'] = state.categoryRows
          .where((row) => row.categoryId != null)
          .map(
            (row) => {
              'categoryId': row.categoryId,
              'amount': row.amount,
            },
          )
          .toList();
      if (state.showPayee && state.payeeId != null) {
        json['payeeId'] = state.payeeId;
      }
    }

    if (state.tagIds.isNotEmpty) json['tagIdList'] = state.tagIds;
    if (state.memberIds.isNotEmpty) json['memberIdList'] = state.memberIds;

    if (state.showExtras && state.extras.isNotEmpty) {
      final categoryIds = state.extraCategoryIds;
      json['extras'] = state.extras
          .where((extra) => extra.amount != 0)
          .where(
            (extra) =>
                state.isTransfer ||
                (extra.categoryId != null &&
                    categoryIds.contains(extra.categoryId)),
          )
          .map(
            (extra) => {
              'extraType': extra.extraType,
              'amount': extra.amount,
              'accountSide': state.isTransfer
                  ? (BillEditorState.isValidTransferAccountSide(
                          extra.accountSide,
                        )
                      ? extra.accountSide
                      : 1)
                  : 1,
              'categoryId': state.isTransfer ? null : extra.categoryId,
              if (extra.remark != null && extra.remark!.isNotEmpty)
                'remark': extra.remark,
            },
          )
          .toList();
    }

    if (state.remark.isNotEmpty) json['remark'] = state.remark;
    if (state.mode == 'edit' && state.billId != null) {
      json['billId'] = state.billId;
    }

    return json;
  }
}
