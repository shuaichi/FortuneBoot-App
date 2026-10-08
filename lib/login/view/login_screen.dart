import 'dart:async';
import 'dart:convert';
import 'dart:ui'; // 引入以使用 FontFeature

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:fortuneboot/core/app_constants.dart';
import 'package:fortuneboot/core/auth/auth_version_checker.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/login/auth/password_policy.dart';
import 'package:fortuneboot/login/auth_version_source.dart';
import 'package:fortuneboot/login/model/login_model.dart';
import 'package:fortuneboot/request/login_request.dart';
import 'package:fortuneboot/util/constants.dart';
import 'package:fortuneboot/theme/app_theme.dart';
import 'package:fortuneboot/core/navigation/app_nav.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/login/model/users.dart';
import 'package:fortuneboot/login/server/server_history_store.dart';
import 'package:fortuneboot/util/base64_img.dart';
import 'package:fortuneboot/util/dio_client.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:encrypt/encrypt.dart';
import '../../generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/pointycastle.dart' as PC;

class LoginScreen extends StatelessWidget {
  static const routeName = '/auth';

  const LoginScreen({super.key, this.roles = const []});

  final List<Map<String, dynamic>> roles;

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 0);

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

  Future<String?> _loginUser(LoginData data) async {
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
        return S.current.default_comment;
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
                  return S.current.default_comment;
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
            return S.current.default_comment;
          })
          .catchError((_) => S.current.default_comment);
    } on Object {
      return S.current.default_comment;
    }
  }

  void _selectRole(SignupData data, Map<String, dynamic> role) async {
    debugPrint("选择角色: $role");
    var str = await _signupUserWithRole(data, role);
    appNavigatorKey.currentState?.pop(str);
  }

  Future<String?> _signupUserWithRole(SignupData data, Map role) async {
    final loginService = LoginService();
    String userName = data.name!;
    String nickName = data.additionalSignupData!['nickname']!;
    String email = data.additionalSignupData!['email']!;
    String phoneNumber = data.additionalSignupData!['phone_number']!;
    int sex =
        (data.additionalSignupData!['sex'] ?? S.current.male) == S.current.male
        ? 1
        : 0;
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
          return value.msg ?? '注册失败';
        })
        .catchError((err) {
          return 'service error: $err';
        });
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
          return _signupUserWithRole(
            data,
            roles.first as Map<String, dynamic>? ?? {},
          );
        } else if (roles.length > 1) {
          final List<SimpleDialogOption> simpleDialogs = roles.map((role) {
            return SimpleDialogOption(
              onPressed: () {
                HapticFeedback.selectionClick();
                _selectRole(data, role);
              },
              child: Text(role['roleName'] as String? ?? ''),
            );
          }).toList();
          return showDialog<String?>(
            context: appNavigatorKey.currentContext!,
            builder: (context) => SimpleDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "选择角色",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              children: simpleDialogs,
            ),
          );
        } else {
          return 'service err role err';
        }
      }
    } catch (e) {
      return Future.delayed(loginTime).then((err) {
        return 'service err $err';
      });
    }
  }

  Future<String?> _recoverPassword(String name) async =>
      S.current.default_comment;

  Future<String?> _signupConfirm(String error, LoginData data) async =>
      S.current.default_comment;

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

  @override
  Widget build(BuildContext context) {
    final additionalSignupFields = fetchUserForms(context);
    final theme = Theme.of(context);
    // Material 3 输入文字用 bodyLarge。登录框是白底，深色主题下 bodyLarge 为浅色会看不见。
    return Theme(
      data: theme.copyWith(
        iconTheme: theme.iconTheme.copyWith(color: AppTheme.textPrimaryColor),
        textTheme: theme.textTheme.copyWith(
          bodyLarge: (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
            color: AppTheme.textPrimaryColor,
          ),
        ),
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          prefixIconColor: AppTheme.textPrimaryColor,
          suffixIconColor: AppTheme.textPrimaryColor,
        ),
      ),
      child: FlutterLogin(
      title: S.of(context).main_logo,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      logo: const AssetImage('assets/images/login_logo.webp'),
      logoTag: Constants.logoTag,
      titleTag: Constants.titleTag,
      navigateBackAfterRecovery: true,
      onConfirmRecover: _signupConfirm,
      onSwitchToAdditionalFields: (p0) async {
        final loginService = LoginService();
        var response = await loginService.checkRepeat(p0.name ?? '');
        print('lxjtodo: $response');
        if (response.code == 0) {
          if (response.data is bool) {
            bool res = response.data as bool;
            if (res) {
              return S.current.account_valid;
            }
          }
          return null;
        } else {
          return S.current.account_valid;
        }
      },
      loginAfterSignUp: false,
      termsOfService: [
        TermOfService(
          id: 'general-term',
          mandatory: true,
          text: S.of(context).term_of_services,
          linkUrl: 'https://privacy-policy.fortuneboot.com/privacy.html',
          validationErrorMessage: S.of(context).service_required,
        ),
      ],
      additionalSignupFields: additionalSignupFields,
      messages: LoginMessages(
        userHint: S.of(context).login_account,
        passwordHint: S.of(context).login_pass,
        confirmPasswordHint: S.of(context).login_confirm,
        loginButton: S.of(context).login_button_text,
        signupButton: S.of(context).register,
        forgotPasswordButton: S.of(context).forgot_huh,
        recoverPasswordButton: S.of(context).help_me,
        goBackButton: S.of(context).go_back,
        confirmPasswordError: S.of(context).not_match,
        recoverPasswordIntro: S.of(context).dont_worry_be_happy,
        recoverPasswordDescription: S.of(context).default_comment,
        recoverPasswordSuccess: S.of(context).password_rescued_successfully,
        flushbarTitleError: S.of(context).oh_no,
        flushbarTitleSuccess: S.of(context).succes,
        providersTitleFirst: S.of(context).or_login_with,
        additionalSignUpFormDescription: S.of(context).fill_to_signup,
        additionalSignUpSubmitButton: S.of(context).sign_up_submit,
        signUpSuccess: S.of(context).sign_up_success,
      ),
      theme: AppTheme.loginTheme(context),
      userValidator: (value) {
        if (value!.isEmpty) {
          return S.of(context).user_auth_vaild;
        }
        return null;
      },
      passwordValidator: (value) {
        if (value!.isEmpty) {
          return S.of(context).password_is_empty;
        }
        if (!PasswordPolicy.isValid(value)) {
          return '密码必须包含字母、数字或特殊字符，长度8-18位，不能包含中文';
        }
        return null;
      },
      onLogin: (loginData) {
        HapticFeedback.mediumImpact(); // 登录按钮中等震动反馈
        return _loginUser(loginData);
      },
      onSignup: (signupData) {
        HapticFeedback.mediumImpact();
        return _signupUser(signupData);
      },
      onSubmitAnimationCompleted: () async {
        final check = await AuthVersionChecker(
          source: LoginApiVersionSource(),
        ).check();
        if (!context.mounted) return;
        if (!check.isCompatible) {
          DioClient().clearAuthHeader();
          await UserDataSingleton().clearAuth();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_apiVersionFailureMessage(context, check))),
          );
          return;
        }
        // 换服务器/重新登录后必须清空会话，否则 MainShell 可能跳过 load。
        context.read<SessionCubit>().reset();
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.main, (route) => false);
      },
      onRecoverPassword: (name) {
        HapticFeedback.lightImpact();
        return _recoverPassword(name);
      },
      headerWidget: const IntroWidget(),
    ),
    );
  }

  List<UserFormField> fetchUserForms(BuildContext context) {
    return [
      UserFormField(
        keyName: 'nickname',
        displayName: S.of(context).login_nickname,
        icon: Icon(FontAwesomeIcons.userLarge.data),
        fieldValidator: (value) {
          if (value!.isEmpty) {
            return S.of(context).user_auth_vaild;
          }
          return null;
        },
      ),
      UserFormField(
        keyName: 'sex',
        displayName: S.of(context).sex,
        icon: Icon(FontAwesomeIcons.venusMars.data),
        tooltip: const TextSpan(text: '男/女'),
        userType: LoginUserType.text,
      ),
      UserFormField(
        keyName: 'email',
        displayName: S.of(context).login_email,
        userType: LoginUserType.email,
        icon: const Icon(Icons.email),
        fieldValidator: (value) {
          if (value!.isNotEmpty &&
              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return S.of(context).invalid_email;
          }
          return null;
        },
      ),
      UserFormField(
        keyName: 'phone_number',
        displayName: S.of(context).phone_number,
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
            return S.of(context).valid_phone_number;
          }
          return null;
        },
      ),
    ];
  }
}

