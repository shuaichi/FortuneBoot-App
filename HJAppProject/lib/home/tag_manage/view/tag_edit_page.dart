import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';
import '../data/tag_service.dart';
import '../model/tag_node.dart';

class TagEditPage extends StatefulWidget {
  final int tagId;
  final String name;
  final bool enable;
  final int sort;
  final String? remark;
  final bool canExpense;
  final bool canIncome;
  final bool canTransfer;
  final int parentId;
  final int bookId;
  final String? parentName;

  const TagEditPage({
    Key? key,
    required this.tagId,
    required this.name,
    required this.enable,
    required this.sort,
    this.remark,
    required this.canExpense,
    required this.canIncome,
    required this.canTransfer,
    required this.parentId,
    required this.bookId,
    this.parentName,
  }) : super(key: key);

  @override
  State<TagEditPage> createState() => _TagEditPageState();
}

class _TagEditPageState extends State<TagEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _sortController;
  late final TextEditingController _remarkController;

  late bool _enable;
  late bool _canExpense;
  late bool _canIncome;
  late bool _canTransfer;
  late int _parentId;

  bool _saving = false;
  bool _dirty = false;

  late final Map<String, dynamic> _initial;

  final TagPageService _service = TagPageService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _sortController = TextEditingController(text: widget.sort.toString());
    _remarkController = TextEditingController(text: widget.remark ?? '');
    
    _enable = widget.enable;
    _canExpense = widget.canExpense;
    _canIncome = widget.canIncome;
    _canTransfer = widget.canTransfer;
    _parentId = widget.parentId;

    _initial = {
      'name': widget.name,
      'sort': widget.sort.toString(),
      'remark': widget.remark ?? '',
      'enable': widget.enable,
      'canExpense': widget.canExpense,
      'canIncome': widget.canIncome,
      'canTransfer': widget.canTransfer,
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
      'canExpense': _canExpense,
      'canIncome': _canIncome,
      'canTransfer': _canTransfer,
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

  Future<String> _loadParentName(int parentId) async {
    if (parentId == -1) return '根标签 (一级标签)';
    
    // Use widget's parentName if available and matching ID, to avoid fetch
    if (widget.parentId == parentId && widget.parentName != null) {
      return widget.parentName!;
    }
    
    final bookId = context.read<BillsRepository>().bookId() ?? 1;
    final roots = await _service.fetchList(
      bookId: bookId,
      recycleBin: false,
    );

    String? _findNameById(List<TagNode> nodes, int id) {
      for (final n in nodes) {
        if (n.id == id) return n.tagName;
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
      await _service.modifyTag(
        enable: _enable,
        tagId: widget.tagId,
        tagName: _nameController.text.trim(),
        bookId: widget.bookId,
        parentId: _parentId,
        sort: _sortController.text.trim().isEmpty ? widget.sort : int.parse(_sortController.text.trim()),
        remark: _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim(),
        canExpense: _canExpense,
        canIncome: _canIncome,
        canTransfer: _canTransfer,
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
          title: const Text(
            '编辑标签',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                      // Parent Info Card (Read Only)
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
                              '父级标签',
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
                                future: _loadParentName(_parentId),
                                builder: (context, snapshot) {
                                  final text = snapshot.hasData ? snapshot.data! : '加载中...';
                                  return Text(
                                    _parentId == -1 ? '根标签 (一级标签)' : text,
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
                              label: '标签名称',
                              hint: '请输入标签名称',
                              maxLength: 32,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _sortController,
                              label: '排序',
                              hint: '数字越小越靠前',
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tag Settings Card
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
                              '标签设置',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            _buildSwitchTile(
                              title: '启用',
                              value: _enable,
                              onChanged: (v) {
                                setState(() => _enable = v);
                                _computeDirty();
                              },
                            ),
                            const Divider(height: 1),
                            _buildSwitchTile(
                              title: '可支出',
                              value: _canExpense,
                              onChanged: (v) {
                                setState(() => _canExpense = v);
                                _computeDirty();
                              },
                            ),
                            const Divider(height: 1),
                            _buildSwitchTile(
                              title: '可收入',
                              value: _canIncome,
                              onChanged: (v) {
                                setState(() => _canIncome = v);
                                _computeDirty();
                              },
                            ),
                            const Divider(height: 1),
                            _buildSwitchTile(
                              title: '可转账',
                              value: _canTransfer,
                              onChanged: (v) {
                                setState(() => _canTransfer = v);
                                _computeDirty();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Remark Card
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
                              '备注',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _remarkController,
                              maxLines: 3,
                              maxLength: 200,
                              decoration: InputDecoration(
                                hintText: '选填，备注信息',
                                hintStyle: const TextStyle(fontSize: 15, color: Colors.black26),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Save Button Area
            Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          '保存',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 15, color: Colors.black26),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            counterText: "",
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 15, color: Colors.black87)),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}