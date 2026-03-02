import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hjproject/util/dio_client.dart';
import 'package:hjproject/home/design_system/hjds_theme.dart';
import 'package:hjproject/home/design_system/hjds_components.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UIState _state = UIState.loading;
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
    setState(() => _state = UIState.loading);
    try {
      final res = await DioClient().dio.get('/system/user/profile');
      final data = Map<String, dynamic>.from(res.data as Map);
      if (data['code'] == 0) {
        final d = Map<String, dynamic>.from(data['data'] as Map? ?? {});
        _user = Map<String, dynamic>.from(d['user'] as Map? ?? {});
        _nicknameCtrl.text = _user['nickname']?.toString() ?? '';
        _emailCtrl.text = _user['email']?.toString() ?? '';
        _phoneCtrl.text = _user['phoneNumber']?.toString() ?? '';
        _sex = (_user['sex'] as int?) ?? 0;
        setState(() => _state = UIState.success);
      } else {
        setState(() => _state = UIState.error);
      }
    } catch (e) {
      setState(() => _state = UIState.error);
    }
  }

  Future<void> _saveProfile(BuildContext bottomSheetContext) async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final body = {
        'nickname': _nicknameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'sex': _sex,
      };
      await DioClient().dio.put('/system/user/profile', data: jsonEncode(body));
      if (mounted) {
        Navigator.pop(bottomSheetContext);
        _fetchProfile();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存失败: $e')));
    }
  }

  void _openEditSheet() {
    int tempSex = _sex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
              left: HJSpacing.md, right: HJSpacing.md, top: HJSpacing.lg,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  const Text('修改个人资料', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: HJSpacing.lg),
                  TextFormField(
                    controller: _nicknameCtrl,
                    decoration: const InputDecoration(labelText: '昵称', prefixIcon: Icon(Icons.badge_outlined)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? '昵称不能为空' : null,
                  ),
                  const SizedBox(height: HJSpacing.md),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: '手机号', prefixIcon: Icon(Icons.phone_iphone)),
                  ),
                  const SizedBox(height: HJSpacing.md),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: '邮箱', prefixIcon: Icon(Icons.email_outlined)),
                  ),
                  const SizedBox(height: HJSpacing.lg),
                  Row(
                    children:[
                      const Icon(Icons.wc_outlined, color: Colors.grey),
                      const SizedBox(width: 12),
                      const Text('性别', style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      ToggleButtons(
                        isSelected:[tempSex == 1, tempSex == 2],
                        onPressed: (index) {
                          setSheetState(() {
                            tempSex = index == 0 ? 1 : 2;
                          });
                          _sex = tempSex;
                        },
                        borderRadius: BorderRadius.circular(8),
                        children: const[
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('男')),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('女')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: HJSpacing.xl),
                  SizedBox(
                      width: double.infinity,
                      child: HJButton.primary(text: '保存', onPressed: () => _saveProfile(sheetCtx))
                  ),
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
    // 【修复】：从后端数据恢复 remark 备注字段解析
    final String remark = _user['remark']?.toString() ?? '';

    final String initialChar = username.isNotEmpty ? username.substring(0, 1).toUpperCase() : '?';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
          title: const Text('个人资料', style: TextStyle(color: Colors.black87, fontSize: 18)),
          backgroundColor: Colors.grey[50],
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87)
      ),
      body: UIStateHandler(
        state: _state,
        onRetry: _fetchProfile,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: HJSpacing.xl),
          child: Column(
            children:[
              Container(
                margin: const EdgeInsets.all(HJSpacing.md),
                padding: const EdgeInsets.all(HJSpacing.lg),
                decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children:[
                    CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: Text(initialChar, style: TextStyle(fontSize: 28, color: Theme.of(context).primaryColor))
                    ),
                    const SizedBox(width: HJSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                          Text(nickname, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(roleName, style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: _openEditSheet),
                  ],
                ),
              ),
              SectionCard(
                title: '详细信息',
                items:[
                  HJListItem.value(icon: Icons.wc_outlined, title: '性别', valueText: _sex == 1 ? '男' : (_sex == 2 ? '女' : '未知'), onTap: () {}),
                  HJListItem.value(icon: Icons.phone_iphone, title: '手机号', valueText: phoneNumber, onTap: () {}),
                  HJListItem.value(icon: Icons.email_outlined, title: '邮箱', valueText: email, onTap: () {}),
                ],
              ),
              // 【修复】：找回了账号、角色、备注，将其放置在系统记录模块中
              SectionCard(
                title: '系统记录',
                items:[
                  HJListItem.value(icon: Icons.person_outline, title: '账号', valueText: username, onTap: () {}),
                  // HJListItem.value(icon: Icons.verified_user_outlined, title: '角色', valueText: roleName, onTap: () {}),
                  HJListItem.value(icon: Icons.language, title: '登录IP', valueText: loginIp, onTap: () {}),
                  HJListItem.value(icon: Icons.access_time, title: '登录时间', valueText: loginDate, onTap: () {}),
                  if (remark.isNotEmpty)
                    HJListItem.value(icon: Icons.note_outlined, title: '备注', valueText: remark, onTap: () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}