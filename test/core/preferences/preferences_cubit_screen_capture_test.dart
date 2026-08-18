import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/preferences/screen_capture_preferences.dart';
import 'package:fortuneboot/core/security/screen_capture_protection.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PreferencesCubit screen capture preference', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });
    test('defaults to protected screen capture', () {
      expect(
        const PreferencesState().screenCapture.allowScreenCapture,
        isFalse,
      );
    });

    test(
      'loads a missing preference as protected and applies it natively',
      () async {
        final protection = _FakeScreenCaptureProtection();
        final store = _FakeScreenCapturePreferenceStore();
        final cubit = PreferencesCubit(
          screenCaptureProtection: protection,
          screenCapturePreferenceStore: store,
        );
        addTearDown(cubit.close);

        await cubit.load();

        expect(cubit.state.screenCapture.allowScreenCapture, isFalse);
        expect(protection.calls, [false]);
        expect(cubit.state.errorMessage, isNull);
      },
    );

    test('loads and applies an explicitly allowed preference', () async {
      final protection = _FakeScreenCaptureProtection();
      final store = _FakeScreenCapturePreferenceStore(allowed: true);
      final cubit = PreferencesCubit(
        screenCaptureProtection: protection,
        screenCapturePreferenceStore: store,
      );
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.screenCapture.allowScreenCapture, isTrue);
      expect(protection.calls, [true]);
    });

    test('allows capture before persisting the preference', () async {
      final events = <String>[];
      final protection = _FakeScreenCaptureProtection(events: events);
      final store = _FakeScreenCapturePreferenceStore(events: events);
      final cubit = PreferencesCubit(
        screenCaptureProtection: protection,
        screenCapturePreferenceStore: store,
      );
      addTearDown(cubit.close);

      final saved = await cubit.setScreenCaptureAllowed(true);

      expect(saved, isTrue);
      expect(events, ['native:true', 'store:true']);
      expect(cubit.state.screenCapture.allowScreenCapture, isTrue);
      expect(cubit.state.errorMessage, isNull);
    });

    test('does not persist when allowing capture fails natively', () async {
      final protection = _FakeScreenCaptureProtection(failOn: true);
      final store = _FakeScreenCapturePreferenceStore();
      final cubit = PreferencesCubit(
        screenCaptureProtection: protection,
        screenCapturePreferenceStore: store,
      );
      addTearDown(cubit.close);

      final saved = await cubit.setScreenCaptureAllowed(true);

      expect(saved, isFalse);
      expect(store.writes, isEmpty);
      expect(cubit.state.screenCapture.allowScreenCapture, isFalse);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test(
      'restores protection when allowing capture cannot be persisted',
      () async {
        final events = <String>[];
        final protection = _FakeScreenCaptureProtection(events: events);
        final store = _FakeScreenCapturePreferenceStore(
          events: events,
          writeResult: false,
        );
        final cubit = PreferencesCubit(
          screenCaptureProtection: protection,
          screenCapturePreferenceStore: store,
        );
        addTearDown(cubit.close);

        final saved = await cubit.setScreenCaptureAllowed(true);

        expect(saved, isFalse);
        expect(events, ['native:true', 'store:true', 'native:false']);
        expect(cubit.state.screenCapture.allowScreenCapture, isFalse);
        expect(cubit.state.errorMessage, isNotNull);
      },
    );

    test('keeps allowed state when restoring protection fails', () async {
      final protection = _FakeScreenCaptureProtection(failOn: false);
      final store = _FakeScreenCapturePreferenceStore(writeResult: false);
      final cubit = PreferencesCubit(
        screenCaptureProtection: protection,
        screenCapturePreferenceStore: store,
      );
      addTearDown(cubit.close);

      final saved = await cubit.setScreenCaptureAllowed(true);

      expect(saved, isFalse);
      expect(protection.calls, [true, false]);
      expect(cubit.state.screenCapture.allowScreenCapture, isTrue);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test(
      'keeps active protection when persisting a protected setting fails',
      () async {
        final protection = _FakeScreenCaptureProtection();
        final store = _FakeScreenCapturePreferenceStore();
        final cubit = PreferencesCubit(
          screenCaptureProtection: protection,
          screenCapturePreferenceStore: store,
        );
        addTearDown(cubit.close);
        await cubit.setScreenCaptureAllowed(true);
        store.writeResult = false;

        final saved = await cubit.setScreenCaptureAllowed(false);

        expect(saved, isFalse);
        expect(protection.calls, [true, false]);
        expect(cubit.state.screenCapture.allowScreenCapture, isFalse);
        expect(cubit.state.errorMessage, isNotNull);
      },
    );
  });
}

class _FakeScreenCaptureProtection implements ScreenCaptureProtection {
  _FakeScreenCaptureProtection({this.events, this.failOn});

  final List<String>? events;
  final bool? failOn;
  final calls = <bool>[];

  @override
  Future<bool> setScreenCaptureAllowed(bool allowed) async {
    calls.add(allowed);
    events?.add('native:$allowed');
    return allowed != failOn;
  }
}

class _FakeScreenCapturePreferenceStore
    implements ScreenCapturePreferenceStore {
  _FakeScreenCapturePreferenceStore({
    this.allowed,
    this.writeResult = true,
    this.events,
  });

  bool? allowed;
  bool writeResult;
  final List<String>? events;
  final writes = <bool>[];

  @override
  Future<bool?> readAllowed() async => allowed;

  @override
  Future<bool> writeAllowed(bool allowed) async {
    writes.add(allowed);
    events?.add('store:$allowed');
    if (writeResult) this.allowed = allowed;
    return writeResult;
  }
}
