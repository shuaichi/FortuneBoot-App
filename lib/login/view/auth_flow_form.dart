import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_pressable.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/login/auth/password_policy.dart';
import 'package:fortuneboot/login/view/auth_scaffold.dart';

enum _AuthFlowMode { signIn, signUp, recover }

/// 工程内认证表单，承接登录、注册与找回密码，不依赖第三方页面模板。
///
/// @author JoyCode
/// @since 2026/11/04
class AuthFlowForm extends StatefulWidget {
  /// 创建认证表单并注入既有业务请求。
  const AuthFlowForm({
    super.key,
    required this.onLogin,
    required this.onSignup,
    required this.onRecoverPassword,
    required this.onCheckUsername,
    required this.onLoginSuccess,
    required this.additionalSignupFields,
    this.onOpenTerms,
  });

  /// 登录请求，返回空表示成功。
  final Future<String?> Function(LoginData data) onLogin;

  /// 注册请求，返回空表示成功。
  final Future<String?> Function(SignupData data) onSignup;

  /// 找回密码请求，返回空表示成功。
  final Future<String?> Function(String account) onRecoverPassword;

  /// 注册前检查用户名，返回空表示可用。
  final Future<String?> Function(String account) onCheckUsername;

  /// 登录成功后的版本检查与页面跳转。
  final Future<void> Function() onLoginSuccess;

  /// 注册附加字段。
  final List<UserFormField> additionalSignupFields;

  /// 打开服务条款与隐私政策。
  final Future<void> Function()? onOpenTerms;

  @override
  State<AuthFlowForm> createState() => _AuthFlowFormState();
}

