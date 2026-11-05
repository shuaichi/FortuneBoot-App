import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
  TestWidgetsFlutterBinding.ensureInitialized();
  const outputDir =
      'docs/design-system/execution-prompts/evidence/S4-A/attempt-001';

  setUpAll(() async {
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    for (final entry in {
      'PreviewCJK': '/System/Library/Fonts/Hiragino Sans GB.ttc',
      'PreviewSystem': '/System/Library/Fonts/SFNS.ttf',
    }.entries) {
      final loader = FontLoader(entry.key);
      loader.addFont(
        File(entry.value).readAsBytes().then(ByteData.sublistView),
      );
      await loader.load();
    }
  });

  final cases = <_RenderCase>[
    const _RenderCase(
      name: 'bills-light-390-1x-cross-year',
      size: Size(390, 1000),
    ),
    const _RenderCase(
      name: 'bills-dark-390-1x-cross-year',
      size: Size(390, 1000),
      brightness: Brightness.dark,
    ),
    const _RenderCase(
      name: 'bills-light-320-2x-long-amount',
      size: Size(320, 1200),
      textScale: 2,
    ),
    const _RenderCase(
      name: 'bills-dark-440-2x-masked',
      size: Size(440, 1200),
      textScale: 2,
      brightness: Brightness.dark,
      masked: true,
    ),
    const _RenderCase(
      name: 'bills-light-390-1x-filtered-empty',
      size: Size(390, 900),
      action: _RenderAction.filteredEmpty,
    ),
    const _RenderCase(
      name: 'bills-light-390-1x-pagination-failure',
      size: Size(390, 900),
      action: _RenderAction.paginationFailure,
    ),
    const _RenderCase(
      name: 'bills-dark-390-1x-refresh-failure',
      size: Size(390, 900),
      brightness: Brightness.dark,
      action: _RenderAction.refreshFailure,
    ),
    const _RenderCase(
      name: 'bills-light-640-320-2x-landscape',
      size: Size(640, 320),
      textScale: 2,
    ),
    const _RenderCase(
      name: 'bills-light-390-1x-filter-form',
      size: Size(390, 900),
      action: _RenderAction.filterForm,
    ),
    const _RenderCase(
      name: 'bills-light-320-2x-filter-error',
      size: Size(320, 1000),
      textScale: 2,
      action: _RenderAction.filterError,
    ),
    const _RenderCase(
      name: 'bills-dark-440-2x-filter-en',
      size: Size(440, 1200),
      textScale: 2,
      brightness: Brightness.dark,
      locale: Locale('en'),
      action: _RenderAction.filterForm,
    ),
  ];

  for (final item in cases) {
    testWidgets('render ${item.name}', (tester) async {
      tester.view.physicalSize = item.size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
      addTearDown(tester.view.reset);
      final service = _RenderBillService(
        failPagination: item.action == _RenderAction.paginationFailure,
        failRefresh: false,
      );
      final bloc = BillsBloc(
        bookId: 7,
        service: service,
        now: DateTime(2026, 11, 5),
      );
      final session = _RenderSessionCubit();
      final preferences = _RenderPreferencesCubit(masked: item.masked);
      addTearDown(() {
        bloc.close();
        session.close();
        preferences.close();
      });
      final boundaryKey = GlobalKey();
      var theme = item.brightness == Brightness.light
          ? FxTheme.light
          : FxTheme.dark;
      final previewFont = item.locale.languageCode == 'zh'
          ? 'PreviewCJK'
          : 'PreviewSystem';
      theme = theme.copyWith(
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: TextStyle(
              fontFamily: previewFont,
              fontFamilyFallback: const ['PreviewCJK'],
            ),
          ),
        ),
        listTileTheme: theme.listTileTheme.copyWith(
          titleTextStyle: TextStyle(
            fontFamily: previewFont,
            fontFamilyFallback: const ['PreviewCJK'],
          ),
          subtitleTextStyle: TextStyle(
            fontFamily: previewFont,
            fontFamilyFallback: const ['PreviewCJK'],
          ),
        ),
        textTheme: theme.textTheme.apply(
          fontFamily: previewFont,
          fontFamilyFallback: const ['PreviewCJK'],
        ),
      );
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: MultiBlocProvider(
            providers: [
              BlocProvider<SessionCubit>.value(value: session),
              BlocProvider<PreferencesCubit>.value(value: preferences),
              BlocProvider<BillsBloc>.value(value: bloc),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: theme,
              locale: item.locale,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                S.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(item.textScale)),
                child: DefaultTextStyle(
                  style: DefaultTextStyle.of(context).style.copyWith(
                    fontFamily: previewFont,
                    fontFamilyFallback: const ['PreviewCJK'],
                  ),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
              home: BillsPage(detailService: service),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      switch (item.action) {
        case _RenderAction.none:
        case _RenderAction.filteredEmpty:
          await tester.tap(find.byTooltip('筛选'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(TextField).first, '无结果');
          await tester.tap(find.text('应用'));
          await tester.pumpAndSettle();
        case _RenderAction.paginationFailure:
          bloc.add(const BillsNextPageRequested());
          await tester.pumpAndSettle();
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -500),
          );
          await tester.pumpAndSettle();
        case _RenderAction.refreshFailure:
          service.failRefresh = true;
          bloc.add(const BillsRefreshed());
          await tester.pumpAndSettle();
        case _RenderAction.filterForm:
          await tester.tap(
            find.byTooltip(item.locale.languageCode == 'en' ? 'Filter' : '筛选'),
          );
          await tester.pumpAndSettle();
        case _RenderAction.filterError:
          await tester.tap(find.byTooltip('筛选'));
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byKey(const ValueKey('bills-filter-min')),
            '20',
          );
          await tester.enterText(
            find.byKey(const ValueKey('bills-filter-max')),
            '10',
          );
          await tester.tap(find.text('应用'));
          await tester.pumpAndSettle();
      }

      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(boundaryKey),
      );
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          '$outputDir/${item.name}.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      expect(tester.takeException(), isNull);
    });
  }
}

