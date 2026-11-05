import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/app_lock/app_lock_cubit.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/profile/data/profile_models.dart';
import 'package:fortuneboot/features/profile/data/profile_service.dart';
import 'package:fortuneboot/features/profile/presentation/widgets/account_deletion_sheet.dart';
import 'package:fortuneboot/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_icon_tile.dart';
import 'package:fortuneboot/fx/components/fx_list_item.dart';
import 'package:fortuneboot/fx/components/fx_list_section.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_text_field.dart';
import 'package:fortuneboot/fx/layout/fx_page_scaffold.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/login/model/users.dart';
import 'package:fortuneboot/util/dio_client.dart';
import 'package:fortuneboot/util/rsa_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

/// 编辑资料页参数：传入当前资料预填。
class ProfileEditArgs {
  final UserProfile profile;

  const ProfileEditArgs({required this.profile});
}

/// 个人资料详情页。
///
/// 保留原有资料更新、头像上传与密码修改的业务契约；资料编辑通过底部
/// Sheet 完成，页面返回 true 后由 [ProfilePage] 刷新用户入口卡。
class ProfileEditPage extends StatefulWidget {
  final UserProfile profile;

  const ProfileEditPage({super.key, required this.profile});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final ProfileService _service = ProfileService();
  final ImagePicker _picker = ImagePicker();

