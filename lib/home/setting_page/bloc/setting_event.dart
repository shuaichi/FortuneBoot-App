part of 'setting_bloc.dart';

sealed class SettingEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class SettingInitDataLoaded extends SettingEvent {}

final class GroupSettingFetched extends SettingEvent {
  GroupSettingFetched({this.groupId});
  final int? groupId;
  @override
  List<Object> get props => [groupId ?? 0];
}

final class BookIdChanged extends SettingEvent {
  BookIdChanged(this.bookId, this.bookName);
  final int bookId;
  final String bookName;
  @override
  List<Object> get props => [bookId, bookName];
}
