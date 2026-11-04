import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/books/data/books_manage_models.dart';
import 'package:fortuneboot/features/books/data/books_service.dart';
import 'package:fortuneboot/features/books/domain/books_manage_capabilities.dart';
import 'package:fortuneboot/features/books/presentation/widgets/destructive_confirm_sheet.dart';
import 'package:fortuneboot/features/shared/invite_member_sheet.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

class GroupDetailPage extends StatefulWidget {
  const GroupDetailPage({
    super.key,
    required this.group,
    required this.service,
    required this.capabilities,
    this.currentUsername,
    this.onChanged,
    this.onManageBooks,
  });

  final ManagedGroup group;
  final BooksService service;
  final ManageCapabilities capabilities;
  final String? currentUsername;
  final VoidCallback? onChanged;
  final VoidCallback? onManageBooks;

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  bool _loading = true;
  String? _error;
  FortuneGroupVo? _detail;
  List<GroupMemberVo> _members = const [];
  List<FortuneBookVo> _books = const [];
  int? _removingRelationId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final groupId = widget.group.groupId;
    if (groupId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait<dynamic>([
        widget.service.getGroupById(groupId),
        widget.service.getGroupUsers(groupId),
        widget.service.getBookPage(groupId: groupId),
      ]);
      if (!mounted) return;
      setState(() {
        _detail = results[0] as FortuneGroupVo?;
        _members = results[1] as List<GroupMemberVo>;
        _books = (results[2] as PagedRows<FortuneBookVo>).rows.take(3).toList();
        _loading = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e is FxApiException ? e.message : e.toString();
      });
    }
  }

  Future<void> _invite() async {
    final groupId = widget.group.groupId;
    if (groupId == null) return;
    final username = await FxSheet.show<String>(
      context,
      scrollable: false,
      maxHeightFactor: FxSheet.formHeightFactor,
      title: S.of(context).booksInviteMembers,
      child: InviteMemberSheet(
        strings: InviteMemberSheetStrings(
          usernameLabel: S.of(context).booksUsername,
          usernameHint: '@zhangsan',
          roleLabel: S.of(context).booksRole,
          helpText: S.of(context).booksInviteHelp,
          submitLabel: S.of(context).booksSendInvite,
          usernameRequiredMessage: S.of(context).booksInviteInputError,
          roleRequiredMessage: S.of(context).booksInviteInputError,
        ),
        loadRoles: () async => (await widget.service.getRoleTypes())
            .map(
              (role) => InviteMemberRole(value: role.value, label: role.label),
            )
            .toList(),
        submitInvite: (username, roleType) => widget.service.inviteGroupUser(
          groupId: groupId,
          username: username,
          roleType: roleType,
        ),
        normalizeUsername: (raw) => raw.trim().replaceFirst('@', ''),
        initialRoleId: (roles) => roles.any((role) => role.value == 2)
            ? 2
            : roles.isEmpty
            ? 2
            : roles.first.value,
        confirmBeforeSubmit: (context, username) async =>
            DestructiveConfirmSheet.show(
              context,
              title: S.of(context).booksInviteConfirmTitle,
              message: S.of(context).booksInviteConfirmMessage(username),
              confirmLabel: S.of(context).booksSendInvite,
              cancelLabel: S.of(context).commonCancel,
            ),
      ),
    );
    if (username == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).booksInvitedUser(username))),
    );
    await _load();
    widget.onChanged?.call();
  }

  Future<void> _remove(GroupMemberVo member) async {
    final relationId = member.relationId;
    if (relationId == null) return;
    if (member.matchesAccount(widget.currentUsername)) {
      _toast(S.of(context).booksCannotRemoveSelf);
      return;
    }
    final owners = _members.where((m) => m.roleType == ManageRole.owner.value);
    if (member.roleType == ManageRole.owner.value && owners.length <= 1) {
      _toast(S.of(context).booksCannotRemoveOnlyOwner);
      return;
    }
    setState(() => _removingRelationId = relationId);
    try {
      await widget.service.removeGroupUser(relationId);
      if (!mounted) return;
      await _load();
      widget.onChanged?.call();
    } on Object catch (e) {
      _toast(e is FxApiException ? e.message : e.toString());
    } finally {
      if (mounted) setState(() => _removingRelationId = null);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(body: FxStateView.loading());
    if (_error != null) {
      return Scaffold(
        body: SafeArea(
          child: FxStateView.error(message: _error, onRetry: _load),
        ),
      );
    }
    final group = _detail ?? widget.group.group;
    final palette = FxPalette.of(context);
    return Scaffold(
      backgroundColor: palette.canvas,
      appBar: AppBar(
        backgroundColor: palette.canvas,
        title: Text(S.of(context).booksGroupDetailTitle),
        actions: [
          if (widget.capabilities.canEdit)
            FxIconButton(
              icon: Icons.edit_rounded,
              tooltip: S.of(context).booksEditGroup,
              onPressed: widget.onChanged,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          FxSpacing.lg,
          FxSpacing.md,
          FxSpacing.lg,
          120,
        ),
        children: [
          FxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.groupName ?? S.of(context).booksUnnamedGroup,
                  style: FxTypography.display,
                ),
                const SizedBox(height: FxSpacing.sm),
                Wrap(
                  spacing: FxSpacing.xs,
                  children: [
                    FxTagChip(label: widget.capabilities.role.label),
                    FxTagChip(label: group.defaultCurrency ?? 'CNY'),
                    if (!group.enable)
                      FxTagChip(
                        label: S.of(context).booksDisabled,
                        dotColor: palette.warning,
                      ),
                  ],
                ),
                if (group.remark?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: FxSpacing.md),
                  Text(group.remark!, style: FxTypography.body),
                ],
              ],
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          FxCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(S.of(context).booksDefaultBookTag),
              subtitle: Text(
                group.defaultBookName ?? S.of(context).commonPleaseSelect,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: widget.onManageBooks,
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          _membersSection(),
          const SizedBox(height: FxSpacing.md),
          FxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).booksBookOverview,
                  style: FxTypography.title,
                ),
                const SizedBox(height: FxSpacing.sm),
                if (_books.isEmpty)
                  Text(S.of(context).booksNoBooks, style: FxTypography.caption)
                else
                  ..._books.map(
                    (b) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(b.bookName ?? S.of(context).booksUnnamedBook),
                      subtitle: Text(b.defaultCurrency ?? 'CNY'),
                    ),
                  ),
                FxButton.tonal(
                  label: S.of(context).booksManageAllBooksInTab,
                  expand: true,
                  onPressed: widget.onManageBooks,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _membersSection() {
    final palette = FxPalette.of(context);
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  S.of(context).booksMembersCount(_members.length),
                  style: FxTypography.title,
                ),
              ),
              if (widget.capabilities.canInvite)
                TextButton.icon(
                  onPressed: _invite,
                  icon: const Icon(Icons.person_add_alt_rounded),
                  label: Text(S.of(context).booksInvite),
                ),
            ],
          ),
          Text(
            S.of(context).booksAdjustRoleHint,
            style: FxTypography.caption.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: FxSpacing.sm),
          ..._members.map((member) {
            final removing =
                member.relationId != null &&
                _removingRelationId == member.relationId;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(member.displayName),
              subtitle: Text(
                member.roleTypeDesc ?? S.of(context).booksUnknownRole,
              ),
              trailing: widget.capabilities.canRemoveMember
                  ? removing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            onPressed: member.relationId == null
                                ? null
                                : () => _remove(member),
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                            ),
                          )
                  : null,
            );
          }),
        ],
      ),
    );
  }
}
