part of 'books_bloc.dart';

sealed class BooksEvent extends Equatable {
  const BooksEvent();

  @override
  List<Object?> get props => [];
}

class BooksLoaded extends BooksEvent {
  const BooksLoaded({this.selectedGroupId});

  final int? selectedGroupId;

  @override
  List<Object?> get props => [selectedGroupId];
}

class BooksMutated extends BooksEvent {
  const BooksMutated();
}

class BooksGroupSelected extends BooksEvent {
  const BooksGroupSelected(this.groupId);

  final int groupId;

  @override
  List<Object?> get props => [groupId];
}

class BooksGroupSearchChanged extends BooksEvent {
  const BooksGroupSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class BooksGroupFilterChanged extends BooksEvent {
  const BooksGroupFilterChanged(this.filter);

  final GroupFilter filter;

  @override
  List<Object?> get props => [filter];
}

class BooksSearchChanged extends BooksEvent {
  const BooksSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class BooksSegmentChanged extends BooksEvent {
  const BooksSegmentChanged(this.segment);

  final BooksSegment segment;

  @override
  List<Object?> get props => [segment];
}

class BooksCapabilitiesRequested extends BooksEvent {
  const BooksCapabilitiesRequested(this.groupId);

  final int groupId;

  @override
  List<Object?> get props => [groupId];
}
