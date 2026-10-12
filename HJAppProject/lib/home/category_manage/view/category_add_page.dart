import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';
import 'package:hjproject/Home/category_manage/data/category_service.dart';
import 'package:hjproject/Home/common/widgets/icon_form_field.dart';
import 'package:hjproject/util/app_icon.dart';

class CategoryAddPage extends StatefulWidget {
  final int categoryType; // 1: 支出, 2: 收入
  final int initialParentId; // -1 表示根分类

  const CategoryAddPage({
    Key? key,
    required this.categoryType,
    required this.initialParentId,
  }) : super(key: key);

  @override
  State<CategoryAddPage> createState() => _CategoryAddPageState();
}

class _CategoryAddPageState extends State<CategoryAddPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _sortController;
  late final TextEditingController _remarkController;

  late final FocusNode _nameNode;
  late final FocusNode _sortNode;
  late final FocusNode _remarkNode;

  bool _enable = true;
  bool _saving = false;
  bool _dirty = false;

  // 自定义图标名（为空表示使用默认图标）
  String? _icon;

  int _parentId = -1;

  final CategoryPageService _service = CategoryPageService();

  @override
  void initState() {
    super.initState();
    _parentId = widget.initialParentId;

    _nameController = TextEditingController();
    _sortController = TextEditingController();
    _remarkController = TextEditingController();

    _nameNode = FocusNode();
    _sortNode = FocusNode();
    _remarkNode = FocusNode();

    void markDirty() {
      setState(() {
        if (!_dirty) {
          _dirty = true;
        }
      });
    }

    _nameController.addListener(markDirty);
    _sortController.addListener(markDirty);
    _remarkController.addListener(markDirty);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sortController.dispose();
    _remarkController.dispose();
    _nameNode.dispose();
    _sortNode.dispose();
    _remarkNode.dispose();
    super.dispose();
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
    final bookId = context.read<BillsRepository>().bookId() ?? 1;
    final roots = await _service.fetchList(
      bookId: bookId,
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

  List<_ParentOption> _flattenToOptions(List<CategoryNode> nodes, {int depth = 0}) {
    final List<_ParentOption> result = [];
    for (final n in nodes) {
      final prefix = depth > 0 ? '${'—' * depth} ' : '';
      result.add(_ParentOption(id: n.id, label: '$prefix${n.categoryName}'));
      result.addAll(_flattenToOptions(n.children, depth: depth + 1));
    }
    return result;
  }

  Future<List<_ParentOption>> _fetchParentOptions() async {
    final bookId = context.read<BillsRepository>().bookId() ?? 1;
    final roots = await _service.fetchList(
      bookId: bookId,
      categoryType: widget.categoryType,
      recycleBin: false,
    );
    return _flattenToOptions(roots);
  }

  Future<void> _onSave() async {
    if (!_isValid) {
      setState(() {}); // 触发表单校验显示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请检查表单填写是否正确'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      _saving = true;
    });
    try {
      final bookId = context.read<BillsRepository>().bookId() ?? 1;
      await _service.addCategory(
        enable: _enable,
        parentId: _parentId,
        categoryName: _nameController.text.trim(),
        categoryType: widget.categoryType,
        bookId: bookId,
        sort: _sortController.text.trim().isEmpty ? 0 : int.parse(_sortController.text.trim()),
        remark: _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim(),
        icon: _icon,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('新增成功'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _dirty = false;
      });
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<bool> _confirmLeave() async {
    if (!_dirty || _saving) return true;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: cs.surface,
          surfaceTintColor: cs.surfaceTint,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cs.outlineVariant),
          ),
          title: Text('放弃更改？', style: tt.titleMedium),
          content: const Text('当前页面存在未保存的更改，确定要离开并丢弃这些更改吗？'),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('取消', style: tt.labelLarge),
            ),
            OutlinedButton(
              style: ButtonStyle(
                side: MaterialStatePropertyAll(BorderSide(color: cs.error)),
                foregroundColor: MaterialStatePropertyAll(cs.error),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('离开', style: tt.labelLarge),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: _confirmLeave,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '新增${widget.categoryType == 1 ? '支出' : '收入'}分类',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: CupertinoScrollbar(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          child: widget.initialParentId != -1
                              ? Card(
                                  color: cs.surfaceVariant,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: cs.outlineVariant),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: FutureBuilder<String>(
                                      future: _loadParentName(widget.initialParentId, widget.categoryType),
                                      builder: (context, snapshot) {
                                        final text = snapshot.hasData ? snapshot.data! : '加载中...';
                                        return Text(
                                          '父级分类：$text（已固定）',
                                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : FutureBuilder<List<_ParentOption>>(
                                  future: _fetchParentOptions(),
                                  builder: (context, snap) {
                                    final items = (snap.data ?? const <_ParentOption>[])
                                        .map((opt) => DropdownMenuItem<int>(
                                              value: opt.id,
                                              child: Text(opt.label, style: tt.bodyMedium),
                                            ))
                                        .toList();
                                    return DropdownButtonFormField<int>(
                                      value: _parentId == -1 ? null : _parentId,
                                      items: items,
                                      style: tt.bodyMedium,
                                      decoration: InputDecoration(
                                        labelText: '父级分类（可选）',
                                        hintText: '不选择则为一级分类',
                                        prefixIcon: const Icon(Icons.account_tree_outlined),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onChanged: _saving ? null : (v) => setState(() => _parentId = (v ?? -1)),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nameController,
                          focusNode: _nameNode,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: '分类名称（必填）',
                            hintText: '请输入分类名称',
                            prefixIcon: const Icon(Icons.label_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return '请输入分类名称';
                            }
                            if (v.trim().length > 32) {
                              return '名称长度不能超过32字符';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        IconFormField(
                          title: '分类图标',
                          value: _icon,
                          defaultIconName: AppIcon.categoryFallback,
                          onChanged: (v) => setState(() => _icon = v),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          dense: false,
                          contentPadding: EdgeInsets.zero,
                          title: Text('启用状态（必填）', style: tt.bodyMedium),
                          value: _enable,
                          onChanged: _saving ? null : (v) => setState(() => _enable = v),
                          secondary: const Icon(Icons.toggle_on),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _sortController,
                          focusNode: _sortNode,
                          decoration: InputDecoration(
                            labelText: '顺序（数字，可选）',
                            hintText: '请输入数字',
                            prefixIcon: const Icon(Icons.format_list_numbered),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                          validator: (v) {
                            if (v == null || v.isEmpty) return null;
                            final n = int.tryParse(v);
                            if (n == null) return '顺序需为数字';
                            if (n < 0) return '顺序不能为负数';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _remarkController,
                          focusNode: _remarkNode,
                          decoration: InputDecoration(
                            labelText: '备注（可选）',
                            hintText: '可填写备注信息',
                            prefixIcon: const Icon(Icons.notes_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          maxLines: 3,
                          validator: (v) {
                            if (v == null || v.isEmpty) return null;
                            if (v.length > 200) return '备注长度不能超过200字符';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: '保存',
          shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          onPressed: _saving || !_isValid ? null : _onSave,
          child: _saving ? const CupertinoActivityIndicator() : const Icon(Icons.check_rounded),
        ),
      ),
    );
  }
}

class _ParentOption {
  final int id;
  final String label;
  const _ParentOption({required this.id, required this.label});
}