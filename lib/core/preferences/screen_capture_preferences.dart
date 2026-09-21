import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenCapturePreferences extends Equatable {
  const ScreenCapturePreferences({this.allowScreenCapture = false});

  final bool allowScreenCapture;

  ScreenCapturePreferences copyWith({bool? allowScreenCapture}) {
    return ScreenCapturePreferences(
      allowScreenCapture: allowScreenCapture ?? this.allowScreenCapture,
    );
  }

  @override
  List<Object> get props => [allowScreenCapture];
}

abstract interface class ScreenCapturePreferenceStore {
  Future<bool?> readAllowed();

  Future<bool> writeAllowed(bool allowed);
}

class SharedPreferencesScreenCapturePreferenceStore
    implements ScreenCapturePreferenceStore {
  SharedPreferencesScreenCapturePreferenceStore({
    SharedPreferences? sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  static const _allowScreenCaptureKey =
      'fortune.preferences.security.allowScreenCapture';

  SharedPreferences? _sharedPreferences;

  Future<SharedPreferences> get _preferences async {
    return _sharedPreferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<bool?> readAllowed() async {
    return (await _preferences).getBool(_allowScreenCaptureKey);
  }

  @override
  Future<bool> writeAllowed(bool allowed) async {
    return (await _preferences).setBool(_allowScreenCaptureKey, allowed);
  }
}
