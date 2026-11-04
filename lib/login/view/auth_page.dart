import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/login/auth/password_policy.dart';

/// 认证页的本地化文案。
///
/// 认证页专用文案层，与 flutter_login 时代的旧模板刻意分离；
/// 后续迁入 ARB 时保持这些字段的语义即可。
@immutable
class AuthCopy {
  /// 产品名。
  final String brand;

  /// 品牌标记中的单字。
  final String brandMark;

  /// 登录标题。
  final String signInTitle;

  /// 注册标题。
  final String signUpTitle;

  /// 找回密码标题。
  final String recoverTitle;

  /// 找回密码说明。
  final String recoverSubtitle;

  /// 用户取消验证码/登录时的提示。
  final String signInCancelled;

  /// 账号字段标签。
  final String accountLabel;

  /// 密码字段标签。
  final String passwordLabel;

  /// 确认密码字段标签。
  final String confirmLabel;

  /// 显示密码提示。
  final String showPassword;

  /// 隐藏密码提示。
  final String hidePassword;

  /// 忘记密码操作。
  final String forgotPassword;

  /// 登录主操作。
  final String signInAction;

  /// 注册主操作。
  final String signUpAction;

  /// 重置密码主操作。
  final String recoverAction;

  /// 登录中状态。
  final String loadingSignIn;

  /// 注册中状态。
  final String loadingSignUp;

  /// 重置中状态。
  final String loadingRecover;

  /// 没有账号提示。
  final String noAccount;

  /// 创建账号操作。
  final String createAccount;

  /// 已有账号提示。
  final String haveAccount;

  /// 返回登录操作。
  final String backToSignIn;

  /// 同意条款前缀。
  final String agreePrefix;

  /// 服务条款名称。
  final String terms;

  /// 查看条款操作。
  final String view;

  /// 未同意条款提示。
  final String termsRequired;

  /// 两次密码不一致提示。
  final String confirmMismatch;

  /// 账号为空提示。
  final String accountRequired;

  /// 密码为空提示。
  final String passwordRequired;

  /// 密码规则提示。
  final String passwordPolicy;

  /// 注册时的密码规则辅助说明。
  final String passwordHelper;

  /// 通用失败提示。
  final String genericError;

  /// 注册成功提示。
  final String signUpSuccess;

  /// 重置成功提示。
  final String recoverSuccess;

  /// 男性选项。
  final String male;

  /// 女性选项。
  final String female;

  /// 选择提示。
  final String select;

  /// 切换服务器操作。
  final String changeServer;

  /// 创建一套文案。
  const AuthCopy({
    required this.brand,
    required this.brandMark,
    required this.signInTitle,
    required this.signUpTitle,
    required this.recoverTitle,
    required this.recoverSubtitle,
    required this.signInCancelled,
    required this.accountLabel,
    required this.passwordLabel,
    required this.confirmLabel,
    required this.showPassword,
    required this.hidePassword,
    required this.forgotPassword,
    required this.signInAction,
    required this.signUpAction,
    required this.recoverAction,
    required this.loadingSignIn,
    required this.loadingSignUp,
    required this.loadingRecover,
    required this.noAccount,
    required this.createAccount,
    required this.haveAccount,
    required this.backToSignIn,
    required this.agreePrefix,
    required this.terms,
    required this.view,
    required this.termsRequired,
    required this.confirmMismatch,
    required this.accountRequired,
    required this.passwordRequired,
    required this.passwordPolicy,
    required this.passwordHelper,
    required this.genericError,
    required this.signUpSuccess,
    required this.recoverSuccess,
    required this.male,
    required this.female,
    required this.select,
    required this.changeServer,
  });

