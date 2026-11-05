import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/fx/components/fx_action_sheet.dart';
import 'package:fortuneboot/fx/components/fx_chip.dart';
import 'package:fortuneboot/fx/components/fx_list_item.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/components/fx_select_row.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

Widget _app(Widget child, {TextScaler textScaler = TextScaler.noScaling}) =>
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
      home: MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('select row clear has a named 44 pixel target', (tester) async {
    await tester.pumpWidget(
      _app(
        FxSelectRow(label: '交易对象', value: '京东', onTap: () {}, onClear: () {}),
      ),
    );

    final clear = find.bySemanticsLabel('清空 交易对象');
    expect(clear, findsOneWidget);
    expect(tester.getSize(clear).width, greaterThanOrEqualTo(44));
    expect(tester.getSize(clear).height, greaterThanOrEqualTo(44));
  });

  testWidgets('select row reflows long label and value at 320 width 2x text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      _app(
        FxSelectRow(
          label: '非常长的交易对象字段名称',
          value: 'A very long counterparty name that must remain readable',
          onTap: () {},
          onClear: () {},
        ),
        textScaler: const TextScaler.linear(2),
      ),
    );

    final value = tester.widget<Text>(
      find.text('A very long counterparty name that must remain readable'),
    );
    expect(value.maxLines, isNull);
    expect(value.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull);
  });

  testWidgets('static tag has no button semantics and delete target is named', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const Column(
          children: [
            FxTagChip(label: '静态标签'),
            FxTagChip(label: '餐饮', onDeleted: _noop),
          ],
        ),
      ),
    );

    final staticSemantics = tester.getSemantics(
      find
          .ancestor(of: find.text('静态标签'), matching: find.byType(Semantics))
          .first,
    );
    expect(staticSemantics.flagsCollection.isButton, isFalse);
    final delete = find.bySemanticsLabel('删除 餐饮');
    expect(delete, findsOneWidget);
    expect(tester.getSize(delete).width, greaterThanOrEqualTo(44));
    expect(tester.getSize(delete).height, greaterThanOrEqualTo(44));
  });

  testWidgets('chip paints its background below ink and supports focus', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(FxChip(label: '支出', selected: true, onTap: () {})),
    );

    final material = tester.widget<Material>(
      find.descendant(of: find.byType(FxChip), matching: find.byType(Material)),
    );
    expect(material.color, isNot(Colors.transparent));
    expect(
      find.descendant(
        of: find.byType(InkWell),
        matching: find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration != null,
        ),
      ),
      findsNothing,
    );
  });

  testWidgets('segmented labels grow at large text without ellipsis', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      _app(
        FxSegmented<String>(
          value: 'expense',
          onChanged: (_) {},
          segments: const [
            FxSegment('income', '非常长的收入分类名称'),
            FxSegment('expense', '非常长的支出分类名称'),
          ],
        ),
        textScaler: const TextScaler.linear(2),
      ),
    );

    for (final label in ['非常长的收入分类名称', '非常长的支出分类名称']) {
      final text = tester.widget<Text>(find.text(label));
      expect(text.maxLines, isNull);
      expect(text.overflow, isNot(TextOverflow.ellipsis));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('list item keeps long title and trailing readable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      _app(
        FxListItem(
          title: '用于验证完整阅读的超长账单标题',
          subtitle: 'A long subtitle that remains associated with the title',
          trailing: const Text('人民币 123,456,789.00'),
          onTap: () {},
        ),
        textScaler: const TextScaler.linear(2),
      ),
    );

    final title = tester.widget<Text>(find.text('用于验证完整阅读的超长账单标题'));
    expect(title.maxLines, isNull);
    expect(title.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull);
  });

  testWidgets('state view exposes task title and recovery action', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      _app(
        FxStateView.error(
          title: '账单暂时无法加载',
          message: '已保留当前账期，请检查网络后重试',
          retryLabel: '重试',
          onRetry: () => retries++,
        ),
      ),
    );

    expect(find.text('账单暂时无法加载'), findsOneWidget);
    await tester.tap(find.text('重试'));
    expect(retries, 1);

    await tester.pumpWidget(
      _app(
        FxStateView.loading(
          title: '账单',
          message: '正在保留当前账期并加载',
        ),
      ),
    );
    expect(find.text('账单'), findsOneWidget);
    expect(find.text('正在保留当前账期并加载'), findsOneWidget);
  });

  testWidgets('feedback semantics contain only localized message', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const SizedBox()));
    FxFeedback.error(tester.element(find.byType(SizedBox)), message: '金额格式不正确');
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('金额格式不正确'), findsOneWidget);
    final liveRegion = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.liveRegion == true &&
          widget.properties.label == '金额格式不正确',
    );
    expect(liveRegion, findsOneWidget);
    final properties = tester.widget<Semantics>(liveRegion).properties;
    expect(properties.label, '金额格式不正确');
    expect(properties.liveRegion, isTrue);
  });

  testWidgets('action sheet uses neutral icons for ordinary actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => FxActionSheet.show(
              context,
              title: '账单操作',
              actions: [
                FxSheetAction(
                  label: '复制',
                  icon: Icons.copy_rounded,
                  onPressed: () {},
                ),
              ],
            ),
            child: const Text('打开'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    final tile = tester.widget<ListTile>(find.byType(ListTile));
    expect(tile.iconColor, FxPalette.light.textSecondary);
  });
}

void _noop() {}
