import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/billing_preferences.dart';
import 'package:fortuneboot/core/preferences/dashboard_display_preferences.dart';
import 'package:fortuneboot/core/preferences/finance_color_preferences.dart';
import 'package:fortuneboot/core/preferences/locale_preferences.dart';
import 'package:fortuneboot/core/preferences/theme_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesState extends Equatable {
  final BillingPreferences billing;
  final ThemePreferences theme;
  final LocalePreferences locale;
  final DashboardDisplayPreferences dashboard;
  final FinanceColorPreferences financeColors;
  final bool isLoading;
  final String? errorMessage;

  const PreferencesState({
    this.billing = const BillingPreferences(),
    this.theme = const ThemePreferences(),
    this.locale = const LocalePreferences(),
    this.dashboard = const DashboardDisplayPreferences(),
    this.financeColors = const FinanceColorPreferences(),
    this.isLoading = false,
    this.errorMessage,
  });

  PreferencesState copyWith({
    BillingPreferences? billing,
    ThemePreferences? theme,
    LocalePreferences? locale,
    DashboardDisplayPreferences? dashboard,
    FinanceColorPreferences? financeColors,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PreferencesState(
      billing: billing ?? this.billing,
      theme: theme ?? this.theme,
      locale: locale ?? this.locale,
      dashboard: dashboard ?? this.dashboard,
      financeColors: financeColors ?? this.financeColors,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    billing,
    theme,
    locale,
    dashboard,
    financeColors,
    isLoading,
    errorMessage,
  ];
}

/// App-level user preferences：账单月开始日、主题、语言、首页金额显示、账单颜色。
class PreferencesCubit extends Cubit<PreferencesState> {
  PreferencesCubit({SharedPreferences? sharedPreferences})
    : _sharedPreferences = sharedPreferences,
      super(const PreferencesState());

  static const String _monthStartDayKey =
      'fortune.preferences.billing.monthStartDay';
  static const String _themeModeKey = 'fortune.preferences.theme.mode';
  static const String _localeCodeKey = 'fortune.preferences.locale.code';
  static const String _hideAmountsKey =
      'fortune.preferences.dashboard.hideAmounts';
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

  Future<SharedPreferences> get _prefs async {
    return _sharedPreferences ??= await SharedPreferences.getInstance();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final prefs = await _prefs;
      final day =
          prefs.getInt(_monthStartDayKey) ??
          BillingPreferences.defaultMonthStartDay;
      final defaults = FinanceColorPreferences.defaults();
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
          dashboard: DashboardDisplayPreferences(
            hideAmounts: prefs.getBool(_hideAmountsKey) ?? false,
          ),
          financeColors: FinanceColorPreferences(
            income: prefs.getInt(_colorIncomeKey) ?? defaults.income,
            expense: prefs.getInt(_colorExpenseKey) ?? defaults.expense,
            transfer: prefs.getInt(_colorTransferKey) ?? defaults.transfer,
            adjust: prefs.getInt(_colorAdjustKey) ?? defaults.adjust,
            advance: prefs.getInt(_colorAdvanceKey) ?? defaults.advance,
            reimburse: prefs.getInt(_colorReimburseKey) ?? defaults.reimburse,
          ),
        ),
      );
    } on Object catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<bool> setMonthStartDay(int day) async {
    final normalized = BillingPreferences.normalizeMonthStartDay(day);
    if (normalized == state.billing.monthStartDay) return true;
    return _guardSave(
      save: (prefs) => prefs.setInt(_monthStartDayKey, normalized),
      apply: () => state.copyWith(
        billing: state.billing.copyWith(monthStartDay: normalized),
      ),
      failMessage: '账单月开始日保存失败',
    );
  }

  Future<bool> setThemeMode(ThemeMode mode) async {
    if (mode == state.theme.mode) return true;
    return _guardSave(
      save: (prefs) =>
          prefs.setString(_themeModeKey, ThemePreferences.modeToStorage(mode)),
      apply: () => state.copyWith(theme: state.theme.copyWith(mode: mode)),
      failMessage: '主题保存失败',
    );
  }

  Future<bool> setLocaleCode(String code) async {
    final normalized = LocalePreferences.normalize(code);
    if (normalized == state.locale.code) return true;
    return _guardSave(
      save: (prefs) => prefs.setString(_localeCodeKey, normalized),
      apply: () =>
          state.copyWith(locale: state.locale.copyWith(code: normalized)),
      failMessage: '语言保存失败',
    );
  }

  Future<bool> setHideAmounts(bool hide) async {
    if (hide == state.dashboard.hideAmounts) return true;
    return _guardSave(
      save: (prefs) => prefs.setBool(_hideAmountsKey, hide),
      apply: () => state.copyWith(
        dashboard: state.dashboard.copyWith(hideAmounts: hide),
      ),
      failMessage: '金额显示设置保存失败',
    );
  }

  Future<bool> setFinanceColors(FinanceColorPreferences colors) async {
    if (colors == state.financeColors) return true;
    try {
      final prefs = await _prefs;
      final results = await Future.wait([
        prefs.setInt(_colorIncomeKey, colors.income),
        prefs.setInt(_colorExpenseKey, colors.expense),
        prefs.setInt(_colorTransferKey, colors.transfer),
        prefs.setInt(_colorAdjustKey, colors.adjust),
        prefs.setInt(_colorAdvanceKey, colors.advance),
        prefs.setInt(_colorReimburseKey, colors.reimburse),
      ]);
      if (results.any((ok) => !ok)) {
        emit(state.copyWith(errorMessage: '账单颜色保存失败'));
        return false;
      }
      emit(state.copyWith(financeColors: colors));
      return true;
    } on Object catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> resetFinanceColors() =>
      setFinanceColors(FinanceColorPreferences.defaults());

  Future<bool> _guardSave({
    required Future<bool> Function(SharedPreferences prefs) save,
    required PreferencesState Function() apply,
    required String failMessage,
  }) async {
    try {
      final prefs = await _prefs;
      final saved = await save(prefs);
      if (!saved) {
        emit(state.copyWith(errorMessage: failMessage));
        return false;
      }
      emit(apply());
      return true;
    } on Object catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return false;
    }
  }
}