  /// 中文文案。
  static const AuthCopy zh = AuthCopy(
    brand: '好记',
    brandMark: '记',
    signInTitle: '登录',
    signUpTitle: '创建账户',
    recoverTitle: '重设密码',
    recoverSubtitle: '输入账号以重设密码。',
    signInCancelled: '登录已取消',
    accountLabel: '账号',
    passwordLabel: '密码',
    confirmLabel: '确认密码',
    showPassword: '显示密码',
    hidePassword: '隐藏密码',
    forgotPassword: '忘记密码',
    signInAction: '登录',
    signUpAction: '创建账户',
    recoverAction: '重设密码',
    loadingSignIn: '正在登录…',
    loadingSignUp: '正在创建…',
    loadingRecover: '正在重设…',
    noAccount: '还没有账号？',
    createAccount: '创建账户',
    haveAccount: '已有账号？',
    backToSignIn: '返回登录',
    agreePrefix: '我已阅读并同意',
    terms: '服务条款',
    view: '查看',
    termsRequired: '请先阅读并同意服务条款',
    confirmMismatch: '两次输入的密码不一致',
    accountRequired: '请输入账号',
    passwordRequired: '请输入密码',
    passwordPolicy: '密码需为 8–18 位，包含字母、数字或符号，且不能包含中文',
    passwordHelper: '8–18 位，包含字母、数字或符号',
    genericError: '操作失败，请稍后重试',
    signUpSuccess: '账户已创建，请登录',
    recoverSuccess: '密码已重设，请使用新密码登录',
    male: '男',
    female: '女',
    select: '请选择',
    changeServer: '切换',
  );

  /// 英文文案。
  static const AuthCopy en = AuthCopy(
    brand: 'FortuneBoot',
    brandMark: 'F',
    signInTitle: 'Sign in',
    signUpTitle: 'Create account',
    recoverTitle: 'Reset password',
    recoverSubtitle: 'Enter your account to reset your password.',
    signInCancelled: 'Sign-in cancelled',
    accountLabel: 'Account',
    passwordLabel: 'Password',
    confirmLabel: 'Confirm password',
    showPassword: 'Show password',
    hidePassword: 'Hide password',
    forgotPassword: 'Forgot password?',
    signInAction: 'Sign in',
    signUpAction: 'Create account',
    recoverAction: 'Reset password',
    loadingSignIn: 'Signing in…',
    loadingSignUp: 'Creating…',
    loadingRecover: 'Resetting…',
    noAccount: 'New here?',
    createAccount: 'Create account',
    haveAccount: 'Already have an account?',
    backToSignIn: 'Back to sign in',
    agreePrefix: 'I agree to the ',
    terms: 'Terms of Service',
    view: 'View',
    termsRequired: 'Please agree to the Terms of Service.',
    confirmMismatch: 'Passwords do not match.',
    accountRequired: 'Enter your account.',
    passwordRequired: 'Enter your password.',
    passwordPolicy:
        'Use 8–18 characters with letters, numbers, or symbols; Chinese characters are not allowed.',
    passwordHelper: '8–18 characters, letters with numbers or symbols',
    genericError: 'Something went wrong. Please try again.',
    signUpSuccess: 'Account created. Sign in to continue.',
    recoverSuccess: 'Password reset. Sign in with your new password.',
    male: 'Male',
    female: 'Female',
    select: 'Select',
    changeServer: 'Change',
  );

  /// 按当前语言选择文案。
  static AuthCopy of(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'zh' ? zh : en;
  }
}

/// 认证页：登录、注册、找回密码共用一条居中的窄列。
///
/// 与原实现相比，这里把品牌、任务标题、表单和服务器信息分层，
/// 并让不同模式的校验、焦点和滚动状态互不污染。
class AuthPage extends StatefulWidget {
  /// 创建认证页。
  const AuthPage({
    super.key,
    required this.copy,
    required this.additionalSignupFields,
    required this.onLogin,
    required this.onSignup,
    required this.onCheckUsername,
    required this.onLoginSuccess,
    this.onRecoverPassword,
    this.onOpenTerms,
    this.onChangeServer,
    this.serverLabel,
  });

  /// 页面文案。
  final AuthCopy copy;

  /// 登录请求，返回空表示成功。
  final Future<String?> Function(LoginData data) onLogin;

  /// 注册请求，返回空表示成功。
  final Future<String?> Function(SignupData data) onSignup;

  /// 找回密码请求，返回空表示成功；为空时隐藏入口。
  final Future<String?> Function(String account)? onRecoverPassword;

  /// 注册前检查用户名，返回空表示可用。
  final Future<String?> Function(String account) onCheckUsername;

