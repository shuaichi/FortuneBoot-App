import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/profile/data/profile_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_text_field.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/util/rsa_util.dart';

/// 账号注销确认表单。
///
/// 密码经 RSA 加密后提交到服务端；成功后弹出方负责清理本地登录态。
/// [encryptPassword] 可注入，便于测试避免真实网络请求。
class AccountDeletionSheet extends StatefulWidget {
  const AccountDeletionSheet({
    super.key,
    required this.service,
    this.encryptPassword = rsaEncrypt,
  });

  final ProfileService service;
  final Future<String> Function(String password) encryptPassword;

  @override
  State<AccountDeletionSheet> createState() => _AccountDeletionSheetState();
}

class _AccountDeletionSheetState extends State<AccountDeletionSheet> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _error = S.of(context).profileDeleteAccountPasswordRequired);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final encryptedPassword = await widget.encryptPassword(password);
      await widget.service.deleteAccount(password: encryptedPassword);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on FxApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = error.message;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = S.of(context).profileDeleteAccountFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final s = S.of(context);
    return Padding(
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
          Icon(Icons.warning_amber_rounded, size: 40, color: palette.danger),
          const SizedBox(height: FxSpacing.sm),
          Text(
            s.profileDeleteAccountWarning,
            style: FxTypography.body.copyWith(color: palette.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: FxSpacing.lg),
          FxTextField(
            label: s.profileDeleteAccountPasswordLabel,
            controller: _passwordController,
            obscureText: _obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            suffixIcon: IconButton(
              tooltip: _obscurePassword
                  ? s.profileDeleteAccountShowPassword
                  : s.profileDeleteAccountHidePassword,
              onPressed: _submitting
                  ? null
                  : () => setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            onSubmitted: _submitting ? null : (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: FxSpacing.md),
            Text(
              _error!,
              style: FxTypography.caption.copyWith(color: palette.danger),
            ),
          ],
          const SizedBox(height: FxSpacing.xl),
          FxButton.critical(
            label: s.profileDeleteAccountConfirm,
            expand: true,
            loading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
          const SizedBox(height: FxSpacing.sm),
          FxButton.text(
            label: s.commonCancel,
            expand: true,
            onPressed: _submitting
                ? null
                : () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
