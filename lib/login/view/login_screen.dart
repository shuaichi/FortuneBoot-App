import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:fortuneboot/core/app_constants.dart';
import 'package:fortuneboot/core/auth/auth_version_checker.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/login/auth_version_source.dart';
import 'package:fortuneboot/login/model/login_model.dart';
import 'package:fortuneboot/request/login_request.dart';
import 'package:fortuneboot/core/navigation/app_nav.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/login/model/users.dart';
import 'package:fortuneboot/login/server/server_history_store.dart';
import 'package:fortuneboot/login/view/auth_page.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_icon_tile.dart';
import 'package:fortuneboot/fx/components/fx_list_item.dart';
import 'package:fortuneboot/fx/components/fx_pressable.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_text_field.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/util/base64_img.dart';
import 'package:fortuneboot/util/dio_client.dart';
import 'package:encrypt/encrypt.dart';
import '../../generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/pointycastle.dart' as PC;
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/auth';

  const LoginScreen({super.key, this.roles = const []});

  final List<Map<String, dynamic>> roles;

  String formatPublicKey(String rawBase64) {
    final header = '-----BEGIN PUBLIC KEY-----\n';
    final footer = '\n-----END PUBLIC KEY-----';
    final sb = StringBuffer(header);

    // 每64字符换行（RFC规范要求）
    for (var i = 0; i < rawBase64.length; i += 64) {
      final end = (i + 64) > rawBase64.length ? rawBase64.length : i + 64;
      sb.writeln(rawBase64.substring(i, end));
    }
    return sb.toString() + footer;
  }

  Future<String?> _loginUser(
    LoginData data, {
    required String cancelledMessage,
  }) async {
    // lxjtodo：注册：1.验证码 2.rsa加密密码 3.login
    final loginService = LoginService();
    var capImgRes = await loginService.captchaImage();
    /**
     *"data": {
     *  "isCaptchaOn": true,
     *  "captchaCodeKey": "string",
     *  "captchaCodeImg": "string"
     *}
     */
    final capDic = capImgRes.data is Map
        ? Map<String, dynamic>.from(capImgRes.data as Map)
        : <String, dynamic>{};
    final isCaptchaOn = capDic['isCaptchaOn'] == true;
    Map<String, dynamic>? userResDic;
    if (isCaptchaOn) {
      final captchaResult = await showCaptchaDialog(capDic);
      userResDic = captchaResult == null
          ? null
          : Map<String, dynamic>.from(captchaResult);
      if (userResDic == null) {
        return cancelledMessage;
      }
    }
    final rsaKey = await loginService.getRsaPublicKey();
    /**
     * "data": "string"
     */
    try {
      String userName = data.name;
      String password = data.password;
      final formattedPublicKey = formatPublicKey(rsaKey.data as String);
      var publicKey =
          RSAKeyParser().parse(formattedPublicKey) as PC.RSAPublicKey;
      final encrypter = Encrypter(RSA(publicKey: publicKey));
      final encrypted = encrypter.encrypt(password).base64;
      Login loginRequest = Login(
        userName,
        encrypted,
        userResDic?['captchaUserInput'] as String? ?? '',
        userResDic?['captchaCodeKey'] as String? ?? '',
      );
      return loginService
          .login(loginRequest)
          .then((value) {
            if (value.code == 0) {
              if (value.data is Map) {
                var responseData = Map<String, dynamic>.from(
                  value.data as Map? ?? {},
                );
                var userInfo = Map<String, dynamic>.from(
                  responseData["currentUser"] as Map? ?? {},
                );
                var token = responseData["token"] as String? ?? "";
                if (token.isEmpty) {
                  return S.current.commonSystemBusy;
                }
                var userToken = {
                  "Cookie":
                      'authorized-token=${Uri.encodeComponent(jsonEncode(responseData))}',
                  "Authorization": "Bearer $token",
                };
                DioClient().setAuthHeader(userToken);
                var user = UserDataSingleton();
                user.setMap(UserDataSingleton.userInfo, userInfo);
                user.setMap(UserDataSingleton.userToken, userToken);
                // 登录成功后记住当前服务器，供下次在 URL 配置页下拉选择。
                unawaited(ServerHistoryStore().rememberCurrentSaved());
              }
              return null;
            }
            return value.msg.isEmpty ? S.current.commonSystemBusy : value.msg;
          })
          .catchError((_) => S.current.commonSystemBusy);
    } on Object {
      return S.current.commonSystemBusy;
    }
  }

  Future<String?> _signupUserWithRole(
    SignupData data,
    Map<String, dynamic> role,
  ) async {
    final loginService = LoginService();
    String userName = data.name!;
    String nickName = data.additionalSignupData!['nickname']!;
    String email = data.additionalSignupData!['email']!;
    String phoneNumber = data.additionalSignupData!['phone_number']!;
    // 表单写入「男/女」或 '1'/'0'。
    final sexRaw = data.additionalSignupData!['sex'];
    final int sex = (sexRaw == '1' || sexRaw == S.current.male) ? 1 : 0;
    String password = data.password!;
    final ResisterLogin post = ResisterLogin(
      userName,
      nickName,
      email,
      phoneNumber,
      sex,
      "",
      password,
      0,
      role['roleId'] as int? ?? 0,
      "",
      0,
    );
    debugPrint('注册请求已构造');
    return loginService
        .loginRegister(post)
        .then((value) {
          if (value.code == 0) {
            return null;
          }
          debugPrint(value.toString());
          return value.msg;
        })
        .catchError((Object _) => S.current.registration_failed);
  }

  Future<String?> _signupUser(SignupData data) async {
    try {
      final loginService = LoginService();
      var registerRoles = await loginService.getAllowRegisterRoles();
      if (registerRoles.data is List<dynamic>) {
        final List<Map<String, dynamic>> roles =
            List<Map<String, dynamic>>.from(
              registerRoles.data as List<dynamic>,
            );
        if (roles.length == 1) {
          return _signupUserWithRole(data, roles.first);
        } else if (roles.length > 1) {
          final selected = await FxSheet.show<String>(
            appNavigatorKey.currentContext!,
            title: S.current.groupUsersRoleRequired,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final role in roles)
                  FxListItem(
                    leading: const FxIconTile(icon: Icons.badge_outlined),
                    title: role['roleName'] as String? ?? '',
                    showChevron: true,
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      final error = await _signupUserWithRole(data, role);
                      appNavigatorKey.currentState?.pop(error);
                    },
                  ),
              ],
            ),
          );
          return selected ?? S.current.commonCancel;
        } else {
          return S.current.commonSystemBusy;
        }
      }
      return S.current.commonSystemBusy;
    } on Object {
      return S.current.commonSystemBusy;
    }
  }

  String _apiVersionFailureMessage(
    BuildContext context,
    ApiVersionCheckResult check,
  ) {
    final s = S.of(context);
    return switch (check.status) {
      ApiVersionStatus.versionTooLow => s.apiVersionTooLow(
        check.actualVersion,
        AppConstants.minApiVersion,
      ),
      ApiVersionStatus.versionTooHigh => s.apiVersionTooHigh(
        check.actualVersion,
        AppConstants.maxApiVersion,
      ),
      ApiVersionStatus.endpointUnavailable => s.apiVersionEndpointUnavailable(
        AppConstants.minApiVersion,
      ),
      ApiVersionStatus.versionInvalid => s.apiVersionUnavailable,
      ApiVersionStatus.connectionFailed => s.serverConnectionFailed,
      ApiVersionStatus.compatible => '',
    };
  }

  Future<String?> _checkUsernameAvailable(String account) async {
    final response = await LoginService().checkRepeat(account);
    if (response.code == 0 && response.data is bool) {
      return response.data as bool ? S.current.account_valid : null;
    }
    return S.current.account_valid;
  }

  Future<void> _completeLogin(BuildContext context) async {
    final check = await AuthVersionChecker(
      source: LoginApiVersionSource(),
    ).check();
    if (!context.mounted) {
      return;
    }
    if (!check.isCompatible) {
      DioClient().clearAuthHeader();
      await UserDataSingleton().clearAuth();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_apiVersionFailureMessage(context, check))),
      );
      return;
    }
    context.read<SessionCubit>().reset();
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.main, (_) => false);
  }

  Future<void> _openTerms() async {
    await launchUrl(
      Uri.parse('https://privacy-policy.fortuneboot.com/privacy.html'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = AuthCopy.of(context);
    return AuthPage(
      copy: copy,
      serverLabel: _currentServerLabel(),
      additionalSignupFields: fetchUserForms(context),
      onCheckUsername: _checkUsernameAvailable,
      onLogin: (data) {
        HapticFeedback.mediumImpact();
        return _loginUser(data, cancelledMessage: copy.signInCancelled);
      },
      onSignup: (data) {
        HapticFeedback.mediumImpact();
        return _signupUser(data);
      },
      onLoginSuccess: () => _completeLogin(context),
      onOpenTerms: _openTerms,
    );
  }

  String? _currentServerLabel() {
    final raw = DioClient().dio.options.baseUrl.trim();
    if (raw.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(raw);
    if (uri == null || uri.host.isEmpty) {
      return raw;
    }
    return uri.hasPort ? '${uri.host}:${uri.port}' : uri.host;
  }

  List<UserFormField> fetchUserForms(BuildContext context) {
    final s = S.of(context);
    return [
      UserFormField(
        keyName: 'nickname',
        displayName: s.login_nickname,
        fieldValidator: (value) {
          if (value!.isEmpty) {
            return s.user_auth_vaild;
          }
          return null;
        },
      ),
      // 不设 tooltip：flutter_login 会用 Tooltip 包住输入框，部分平台会抢点击。
      UserFormField(
        keyName: 'sex',
        displayName: s.sex,
        userType: LoginUserType.text,
        defaultValue: s.male,
        fieldValidator: (value) {
          if (value != s.male && value != s.female) {
            return '${s.commonPleaseSelect}${s.sex}（${s.male}/${s.female}）';
          }
          return null;
        },
      ),
      UserFormField(
        keyName: 'email',
        displayName: s.login_email,
        userType: LoginUserType.email,
        fieldValidator: (value) {
          if (value!.isNotEmpty &&
              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return s.invalid_email;
          }
          return null;
        },
      ),
      UserFormField(
        keyName: 'phone_number',
        displayName: s.phone_number,
        userType: LoginUserType.phone,
        fieldValidator: (value) {
          if (value == null || value.isEmpty) {
            return null;
          }
          final phoneRegExp = RegExp(
            r'^'
            r'(?:'
            r'\+1[ -]?(?:\(\d{3}\)|\d{3})[ -]?\d{3}[ -]?\d{4}'
            r'|\+81[ -]?(?:0\d{1,4}[ -]?\d{1,4}[ -]?\d{4}|\d{1,4}[ -]?\d{1,4}[ -]?\d{4})'
            r'|\+82[ -]?0?1[0-9]{1}[ -]?\d{3,4}[ -]?\d{4}'
            r'|\+33[ -]?(?:[1-9]\d{1}[ -]?){3}\d{2}'
            r'|\+44[ -]?7(?:[0-9][ -]?){9}'
            r'|\+7[ -]?[3489]\d{2}[ -]?\d{3}[ -]?\d{2}[ -]?\d{2}'
            r'|\+91[ -]?[6-9]\d{4}[ -]?\d{5}'
            r'|\+86[ -]?1[3-9]\d[ -]?\d{4}[ -]?\d{4}'
            r')'
            r'|'
            r'(?:1[3-9]\d[ -]?\d{4}[ -]?\d{4})'
            r'$',
          );
          if (!phoneRegExp.hasMatch(value)) {
            return s.valid_phone_number;
          }
          return null;
        },
      ),
    ];
  }
}

/// 展示与认证页面同主题的验证码弹层。
Future<Map<String, dynamic>?> showCaptchaDialog(
  Map<String, dynamic> captchaDic,
) async {
  final rootContext = appNavigatorKey.currentContext;
  if (rootContext == null) {
    return null;
  }

  HapticFeedback.selectionClick();
  final palette = FxPalette.of(rootContext);
  return showModalBottomSheet<Map<String, dynamic>>(
    context: rootContext,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    useSafeArea: true,
    backgroundColor: palette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: FxRadius.sheetRadius),
    ),
    builder: (_) => _CaptchaSheet(initialData: captchaDic),
  );
}

