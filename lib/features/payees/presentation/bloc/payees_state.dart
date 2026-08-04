part of 'payees_bloc.dart';

enum PayeesStatus { initial, loading, loaded, error, empty }

class PayeesState extends Equatable {
  final PayeesStatus status;
  final List<FortunePayeeVo> payees; // 当前 recycleBin 维度全部
  final ManageTab tab;
  final String keyword;
  final String? errorMessage;
  final String? toastMessage;

  const PayeesState({
    this.status = PayeesStatus.initial,
    this.payees = const [],
    this.tab = ManageTab.all,
    this.keyword = '',
    this.errorMessage,
    this.toastMessage,
  });

  /// 本地按 tab（enable）过滤后列表（搜索由服务端 payeeName 处理）。
  List<FortunePayeeVo> get filtered {
    final enableFilter = tab.enableFilter;
    final list = enableFilter == null
        ? payees
        : payees.where((p) => p.enable == enableFilter).toList();
    final sorted = [...list]
      ..sort((a, b) => (a.sort ?? 0).compareTo(b.sort ?? 0));
    return sorted;
  }

  PayeesState copyWith({
    PayeesStatus? status,
    List<FortunePayeeVo>? payees,
    ManageTab? tab,
    String? keyword,
    String? errorMessage,
    String? toastMessage,
  }) {
    return PayeesState(
      status: status ?? this.status,
      payees: payees ?? this.payees,
      tab: tab ?? this.tab,
      keyword: keyword ?? this.keyword,
      errorMessage: errorMessage,
      toastMessage: toastMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    payees,
    tab,
    keyword,
    errorMessage,
    toastMessage,
  ];
}
