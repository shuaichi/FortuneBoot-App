import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/stats/data/holiday_patch_service.dart';
import 'package:lunar/lunar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleData = '202701010120270101';

  setUp(() {
    HolidayUtil.fix(null, '');
  });

  test('applyFromRaw injects holiday from bundled json shape', () {
    final service = HolidayPatchService(
      loadAsset: (_) async => throw StateError('unused'),
    );

    final ok = service.applyFromRaw({
      'version': 1,
      'data': sampleData,
    });

    expect(ok, isTrue);
    final holiday = HolidayUtil.getHolidayByYmd(2027, 1, 1);
    expect(holiday, isNotNull);
    expect(holiday!.isWork(), isFalse);
  });

  test('applyFromRaw rejects invalid payload', () {
    final service = HolidayPatchService(
      loadAsset: (_) async => throw StateError('unused'),
    );

    expect(service.applyFromRaw({'version': 1, 'data': 'short'}), isFalse);
    expect(service.applyFromRaw('not-a-map'), isFalse);
  });

  test('applyBundled loads asset text', () async {
    final service = HolidayPatchService(
      assetPath: 'assets/calendar/holiday-patch.json',
      loadAsset: (key) async {
        expect(key, 'assets/calendar/holiday-patch.json');
        return '{"version":1,"data":"$sampleData"}';
      },
    );

    final ok = await service.applyBundled();
    expect(ok, isTrue);
    expect(HolidayUtil.getHolidayByYmd(2027, 1, 1), isNotNull);
  });

  test('applyBundled returns false when asset missing', () async {
    final service = HolidayPatchService(
      loadAsset: (_) async {
        throw FlutterError('Unable to load asset');
      },
    );

    expect(await service.applyBundled(), isFalse);
  });
}