class _CaptchaSheet extends StatefulWidget {
  const _CaptchaSheet({required this.initialData});

  final Map<String, dynamic> initialData;

  @override
  State<_CaptchaSheet> createState() => _CaptchaSheetState();
}

class _CaptchaSheetState extends State<_CaptchaSheet> {
  final LoginService _service = LoginService();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late String _captchaCode;
  late Map<String, dynamic> _captchaData;
  bool _refreshing = false;
  String? _inputError;
  String? _refreshError;

  @override
  void initState() {
    super.initState();
    _captchaData = widget.initialData;
    _captchaCode = widget.initialData['captchaCodeImg'] as String? ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    HapticFeedback.lightImpact();
    setState(() {
      _refreshing = true;
      _refreshError = null;
    });
    try {
      final response = await _service.captchaImage();
      if (!mounted) return;
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      final code = data['captchaCodeImg'];
      if (code is! String || code.isEmpty) {
        throw StateError('captcha image missing');
      }
      setState(() {
        _captchaCode = code;
        _captchaData = data;
      });
    } on Object {
      if (!mounted) return;
      setState(() => _refreshError = S.of(context).commonSystemBusy);
    } finally {
      if (mounted) {
        setState(() => _refreshing = false);
      }
    }
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      HapticFeedback.heavyImpact();
      setState(() => _inputError = S.of(context).captchaRequired);
      _focusNode.requestFocus();
      return;
    }
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop({
      'captchaUserInput': value,
      'captchaCodeKey': _captchaData['captchaCodeKey'],
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final palette = FxPalette.of(context);
    return FxSheet(
      title: s.captchaTitle,
      scrollable: true,
      maxHeightFactor: 0.9,
      footer: _footer(context, s),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FxSpacing.lg,
          0,
          FxSpacing.lg,
          FxSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.captchaSubtitle,
              style: FxTypography.body.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: FxSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    label: s.captchaRefresh,
                    child: InkWell(
                      onTap: _refreshing ? null : _refresh,
                      borderRadius: FxRadius.tileBorder,
                      child: Container(
                        height: 64,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: palette.surfaceMuted,
                          borderRadius: FxRadius.tileBorder,
                          border: Border.all(color: palette.border),
                        ),
                        child: Base64Image(
                          key: ValueKey<String>(_captchaCode),
                          base64String: _captchaCode,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: FxSpacing.sm),
                FxPressable(
                  semanticLabel: s.captchaRefresh,
                  onPressed: _refreshing ? null : _refresh,
                  padding: EdgeInsets.zero,
                  borderRadius: FxRadius.pillBorder,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: _refreshing
                        ? Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: palette.primary,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.refresh_rounded,
                            color: palette.textSecondary,
                          ),
                  ),
                ),
              ],
            ),
            if (_refreshError case final message?) ...[
              const SizedBox(height: FxSpacing.sm),
              Semantics(
                liveRegion: true,
                child: Text(
                  message,
                  style: FxTypography.caption.copyWith(color: palette.danger),
                ),
              ),
            ],
            const SizedBox(height: FxSpacing.lg),
            FxTextField(
              label: s.captchaTitle,
              controller: _controller,
              focusNode: _focusNode,
              hintText: '••••',
              errorText: _inputError,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              maxLength: 4,
              autofocus: true,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: FxTypography.titleLarge.copyWith(
                color: palette.textPrimary,
                letterSpacing: 12,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              onChanged: (_) {
                if (_inputError != null) {
                  setState(() => _inputError = null);
                }
              },
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer(BuildContext context, S s) {
    final palette = FxPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FxSpacing.lg,
          FxSpacing.md,
          FxSpacing.lg,
          FxSpacing.lg,
        ),
        child: Row(
          children: [
            Expanded(
              child: FxButton.tonal(
                label: s.commonCancel,
                expand: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: FxSpacing.md),
            Expanded(
              child: FxButton(
                label: s.confirm,
                expand: true,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
