import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/preferences/locale_preferences.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/widgets/session_switcher_sheet.dart';
import 'package:fortuneboot/features/profile/data/profile_models.dart';
import 'package:fortuneboot/features/profile/data/profile_service.dart';
import 'package:fortuneboot/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fortuneboot/features/profile/presentation/profile_edit_page.dart';
import 'package:fortuneboot/features/profile/presentation/widgets/finance_color_editor.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_list_item.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/login/model/users.dart';
import 'package:fortuneboot/util/dio_client.dart';

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

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openEdit(BuildContext context, UserProfile profile) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ProfileEditPage(profile: profile)),
    );
    if (changed == true && context.mounted) {
      context.read<ProfileBloc>().add(const ProfileUserRefreshed());
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Scaffold(
      backgroundColor: palette.canvas,
      body: SafeArea(
        bottom: false,
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
                const SizedBox(height: FxSpacing.lg),
                _billingSection(context),
                const SizedBox(height: FxSpacing.lg),
                _toolboxSection(context),
                const SizedBox(height: FxSpacing.lg),
                _preferenceSection(context),
                const SizedBox(height: FxSpacing.lg),
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
    final avatar = profile.avatar;
    return FxCard(
      onTap: () => _openEdit(context, profile),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.primaryContainer,
              image: (avatar != null && avatar.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(avatar),
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: (avatar == null || avatar.isEmpty)
                ? Icon(Icons.person_rounded, size: 30, color: palette.primary)
                : null,
          ),
          const SizedBox(width: FxSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.nickname?.isNotEmpty == true
                      ? profile.nickname!
                      : (profile.username ?? S.of(context).profileNotLoggedIn),
                  style: FxTypography.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (profile.roleName?.isNotEmpty == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FxSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: palette.primaryContainer,
                      borderRadius: FxRadius.pillBorder,
                    ),
                    child: Text(
                      profile.roleName!,
                      style: FxTypography.caption.copyWith(
                        color: palette.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context).profileEditProfile,
                style: FxTypography.caption.copyWith(
                  color: palette.textSecondary,
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: palette.textTertiary),
            ],
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
        return _sectionCard(context, S.of(context).profileBookGroup, [
          FxListItem(
            leading: _tileIcon(Icons.swap_horiz_rounded, palette.primary),
            title: S.of(context).profileCurrentGroupBook,
            subtitle: '$groupName · $bookName',
            showChevron: true,
            onTap: () => _openSwitcher(context),
          ),
          _divider(context),
          FxListItem(
            leading: _tileIcon(Icons.folder_rounded, palette.info),
            title: S.of(context).profileGroupManage,
            showChevron: true,
            onTap: () => AppRouter.push<void>(context, Routes.groups),
          ),
          _divider(context),
          FxListItem(
            leading: _tileIcon(Icons.menu_book_rounded, finance.transfer),
            title: S.of(context).profileBookManage,
            showChevron: true,
            onTap: () => AppRouter.push<void>(context, Routes.books),
          ),
          _divider(context),
          FxListItem(
            leading: _tileIcon(Icons.group_rounded, finance.income),
            title: S.of(context).profileMemberManageGroup,
            showChevron: true,
            onTap: () => AppRouter.push<void>(context, Routes.groupUsers),
          ),
        ]);
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
    return _sectionCard(context, S.of(context).profileBillingManage, [
      _navItem(
        context,
        Icons.category_rounded,
        finance.expense,
        S.of(context).profileCategoryManage,
        Routes.categories,
      ),
      _divider(context),
      _navItem(
        context,
        Icons.tag_rounded,
        palette.info,
        S.of(context).profileTagManage,
        Routes.tags,
      ),
      _divider(context),
      _navItem(
        context,
        Icons.storefront_rounded,
        finance.adjust,
        S.of(context).profilePayeeManage,
        Routes.payees,
      ),
      _divider(context),
      _navItem(
        context,
        Icons.people_alt_rounded,
        finance.income,
        S.of(context).profileMemberManageBill,
        Routes.members,
      ),
      _divider(context),
      _navItem(
        context,
        Icons.credit_card_rounded,
        palette.primary,
        S.of(context).profileAccountManage,
        Routes.accounts,
      ),
    ]);
  }

  // ---------------- 工具箱 ----------------

  Widget _toolboxSection(BuildContext context) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    return _sectionCard(context, S.of(context).profileToolbox, [
      _navItem(
        context,
        Icons.inventory_2_rounded,
        finance.transfer,
        S.of(context).profileGoodsManage,
        Routes.goods,
      ),
      _divider(context),
      _navItem(
        context,
        Icons.description_rounded,
        palette.info,
        S.of(context).profileOrdersManage,
        Routes.orders,
      ),
      _divider(context),
      _navItem(
        context,
        Icons.repeat_rounded,
        finance.income,
        S.of(context).profileRecurringManage,
        Routes.recurring,
      ),
      _divider(context),
      _navItem(
        context,
        Icons.import_export_rounded,
        finance.adjust,
        S.of(context).profileImportExport,
        Routes.io,
      ),
    ]);
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
        return _sectionCard(context, S.of(context).profilePreferences, [
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
            leading: _tileIcon(Icons.currency_exchange_rounded, finance.income),
            title: S.of(context).profileCurrencyRefresh,
            trailing: Text(
              S.of(context).profileRefresh,
              style: FxTypography.caption.copyWith(color: palette.primary),
            ),
            onTap: () => _refreshCurrency(context),
          ),
          _divider(context),
          FxListItem(
            leading: _tileIcon(Icons.visibility_off_rounded, finance.adjust),
            title: S.of(context).profileHideAmounts,
            subtitle: S.of(context).profileHideAmountsSubtitle,
            trailing: Switch.adaptive(
              value: preferences.dashboard.hideAmounts,
              onChanged: (hide) async {
                final ok = await context
                    .read<PreferencesCubit>()
                    .setHideAmounts(hide);
                if (!context.mounted || ok) return;
                _toast(context, S.of(context).profileSaveFailedRetry);
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
        ]);
      },
    );
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
        height: MediaQuery.of(context).size.height * 0.58,
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
    } on Object catch (e) {
      if (context.mounted) {
        _toast(context, s.profileCurrencyRefreshFailed(e.toString()));
      }
    }
  }

  // ---------------- 关于 ----------------

  Widget _aboutSection(BuildContext context, AppAbout about) {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final version = about.appVersion.isEmpty ? '' : 'v${about.appVersion}';
    return _sectionCard(context, S.of(context).profileAbout, [
      FxListItem(
        leading: _tileIcon(Icons.info_outline_rounded, palette.primary),
        title: S.of(context).profileAboutApp,
        trailing: Text(
          version,
          style: FxTypography.caption.copyWith(color: palette.textSecondary),
        ),
        showChevron: true,
        onTap: () => _openAbout(context, about),
      ),
      _divider(context),
      FxListItem(
        leading: _tileIcon(Icons.help_outline_rounded, palette.info),
        title: S.of(context).profileHelp,
        showChevron: true,
        onTap: () => _openHelp(context),
      ),
      _divider(context),
      FxListItem(
        leading: _tileIcon(Icons.favorite_border_rounded, finance.expense),
        title: S.of(context).profileDonate,
        showChevron: true,
        onTap: () => _openDonate(context),
      ),
    ]);
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
              about.appVersion.isEmpty ? '-' : 'v${about.appVersion}',
            ),
            _aboutRow(context, S.of(context).profileApiVersion, about.apiVersion ?? '-'),
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
            width: 88,
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
      (Icons.add_circle_rounded, palette.primary, s.profileHelpQuickTitle, s.profileHelpQuickBody),
      (Icons.receipt_long_rounded, finance.expense, s.profileHelpBillsTitle, s.profileHelpBillsBody),
      (Icons.menu_book_rounded, finance.transfer, s.profileHelpBookTitle, s.profileHelpBookBody),
      (Icons.category_rounded, palette.info, s.profileHelpManageTitle, s.profileHelpManageBody),
      (Icons.autorenew_rounded, finance.income, s.profileHelpRecurringTitle, s.profileHelpRecurringBody),
      (Icons.visibility_off_rounded, finance.adjust, s.profileHelpPrivacyTitle, s.profileHelpPrivacyBody),
      (Icons.support_agent_rounded, palette.textSecondary, s.profileHelpContactTitle, s.profileHelpContactBody),
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
              Expanded(
                child: Text(title, style: FxTypography.bodyStrong),
              ),
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
                  child: _donateQr(
                    context,
                    asset: 'assets/images/donate_wechat.jpg',
                    label: S.of(context).profileDonateWechat,
                    tint: finance.expense,
                    icon: Icons.wechat_rounded,
                  ),
                ),
                const SizedBox(width: FxSpacing.md),
                Expanded(
                  child: _donateQr(
                    context,
                    asset: 'assets/images/donate_alipay.jpg',
                    label: S.of(context).profileDonateAlipay,
                    tint: palette.info,
                    icon: Icons.account_balance_wallet_rounded,
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

  Widget _donateQr(
    BuildContext context, {
    required String asset,
    required String label,
    required Color tint,
    required IconData icon,
  }) {
    final palette = FxPalette.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: tint),
            const SizedBox(width: FxSpacing.xs),
            Text(
              label,
              style: FxTypography.label.copyWith(color: tint),
            ),
          ],
        ),
        const SizedBox(height: FxSpacing.sm),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: FxRadius.cardBorder,
              border: Border.all(color: palette.border),
            ),
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.all(FxSpacing.sm),
            child: Image.asset(
              asset,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => Center(
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: 48,
                  color: palette.textTertiary,
                ),
              ),
            ),
          ),
        ),
      ],
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
                DioClient().clearAuthHeader();
                await UserDataSingleton().clearAuth();
                sessionCubit.reset();
                navigator.pushNamedAndRemoveUntil(
                  Routes.auth,
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

  Widget _sectionCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: FxSpacing.xs,
            bottom: FxSpacing.sm,
          ),
          child: Text(
            title,
            style: FxTypography.label.copyWith(
              color: FxPalette.of(context).textSecondary,
            ),
          ),
        ),
        FxCard(
          padding: const EdgeInsets.symmetric(vertical: FxSpacing.xs),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    Color tint,
    String title,
    String route,
  ) {
    return FxListItem(
      leading: _tileIcon(icon, tint),
      title: title,
      showChevron: true,
      onTap: () => AppRouter.push<void>(context, route),
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
