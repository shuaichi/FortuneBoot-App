import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/profile/presentation/widgets/donate_qr_tile.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/util/image_save_service.dart';

const _wechatAsset = 'assets/images/donate_wechat.jpg';
const _alipayAsset = 'assets/images/donate_alipay.jpg';

Widget _testApp({required DonateQrTile tile}) {
  return MaterialApp(
    theme: FxTheme.light,
    locale: const Locale('zh'),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      S.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: Scaffold(
      body: Center(child: SizedBox(width: 200, child: tile)),
    ),
  );
}

DonateQrTile _tile({
  required String assetPath,
  required String fileName,
  required DonateQrSaveCallback onSave,
}) {
  return DonateQrTile(
    assetPath: assetPath,
    fileName: fileName,
    label: '微信',
    semanticsLabel: '微信捐赠二维码，长按保存到相册',
    tint: Colors.green,
    icon: Icons.wechat_rounded,
    onSave: onSave,
  );
}

void main() {
  testWidgets('long press on WeChat QR forwards asset and file name', (
    tester,
  ) async {
    final calls = <(String, String)>[];

    await tester.pumpWidget(
      _testApp(
        tile: _tile(
          assetPath: _wechatAsset,
          fileName: 'fortuneboot_donate_wechat.jpg',
          onSave: (assetPath, fileName) async {
            calls.add((assetPath, fileName));
            return ImageSaveResult.saved;
          },
        ),
      ),
    );

    await tester.longPress(find.byKey(DonateQrTile.qrKey));
    await tester.pump();

    expect(calls, [(_wechatAsset, 'fortuneboot_donate_wechat.jpg')]);
    expect(find.text('已保存到相册'), findsOneWidget);
  });

  testWidgets('long press on Alipay QR forwards asset and file name', (
    tester,
  ) async {
    final calls = <(String, String)>[];

    await tester.pumpWidget(
      _testApp(
        tile: _tile(
          assetPath: _alipayAsset,
          fileName: 'fortuneboot_donate_alipay.jpg',
          onSave: (assetPath, fileName) async {
            calls.add((assetPath, fileName));
            return ImageSaveResult.saved;
          },
        ),
      ),
    );

    await tester.longPress(find.byKey(DonateQrTile.qrKey));
    await tester.pump();

    expect(calls, [(_alipayAsset, 'fortuneboot_donate_alipay.jpg')]);
  });

  testWidgets('shows saving feedback and ignores repeated long presses', (
    tester,
  ) async {
    final completer = Completer<ImageSaveResult>();
    var saveCount = 0;

    await tester.pumpWidget(
      _testApp(
        tile: _tile(
          assetPath: _wechatAsset,
          fileName: 'fortuneboot_donate_wechat.jpg',
          onSave: (_, _) {
            saveCount++;
            return completer.future;
          },
        ),
      ),
    );

    await tester.longPress(find.byKey(DonateQrTile.qrKey));
    await tester.pump();
    await tester.longPress(find.byKey(DonateQrTile.qrKey));
    await tester.pump();

    expect(saveCount, 1);
    expect(find.text('正在保存…'), findsOneWidget);

    completer.complete(ImageSaveResult.saved);
    await tester.pump();

    expect(find.text('已保存到相册'), findsOneWidget);
  });

  testWidgets('shows failure feedback and allows a retry', (tester) async {
    var saveCount = 0;

    await tester.pumpWidget(
      _testApp(
        tile: _tile(
          assetPath: _wechatAsset,
          fileName: 'fortuneboot_donate_wechat.jpg',
          onSave: (_, _) async {
            saveCount++;
            return saveCount == 1
                ? ImageSaveResult.failed
                : ImageSaveResult.saved;
          },
        ),
      ),
    );

    await tester.longPress(find.byKey(DonateQrTile.qrKey));
    await tester.pump();
    expect(find.text('保存失败，请重试'), findsOneWidget);

    await tester.longPress(find.byKey(DonateQrTile.qrKey));
    await tester.pump();

    expect(saveCount, 2);
    expect(find.text('已保存到相册'), findsOneWidget);
  });

  testWidgets('save button has localized text, tooltip, and a 48dp target', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        tile: _tile(
          assetPath: _wechatAsset,
          fileName: 'fortuneboot_donate_wechat.jpg',
          onSave: (_, _) async => ImageSaveResult.saved,
        ),
      ),
    );

    final label = find.text('保存');
    expect(label, findsOneWidget);
    final target = find.ancestor(
      of: label,
      matching: find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 48,
      ),
    );
    expect(target, findsOneWidget);
    expect(tester.getSize(target).height, 48);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Tooltip && widget.message == '保存',
      ),
      findsOneWidget,
    );
  });

  testWidgets('tap on a QR does not request saving', (tester) async {
    var saveCount = 0;

    await tester.pumpWidget(
      _testApp(
        tile: _tile(
          assetPath: _wechatAsset,
          fileName: 'fortuneboot_donate_wechat.jpg',
          onSave: (_, _) async {
            saveCount++;
            return ImageSaveResult.saved;
          },
        ),
      ),
    );

    await tester.tap(find.byKey(DonateQrTile.qrKey));
    await tester.pump();

    expect(saveCount, 0);
  });

  testWidgets('exposes an accessible long-press QR action', (tester) async {
    await tester.pumpWidget(
      _testApp(
        tile: _tile(
          assetPath: _wechatAsset,
          fileName: 'fortuneboot_donate_wechat.jpg',
          onSave: (_, _) async => ImageSaveResult.saved,
        ),
      ),
    );

    final semantics = tester
        .getSemantics(find.byKey(DonateQrTile.qrKey))
        .getSemanticsData();

    expect(semantics.label, '微信捐赠二维码，长按保存到相册');
    expect(semantics.hasAction(SemanticsAction.longPress), isTrue);
  });
}
