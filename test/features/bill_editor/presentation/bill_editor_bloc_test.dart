import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/bill_editor/data/editor_options_service.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_args.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_bloc.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';

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
    final oneRow = await removed;

    final changed = bloc.stream.firstWhere(
      (state) => state.categoryRows.single.amount == 12.5,
    );
    bloc.add(CategoryRowAmountChanged(survivingRow.rowId, 12.5));
    final updated = await changed;

    expect(updated.categoryRows.single.rowId, survivingRow.rowId);
    expect(updated.categoryRows.single.amount, 12.5);
  });

  test('ignores an update for a removed extra row', () async {
    final bloc = _createBloc();
    addTearDown(bloc.close);
    await _initialize(bloc);

    final firstAdded = bloc.stream.firstWhere(
      (state) => state.extras.length == 1,
    );
    bloc.add(const ExtraRowAdded());
    final firstRow = (await firstAdded).extras.single;

    final secondAdded = bloc.stream.firstWhere(
      (state) => state.extras.length == 2,
    );
    bloc.add(const ExtraRowAdded());
    final twoRows = await secondAdded;
    final survivingRow = twoRows.extras.last;

    final removed = bloc.stream.firstWhere((state) => state.extras.length == 1);
    bloc.add(ExtraRowRemoved(firstRow.rowId));
    final oneRow = await removed;

    bloc.add(
      ExtraRowChanged(
        firstRow.rowId,
        firstRow.copyWith(amount: 99),
      ),
    );
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
}

Future<BillEditorState> _initialize(BillEditorBloc bloc) {
  final ready = bloc.stream.firstWhere(
    (state) => state.status == EditorStatus.ready,
  );
  bloc.add(const BillEditorInitialized(BillEditorArgs(mode: 'new')));
  return ready;
}

BillEditorBloc _createBloc() {
  return BillEditorBloc(
    bookId: 1,
    groupId: 1,
    optionsService: _FakeEditorOptionsService(),
  );
}

class _FakeEditorOptionsService extends EditorOptionsService {
  @override
  Future<EditorOptions> loadAll({
    required int bookId,
    required int groupId,
  }) async {
    return const EditorOptions();
  }
}
