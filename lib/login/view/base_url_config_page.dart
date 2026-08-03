import 'dart:math';

import 'package:flutter/material.dart';
// 引入震动反馈
import 'package:flutter/services.dart';
import 'package:fortuneboot/repository/repository/bills_repository.dart';
import 'package:fortuneboot/request/login_request.dart';
import 'package:fortuneboot/home/home/view/home_page.dart';
import 'package:fortuneboot/login/model/users.dart';
import 'package:fortuneboot/login/view/login_screen.dart';
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

  // 新增：用于接管网络请求时的动态 Loading 状态
  bool _isConnecting = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTokenValid();
    });
    super.initState();
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

    if (baseUrlDomain?.isNotEmpty == true &&
        baseUrlPort?.isNotEmpty == true &&
        baseProtocol?.isNotEmpty == true) {
      _domainController.text = baseUrlDomain!;
      _portController.text = baseUrlPort!;
      _protocol = baseProtocol!;
    }
    var userInfo = await UserDataSingleton().getMap(UserDataSingleton.userInfo);
    var userToken = await UserDataSingleton().getMap(
      UserDataSingleton.userToken,
    );

    if ((userInfo?.isNotEmpty == true) &&
        (userToken?.isNotEmpty == true) &&
        (baseUrlDomain?.isNotEmpty == true) &&
        (baseUrlPort?.isNotEmpty == true) &&
        (baseProtocol?.isNotEmpty == true)) {
      // 跳登录页
      final baseUrl = '$baseProtocol://$baseUrlDomain:$baseUrlPort';
      DioClient().updateBaseUrl('$baseUrl/prod-api');
      if (!(await checkApiVersion())) {
        _showErrorDialog(S.current.serverConnectionFailed);
        _authMode.value = AuthMode.signIn;
        return;
      }
      DioClient().refreshToken(userToken!);
      if (!(await _checkLoginSessionValid())) {
        UserDataSingleton().remove(UserDataSingleton.userInfo);
        UserDataSingleton().remove(UserDataSingleton.userToken);
        DioClient().refreshToken({});
        _authMode.value = AuthMode.signIn;
        return;
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } else {
      _authMode.value = AuthMode.signIn;
    }
  }

  Future<bool> _checkLoginSessionValid() async {
    try {
      final response = await DioClient().dio.get('/system/user/profile');
      final data = response.data;
      if (data is Map) {
        return data['code'] == 0;
      }
      return false;
    } on Exception {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthMode>(
      valueListenable: _authMode,
      builder: (context, mode, child) {
        return Scaffold(
          // 采用高端蓝灰底色，凸显卡片的纯白质感
          backgroundColor: const Color(0xFFF2F4F7),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              S.of(context).baseUrlConfig,
              style: const TextStyle(
                color: Color(0xFF1C1C1E),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF1C1C1E)),
          ),
          body: mode == AuthMode.loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(
                      0xFF007AFF,
                    ), // iOS经典蓝 (Neutral / Config Action)
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 32),
                          _buildConfigCard(),
                          const SizedBox(height: 40),
                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  // --- 1. 高端金融级标题组件 ---
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF007AFF).withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.dns_rounded,
            color: Color(0xFF007AFF),
            size: 24,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          S.of(context).baseUrlConfig,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1E),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  // --- 2. 玻璃态组合卡片视图 (Card Grouping) ---
  Widget _buildConfigCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProtocolRow(),
          _buildDivider(),
          _buildTextFieldRow(
            label: S.of(context).domain,
            controller: _domainController,
            hint: "demo.fortuneboot.com",
            icon: Icons.language_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).pleaseEnterDomain;
              }
              return null;
            },
          ),
          _buildDivider(),
          _buildTextFieldRow(
            label: S.of(context).port,
            controller: _portController,
            hint: "443",
            icon: Icons.numbers_rounded,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.security_rounded,
              size: 20,
              color: Color(0xFF007AFF),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              S.of(context).protocol,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _protocol,
              icon: const Icon(
                Icons.expand_more_rounded,
                color: Color(0xFF8E8E93),
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF007AFF),
              ),
              items: ['https', 'http'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.toUpperCase()),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  HapticFeedback.selectionClick(); // 下拉选择触发轻触反馈
                  setState(() {
                    _protocol = newValue;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldRow({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF007AFF)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8E8E93), // 次要信息降噪
                  ),
                ),
                TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  cursorColor: const Color(0xFF007AFF),
                  onTap: () => HapticFeedback.selectionClick(), // 激活输入时的反馈
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.only(top: 4, bottom: 4),
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8E93).withOpacity(0.5),
                    ),
                  ),
                  validator: validator,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 精致发丝线分割器
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Container(height: 0.5, color: const Color(0xFFC6C6C8)),
    );
  }

  // --- 3. 动态加载确认按钮 ---
  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isConnecting ? null : _submitForm,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _isConnecting
              ? const Color(0xFF007AFF).withOpacity(0.7)
              : const Color(0xFF007AFF),
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
        child: _isConnecting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                S.of(context).confirm,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact(); // 提交时中等力度震动反馈
      setState(() => _isConnecting = true);

      DioClient().refreshToken({});
      var baseUrl = '$_protocol://${_domainController.text}';
      if (_portController.text.isNotEmpty) {
        baseUrl += ':${_portController.text}';
      }
      DioClient().updateBaseUrl('$baseUrl/prod-api');
      try {
        if (await checkApiVersion()) {
          UserDataSingleton().setStr(
            UserDataSingleton.baseUrlDomain,
            _domainController.text,
          );
          UserDataSingleton().setStr(
            UserDataSingleton.baseUrlPort,
            _portController.text,
          );
          UserDataSingleton().setStr(
            UserDataSingleton.baseUrlProtocol,
            _protocol,
          );

          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          _showErrorDialog(S.current.serverConnectionFailed);
        }
      } catch (e) {
        _showErrorDialog(S.current.serverConnectionFailed);
      } finally {
        if (mounted) setState(() => _isConnecting = false);
      }
    }
  }

  // --- 核心业务逻辑不变 ---
  Future<bool> checkApiVersion() async {
    LoginService loginService = LoginService();
    try {
      final apiResponse = await loginService.apiVersion();
      if (apiResponse.code == 0) {
        final curVersionString = apiResponse.data as String? ?? '';
        if (curVersionString.isNotEmpty) {
          final int maxRes = compareVersion(
            curVersionString,
            BillsRepository.maxApiVersion,
          );
          final int minRes = compareVersion(
            curVersionString,
            BillsRepository.minApiVersion,
          );
          // 左闭右开
          print('lxjtodo: $maxRes $minRes');
          return maxRes < 0 && minRes >= 0;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      _showErrorDialog(e.toString());
      return false;
    }
  }

  int compareVersion(String version1, String version2) {
    List<String> v1 = version1.split('.');
    List<String> v2 = version2.split('.');

    int maxLength = max(v1.length, v2.length);
    for (int i = 0; i < maxLength; i++) {
      int num1 = (i < v1.length) ? int.parse(v1[i]) : 0;
      int num2 = (i < v2.length) ? int.parse(v2[i]) : 0;

      if (num1 < num2) {
        return -1;
      } else if (num1 > num2) {
        return 1;
      }
    }
    return 0;
  }

  // --- 4. 摒弃原生系统警告，重写高端金融级报错弹窗 ---
  void _showErrorDialog(String message) {
    HapticFeedback.heavyImpact(); // 错误发生时强震动警告
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFFF3B30,
                  ).withOpacity(0.12), // iOS Red State
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFFF3B30),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                S.of(context).error,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    S.of(context).ok,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