  String? _avatar;
  File? _localAvatar;
  String? _avatarCacheToken;
  bool _uploadingAvatar = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _avatar = widget.profile.avatar;
  }

  int? get _userId => widget.profile.userId;

  String get _displayName {
    final nickname = widget.profile.nickname;
    if (nickname?.isNotEmpty == true) return nickname!;
    return widget.profile.username ?? S.of(context).profileNotLoggedIn;
  }

  void _toast(String message, {FxFeedbackTone tone = FxFeedbackTone.info}) {
    FxFeedback.show(context, message: message, tone: tone);
  }

  Future<void> _pickAvatar() async {
    final userId = _userId;
    final s = S.of(context);
    if (userId == null) {
      _toast(s.profileMissingUserInfoUpload);
      return;
    }
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    final local = File(picked.path);
    setState(() {
      _localAvatar = local;
      _uploadingAvatar = true;
    });
    try {
      final url = await _service.uploadAvatar(local);
      if (!mounted) return;
      setState(() {
        _avatar = url;
        _avatarCacheToken = DateTime.now().millisecondsSinceEpoch.toString();
        _localAvatar = null;
        _uploadingAvatar = false;
        _dirty = true;
      });
      _toast(s.profileAvatarUpdated);
    } on Object {
      if (!mounted) return;
      setState(() {
        _uploadingAvatar = false;
        // 上传失败时保留本地预览，便于用户感知已选图。
      });
      _toast(s.profileSaveFailedRetry, tone: FxFeedbackTone.error);
    }
  }

  Future<void> _openEditSheet() async {
    final userId = _userId;
    if (userId == null) {
      _toast(S.of(context).profileMissingUserInfoSave);
      return;
    }
    final changed = await FxSheet.show<bool>(
      context,
      scrollable: false,
      maxHeightFactor: FxSheet.pickerHeightFactor,
      title: S.of(context).profileEditTitle,
      child: _ProfileDetailsEditSheet(
        profile: widget.profile,
        service: _service,
        userId: userId,
      ),
    );
    if (changed != true || !mounted) return;
    setState(() => _dirty = true);
    Navigator.of(context).pop(true);
  }

  Future<void> _openPasswordSheet() async {
    final userId = _userId;
    if (userId == null) {
      _toast(S.of(context).profileMissingUserInfoPassword);
      return;
    }
    await FxSheet.show<void>(
      context,
      title: S.of(context).profileChangePassword,
      child: _PasswordSheet(service: _service, userId: userId),
    );
  }

  // ---------------- 注销账号 ----------------

  Future<void> _confirmDeleteAccount() async {
    final sessionCubit = context.read<SessionCubit>();
    final appLockCubit = context.read<AppLockCubit>();
    final navigator = Navigator.of(context, rootNavigator: true);

    final deleted = await FxSheet.show<bool>(
      context,
      title: S.of(context).profileDeleteAccount,
      scrollable: true,
      child: AccountDeletionSheet(service: _service),
    );
    if (deleted != true) return;

    // 注销成功后清理本地登录态并回到服务器配置页。
    DioClient().clearAuthHeader();
    await UserDataSingleton().clearAuth();
    sessionCubit.reset();
    appLockCubit.onSignedOut();
    await navigator.pushNamedAndRemoveUntil(
      Routes.baseUrlConfig,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.of(context).pop(_dirty);
      },
      child: FxPageScaffold(
        title: s.profileDetailsTitle,
        onBack: () => Navigator.of(context).pop(_dirty),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            FxSpacing.lg,
            FxSpacing.md,
            FxSpacing.lg,
            FxSpacing.xxxl,
          ),
          children: [
            _identityCard(context),
            const SizedBox(height: FxSpacing.xxl),
            _section(context, s.profileDetailedInformation, [
              _informationItem(
                context,
                icon: Icons.wc_rounded,
                title: s.profileSex,
                value: _sexLabel(s),
              ),
              _informationItem(
                context,
                icon: Icons.phone_iphone_rounded,
                title: s.profilePhone,
                value: _valueOrPlaceholder(widget.profile.phoneNumber, s),
              ),
              _informationItem(
                context,
                icon: Icons.mail_outline_rounded,
                title: s.profileEmail,
                value: _valueOrPlaceholder(widget.profile.email, s),
              ),
            ]),
            const SizedBox(height: FxSpacing.xxl),
            _section(context, s.profileSystemRecords, [
              _informationItem(
                context,
                icon: Icons.person_outline_rounded,
                title: s.profileUsername,
                value: _valueOrPlaceholder(widget.profile.username, s),
              ),
              _informationItem(
                context,
                icon: Icons.verified_user_outlined,
                title: s.profileRole,
                value: _valueOrPlaceholder(widget.profile.roleName, s),
              ),
              _informationItem(
                context,
                icon: Icons.language_rounded,
                title: s.profileLoginIp,
                value: _valueOrPlaceholder(widget.profile.loginIp, s),
              ),
              _informationItem(
                context,
                icon: Icons.access_time_rounded,
                title: s.profileLoginTime,
                value: _loginTimeLabel(widget.profile.loginDate, s),
              ),
              _informationItem(
                context,
                icon: Icons.note_alt_outlined,
                title: s.profileRemark,
                value: _valueOrPlaceholder(widget.profile.remark, s),
              ),
              _informationItem(
                context,
                icon: Icons.lock_outline_rounded,
                title: s.profileChangePassword,
                value: '',
                onTap: _openPasswordSheet,
              ),
              _informationItem(
                context,
                icon: Icons.delete_forever_outlined,
                destructive: true,
                title: s.profileDeleteAccount,
                value: '',
                onTap: _confirmDeleteAccount,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _identityCard(BuildContext context) {
    final palette = FxPalette.of(context);
    final s = S.of(context);
    return FxCard(
      radius: FxRadius.sheet,
      child: Row(
        children: [
          Semantics(
            button: true,
            label: s.profileEditAvatar,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _uploadingAvatar ? null : _pickAvatar,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ProfileAvatar(
                    imageUrl: _avatar,
                    localFile: _localAvatar,
                    cacheToken: _avatarCacheToken,
                    label: _displayName,
                    size: 88,
                  ),
                  if (_uploadingAvatar)
                    ColoredBox(
                      color: palette.shadow,
                      child: const SizedBox.square(
                        dimension: 88,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: FxSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  style: FxTypography.titleLarge.copyWith(
                    color: palette.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: FxSpacing.xs),
                Text(
                  _valueOrPlaceholder(widget.profile.roleName, s),
                  style: FxTypography.body.copyWith(
                    color: palette.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: s.profileEditProfile,
            onPressed: _openEditSheet,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    final palette = FxPalette.of(context);
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
            style: FxTypography.title.copyWith(color: palette.textSecondary),
          ),
        ),
        FxListSection(dividerIndent: 72, children: children),
      ],
    );
  }

  Widget _informationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
    bool destructive = false,
  }) {
    final palette = FxPalette.of(context);
    return FxListItem(
      leading: FxIconTile(
        icon: icon,
        tone: destructive ? FxIconTone.danger : FxIconTone.neutral,
        size: 44,
        iconSize: 22,
      ),
      title: title,
      subtitle: value.isEmpty ? null : value,
      subtitleStyle: FxTypography.body.copyWith(color: palette.textSecondary),
      showChevron: onTap != null,
      onTap: onTap,
    );
  }

  String _sexLabel(S s) => switch (widget.profile.sex) {
    1 => s.profileSexMale,
    0 => s.profileSexFemale,
    _ => s.profileNotSet,
  };

  String _loginTimeLabel(String? value, S s) {
    final rawValue = value?.trim();
    if (rawValue?.isEmpty ?? true) return s.profileNotSet;
    final parsed = DateTime.tryParse(rawValue!);
    if (parsed == null) return rawValue;
    return DateFormat('yyyy-MM-dd HH:mm').format(parsed.toLocal());
  }

  String _valueOrPlaceholder(String? value, S s) {
    return value?.trim().isNotEmpty == true ? value!.trim() : s.profileNotSet;
  }
}

class _ProfileDetailsEditSheet extends StatefulWidget {
  final UserProfile profile;
  final ProfileService service;
  final int userId;

  const _ProfileDetailsEditSheet({
    required this.profile,
    required this.service,
    required this.userId,
  });

  @override
  State<_ProfileDetailsEditSheet> createState() =>
      _ProfileDetailsEditSheetState();
}

class _ProfileDetailsEditSheetState extends State<_ProfileDetailsEditSheet> {
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  int? _sex;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nicknameCtrl = TextEditingController(text: widget.profile.nickname ?? '');
    _phoneCtrl = TextEditingController(text: widget.profile.phoneNumber ?? '');
    _emailCtrl = TextEditingController(text: widget.profile.email ?? '');
    _sex = widget.profile.sex;
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = S.of(context);
    final nickname = _nicknameCtrl.text.trim();
    if (nickname.isEmpty) {
      _toast(s.profileNicknameRequired);
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.service.updateProfile(
        userId: widget.userId,
        nickname: nickname,
        sex: _sex,
        phoneNumber: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      FxFeedback.success(context, message: s.profileSaved);
    } on Object {
      if (!mounted) return;
      setState(() => _saving = false);
      _toast(s.profileSaveFailedRetry, tone: FxFeedbackTone.error);
    }
  }

  void _toast(String message, {FxFeedbackTone tone = FxFeedbackTone.info}) {
    FxFeedback.show(context, message: message, tone: tone);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(
            label: S.of(context).profileNickname,
            controller: _nicknameCtrl,
            icon: Icons.badge_outlined,
            hint: S.of(context).profileNicknameHint,
            autofillHints: const [AutofillHints.nickname],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: FxSpacing.lg),
          _field(
            label: S.of(context).profilePhone,
            controller: _phoneCtrl,
            icon: Icons.phone_iphone_rounded,
            hint: S.of(context).profilePhoneHint,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumber],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: FxSpacing.lg),
          _field(
            label: S.of(context).profileEmail,
            controller: _emailCtrl,
            icon: Icons.mail_outline_rounded,
            hint: S.of(context).profileEmailHint,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: FxSpacing.xl),
          _genderSelector(),
          const SizedBox(height: FxSpacing.xxl),
          FxButton(
            label: S.of(context).commonSave,
            expand: true,
            loading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
    TextInputAction? textInputAction,
  }) {
    return FxTextField(
      label: label,
      controller: controller,
      hintText: hint,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      prefixIcon: Icon(icon),
      scrollPadding: const EdgeInsets.only(bottom: 120),
    );
  }

  Widget _genderSelector() {
    final s = S.of(context);
    final palette = FxPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.profileSex,
          style: FxTypography.bodyStrong.copyWith(color: palette.textPrimary),
        ),
        const SizedBox(height: FxSpacing.sm),
        Container(
          height: 52,
          padding: const EdgeInsets.all(FxSpacing.xs),
          decoration: BoxDecoration(
            color: palette.surfaceMuted,
            borderRadius: FxRadius.pillBorder,
          ),
          child: Row(
            children: [
              _genderOption('-', null),
              _genderOption(s.profileSexMale, 1),
              _genderOption(s.profileSexFemale, 0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _genderOption(String label, int? value) {
    final palette = FxPalette.of(context);
    final selected = _sex == value;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Material(
          color: selected ? palette.surface : Colors.transparent,
          borderRadius: FxRadius.pillBorder,
          child: InkWell(
            borderRadius: FxRadius.pillBorder,
            onTap: () => setState(() => _sex = value),
            child: Center(
              child: Text(
                label,
                style: FxTypography.bodyStrong.copyWith(
                  color: selected ? palette.textPrimary : palette.textSecondary,
                ),
              ),
            ),
          ),
        ),
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
    final s = S.of(context);
    final oldPwd = _oldCtrl.text;
    final newPwd = _newCtrl.text;
    final confirm = _confirmCtrl.text;
    if (oldPwd.isEmpty || newPwd.isEmpty) {
      setState(() => _error = s.profilePasswordFillOldNew);
      return;
    }
    if (newPwd.length < 6) {
      setState(() => _error = s.profilePasswordMinLength);
      return;
    }
    if (newPwd != confirm) {
      setState(() => _error = s.profilePasswordMismatch);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final encOld = await rsaEncrypt(oldPwd);
      final encNew = await rsaEncrypt(newPwd);
      await widget.service.updatePassword(
        userId: widget.userId,
        oldPassword: encOld,
        newPassword: encNew,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      FxFeedback.success(context, message: s.profilePasswordChanged);
    } on Object {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = s.profileSaveFailedRetry;
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
          _field(S.of(context).profileOldPassword, _oldCtrl),
          const SizedBox(height: FxSpacing.md),
          _field(S.of(context).profileNewPassword, _newCtrl),
          const SizedBox(height: FxSpacing.md),
          _field(S.of(context).profileConfirmNewPassword, _confirmCtrl),
          if (_error != null) ...[
            const SizedBox(height: FxSpacing.md),
            Text(
              _error!,
              style: FxTypography.caption.copyWith(color: palette.danger),
            ),
          ],
          const SizedBox(height: FxSpacing.lg),
          FxButton(
            label: S.of(context).profileConfirmChange,
            expand: true,
            loading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return FxTextField(
      label: label,
      controller: controller,
      obscureText: true,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.password],
      scrollPadding: const EdgeInsets.only(bottom: 160),
    );
  }
}
