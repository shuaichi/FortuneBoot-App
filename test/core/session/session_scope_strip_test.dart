import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/core/session/widgets/session_scope_strip.dart';
import 'package:fortuneboot/core/session/widgets/session_scoped_page.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/login/model/login_model.dart';
import 'package:fortuneboot/request/book_request.dart';
import 'package:fortuneboot/request/group_request.dart';

void main() {
  testWidgets('pending switch is labelled without renaming the current scope', (
    tester,
  ) async {
    final state = SessionState(
      status: SessionStatus.loading,
      currentGroup: _group(1, 'Group 1'),
      currentBook: _book(11, 'Book 1'),
      pendingGroup: _group(2, 'Group 2'),
      books: [_book(11, 'Book 1')],
    );
    await _pumpStrip(tester, state: state);

    expect(find.text('Group 1'), findsOneWidget);
    expect(find.text('Book 1'), findsOneWidget);
    expect(find.text('正在切换到「Group 2」…'), findsOneWidget);
    expect(find.text('Group 2'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('group-level scope does not imply a book', (tester) async {
    final state = SessionState(
      status: SessionStatus.ready,
      currentGroup: _group(1, 'Group 1'),
      currentBook: _book(11, 'Book 1'),
      books: [_book(11, 'Book 1')],
    );
    await _pumpStrip(tester, state: state, level: SessionScopeLevel.group);

    expect(find.text('Group 1'), findsOneWidget);
    expect(find.text('Book 1'), findsNothing);
  });

  testWidgets('reload labels the retained scope as updating', (tester) async {
    final state = SessionState(
      status: SessionStatus.loading,
      currentGroup: _group(1, 'Group 1'),
      currentBook: _book(11, 'Book 1'),
      books: [_book(11, 'Book 1')],
    );
    await _pumpStrip(tester, state: state);

    expect(find.text('Group 1'), findsOneWidget);
    expect(find.text('Book 1'), findsOneWidget);
    expect(find.text('正在更新当前范围…'), findsOneWidget);
  });

  testWidgets('large text and long names wrap without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final state = SessionState(
      status: SessionStatus.ready,
      currentGroup: _group(1, '家庭共同生活分组与长期目标'),
      currentBook: _book(11, '家庭共同生活与长期储蓄账本 2026 年度'),
      books: [_book(11, '家庭共同生活与长期储蓄账本 2026 年度')],
    );
    await _pumpStrip(tester, state: state, textScale: 2);

    expect(tester.takeException(), isNull);
    expect(find.text('家庭共同生活与长期储蓄账本 2026 年度'), findsOneWidget);
  });

  testWidgets('scope change rebuilds the page bound to the new book', (
    tester,
  ) async {
    final session = SessionCubit(
      groupService: const _ReadyGroupService(),
      bookService: const _ReadyBookService(),
    );
    addTearDown(session.close);
    await session.load();
    _ScopedCounter.reset();
    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        locale: const Locale('zh'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: BlocProvider<SessionCubit>.value(
          value: session,
          child: const Scaffold(
            body: SessionScopedPage(child: _ScopedCounter()),
          ),
        ),
      ),
    );
    session.switchBook(_book(12, 'Book 2'));
    await tester.pump();

    expect(session.state.currentBookId, 12);
    expect(find.text('Book 2'), findsOneWidget);
    expect(_ScopedCounter.builds, 2);
    expect(find.text('Book 2 rebuilt'), findsOneWidget);
  });
}

Future<void> _pumpStrip(
  WidgetTester tester, {
  required SessionState state,
  SessionScopeLevel level = SessionScopeLevel.book,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: FxTheme.light,
      locale: const Locale('zh'),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child ?? const SizedBox.shrink(),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        S.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        body: SessionScopeStrip(state: state, level: level),
      ),
    ),
  );
  await tester.pump();
}

FortuneGroupVo _group(int id, String name) => FortuneGroupVo(
  groupId: id,
  groupName: name,
  roleType: 1,
  defaultBookId: 11,
);

FortuneBookVo _book(int id, String name) => FortuneBookVo(
  bookId: id,
  groupId: 1,
  bookName: name,
  defaultCurrency: 'CNY',
);

class _ScopedCounter extends StatefulWidget {
  const _ScopedCounter();

  static int builds = 0;

  static void reset() => builds = 0;

  @override
  State<_ScopedCounter> createState() => _ScopedCounterState();
}

class _ScopedCounterState extends State<_ScopedCounter> {
  @override
  void initState() {
    super.initState();
    _ScopedCounter.builds++;
  }

  @override
  Widget build(BuildContext context) {
    final bookName = context.read<SessionCubit>().state.currentBook?.bookName;
    return Center(child: Text('$bookName rebuilt'));
  }
}

class _ReadyGroupService implements GroupService {
  const _ReadyGroupService();

  @override
  Future<HJResponse> getEnableList() async => HJResponse(0, 'ok', [
    <String, dynamic>{
      'groupId': 1,
      'groupName': 'Group 1',
      'defaultCurrency': 'CNY',
      'roleType': 1,
      'defaultBookId': 11,
    },
  ]);

  @override
  Future<HJResponse> getDefaultGroupId() async => HJResponse(0, 'ok', 1);

  @override
  Future<HJResponse> getByGroupId(int groupId) async =>
      HJResponse(0, 'ok', <String, dynamic>{
        'groupId': 1,
        'groupName': 'Group 1',
        'defaultCurrency': 'CNY',
        'defaultBookId': 11,
      });
}

class _ReadyBookService implements BookService {
  const _ReadyBookService();

  @override
  Future<HJResponse> getByGroupId(int groupId) async => HJResponse(0, 'ok', [
    <String, dynamic>{
      'bookId': 11,
      'groupId': 1,
      'bookName': 'Book 1',
      'defaultCurrency': 'CNY',
    },
  ]);

  @override
  Future<HJResponse> getEnableList(int id, {int? type}) =>
      throw UnimplementedError();
}
