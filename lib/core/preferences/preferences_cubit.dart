import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/errors/fx_failure.dart';
import 'package:fortuneboot/core/errors/fx_failure_mapper.dart';
import 'package:fortuneboot/core/preferences/billing_preferences.dart';
import 'package:fortuneboot/core/preferences/dashboard_display_preferences.dart';
import 'package:fortuneboot/core/preferences/finance_color_preferences.dart';
import 'package:fortuneboot/core/preferences/locale_preferences.dart';
import 'package:fortuneboot/core/preferences/screen_capture_preferences.dart';
import 'package:fortuneboot/core/preferences/stats_display_preferences.dart';
import 'package:fortuneboot/core/preferences/theme_preferences.dart';
import 'package:fortuneboot/core/security/screen_capture_protection.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_card_catalog.dart';
import 'package:fortuneboot/features/stats/data/stats_card_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesState extends Equatable {
  final BillingPreferences billing;
  final ThemePreferences theme;
  final LocalePreferences locale;
  final DashboardDisplayPreferences dashboard;
  final StatsDisplayPreferences stats;
  final FinanceColorPreferences financeColors;
  final ScreenCapturePreferences screenCapture;
  final bool isLoading;
  final String? errorMessage;
  final FxFailure? failure;

  const PreferencesState({
    this.billing = const BillingPreferences(),
    this.theme = const ThemePreferences(),
    this.locale = const LocalePreferences(),
    this.dashboard = const DashboardDisplayPreferences(),
    this.stats = const StatsDisplayPreferences(),
    this.financeColors = const FinanceColorPreferences(),
    this.screenCapture = const ScreenCapturePreferences(),
    this.isLoading = false,
    this.errorMessage,
    this.failure,
  });

  PreferencesState copyWith({
    BillingPreferences? billing,
    ThemePreferences? theme,
    LocalePreferences? locale,
    DashboardDisplayPreferences? dashboard,
    StatsDisplayPreferences? stats,
    FinanceColorPreferences? financeColors,
    ScreenCapturePreferences? screenCapture,
    bool? isLoading,
    String? errorMessage,
    FxFailure? failure,
  }) {
    return PreferencesState(
      billing: billing ?? this.billing,
      theme: theme ?? this.theme,
      locale: locale ?? this.locale,
      dashboard: dashboard ?? this.dashboard,
      stats: stats ?? this.stats,
      financeColors: financeColors ?? this.financeColors,
      screenCapture: screenCapture ?? this.screenCapture,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
    billing,
    theme,
    locale,
    dashboard,
    stats,
    financeColors,
    screenCapture,
    isLoading,
    errorMessage,
    failure,
  ];
}

/// App-level user preferences：账单月开始日、主题、语言、首页金额显示、账单颜色。
class PreferencesCubit extends Cubit<PreferencesState> {
  PreferencesCubit({
    SharedPreferences? sharedPreferences,
    ScreenCapturePreferenceStore? screenCapturePreferenceStore,
    ScreenCaptureProtection? screenCaptureProtection,
  }) : _sharedPreferences = sharedPreferences,
       _screenCapturePreferenceStore =
           screenCapturePreferenceStore ??
           SharedPreferencesScreenCapturePreferenceStore(
             sharedPreferences: sharedPreferences,
           ),
       _screenCaptureProtection =
           screenCaptureProtection ?? PlatformScreenCaptureProtection(),
       super(const PreferencesState());

  static const String _monthStartDayKey =
      'fortune.preferences.billing.monthStartDay';
  static const String _themeModeKey = 'fortune.preferences.theme.mode';
  static const String _localeCodeKey = 'fortune.preferences.locale.code';
  static const String _hideAmountsKey =
      'fortune.preferences.dashboard.hideAmounts';
  static const String _dashboardLayoutKey =
      'fortune.preferences.dashboard.layout';
  static const String _statsLayoutKey = 'fortune.preferences.stats.layout';
  static const String _colorPresetKey =
      'fortune.preferences.financeColors.preset';
  static const String _colorIncomeKey =
      'fortune.preferences.financeColors.income';
  static const String _colorExpenseKey =
      'fortune.preferences.financeColors.expense';
  static const String _colorTransferKey =
      'fortune.preferences.financeColors.transfer';
  static const String _colorAdjustKey =
      'fortune.preferences.financeColors.adjust';
  static const String _colorAdvanceKey =
      'fortune.preferences.financeColors.advance';
  static const String _colorReimburseKey =
      'fortune.preferences.financeColors.reimburse';

