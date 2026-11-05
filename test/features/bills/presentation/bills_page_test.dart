import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/preferences/dashboard_display_preferences.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/bills/presentation/bills_page.dart';
import 'package:fortuneboot/features/bills/presentation/bloc/bills_bloc.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('older navigation stays enabled for an already loaded month', (
    tester,
  ) async {
    final fixture = _PageFixture();
    await fixture.pump(tester);

    final older = find.byKey(const ValueKey('bills-older-period'));
    expect(older, findsOneWidget);
    expect(tester.widget<InkResponse>(older).onTap, isNotNull);
  });

  testWidgets(
    'quick period picker jumps directly to a loaded historical month',
    (tester) async {
      final fixture = _PageFixture();
      await fixture.pump(tester);

      await tester.tap(find.byKey(const ValueKey('bills-period-selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2025').last);
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('bills-period-option-2025-10')),
      );
      await tester.pumpAndSettle();

      final label = tester.widget<Text>(
        find.byKey(const ValueKey('bills-current-period-label')),
      );
      expect(label.data, contains('2025年10月'));
    },
  );

  testWidgets('quick period picker loads an unloaded historical month', (
    tester,
  ) async {
    final fixture = _PageFixture(total: 3);
    await fixture.pump(tester);

    await tester.tap(find.byKey(const ValueKey('bills-period-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2025').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bills-period-option-2025-09')));
    await tester.pumpAndSettle();

    final label = tester.widget<Text>(
      find.byKey(const ValueKey('bills-current-period-label')),
    );
    expect(label.data, contains('2025年9月'));
    expect(fixture.service.queries.map((query) => query.pageNum), [1, 2]);
  });

  testWidgets('zero filtered results offer adjust and clear recovery', (
    tester,
  ) async {
    final fixture = _PageFixture();
    await fixture.pump(tester);

    await tester.tap(find.byTooltip('筛选'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '不存在');
    await tester.tap(find.text('应用'));
    await tester.pumpAndSettle();

    expect(find.text('没有符合当前筛选的账单'), findsOneWidget);
    expect(find.text('1 项筛选已启用'), findsOneWidget);
    expect(find.textContaining('标题：不存在'), findsOneWidget);
    expect(find.text('调整筛选'), findsOneWidget);
    final clear = find.text('清除筛选');
    await tester.ensureVisible(clear);
    await tester.pump();
    await tester.tap(clear);
    await tester.pumpAndSettle();

    tester
        .widget<CustomScrollView>(find.byType(CustomScrollView))
        .controller!
        .jumpTo(0);
    await tester.pump();
    expect(find.text('当前账单'), findsOneWidget);
    expect(fixture.service.queries.last.title, isNull);
  });

  testWidgets('sticky day headers grow with the system text scaler', (
    tester,
  ) async {
    final fixture = _PageFixture(textScale: 2, size: const Size(320, 700));
    await fixture.pump(tester);

    final header = tester.widget<SliverPersistentHeader>(
      find.byType(SliverPersistentHeader).first,
    );
    expect(header.delegate.maxExtent, greaterThan(40));
    expect(header.delegate.maxExtent, header.delegate.minExtent);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pagination failure retains context and shows a retry action', (
    tester,
  ) async {
    final fixture = _PageFixture(total: 3, failPageTwo: true);
    await fixture.pump(tester);
    final bloc = fixture.bloc;
    bloc.add(const BillsNextPageRequested());
    await tester.pumpAndSettle();

    expect(find.text('当前账单'), findsOneWidget);
    expect(find.textContaining('后续账单加载失败'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
  });

  testWidgets('swipe confirmation deletes the swiped bill only', (
    tester,
  ) async {
    final fixture = _PageFixture();
    await fixture.pump(tester);

    await tester.drag(find.text('历史账单'), const Offset(-220, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除').last);
    await tester.pumpAndSettle();

    expect(fixture.service.deletedBillIds, [2]);
    expect(find.text('当前账单'), findsOneWidget);
  });

  testWidgets(
    'short landscape keeps title fixed while period controls scroll',
    (tester) async {
      final fixture = _PageFixture(textScale: 2, size: const Size(640, 320));
      await fixture.pump(tester);

      final summary = find.byKey(const ValueKey('bills-period-summary'));
      final title = find.text('账单');
      final summaryTop = tester.getTopLeft(summary).dy;
      final titleTop = tester.getTopLeft(title).dy;
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -80));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(summary).dy, lessThan(summaryTop));
      expect(tester.getTopLeft(title).dy, titleTop);
      await tester.scrollUntilVisible(
        find.text('当前账单'),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

class _PageFixture {
  _PageFixture({
    this.textScale = 1,
    this.size = const Size(390, 844),
    int total = 2,
    bool failPageTwo = false,
  }) : service = _FakeBillService(total: total, failPageTwo: failPageTwo) {
    bloc = BillsBloc(bookId: 7, service: service, now: DateTime(2026, 11, 5));
    session = _TestSessionCubit();
    preferences = _TestPreferencesCubit();
  }

  final double textScale;
  final Size size;
  final _FakeBillService service;
  late final BillsBloc bloc;
  late final SessionCubit session;
  late final PreferencesCubit preferences;

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(() {
      bloc.close();
      session.close();
      preferences.close();
    });
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: session),
          BlocProvider.value(value: preferences),
          BlocProvider.value(value: bloc),
        ],
        child: MaterialApp(
          theme: FxTheme.light,
          locale: const Locale('zh'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            S.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: BillsPage(detailService: service),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
  }
}

class _TestSessionCubit extends SessionCubit {
  _TestSessionCubit() : super() {
    emit(
      const SessionState(
        status: SessionStatus.ready,
        currentGroup: FortuneGroupVo(roleType: 2),
        currentBook: FortuneBookVo(bookId: 7, defaultCurrency: 'CNY'),
      ),
    );
  }
}

class _TestPreferencesCubit extends PreferencesCubit {
  _TestPreferencesCubit() : super() {
    emit(state.copyWith(dashboard: const DashboardDisplayPreferences()));
  }
}

class _FakeBillService extends BillService {
  _FakeBillService({required this.total, required this.failPageTwo});

  final int total;
  final bool failPageTwo;
  final queries = <BillQuery>[];
  final deletedBillIds = <int>[];

  @override
  Future<BillPage> getPage(BillQuery query) async {
    queries.add(query);
    if (query.title == '不存在') return const BillPage();
    if (query.pageNum == 2) {
      if (failPageTwo) throw FxApiException(-1, '分页失败');
      return BillPage(
        rows: [_bill(3, '更早账单', DateTime(2025, 9))],
        total: total,
      );
    }
    return BillPage(
      rows: [
        _bill(1, '当前账单', DateTime(2026, 11, 3, 8)),
        _bill(2, '历史账单', DateTime(2025, 10, 4, 9)),
      ],
      total: total,
    );
  }

  @override
  Future<BillStatistics> getStatistics({
    required int bookId,
    required String tradeTimeStartTime,
    required String tradeTimeEndTime,
  }) async => const BillStatistics(expense: 20, income: 30, surplus: 10);

  @override
  Future<void> remove({required int bookId, required int billId}) async {
    deletedBillIds.add(billId);
  }
}

FortuneBillVo _bill(int id, String title, DateTime tradeTime) => FortuneBillVo(
  billId: id,
  title: title,
  tradeTime: tradeTime,
  amount: 10,
  billType: FxBillType.expense.value,
  currencyCode: 'CNY',
);
