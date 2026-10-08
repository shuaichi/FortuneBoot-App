import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/manage_shared/manage_menu.dart';
import 'package:fortuneboot/features/members/data/member_models.dart';
import 'package:fortuneboot/features/members/data/member_service.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 成员新增/编辑表单。字段：名称 / 排序 / 备注 / 启用。
class MemberFormSheet extends StatefulWidget {
  final MemberService service;
  final int bookId;
  final FortuneMemberVo? member;

  const MemberFormSheet({
    super.key,
    required this.service,
    required this.bookId,
    this.member,
  });

  bool get isEdit => member != null;

  @override
  State<MemberFormSheet> createState() => MemberFormSheetState();
}

class MemberFormSheetState extends State<MemberFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _sortCtrl;
  late final TextEditingController _remarkCtrl;
  late bool _enable;

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final m = widget.member;
    _nameCtrl = TextEditingController(text: m?.memberName ?? '');
    _sortCtrl = TextEditingController(text: m?.sort?.toString() ?? '');
    _remarkCtrl = TextEditingController(text: m?.remark ?? '');
    _enable = m?.enable ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sortCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  String get submitLabel => widget.isEdit
      ? S.of(context).membersSaveEdit
      : S.of(context).membersCreate;

  bool get isSubmitting => _submitting;

  Future<void> submit() {
    if (_submitting) return Future<void>.value();
    return _submit();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = S.of(context).membersNameRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final body = <String, dynamic>{
      'bookId': widget.bookId,
      'memberName': _nameCtrl.text.trim(),
      'enable': _enable,
    };
    if (widget.isEdit) body['memberId'] = widget.member!.memberId;
    final sort = int.tryParse(_sortCtrl.text.trim());
    if (sort != null) body['sort'] = sort;
    final remark = _remarkCtrl.text.trim();
    if (remark.isNotEmpty) body['remark'] = remark;

    try {
      if (widget.isEdit) {
        final member = widget.member!;
        final memberId = member.memberId;
        final enableChanged = _enable != (member.enable ?? true);
        final nameChanged =
            _nameCtrl.text.trim() != (member.memberName ?? '').trim();
        final originalSort = member.sort;
        final sortChanged = sort != originalSort &&
            !(_sortCtrl.text.trim().isEmpty && originalSort == null);
        final remarkChanged = remark != (member.remark ?? '').trim();
        final fieldsChanged = nameChanged || sortChanged || remarkChanged;

        // 名称/排序/备注走 modify；启用走专用 PATCH，避免后端重名校验误伤自身。
        if (fieldsChanged) {
          await widget.service.modify(body);
        }
        if (enableChanged && memberId != null) {
          await widget.service.toggle(
            bookId: widget.bookId,
            memberId: memberId,
            action: _enable ? 'enable' : 'disable',
          );
        }
      } else {
        await widget.service.add(body);
      }
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
          ManageFieldLabel(S.of(context).membersNameLabel),
          TextField(
            controller: _nameCtrl,
            decoration: manageInputDecoration(
              context,
              S.of(context).membersNameHint,
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          ManageFieldLabel(S.of(context).membersSortLabel),
          TextField(
            controller: _sortCtrl,
            keyboardType: TextInputType.number,
            decoration: manageInputDecoration(
              context,
              S.of(context).membersSortHint,
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          ManageFieldLabel(S.of(context).membersRemarkLabel),
          TextField(
            controller: _remarkCtrl,
            decoration: manageInputDecoration(
              context,
              S.of(context).membersRemarkHint,
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          ManageFieldLabel(S.of(context).membersEnable),
          Align(
            alignment: Alignment.centerLeft,
            child: _EnableToggleButton(
              enabled: _enable,
              onPressed: () => setState(() => _enable = !_enable),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: FxSpacing.sm),
            Text(
              _error!,
              style: FxTypography.caption.copyWith(color: palette.danger),
            ),
          ],
        ],
      ),
    );
  }
}

/// 启用状态切换按钮：点一下停用，再点一下启用。
class _EnableToggleButton extends StatelessWidget {
  const _EnableToggleButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final color = enabled ? palette.success : palette.textTertiary;
    final label = enabled
        ? S.of(context).membersStatusEnabled
        : S.of(context).membersStatusDisabled;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: FxRadius.pillBorder,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FxSpacing.md,
            vertical: FxSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: FxRadius.pillBorder,
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Text(
            label,
            style: FxTypography.body.copyWith(color: color),
          ),
        ),
      ),
    );
  }
}
