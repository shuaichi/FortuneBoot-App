import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/preferences/dashboard_display_preferences.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_detail_flow.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const output =
      'docs/design-system/execution-prompts/evidence/S4-B/attempt-001';

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

  final cases = <_Case>[
    const _Case(name: 'detail-light-390-full', size: Size(390, 1400)),
    const _Case(
      name: 'detail-dark-390-full',
      size: Size(390, 1400),
      brightness: Brightness.dark,
    ),
    const _Case(
      name: 'detail-light-320-2x-full',
      size: Size(320, 1700),
      textScale: 2,
    ),
    const _Case(
      name: 'detail-dark-440-2x-masked',
      size: Size(440, 1700),
      textScale: 2,
      brightness: Brightness.dark,
      masked: true,
    ),
    const _Case(
      name: 'detail-light-390-file-error',
      size: Size(390, 900),
      action: _Action.fileError,
    ),
    const _Case(
      name: 'detail-light-390-attachments',
      size: Size(390, 1100),
      action: _Action.attachments,
    ),
    const _Case(
      name: 'detail-dark-390-image-preview',
      size: Size(390, 900),
      brightness: Brightness.dark,
      action: _Action.imagePreview,
    ),
    const _Case(
      name: 'detail-light-390-readonly',
      size: Size(390, 1100),
      action: _Action.readonly,
    ),
    const _Case(
      name: 'detail-dark-1440-wide-close',
      size: Size(1440, 1100),
      brightness: Brightness.dark,
    ),
    const _Case(
      name: 'detail-light-440-2x-english',
      size: Size(440, 1700),
      textScale: 2,
      locale: Locale('en'),
    ),
  ];

  for (final item in cases) {
    testWidgets('render ${item.name}', (tester) async {
      tester.view.physicalSize = item.size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
      addTearDown(tester.view.reset);
      final preferences = _RenderPreferencesCubit(item.masked);
      final boundaryKey = GlobalKey();
      var theme = item.brightness == Brightness.light
          ? FxTheme.light
          : FxTheme.dark;
      final font = item.locale.languageCode == 'zh'
          ? 'PreviewCJK'
          : 'PreviewSystem';
      theme = theme.copyWith(
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            textStyle: TextStyle(
              fontFamily: font,
              fontFamilyFallback: const ['PreviewCJK'],
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: TextStyle(
              fontFamily: font,
              fontFamilyFallback: const ['PreviewCJK'],
            ),
          ),
        ),
        listTileTheme: theme.listTileTheme.copyWith(
          titleTextStyle: TextStyle(
            fontFamily: font,
            fontFamilyFallback: const ['PreviewCJK'],
          ),
          subtitleTextStyle: TextStyle(
            fontFamily: font,
            fontFamilyFallback: const ['PreviewCJK'],
          ),
        ),
        textTheme: theme.textTheme.apply(
          fontFamily: font,
          fontFamilyFallback: const ['PreviewCJK'],
        ),
      );
      final bill = item.action == _Action.readonly ? _readOnlyBill : _fullBill;
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: BlocProvider<PreferencesCubit>.value(
            value: preferences,
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
                    fontFamily: font,
                    fontFamilyFallback: const ['PreviewCJK'],
                  ),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: FilledButton(
                      onPressed: () => BillDetailFlow(
                        service: _RenderService(item.action),
                      ).show(context, bookId: 7, bill: bill),
                      child: const Text('打开'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      if (item.action == _Action.imagePreview) {
        final image = find.byKey(const ValueKey('bill-attachment-image'));
        await tester.scrollUntilVisible(
          image,
          400,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.tap(image);
        await tester.pumpAndSettle();
      }
      if (item.action == _Action.attachments ||
          item.action == _Action.fileError) {
        final position = tester
            .state<ScrollableState>(find.byType(Scrollable).last)
            .position;
        position.jumpTo(position.maxScrollExtent);
        await tester.pump();
      }
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(boundaryKey),
      );
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          '$output/${item.name}.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      expect(tester.takeException(), isNull);
    });
  }
}

class _RenderPreferencesCubit extends PreferencesCubit {
  _RenderPreferencesCubit(bool masked) : super() {
    emit(
      state.copyWith(
        dashboard: DashboardDisplayPreferences(hideAmounts: masked),
      ),
    );
  }
}

enum _Action { full, fileError, imagePreview, readonly, attachments }

class _Case {
  const _Case({
    required this.name,
    required this.size,
    this.brightness = Brightness.light,
    this.textScale = 1,
    this.masked = false,
    this.locale = const Locale('zh'),
    this.action = _Action.full,
  });

  final String name;
  final Size size;
  final Brightness brightness;
  final double textScale;
  final bool masked;
  final Locale locale;
  final _Action action;
}

class _RenderService extends BillService {
  _RenderService(this.action);

  final _Action action;

  @override
  Future<List<BillFileVo>> getFiles(int billId) async {
    if (action == _Action.fileError) throw StateError('附件读取失败');
    return [
      BillFileVo(
        fileId: 1,
        originalName: 'photo.png',
        contentType: 'image/png',
        fileData: base64Encode(_png),
      ),
      const BillFileVo(
        fileId: 2,
        originalName: '报销说明与费用核对.pdf',
        contentType: 'application/pdf',
        fileData: 'JVBERi0xLjQgdGVzdA==',
      ),
    ];
  }
}

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Y9Z3T0AAAAASUVORK5CYII=',
);

final _fullBill = FortuneBillVo(
  billId: 1,
  bookId: 7,
  orderId: 9,
  orderComponent: FinanceOrderComponent.fee,
  orderLedgerVersion: 4,
  title: '跨年夜酒店与手续费核对——用于验证完整长标题与费用口径',
  tradeTime: DateTime(2026, 11, 3, 21, 14),
  amount: 100,
  billType: 1,
  currencyCode: 'CNY',
  accountName: '日常银行卡',
  confirm: false,
  remark: '第一段：跨年行程和住宿发票已核对。\n\n第二段：机场停车费计入手续费，会员优惠从原额扣除。',
  allowedActions: const ['EDIT', 'CONFIRM', 'DELETE'],
  hasFile: true,
  categoryAmountPair: const [
    BillCategoryAmount(categoryName: '住宿', amount: 100),
  ],
  tagList: const [
    BillTag(tagName: '跨年旅行'),
    BillTag(tagName: '酒店'),
    BillTag(tagName: '报销'),
    BillTag(tagName: '交通'),
    BillTag(tagName: '家庭'),
    BillTag(tagName: '需复核'),
  ],
  extras: const [
    BillExtra(extraType: 1, amount: 3, categoryId: 8, remark: '机场停车费'),
    BillExtra(extraType: 2, amount: 5, remark: '会员优惠'),
  ],
);

final _readOnlyBill = FortuneBillVo(
  billId: 2,
  bookId: 7,
  orderId: 9,
  orderComponent: FinanceOrderComponent.interest,
  title: '来源单据已锁定的利息流水',
  tradeTime: DateTime(2026, 10, 2, 9),
  billType: 2,
  currencyCode: 'USD',
  include: false,
  readOnlyReason: '单据已锁定，来源动作不可修改',
);
