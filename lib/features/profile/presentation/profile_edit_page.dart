import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/profile/data/profile_models.dart';
import 'package:fortuneboot/features/profile/data/profile_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/util/rsa_util.dart';
import 'package:image_picker/image_picker.dart';

/// 编辑资料页参数：传入当前资料预填。
class ProfileEditArgs {
  final UserProfile profile;
  const ProfileEditArgs({required this.profile});
}

/// 编辑资料页（Routes.profileEdit）。
///
/// - 头像上传（image_picker → multipart avatarfile → 刷新）。
/// - 昵称/性别/电话/邮箱 → PUT profile。
/// - 改密码入口 → FxSheet（旧+新密码 RSA 加密 → PUT password）。
///
/// 保存/头像变更成功后 pop(true)，由 ProfilePage 触发用户卡刷新。
class ProfileEditPage extends StatefulWidget {
  final UserProfile profile;

  const ProfileEditPage({super.key, required this.profile});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final ProfileService _service = ProfileService();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late int _sex;
  String? _avatar;

  bool _saving = false;
  bool _uploadingAvatar = false;
  bool _dirty = false; // 任一保存成功

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nicknameCtrl = TextEditingController(text: p.nickname ?? '');
    _phoneCtrl = TextEditingController(text: p.phoneNumber ?? '');
    _emailCtrl = TextEditingController(text: p.email ?? '');
    _sex = p.sex ?? 1;
    _avatar = p.avatar;
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  int? get _userId => widget.profile.userId;

  Future<void> _pickAvatar() async {
    final userId = _userId;
    if (userId == null) {
      _toast('缺少用户信息，无法上传');
      return;
    }
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _uploadingAvatar = true);
    try {
      final url = await _service.uploadAvatar(File(picked.path));
      if (!mounted) return;
      setState(() {
        _avatar = url;
        _uploadingAvatar = false;
        _dirty = true;
      });
      _toast('头像已更新');
    } on FxApiException catch (e) {
      if (!mounted) return;
      setState(() => _uploadingAvatar = false);
      _toast(e.message);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _uploadingAvatar = false);
      _toast('上传失败：$e');
    }
  }

  Future<void> _save() async {
    final userId = _userId;
    if (userId == null) {
      _toast('缺少用户信息，无法保存');
      return;
    }
    final nickname = _nicknameCtrl.text.trim();
    if (nickname.isEmpty) {
      _toast('昵称不能为空');
      return;
    }
    setState(() => _saving = true);
    try {
      await _service.updateProfile(
        userId: userId,
        nickname: nickname,
        sex: _sex,
        phoneNumber: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _saving = false;
        _dirty = true;
      });
      _toast('资料已保存');
      Navigator.of(context).pop(true);
    } on FxApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _toast(e.message);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _toast('保存失败：$e');
    }
  }

  Future<void> _openPasswordSheet() async {
    final userId = _userId;
    if (userId == null) {
      _toast('缺少用户信息，无法修改密码');
      return;
    }
    await FxSheet.show<void>(
      context,
      title: '修改密码',
      child: _PasswordSheet(service: _service, userId: userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_dirty);
      },
      child: Scaffold(
        backgroundColor: palette.canvas,
        appBar: AppBar(
          backgroundColor: palette.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: const Text('编辑资料', style: FxTypography.title),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: palette.textPrimary),
            onPressed: () => Navigator.of(context).pop(_dirty),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(FxSpacing.lg),
          children: [
            _avatarSection(),
            const SizedBox(height: FxSpacing.lg),
            FxCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _labeledField('昵称', _nicknameCtrl, hint: '请输入昵称'),
                  const SizedBox(height: FxSpacing.lg),
                  _sexField(),
                  const SizedBox(height: FxSpacing.lg),
                  _labeledField(
                    '电话',
                    _phoneCtrl,
                    hint: '请输入手机号',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: FxSpacing.lg),
                  _labeledField(
                    '邮箱',
                    _emailCtrl,
                    hint: '请输入邮箱',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),
            const SizedBox(height: FxSpacing.lg),
            FxCard(
              padding: EdgeInsets.zero,
              child: InkWell(
                borderRadius: FxRadius.cardBorder,
                onTap: _openPasswordSheet,
                child: Padding(
                  padding: const EdgeInsets.all(FxSpacing.lg),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        color: palette.textSecondary,
                      ),
                      const SizedBox(width: FxSpacing.md),
                      const Expanded(
                        child: Text('修改密码', style: FxTypography.bodyStrong),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: palette.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: FxSpacing.xxl),
            FxButton(
              label: '保存',
              expand: true,
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarSection() {
    final palette = FxPalette.of(context);
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _uploadingAvatar ? null : _pickAvatar,
            child: Stack(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.primaryContainer,
                    image: (_avatar != null && _avatar!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(_avatar!),
                            fit: BoxFit.cover,
                            onError: (_, __) {},
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: (_avatar == null || _avatar!.isEmpty)
                      ? Icon(
                          Icons.person_rounded,
                          size: 44,
                          color: palette.primary,
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.primary,
                    ),
                    child: _uploadingAvatar
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: FxSpacing.sm),
          const Text('点击更换头像', style: FxTypography.caption),
        ],
      ),
    );
  }

  Widget _labeledField(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: FxTypography.label),
        const SizedBox(height: FxSpacing.sm),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: FxTypography.body,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  Widget _sexField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('性别', style: FxTypography.label),
        const SizedBox(height: FxSpacing.sm),
        Row(
          children: [
            _sexChip('男', 1),
            const SizedBox(width: FxSpacing.md),
            _sexChip('女', 0),
          ],
        ),
      ],
    );
  }

  Widget _sexChip(String label, int value) {
    final palette = FxPalette.of(context);
    final selected = _sex == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _sex = value),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? palette.primaryContainer : palette.surfaceMuted,
            borderRadius: FxRadius.tileBorder,
            border: Border.all(
              color: selected ? palette.primary : palette.border,
            ),
          ),
          child: Text(
            label,
            style: FxTypography.bodyStrong.copyWith(
              color: selected ? palette.primary : palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    final palette = FxPalette.of(context);
    return InputDecoration(
      hintText: hint,
      hintStyle: FxTypography.body.copyWith(color: palette.textTertiary),
      filled: true,
      fillColor: palette.surfaceMuted,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: FxSpacing.md,
        vertical: FxSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: FxRadius.tileBorder,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: FxRadius.tileBorder,
        borderSide: BorderSide(color: palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: FxRadius.tileBorder,
        borderSide: BorderSide(color: palette.primary),
      ),
    );
  }
}

