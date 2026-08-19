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