// 高级金融感：重写头部引导区
class IntroWidget extends StatelessWidget {
  const IntroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: S.of(context).login_message,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93), // 次要信息降噪
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                TextSpan(
                  text: ' ${S.of(context).login_host}',
                  style: const TextStyle(
                    color: Color(0xFF1C1C1E),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              const Expanded(
                child: Divider(thickness: 0.5, color: Color(0xFFC6C6C8)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  S.of(context).authenticate,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8E8E93),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(thickness: 0.5, color: Color(0xFFC6C6C8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// 极致金融级安全验证码弹窗 - Top-Tier Fintech Captcha Dialog
// ----------------------------------------------------------------------
Future<Map?> showCaptchaDialog(Map captchaDic) async {
  if (appNavigatorKey.currentContext == null) {
    return null;
  }

  // 弹窗出现时的物理感知
  HapticFeedback.selectionClick();

  final controller = TextEditingController();
  final focusNode = FocusNode();
  String captchaCode = captchaDic['captchaCodeImg'] as String;
  Map captchaData = captchaDic;
  final LoginService loginService = LoginService();
  bool isLoading = false; // 刷新状态防抖

  return showDialog<Map?>(
    context: appNavigatorKey.currentContext!,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.4), // 沉浸式背景层
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        Future<void> _refreshCaptcha() async {
          if (isLoading) return;
          HapticFeedback.lightImpact(); // 轻按反馈
          setState(() => isLoading = true);
          try {
            final capImgRes = await loginService.captchaImage();
            final Map<String, dynamic> capDic = Map<String, dynamic>.from(
              capImgRes.data as Map,
            );
            setState(() {
              captchaCode = capDic['captchaCodeImg'] as String;
              captchaData = capDic;
            });
          } finally {
            setState(() => isLoading = false);
          }
        }

        return Dialog(
          backgroundColor: Colors.transparent, // 穿透以渲染自定义卡片
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24), // 大圆角
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部图标 Affordance
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withOpacity(0.12), // iOS蓝态
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_rounded, // 安全护盾图标传达信任感
                    color: Color(0xFF007AFF),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '请输入验证码',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '保障您的账户资金安全',
                  style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
                ),
                const SizedBox(height: 24),

                // 验证码图片与刷新按钮行
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _refreshCaptcha,
                        child: Container(
                          height: 54,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE5E5EA),
                              width: 1,
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Base64Image(
                              key: ValueKey<String>(captchaCode),
                              base64String: captchaCode,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _refreshCaptcha,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isLoading
                              ? const Color(0xFF007AFF).withOpacity(0.05)
                              : const Color(0xFF007AFF).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Color(0xFF007AFF),
                                ),
                              )
                            : const Icon(
                                Icons.refresh_rounded,
                                color: Color(0xFF007AFF),
                                size: 24,
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 极致抛光的数字输入区
                TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  cursorColor: const Color(0xFF007AFF),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: 24, // 增加字符间距营造高级感
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                  onChanged: (val) {
                    HapticFeedback.lightImpact(); // 每次按键注入触觉反馈
                  },
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFFF2F4F7),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    hintText: '· ·',
                    hintStyle: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8E93).withOpacity(0.4),
                      letterSpacing: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 底部操作区组
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '取消',
                            style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (controller.text.isEmpty) {
                            // 错误态震动
                            HapticFeedback.heavyImpact();
                            return;
                          }
                          HapticFeedback.mediumImpact(); // 提交时震动反馈
                          Map<String, dynamic> userDic = {};
                          userDic['captchaUserInput'] = controller.text;
                          userDic['captchaCodeKey'] =
                              captchaData['captchaCodeKey'];
                          Navigator.pop(context, userDic);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF007AFF), // 核心提交色
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF007AFF).withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '确认',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
