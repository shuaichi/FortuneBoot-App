part of 'accounts_bloc.dart';

enum AccountsStatus { initial, loading, loaded, error, empty }

/// 按账户类型分组（现金1 → 信用卡2 → 资产3 → 贷款4），含组内小计。
class AccountGroup extends Equatable {
  final AccountTypeMeta meta;
  final List<FortuneAccountVo> accounts;

  const AccountGroup({required this.meta, required this.accounts});

  /// 组内余额小计（负债类为负）。
  double get subtotal =>
      accounts.fold<double>(0, (s, a) => s + a.displayBalance);

  @override
  List<Object?> get props => [meta.id, accounts];
}

class AccountsState extends Equatable {
  final AccountsStatus status;
  final List<FortuneAccountVo> accounts;
  final AssetsLiabilities assets;
  final String? errorMessage;
  final String? toastMessage;
  final String? currencyCode;

  const AccountsState({
    this.status = AccountsStatus.initial,
    this.accounts = const [],
    this.assets = const AssetsLiabilities(),
    this.errorMessage,
    this.toastMessage,
    this.currencyCode,
  });

  /// 按类型分组，仅保留有账户的组，按 [AccountTypeMeta.ordered] 排序。
  List<AccountGroup> get groups {
    final byType = <int, List<FortuneAccountVo>>{};
    for (final a in accounts) {
      final meta = AccountTypeMeta.of(a.accountType);
      byType.putIfAbsent(meta.id, () => []).add(a);
    }
    final result = <AccountGroup>[];
    for (final meta in AccountTypeMeta.ordered) {
      final list = byType.remove(meta.id);
      if (list != null && list.isNotEmpty) {
        list.sort((x, y) => (x.sort ?? 0).compareTo(y.sort ?? 0));
        result.add(AccountGroup(meta: meta, accounts: list));
      }
    }
    // 其他/未知类型兜底组。
    final leftovers = byType.values.expand((e) => e).toList();
    if (leftovers.isNotEmpty) {
      result.add(
        AccountGroup(meta: AccountTypeMeta.unknown, accounts: leftovers),
      );
    }
    return result;
  }

  AccountsState copyWith({
    AccountsStatus? status,
    List<FortuneAccountVo>? accounts,
    AssetsLiabilities? assets,
    String? errorMessage,
    String? toastMessage,
    String? currencyCode,
  }) {
    return AccountsState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      assets: assets ?? this.assets,
      errorMessage: errorMessage,
      toastMessage: toastMessage,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    accounts,
    assets,
    errorMessage,
    toastMessage,
    currencyCode,
  ];
}
