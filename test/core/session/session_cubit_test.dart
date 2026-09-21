import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/errors/fx_failure.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/login/model/login_model.dart';
import 'package:fortuneboot/request/book_request.dart';
import 'package:fortuneboot/request/group_request.dart';

void main() {
  group('SessionCubit', () {
    test(
      'uses group detail default book instead of enabled group data',
      () async {
        final groups = _FakeGroupService(
          enabledGroups: [
            _group(id: 1, defaultBookId: 101),
            _group(id: 2, defaultBookId: 201),
          ],
          defaultGroupId: 1,
          groupDetails: {1: _group(id: 1, defaultBookId: 102)},
        );
        final books = _FakeBookService({
          1: [_book(id: 101, groupId: 1), _book(id: 102, groupId: 1)],
        });
        final cubit = SessionCubit(groupService: groups, bookService: books);
        addTearDown(cubit.close);

        await cubit.load();

        expect(cubit.state.status, SessionStatus.ready);
        expect(cubit.state.currentGroup?.defaultBookId, 102);
        expect(cubit.state.currentBookId, 102);
        expect(groups.requestedGroupIds, [1]);
      },
    );

    test('falls back to first enabled group then loads its detail', () async {
      final groups = _FakeGroupService(
        enabledGroups: [_group(id: 1, defaultBookId: 101)],
        defaultGroupError: true,
        groupDetails: {1: _group(id: 1, defaultBookId: 102)},
      );
      final books = _FakeBookService({
        1: [_book(id: 101, groupId: 1), _book(id: 102, groupId: 1)],
      });
      final cubit = SessionCubit(groupService: groups, bookService: books);
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.currentBookId, 102);
      expect(groups.requestedGroupIds, [1]);
    });

    test('uses group detail default book when switching groups', () async {
      final groups = _FakeGroupService(
        enabledGroups: [
          _group(id: 1, defaultBookId: 101),
          _group(id: 2, defaultBookId: 201),
        ],
        defaultGroupId: 1,
        groupDetails: {
          1: _group(id: 1, defaultBookId: 101),
          2: _group(id: 2, defaultBookId: 202),
        },
      );
      final books = _FakeBookService({
        1: [_book(id: 101, groupId: 1)],
        2: [_book(id: 201, groupId: 2), _book(id: 202, groupId: 2)],
      });
      final cubit = SessionCubit(groupService: groups, bookService: books);
      addTearDown(cubit.close);

      await cubit.load();
      await cubit.switchGroup(
        FortuneGroupVo.fromJson(_group(id: 2, defaultBookId: 201)),
      );

      expect(cubit.state.currentGroup?.groupId, 2);
      expect(cubit.state.currentGroup?.defaultBookId, 202);
      expect(cubit.state.currentBookId, 202);
    });

    test('retries the failed target group detail request', () async {
      final groups = _FakeGroupService(
        enabledGroups: [_group(id: 1), _group(id: 2)],
        defaultGroupId: 1,
        groupDetails: {
          1: _group(id: 1, defaultBookId: 101),
          2: _group(id: 2, defaultBookId: 202),
        },
      );
      final books = _FakeBookService({
        1: [_book(id: 101, groupId: 1)],
        2: [_book(id: 201, groupId: 2), _book(id: 202, groupId: 2)],
      });
      final cubit = SessionCubit(groupService: groups, bookService: books);
      addTearDown(cubit.close);

      await cubit.load();
      groups.groupDetailError = true;
      await cubit.switchGroup(FortuneGroupVo.fromJson(_group(id: 2)));

      expect(cubit.state.status, SessionStatus.error);
      expect(cubit.state.currentGroupId, 2);

      groups.groupDetailError = false;
      await cubit.switchGroup(FortuneGroupVo.fromJson(_group(id: 2)));

      expect(cubit.state.status, SessionStatus.ready);
      expect(cubit.state.currentGroupId, 2);
      expect(cubit.state.currentBookId, 202);
      expect(groups.requestedGroupIds, [1, 2, 2]);
    });

    test(
      'falls back to first book when detail default book is unavailable',
      () async {
        final groups = _FakeGroupService(
          enabledGroups: [_group(id: 1)],
          defaultGroupId: 1,
          groupDetails: {1: _group(id: 1, defaultBookId: 999)},
        );
        final books = _FakeBookService({
          1: [_book(id: 101, groupId: 1), _book(id: 102, groupId: 1)],
        });
        final cubit = SessionCubit(groupService: groups, bookService: books);
        addTearDown(cubit.close);

        await cubit.load();

        expect(cubit.state.status, SessionStatus.ready);
        expect(cubit.state.currentBookId, 101);
      },
    );

    test('maps a timeout to a safe failure without raw details', () async {
      final groups = _FakeGroupService(
        enabledGroups: [_group(id: 1)],
        defaultGroupId: 1,
        groupDetailException: DioException(
          requestOptions: RequestOptions(
            path: 'https://example.test/token=secret',
          ),
          type: DioExceptionType.receiveTimeout,
          message: 'token=secret',
        ),
      );
      final cubit = SessionCubit(
        groupService: groups,
        bookService: const _FakeBookService({}),
      );
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.status, SessionStatus.error);
      expect(cubit.state.failure?.kind, FxFailureKind.timeout);
      expect(cubit.state.errorMessage, isNull);
    });

    test('emits error when group detail cannot be loaded', () async {
      final groups = _FakeGroupService(
        enabledGroups: [_group(id: 1)],
        defaultGroupId: 1,
        groupDetailError: true,
      );
      final cubit = SessionCubit(
        groupService: groups,
        bookService: const _FakeBookService({}),
      );
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.status, SessionStatus.error);
      expect(cubit.state.currentBook, isNull);
    });

    test(
      'keeps group detail and emits empty when its book list is empty',
      () async {
        final groups = _FakeGroupService(
          enabledGroups: [_group(id: 1)],
          defaultGroupId: 1,
          groupDetails: {1: _group(id: 1, defaultBookId: 101)},
        );
        final cubit = SessionCubit(
          groupService: groups,
          bookService: const _FakeBookService({}),
        );
        addTearDown(cubit.close);

        await cubit.load();

        expect(cubit.state.status, SessionStatus.empty);
        expect(cubit.state.currentGroup?.groupId, 1);
        expect(cubit.state.currentBook, isNull);
      },
    );
  });
}

