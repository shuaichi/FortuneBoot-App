import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/security/screen_capture_protection.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PreferencesCubit billing preferences', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults to using the current time when copying', () {
      expect(const PreferencesState().billing.copyUsesCurrentTime, isTrue);
    });

    test('loads a stored copy-time preference', () async {
      SharedPreferences.setMockInitialValues({
        'fortune.preferences.billing.copyUsesCurrentTime': false,
      });
      final cubit = PreferencesCubit(
        screenCaptureProtection: _AlwaysSucceedsScreenCaptureProtection(),
      );
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.billing.copyUsesCurrentTime, isFalse);
    });

    test('persists the copy-time preference', () async {
      final cubit = PreferencesCubit(
        screenCaptureProtection: _AlwaysSucceedsScreenCaptureProtection(),
      );
      addTearDown(cubit.close);

      final saved = await cubit.setCopyUsesCurrentTime(false);

      expect(saved, isTrue);
      expect(cubit.state.billing.copyUsesCurrentTime, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getBool('fortune.preferences.billing.copyUsesCurrentTime'),
        isFalse,
      );
    });
  });
}

class _AlwaysSucceedsScreenCaptureProtection
    implements ScreenCaptureProtection {
  @override
  Future<bool> setScreenCaptureAllowed(bool allowed) async => true;
}