class _AuthFlowFormState extends State<AuthFlowForm> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _additionalControllers = <String, TextEditingController>{};

  _AuthFlowMode _mode = _AuthFlowMode.signIn;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _acceptedTerms = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    for (final field in widget.additionalSignupFields) {
      _additionalControllers[field.keyName] = TextEditingController(
        text: field.defaultValue,
      );
    }
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (final controller in _additionalControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _changeMode(_AuthFlowMode mode) {
    setState(() {
      _mode = mode;
      _errorMessage = null;
      _successMessage = null;
    });
  }

  Future<void> _submit() async {
    final s = S.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_mode == _AuthFlowMode.signUp && !_acceptedTerms) {
      setState(() => _errorMessage = s.service_required);
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    String? error;
    try {
      switch (_mode) {
        case _AuthFlowMode.signIn:
          error = await widget.onLogin(
            LoginData(
              name: _accountController.text.trim(),
              password: _passwordController.text,
            ),
          );
          if (error == null && mounted) {
            await widget.onLoginSuccess();
          }
        case _AuthFlowMode.signUp:
          error = await widget.onCheckUsername(_accountController.text.trim());
          if (error == null) {
            error = await widget.onSignup(
              SignupData.fromSignupForm(
                name: _accountController.text.trim(),
                password: _passwordController.text,
                additionalSignupData: {
                  for (final entry in _additionalControllers.entries)
                    entry.key: entry.value.text.trim(),
                },
              ),
            );
          }
          if (error == null && mounted) {
            _passwordController.clear();
            _confirmPasswordController.clear();
            _changeMode(_AuthFlowMode.signIn);
            setState(() => _successMessage = s.sign_up_success);
          }
        case _AuthFlowMode.recover:
          error = await widget.onRecoverPassword(
            _accountController.text.trim(),
          );
          if (error == null && mounted) {
            _changeMode(_AuthFlowMode.signIn);
            setState(() => _successMessage = s.password_rescued_successfully);
          }
      }
    } on Object {
      // 请求层未收敛的异常统一转成表单反馈，并恢复可提交状态。
      error = s.default_comment;
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = error;
        });
      }
    }
  }

  String? _validateAccount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return S.of(context).user_auth_vaild;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final s = S.of(context);
    if (value == null || value.isEmpty) {
      return s.password_is_empty;
    }
    if (!PasswordPolicy.isValid(value)) {
      return s.passwordPolicyHint;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final palette = FxPalette.of(context);
    final title = switch (_mode) {
      _AuthFlowMode.signIn => s.login_button_text,
      _AuthFlowMode.signUp => s.register,
      _AuthFlowMode.recover => s.help_me,
    };

    return AutofillGroup(
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: FxTypography.titleLarge.copyWith(
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: FxSpacing.xxl),
            TextFormField(
              controller: _accountController,
              enabled: !_loading,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              validator: _validateAccount,
              decoration: authInputDecoration(
                context,
                label: s.login_account,
                icon: Icons.person_outline_rounded,
              ),
            ),
            if (_mode != _AuthFlowMode.recover) ...[
              const SizedBox(height: FxSpacing.lg),
              TextFormField(
                controller: _passwordController,
                enabled: !_loading,
                obscureText: _obscurePassword,
                textInputAction: _mode == _AuthFlowMode.signIn
                    ? TextInputAction.done
                    : TextInputAction.next,
                autofillHints: [
                  _mode == _AuthFlowMode.signIn
                      ? AutofillHints.password
                      : AutofillHints.newPassword,
                ],
                onFieldSubmitted: (_) {
                  if (_mode == _AuthFlowMode.signIn) {
                    _submit();
                  }
                },
                validator: _validatePassword,
                decoration: authInputDecoration(
                  context,
                  label: s.login_pass,
                  icon: Icons.lock_outline_rounded,
                  suffixIcon: FxPressable(
                    semanticLabel: s.login_pass,
                    padding: EdgeInsets.zero,
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
            if (_mode == _AuthFlowMode.signUp) ...[
              const SizedBox(height: FxSpacing.lg),
              TextFormField(
                controller: _confirmPasswordController,
                enabled: !_loading,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: (value) {
                  if (value != _passwordController.text) {
                    return s.not_match;
                  }
                  return null;
                },
                decoration: authInputDecoration(
                  context,
                  label: s.login_confirm,
                  icon: Icons.lock_reset_rounded,
                ),
              ),
              for (final field in widget.additionalSignupFields) ...[
                const SizedBox(height: FxSpacing.lg),
                _buildAdditionalField(field),
              ],
              const SizedBox(height: FxSpacing.md),
              CheckboxListTile(
                value: _acceptedTerms,
                onChanged: _loading
                    ? null
                    : (value) =>
                          setState(() => _acceptedTerms = value ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: FxPressable(
                  semanticLabel: s.term_of_services,
                  onPressed: _loading ? null : widget.onOpenTerms,
                  child: Text(
                    s.term_of_services,
                    style: FxTypography.label.copyWith(
                      color: palette.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: FxSpacing.md),
              Semantics(
                liveRegion: true,
                child: Text(
                  _errorMessage!,
                  style: FxTypography.label.copyWith(color: palette.danger),
                ),
              ),
            ],
            if (_successMessage != null) ...[
              const SizedBox(height: FxSpacing.md),
              Semantics(
                liveRegion: true,
                child: Text(
                  _successMessage!,
                  style: FxTypography.label.copyWith(color: palette.success),
                ),
              ),
            ],
            const SizedBox(height: FxSpacing.xxl),
            FxButton(
              label: title,
              expand: true,
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: FxSpacing.sm),
            _buildSecondaryActions(s),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalField(UserFormField field) {
    final s = S.of(context);
    final controller = _additionalControllers[field.keyName]!;
    if (field.keyName == 'sex') {
      return DropdownButtonFormField<String>(
        initialValue: controller.text,
        decoration: authInputDecoration(
          context,
          label: field.displayName,
          icon: Icons.wc_outlined,
        ),
        items: [
          DropdownMenuItem(value: s.male, child: Text(s.male)),
          DropdownMenuItem(value: s.female, child: Text(s.female)),
        ],
        validator: field.fieldValidator,
        onChanged: _loading ? null : (value) => controller.text = value ?? '',
      );
    }
    return TextFormField(
      controller: controller,
      enabled: !_loading,
      keyboardType: switch (field.userType) {
        LoginUserType.email => TextInputType.emailAddress,
        LoginUserType.phone || LoginUserType.intlPhone => TextInputType.phone,
        _ => TextInputType.text,
      },
      textInputAction: TextInputAction.next,
      validator: field.fieldValidator,
      decoration: authInputDecoration(
        context,
        label: field.displayName,
        icon: switch (field.userType) {
          LoginUserType.email => Icons.mail_outline_rounded,
          LoginUserType.phone ||
          LoginUserType.intlPhone => Icons.phone_outlined,
          _ => Icons.badge_outlined,
        },
      ),
    );
  }

  Widget _buildSecondaryActions(S s) {
    return switch (_mode) {
      // FxButton 在宽松约束下会撑满可用宽度，这里用 IntrinsicWidth 收成内容宽度；
      // 两个操作在窄屏放不下时由 Wrap 换行，避免 RenderFlex 溢出。
      _AuthFlowMode.signIn => Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: FxSpacing.sm,
        runSpacing: FxSpacing.xs,
        children: [
          IntrinsicWidth(
            child: FxButton.text(
              label: s.forgot_huh,
              onPressed: _loading
                  ? null
                  : () => _changeMode(_AuthFlowMode.recover),
            ),
          ),
          IntrinsicWidth(
            child: FxButton.text(
              label: s.register,
              onPressed: _loading
                  ? null
                  : () => _changeMode(_AuthFlowMode.signUp),
            ),
          ),
        ],
      ),
      _AuthFlowMode.signUp || _AuthFlowMode.recover => FxButton.text(
        label: s.go_back,
        expand: true,
        onPressed: _loading ? null : () => _changeMode(_AuthFlowMode.signIn),
      ),
    };
  }
}
