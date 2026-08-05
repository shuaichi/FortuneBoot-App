import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/books/data/books_manage_models.dart';
import 'package:fortuneboot/features/books/data/books_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

class InviteMemberSheet extends StatefulWidget {
  const InviteMemberSheet({
    super.key,
    required this.service,
    required this.groupId,
  });

  final BooksService service;
  final int groupId;

  @override
  State<InviteMemberSheet> createState() => _InviteMemberSheetState();
}

class _InviteMemberSheetState extends State<InviteMemberSheet> {
  final TextEditingController _usernameCtrl = TextEditingController();
  List<RoleTypeOption> _roles = const [];
  int? _roleType;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRoles() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final roles = await widget.service.getRoleTypes();
      if (!mounted) return;
      setState(() {
        _roles = roles;
        _roleType = roles.any((r) => r.value == 2)
            ? 2
            : roles.isEmpty
            ? 2
            : roles.first.value;
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

  Future<void> _submit() async {
    final username = _usernameCtrl.text.trim().replaceFirst('@', '');
    final roleType = _roleType;
    if (username.isEmpty || roleType == null) {
      setState(() => _error = S.of(context).booksInviteInputError);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).booksInviteConfirmTitle),
        content: Text(S.of(context).booksInviteConfirmMessage(username)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(S.of(context).commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(S.of(context).booksSendInvite),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.service.inviteGroupUser(
        groupId: widget.groupId,
        username: username,
        roleType: roleType,
      );
      if (mounted) Navigator.of(context).pop(username);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e is FxApiException ? e.message : e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return FxStateView.loading();
    if (_error != null && _roles.isEmpty) {
      return FxStateView.error(message: _error, onRetry: _loadRoles);
    }
    final palette = FxPalette.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(S.of(context).booksUsername, style: FxTypography.label),
          const SizedBox(height: FxSpacing.xs),
          TextField(
            controller: _usernameCtrl,
            enabled: !_submitting,
            decoration: InputDecoration(
              hintText: '@zhangsan',
              filled: true,
              fillColor: palette.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: FxRadius.tileBorder,
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          Text(S.of(context).booksRole, style: FxTypography.label),
          const SizedBox(height: FxSpacing.xs),
          Wrap(
            spacing: FxSpacing.sm,
            runSpacing: FxSpacing.sm,
            children: _roles.map((role) {
              final selected = role.value == _roleType;
              return ChoiceChip(
                label: Text(role.label),
                selected: selected,
                onSelected: _submitting
                    ? null
                    : (_) => setState(() => _roleType = role.value),
              );
            }).toList(),
          ),
          const SizedBox(height: FxSpacing.md),
          Text(
            S.of(context).booksInviteHelp,
            style: FxTypography.caption.copyWith(color: palette.textSecondary),
          ),
          if (_error != null) ...[
            const SizedBox(height: FxSpacing.sm),
            Text(
              _error!,
              style: FxTypography.caption.copyWith(color: palette.danger),
            ),
          ],
          const SizedBox(height: FxSpacing.xl),
          FxButton(
            label: S.of(context).booksSendInvite,
            loading: _submitting,
            expand: true,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}
