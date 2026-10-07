part of 'members_bloc.dart';

enum MembersStatus { initial, loading, loaded, error, empty }

class MembersState extends Equatable {
  final MembersStatus status;
  final List<FortuneMemberVo> members;
  final ManageTab tab;
  final String keyword;
  final String? errorMessage;
  final String? toastMessage;

  const MembersState({
    this.status = MembersStatus.initial,
    this.members = const [],
    this.tab = ManageTab.all,
    this.keyword = '',
    this.errorMessage,
    this.toastMessage,
  });

  /// 本地按 tab（enable）过滤后列表（搜索由服务端 memberName 处理）。
  List<FortuneMemberVo> get filtered {
    final enableFilter = tab.enableFilter;
    final list = enableFilter == null
        ? members
        : members.where((m) => m.enable == enableFilter).toList();
    final sorted = [...list]
      ..sort((a, b) => (a.sort ?? 0).compareTo(b.sort ?? 0));
    return sorted;
  }

  MembersState copyWith({
    MembersStatus? status,
    List<FortuneMemberVo>? members,
    ManageTab? tab,
    String? keyword,
    String? errorMessage,
    String? toastMessage,
  }) {
    return MembersState(
      status: status ?? this.status,
      members: members ?? this.members,
      tab: tab ?? this.tab,
      keyword: keyword ?? this.keyword,
      errorMessage: errorMessage,
      toastMessage: toastMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    members,
    tab,
    keyword,
    errorMessage,
    toastMessage,
  ];
}