  SharedPreferences? _sharedPreferences;
  final ScreenCapturePreferenceStore _screenCapturePreferenceStore;
  final ScreenCaptureProtection _screenCaptureProtection;
  var _screenCaptureOperationVersion = 0;
  var _screenCaptureRequestedAllowed = false;

  Future<SharedPreferences> get _prefs async {
    return _sharedPreferences ??= await SharedPreferences.getInstance();
  }

  Future<void> load() async {
    final operationVersion = ++_screenCaptureOperationVersion;
    emit(state.copyWith(isLoading: true));
    try {
      final prefs = await _prefs;
      final day =
          prefs.getInt(_monthStartDayKey) ??
          BillingPreferences.defaultMonthStartDay;
      final defaults = FinanceColorPreferences.defaults();
      final allowScreenCapture =
          await _screenCapturePreferenceStore.readAllowed() ?? false;
      if (operationVersion != _screenCaptureOperationVersion) return;
      _screenCaptureRequestedAllowed = allowScreenCapture;
      final applied = await _screenCaptureProtection.setScreenCaptureAllowed(
        allowScreenCapture,
      );
      if (operationVersion != _screenCaptureOperationVersion) return;
      final screenCapture = ScreenCapturePreferences(
        allowScreenCapture: applied && allowScreenCapture,
      );
      emit(
        PreferencesState(
          billing: BillingPreferences(
            monthStartDay: BillingPreferences.normalizeMonthStartDay(day),
          ),
          theme: ThemePreferences(
            mode: ThemePreferences.modeFromStorage(
              prefs.getString(_themeModeKey),
            ),
          ),
          locale: LocalePreferences(
            code: LocalePreferences.normalize(
              prefs.getString(_localeCodeKey) ?? LocalePreferences.systemCode,
            ),
          ),
          dashboard: _readDashboard(prefs),
          stats: _readStats(prefs),
          financeColors: _readFinanceColors(prefs, defaults),
          screenCapture: screenCapture,
          failure: applied
              ? null
              : const FxFailure(kind: FxFailureKind.persistence),
        ),
      );
    } on Object catch (error) {
      if (operationVersion != _screenCaptureOperationVersion) return;
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: null,
          failure: FxFailureMapper.map(error),
        ),
      );
    }
  }

  DashboardDisplayPreferences _readDashboard(SharedPreferences prefs) {
    final hideAmounts = prefs.getBool(_hideAmountsKey) ?? false;
    final raw = prefs.getString(_dashboardLayoutKey);
    if (raw == null || raw.isEmpty) {
      return DashboardDisplayPreferences(hideAmounts: hideAmounts);
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return DashboardDisplayPreferences(hideAmounts: hideAmounts);
      }
      final map = Map<String, dynamic>.from(decoded);
      final order = _stringList(map['order']);
      final hidden = _stringList(map['hidden']);
      return DashboardDisplayPreferences(
        hideAmounts: hideAmounts,
        cardOrder: order,
        hiddenCardIds: hidden,
        layoutConfigured: true,
      );
    } on Object {
      return DashboardDisplayPreferences(hideAmounts: hideAmounts);
    }
  }

  StatsDisplayPreferences _readStats(SharedPreferences prefs) {
    final raw = prefs.getString(_statsLayoutKey);
    if (raw == null || raw.isEmpty) {
      return const StatsDisplayPreferences();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const StatsDisplayPreferences();
      final map = Map<String, dynamic>.from(decoded);
      return StatsDisplayPreferences(
        cardOrder: _stringList(map['order']),
        hiddenCardIds: _stringList(map['hidden']),
        layoutConfigured: true,
      );
    } on Object {
      return const StatsDisplayPreferences();
    }
  }

  List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return value
        .map((e) => e?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  FinanceColorPreferences _readFinanceColors(
    SharedPreferences prefs,
    FinanceColorPreferences defaults,
  ) {
    final income = prefs.getInt(_colorIncomeKey) ?? defaults.income;
    final expense = prefs.getInt(_colorExpenseKey) ?? defaults.expense;
    final transfer = prefs.getInt(_colorTransferKey) ?? defaults.transfer;
    final adjust = prefs.getInt(_colorAdjustKey) ?? defaults.adjust;
    final advance = prefs.getInt(_colorAdvanceKey) ?? defaults.advance;
    final reimburse = prefs.getInt(_colorReimburseKey) ?? defaults.reimburse;
    final preset =
        prefs.getString(_colorPresetKey) ??
        FinanceColorPreferences.inferPreset(
          income: income,
          expense: expense,
          transfer: transfer,
          adjust: adjust,
          advance: advance,
          reimburse: reimburse,
        );
    return FinanceColorPreferences(
      income: income,
      expense: expense,
      transfer: transfer,
      adjust: adjust,
      advance: advance,
      reimburse: reimburse,
      preset: preset,
    );
  }

  Future<bool> setMonthStartDay(int day) async {
    final normalized = BillingPreferences.normalizeMonthStartDay(day);
    if (normalized == state.billing.monthStartDay) return true;
    return _guardSave(
      save: (prefs) => prefs.setInt(_monthStartDayKey, normalized),
      apply: () => state.copyWith(
        billing: state.billing.copyWith(monthStartDay: normalized),
      ),
    );
  }

  Future<bool> setThemeMode(ThemeMode mode) async {
    if (mode == state.theme.mode) return true;
    return _guardSave(
      save: (prefs) =>
          prefs.setString(_themeModeKey, ThemePreferences.modeToStorage(mode)),
      apply: () => state.copyWith(theme: state.theme.copyWith(mode: mode)),
    );
  }

  Future<bool> setLocaleCode(String code) async {
    final normalized = LocalePreferences.normalize(code);
    if (normalized == state.locale.code) return true;
    return _guardSave(
      save: (prefs) => prefs.setString(_localeCodeKey, normalized),
      apply: () =>
          state.copyWith(locale: state.locale.copyWith(code: normalized)),
    );
  }

  Future<bool> setHideAmounts(bool hide) async {
    if (hide == state.dashboard.hideAmounts) return true;
    return _guardSave(
      save: (prefs) => prefs.setBool(_hideAmountsKey, hide),
      apply: () => state.copyWith(
        dashboard: state.dashboard.copyWith(hideAmounts: hide),
      ),
    );
  }

  /// 保存仪表盘卡片顺序与隐藏集（本地偏好，不走后端）。
  Future<bool> setDashboardLayout({
    required List<DashboardCardId> order,
    required Set<DashboardCardId> hidden,
  }) async {
    final orderIds = order.map(DashboardCardCatalog.toStorageId).toList();
    final hiddenIds = DashboardCardCatalog.allIds
        .where(hidden.contains)
        .map(DashboardCardCatalog.toStorageId)
        .toList();
    final next = state.dashboard.copyWith(
      cardOrder: orderIds,
      hiddenCardIds: hiddenIds,
      layoutConfigured: true,
    );
    if (next == state.dashboard) return true;
    final payload = jsonEncode({'order': orderIds, 'hidden': hiddenIds});
    return _guardSave(
      save: (prefs) => prefs.setString(_dashboardLayoutKey, payload),
      apply: () => state.copyWith(dashboard: next),
    );
  }

  Future<bool> resetDashboardLayout() async {
    if (!state.dashboard.layoutConfigured &&
        state.dashboard.cardOrder.isEmpty &&
        state.dashboard.hiddenCardIds.isEmpty) {
      return true;
    }
    return _guardSave(
      save: (prefs) => prefs.remove(_dashboardLayoutKey),
      apply: () => state.copyWith(
        dashboard: state.dashboard.copyWith(
          cardOrder: const [],
          hiddenCardIds: const [],
          layoutConfigured: false,
        ),
      ),
    );
  }

  /// 保存统计页卡片顺序与隐藏集（本地偏好）。
  Future<bool> setStatsLayout({
    required List<StatsCardId> order,
    required Set<StatsCardId> hidden,
  }) async {
    final orderIds = order.map(StatsCardCatalog.toStorageId).toList();
    final hiddenIds = StatsCardCatalog.allIds
        .where(hidden.contains)
        .map(StatsCardCatalog.toStorageId)
        .toList();
    final next = state.stats.copyWith(
      cardOrder: orderIds,
      hiddenCardIds: hiddenIds,
      layoutConfigured: true,
    );
    if (next == state.stats) return true;
    final payload = jsonEncode({'order': orderIds, 'hidden': hiddenIds});
    return _guardSave(
      save: (prefs) => prefs.setString(_statsLayoutKey, payload),
      apply: () => state.copyWith(stats: next),
    );
  }

  Future<bool> resetStatsLayout() async {
    if (!state.stats.layoutConfigured &&
        state.stats.cardOrder.isEmpty &&
        state.stats.hiddenCardIds.isEmpty) {
      return true;
    }
    return _guardSave(
      save: (prefs) => prefs.remove(_statsLayoutKey),
      apply: () => state.copyWith(
        stats: state.stats.copyWith(
          cardOrder: const [],
          hiddenCardIds: const [],
          layoutConfigured: false,
        ),
      ),
    );
  }

  Future<bool> setScreenCaptureAllowed(bool allowed) async {
    if (allowed == _screenCaptureRequestedAllowed) return true;

    _screenCaptureRequestedAllowed = allowed;
    final operationVersion = ++_screenCaptureOperationVersion;
    emit(state.copyWith(isLoading: true));
    final applied = await _screenCaptureProtection.setScreenCaptureAllowed(
      allowed,
    );
    if (operationVersion != _screenCaptureOperationVersion) return false;
    if (!applied) {
      _screenCaptureRequestedAllowed = state.screenCapture.allowScreenCapture;
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: null,
          failure: const FxFailure(kind: FxFailureKind.persistence),
        ),
      );
      return false;
    }

    try {
      final saved = await _screenCapturePreferenceStore.writeAllowed(allowed);
      if (operationVersion != _screenCaptureOperationVersion) return false;
      if (saved) {
        emit(
          state.copyWith(
            screenCapture: state.screenCapture.copyWith(
              allowScreenCapture: allowed,
            ),
            isLoading: false,
          ),
        );
        return true;
      }
    } on Object catch (_) {
      // Fall through to the shared failure handling below.
    }

    if (allowed) {
      final restored = await _screenCaptureProtection.setScreenCaptureAllowed(
        false,
      );
      if (!restored) {
        _screenCaptureRequestedAllowed = true;
        emit(
          state.copyWith(
            screenCapture: state.screenCapture.copyWith(
              allowScreenCapture: true,
            ),
            isLoading: false,
            errorMessage: null,
            failure: const FxFailure(kind: FxFailureKind.persistence),
          ),
        );
        return false;
      }
    }
    if (operationVersion != _screenCaptureOperationVersion) return false;
    _screenCaptureRequestedAllowed = false;
    emit(
      state.copyWith(
        screenCapture: state.screenCapture.copyWith(allowScreenCapture: false),
        isLoading: false,
        errorMessage: null,
        failure: const FxFailure(kind: FxFailureKind.persistence),
      ),
    );
    return false;
  }

  Future<bool> setFinanceColors(FinanceColorPreferences colors) async {
    if (colors == state.financeColors) return true;
    try {
      final prefs = await _prefs;
      final results = await Future.wait([
        prefs.setString(_colorPresetKey, colors.preset),
        prefs.setInt(_colorIncomeKey, colors.income),
        prefs.setInt(_colorExpenseKey, colors.expense),
        prefs.setInt(_colorTransferKey, colors.transfer),
        prefs.setInt(_colorAdjustKey, colors.adjust),
        prefs.setInt(_colorAdvanceKey, colors.advance),
        prefs.setInt(_colorReimburseKey, colors.reimburse),
      ]);
      if (results.any((ok) => !ok)) {
        emit(
          state.copyWith(
            errorMessage: null,
            failure: const FxFailure(kind: FxFailureKind.persistence),
          ),
        );
        return false;
      }
      emit(state.copyWith(financeColors: colors));
      return true;
    } on Object catch (error) {
      emit(
        state.copyWith(errorMessage: null, failure: FxFailureMapper.map(error)),
      );
      return false;
    }
  }

  Future<bool> resetFinanceColors() =>
      setFinanceColors(FinanceColorPreferences.defaults());

  Future<bool> _guardSave({
    required Future<bool> Function(SharedPreferences prefs) save,
    required PreferencesState Function() apply,
  }) async {
    try {
      final prefs = await _prefs;
      final saved = await save(prefs);
      if (!saved) {
        emit(
          state.copyWith(
            errorMessage: null,
            failure: const FxFailure(kind: FxFailureKind.persistence),
          ),
        );
        return false;
      }
      emit(apply());
      return true;
    } on Object catch (error) {
      emit(
        state.copyWith(errorMessage: null, failure: FxFailureMapper.map(error)),
      );
      return false;
    }
  }
}
