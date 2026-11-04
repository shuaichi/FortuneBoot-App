import 'package:fortuneboot/core/auth/auth_version_checker.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:flutter/material.dart';
// 引入震动反馈
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/app_constants.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/preferences/locale_preferences.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/login/auth_version_source.dart';
import 'package:fortuneboot/login/view/auth_scaffold.dart';
import 'package:fortuneboot/login/model/users.dart';
import 'package:fortuneboot/login/server/server_endpoint.dart';
import 'package:fortuneboot/login/server/server_history_store.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/util/dio_client.dart';

enum AuthMode { loading, signIn }

class BaseUrlConfigPage extends StatefulWidget {
  static const routeName = '/base_url_config';

  const BaseUrlConfigPage({Key? key}) : super(key: key);

  @override
  _BaseUrlConfigPageState createState() => _BaseUrlConfigPageState();
}

class _BaseUrlConfigPageState extends State<BaseUrlConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<AuthMode> _authMode = ValueNotifier<AuthMode>(
    AuthMode.loading,
  );

  String _protocol = 'https';
  final TextEditingController _domainController = TextEditingController(
    text: 'demo.fortuneboot.com',
  );
  final TextEditingController _portController = TextEditingController(
    text: '443',
  );
  final TextEditingController _apiPrefixController = TextEditingController(
    text: ServerEndpoint.defaultApiPrefix,
  );
  final ServerHistoryStore _historyStore = ServerHistoryStore();
  List<ServerHistoryEntry> _history = const [];

  // 新增：用于接管网络请求时的动态 Loading 状态
  bool _isConnecting = false;

  /// 开发者隐藏开关：连续点击顶部图标 [_devTapThreshold] 次（间隔超 2 秒重新计数）
  /// 后显示接口前缀输入框；为内存态，冷启动自动隐藏。
  bool _devPrefixVisible = false;
  int _devTapCount = 0;
  DateTime? _lastDevTap;
  static const int _devTapThreshold = 7;

  void _handleDevTap() {
    if (_devPrefixVisible) return;
    final now = DateTime.now();
    if (_lastDevTap == null ||
        now.difference(_lastDevTap!) > const Duration(seconds: 2)) {
      _devTapCount = 0;
    }
    _lastDevTap = now;
    _devTapCount++;
    if (_devTapCount >= _devTapThreshold) {
      HapticFeedback.mediumImpact();
      setState(() {
        _devPrefixVisible = true;
        _apiPrefixController.text =
            ServerEndpoint.sessionApiPrefix ?? ServerEndpoint.defaultApiPrefix;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).developerPrefixUnlocked),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTokenValid();
    });
    super.initState();
  }

  Future<void> _reloadHistory() async {
    final list = await _historyStore.load();
    if (!mounted) return;
    setState(() => _history = list);
  }

  void _applyHistoryEntry(ServerHistoryEntry entry) {
    HapticFeedback.selectionClick();
    setState(() {
      _protocol = entry.protocol;
      _domainController.text = entry.host;
      _portController.text = entry.port;
    });
  }

  Future<void> _checkTokenValid() async {
    var baseUrlDomain = await UserDataSingleton().getStr(
      UserDataSingleton.baseUrlDomain,
    );
    var baseUrlPort = await UserDataSingleton().getStr(
      UserDataSingleton.baseUrlPort,
    );
    var baseProtocol = await UserDataSingleton().getStr(
      UserDataSingleton.baseUrlProtocol,
    );

    if (baseUrlDomain?.isNotEmpty == true && baseProtocol?.isNotEmpty == true) {
      _domainController.text = baseUrlDomain!;
      _portController.text = baseUrlPort ?? '';
      _protocol = baseProtocol!;
      // 把当前已保存地址写入历史，便于下次下拉选择。
      await _historyStore.rememberCurrentSaved();
    }
    await _reloadHistory();
    var userInfo = await UserDataSingleton().getMap(UserDataSingleton.userInfo);
    var userToken = await UserDataSingleton().getMap(
      UserDataSingleton.userToken,
    );

    if ((userInfo?.isNotEmpty == true) &&
        (userToken?.isNotEmpty == true) &&
        (baseUrlDomain?.isNotEmpty == true) &&
        (baseProtocol?.isNotEmpty == true)) {
      final endpoint = ServerEndpoint.parse(
        protocol: baseProtocol!,
        host: baseUrlDomain!,
        port: baseUrlPort,
        apiPrefix: ServerEndpoint.sessionApiPrefix,
      );
      DioClient().updateBaseUrl(endpoint.apiBaseUri.toString());
      final check = await _checkApiVersion();
      if (!mounted) return;
      if (!check.isCompatible) {
        _showVersionCheckFailure(check);
        _authMode.value = AuthMode.signIn;
        return;
      }
      DioClient().setAuthHeader(userToken!);
      if (!(await _checkLoginSessionValid())) {
        DioClient().clearAuthHeader();
        await UserDataSingleton().clearAuth();
        _authMode.value = AuthMode.signIn;
        return;
      }
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Routes.main, (route) => false);
    } else {
      _authMode.value = AuthMode.signIn;
    }
  }

  Widget _buildLanguageMenu(BuildContext context) {
    final s = S.of(context);
    final current = context.watch<PreferencesCubit>().state.locale.code;
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.language_rounded,
        color: FxPalette.of(context).textPrimary,
      ),
      tooltip: s.commonLanguage,
      onSelected: (code) =>
          context.read<PreferencesCubit>().setLocaleCode(code),
      itemBuilder: (context) => [
        _langItem(LocalePreferences.systemCode, s.commonFollowSystem, current),
        _langItem('zh', s.commonChinese, current),
        _langItem('en', s.commonEnglish, current),
      ],
    );
  }

  PopupMenuItem<String> _langItem(String code, String label, String current) {
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          if (code == current)
            Icon(
              Icons.check_rounded,
              size: 18,
              color: FxPalette.of(context).primary,
            ),
        ],
      ),
    );
  }

  Future<bool> _checkLoginSessionValid() async {
    try {
      final response = await DioClient().dio.get<Object?>(
        '/system/user/profile',
      );
      final data = response.data;
      if (data is Map<Object?, Object?>) {
        return data['code'] == 0;
      }
      return false;
    } on Exception {
      return false;
    }
  }

  @override
  void dispose() {
    _authMode.dispose();
    _domainController.dispose();
    _portController.dispose();
    _apiPrefixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ValueListenableBuilder<AuthMode>(
      valueListenable: _authMode,
      builder: (context, mode, child) {
        return AuthScaffold(
          title: s.baseUrlConfig,
          subtitle: '',
          actions: [_buildLanguageMenu(context)],
          onTitleTap: _handleDevTap,
          child: mode == AuthMode.loading
              ? const SizedBox(
                  height: 240,
                  child: Center(child: CircularProgressIndicator()),
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildConfigCard(),
                      const SizedBox(height: FxSpacing.xxxl),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildConfigCard() {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_history.isNotEmpty) ...[
          _buildHistoryField(),
          const SizedBox(height: FxSpacing.lg),
        ],
        _buildProtocolField(),
        const SizedBox(height: FxSpacing.lg),
        _buildTextField(
          label: s.domain,
          controller: _domainController,
          hint: 'demo.fortuneboot.com',
          icon: Icons.language_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return s.pleaseEnterDomain;
            }
            return null;
          },
        ),
        const SizedBox(height: FxSpacing.lg),
        _buildTextField(
          label: s.port,
          controller: _portController,
          hint: '443',
          icon: Icons.numbers_rounded,
          keyboardType: TextInputType.number,
        ),
        if (_devPrefixVisible) ...[
          const SizedBox(height: FxSpacing.lg),
          _buildTextField(
            label: s.apiPrefixLabel,
            controller: _apiPrefixController,
            hint: ServerEndpoint.defaultApiPrefix,
            icon: Icons.alt_route_rounded,
            validator: (value) {
              final prefix = value?.trim() ?? '';
              if (prefix.isEmpty) {
                return null;
              }
              if (!prefix.startsWith('/') ||
                  prefix.endsWith('/') ||
                  prefix == '/' ||
                  prefix.contains(RegExp(r'\s'))) {
                return s.apiPrefixInvalid;
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildHistoryField() {
    final s = S.of(context);
    final current = ServerHistoryEntry(
      protocol: _protocol,
      host: _domainController.text.trim(),
      port: _portController.text.trim(),
    );
    ServerHistoryEntry? matched;
    for (final entry in _history) {
      if (entry == current) {
        matched = entry;
        break;
      }
    }
    return DropdownButtonFormField<ServerHistoryEntry>(
      initialValue: matched,
      isExpanded: true,
      decoration: _inputDecoration(
        label: s.serverHistory,
        hint: s.serverHistorySelect,
        icon: Icons.history_rounded,
      ),
      items: [
        for (final entry in _history)
          DropdownMenuItem<ServerHistoryEntry>(
            value: entry,
            child: Text(
              entry.displayLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (entry) {
        if (entry != null) {
          _applyHistoryEntry(entry);
        }
      },
    );
  }

  Widget _buildProtocolField() {
    final s = S.of(context);
    return DropdownButtonFormField<String>(
      initialValue: _protocol,
      decoration: _inputDecoration(
        label: s.protocol,
        icon: Icons.security_rounded,
      ),
      items: const [
        DropdownMenuItem(value: 'https', child: Text('HTTPS')),
        DropdownMenuItem(value: 'http', child: Text('HTTP')),
      ],
      onChanged: (value) {
        if (value == null) {
          return;
        }
        HapticFeedback.selectionClick();
        setState(() {
          _protocol = value;
          _portController.text = value == 'https' ? '443' : '80';
        });
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return authInputDecoration(context, label: label, icon: icon, hint: hint);
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final palette = FxPalette.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      cursorColor: palette.primary,
      style: FxTypography.bodyStrong.copyWith(color: palette.textPrimary),
      decoration: _inputDecoration(label: label, hint: hint, icon: icon),
      validator: validator,
    );
  }

  Widget _buildSubmitButton() {
    return FxButton(
      label: S.of(context).confirm,
      expand: true,
      loading: _isConnecting,
      onPressed: _submitForm,
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact(); // 提交时中等力度震动反馈
      setState(() => _isConnecting = true);

      final endpoint = _parseEndpoint();
      if (endpoint == null) {
        setState(() => _isConnecting = false);
        return;
      }
      // 换服务器必须清掉旧 token，并重置会话；否则会带着 A 站凭证打 B 站。
      DioClient().clearAuthHeader();
      await UserDataSingleton().clearAuth();
      if (mounted) context.read<SessionCubit>().reset();
      DioClient().updateBaseUrl(endpoint.apiBaseUri.toString());
      try {
        final check = await _checkApiVersion();
        if (!mounted) return;
        if (check.isCompatible) {
          UserDataSingleton().setStr(
            UserDataSingleton.baseUrlDomain,
            endpoint.host,
          );
          UserDataSingleton().setStr(
            UserDataSingleton.baseUrlPort,
            endpoint.storedPort,
          );
          UserDataSingleton().setStr(
            UserDataSingleton.baseUrlProtocol,
            endpoint.protocol,
          );
          if (_devPrefixVisible) {
            // 会话前缀仅保留在内存，冷启动回滚默认 /prod-api。
            ServerEndpoint.sessionApiPrefix = endpoint.apiPrefix;
          }
          await _historyStore.remember(endpoint);

          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(Routes.auth);
        } else {
          _showVersionCheckFailure(check);
        }
      } catch (e) {
        _showErrorDialog(S.current.serverConnectionFailed);
      } finally {
        if (mounted) setState(() => _isConnecting = false);
      }
    }
  }

  ServerEndpoint? _parseEndpoint() {
    try {
      return ServerEndpoint.parse(
        protocol: _protocol,
        host: _domainController.text,
        port: _portController.text,
        apiPrefix: _devPrefixVisible
            ? _apiPrefixController.text
            : ServerEndpoint.sessionApiPrefix,
      );
    } on ServerEndpointFormatException {
      _showErrorDialog(S.current.serverConnectionFailed);
      return null;
    }
  }

  Future<ApiVersionCheckResult> _checkApiVersion() =>
      AuthVersionChecker(source: LoginApiVersionSource()).check();

  /// 按版本校验失败结果弹出对应的提示文案。
  void _showVersionCheckFailure(ApiVersionCheckResult check) {
    final message = switch (check.status) {
      ApiVersionStatus.versionTooLow => S.current.apiVersionTooLow(
        check.actualVersion,
        AppConstants.minApiVersion,
      ),
      ApiVersionStatus.versionTooHigh => S.current.apiVersionTooHigh(
        check.actualVersion,
        AppConstants.maxApiVersion,
      ),
      ApiVersionStatus.endpointUnavailable =>
        S.current.apiVersionEndpointUnavailable(AppConstants.minApiVersion),
      ApiVersionStatus.versionInvalid => S.current.apiVersionUnavailable,
      ApiVersionStatus.connectionFailed => S.current.serverConnectionFailed,
      ApiVersionStatus.compatible => '',
    };
    if (message.isNotEmpty) _showErrorDialog(message);
  }

  // --- 4. 摒弃原生系统警告，重写高端金融级报错弹窗 ---
  void _showErrorDialog(String message) {
    HapticFeedback.heavyImpact();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final palette = FxPalette.of(dialogContext);
        return AlertDialog(
          backgroundColor: palette.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: FxRadius.cardBorder),
          icon: Icon(
            Icons.error_outline_rounded,
            color: palette.danger,
            size: 28,
          ),
          title: Text(
            S.of(dialogContext).error,
            style: FxTypography.title.copyWith(color: palette.textPrimary),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: FxTypography.body.copyWith(color: palette.textSecondary),
          ),
          actions: [
            FxButton(
              label: S.of(dialogContext).ok,
              expand: true,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }
}
