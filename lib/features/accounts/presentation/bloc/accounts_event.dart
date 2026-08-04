part of 'accounts_bloc.dart';

/// 账户 feature 事件。
sealed class AccountsEvent extends Equatable {
  const AccountsEvent();

  @override
  List<Object?> get props => [];
}

/// 首次/切分组加载或下拉刷新：并发拉账户列表 + 净资产。
class AccountsLoaded extends AccountsEvent {
  const AccountsLoaded();
}

/// SessionCubit 分组变化 → 重拉。
class AccountsGroupChanged extends AccountsEvent {
  final int? groupId;
  const AccountsGroupChanged(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

/// 切换某账户的某个开关（乐观更新，失败回滚）。
class AccountToggleChanged extends AccountsEvent {
  final FortuneAccountVo account;
  final AccountToggleField field;
  final bool value;

  const AccountToggleChanged({
    required this.account,
    required this.field,
    required this.value,
  });

  @override
  List<Object?> get props => [account.accountId, field, value];
}

/// 写操作（新增/修改/余额调整/回收站/删除）成功后要求刷新列表 + 净资产。
class AccountsMutated extends AccountsEvent {
  const AccountsMutated();
}