Map<String, dynamic> _group({required int id, int? defaultBookId}) => {
  'groupId': id,
  'groupName': 'Group $id',
  'defaultBookId': defaultBookId,
};

Map<String, dynamic> _book({required int id, required int groupId}) => {
  'bookId': id,
  'groupId': groupId,
  'bookName': 'Book $id',
};

class _FakeGroupService implements GroupService {
  _FakeGroupService({
    required this.enabledGroups,
    this.defaultGroupId,
    this.groupDetails = const {},
    this.defaultGroupError = false,
    this.groupDetailError = false,
    this.groupDetailException,
  });

  final List<Map<String, dynamic>> enabledGroups;
  final int? defaultGroupId;
  final Map<int, Map<String, dynamic>> groupDetails;
  final bool defaultGroupError;
  bool groupDetailError;
  final Object? groupDetailException;
  final requestedGroupIds = <int>[];

  @override
  Future<HJResponse> getEnableList() async =>
      HJResponse(0, 'ok', enabledGroups);

  @override
  Future<HJResponse> getDefaultGroupId() async {
    if (defaultGroupError) throw StateError('default group failed');
    return HJResponse(0, 'ok', defaultGroupId);
  }

  @override
  Future<HJResponse> getByGroupId(int groupId) async {
    requestedGroupIds.add(groupId);
    if (groupDetailException case final exception?) throw exception;
    if (groupDetailError) throw StateError('group detail failed');
    return HJResponse(0, 'ok', groupDetails[groupId]);
  }
}

class _FakeBookService implements BookService {
  const _FakeBookService(this.booksByGroup);

  final Map<int, List<Map<String, dynamic>>> booksByGroup;

  @override
  Future<HJResponse> getByGroupId(int groupId) async =>
      HJResponse(0, 'ok', booksByGroup[groupId] ?? const []);

  @override
  Future<HJResponse> getEnableList(int id, {int? type}) =>
      throw UnimplementedError();
}
