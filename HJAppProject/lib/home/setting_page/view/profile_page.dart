import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' show Options, Headers;
import 'package:hjproject/util/dio_client.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  bool _saving = false;
  bool _editing = false;
  Map<String, dynamic>? _user;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  int _sex = 0;

  @override
  void initState() {
    super.initState();
    _nicknameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
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
    setState(() { _loading = true; });
    try {
      final dio = DioClient().dio;
      final res = await dio.get('/system/user/profile');
      final data = Map<String, dynamic>.from(res.data as Map);
      if ((data['code'] as int? ?? -1) == 0) {
        final d = Map<String, dynamic>.from(data['data'] as Map? ?? {});
        final user = Map<String, dynamic>.from(d['user'] as Map? ?? {});
        _user = user;
        _nicknameCtrl.text = user['nickname']?.toString() ?? '';
        _emailCtrl.text = user['email']?.toString() ?? '';
        _phoneCtrl.text = user['phoneNumber']?.toString() ?? '';
        _sex = (user['sex'] as int?) ?? 0;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['msg']?.toString() ?? '加载失败')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('网络错误: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _loading = false; });
      }
    }
  }

  String _composeAvatarUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final base = DioClient().dio.options.baseUrl;
    if (base.isEmpty) return path;
    if (base.endsWith('/') && path.startsWith('/')) {
      return base.substring(0, base.length - 1) + path;
    } else if (!base.endsWith('/') && !path.startsWith('/')) {
      return '$base/$path';
    }
    return '$base$path';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; });
    try {
      final dio = DioClient().dio;
      final body = {
        'nickname': _nicknameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'sex': _sex,
      };
      final res = await dio.put(
        '/system/user/profile',
        data: jsonEncode(body),
        options: Options(contentType: Headers.jsonContentType),
      );
      final data = Map<String, dynamic>.from(res.data as Map);
      if ((data['code'] as int? ?? -1) == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('保存成功')),
          );
          setState(() {
            _editing = false;
          });
        }
        await _fetchProfile();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['msg']?.toString() ?? '保存失败')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('网络错误: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _saving = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人资料'),
        actions: [
          if (!_editing)
            TextButton(
              onPressed: _saving
                  ? null
                  : () {
                      setState(() {
                        _editing = true;
                      });
                    },
              child: const Text('修改', style: TextStyle(color: Colors.white)),
            )
          else
            TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator())
        : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final user = _user ?? {};
    final username = user['username']?.toString() ?? '';
    final roleName = (user['roleName'] ?? user['role_name'] ?? '').toString();
    final avatarUrl = _composeAvatarUrl(user['avatar']?.toString());
    final loginIp = user['loginIp']?.toString() ?? '';
    final loginDate = user['loginDate']?.toString() ?? '';
    final remark = user['remark']?.toString() ?? '';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.primaryColor,
                theme.primaryColor.withOpacity(0.8),
              ]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  backgroundImage: (avatarUrl.isNotEmpty)
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: (avatarUrl.isEmpty)
                      ? Text(
                          (username.isNotEmpty ? username[0].toUpperCase() : '?'),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['nickname']?.toString().isNotEmpty == true
                            ? user['nickname'].toString()
                            : username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        roleName.isEmpty ? '用户' : roleName,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildEditableCard(),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildReadonlyCard(username, roleName, loginIp, loginDate, remark),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEditableCard() {
    final nickname = _nicknameCtrl.text;
    final email = _emailCtrl.text;
    final phone = _phoneCtrl.text;
    final sexText = _sex == 1 ? '男' : _sex == 2 ? '女' : '未知';

    // 只读态：使用只读信息块样式，和账号/角色等一致
    if (!_editing) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _kv('昵称', nickname.isEmpty ? '—' : nickname, Icons.badge_outlined),
              const Divider(height: 16),
              _kv('邮箱', email.isEmpty ? '—' : email, Icons.email_outlined),
              const Divider(height: 16),
              _kv('手机号', phone.isEmpty ? '—' : phone, Icons.phone_iphone),
              const Divider(height: 16),
              _kv('性别', sexText, Icons.wc_outlined),
            ],
          ),
        ),
      );
    }

    //修改态：显示输入框与性别切换
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nicknameCtrl,
                decoration: const InputDecoration(
                  labelText: '昵称',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return '昵称不能为空';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: '邮箱',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailReg.hasMatch(v)) return '邮箱格式不正确';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '手机号',
                  prefixIcon: Icon(Icons.phone_iphone),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.wc_outlined, color: Colors.grey),
                  const SizedBox(width: 12),
                  const Text('性别'),
                  const Spacer(),
                  ToggleButtons(
                    // 第一个按钮对应男(1)，第二个按钮对应女(2)
                    isSelected: [_sex == 1, _sex == 2],
                    onPressed: (index) {
                      setState(() {
                        // index=0时设为1(男)，index=1时设为2(女)
                        _sex = index == 0 ? 1 : 2;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('男'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('女'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadonlyCard(String username, String roleName, String ip, String date, String remark) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _kv('账号', username, Icons.person_outline),
            const Divider(height: 16),
            _kv('角色', roleName.isEmpty ? '—' : roleName, Icons.verified_user_outlined),
            const Divider(height: 16),
            _kv('登录IP', ip.isEmpty ? '—' : ip, Icons.language_outlined),
            const Divider(height: 16),
            _kv('登录时间', date.isEmpty ? '—' : date, Icons.access_time),
            if (remark.isNotEmpty) ...[
              const Divider(height: 16),
              _kv('备注', remark, Icons.note_outlined),
            ]
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(k, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(v, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
