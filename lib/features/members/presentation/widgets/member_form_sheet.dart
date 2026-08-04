import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/manage_shared/manage_menu.dart';
import 'package:fortuneboot/features/members/data/member_models.dart';
import 'package:fortuneboot/features/members/data/member_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

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
  State<MemberFormSheet> createState() => _MemberFormSheetState();
}

class _MemberFormSheetState extends State<MemberFormSheet> {
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

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = '请输入成员名称');
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
        await widget.service.modify(body);
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
          const ManageFieldLabel('成员名称'),
          TextField(
            controller: _nameCtrl,
            decoration: manageInputDecoration('如：张三'),
          ),
          const SizedBox(height: FxSpacing.md),
          const ManageFieldLabel('排序（可选）'),
          TextField(
            controller: _sortCtrl,
            keyboardType: TextInputType.number,
            decoration: manageInputDecoration('数字越小越靠前'),
          ),
          const SizedBox(height: FxSpacing.md),
          const ManageFieldLabel('备注（可选）'),
          TextField(
            controller: _remarkCtrl,
            decoration: manageInputDecoration('备注'),
          ),
          const SizedBox(height: FxSpacing.md),
          ManageSwitchRow(
            label: '启用',
            value: _enable,
            onChanged: (v) => setState(() => _enable = v),
          ),
          if (_error != null) ...[
            const SizedBox(height: FxSpacing.sm),
            Text(
              _error!,
              style: FxTypography.caption.copyWith(color: FxColors.danger),
            ),
          ],
          const SizedBox(height: FxSpacing.xl),
          FxButton(
            label: widget.isEdit ? '保存修改' : '创建成员',
            expand: true,
            loading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}
