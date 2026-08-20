import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/group_users/data/group_users_service.dart';
import 'package:fortuneboot/features/group_users/presentation/bloc/group_users_bloc.dart';
import 'package:fortuneboot/features/group_users/presentation/widgets/invite_user_sheet.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_confirm_sheet.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 分组协作成员管理页（Routes.groupUsers）。
///
/// 成员列表 + 邀请（仅 owner）+ 移除（仅 owner）。owner 判定为前端软约束，
/// 依据当前用户在该组的 roleTypeDesc；后端 SpEL 兜底真正鉴权。
class GroupUsersPage extends StatefulWidget {
  const GroupUsersPage({super.key});

  @override
  State<GroupUsersPage> createState() => _GroupUsersPageState();
}

class _GroupUsersPageState extends State<GroupUsersPage> {
  final GroupUsersService _service = GroupUsersService();

  GroupUsersBloc get _bloc => context.read<GroupUsersBloc>();

  int? get _groupId => context.read<SessionCubit>().state.currentGroupId;

  /// 前端软约束：当前用户在该组是否为所有者。
  /// FortuneGroupVo 只返回 roleTypeDesc（无 int），故与 getRoleTypes 中 owner 的
  /// 描述文案精确比较，而非猜测中/英文子串。枚举未就绪时回退为 false（隐藏专属操作），
  /// 后端 SpEL 兜底真正鉴权。
  bool _currentUserIsOwner(GroupUsersState state, int? currentGroupId) {
    final ownerDesc = state.ownerRoleDesc;
    if (ownerDesc == null || state.groupId != currentGroupId) return false;
    final desc = context.read<SessionCubit>().state.currentGroup?.roleTypeDesc;
    return desc != null && desc == ownerDesc;
  }

  /// 成员是否为 owner：成员项带 roleType int，用 owner 的 int 精确比较。
  bool _memberIsOwner(GroupUserVo user, GroupUsersState state) {
    final ownerType = state.ownerRoleType;
    return ownerType != null && user.roleType == ownerType;
  }

  void _showToast(String message) {
    FxFeedback.info(context, message: message);
  }

  Future<void> _invite() async {
    final groupId = _groupId;
    if (groupId == null) {
      _showToast(S.of(context).groupUsersSelectGroupFirst);
      return;
    }
    final ok = await FxSheet.show<bool>(
      context,
      title: S.of(context).groupUsersInviteTitle,
      child: InviteUserSheet(service: _service, groupId: groupId),
    );
    if (ok == true && mounted && _groupId == groupId) {
      _bloc.add(const GroupUsersMutated());
      _showToast(S.of(context).groupUsersInviteSent);
    }
  }

