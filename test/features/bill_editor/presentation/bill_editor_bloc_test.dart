import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/bill_editor/data/editor_options_service.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_args.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_bloc.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';

void main() {
  final sourceTradeTime = DateTime(2020, 1, 2, 3, 4, 5);
  final sourceBill = FortuneBillVo(
    billId: 1,
    billType: 1,
    amount: 28,
    tradeTime: sourceTradeTime,
  );

  test('uses the current time when copying a bill', () async {
    final bloc = _createBloc();
    addTearDown(bloc.close);
    final before = DateTime.now();

    bloc.add(
      BillEditorInitialized(
        BillEditorArgs(mode: 'copy', sourceBill: sourceBill),
      ),
    );
    final state = await bloc.stream.firstWhere(
      (state) => state.status == EditorStatus.ready,
    );
    final after = DateTime.now();

    expect(state.mode, 'copy');
    expect(state.tradeTime, isNot(sourceTradeTime));
    expect(state.tradeTime.isBefore(before), isFalse);
    expect(state.tradeTime.isAfter(after), isFalse);
  });

  test('keeps the source time when copying with the setting disabled', () async {
    final bloc = _createBloc(copyUsesCurrentTime: false);
    addTearDown(bloc.close);

    bloc.add(
      BillEditorInitialized(
        BillEditorArgs(mode: 'copy', sourceBill: sourceBill),
      ),
    );
    final state = await bloc.stream.firstWhere(
      (state) => state.status == EditorStatus.ready,
    );

    expect(state.mode, 'copy');
    expect(state.tradeTime, sourceTradeTime);
  });

  test('preserves the source time when editing a bill', () async {
    final bloc = _createBloc();
    addTearDown(bloc.close);

    bloc.add(
      BillEditorInitialized(
        BillEditorArgs(
          mode: 'edit',
          billId: sourceBill.billId,
          sourceBill: sourceBill,
        ),
      ),
    );
    final state = await bloc.stream.firstWhere(
      (state) => state.status == EditorStatus.ready,
    );

    expect(state.mode, 'edit');
    expect(state.tradeTime, sourceTradeTime);
  });

  test('prefills pending amount for settle preset from the order detail', () async {
    final bloc = _createBloc();
    addTearDown(bloc.close);

    bloc.add(
      const BillEditorInitialized(
        BillEditorArgs(
          mode: 'new',
          presetBillType: 10,
          presetBookId: 1,
          presetOrderId: 11,
          presetOrderComponent: FinanceOrderComponent.principal,
          presetAmountCents: 60000,
          lockOrderContext: true,
        ),
      ),
    );
    final state = await bloc.stream.firstWhere(
      (state) => state.status == EditorStatus.ready,
    );

    expect(state.billType, FxBillType.loanRecover);
    expect(state.singleAmountCents, 60000);
    expect(state.orderId, 11);
  });

  test('prefills pending amount into the first category row for reimburse/write-off', () async {
    final bloc = _createBloc();
    addTearDown(bloc.close);

    bloc.add(
      const BillEditorInitialized(
        BillEditorArgs(
          mode: 'new',
          presetBillType: 8,
          presetBookId: 1,
          presetOrderId: 11,
          presetOrderComponent: FinanceOrderComponent.principal,
          presetAmountCents: 60000,
          lockOrderContext: true,
        ),
      ),
    );
    final state = await bloc.stream.firstWhere(
      (state) => state.status == EditorStatus.ready,
    );

    expect(state.billType, FxBillType.reimburse);
    expect(state.categoryRows.single.amountCents, 60000);
  });

  test('round-trips presetAmountCents through route args', () {
    final args = BillEditorArgs.fromRouteArgs({
      'mode': 'new',
      'presetBillType': 10,
      'presetOrderId': 11,
      'presetOrderComponent': 'PRINCIPAL',
      'presetAmountCents': 60000,
    });

    expect(args.presetAmountCents, 60000);
  });

  test('updates the surviving category row by stable row ID', () async {
    final bloc = _createBloc();
    addTearDown(bloc.close);
    final ready = await _initialize(bloc);

    final firstRow = ready.categoryRows.single;
    final added = bloc.stream.firstWhere(
      (state) => state.categoryRows.length == 2,
    );
    bloc.add(const CategoryRowAdded());
    final twoRows = await added;
    final survivingRow = twoRows.categoryRows.last;

    final removed = bloc.stream.firstWhere(
      (state) => state.categoryRows.length == 1,
    );
    bloc.add(CategoryRowRemoved(firstRow.rowId));
    await removed;

    final changed = bloc.stream.firstWhere(
      (state) => state.categoryRows.single.amount == 12.5,
    );
    bloc.add(CategoryRowAmountChanged(survivingRow.rowId, 12.5));
    final updated = await changed;

    expect(updated.categoryRows.single.rowId, survivingRow.rowId);
    expect(updated.categoryRows.single.amount, 12.5);
  });

  test(
    'adds a non-transfer extra only for a category in the current split',
    () async {
      final bloc = _createBloc();
      addTearDown(bloc.close);
      final ready = await _initialize(bloc);
      final category = ready.categoryRows.single;

      final categorySelected = bloc.stream.firstWhere(
        (state) => state.categoryRows.single.categoryId == 101,
      );
      bloc.add(CategoryRowCategoryChanged(category.rowId, 101, '餐饮'));
      await categorySelected;

      final added = bloc.stream.firstWhere((state) => state.extras.length == 1);
      bloc.add(const ExtraRowAdded(categoryId: 101));
      expect((await added).extras.single.categoryId, 101);

      bloc.add(const ExtraRowAdded(categoryId: 999));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.extras, hasLength(1));
    },
  );

  test(
    'rejects a non-transfer extra whose category leaves the split',
    () async {
      final bloc = _createBloc();
      addTearDown(bloc.close);
      final ready = await _initialize(bloc);
      final category = ready.categoryRows.single;

      bloc.add(CategoryRowCategoryChanged(category.rowId, 101, '餐饮'));
      bloc.add(CategoryRowAmountChanged(category.rowId, 20));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ExtraRowAdded(categoryId: 101));
      final extra = await bloc.stream.firstWhere(
        (state) => state.extras.length == 1,
      );
      bloc.add(
        ExtraRowChanged(
          extra.extras.single.rowId,
          extra.extras.single.copyWith(amount: 12),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      bloc.add(CategoryRowCategoryChanged(category.rowId, 202, '交通'));
      bloc.add(const AccountChanged(1, '现金'));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.extras.single.categoryId, 101);
      expect(
        bloc.state.validationError,
        BillValidationError.extraCategoryNotInSplit,
      );
    },
  );

  test('preserves non-transfer extra categories when copying a bill', () async {
    final source = FortuneBillVo(
      billId: 1,
      billType: 1,
      amount: 20,
      categoryAmountPair: const [
        BillCategoryAmount(categoryId: 101, categoryName: '餐饮', amount: 20),
      ],
      extras: const [BillExtra(amount: 2, categoryId: 101)],
    );
    final bloc = _createBloc();
    addTearDown(bloc.close);

    bloc.add(
      BillEditorInitialized(BillEditorArgs(mode: 'copy', sourceBill: source)),
    );
    final state = await bloc.stream.firstWhere(
      (state) => state.status == EditorStatus.ready,
    );

    expect(state.mode, 'copy');
    expect(state.billId, isNull);
    expect(state.extras.single.categoryId, 101);
  });

  test(
    'normalizes transfer extra category and account side when prefilling',
    () async {
      final source = FortuneBillVo(
        billId: 1,
        billType: 3,
        amount: 20,
        extras: const [
          BillExtra(amount: 2, accountSide: 2, categoryId: 101),
          BillExtra(amount: 3, accountSide: 3, categoryId: 202),
        ],
      );
      final bloc = _createBloc();
      addTearDown(bloc.close);

      bloc.add(
        BillEditorInitialized(BillEditorArgs(mode: 'edit', sourceBill: source)),
      );
      final state = await bloc.stream.firstWhere(
        (state) => state.status == EditorStatus.ready,
      );

      expect(
        state.extras.map((extra) => extra.categoryId),
        everyElement(isNull),
      );
      expect(state.extras.map((extra) => extra.accountSide), [2, 1]);
    },
  );

  test('allows a zero-amount extra draft without a category', () async {
    final bloc = _createBloc();
    addTearDown(bloc.close);
    final ready = await _initialize(bloc);

    final changed = bloc.stream.firstWhere((state) => state.extras.length == 1);
    bloc.add(BillTypeChanged(FxBillType.transfer));
    await Future<void>.delayed(Duration.zero);
    bloc.add(const ExtraRowAdded());
    final withDraft = await changed;

    expect(withDraft.extras.single.categoryId, isNull);
    expect(
      withDraft.validationError,
      isNot(BillValidationError.extraCategoryRequired),
    );
    expect(
      withDraft.validationError,
      isNot(BillValidationError.extraCategoryNotInSplit),
    );
    expect(ready.extras, isEmpty);
  });

  test(
    'submits non-transfer extras with a category from the current split',
    () async {
      final service = _CapturingBillService();
      final bloc = _createBloc(billService: service);
      addTearDown(bloc.close);
      final ready = await _initialize(bloc);
      final category = ready.categoryRows.single;

      bloc.add(CategoryRowCategoryChanged(category.rowId, 101, '餐饮'));
      bloc.add(CategoryRowAmountChanged(category.rowId, 20));
      bloc.add(const AccountChanged(1, '现金'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ExtraRowAdded(categoryId: 101));
      final withExtra = await bloc.stream.firstWhere(
        (state) => state.extras.length == 1,
      );
      bloc.add(
        ExtraRowChanged(
          withExtra.extras.single.rowId,
          withExtra.extras.single.copyWith(amount: 2, remark: '服务费'),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final submitted = bloc.stream.firstWhere(
        (state) => state.submitStatus == SubmitStatus.success,
      );
      bloc.add(const BillEditorSubmitted());
      await submitted;

      final extras = service.submittedData!['extras'] as List<dynamic>;
      expect(service.submittedModify, isFalse);
      expect(extras, [
        {
          'extraType': 1,
          'amount': 2.0,
          'accountSide': 1,
          'categoryId': 101,
          'remark': '服务费',
        },
      ]);
    },
  );

  test(
    'submits transfer extras with null category IDs and valid sides',
    () async {
      final service = _CapturingBillService();
      final bloc = _createBloc(billService: service);
      addTearDown(bloc.close);
      await _initialize(bloc);

      bloc.add(BillTypeChanged(FxBillType.transfer));
      bloc.add(const TransferAmountChanged(100));
      bloc.add(const AccountChanged(1, '转出账户'));
      bloc.add(const ToAccountChanged(2, '转入账户'));
      bloc.add(const TitleChanged('账户转账'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ExtraRowAdded());
      final withExtra = await bloc.stream.firstWhere(
        (state) => state.extras.length == 1,
      );
      bloc.add(
        ExtraRowChanged(
          withExtra.extras.single.rowId,
          withExtra.extras.single.copyWith(
            amount: 3,
            accountSide: 2,
            categoryId: 101,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final submitted = bloc.stream.firstWhere(
        (state) => state.submitStatus == SubmitStatus.success,
      );
      bloc.add(const BillEditorSubmitted());
      await submitted;

      final extras = service.submittedData!['extras'] as List<dynamic>;
      expect(service.submittedData!['categoryAmountPair'], isEmpty);
      expect(extras, [
        {'extraType': 1, 'amount': 3.0, 'accountSide': 2, 'categoryId': null},
      ]);
    },
  );

  test('ignores an update for a removed extra row', () async {
    final bloc = _createBloc();
    addTearDown(bloc.close);
    final ready = await _initialize(bloc);
    final category = ready.categoryRows.single;
    bloc.add(CategoryRowCategoryChanged(category.rowId, 1, '餐饮'));
    await Future<void>.delayed(Duration.zero);

    final firstAdded = bloc.stream.firstWhere(
      (state) => state.extras.length == 1,
    );
    bloc.add(const ExtraRowAdded(categoryId: 1));
    final firstRow = (await firstAdded).extras.single;

    final secondAdded = bloc.stream.firstWhere(
      (state) => state.extras.length == 2,
    );
    bloc.add(const ExtraRowAdded(categoryId: 1));
    final twoRows = await secondAdded;
    final survivingRow = twoRows.extras.last;

    final removed = bloc.stream.firstWhere((state) => state.extras.length == 1);
    bloc.add(ExtraRowRemoved(firstRow.rowId));
    final oneRow = await removed;

    bloc.add(ExtraRowChanged(firstRow.rowId, firstRow.copyWith(amount: 99)));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state, oneRow);
    expect(bloc.state.extras.single.rowId, survivingRow.rowId);
  });

  test('transfer default title follows from/to account types', () {
    const cash = AccountOption(
      accountId: 1,
      accountName: '钱包',
      accountType: 1,
    );
    const credit = AccountOption(
      accountId: 2,
      accountName: '招行',
      accountType: 2,
    );
    const asset = AccountOption(
      accountId: 3,
      accountName: '余额宝',
      accountType: 3,
    );
    const wechat = AccountOption(
      accountId: 4,
      accountName: '微信',
      accountType: 1,
    );
    const alipay = AccountOption(
      accountId: 5,
      accountName: '支付宝',
      accountType: 1,
    );
    const options = EditorOptions(
      accounts: [cash, credit, asset, wechat, alipay],
    );

    BillEditorState state({int? from, int? to}) => BillEditorState(
      tradeTime: DateTime(2026, 1, 1),
      billType: FxBillType.transfer,
      accountId: from,
      toAccountId: to,
      options: options,
    );

    expect(state(from: 1, to: 3).suggestedTransferTitle, '转账');
    expect(state(from: 2, to: 1).suggestedTransferTitle, '提现');
    expect(state(from: 1, to: 2).suggestedTransferTitle, '还款');
    expect(state(from: 2, to: 2).suggestedTransferTitle, '还款');
    expect(state(from: 1, to: 2).effectiveTitle, '还款');
    expect(state(from: 4, to: 1).suggestedTransferTitle, '微信提现');
    expect(state(from: 5, to: 1).suggestedTransferTitle, '支付宝提现');
    expect(state(from: 4, to: 2).suggestedTransferTitle, '还款');
  });

  test('income-side associations bind reimburse like income', () {
    bool usesIncomeAssociations(FxBillType type) => BillEditorState(
      tradeTime: DateTime(2026, 1, 1),
      billType: type,
    ).usesIncomeAssociations;

    expect(usesIncomeAssociations(FxBillType.income), isTrue);
    expect(usesIncomeAssociations(FxBillType.reimburse), isTrue);
    expect(usesIncomeAssociations(FxBillType.expense), isFalse);
    expect(usesIncomeAssociations(FxBillType.advance), isFalse);
    expect(usesIncomeAssociations(FxBillType.transfer), isFalse);
  });

  test('new advance bills default to an expense-capable account', () async {
    final bloc = _createBloc();
    addTearDown(bloc.close);

    bloc.add(
      const BillEditorInitialized(
        BillEditorArgs(mode: 'new', presetBillType: 7),
      ),
    );
    final state = await bloc.stream.firstWhere(
      (state) => state.status == EditorStatus.ready,
    );

    expect(state.billType, FxBillType.advance);
    expect(state.accountId, 11);
  });

  test('new reimburse bills default to an income-capable account', () async {
    final bloc = _createBloc();
    addTearDown(bloc.close);

    bloc.add(
      const BillEditorInitialized(
        BillEditorArgs(mode: 'new', presetBillType: 8),
      ),
    );
    final state = await bloc.stream.firstWhere(
      (state) => state.status == EditorStatus.ready,
    );

    expect(state.billType, FxBillType.reimburse);
    expect(state.accountId, 22);
  });
}

Future<BillEditorState> _initialize(BillEditorBloc bloc) {
  final ready = bloc.stream.firstWhere(
    (state) => state.status == EditorStatus.ready,
  );
  bloc.add(const BillEditorInitialized(BillEditorArgs(mode: 'new')));
  return ready;
}

BillEditorBloc _createBloc({
  BillService? billService,
  bool copyUsesCurrentTime = true,
}) {
  return BillEditorBloc(
    bookId: 1,
    groupId: 1,
    optionsService: _FakeEditorOptionsService(),
    billService: billService,
    copyUsesCurrentTime: copyUsesCurrentTime,
  );
}

class _CapturingBillService extends BillService {
  Map<String, dynamic>? submittedData;
  bool? submittedModify;

  @override
  Future<void> submit(
    Map<String, dynamic> data, {
    required bool modify,
    List<BillAttachment>? attachments,
  }) async {
    submittedData = Map<String, dynamic>.from(data);
    submittedModify = modify;
  }
}

class _FakeEditorOptionsService extends EditorOptionsService {
  @override
  Future<EditorOptions> loadAll({
    required int bookId,
    required int groupId,
    FxBillType? billType,
    int pageNum = 1,
    int pageSize = 20,
    int? presetOrderId,
    String? presetOrderTitle,
  }) async {
    return const EditorOptions(
      accounts: [
        AccountOption(accountId: 11, accountName: '支出账户', canExpense: true),
        AccountOption(accountId: 22, accountName: '收入账户', canIncome: true),
      ],
    );
  }
}
