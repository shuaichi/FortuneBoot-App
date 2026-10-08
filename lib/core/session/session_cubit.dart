import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/errors/fx_failure.dart';
import 'package:fortuneboot/core/errors/fx_failure_mapper.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/books/data/books_service.dart';
import 'package:fortuneboot/request/book_request.dart';
import 'package:fortuneboot/request/group_request.dart';

part 'session_state.dart';

/// 全局会话：当前分组/账本/币种。取代各页面散取 UserDataSingleton。
/// 进入 MainShell 时 [load]，退出登录时 [reset]。
class SessionCubit extends Cubit<SessionState> {
  SessionCubit({
    GroupService? groupService,
    BookService? bookService,
    BooksService? booksService,
  }) : _groupService = groupService ?? GroupService(),
       _bookService = bookService ?? BookService(),
       _booksService = booksService ?? BooksService(),
       super(const SessionState());

  final GroupService _groupService;
  final BookService _bookService;
  final BooksService _booksService;

  /// 启动拉取链：默认分组 → 分组列表 → 该分组账本 → 默认账本。
  Future<void> load() async {
    emit(state.copyWith(status: SessionStatus.loading));
    try {
      // 1. 分组列表
      final groupsData = FxApi.unwrap(await _groupService.getEnableList());
      final groups = (groupsData as List? ?? [])
          .map(
            (e) => FortuneGroupVo.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();

      if (groups.isEmpty) {
        emit(state.copyWith(status: SessionStatus.empty, groups: const []));
        return;
      }

      // 2. 默认分组 id
      int? defaultGroupId;
      try {
        final d = FxApi.unwrap(await _groupService.getDefaultGroupId());
        defaultGroupId = FxApi.asId(d);
      } catch (_) {
        defaultGroupId = null;
      }

      final selectedGroup = groups.firstWhere(
        (g) => g.groupId == defaultGroupId,
        orElse: () => groups.first,
      );
      final groupId = selectedGroup.groupId;
      if (groupId == null) {
        throw StateError('Selected group has no groupId');
      }

      await _loadGroupAndBooks(groups, groupId);
    } on Object catch (error) {
      _emitFailure(error);
    }
  }

  void _emitFailure(Object error) {
    emit(
      state.copyWith(
        status: SessionStatus.error,
        failure: FxFailureMapper.map(error),
      ),
    );
  }

  Future<void> _loadGroupAndBooks(
    List<FortuneGroupVo> groups,
    int groupId,
  ) async {
    final groupData = FxApi.unwrap(await _groupService.getByGroupId(groupId));
    if (groupData is! Map) {
      throw StateError('Group detail is invalid');
    }
    final detail = FortuneGroupVo.fromJson(
      Map<String, dynamic>.from(groupData),
    );
    FortuneGroupVo? listed;
    for (final g in groups) {
      if (g.groupId == detail.groupId) {
        listed = g;
        break;
      }
    }
    // getByGroupId 不含当前用户角色；必须从 getEnableList 结果补齐，否则会误判为访客。
    var currentGroup = detail.withRoleFrom(listed);
    final currentGroupId = currentGroup.groupId;
    if (currentGroupId == null) {
      throw StateError('Group detail has no groupId');
    }

    // 历史脏数据：defaultCurrency 误存成 currencyId（如 "33"），启动时自动写回币种代码。
    currentGroup = await _repairGroupCurrency(currentGroup);
    final updatedGroups = [
      for (final g in groups)
        if (g.groupId == currentGroup.groupId) currentGroup else g,
    ];

    final booksData = FxApi.unwrap(
      await _bookService.getByGroupId(currentGroupId),
    );
    var books = (booksData as List? ?? [])
        .map((e) => FortuneBookVo.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    books = await _repairBookCurrencies(books);

    FortuneBookVo? currentBook;
    if (books.isNotEmpty) {
      currentBook = books.firstWhere(
        (b) => b.bookId == currentGroup.defaultBookId,
        orElse: () => books.first,
      );
    }

    emit(
      state.copyWith(
        status: currentBook == null ? SessionStatus.empty : SessionStatus.ready,
        groups: updatedGroups,
        currentGroup: currentGroup,
        books: books,
        currentBook: currentBook,
      ),
    );
  }

  bool _isCurrencyId(String? raw) =>
      raw != null && RegExp(r'^\d+$').hasMatch(raw.trim());

  Future<FortuneGroupVo> _repairGroupCurrency(FortuneGroupVo group) async {
    if (!_isCurrencyId(group.defaultCurrency)) return group;
    try {
      final code = await _booksService.requireCurrencyCode(
        group.defaultCurrency,
      );
      if (group.groupId != null && group.groupName != null) {
        await _booksService.modifyGroup({
          'groupId': group.groupId,
          'groupName': group.groupName,
          'defaultCurrency': code,
          'enable': group.enable,
          if (group.defaultBookId != null) 'defaultBookId': group.defaultBookId,
          if (group.remark != null && group.remark!.isNotEmpty)
            'remark': group.remark,
        });
      }
      return group.copyWith(defaultCurrency: code);
    } on Object {
      final fallback = group.defaultCurrency?.trim() == '33'
          ? 'CNY'
          : group.defaultCurrency;
      return group.copyWith(defaultCurrency: fallback);
    }
  }

  Future<List<FortuneBookVo>> _repairBookCurrencies(
    List<FortuneBookVo> books,
  ) async {
    final out = <FortuneBookVo>[];
    for (final book in books) {
      if (!_isCurrencyId(book.defaultCurrency)) {
        out.add(book);
        continue;
      }
      try {
        final code = await _booksService.requireCurrencyCode(
          book.defaultCurrency,
        );
        if (book.bookId != null &&
            book.groupId != null &&
            book.bookName != null) {
          await _booksService.modifyBook({
            'bookId': book.bookId,
            'groupId': book.groupId,
            'bookName': book.bookName,
            'defaultCurrency': code,
            'enable': book.enable,
            if (book.defaultExpenseAccountId != null)
              'defaultExpenseAccountId': book.defaultExpenseAccountId,
            if (book.defaultIncomeAccountId != null)
              'defaultIncomeAccountId': book.defaultIncomeAccountId,
            if (book.defaultTransferOutAccountId != null)
              'defaultTransferOutAccountId': book.defaultTransferOutAccountId,
            if (book.defaultTransferInAccountId != null)
              'defaultTransferInAccountId': book.defaultTransferInAccountId,
            if (book.sort != null) 'sort': book.sort,
            if (book.remark != null && book.remark!.isNotEmpty)
              'remark': book.remark,
          });
        }
        out.add(book.copyWith(defaultCurrency: code));
      } on Object {
        final fallback = book.defaultCurrency?.trim() == '33'
            ? 'CNY'
            : book.defaultCurrency;
        out.add(book.copyWith(defaultCurrency: fallback));
      }
    }
    return out;
  }

  /// 切换分组：重拉该分组账本并选默认账本。
  Future<void> switchGroup(FortuneGroupVo group) async {
    if (group.groupId == state.currentGroupId &&
        state.status != SessionStatus.error) {
      return;
    }
    emit(
      SessionState(
        status: SessionStatus.loading,
        groups: state.groups,
        currentGroup: group,
      ),
    );
    final groupId = group.groupId;
    if (groupId == null) {
      _emitFailure(StateError('Selected group has no groupId'));
      return;
    }
    try {
      await _loadGroupAndBooks(state.groups, groupId);
    } on Object catch (error) {
      _emitFailure(error);
    }
  }

  /// 切换账本。
  void switchBook(FortuneBookVo book) {
    if (book.bookId == state.currentBookId) return;
    emit(state.copyWith(currentBook: book, status: SessionStatus.ready));
  }

  /// 原子切换到指定分组下的指定账本：保证 currentGroup 与 currentBook 属于同一分组，
  /// 避免“设默认账本”时先 load() 切到默认分组、再 switchBook 塞入他组账本导致的错配。
  /// [group] 为账本所属分组；若与当前分组不同会重拉该分组账本列表。
  Future<void> selectGroupAndBook(
    FortuneGroupVo group,
    FortuneBookVo book,
  ) async {
    if (group.groupId == null) return;
    if (group.groupId == state.currentGroupId) {
      switchBook(book);
      return;
    }
    emit(state.copyWith(status: SessionStatus.loading));
    try {
      final booksData = FxApi.unwrap(
        await _bookService.getByGroupId(group.groupId!),
      );
      var books = (booksData as List? ?? [])
          .map(
            (e) => FortuneBookVo.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
      books = await _repairBookCurrencies(books);
      final repairedGroup = await _repairGroupCurrency(group);
      // 用列表中的同 id 实例，避免持有过期副本。
      final target = books.firstWhere(
        (b) => b.bookId == book.bookId,
        orElse: () => book,
      );
      emit(
        state.copyWith(
          status: SessionStatus.ready,
          currentGroup: repairedGroup,
          books: books,
          currentBook: target,
        ),
      );
    } on Object catch (error) {
      _emitFailure(error);
    }
  }

  void reset() => emit(const SessionState());
}