  Future<void> _remove(GroupUserVo user) async {
    final relationId = user.userGroupRelationId;
    final groupId = _groupId;
    if (relationId == null || groupId == null) return;
    final ok = await FxConfirmSheet.show(
      context,
      title: S.of(context).groupUsersRemoveTitle,
      message: S.of(context).groupUsersRemoveConfirm(user.displayName),
      confirmLabel: S.of(context).groupUsersRemove,
      cancelLabel: S.of(context).commonCancel,
      destructive: true,
      failureMessage: S.of(context).profileSaveFailedRetry,
      onConfirm: () async {
        await _service.removeGroupUser(relationId);
        return true;
      },
    );
    if (ok == true && mounted && _groupId == groupId) {
      _bloc.add(const GroupUsersMutated());
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupId = context.select<SessionCubit, int?>(
      (c) => c.state.currentGroupId,
    );
    return _GroupSync(
      groupId: groupId,
      child: Scaffold(
        backgroundColor: FxPalette.of(context).canvas,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<GroupUsersBloc, GroupUsersState>(
            builder: (context, state) {
              final isOwner = _currentUserIsOwner(state, groupId);
              return Column(
                children: [
                  _buildHeader(context, isOwner),
                  Expanded(child: _buildBody(state, isOwner)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isOwner) {
    final groupName = context
        .read<SessionCubit>()
        .state
        .currentGroup
        ?.groupName;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.sm,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: Row(
        children: [
          FxIconButton(
            icon: Icons.chevron_left_rounded,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(
              groupName == null
                  ? S.of(context).groupUsersTitle
                  : S.of(context).groupUsersTitleWithName(groupName),
              style: FxTypography.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isOwner)
            FxButton.text(
              label: S.of(context).groupUsersInvite,
              icon: Icons.person_add_alt_1_rounded,
              onPressed: _invite,
            ),
        ],
      ),
    );
  }

  Widget _buildBody(GroupUsersState state, bool isOwner) {
    if (_groupId == null || state.groupId != _groupId) {
      return FxStateView.empty(
        message: S.of(context).groupUsersSelectGroupFirst,
      );
    }
    switch (state.status) {
      case GroupUsersStatus.initial:
      case GroupUsersStatus.loading:
        return FxStateView.loading();
      case GroupUsersStatus.error:
        return FxStateView.error(
          message: state.errorMessage,
          retryLabel: S.of(context).commonRetry,
          onRetry: () => _bloc.add(const GroupUsersLoaded()),
        );
      case GroupUsersStatus.empty:
        return FxStateView.empty(
          message: S.of(context).groupUsersEmpty,
          icon: Icons.group_outlined,
        );
      case GroupUsersStatus.loaded:
        return RefreshIndicator(
          onRefresh: () async => _bloc.add(const GroupUsersLoaded()),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg,
              FxSpacing.sm,
              FxSpacing.lg,
              FxSpacing.xxxl,
            ),
            itemCount: state.users.length,
            itemBuilder: (context, i) =>
                _userTile(context, state.users[i], state, isOwner),
          ),
        );
    }
  }

  Widget _userTile(
    BuildContext context,
    GroupUserVo user,
    GroupUsersState state,
    bool owner,
  ) {
    final palette = FxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: FxSpacing.md),
      child: FxCard(
        child: Row(
          children: [
            _avatar(context, user.displayName),
            const SizedBox(width: FxSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: FxTypography.bodyStrong,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.username != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username}',
                      style: FxTypography.caption.copyWith(
                        color: palette.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (user.roleTypeDesc != null)
              _rolePill(
                context,
                user.roleTypeDesc!,
                _memberIsOwner(user, state),
              ),
            // 移除按钮仅 owner 可见，且不允许移除其它 owner。
            if (owner && !_memberIsOwner(user, state)) ...[
              const SizedBox(width: FxSpacing.xs),
              FxIconButton(
                icon: Icons.person_remove_alt_1_rounded,
                tooltip: S.of(context).groupUsersRemove,
                color: palette.danger,
                onPressed: () => _remove(user),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _rolePill(BuildContext context, String desc, bool isOwner) {
    final palette = FxPalette.of(context);
    final c = isOwner ? palette.primary : palette.info;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FxSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: FxRadius.pillBorder,
      ),
      child: Text(desc, style: FxTypography.caption.copyWith(color: c)),
    );
  }

  Widget _avatar(BuildContext context, String name) {
    final palette = FxPalette.of(context);
    final initial = name.isNotEmpty ? name.characters.first : '?';
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: FxTypography.bodyStrong.copyWith(color: palette.primary),
      ),
    );
  }
}

class _GroupSync extends StatefulWidget {
  final int? groupId;
  final Widget child;

  const _GroupSync({required this.groupId, required this.child});

  @override
  State<_GroupSync> createState() => _GroupSyncState();
}

class _GroupSyncState extends State<_GroupSync> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GroupUsersBloc>().add(
        GroupUsersGroupChanged(widget.groupId),
      );
    });
  }

  @override
  void didUpdateWidget(_GroupSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupId != widget.groupId) {
      context.read<GroupUsersBloc>().add(
        GroupUsersGroupChanged(widget.groupId),
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
