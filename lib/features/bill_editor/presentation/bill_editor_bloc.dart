import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/errors/fx_failure.dart';
import 'package:fortuneboot/core/errors/fx_failure_mapper.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/bill_editor/data/editor_options_service.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_args.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_models.dart';
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
  }) : _bookId = bookId,
       _groupId = groupId,
       _optionsService = optionsService ?? EditorOptionsService(),
       _billService = billService ?? BillService(),
       super(BillEditorState(tradeTime: DateTime.now())) {
    on<BillEditorInitialized>(_onInitialized);
    on<BillEditorRetried>(_onRetried);
    on<BillTypeChanged>(_onBillTypeChanged);
    on<TransferAmountChanged>(_onTransferAmountChanged);
    on<CategoryRowAdded>(_onCategoryRowAdded);
    on<CategoryRowRemoved>(_onCategoryRowRemoved);
    on<CategoryRowCategoryChanged>(_onCategoryRowCategoryChanged);
    on<CategoryRowAmountChanged>(_onCategoryRowAmountChanged);
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
  var _nextRowSequence = 0;

  String _nextRowId() => 'editor-row-${_nextRowSequence++}';

  CategoryAmountRow _newCategoryRow({
    int? categoryId,
    String? categoryName,
    double amount = 0,
  }) => CategoryAmountRow(
    rowId: _nextRowId(),
    categoryId: categoryId,
    categoryName: categoryName,
    amount: amount,
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

  Future<void> _onInitialized(
    BillEditorInitialized event,
    Emitter<BillEditorState> emit,
  ) async {
    final args = event.args;
    final source = args.sourceBill;

    // 1) 用 args 预填基础字段（在选项加载前，界面即可先出骨架）。
    var next = _prefillFromArgs(state, args);
    emit(next.copyWith(status: EditorStatus.loading));

    // 2) 并发加载选项。
    try {
      final options = await _optionsService.loadAll(
        bookId: _bookId,
        groupId: _groupId,
      );
      next = next.copyWith(status: EditorStatus.ready, options: options);
      // 新建且未预填账户时，按默认账户填充。
      if (source == null) {
        next = _applyDefaultAccount(next);
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
    try {
      final options = await _optionsService.loadAll(
        bookId: _bookId,
        groupId: _groupId,
      );
      var next = state.copyWith(status: EditorStatus.ready, options: options);
      if (state.mode == 'new' && state.accountId == null) {
        next = _applyDefaultAccount(next);
      }
      emit(next);
    } on FxApiException catch (e) {
      emit(state.copyWith(status: EditorStatus.error, loadError: e.message));
    } on Object catch (e) {
      emit(state.copyWith(status: EditorStatus.error, loadError: e.toString()));
    }
  }

  /// 从 args（含 sourceBill / presetBillType）预填表单。
  BillEditorState _prefillFromArgs(BillEditorState base, BillEditorArgs args) {
    final source = args.sourceBill;

    if (source != null) {
      final billType =
          FxBillType.fromValue(source.billType) ?? FxBillType.expense;
      final rows = source.categoryAmountPair.isEmpty
          ? [_newCategoryRow()]
          : source.categoryAmountPair
                .map(
                  (e) => _newCategoryRow(
                    categoryId: e.categoryId,
                    categoryName: e.categoryName,
                    amount: e.amount,
                  ),
                )
                .toList();
      final extras = source.extras
          .map(
            (e) => _newExtraRow(
              extraType: e.extraType ?? 1,
              amount: e.amount,
              accountSide: e.accountSide ?? 1,
              categoryId: e.categoryId,
              remark: e.remark,
            ),
          )
          .toList();

      return base.copyWith(
        mode: args.mode,
        billId: args.isEdit ? args.billId : null,
        lockBillType: args.lockBillType,
        billType: billType,
        transferAmount: source.amount,
        categoryRows: rows,
        accountId: source.accountId,
        accountName: source.accountName,
        toAccountId: source.toAccountId,
        toAccountName: source.toAccountName,
        payeeId: source.payeeId,
        payeeName: source.payeeName,
        tradeTime: source.tradeTime ?? DateTime.now(),
        tagIds: source.tagList.map((t) => t.tagId).whereType<int>().toList(),
        tagNames: source.tagList
            .map((t) => t.tagName ?? '')
            .where((s) => s.isNotEmpty)
            .toList(),
        memberIds: source.memberList
            .map((m) => m.memberId)
            .whereType<int>()
            .toList(),
        memberNames: source.memberList
            .map((m) => m.memberName ?? '')
            .where((s) => s.isNotEmpty)
            .toList(),
        orderId: source.orderId,
        extras: extras,
        title: source.title ?? '',
        titleTouched: (source.title ?? '').isNotEmpty,
        remark: source.remark ?? '',
        confirm: source.confirm,
        include: source.include,
      );
    }

    // 新建：可能带 presetBillType。
    final preset = FxBillType.fromValue(args.presetBillType);
    return base.copyWith(
      mode: args.mode,
      billId: args.billId,
      lockBillType: args.lockBillType,
      billType: preset ?? FxBillType.expense,
      categoryRows: [_newCategoryRow()],
    );
  }

  /// 依据当前类型选默认账户（来自选项中首个可用账户）。
  BillEditorState _applyDefaultAccount(BillEditorState s) {
    final accounts = s.options.accounts;
    if (accounts.isEmpty) return s;

    AccountOption? pick(bool Function(AccountOption) test) {
      for (final a in accounts) {
        if (test(a)) return a;
      }
      return null;
    }

    if (s.isTransfer) {
      final out = pick((a) => a.canTransferOut);
      final inn = pick((a) => a.canTransferIn && a.accountId != out?.accountId);
      return s.copyWith(
        accountId: out?.accountId,
        accountName: out?.accountName,
        toAccountId: inn?.accountId,
        toAccountName: inn?.accountName,
      );
    }

    final test = s.isIncome
        ? (AccountOption a) => a.canIncome
        : (AccountOption a) => a.canExpense;
    final acc = pick(test);
    if (acc == null) return s;
    return s.copyWith(accountId: acc.accountId, accountName: acc.accountName);
  }

  void _onBillTypeChanged(
    BillTypeChanged event,
    Emitter<BillEditorState> emit,
  ) {
    if (state.lockBillType) return;
    if (event.billType == state.billType) return;
    // 切换类型时重置与类型强相关的字段，避免脏数据。
    var next = state.copyWith(
      billType: event.billType,
      clearAccount: true,
      clearToAccount: true,
      clearPayee: true,
      clearOrder: true,
      categoryRows: [_newCategoryRow()],
      extras: const [],
    );
    if (state.status == EditorStatus.ready) {
      next = _applyDefaultAccount(next);
    }
    emit(next);
  }

  void _onTransferAmountChanged(
    TransferAmountChanged event,
    Emitter<BillEditorState> emit,
  ) {
    emit(state.copyWith(transferAmount: event.amount));
  }

  void _onCategoryRowAdded(
    CategoryRowAdded event,
    Emitter<BillEditorState> emit,
  ) {
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
    rows[index] = rows[index].copyWith(amount: event.amount);
    emit(state.copyWith(categoryRows: rows));
  }

  void _onAccountChanged(AccountChanged event, Emitter<BillEditorState> emit) {
    emit(
      state.copyWith(
        accountId: event.accountId,
        accountName: event.accountName,
      ),
    );
  }

  void _onToAccountChanged(
    ToAccountChanged event,
    Emitter<BillEditorState> emit,
  ) {
    emit(
      state.copyWith(
        toAccountId: event.accountId,
        toAccountName: event.accountName,
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
    if (event.orderId == null) {
      emit(state.copyWith(clearOrder: true));
    } else {
      emit(
        state.copyWith(orderId: event.orderId, orderTitle: event.orderTitle),
      );
    }
  }

  void _onExtraRowAdded(ExtraRowAdded event, Emitter<BillEditorState> emit) {
    // 转账默认转出方向 from(1)，支出固定 from。
    emit(state.copyWith(extras: [...state.extras, _newExtraRow()]));
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
    extras[index] = ExtraRow(
      rowId: extras[index].rowId,
      extraType: event.row.extraType,
      amount: event.row.amount,
      accountSide: event.row.accountSide,
      categoryId: event.row.categoryId,
      remark: event.row.remark,
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
    emit(state.copyWith(confirm: event.value));
  }

  void _onIncludeToggled(IncludeToggled event, Emitter<BillEditorState> emit) {
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
        submitFailure: null,
        validationFailure: null,
      ),
    );
    try {
      final json = _buildCommand(state);
      await _billService.submit(
        json,
        modify: state.mode == 'edit',
        attachments: state.attachments.isEmpty ? null : state.attachments,
      );
      emit(state.copyWith(submitStatus: SubmitStatus.success));
    } on Object catch (error) {
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

  /// 构造 FortuneBillAddCommand JSON。
  Map<String, dynamic> _buildCommand(BillEditorState s) {
    final json = <String, dynamic>{
      'bookId': _bookId,
      'title': s.effectiveTitle,
      'tradeTime': BillService.dateTimeFormat.format(s.tradeTime),
      'billType': s.billTypeValue,
      'confirm': s.confirm,
      'include': s.include,
    };

    if (s.isTransfer) {
      json['amount'] = s.transferAmount;
      json['accountId'] = s.accountId;
      json['toAccountId'] = s.toAccountId;
      // 转账无分类，补空数组占位绕过后端 @NotNull 校验（空 list 非 null）。
      json['categoryAmountPair'] = const <Map<String, dynamic>>[];
    } else {
      json['accountId'] = s.accountId;
      json['categoryAmountPair'] = s.categoryRows
          .where((r) => r.categoryId != null)
          .map((r) => {'categoryId': r.categoryId, 'amount': r.amount})
          .toList();
      if (s.showPayee && s.payeeId != null) json['payeeId'] = s.payeeId;
      if (s.showOrder && s.orderId != null) json['orderId'] = s.orderId;
    }

    if (s.tagIds.isNotEmpty) json['tagIdList'] = s.tagIds;
    if (s.memberIds.isNotEmpty) json['memberIdList'] = s.memberIds;

    if (s.showExtras && s.extras.isNotEmpty) {
      json['extras'] = s.extras
          .where((e) => e.amount != 0)
          .map(
            (e) => {
              'extraType': e.extraType,
              'amount': e.amount,
              'accountSide': s.isTransfer ? e.accountSide : 1,
              if (e.categoryId != null) 'categoryId': e.categoryId,
              if (e.remark != null && e.remark!.isNotEmpty) 'remark': e.remark,
            },
          )
          .toList();
    }

    if (s.remark.isNotEmpty) json['remark'] = s.remark;
    if (s.mode == 'edit' && s.billId != null) json['billId'] = s.billId;

    return json;
  }
}
