import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/profile/presentation/widgets/donate_qr_tile.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

const _wechatAsset = 'assets/images/donate_wechat.jpg';
const _alipayAsset = 'assets/images/donate_alipay.jpg';

Widget _testApp({required DonateQrTile tile}) {
  return MaterialApp(
    theme: FxTheme.light,
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
          },
        ),
      ),
    );

    await tester.longPress(find.byKey(DonateQrTile.qrKey));
    await tester.pump();

    expect(calls, [(_wechatAsset, 'fortuneboot_donate_wechat.jpg')]);
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
          },
        ),
      ),
    );

    await tester.longPress(find.byKey(DonateQrTile.qrKey));
    await tester.pump();

    expect(calls, [(_alipayAsset, 'fortuneboot_donate_alipay.jpg')]);
  });

  testWidgets('tap on a QR does not request saving', (tester) async {
    final calls = <(String, String)>[];

    await tester.pumpWidget(
      _testApp(
        tile: _tile(
          assetPath: _wechatAsset,
          fileName: 'fortuneboot_donate_wechat.jpg',
          onSave: (assetPath, fileName) async {
            calls.add((assetPath, fileName));
          },
        ),
      ),
    );

    await tester.tap(find.byKey(DonateQrTile.qrKey));
    await tester.pump();

    expect(calls, isEmpty);
  });

  testWidgets('exposes an accessible long-press QR action', (tester) async {
    await tester.pumpWidget(
      _testApp(
        tile: _tile(
          assetPath: _wechatAsset,
          fileName: 'fortuneboot_donate_wechat.jpg',
          onSave: (_, _) async {},
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
