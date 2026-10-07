part of 'members_bloc.dart';

sealed class MembersEvent extends Equatable {
  const MembersEvent();

  @override
  List<Object?> get props => [];
}

class MembersLoaded extends MembersEvent {
  const MembersLoaded();
}

class MembersBookChanged extends MembersEvent {
  final int? bookId;
  const MembersBookChanged(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

class MembersTabChanged extends MembersEvent {
  final ManageTab tab;
  const MembersTabChanged(this.tab);

  @override
  List<Object?> get props => [tab];
}

class MembersSearchChanged extends MembersEvent {
  final String keyword;
  const MembersSearchChanged(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class MembersMutated extends MembersEvent {
  const MembersMutated();
}

/// 启用开关乐观更新。
class MemberEnableToggled extends MembersEvent {
  final FortuneMemberVo member;
  final bool value;
  const MemberEnableToggled({required this.member, required this.value});

  @override
  List<Object?> get props => [member.memberId, value];
}
