import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/group_users/data/group_users_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 邀请用户表单：输入用户名 + 选择角色（getRoleTypes 动态下拉）。
class InviteUserSheet extends StatefulWidget {
  final GroupUsersService service;
  final int groupId;

  const InviteUserSheet({
    super.key,
    required this.service,
    required this.groupId,
  });

  @override
  State<InviteUserSheet> createState() => _InviteUserSheetState();
}

class _InviteUserSheetState extends State<InviteUserSheet> {
  final TextEditingController _usernameCtrl = TextEditingController();
  List<RoleTypeOption> _roles = const [];
  int? _roleType;
  bool _loadingRoles = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await widget.service.getRoleTypes();
      if (mounted) {
        setState(() {
          _roles = roles;
          _roleType = roles.isNotEmpty ? roles.first.value : null;
          _loadingRoles = false;
        });
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _loadingRoles = false;
          _error = e is FxApiException ? e.message : e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameCtrl.text.trim();
    if (username.isEmpty) {
      setState(() => _error = '请输入用户名');
      return;
    }
    if (_roleType == null) {
      setState(() => _error = '请选择角色');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.service.inviteUser(
        groupId: widget.groupId,
        roleType: _roleType!,
        username: username,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = e is FxApiException ? e.message : e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          _label('用户名'),
          TextField(
            controller: _usernameCtrl,
            decoration: _dec(context, '输入被邀请人的用户名'),
          ),
          const SizedBox(height: FxSpacing.md),
          _label('角色'),
          if (_loadingRoles)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: FxSpacing.md),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            _roleSelector(context),
          if (_error != null) ...[
            const SizedBox(height: FxSpacing.sm),
            Text(
              _error!,
              style: FxTypography.caption.copyWith(color: palette.danger),
            ),
          ],
          const SizedBox(height: FxSpacing.xl),
          FxButton(
            label: '发送邀请',
            expand: true,
            loading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _roleSelector(BuildContext context) {
    final palette = FxPalette.of(context);
    return Wrap(
      spacing: FxSpacing.sm,
      runSpacing: FxSpacing.sm,
      children: _roles.map((r) {
        final selected = r.value == _roleType;
        return GestureDetector(
          onTap: () => setState(() => _roleType = r.value),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: FxSpacing.md,
              vertical: FxSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: selected ? palette.primaryContainer : palette.surfaceMuted,
              borderRadius: FxRadius.pillBorder,
              border: Border.all(
                color: selected ? palette.primary : palette.border,
              ),
            ),
            child: Text(
              r.label,
              style: FxTypography.label.copyWith(
                color: selected ? palette.primary : palette.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: FxSpacing.xs),
    child: Text(text, style: FxTypography.label),
  );

  InputDecoration _dec(BuildContext context, String hint) => InputDecoration(
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
