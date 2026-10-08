import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/app_lock_preferences.dart';
import 'package:fortuneboot/core/security/app_lock_authenticator.dart';

class AppLockState extends Equatable {
  const AppLockState({
    this.inProtectedArea = false,
    this.locked = false,
    this.authenticating = false,
    this.pendingLock = false,
  });

  final bool inProtectedArea;
  final bool locked;
  final bool authenticating;
  final bool pendingLock;

  bool get shouldBlock => inProtectedArea && locked;

  AppLockState copyWith({
    bool? inProtectedArea,
    bool? locked,
    bool? authenticating,
    bool? pendingLock,
  }) {
    return AppLockState(
      inProtectedArea: inProtectedArea ?? this.inProtectedArea,
      locked: locked ?? this.locked,
      authenticating: authenticating ?? this.authenticating,
      pendingLock: pendingLock ?? this.pendingLock,
    );
  }

  @override
  List<Object> get props =>
      [inProtectedArea, locked, authenticating, pendingLock];
}

class AppLockCubit extends Cubit<AppLockState> {
  AppLockCubit({
    required AppLockAuthenticator authenticator,
    required bool Function() isEnabled,
  }) : _authenticator = authenticator,
       _isEnabled = isEnabled,
       super(const AppLockState());

  final AppLockAuthenticator _authenticator;
  final bool Function() _isEnabled;

  Future<AppLockAvailability> availability({required bool unlocking}) {
    return _authenticator.availability(unlocking: unlocking);
  }

  Future<void> enrollPassword(String password) {
    return _authenticator.enrollPassword(password);
  }

  Future<void> enrollGesture(List<int> cells) {
    return _authenticator.enrollGesture(cells);
  }

  Future<void> cancel() => _authenticator.cancel();

  void enterProtectedArea() {
    if (state.inProtectedArea) return;
    final enabled = _isEnabled();
    emit(
      state.copyWith(
        inProtectedArea: true,
        locked: enabled,
        pendingLock: !enabled,
      ),
    );
  }

  void exitProtectedArea() {
    emit(const AppLockState());
  }

  void onPreferencesLoaded() {
    if (!state.pendingLock || !state.inProtectedArea) return;
    emit(
      state.copyWith(
        pendingLock: false,
        locked: _isEnabled(),
      ),
    );
  }

  void unlock() {
    if (!state.locked) return;
    emit(state.copyWith(locked: false));
  }

  void onBackgrounded() {
    if (!state.inProtectedArea || !_isEnabled()) return;
    emit(state.copyWith(locked: true));
  }

  Future<bool> authenticate({
    required String reason,
    required AppLockMethod method,
    String? password,
    List<int>? gesture,
  }) async {
    if (state.authenticating) return false;
    emit(state.copyWith(authenticating: true));
    var ok = false;
    try {
      ok = await _authenticator.authenticate(
        reason: reason,
        method: method,
        password: password,
        gesture: gesture,
      );
      return ok;
    } on Object {
      ok = false;
      return false;
    } finally {
      if (!isClosed) {
        emit(
          state.copyWith(
            authenticating: false,
            locked: ok ? false : state.locked,
          ),
        );
      }
    }
  }
}
