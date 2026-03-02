import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hjproject/util/dio_client.dart';
import 'package:hjproject/home/design_system/hjds_theme.dart';
import 'package:hjproject/home/design_system/hjds_components.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 【修复 Issue 7】重命名为 _uiState 避免混淆
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
      if (!mounted) return; // 【修复 Issue 3】跨帧渲染异常检查

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

  // 【修复 Issue 2】接收 BottomSheet 内的实际选择值，不依赖全局延迟同步
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
      // 【修复 Issue 6】友好的错误提示翻译
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

  void _openEditSheet() {
    int tempSex = _sex; // 面板内的局部状态
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
              left: HJSpacing.md,
              right: HJSpacing.md,
              top: HJSpacing.lg,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('修改个人资料',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: HJSpacing.lg),
                  TextFormField(
                    controller: _nicknameCtrl,
                    decoration: const InputDecoration(
                        labelText: '昵称',
                        prefixIcon: Icon(Icons.badge_outlined)),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? '昵称不能为空' : null,
                  ),
                  const SizedBox(height: HJSpacing.md),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: '手机号', prefixIcon: Icon(Icons.phone_iphone)),
                    // 【修复 Issue 12】手机号正则校验
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (!RegExp(r'^1\d{10}$').hasMatch(v)) return '手机号格式不正确';
                      return null;
                    },
                  ),
                  const SizedBox(height: HJSpacing.md),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: '邮箱',
                        prefixIcon: Icon(Icons.email_outlined)),
                    // 【修复 Issue 12】邮箱正则校验
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(v)) return '邮箱格式不正确';
                      return null;
                    },
                  ),
                  const SizedBox(height: HJSpacing.lg),
                  Row(
                    children: [
                      const Icon(Icons.wc_outlined, color: Colors.grey),
                      const SizedBox(width: 12),
                      const Text('性别', style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      ToggleButtons(
                        isSelected: [tempSex == 1, tempSex == 2],
                        onPressed: (index) =>
                            setSheetState(() => tempSex = index == 0 ? 1 : 2),
                        borderRadius: BorderRadius.circular(8),
                        children: const [
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('男')),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('女')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: HJSpacing.xl),
                  SizedBox(
                      width: double.infinity,
                      // 【修复 Issue 2】直接将面板内的 tempSex 传给保存函数，彻底解耦全局 _sex
                      child: HJButton.primary(
                          text: '保存',
                          onPressed: () => _saveProfile(sheetCtx, tempSex))),
                  const SizedBox(height: HJSpacing.xl),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
          title: const Text('个人资料',
              style: TextStyle(color: Colors.black87, fontSize: 18)),
          backgroundColor: Colors.grey[50],
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87)),
      body: UIStateHandler(
        state: _uiState,
        onRetry: _fetchProfile,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: HJSpacing.xl),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(HJSpacing.md),
                padding: const EdgeInsets.all(HJSpacing.lg),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: Text(initialChar,
                            style: TextStyle(
                                fontSize: 28,
                                color: Theme.of(context).primaryColor))),
                    const SizedBox(width: HJSpacing.md),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(nickname,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(roleName,
                              style: const TextStyle(color: Colors.white70))
                        ])),
                    IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: _openEditSheet),
                  ],
                ),
              ),
              SectionCard(
                title: '详细信息',
                items: [
                  HJValueItem(
                      icon: Icons.wc_outlined,
                      title: '性别',
                      valueText: _sex == 1 ? '男' : (_sex == 2 ? '女' : '未知'),
                      onTap: () {}),
                  HJValueItem(
                      icon: Icons.phone_iphone,
                      title: '手机号',
                      valueText: phoneNumber,
                      onTap: () {}),
                  HJValueItem(
                      icon: Icons.email_outlined,
                      title: '邮箱',
                      valueText: email,
                      onTap: () {}),
                ],
              ),
              SectionCard(
                title: '系统记录',
                items: [
                  HJValueItem(
                      icon: Icons.person_outline,
                      title: '账号',
                      valueText: username,
                      onTap: () {}),
                  HJValueItem(
                      icon: Icons.verified_user_outlined,
                      title: '角色',
                      valueText: roleName,
                      onTap: () {}),
                  HJValueItem(
                      icon: Icons.language,
                      title: '登录IP',
                      valueText: loginIp,
                      onTap: () {}),
                  HJValueItem(
                      icon: Icons.access_time,
                      title: '登录时间',
                      valueText: loginDate,
                      onTap: () {}),
                  if (remark.isNotEmpty)
                    HJValueItem(
                        icon: Icons.note_outlined,
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