  /// 登录成功后的版本检查与页面跳转。
  final Future<void> Function() onLoginSuccess;

  /// 注册附加字段。
  final List<UserFormField> additionalSignupFields;

  /// 打开服务条款与隐私政策。
  final Future<void> Function()? onOpenTerms;

  /// 切换服务器。
  final VoidCallback? onChangeServer;

  /// 当前服务器地址；为空时不展示。
  final String? serverLabel;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

enum _AuthMode { signIn, signUp, recover }

class _AuthPageState extends State<AuthPage> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _additionalControllers = <String, TextEditingController>{};
  final _scrollController = ScrollController();
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  final _recoverFormKey = GlobalKey<FormState>();

  _AuthMode _mode = _AuthMode.signIn;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _acceptedTerms = false;
  bool _submitted = false;
  String? _errorMessage;
  String? _successMessage;
  String? _termsError;

  @override
  void initState() {
    super.initState();
    _syncAdditionalControllers();
  }

  @override
  void didUpdateWidget(covariant AuthPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAdditionalControllers();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (final controller in _additionalControllers.values) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _syncAdditionalControllers() {
    for (final field in widget.additionalSignupFields) {
      _additionalControllers.putIfAbsent(
        field.keyName,
        () => TextEditingController(text: field.defaultValue),
      );
    }
  }

  GlobalKey<FormState> _formKeyFor(_AuthMode mode) {
    return switch (mode) {
      _AuthMode.signIn => _signInFormKey,
      _AuthMode.signUp => _signUpFormKey,
      _AuthMode.recover => _recoverFormKey,
    };
  }

  String _titleFor(_AuthMode mode) {
    return switch (mode) {
      _AuthMode.signIn => widget.copy.signInTitle,
      _AuthMode.signUp => widget.copy.signUpTitle,
      _AuthMode.recover => widget.copy.recoverTitle,
    };
  }

  String _actionFor(_AuthMode mode) {
    return switch (mode) {
      _AuthMode.signIn => widget.copy.signInAction,
      _AuthMode.signUp => widget.copy.signUpAction,
      _AuthMode.recover => widget.copy.recoverAction,
    };
  }

  String _loadingLabelFor(_AuthMode mode) {
    return switch (mode) {
      _AuthMode.signIn => widget.copy.loadingSignIn,
      _AuthMode.signUp => widget.copy.loadingSignUp,
      _AuthMode.recover => widget.copy.loadingRecover,
    };
  }

  void _changeMode(_AuthMode mode) {
    if (_mode == mode) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _mode = mode;
      _submitted = false;
      _errorMessage = null;
      _successMessage = null;
      _termsError = null;
      if (mode != _AuthMode.signUp) {
        _confirmPasswordController.clear();
      }
    });
    _scrollToTop();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      unawaited(
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        ),
      );
    });
  }

  Future<void> _submit() async {
    if (_loading) {
      return;
    }
    final copy = widget.copy;
    final form = _formKeyFor(_mode).currentState;
    setState(() {
      _submitted = true;
      _termsError = null;
    });
    if (form == null || !form.validate()) {
      return;
    }
    if (_mode == _AuthMode.signUp && !_acceptedTerms) {
      setState(() => _termsError = copy.termsRequired);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    String? error;
    try {
      switch (_mode) {
        case _AuthMode.signIn:
          error = await widget.onLogin(
            LoginData(
              name: _accountController.text.trim(),
              password: _passwordController.text,
            ),
          );
          if (error == null && mounted) {
            TextInput.finishAutofillContext();
            await widget.onLoginSuccess();
          }
        case _AuthMode.signUp:
          error = await widget.onCheckUsername(_accountController.text.trim());
          error ??= await widget.onSignup(
            SignupData.fromSignupForm(
              name: _accountController.text.trim(),
              password: _passwordController.text,
              additionalSignupData: {
                for (final entry in _additionalControllers.entries)
                  entry.key: entry.value.text.trim(),
              },
            ),
          );
          if (error == null && mounted) {
            TextInput.finishAutofillContext();
            _passwordController.clear();
            _confirmPasswordController.clear();
            _changeMode(_AuthMode.signIn);
            setState(() => _successMessage = copy.signUpSuccess);
          }
        case _AuthMode.recover:
          final recoverPassword = widget.onRecoverPassword;
          if (recoverPassword == null) {
            return;
          }
          error = await recoverPassword(_accountController.text.trim());
          if (error == null && mounted) {
            _passwordController.clear();
            _changeMode(_AuthMode.signIn);
            setState(() => _successMessage = copy.recoverSuccess);
          }
      }
    } on Object {
      error = copy.genericError;
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
      return widget.copy.accountRequired;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return widget.copy.passwordRequired;
    }
    // 登录只检查非空：旧密码可能早于当前注册策略，不能在客户端先判死。
    if (_mode == _AuthMode.signUp && !PasswordPolicy.isValid(value)) {
      return widget.copy.passwordPolicy;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return widget.copy.passwordRequired;
    }
    if (value != _passwordController.text) {
      return widget.copy.confirmMismatch;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      backgroundColor: palette.surface,
      body: SafeArea(
        bottom: !keyboardVisible,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight - 48;
            return SingleChildScrollView(
              key: const ValueKey('auth-scroll'),
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: availableHeight > 0 ? availableHeight : 0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(child: _buildBrand(palette)),
                        const SizedBox(height: 40),
                        _buildHeader(palette),
                        const SizedBox(height: 28),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: KeyedSubtree(
                              key: ValueKey(_mode),
                              child: _buildForm(palette),
                            ),
                          ),
                        ),
                        if (widget.serverLabel case final serverLabel?
                            when serverLabel.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          _buildServerFooter(palette, serverLabel),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrand(FxPalette palette) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: widget.copy.brand,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.copy.brandMark,
                style: textTheme.labelLarge?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: palette.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Text(
              widget.copy.brand,
              style: textTheme.labelLarge?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
                color: palette.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(FxPalette palette) {
    final textTheme = Theme.of(context).textTheme;
    final subtitle = _mode == _AuthMode.recover
        ? widget.copy.recoverSubtitle
        : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Semantics(
            key: ValueKey('auth-title-$_mode'),
            header: true,
            child: Text(
              _titleFor(_mode),
              style: textTheme.headlineSmall?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: -0.3,
                color: palette.textPrimary,
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.topLeft,
          child: subtitle.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildForm(FxPalette palette) {
    final copy = widget.copy;
    return Form(
      key: _formKeyFor(_mode),
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              label: copy.accountLabel,
              controller: _accountController,
              validator: _validateAccount,
              autofillHints: const [AutofillHints.username],
            ),
            if (_mode != _AuthMode.recover) ...[
              const SizedBox(height: 16),
              _buildPasswordField(palette),
              if (_mode == _AuthMode.signIn &&
                  widget.onRecoverPassword != null) ...[
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _loading
                        ? null
                        : () => _changeMode(_AuthMode.recover),
                    style: TextButton.styleFrom(
                      foregroundColor: palette.textSecondary,
                      minimumSize: const Size(44, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      textStyle: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    child: Text(copy.forgotPassword),
                  ),
                ),
              ],
            ],
            if (_mode == _AuthMode.signUp) ...[
              const SizedBox(height: 16),
              _buildTextField(
                label: copy.confirmLabel,
                controller: _confirmPasswordController,
                validator: _validateConfirmPassword,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
              ),
              for (final field in widget.additionalSignupFields) ...[
                const SizedBox(height: 16),
                _buildAdditionalField(field),
              ],
              const SizedBox(height: 20),
              _ConsentRow(
                value: _acceptedTerms,
                copy: copy,
                enabled: !_loading,
                errorText: _termsError,
                onChanged: (value) {
                  setState(() {
                    _acceptedTerms = value;
                    _termsError = null;
                  });
                },
                onOpenTerms: widget.onOpenTerms == null
                    ? null
                    : () => unawaited(widget.onOpenTerms!()),
              ),
            ],
            if (_errorMessage case final message?) ...[
              const SizedBox(height: 16),
              _StatusBanner(message: message, success: false),
            ],
            if (_successMessage case final message?) ...[
              const SizedBox(height: 16),
              _StatusBanner(message: message, success: true),
            ],
            const SizedBox(height: 20),
            _buildPrimaryButton(palette),
            const SizedBox(height: 12),
            _buildFooter(palette),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(FxPalette palette) {
    final copy = widget.copy;
    final isSignIn = _mode == _AuthMode.signIn;
    return _buildTextField(
      label: copy.passwordLabel,
      controller: _passwordController,
      validator: _validatePassword,
      obscureText: _obscurePassword,
      autofillHints: [
        if (isSignIn) AutofillHints.password else AutofillHints.newPassword,
      ],
      textInputAction: isSignIn ? TextInputAction.done : TextInputAction.next,
      helperText: _mode == _AuthMode.signUp ? copy.passwordHelper : null,
      onSubmitted: isSignIn ? () => unawaited(_submit()) : null,
      suffixIcon: IconButton(
        tooltip: _obscurePassword ? copy.showPassword : copy.hidePassword,
        onPressed: _loading
            ? null
            : () => setState(() => _obscurePassword = !_obscurePassword),
        iconSize: 20,
        color: palette.textSecondary,
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
      ),
    );
  }

  Widget _buildAdditionalField(UserFormField field) {
    if (field.keyName == 'sex') {
      return _buildSexField(field);
    }
    final keyboardType = switch (field.userType) {
      LoginUserType.email => TextInputType.emailAddress,
      LoginUserType.phone || LoginUserType.intlPhone => TextInputType.phone,
      _ => TextInputType.text,
    };
    final autofillHints = switch (field.userType) {
      LoginUserType.email => const [AutofillHints.email],
      LoginUserType.phone ||
      LoginUserType.intlPhone => const [AutofillHints.telephoneNumber],
      _ => null,
    };
    return _buildTextField(
      label: field.displayName,
      controller: _additionalControllers[field.keyName]!,
      validator: field.fieldValidator,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
    );
  }

  Widget _buildSexField(UserFormField field) {
    final palette = FxPalette.of(context);
    final copy = widget.copy;
    final controller = _additionalControllers[field.keyName]!;
    final options = [copy.male, copy.female];
    final current = options.contains(controller.text) ? controller.text : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.displayName,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: palette.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: current,
          isExpanded: true,
          hint: Text(
            copy.select,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 15,
              color: palette.textSecondary,
            ),
          ),
          decoration: _inputDecoration(context),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            color: palette.textPrimary,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: palette.textSecondary,
          ),
          borderRadius: BorderRadius.circular(10),
          items: [
            for (final option in options)
              DropdownMenuItem<String>(value: option, child: Text(option)),
          ],
          validator: field.fieldValidator,
          onChanged: _loading
              ? null
              : (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => controller.text = value);
                },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FormFieldValidator<String>? validator,
    String? helperText,
    VoidCallback? onSubmitted,
    TextInputAction textInputAction = TextInputAction.next,
    TextInputType? keyboardType,
    List<String>? autofillHints,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    final palette = FxPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: palette.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: !_loading,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          textInputAction: textInputAction,
          autocorrect: false,
          enableSuggestions: false,
          smartDashesType: SmartDashesType.disabled,
          smartQuotesType: SmartQuotesType.disabled,
          scrollPadding: const EdgeInsets.only(bottom: 120),
          onFieldSubmitted: onSubmitted == null ? null : (_) => onSubmitted(),
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            color: palette.textPrimary,
          ),
          cursorColor: palette.primary,
          decoration: _inputDecoration(context, helperText: helperText)
              .copyWith(
                suffixIcon: suffixIcon,
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
              ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(BuildContext context, {String? helperText}) {
    final palette = FxPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _fieldBorderColor(context)),
    );
    return InputDecoration(
      isDense: true,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
      helperText: helperText,
      helperMaxLines: 2,
      helperStyle: textTheme.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.35,
        color: palette.textSecondary,
      ),
      errorMaxLines: 3,
      errorStyle: textTheme.bodySmall?.copyWith(
        fontSize: 12.5,
        height: 1.35,
        color: _dangerInk(context),
      ),
      border: border,
      enabledBorder: border,
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: _fieldBorderColor(context).withValues(alpha: 0.55),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: palette.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _dangerInk(context)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _dangerInk(context), width: 1.5),
      ),
    );
  }

  Widget _buildPrimaryButton(FxPalette palette) {
    final theme = Theme.of(context);
    final label = _actionFor(_mode);
    final loadingLabel = _loadingLabelFor(_mode);
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _loading ? null : () => unawaited(_submit()),
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          disabledBackgroundColor: palette.primary.withValues(alpha: 0.45),
          disabledForegroundColor: palette.onPrimary,
          elevation: 0,
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: theme.textTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: _loading
              ? Row(
                  key: const ValueKey('auth-loading'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: palette.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(loadingLabel),
                  ],
                )
              : Text(label, key: ValueKey(label)),
        ),
      ),
    );
  }

  Widget _buildFooter(FxPalette palette) {
    final copy = widget.copy;
    final question = switch (_mode) {
      _AuthMode.signIn => copy.noAccount,
      _AuthMode.signUp => copy.haveAccount,
      _AuthMode.recover => null,
    };
    final action = switch (_mode) {
      _AuthMode.signIn => copy.createAccount,
      _AuthMode.signUp || _AuthMode.recover => copy.backToSignIn,
    };
    final onPressed = _loading
        ? null
        : () => _changeMode(
            _mode == _AuthMode.signIn ? _AuthMode.signUp : _AuthMode.signIn,
          );
    final actionButton = TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: palette.textPrimary,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: palette.textTertiary,
          decorationThickness: 1,
        ),
      ),
      child: Text(action),
    );
    if (question == null) {
      return Center(child: actionButton);
    }
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 2,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 13.5,
            color: palette.textSecondary,
          ),
        ),
        actionButton,
      ],
    );
  }

  Widget _buildServerFooter(FxPalette palette, String serverLabel) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              serverLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: palette.textSecondary,
              ),
            ),
          ),
          if (widget.onChangeServer != null) ...[
            const SizedBox(width: 2),
            TextButton(
              onPressed: widget.onChangeServer,
              style: TextButton.styleFrom(
                foregroundColor: palette.textSecondary,
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: Text(widget.copy.changeServer),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.message, required this.success});

  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final color = success ? _successInk(context) : _dangerInk(context);
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              success
                  ? Icons.check_circle_outline_rounded
                  : Icons.error_outline_rounded,
              size: 17,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.value,
    required this.copy,
    required this.onChanged,
    required this.onOpenTerms,
    required this.enabled,
    this.errorText,
  });

  final bool value;
  final AuthCopy copy;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onOpenTerms;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                container: true,
                checked: value,
                label: '${copy.agreePrefix}${copy.terms}',
                onTap: enabled ? () => onChanged(!value) : null,
                child: ExcludeSemantics(
                  child: InkWell(
                    onTap: enabled ? () => onChanged(!value) : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: Checkbox(
                            value: value,
                            onChanged: enabled
                                ? (next) => onChanged(next ?? false)
                                : null,
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            activeColor: palette.primary,
                            side: BorderSide(
                              color: _fieldBorderColor(context),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${copy.agreePrefix}${copy.terms}',
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 13.5,
                              height: 1.35,
                              color: palette.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: onOpenTerms,
              style: TextButton.styleFrom(
                foregroundColor: palette.textSecondary,
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: Text(copy.view),
            ),
          ],
        ),
        if (errorText case final message?)
          Padding(
            padding: const EdgeInsets.only(left: 52, top: 2),
            child: Semantics(
              liveRegion: true,
              child: Text(
                message,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12.5,
                  height: 1.35,
                  color: _dangerInk(context),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

Color _fieldBorderColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF46505F)
      : const Color(0xFFAEB7C2);
}

Color _dangerInk(BuildContext context) {
  final palette = FxPalette.of(context);
  return Theme.of(context).brightness == Brightness.dark
      ? palette.danger
      : const Color(0xFFB42318);
}

Color _successInk(BuildContext context) {
  final palette = FxPalette.of(context);
  return Theme.of(context).brightness == Brightness.dark
      ? palette.success
      : const Color(0xFF067647);
}
