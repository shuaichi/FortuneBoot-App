import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/app/fx_app.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/profile/data/profile_models.dart';
import 'package:fortuneboot/features/profile/data/profile_service.dart';
import 'package:fortuneboot/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fortuneboot/features/profile/presentation/profile_edit_page.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_list_item.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
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
      MaterialPageRoute(
        builder: (_) => ProfileEditPage(profile: profile),
      ),
    );
    if (changed == true && context.mounted) {
      context.read<ProfileBloc>().add(const ProfileUserRefreshed());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FxColors.canvas,
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
                  label: '退出登录',
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
    if (state.status == ProfileStatus.loading && state.profile == null) {
      return const FxCard(
        child: SizedBox(height: 72, child: FxStateViewLoadingInline()),
      );
    }
    if (state.status == ProfileStatus.error && state.profile == null) {
      return FxCard(
        child: FxStateView.error(
          message: state.errorMessage ?? '资料加载失败',
          onRetry: () =>
              context.read<ProfileBloc>().add(const ProfileLoaded()),
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
              color: FxColors.primaryContainer,
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
                ? const Icon(Icons.person_rounded,
                    size: 30, color: FxColors.primary)
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
                      : (profile.username ?? '未登录'),
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
                      color: FxColors.primaryContainer,
                      borderRadius: FxRadius.pillBorder,
                    ),
                    child: Text(
                      profile.roleName!,
                      style: FxTypography.caption
                          .copyWith(color: FxColors.primary),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('编辑资料',
                  style: FxTypography.caption
                      .copyWith(color: FxColors.textSecondary)),
              const Icon(Icons.chevron_right_rounded,
                  color: FxColors.textTertiary),
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
        final groupName = session.currentGroup?.groupName ?? '未选择';
        final bookName = session.currentBook?.bookName ?? '未选择';
        return _sectionCard(
          '账本与分组',
          [
            FxListItem(
              leading: _tileIcon(Icons.swap_horiz_rounded, FxColors.primary),
              title: '当前分组·账本',
              subtitle: '$groupName · $bookName',
              showChevron: true,
              onTap: () => _openSwitcher(context),
            ),
            _divider(),
            FxListItem(
              leading: _tileIcon(Icons.folder_rounded, FxColors.info),
              title: '分组管理',
              showChevron: true,
              onTap: () => AppRouter.push<void>(context, Routes.books),
            ),
            _divider(),
            FxListItem(
              leading:
                  _tileIcon(Icons.menu_book_rounded, FxColors.transfer),
              title: '账本管理',
              showChevron: true,
              onTap: () => AppRouter.push<void>(context, Routes.books),
            ),
            _divider(),
            FxListItem(
              leading: _tileIcon(Icons.group_rounded, FxColors.income),
              title: '成员管理（分组协作）',
              showChevron: true,
              onTap: () => AppRouter.push<void>(context, Routes.groupUsers),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openSwitcher(BuildContext context) async {
    final cubit = context.read<SessionCubit>();
    await FxSheet.show<void>(
      context,
      title: '切换分组 / 账本',
      child: _SwitcherSheet(cubit: cubit),
    );
  }

  // ---------------- 记账管理 ----------------

  Widget _billingSection(BuildContext context) {
    return _sectionCard('记账管理', [
      _navItem(context, Icons.category_rounded, FxColors.expense, '分类管理',
          Routes.categories),
      _divider(),
      _navItem(context, Icons.tag_rounded, FxColors.info, '标签管理', Routes.tags),
      _divider(),
      _navItem(context, Icons.storefront_rounded, FxColors.adjust, '交易对象管理',
          Routes.payees),
      _divider(),
      _navItem(context, Icons.people_alt_rounded, FxColors.income, '成员管理（账单）',
          Routes.members),
      _divider(),
      _navItem(context, Icons.credit_card_rounded, FxColors.primary, '账户管理',
          Routes.accounts),
    ]);
  }

  // ---------------- 工具箱 ----------------

  Widget _toolboxSection(BuildContext context) {
    return _sectionCard('工具箱', [
      _navItem(context, Icons.inventory_2_rounded, FxColors.transfer, '归物管理',
          Routes.goods),
      _divider(),
      _navItem(context, Icons.description_rounded, FxColors.info, '单据管理',
          Routes.orders),
      _divider(),
      _navItem(context, Icons.repeat_rounded, FxColors.income, '周期记账',
          Routes.recurring),
      _divider(),
      _navItem(context, Icons.import_export_rounded, FxColors.adjust, '导入 / 导出',
          Routes.io),
    ]);
  }

  // ---------------- 偏好设置 ----------------

  Widget _preferenceSection(BuildContext context) {
    final locale = AppLocale.value;
    final langLabel = (locale?.languageCode == 'en') ? 'English' : '中文';
    return _sectionCard('偏好设置', [
      FxListItem(
        leading: _tileIcon(Icons.language_rounded, FxColors.primary),
        title: '语言',
        trailing: Text(langLabel,
            style:
                FxTypography.caption.copyWith(color: FxColors.textSecondary)),
        showChevron: true,
        onTap: () => _openLanguage(context),
      ),
      _divider(),
      FxListItem(
        leading: _tileIcon(Icons.currency_exchange_rounded, FxColors.income),
        title: '汇率刷新',
        trailing: Text('刷新',
            style: FxTypography.caption.copyWith(color: FxColors.primary)),
        onTap: () => _refreshCurrency(context),
      ),
      _divider(),
      FxListItem(
        leading: _tileIcon(Icons.tune_rounded, FxColors.transfer),
        title: '首页金额显示设置',
        showChevron: true,
        onTap: () => _openDisplayConfig(context),
      ),
    ]);
  }

  Future<void> _openLanguage(BuildContext context) async {
    final current = AppLocale.value?.languageCode ?? 'zh';
    await FxSheet.show<void>(
      context,
      title: '选择语言',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FxListItem(
            leading: _tileIcon(Icons.translate_rounded, FxColors.primary),
            title: '中文',
            trailing: current == 'zh'
                ? const Icon(Icons.check_rounded, color: FxColors.primary)
                : null,
            onTap: () {
              AppLocale.set(const Locale('zh', 'CN'));
              Navigator.of(context).pop();
            },
          ),
          FxListItem(
            leading: _tileIcon(Icons.translate_rounded, FxColors.info),
            title: 'English',
            trailing: current == 'en'
                ? const Icon(Icons.check_rounded, color: FxColors.primary)
                : null,
            onTap: () {
              AppLocale.set(const Locale('en'));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _refreshCurrency(BuildContext context) async {
    HapticFeedback.selectionClick();
    _toast(context, '正在刷新汇率…');
    try {
      await ProfileService().refreshCurrency();
      if (context.mounted) _toast(context, '汇率已刷新');
    } on Object catch (e) {
      if (context.mounted) _toast(context, '刷新失败：$e');
    }
  }

  Future<void> _openDisplayConfig(BuildContext context) async {
    await FxSheet.show<void>(
      context,
      title: '首页金额显示设置',
      child: FutureBuilder<String?>(
        future: ProfileService().getDisplayConfig(),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 120,
              child: FxStateViewLoadingInline(),
            );
          }
          final config = snap.data;
          return Padding(
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
                const Text('当前配置', style: FxTypography.label),
                const SizedBox(height: FxSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(FxSpacing.md),
                  decoration: BoxDecoration(
                    color: FxColors.surfaceMuted,
                    borderRadius: FxRadius.tileBorder,
                  ),
                  child: Text(
                    (config == null || config.isEmpty) ? '默认显示' : config,
                    style: FxTypography.body,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------- 关于 ----------------

  Widget _aboutSection(BuildContext context, AppAbout about) {
    final version =
        about.appVersion.isEmpty ? '' : 'v${about.appVersion}';
    return _sectionCard('关于', [
      FxListItem(
        leading: _tileIcon(Icons.info_outline_rounded, FxColors.primary),
        title: '关于好记',
        trailing: Text(version,
            style:
                FxTypography.caption.copyWith(color: FxColors.textSecondary)),
        showChevron: true,
        onTap: () => _openAbout(context, about),
      ),
      _divider(),
      FxListItem(
        leading: _tileIcon(Icons.help_outline_rounded, FxColors.info),
        title: '帮助',
        showChevron: true,
        onTap: () => _openHelp(context),
      ),
      _divider(),
      FxListItem(
        leading: _tileIcon(Icons.favorite_border_rounded, FxColors.expense),
        title: '捐赠',
        showChevron: true,
        onTap: () => _openDonate(context),
      ),
    ]);
  }

  Future<void> _openAbout(BuildContext context, AppAbout about) async {
    await FxSheet.show<void>(
      context,
      title: '关于好记',
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
            _aboutRow('应用版本',
                about.appVersion.isEmpty ? '-' : 'v${about.appVersion}'),
            _aboutRow('API 版本', about.apiVersion ?? '-'),
            _aboutRow('ICP 备案', about.icp ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _aboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FxSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: FxTypography.label),
          ),
          Expanded(child: Text(value, style: FxTypography.body)),
        ],
      ),
    );
  }

  Future<void> _openHelp(BuildContext context) async {
    await FxSheet.show<void>(
      context,
      title: '帮助',
      child: const Padding(
        padding: EdgeInsets.fromLTRB(
          FxSpacing.lg,
          0,
          FxSpacing.lg,
          FxSpacing.xl,
        ),
        child: Text(
          '好记是一款多分组、多账本的记账应用。\n\n'
          '· 在首页快速记一笔，或在账单页查看明细。\n'
          '· 通过"我的"进入分类、标签、账户、成员等管理。\n'
          '· 遇到问题可联系管理员或查看项目文档。',
          style: FxTypography.body,
        ),
      ),
    );
  }

  Future<void> _openDonate(BuildContext context) async {
    await FxSheet.show<void>(
      context,
      title: '捐赠支持',
      child: const Padding(
        padding: EdgeInsets.fromLTRB(
          FxSpacing.lg,
          0,
          FxSpacing.lg,
          FxSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_rounded, size: 48, color: FxColors.expense),
            SizedBox(height: FxSpacing.md),
            Text(
              '感谢你的支持！\n如愿意赞助开发，可通过项目主页获取捐赠方式。',
              style: FxTypography.body,
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
      title: '退出登录',
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
            const Text(
              '确定要退出当前账号吗？',
              style: FxTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FxSpacing.xl),
            FxButton.critical(
              label: '退出登录',
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
              label: '取消',
              expand: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- 复用小组件 ----------------

  Widget _sectionCard(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: FxSpacing.xs,
            bottom: FxSpacing.sm,
          ),
          child: Text(title, style: FxTypography.label),
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

  Widget _divider() => const Padding(
        padding: EdgeInsets.only(left: 64),
        child: Divider(height: 1, thickness: 0.5, color: FxColors.border),
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

/// 分组 / 账本切换 sheet：列当前分组列表 + 所选分组下账本列表。
class _SwitcherSheet extends StatefulWidget {
  final SessionCubit cubit;
  const _SwitcherSheet({required this.cubit});

  @override
  State<_SwitcherSheet> createState() => _SwitcherSheetState();
}

class _SwitcherSheetState extends State<_SwitcherSheet> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      bloc: widget.cubit,
      builder: (context, state) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
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
                const Text('分组', style: FxTypography.label),
                const SizedBox(height: FxSpacing.sm),
                ...state.groups.map((g) => _groupTile(state, g)),
                const SizedBox(height: FxSpacing.lg),
                const Text('账本', style: FxTypography.label),
                const SizedBox(height: FxSpacing.sm),
                if (state.books.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: FxSpacing.md),
                    child: Text('该分组下暂无账本',
                        style: FxTypography.caption),
                  )
                else
                  ...state.books.map((b) => _bookTile(state, b)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _groupTile(SessionState state, FortuneGroupVo group) {
    final selected = group.groupId == state.currentGroupId;
    return _selectableTile(
      icon: Icons.folder_rounded,
      label: group.groupName ?? '未命名分组',
      selected: selected,
      onTap: () => widget.cubit.switchGroup(group),
    );
  }

  Widget _bookTile(SessionState state, FortuneBookVo book) {
    final selected = book.bookId == state.currentBookId;
    return _selectableTile(
      icon: Icons.menu_book_rounded,
      label: book.bookName ?? '未命名账本',
      selected: selected,
      onTap: () {
        widget.cubit.switchBook(book);
        Navigator.of(context).pop();
      },
    );
  }

  Widget _selectableTile({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FxSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FxSpacing.md,
            vertical: FxSpacing.md,
          ),
          decoration: BoxDecoration(
            color: selected ? FxColors.primaryContainer : FxColors.surfaceMuted,
            borderRadius: FxRadius.tileBorder,
            border: Border.all(
              color: selected ? FxColors.primary : FxColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 20,
                  color: selected ? FxColors.primary : FxColors.textSecondary),
              const SizedBox(width: FxSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: FxTypography.bodyStrong.copyWith(
                    color:
                        selected ? FxColors.primary : FxColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selected)
                const Icon(Icons.check_rounded,
                    size: 18, color: FxColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
