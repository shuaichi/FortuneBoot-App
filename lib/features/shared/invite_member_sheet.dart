import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_chip.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

class InviteMemberRole {
  const InviteMemberRole({required this.value, required this.label});

  final int value;
  final String label;
}

class InviteMemberSheetStrings {
  const InviteMemberSheetStrings({
    required this.usernameLabel,
    required this.usernameHint,
    required this.roleLabel,
    required this.helpText,
    required this.submitLabel,
    required this.usernameRequiredMessage,
    required this.roleRequiredMessage,
  });

  final String usernameLabel;
  final String usernameHint;
  final String roleLabel;
  final String helpText;
  final String submitLabel;
  final String usernameRequiredMessage;
  final String roleRequiredMessage;
}

/// 可由不同业务注入文案和提交策略的邀请成员表单。
class InviteMemberSheet extends StatefulWidget {
  const InviteMemberSheet({
    super.key,
    required this.strings,
    required this.loadRoles,
    required this.submitInvite,
    required this.normalizeUsername,
    required this.initialRoleId,
    this.confirmBeforeSubmit,
  });

  final InviteMemberSheetStrings strings;
  final Future<List<InviteMemberRole>> Function() loadRoles;
  final Future<void> Function(String username, int roleType) submitInvite;
  final String Function(String rawUsername) normalizeUsername;
  final int? Function(List<InviteMemberRole> roles) initialRoleId;
  final Future<bool> Function(BuildContext context, String username)?
  confirmBeforeSubmit;

  @override
  State<InviteMemberSheet> createState() => _InviteMemberSheetState();
}

class _InviteMemberSheetState extends State<InviteMemberSheet> {
  final _usernameController = TextEditingController();
  List<InviteMemberRole> _roles = const [];
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
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadRoles() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final roles = await widget.loadRoles();
      if (!mounted) return;
      setState(() {
        _roles = roles;
        _roleType = widget.initialRoleId(roles);
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error is FxApiException ? error.message : error.toString();
      });
    }
  }

  Future<void> _submit() async {
    final username = widget.normalizeUsername(_usernameController.text);
    final roleType = _roleType;
    if (username.isEmpty) {
      setState(() => _error = widget.strings.usernameRequiredMessage);
      return;
    }
    if (roleType == null) {
      setState(() => _error = widget.strings.roleRequiredMessage);
      return;
    }
    final confirmed =
        await widget.confirmBeforeSubmit?.call(context, username) ?? true;
    if (!confirmed || !mounted) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.submitInvite(username, roleType);
      if (mounted) Navigator.of(context).pop(username);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = error is FxApiException ? error.message : error.toString();
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
          _label(context, widget.strings.usernameLabel),
          TextField(
            controller: _usernameController,
            enabled: !_submitting,
            decoration: _decoration(context, widget.strings.usernameHint),
          ),
          const SizedBox(height: FxSpacing.md),
          _label(context, widget.strings.roleLabel),
          Wrap(
            spacing: FxSpacing.sm,
            runSpacing: FxSpacing.sm,
            children: _roles
                .map(
                  (role) => FxChip(
                    label: role.label,
                    selected: role.value == _roleType,
                    enabled: !_submitting,
                    onTap: () => setState(() => _roleType = role.value),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: FxSpacing.md),
          Text(
            widget.strings.helpText,
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
            label: widget.strings.submitLabel,
            loading: _submitting,
            expand: true,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: FxSpacing.xs),
    child: Text(
      text,
      style: FxTypography.label.copyWith(
        color: FxPalette.of(context).textSecondary,
      ),
    ),
  );

  InputDecoration _decoration(BuildContext context, String hint) =>
      InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: FxPalette.of(context).surfaceMuted,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FxSpacing.md,
          vertical: FxSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: FxRadius.tileBorder,
          borderSide: BorderSide.none,
        ),
      );
}
