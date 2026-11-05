import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/components/fx_confirm_sheet.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_text_field.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

Widget _app(Widget child) => MaterialApp(
  theme: FxTheme.light,
  locale: const Locale('zh'),
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    S.delegate,
  ],
  supportedLocales: S.delegate.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    for (final entry in {
      'PreviewCJK': '/System/Library/Fonts/Hiragino Sans GB.ttc',
      'PreviewSystem': '/System/Library/Fonts/SFNS.ttf',
    }.entries) {
      final loader = FontLoader(entry.key);
      loader.addFont(File(entry.value).readAsBytes().then(ByteData.sublistView));
      await loader.load();
    }
  });

  testWidgets('successful confirm closes and returns true', (tester) async {
    bool? result;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await FxConfirmSheet.show(
                context,
                title: '删除账单',
                message: '删除后不可恢复',
                confirmLabel: '删除',
                cancelLabel: '取消',
                onConfirm: () async => true,
              );
            },
            child: const Text('打开'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.byType(FxSheet), findsNothing);
  });

  testWidgets('render busy guarded sheet with keyboard inset', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    final boundaryKey = GlobalKey();
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    var theme = FxTheme.light;
    theme = theme.copyWith(
      textTheme: theme.textTheme.apply(
        fontFamily: 'PreviewSystem',
        fontFamilyFallback: const ['PreviewCJK'],
      ),
    );
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: MaterialApp(
          theme: theme,
          locale: const Locale('zh'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            S.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => FxSheet.show<void>(
                  context,
                  title: '编辑账单',
                  submitLabel: '保存账单',
                  submitLoading: true,
                  onSubmit: () {},
                  child: FxSheetPopGuard(
                    hasUnsavedChanges: true,
                    isBusy: true,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: FxTextField(
                        label: '备注',
                        focusNode: focusNode,
                        controller: TextEditingController(text: '已输入但尚未保存的内容'),
                      ),
                    ),
                  ),
                ),
                child: const Text('打开'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开'));
    await tester.pump(const Duration(milliseconds: 400));
    focusNode.requestFocus();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.byType(FxSheet), findsOneWidget);

    final boundary = boundaryKey.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(
        'docs/design-system/execution-prompts/evidence/S2-A/attempt-001/modal-keyboard-busy-light-390-1x.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  });
}
