import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/util/dio_client.dart';
import 'package:fortuneboot/home/design_system/hjds_theme.dart';
import 'package:fortuneboot/home/design_system/hjds_components.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UIState _uiState = UIState.loading;
  Map<String, dynamic> _user = {};

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameCtrl = TextEditingController();
  late final TextEditingController _emailCtrl = TextEditingController();
  late final TextEditingController _phoneCtrl = TextEditingController();
  int _sex = 0;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() => _uiState = UIState.loading);
    try {
      final res = await DioClient().dio.get('/system/user/profile');
      if (!mounted) return;

      final data = Map<String, dynamic>.from(res.data as Map);
      if (data['code'] == 0) {
        final d = Map<String, dynamic>.from(data['data'] as Map? ?? {});
        _user = Map<String, dynamic>.from(d['user'] as Map? ?? {});
        _nicknameCtrl.text = _user['nickname']?.toString() ?? '';
        _emailCtrl.text = _user['email']?.toString() ?? '';
        _phoneCtrl.text = _user['phoneNumber']?.toString() ?? '';
        _sex = (_user['sex'] as int?) ?? 0;
        setState(() => _uiState = UIState.success);
      } else {
        setState(() => _uiState = UIState.error);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _uiState = UIState.error);
    }
  }

  Future<void> _saveProfile(
      BuildContext bottomSheetContext, int selectedSex) async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final body = {
        'nickname': _nicknameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'sex': selectedSex,
      };
      await DioClient().dio.put('/system/user/profile', data: jsonEncode(body));
      if (!mounted) return;

      Navigator.pop(bottomSheetContext);
      _fetchProfile();
    } catch (e) {
      if (!mounted) return;
      String errorMsg = '保存失败，请稍后重试';
      if (e.toString().contains('timeout') ||
          e.toString().contains('SocketException')) {
        errorMsg = '网络请求超时，请检查您的网络连接';
      } else if (e.toString().contains('401')) {
        errorMsg = '登录已过期，请重新登录';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: HJColors.textSecondary),
      prefixIcon: Icon(icon, color: HJColors.textSecondary, size: 20),
      filled: true,
      fillColor: HJColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: HJColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }

  Widget _buildGenderToggle(int tempSex, StateSetter setSheetState) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: HJColors.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children:[
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setSheetState(() => tempSex = 1);
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tempSex == 1 ? HJColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: tempSex == 1
                      ?[
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2))
                  ]
                      : null,
                ),
                child: Text('男',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: tempSex == 1
                            ? HJColors.textPrimary
                            : HJColors.textSecondary)),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setSheetState(() => tempSex = 2);
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tempSex == 2 ? HJColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: tempSex == 2
                      ?[
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2))
                  ]
                      : null,
                ),
                child: Text('女',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: tempSex == 2
                            ? HJColors.textPrimary
                            : HJColors.textSecondary)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openEditSheet() {
    int tempSex = _sex;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: HJColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 12,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: HJColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text('修改个人资料',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: HJColors.textPrimary)),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nicknameCtrl,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: HJColors.textPrimary),
                    decoration: _inputDecoration('昵称', Icons.badge_outlined),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '昵称不能为空' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: HJColors.textPrimary),
                    decoration: _inputDecoration('手机号', Icons.phone_iphone),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (!RegExp(r'^1\d{10}$').hasMatch(v)) return '手机号格式不正确';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: HJColors.textPrimary),
                    decoration: _inputDecoration('邮箱', Icons.email_outlined),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(v)) return '邮箱格式不正确';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children:[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: HJColors.textSecondary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.wc_outlined,
                            color: HJColors.textSecondary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text('性别',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: HJColors.textPrimary)),
                      const Spacer(),
                      Expanded(
                          flex: 2,
                          child: _buildGenderToggle(tempSex, setSheetState)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                      width: double.infinity,
                      child: HJButton.primary(
                          text: '保存',
                          onPressed: () => _saveProfile(sheetCtx, tempSex))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String nickname = _user['nickname']?.toString() ?? '';
    final String username = _user['username']?.toString() ?? '';
    final String roleName = _user['roleName']?.toString() ?? '用户';
    final String phoneNumber = _user['phoneNumber']?.toString() ?? '未设置';
    final String email = _user['email']?.toString() ?? '未设置';
    final String loginIp = _user['loginIp']?.toString() ?? '';
    final String loginDate = _user['loginDate']?.toString() ?? '';
    final String remark = _user['remark']?.toString() ?? '';
    final String initialChar =
    username.isNotEmpty ? username.substring(0, 1).toUpperCase() : '?';

    return Scaffold(
      backgroundColor: HJColors.background,
      appBar: AppBar(
          title: const Text('个人资料',
              style: TextStyle(
                  color: HJColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          backgroundColor: HJColors.background,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: HJColors.textPrimary)),
      body: UIStateHandler(
        state: _uiState,
        onRetry: _fetchProfile,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: HJSpacing.xl),
          child: Column(
            children:[
              Container(
                margin: const EdgeInsets.all(HJSpacing.md),
                padding: const EdgeInsets.all(HJSpacing.lg),
                decoration: BoxDecoration(
                    color: HJColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow:[
                      BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 4))
                    ]),
                child: Row(
                  children:[
                    CircleAvatar(
                        radius: 36,
                        backgroundColor: HJColors.primary.withOpacity(0.12),
                        child: Text(initialChar,
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: HJColors.primary))),
                    const SizedBox(width: HJSpacing.md),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              Text(nickname,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: HJColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text(roleName,
                                  style: const TextStyle(
                                      color: HJColors.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500))
                            ])),
                    Container(
                      decoration: const BoxDecoration(
                        color: HJColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: HJColors.textPrimary, size: 20),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            _openEditSheet();
                          }),
                    ),
                  ],
                ),
              ),
              SectionCard(
                title: '详细信息',
                items:[
                  HJValueItem(
                      icon: Icons.wc_outlined,
                      iconColor: const Color(0xFFAF52DE),
                      title: '性别',
                      valueText: _sex == 1 ? '男' : (_sex == 2 ? '女' : '未知'),
                      onTap: () {}),
                  HJValueItem(
                      icon: Icons.phone_iphone,
                      iconColor: const Color(0xFFFF9500),
                      title: '手机号',
                      valueText: phoneNumber,
                      onTap: () {}),
                  HJValueItem(
                      icon: Icons.email_outlined,
                      iconColor: HJColors.primary,
                      title: '邮箱',
                      valueText: email,
                      onTap: () {}),
                ],
              ),
              SectionCard(
                title: '系统记录',
                items:[
                  HJValueItem(
                      icon: Icons.person_outline,
                      iconColor: const Color(0xFF5856D6),
                      title: '账号',
                      valueText: username,
                      onTap: () {}),
                  HJValueItem(
                      icon: Icons.verified_user_outlined,
                      iconColor: HJColors.income,
                      title: '角色',
                      valueText: roleName,
                      onTap: () {}),
                  HJValueItem(
                      icon: Icons.language,
                      iconColor: HJColors.primary,
                      title: '登录IP',
                      valueText: loginIp,
                      onTap: () {}),
                  HJValueItem(
                      icon: Icons.access_time,
                      iconColor: const Color(0xFFFF2D55),
                      title: '登录时间',
                      valueText: loginDate,
                      onTap: () {}),
                  if (remark.isNotEmpty)
                    HJValueItem(
                        icon: Icons.note_outlined,
                        iconColor: HJColors.textSecondary,
                        title: '备注',
                        valueText: remark,
                        onTap: () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}