/// 修改密码 sheet：旧密码 + 新密码 + 确认，均 RSA 加密后提交。
class _PasswordSheet extends StatefulWidget {
  final ProfileService service;
  final int userId;

  const _PasswordSheet({required this.service, required this.userId});

  @override
  State<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends State<_PasswordSheet> {
  final TextEditingController _oldCtrl = TextEditingController();
  final TextEditingController _newCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final oldPwd = _oldCtrl.text;
    final newPwd = _newCtrl.text;
    final confirm = _confirmCtrl.text;
    if (oldPwd.isEmpty || newPwd.isEmpty) {
      setState(() => _error = '请填写旧密码和新密码');
      return;
    }
    if (newPwd.length < 6) {
      setState(() => _error = '新密码至少 6 位');
      return;
    }
    if (newPwd != confirm) {
      setState(() => _error = '两次输入的新密码不一致');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      // 旧密码与新密码分别 RSA 加密。
      final encOld = await rsaEncrypt(oldPwd);
      final encNew = await rsaEncrypt(newPwd);
      await widget.service.updatePassword(
        userId: widget.userId,
        oldPassword: encOld,
        newPassword: encNew,
      );
      if (!mounted) return;
      // 先捕获 messenger 引用再 pop：pop 后本页 context 失效，
      // 直接 ScaffoldMessenger.of(context) 取不到，提示会丢失。
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('密码修改成功')));
    } on FxApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = '修改失败：$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field('旧密码', _oldCtrl),
          const SizedBox(height: FxSpacing.md),
          _field('新密码', _newCtrl),
          const SizedBox(height: FxSpacing.md),
          _field('确认新密码', _confirmCtrl),
          if (_error != null) ...[
            const SizedBox(height: FxSpacing.md),
            Text(
              _error!,
              style: FxTypography.caption.copyWith(color: palette.danger),
            ),
          ],
          const SizedBox(height: FxSpacing.lg),
          FxButton(
            label: '确认修改',
            expand: true,
            loading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    final palette = FxPalette.of(context);
    return TextField(
      controller: controller,
      obscureText: true,
      style: FxTypography.body,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: FxTypography.label,
        filled: true,
        fillColor: palette.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FxSpacing.md,
          vertical: FxSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: FxRadius.tileBorder,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: FxRadius.tileBorder,
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: FxRadius.tileBorder,
          borderSide: BorderSide(color: palette.primary),
        ),
      ),
    );
  }
}