enum _RenderAction {
  none,
  filteredEmpty,
  paginationFailure,
  refreshFailure,
  filterForm,
  filterError,
}

class _RenderCase {
  const _RenderCase({
    required this.name,
    required this.size,
    this.brightness = Brightness.light,
    this.textScale = 1,
    this.masked = false,
    this.locale = const Locale('zh'),
    this.action = _RenderAction.none,
  });

  final String name;
  final Size size;
  final Brightness brightness;
  final double textScale;
  final bool masked;
  final Locale locale;
  final _RenderAction action;
}

class _RenderSessionCubit extends SessionCubit {
  _RenderSessionCubit() : super() {
    emit(
      const SessionState(
        status: SessionStatus.ready,
        currentGroup: FortuneGroupVo(roleType: 2),
        currentBook: FortuneBookVo(bookId: 7, defaultCurrency: 'CNY'),
      ),
    );
  }
}

class _RenderPreferencesCubit extends PreferencesCubit {
  _RenderPreferencesCubit({required bool masked}) : super() {
    emit(
      state.copyWith(
        dashboard: DashboardDisplayPreferences(hideAmounts: masked),
      ),
    );
  }
}

class _RenderBillService extends BillService {
  _RenderBillService({required this.failPagination, required this.failRefresh});

  final bool failPagination;
  bool failRefresh;

  @override
  Future<BillPage> getPage(BillQuery query) async {
    if (query.title == '无结果') return const BillPage();
    if (failRefresh && query.pageNum == 1) {
      throw FxApiException(-1, '刷新失败');
    }
    if (query.pageNum == 2) {
      if (failPagination) throw FxApiException(-1, '分页失败');
      return BillPage(rows: [_olderIncome], total: 3);
    }
    return BillPage(
      rows: [_currentBill, _historicalBill],
      total: failPagination ? 3 : 2,
    );
  }

  @override
  Future<BillStatistics> getStatistics({
    required int bookId,
    required String tradeTimeStartTime,
    required String tradeTimeEndTime,
  }) async {
    if (tradeTimeStartTime.startsWith('2025-10')) {
      return const BillStatistics(expense: 89.99, income: 20, surplus: -69.99);
    }
    if (tradeTimeStartTime.startsWith('2025-09')) {
      return const BillStatistics(income: 200, surplus: 200);
    }
    return const BillStatistics(
      expense: 123456789.12,
      income: 200,
      surplus: -123456589.12,
    );
  }
}

final _currentBill = FortuneBillVo(
  billId: 1,
  title: '跨年夜酒店与手续费核对——用于检查完整标题和费用层级',
  tradeTime: DateTime(2026, 11, 3, 21, 14),
  amount: 123456789.12,
  billType: 1,
  currencyCode: 'CNY',
  accountName: '日常银行卡',
  categoryAmountPair: const [
    BillCategoryAmount(categoryName: '旅行住宿', amount: 123456789.12),
  ],
  extras: const [
    BillExtra(extraType: 1, amount: 3),
    BillExtra(extraType: 2, amount: 5),
  ],
  hasFile: true,
  confirm: false,
);

final _historicalBill = FortuneBillVo(
  billId: 2,
  title: 'USD subscription with a deliberately long description for wrapping',
  tradeTime: DateTime(2025, 10, 4, 9, 30),
  amount: 89.99,
  billType: 1,
  currencyCode: 'USD',
  accountName: 'International card',
  categoryAmountPair: const [
    BillCategoryAmount(categoryName: 'Software subscription', amount: 89.99),
  ],
);

final _olderIncome = FortuneBillVo(
  billId: 3,
  title: '上年度报销到账',
  tradeTime: DateTime(2025, 9, 20, 12),
  amount: 200,
  billType: 2,
  currencyCode: 'CNY',
  accountName: '日常银行卡',
);
