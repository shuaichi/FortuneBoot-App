import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/accounts/data/account_models.dart';
import 'package:fortuneboot/features/accounts/data/account_service.dart';

part 'accounts_event.dart';
part 'accounts_state.dart';

/// 账户 Bloc：拉账户列表（按类型分组）+ 净资产；开关乐观更新。
///
/// 订阅由页面转发的 [AccountsGroupChanged]，切分组重拉。
class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  final AccountService _service;
  int? _groupId;

  AccountsBloc({
    AccountService? service,
    int? groupId,
    String? currencyCode,
  }) : _service = service ?? AccountService(),
       _groupId = groupId,
       super(AccountsState(currencyCode: currencyCode)) {
    on<AccountsLoaded>(_onLoaded);
    on<AccountsMutated>(_onLoaded);
    on<AccountsGroupChanged>(_onGroupChanged);
    on<AccountToggleChanged>(_onToggleChanged);
  }

  Future<void> _onGroupChanged(
    AccountsGroupChanged event,
    Emitter<AccountsState> emit,
  ) async {
    if (event.groupId == _groupId && state.status != AccountsStatus.initial) {
      return;
    }
    _groupId = event.groupId;
    await _load(emit);
  }

  Future<void> _onLoaded(
    AccountsEvent event,
    Emitter<AccountsState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<AccountsState> emit) async {
    final groupId = _groupId;
    if (groupId == null) {
      emit(state.copyWith(status: AccountsStatus.empty, accounts: const []));
      return;
    }
    emit(state.copyWith(status: AccountsStatus.loading));
    try {
      final results = await Future.wait([
        _service.getAllAccounts(groupId),
        _service.getAssetsLiabilities(groupId),
      ]);
      final accounts = results[0] as List<FortuneAccountVo>;
      final assets = results[1] as AssetsLiabilities;
      emit(
        state.copyWith(
          status: accounts.isEmpty
              ? AccountsStatus.empty
              : AccountsStatus.loaded,
          accounts: accounts,
          assets: assets,
        ),
      );
    } on FxApiException catch (e) {
      emit(state.copyWith(status: AccountsStatus.error, errorMessage: e.message));
    } on Object catch (e) {
      emit(
        state.copyWith(status: AccountsStatus.error, errorMessage: e.toString()),
      );
    }
  }

  /// 开关乐观更新：先本地翻转，调 PATCH，失败回滚 + toast。
  Future<void> _onToggleChanged(
    AccountToggleChanged event,
    Emitter<AccountsState> emit,
  ) async {
    final groupId = _groupId;
    final accountId = event.account.accountId;
    if (groupId == null || accountId == null) return;

    final original = state.accounts;
    final optimistic = _applyToggle(original, accountId, event.field, event.value);
    emit(state.copyWith(accounts: optimistic));

    try {
      await _service.toggle(
        groupId: groupId,
        accountId: accountId,
        action: event.field.action(event.value),
      );
      // include（计入净资产）开关改变净资产口径，需重拉净资产刷新顶部卡片。
      if (event.field == AccountToggleField.include) {
        try {
          final assets = await _service.getAssetsLiabilities(groupId);
          emit(state.copyWith(assets: assets));
        } on Object catch (_) {
          // 净资产重拉失败不影响开关本身的成功语义，静默忽略。
        }
      }
    } on Object catch (e) {
      // 回滚。
      emit(
        state.copyWith(
          accounts: original,
          toastMessage: '${event.field.label}切换失败：'
              '${e is FxApiException ? e.message : e.toString()}',
        ),
      );
    }
  }

  List<FortuneAccountVo> _applyToggle(
    List<FortuneAccountVo> list,
    int accountId,
    AccountToggleField field,
    bool value,
  ) {
    return list.map((a) {
      if (a.accountId != accountId) return a;
      switch (field) {
        case AccountToggleField.canExpense:
          return a.copyWith(canExpense: value);
        case AccountToggleField.canIncome:
          return a.copyWith(canIncome: value);
        case AccountToggleField.canTransferOut:
          return a.copyWith(canTransferOut: value);
        case AccountToggleField.canTransferIn:
          return a.copyWith(canTransferIn: value);
        case AccountToggleField.include:
          return a.copyWith(include: value);
        case AccountToggleField.enable:
          return a.copyWith(enable: value);
      }
    }).toList();
  }
}
