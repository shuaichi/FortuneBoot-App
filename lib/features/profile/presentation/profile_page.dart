import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/app_constants.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/preferences/app_lock_preferences.dart';
import 'package:fortuneboot/core/preferences/locale_preferences.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/security/app_lock_cubit.dart';
import 'package:fortuneboot/core/security/app_lock_fingerprint_hint.dart';
import 'package:fortuneboot/core/security/app_lock_gate.dart';
import 'package:fortuneboot/core/security/app_lock_secret_sheets.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/widgets/session_switcher_sheet.dart';
import 'package:fortuneboot/features/profile/data/profile_models.dart';
import 'package:fortuneboot/features/profile/data/profile_service.dart';
import 'package:fortuneboot/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fortuneboot/features/profile/presentation/profile_edit_page.dart';
import 'package:fortuneboot/features/profile/presentation/widgets/donate_qr_tile.dart';
import 'package:fortuneboot/features/profile/presentation/widgets/finance_color_editor.dart';
import 'package:fortuneboot/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_list_item.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/login/model/users.dart';
import 'package:fortuneboot/util/dio_client.dart';
import 'package:fortuneboot/util/image_save_service.dart';

/// 个人中心 / 设置（MainShell "我的" tab）。
///
/// 聚合所有管理入口：用户卡、账本与分组、记账管理、工具箱、偏好设置、关于、退出登录。
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileView();
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  /// 当前展开的分组 id；同一时间只展开一组。
  String? _expandedSection;

  static const _sectionBook = 'book';
  static const _sectionBilling = 'billing';
  static const _sectionToolbox = 'toolbox';
  static const _sectionPreferences = 'preferences';
  static const _sectionAbout = 'about';

  void _toast(
    BuildContext context,
    String message, {
    FxFeedbackTone tone = FxFeedbackTone.info,
  }) {
    FxFeedback.show(context, message: message, tone: tone);
  }

  Future<void> _openEdit(BuildContext context, UserProfile profile) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ProfileEditPage(profile: profile)),
    );
    if (changed == true && context.mounted) {
      context.read<ProfileBloc>().add(const ProfileUserRefreshed());
    }
  }

  void _toggleSection(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      _expandedSection = _expandedSection == id ? null : id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Scaffold(
      backgroundColor: palette.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: kToolbarHeight,
              child: Center(
                child: Text(
                  S.of(context).navProfile,
                  style: FxTypography.title.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      FxSpacing.lg,
                      FxSpacing.lg,
                      FxSpacing.lg,
                      FxSpacing.xxxl,
                    ),
                    children: [
                      _userCard(context, state),
                      const SizedBox(height: FxSpacing.lg),
                      _bookGroupSection(context),
                      const SizedBox(height: FxSpacing.md),
                      _billingSection(context),
                      const SizedBox(height: FxSpacing.md),
                      _toolboxSection(context),
                      const SizedBox(height: FxSpacing.md),
                      _preferenceSection(context),
                      const SizedBox(height: FxSpacing.md),
                      _aboutSection(context, state.about),
                      const SizedBox(height: FxSpacing.xxl),
                      FxButton.critical(
                        label: S.of(context).profileLogout,
                        expand: true,
                        onPressed: () => _confirmLogout(context),
                      ),
                      const SizedBox(height: FxSpacing.xxl),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- 用户卡 ----------------

  Widget _userCard(BuildContext context, ProfileState state) {
    final palette = FxPalette.of(context);
    if (state.status == ProfileStatus.loading && state.profile == null) {
      return const FxCard(
        child: SizedBox(height: 72, child: FxStateViewLoadingInline()),
      );
    }
    if (state.status == ProfileStatus.error && state.profile == null) {
      return FxCard(
        child: FxStateView.error(
          message: state.errorMessage ?? S.of(context).profileLoadFailed,
          onRetry: () => context.read<ProfileBloc>().add(const ProfileLoaded()),
        ),
      );
    }
    final profile = state.profile ?? const UserProfile();
    final displayName = profile.nickname?.isNotEmpty == true
        ? profile.nickname!
        : (profile.username ?? S.of(context).profileNotLoggedIn);
    final avatar = profile.avatar;
    return FxCard(
      onTap: () => _openEdit(context, profile),
      radius: FxRadius.sheet,
      child: Row(
        children: [
          ProfileAvatar(
            imageUrl: avatar,
            cacheToken: avatar,
            label: displayName,
            size: 64,
          ),
          const SizedBox(width: FxSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayName,
                  style: FxTypography.titleLarge.copyWith(
                    color: palette.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: FxSpacing.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        S.of(context).profileViewProfile,
                        style: FxTypography.body.copyWith(
                          color: palette.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: palette.textTertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: S.of(context).profileDonate,
            onPressed: () => _openDonate(context),
            icon: Icon(
              Icons.qr_code_rounded,
              size: 28,
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- 账本与分组 ----------------

  Widget _bookGroupSection(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, session) {
        final palette = FxPalette.of(context);
        final finance = FxFinanceColors.of(context);
        final groupName =
            session.currentGroup?.groupName ?? S.of(context).profileNotSelected;
        final bookName =
            session.currentBook?.bookName ?? S.of(context).profileNotSelected;
        final s = S.of(context);
        return _expandableGroup(
          context,
          id: _sectionBook,
          title: s.profileBookGroup,
          icon: Icons.menu_book_rounded,
          tint: palette.primary,
          subtitle: '$groupName · $bookName',
          features: [
            _ProfileFeature(
              icon: Icons.swap_horiz_rounded,
              tint: palette.primary,
              label: s.profileCurrentGroupBook,
              onTap: () => _openSwitcher(context),
            ),
            _ProfileFeature(
              icon: Icons.folder_copy_rounded,
              tint: palette.info,
              label: s.booksManageTitle,
              onTap: () => AppRouter.push<void>(context, Routes.groups),
            ),
            _ProfileFeature(
              icon: Icons.group_rounded,
              tint: finance.income,
              label: s.profileMemberManageGroup,
              onTap: () => AppRouter.push<void>(context, Routes.groupUsers),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openSwitcher(BuildContext context) async {
    await SessionSwitcherSheet.show(context);
  }

  // ---------------- 记账管理 ----------------

  Widget _billingSection(BuildContext context) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final s = S.of(context);
    return _expandableGroup(
      context,
      id: _sectionBilling,
      title: s.profileBillingManage,
      icon: Icons.receipt_long_rounded,
      tint: finance.expense,
      features: [
        _ProfileFeature(
          icon: Icons.category_rounded,
          tint: finance.expense,
          label: s.profileCategoryManage,
          onTap: () => AppRouter.push<void>(context, Routes.categories),
        ),
        _ProfileFeature(
          icon: Icons.tag_rounded,
          tint: palette.info,
          label: s.profileTagManage,
          onTap: () => AppRouter.push<void>(context, Routes.tags),
        ),
        _ProfileFeature(
          icon: Icons.storefront_rounded,
          tint: finance.adjust,
          label: s.profilePayeeManage,
          onTap: () => AppRouter.push<void>(context, Routes.payees),
        ),
        _ProfileFeature(
          icon: Icons.people_alt_rounded,
          tint: finance.income,
          label: s.profileMemberManageBill,
          onTap: () => AppRouter.push<void>(context, Routes.members),
        ),
        _ProfileFeature(
          icon: Icons.credit_card_rounded,
          tint: palette.primary,
          label: s.profileAccountManage,
          onTap: () => AppRouter.push<void>(context, Routes.accounts),
        ),
      ],
    );
  }

  // ---------------- 工具箱 ----------------

  Widget _toolboxSection(BuildContext context) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final s = S.of(context);
    return _expandableGroup(
      context,
      id: _sectionToolbox,
      title: s.profileToolbox,
      icon: Icons.handyman_rounded,
      tint: finance.transfer,
      features: [
        _ProfileFeature(
          icon: Icons.inventory_2_rounded,
          tint: finance.transfer,
          label: s.profileGoodsManage,
          onTap: () => AppRouter.push<void>(context, Routes.goods),
        ),
        _ProfileFeature(
          icon: Icons.description_rounded,
          tint: palette.info,
          label: s.profileOrdersManage,
          onTap: () => AppRouter.push<void>(context, Routes.orders),
        ),
        _ProfileFeature(
          icon: Icons.repeat_rounded,
          tint: finance.income,
          label: s.profileRecurringManage,
          onTap: () => AppRouter.push<void>(context, Routes.recurring),
        ),
        _ProfileFeature(
          icon: Icons.import_export_rounded,
          tint: finance.adjust,
          label: s.profileImportExport,
          onTap: () => AppRouter.push<void>(context, Routes.io),
        ),
        _ProfileFeature(
          icon: Icons.history_rounded,
          tint: palette.primary,
          label: s.profileLogs,
          onTap: () => AppRouter.push<void>(context, Routes.logs),
        ),
      ],
    );
  }

  // ---------------- 偏好设置 ----------------

  Widget _preferenceSection(BuildContext context) {
    return BlocBuilder<PreferencesCubit, PreferencesState>(
      builder: (context, preferences) {
        final palette = FxPalette.of(context);
        final finance = FxFinanceColors.of(context);
        final startDay = preferences.billing.monthStartDay;
        final localeCode = preferences.locale.code;
        final langLabel = switch (localeCode) {
          'en' => 'English',
          'zh' => S.of(context).commonChinese,
          _ => S.of(context).commonFollowSystem,
        };
        final themeLabel = switch (preferences.theme.mode) {
          ThemeMode.light => S.of(context).profileThemeLight,
          ThemeMode.dark => S.of(context).profileThemeDark,
          ThemeMode.system => S.of(context).commonFollowSystem,
        };
        final screenCaptureSubtitle =
            Theme.of(context).platform == TargetPlatform.iOS
            ? S.of(context).profileScreenCaptureAllowedIosHint
            : S.of(context).profileScreenCaptureAllowedSubtitle;
        return _expandableGroup(
          context,
          id: _sectionPreferences,
          title: S.of(context).profilePreferences,
          icon: Icons.tune_rounded,
          tint: palette.primary,
          body: Column(
            children: [
              FxListItem(
                leading: _tileIcon(Icons.language_rounded, palette.primary),
                title: S.of(context).profileLanguage,
                trailing: Text(
                  langLabel,
                  style: FxTypography.caption.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                showChevron: true,
                onTap: () => _openLanguage(context),
              ),
              _divider(context),
              FxListItem(
                leading: _tileIcon(Icons.dark_mode_rounded, finance.transfer),
                title: S.of(context).profileThemeMode,
                trailing: Text(
                  themeLabel,
                  style: FxTypography.caption.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                showChevron: true,
                onTap: () => _openThemeMode(context),
              ),
              _divider(context),
              FxListItem(
                leading: _tileIcon(Icons.calendar_month_rounded, palette.info),
                title: S.of(context).profileMonthStartDay,
                trailing: Text(
                  S.of(context).profileMonthStartDayValue(startDay),
                  style: FxTypography.caption.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                showChevron: true,
                onTap: () => _openMonthStartDay(context, startDay),
              ),
              _divider(context),
              FxListItem(
                leading: _tileIcon(Icons.content_copy_rounded, palette.primary),
                title: S.of(context).profileCopyUsesCurrentTime,
                subtitle: S.of(context).profileCopyUsesCurrentTimeSubtitle,
                trailing: Switch.adaptive(
                  value: preferences.billing.copyUsesCurrentTime,
                  onChanged: preferences.isLoading
                      ? null
                      : (useCurrentTime) async {
                          final ok = await context
                              .read<PreferencesCubit>()
                              .setCopyUsesCurrentTime(useCurrentTime);
                          if (!context.mounted || ok) return;
                          _toast(
                            context,
                            S.of(context).profileSaveFailedRetry,
                          );
                        },
                ),
              ),
              _divider(context),
              FxListItem(
                leading:
                    _tileIcon(Icons.currency_exchange_rounded, finance.income),
                title: S.of(context).profileCurrencyRefresh,
                trailing: Text(
                  S.of(context).profileRefresh,
                  style: FxTypography.caption.copyWith(color: palette.primary),
                ),
                onTap: () => _refreshCurrency(context),
              ),
              _divider(context),
              if (_supportsAppLockPlatform(context)) ...[
                FxListItem(
                  leading: _tileIcon(Icons.lock_rounded, palette.primary),
                  title: S.of(context).profileAppLock,
                  subtitle: S.of(context).profileAppLockSubtitle,
                  trailing: Switch.adaptive(
                    value: preferences.appLock.enabled,
                    onChanged: preferences.isLoading
                        ? null
                        : (enabled) => _setAppLockEnabled(context, enabled),
                  ),
                ),
                if (preferences.appLock.enabled) ...[
                  _divider(context),
                  FxListItem(
                    leading: _tileIcon(
                      _appLockMethodIcon(preferences.appLock.method),
                      palette.primary,
                    ),
                    title: S.of(context).profileAppLockMethod,
                    trailing: Text(
                      _appLockMethodLabel(
                        S.of(context),
                        preferences.appLock.method,
                      ),
                      style: FxTypography.caption.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                    showChevron: true,
                    onTap: () => _changeAppLockMethod(context),
                  ),
                ],
                _divider(context),
              ],
              FxListItem(
                leading:
                    _tileIcon(Icons.screenshot_monitor_rounded, palette.info),
                title: S.of(context).profileScreenCaptureAllowed,
                subtitle: screenCaptureSubtitle,
                trailing: Switch.adaptive(
                  value: preferences.screenCapture.allowScreenCapture,
                  onChanged: preferences.isLoading
                      ? null
                      : (allowed) async {
                          final ok = await context
                              .read<PreferencesCubit>()
                              .setScreenCaptureAllowed(allowed);
                          if (!context.mounted || ok) return;
                          _toast(
                            context,
                            S.of(context).profileScreenCaptureProtectionFailed,
                          );
                        },
                ),
              ),
              _divider(context),
              FxListItem(
                leading: _tileIcon(Icons.palette_rounded, finance.expense),
                title: S.of(context).profileFinanceColors,
                subtitle: S.of(context).profileFinanceColorsSubtitle,
                showChevron: true,
                onTap: () => _openFinanceColors(context),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 安卓与鸿蒙均可启用应用锁（密码/手势全平台；生物识别走原生通道）。
  bool _supportsAppLockPlatform(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.android ||
        platform == TargetPlatform.ohos;
  }

  Future<void> _setAppLockEnabled(BuildContext context, bool enabled) async {
    final s = S.of(context);
    final prefs = context.read<PreferencesCubit>();
    final lock = context.read<AppLockCubit>();
    if (!enabled) {
      final ok = await prefs.setAppLock(enabled: false);
      if (!context.mounted) return;
      if (!ok) {
        _toast(context, s.profileSaveFailedRetry);
        return;
      }
      lock.unlock();
      return;
    }
    final method = await _pickAndVerifyAppLockMethod(context);
    if (!context.mounted || method == null) return;
    final ok = await prefs.setAppLock(enabled: true, method: method);
    if (!context.mounted) return;
    if (!ok) _toast(context, s.profileSaveFailedRetry);
  }

  Future<void> _changeAppLockMethod(BuildContext context) async {
    final s = S.of(context);
    final prefs = context.read<PreferencesCubit>();
    final method = await _pickAndVerifyAppLockMethod(
      context,
      current: prefs.state.appLock.method,
    );
    if (!context.mounted || method == null) return;
    final ok = await prefs.setAppLock(method: method);
    if (!context.mounted) return;
    if (!ok) _toast(context, s.profileSaveFailedRetry);
  }

  Future<AppLockMethod?> _pickAndVerifyAppLockMethod(
    BuildContext context, {
    AppLockMethod? current,
  }) async {
    final s = S.of(context);
    final lock = context.read<AppLockCubit>();
    final available = await lock.availability(unlocking: false);
    if (!context.mounted) return null;
    if (!available.any) {
      _toast(context, s.profileAppLockUnavailable);
      return null;
    }
    final method = await showAppLockMethodSheet(
      context,
      availability: available,
      current: current,
    );
    if (!context.mounted || method == null) return null;
    // 等底部弹层关闭后再拉系统生物识别，避免控件被立刻取消。
    if (method == AppLockMethod.face ||
        method == AppLockMethod.fingerprint) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!context.mounted) return null;
    }
    switch (method) {
      case AppLockMethod.password:
        final password = await showAppLockPasswordSheet(context, setup: true);
        if (!context.mounted || password == null) return null;
        await lock.enrollPassword(password);
        return method;
      case AppLockMethod.gesture:
        final gesture = await showAppLockGestureSheet(context, setup: true);
        if (!context.mounted || gesture == null) return null;
        await lock.enrollGesture(gesture);
        return method;
      case AppLockMethod.fingerprint:
        // 鸿蒙走系统 UserAuth 控件；Android 才用指纹传感器提示层。
        if (Theme.of(context).platform == TargetPlatform.ohos) {
          final verified = await lock.authenticate(
            reason: s.profileAppLockEnableReason,
            method: method,
          );
          if (!context.mounted) return null;
          if (!verified) {
            _toast(context, s.profileAppLockFailed);
            return null;
          }
          return method;
        }
        final verified = await showAppLockFingerprintPrompt(
          context,
          reason: s.profileAppLockEnableReason,
        );
        if (!context.mounted) return null;
        if (!verified) {
          _toast(context, s.profileAppLockFailed);
          return null;
        }
        return method;
      case AppLockMethod.face:
        final verified = await lock.authenticate(
          reason: s.profileAppLockEnableReason,
          method: method,
        );
        if (!context.mounted) return null;
        if (!verified) {
          _toast(context, s.profileAppLockFailed);
          return null;
        }
        return method;
    }
  }

  String _appLockMethodLabel(S s, AppLockMethod method) {
    return switch (method) {
      AppLockMethod.face => s.profileAppLockMethodFace,
      AppLockMethod.fingerprint => s.profileAppLockMethodFingerprint,
      AppLockMethod.password => s.profileAppLockMethodPassword,
      AppLockMethod.gesture => s.profileAppLockMethodGesture,
    };
  }

  IconData _appLockMethodIcon(AppLockMethod method) {
    return switch (method) {
      AppLockMethod.face => Icons.face_retouching_natural_rounded,
      AppLockMethod.fingerprint => Icons.fingerprint_rounded,
      AppLockMethod.password => Icons.password_rounded,
      AppLockMethod.gesture => Icons.gesture_rounded,
    };
  }

  Future<void> _openThemeMode(BuildContext context) async {
    final cubit = context.read<PreferencesCubit>();
    final current = cubit.state.theme.mode;
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    await FxSheet.show<void>(
      context,
      title: S.of(context).profileThemeMode,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entry in [
            (
              ThemeMode.system,
              S.of(context).commonFollowSystem,
              Icons.brightness_auto_rounded,
            ),
            (
              ThemeMode.light,
              S.of(context).profileThemeLight,
              Icons.light_mode_rounded,
            ),
            (
              ThemeMode.dark,
              S.of(context).profileThemeDark,
              Icons.dark_mode_rounded,
            ),
          ])
            FxListItem(
              leading: _tileIcon(entry.$3, finance.transfer),
              title: entry.$2,
              trailing: current == entry.$1
                  ? Icon(Icons.check_rounded, color: palette.primary)
                  : null,
              onTap: () async {
                final ok = await cubit.setThemeMode(entry.$1);
                if (!context.mounted) return;
                if (ok) {
                  Navigator.of(context).pop();
                } else {
                  _toast(context, S.of(context).profileSaveFailedRetry);
                }
              },
            ),
        ],
      ),
    );
  }

  Future<void> _openFinanceColors(BuildContext context) async {
    final cubit = context.read<PreferencesCubit>();
    await FxSheet.show<void>(
      context,
      title: S.of(context).profileFinanceColors,
      scrollable: true,
      child: FinanceColorEditor(cubit: cubit),
    );
  }

  Future<void> _openMonthStartDay(BuildContext context, int currentDay) async {
    final palette = FxPalette.of(context);
    await FxSheet.show<void>(
      context,
      title: S.of(context).profileMonthStartDay,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * FxSheet.pickerHeightFactor,
        child: ListView.builder(
          itemCount: 31,
          itemBuilder: (context, index) {
            final day = index + 1;
            return FxListItem(
              leading: _tileIcon(Icons.event_rounded, palette.info),
              title: S.of(context).profileMonthStartDayValue(day),
              subtitle: day > 28
                  ? S.of(context).profileMonthStartDayHint
                  : null,
              trailing: currentDay == day
                  ? Icon(Icons.check_rounded, color: palette.primary)
                  : null,
              onTap: () async {
                final saved = await context
                    .read<PreferencesCubit>()
                    .setMonthStartDay(day);
                if (!context.mounted) return;
                if (saved) {
                  Navigator.of(context).pop();
                } else {
                  _toast(context, S.of(context).profileSaveFailedRetry);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _openLanguage(BuildContext context) async {
    final cubit = context.read<PreferencesCubit>();
    final current = cubit.state.locale.code;
    final palette = FxPalette.of(context);
    await FxSheet.show<void>(
      context,
      title: S.of(context).profileSelectLanguage,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entry in [
            (
              LocalePreferences.systemCode,
              S.of(context).commonFollowSystem,
              Icons.language_rounded,
            ),
            ('zh', S.of(context).commonChinese, Icons.translate_rounded),
            ('en', 'English', Icons.translate_rounded),
          ])
            FxListItem(
              leading: _tileIcon(entry.$3, palette.primary),
              title: entry.$2,
              trailing: current == entry.$1
                  ? Icon(Icons.check_rounded, color: palette.primary)
                  : null,
              onTap: () async {
                final ok = await cubit.setLocaleCode(entry.$1);
                if (!context.mounted) return;
                if (ok) {
                  Navigator.of(context).pop();
                } else {
                  _toast(context, S.of(context).profileSaveFailedRetry);
                }
              },
            ),
        ],
      ),
    );
  }

  Future<void> _refreshCurrency(BuildContext context) async {
    final s = S.of(context);
    HapticFeedback.selectionClick();
    _toast(context, s.profileCurrencyRefreshing);
    try {
      await ProfileService().refreshCurrency();
      if (context.mounted) _toast(context, s.profileCurrencyRefreshed);
    } on Object {
      if (context.mounted) {
        _toast(context, s.profileSaveFailedRetry, tone: FxFeedbackTone.error);
      }
    }
  }

  // ---------------- 关于 ----------------

  Widget _aboutSection(BuildContext context, AppAbout about) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final s = S.of(context);
    return _expandableGroup(
      context,
      id: _sectionAbout,
      title: s.profileAbout,
      icon: Icons.info_outline_rounded,
      tint: palette.primary,
      subtitle: about.appVersion.isEmpty ? null : about.appVersion,
      features: [
        _ProfileFeature(
          icon: Icons.info_outline_rounded,
          tint: palette.primary,
          label: s.profileAboutApp,
          onTap: () => _openAbout(context, about),
        ),
        _ProfileFeature(
          icon: Icons.help_outline_rounded,
          tint: palette.info,
          label: s.profileHelp,
          onTap: () => _openHelp(context),
        ),
        _ProfileFeature(
          icon: Icons.favorite_border_rounded,
          tint: finance.expense,
          label: s.profileDonate,
          onTap: () => _openDonate(context),
        ),
      ],
    );
  }

  Future<void> _openAbout(BuildContext context, AppAbout about) async {
    await FxSheet.show<void>(
      context,
      title: S.of(context).profileAboutApp,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FxSpacing.lg,
          0,
          FxSpacing.lg,
          FxSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _aboutRow(
              context,
              S.of(context).profileAppVersion,
              about.appVersion.isEmpty ? '-' : about.appVersion,
            ),
            _aboutRow(
              context,
              S.of(context).profileApiVersion,
              about.apiVersion ?? '-',
            ),
            _aboutRow(
              context,
              S.of(context).profileAppIcp,
              AppConstants.appIcpFiling,
            ),
            _aboutRow(context, S.of(context).profileIcp, about.icp ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _aboutRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FxSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: FxTypography.label.copyWith(
                color: FxPalette.of(context).textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value, style: FxTypography.body)),
        ],
      ),
    );
  }

  Future<void> _openHelp(BuildContext context) async {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final s = S.of(context);
    final sections = <(IconData, Color, String, String)>[
      (
        Icons.add_circle_rounded,
        palette.primary,
        s.profileHelpQuickTitle,
        s.profileHelpQuickBody,
      ),
      (
        Icons.receipt_long_rounded,
        finance.expense,
        s.profileHelpBillsTitle,
        s.profileHelpBillsBody,
      ),
      (
        Icons.menu_book_rounded,
        finance.transfer,
        s.profileHelpBookTitle,
        s.profileHelpBookBody,
      ),
      (
        Icons.category_rounded,
        palette.info,
        s.profileHelpManageTitle,
        s.profileHelpManageBody,
      ),
      (
        Icons.autorenew_rounded,
        finance.income,
        s.profileHelpRecurringTitle,
        s.profileHelpRecurringBody,
      ),
      (
        Icons.visibility_off_rounded,
        finance.adjust,
        s.profileHelpPrivacyTitle,
        s.profileHelpPrivacyBody,
      ),
      (
        Icons.support_agent_rounded,
        palette.textSecondary,
        s.profileHelpContactTitle,
        s.profileHelpContactBody,
      ),
    ];
    await FxSheet.show<void>(
      context,
      title: s.profileHelp,
      expand: true,
      expandHeightFactor: FxSheet.pickerHeightFactor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          FxSpacing.lg,
          0,
          FxSpacing.lg,
          FxSpacing.xxxl,
        ),
        children: [
          Text(
            s.profileHelpIntro,
            style: FxTypography.body.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: FxSpacing.lg),
          for (final sec in sections) ...[
            _helpSection(context, sec.$1, sec.$2, sec.$3, sec.$4),
            const SizedBox(height: FxSpacing.md),
          ],
        ],
      ),
    );
  }

  Widget _helpSection(
    BuildContext context,
    IconData icon,
    Color tint,
    String title,
    String body,
  ) {
    final palette = FxPalette.of(context);
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _tileIcon(icon, tint),
              const SizedBox(width: FxSpacing.md),
              Expanded(child: Text(title, style: FxTypography.bodyStrong)),
            ],
          ),
          const SizedBox(height: FxSpacing.sm),
          Text(
            body,
            style: FxTypography.body.copyWith(
              color: palette.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDonate(BuildContext context) async {
    final finance = FxFinanceColors.of(context);
    final palette = FxPalette.of(context);
    await FxSheet.show<void>(
      context,
      title: S.of(context).profileDonate,
      scrollable: true,
      maxHeightFactor: FxSheet.pickerHeightFactor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FxSpacing.lg,
          0,
          FxSpacing.lg,
          FxSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_rounded, size: 44, color: finance.expense),
            const SizedBox(height: FxSpacing.sm),
            Text(
              S.of(context).profileDonateContent,
              style: FxTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FxSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: DonateQrTile(
                    assetPath: 'assets/images/donate_wechat.jpg',
                    fileName: 'fortuneboot_donate_wechat.jpg',
                    label: S.of(context).profileDonateWechat,
                    semanticsLabel:
                        '${S.of(context).profileDonateWechat} '
                        '${S.of(context).profileDonateScanHint}',
                    tint: finance.expense,
                    icon: Icons.wechat_rounded,
                    onSave: ImageSaveService.saveAssetImage,
                  ),
                ),
                const SizedBox(width: FxSpacing.md),
                Expanded(
                  child: DonateQrTile(
                    assetPath: 'assets/images/donate_alipay.jpg',
                    fileName: 'fortuneboot_donate_alipay.jpg',
                    label: S.of(context).profileDonateAlipay,
                    semanticsLabel:
                        '${S.of(context).profileDonateAlipay} '
                        '${S.of(context).profileDonateScanHint}',
                    tint: palette.info,
                    icon: Icons.account_balance_wallet_rounded,
                    onSave: ImageSaveService.saveAssetImage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FxSpacing.md),
            Text(
              S.of(context).profileDonateScanHint,
              style: FxTypography.caption.copyWith(color: palette.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- 退出登录 ----------------

  Future<void> _confirmLogout(BuildContext context) async {
    final sessionCubit = context.read<SessionCubit>();
    final navigator = Navigator.of(context, rootNavigator: true);
    await FxSheet.show<void>(
      context,
      title: S.of(context).profileLogout,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FxSpacing.lg,
          0,
          FxSpacing.lg,
          FxSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              S.of(context).profileLogoutConfirm,
              style: FxTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FxSpacing.xl),
            FxButton.critical(
              label: S.of(context).profileLogout,
              expand: true,
              onPressed: () async {
                // 纯本地清理，不调接口。
                final lockCubit = context.read<AppLockCubit>();
                DioClient().clearAuthHeader();
                await UserDataSingleton().clearAuth();
                sessionCubit.reset();
                lockCubit.exitProtectedArea();
                navigator.pushNamedAndRemoveUntil(
                  // 登出强制返回URL配置页，用于用户更换服务器（登录页无法直接返回URL配置页）
                  Routes.baseUrlConfig,
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: FxSpacing.sm),
            FxButton.text(
              label: S.of(context).commonCancel,
              expand: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- 复用小组件 ----------------

  Widget _expandableGroup(
    BuildContext context, {
    required String id,
    required String title,
    required IconData icon,
    required Color tint,
    String? subtitle,
    List<_ProfileFeature> features = const [],
    Widget? body,
  }) {
    final palette = FxPalette.of(context);
    final expanded = _expandedSection == id;
    return FxCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          FxListItem(
            leading: _tileIcon(icon, tint),
            title: title,
            subtitle: subtitle,
            trailing: AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.expand_more_rounded,
                color: palette.textTertiary,
              ),
            ),
            onTap: () => _toggleSection(id),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeOutCubic,
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              children: [
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: palette.border,
                ),
                if (body != null)
                  body
                else
                  _featureButtonGrid(context, features),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureButtonGrid(
    BuildContext context,
    List<_ProfileFeature> features,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.md,
        FxSpacing.sm,
        FxSpacing.md,
        FxSpacing.md,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: features.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: FxSpacing.sm,
          crossAxisSpacing: FxSpacing.sm,
          childAspectRatio: 0.92,
        ),
        itemBuilder: (context, index) {
          final feature = features[index];
          return _featureButton(context, feature);
        },
      ),
    );
  }

  Widget _featureButton(BuildContext context, _ProfileFeature feature) {
    final palette = FxPalette.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          feature.onTap();
        },
        borderRadius: FxRadius.tileBorder,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: FxSpacing.xs,
            vertical: FxSpacing.sm,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _tileIcon(feature.icon, feature.tint),
              const SizedBox(height: FxSpacing.sm),
              Text(
                feature.label,
                style: FxTypography.caption.copyWith(
                  color: palette.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tileIcon(IconData icon, Color tint) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: FxRadius.tileBorder,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20, color: tint),
    );
  }

  Widget _divider(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 64),
    child: Divider(
      height: 1,
      thickness: 0.5,
      color: FxPalette.of(context).border,
    ),
  );
}

class _ProfileFeature {
  const _ProfileFeature({
    required this.icon,
    required this.tint,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final String label;
  final VoidCallback onTap;
}

/// 内联 loading（用于卡片内小高度占位）。
class FxStateViewLoadingInline extends StatelessWidget {
  const FxStateViewLoadingInline({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }
}
