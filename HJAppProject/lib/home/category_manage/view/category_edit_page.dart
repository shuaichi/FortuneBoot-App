import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hjproject/Home/category_manage/data/category_service.dart';
import 'parent_category_select_page.dart';

class CategoryEditPage extends StatefulWidget {
  final int categoryId;
  final String name;
  final bool enable;
  final int sort;
  final String? remark;
  final int categoryType; // 1: 支出, 2: 收入
  final int parentId;
  final int bookId;

  const CategoryEditPage({
    Key? key,
    required this.categoryId,
    required this.name,
    required this.enable,
    required this.sort,
    required this.remark,
    required this.categoryType,
    required this.parentId,
    required this.bookId,
  }) : super(key: key);

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _sortController;
  late final TextEditingController _remarkController;

  late bool _enable;
  late int _parentId;

  bool _saving = false;
  bool _dirty = false;

  late final Map<String, dynamic> _initial;

  final CategoryPageService _service = CategoryPageService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _sortController = TextEditingController(text: widget.sort.toString());
    _remarkController = TextEditingController(text: widget.remark ?? '');
    _enable = widget.enable;
    _parentId = widget.parentId;

    _initial = {
      'name': widget.name,
      'sort': widget.sort.toString(),
      'remark': widget.remark ?? '',
      'enable': widget.enable,
      'parentId': widget.parentId,
    };

    void listener() => _computeDirty();
    _nameController.addListener(listener);
    _sortController.addListener(listener);
    _remarkController.addListener(listener);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sortController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _computeDirty() {
    final now = {
      'name': _nameController.text,
      'sort': _sortController.text,
      'remark': _remarkController.text,
      'enable': _enable,
      'parentId': _parentId,
    };
    final changed = now.entries.any((e) => _initial[e.key] != e.value);
    if (_dirty != changed) {
      setState(() {
        _dirty = changed;
      });
    }
  }

  bool get _isValid {
    final name = _nameController.text.trim();
    if (name.isEmpty || name.length > 32) return false;
    final sortText = _sortController.text.trim();
    if (sortText.isNotEmpty) {
      final sort = int.tryParse(sortText);
      if (sort == null || sort < 0) return false;
    }
    final remark = _remarkController.text;
    if (remark.isNotEmpty && remark.length > 200) return false;
    return true;
  }

  Future<String> _loadParentName(int parentId, int categoryType) async {
    if (parentId == -1) return '根分类';
    final roots = await _service.fetchList(
      bookId: widget.bookId,
      categoryType: categoryType,
      recycleBin: false,
    );
    String? _findNameById(List<CategoryNode> nodes, int id) {
      for (final n in nodes) {
        if (n.id == id) return n.categoryName;
        final found = _findNameById(n.children, id);
        if (found != null) return found;
      }
      return null;
    }

    final name = _findNameById(roots, parentId);
    return name ?? '未知';
  }

  Future<void> _onSave() async {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请检查表单填写是否正确'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await _service.modifyCategory(
        enable: _enable,
        categoryId: widget.categoryId,
        categoryName: _nameController.text.trim(),
        categoryType: widget.categoryType,
        bookId: widget.bookId,
        parentId: _parentId,
        sort: _sortController.text.trim().isEmpty
            ? widget.sort
            : int.parse(_sortController.text.trim()),
        remark: _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim(),
        recycleBin: false,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功'), behavior: SnackBarBehavior.floating),
      );
      setState(() => _dirty = false);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _confirmLeave() async {
    if (!_dirty || _saving) return true;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('放弃更改？'),
        content: const Text('当前页面存在未保存的更改，确定要离开并丢弃这些更改吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: const Text('离开'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Design Tokens
    const Color bgColor = Color(0xFFFAFAFA);
    const double hPadding = 16.0;
    const double cardRadius = 16.0;

    return WillPopScope(
      onWillPop: _confirmLeave,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(
            '修改${widget.categoryType == 1 ? '支出' : '收入'}分类',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: bgColor,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(hPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Parent Info Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(cardRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '父级分类',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100], // Indicate read-only
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: double.infinity,
                              child: FutureBuilder<String>(
                                future: _loadParentName(_parentId, widget.categoryType),
                                builder: (context, snapshot) {
                                  final text = snapshot.hasData ? snapshot.data! : '加载中...';
                                  return Text(
                                    _parentId == -1 ? '根分类 (一级分类)' : text,
                                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Basic Info Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(cardRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '基本信息',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _nameController,
                              label: '分类名称',
                              hint: '请输入分类名称',
                              icon: Icons.label_outline,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return '请输入分类名称';
                                if (v.trim().length > 32) return '名称长度不能超过32字符';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _sortController,
                              label: '排序值',
                              hint: '默认 0，越小越靠前',
                              icon: Icons.sort,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v != null && v.trim().isNotEmpty && int.tryParse(v.trim()) == null) {
                                  return '必须是数字';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _remarkController,
                              label: '备注',
                              hint: '选填',
                              icon: Icons.note_alt_outlined,
                              maxLines: 3,
                              validator: (v) {
                                if (v != null && v.length > 200) return '备注不能超过200字';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Enable Switch Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(cardRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: SwitchListTile(
                          title: const Text('启用状态', style: TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(_enable ? '当前已启用' : '当前已禁用', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          value: _enable,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (v) {
                            setState(() => _enable = v);
                            _computeDirty();
                          },
                          secondary: Icon(_enable ? Icons.check_circle_outline : Icons.cancel_outlined, color: _enable ? Theme.of(context).primaryColor : Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom Action Bar
            Container(
              padding: EdgeInsets.fromLTRB(hPadding, 12, hPadding, MediaQuery.of(context).padding.bottom + 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _saving ? null : _onSave,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // Pill shape
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('保存修改', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
      onChanged: (_) => _computeDirty(),
    );
  }
}