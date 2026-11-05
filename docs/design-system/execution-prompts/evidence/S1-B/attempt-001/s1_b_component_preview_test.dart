import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/components/fx_amount_input.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_chip.dart';
import 'package:fortuneboot/fx/components/fx_list_item.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/components/fx_select_row.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/components/fx_text.dart';
import 'package:fortuneboot/fx/components/fx_text_field.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tree/fx_tree_picker.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const cjkFontPath = '/System/Library/Fonts/Hiragino Sans GB.ttc';
  const latinFontPath = '/System/Library/Fonts/SFNS.ttf';

  setUpAll(() async {
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    for (final entry in {
      'PreviewCJK': cjkFontPath,
      'PreviewSystem': latinFontPath,
    }.entries) {
      final loader = FontLoader(entry.key);
      loader.addFont(
        File(entry.value).readAsBytes().then(ByteData.sublistView),
      );
      await loader.load();
    }
  });

  for (final brightness in Brightness.values) {
    for (final width in [320.0, 390.0, 440.0]) {
      for (final scale in [1.0, 2.0]) {
        final name = '${brightness.name}-${width.toInt()}-${scale.toInt()}x';
        testWidgets('render shared components $name', (tester) async {
          final logicalSize = Size(
            width,
            scale == 1 ? 1900 : (width == 320 ? 3500 : 3000),
          );
          tester.view.physicalSize = logicalSize;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final boundaryKey = GlobalKey();
          final fieldFocus = FocusNode();
          addTearDown(fieldFocus.dispose);
          var theme = brightness == Brightness.light
              ? FxTheme.light
              : FxTheme.dark;
          theme = theme.copyWith(
            textTheme: theme.textTheme.apply(
              fontFamily: 'PreviewSystem',
              fontFamilyFallback: const ['PreviewCJK'],
            ),
          );
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              locale: const Locale('zh'),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                S.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: RepaintBoundary(
                  key: boundaryKey,
                  child: Scaffold(
                    body: Padding(
                      padding: const EdgeInsets.all(FxSpacing.pageInset),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const FxText(
                            '好记 · 共享控件 / Shared controls',
                            role: FxTextRole.title,
                          ),
                          const SizedBox(height: FxSpacing.lg),
                          const FxMoneyText(
                            amount: 1234567890.12,
                            currencyCode: 'CNY',
                            fontSize: 34,
                          ),
                          const FxMoneyText(
                            amount: 1234567890.12,
                            currencyCode: 'CNY',
                            masked: true,
                          ),
                          const SizedBox(height: FxSpacing.lg),
                          Builder(
                            builder: (context) => FxCard(
                              background: FxPalette.of(context).primary,
                              onTap: () {},
                              child: Text(
                                '快捷记账 · 当前账本\nQuick add · Current book',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: FxPalette.of(context).onPrimary,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: FxSpacing.lg),
                          FxSelectRow(
                            label: '交易对象 / Counterparty',
                            value:
                                '京东集团一个非常长的供应商名称 / A very long counterparty name',
                            onTap: () {},
                            onClear: () {},
                          ),
                          const Divider(),
                          FxListItem(
                            title: '完整账单标题应当能够换行阅读',
                            subtitle:
                                'A long subtitle stays associated with the bill title',
                            trailing: const Text('人民币 123,456,789.00'),
                            onTap: () {},
                          ),
                          const SizedBox(height: FxSpacing.lg),
                          FxSegmented<String>(
                            value: 'expense',
                            onChanged: (_) {},
                            segments: const [
                              FxSegment('income', '收入分类 / Income'),
                              FxSegment('expense', '支出分类 / Expense'),
                            ],
                          ),
                          const SizedBox(height: FxSpacing.lg),
                          Wrap(
                            spacing: FxSpacing.sm,
                            runSpacing: FxSpacing.sm,
                            children: [
                              FxChip(
                                label: '选中支出',
                                selected: true,
                                onTap: () {},
                              ),
                              FxChip(
                                label: '禁用选项',
                                selected: false,
                                enabled: false,
                                onTap: () {},
                              ),
                              const FxTagChip(label: '静态标签'),
                              FxTagChip(label: '可删除标签', onDeleted: () {}),
                            ],
                          ),
                          const SizedBox(height: FxSpacing.lg),
                          FxTextField(
                            label: '备注 / Note',
                            focusNode: fieldFocus,
                            hintText: '聚焦输入框',
                            errorText: '字段错误持久显示，不只使用短暂提示',
                          ),
                          const SizedBox(height: FxSpacing.md),
                          const FxAmountInput(
                            label: '金额 / Amount',
                            currencySymbol: '¥',
                          ),
                          const SizedBox(height: FxSpacing.lg),
                          FxStateView.error(
                            title: '账单暂时无法加载',
                            message: '已保留当前账期和筛选条件，请检查网络后重试',
                            retryLabel: '重试',
                            onRetry: () {},
                            compact: true,
                          ),
                          const SizedBox(height: FxSpacing.lg),
                          FxButton(
                            label: '保存账单并继续添加下一笔 / Save and add another',
                            onPressed: () {},
                          ),
                          const SizedBox(height: FxSpacing.lg),
                          FxTreePicker<String>(
                            roots: const ['餐饮', '交通'],
                            childrenOf: (node) => node == '餐饮'
                                ? const ['工作日团队聚餐和 client lunch']
                                : const [],
                            labelOf: (node) => node,
                            idOf: (node) => node,
                            embedded: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          fieldFocus.requestFocus();
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final boundary =
              boundaryKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final output = File(
              'docs/design-system/execution-prompts/evidence/S1-B/attempt-001/shared-$name.png',
            );
            await output.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        });
      }
    }
  }
}
