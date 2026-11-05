import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_list_section.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_text.dart';
import 'package:fortuneboot/fx/components/fx_text_field.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';

/// 本地设计底座展示图生成器；字体文件只用于预览，不加入应用资产。
///
/// Run with flutter test tool/design_system_preview_test.dart and optionally
/// --dart-define=DESIGN_PREVIEW_FONT=/path/to/system-font.ttf.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const fontPath = String.fromEnvironment('DESIGN_PREVIEW_FONT');
  const cjkFontPath = String.fromEnvironment('DESIGN_PREVIEW_CJK_FONT');

  setUpAll(() async {
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    for (final font in {
      'PreviewSystem': fontPath,
      'PreviewCJK': cjkFontPath,
    }.entries) {
      if (font.value.isEmpty) continue;
      final loader = FontLoader(font.key);
      loader.addFont(File(font.value).readAsBytes().then(ByteData.sublistView));
      await loader.load();
    }
  });

  for (final brightness in Brightness.values) {
    testWidgets('render ${brightness.name} design foundation', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 920));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final boundaryKey = GlobalKey();
      var theme = brightness == Brightness.light ? FxTheme.light : FxTheme.dark;
      if (fontPath.isNotEmpty) {
        theme = theme.copyWith(
          textTheme: theme.textTheme.apply(
            fontFamily: 'PreviewSystem',
            fontFamilyFallback: const ['PreviewCJK'],
          ),
          listTileTheme: theme.listTileTheme.copyWith(
            titleTextStyle: theme.listTileTheme.titleTextStyle?.copyWith(
              fontFamily: 'PreviewSystem',
              fontFamilyFallback: const ['PreviewCJK'],
            ),
            subtitleTextStyle: theme.listTileTheme.subtitleTextStyle?.copyWith(
              fontFamily: 'PreviewSystem',
              fontFamilyFallback: const ['PreviewCJK'],
            ),
          ),
        );
      }
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: RepaintBoundary(
            key: boundaryKey,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  final palette = FxPalette.of(context);
                  return Padding(
                    padding: const EdgeInsets.all(FxSpacing.pageInset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: FxSpacing.xl),
                        const FxText(
                          '好记 · 设计底座',
                          role: FxTextRole.label,
                          tone: FxTextTone.secondary,
                        ),
                        const SizedBox(height: FxSpacing.sm),
                        const FxText('把账记清楚', role: FxTextRole.display),
                        const SizedBox(height: FxSpacing.xxl),
                        FxCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FxCardLabel('本账期结余'),
                              const SizedBox(height: FxSpacing.sm),
                              const FxMoneyText(
                                amount: 23840.26,
                                currencyCode: 'CNY',
                                fontSize: 34,
                              ),
                              const SizedBox(height: FxSpacing.sm),
                              const FxText(
                                '11 月 1 日 — 11 月 30 日 · 人民币',
                                role: FxTextRole.caption,
                                tone: FxTextTone.secondary,
                              ),
                              const SizedBox(height: FxSpacing.lg),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: palette.success,
                                    size: 18,
                                  ),
                                  const SizedBox(width: FxSpacing.sm),
                                  const Expanded(
                                    child: FxText(
                                      '金额完整展示，辅助说明保持可读',
                                      role: FxTextRole.caption,
                                      tone: FxTextTone.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: FxSpacing.xxl),
                        const FxText('最近记录', role: FxTextRole.title),
                        const SizedBox(height: FxSpacing.md),
                        FxListSection(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.local_cafe_outlined),
                              title: const Text('工作日午餐'),
                              subtitle: const Text('今天 12:30 · 日常支出'),
                              trailing: const FxMoneyText(
                                amount: -38,
                                currencyCode: 'CNY',
                              ),
                              onTap: () {},
                            ),
                            ListTile(
                              leading: const Icon(Icons.train_outlined),
                              title: const Text('通勤交通'),
                              subtitle: const Text('昨天 · 交通出行'),
                              trailing: const FxMoneyText(
                                amount: -12,
                                currencyCode: 'CNY',
                              ),
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: FxSpacing.xxl),
                        const FxTextField(label: '记录名称', hintText: '例如：周末采购'),
                        const SizedBox(height: FxSpacing.xl),
                        FxButton(label: '保存记录', onPressed: () {}),
                        const SizedBox(height: FxSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: FxButton.tonal(
                                label: '稍后再说',
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: FxSpacing.md),
                            Expanded(
                              child: FxButton.critical(
                                label: '删除记录',
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: FxSpacing.xxl),
                        Material(
                          color: palette.surfaceRaised,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              color: palette.border,
                              width: FxSpacing.hairline,
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(FxSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FxText('浮层表面', role: FxTextRole.title),
                                SizedBox(height: FxSpacing.sm),
                                FxText(
                                  '表面表达层级，文字负责信息。',
                                  tone: FxTextTone.secondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final snapshot = await boundary.toImage(pixelRatio: 2);
        final bytes = await snapshot.toByteData(format: ui.ImageByteFormat.png);
        final output = File(
          'docs/design-system/foundation-${brightness.name}.png',
        );
        await output.parent.create(recursive: true);
        await output.writeAsBytes(bytes!.buffer.asUint8List());
        snapshot.dispose();
      });
    });
  }
}
