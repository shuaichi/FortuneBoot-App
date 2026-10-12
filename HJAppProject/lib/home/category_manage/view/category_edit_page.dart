import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hjproject/Home/category_manage/data/category_service.dart';
import 'package:hjproject/Home/common/widgets/icon_form_field.dart';
import 'package:hjproject/util/app_icon.dart';

class CategoryEditPage extends StatefulWidget {
  final int categoryId;
  final String name;
  final bool enable;
  final int sort;
  final String? remark;
  final int categoryType; // 1: 支出, 2: 收入
  final int parentId;
  final int bookId;
  final String? icon;

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
    this.icon,
  }) : super(key: key);

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _sortController;
  late final TextEditingController _remarkController;

  late final FocusNode _nameNode;
  late final FocusNode _sortNode;
  late final FocusNode _remarkNode;

  late bool _enable;

  /// 自定义图标名（Iconify 名称），为空表示使用默认图标
  String? _icon;

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
    _icon = widget.icon;

    _nameNode = FocusNode();
    _sortNode = FocusNode();
    _remarkNode = FocusNode();

    _initial = {
      'name': widget.name,
      'sort': widget.sort.toString(),
      'remark': widget.remark ?? '',
      'enable': widget.enable,
      'icon': widget.icon,
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
    _nameNode.dispose();
    _sortNode.dispose();
    _remarkNode.dispose();
    super.dispose();
  }

  void _computeDirty() {
    final now = {
      'name': _nameController.text,
      'sort': _sortController.text,
      'remark': _remarkController.text,
      'enable': _enable,
      'icon': _icon,
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
      await _service.modifyCategory(
        enable: _enable,
        categoryId: widget.categoryId,
        categoryName: _nameController.text.trim(),
        categoryType: widget.categoryType,
        bookId: widget.bookId,
        parentId: widget.parentId,
        sort: _sortController.text.trim().isEmpty
            ? widget.sort
            : int.parse(_sortController.text.trim()),
        remark: _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim(),
        recycleBin: false,
        icon: _icon,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('保存成功'),
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
            '修改${widget.categoryType == 1 ? '支出' : '收入'}分类',
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
                        Card(
                          color: cs.surfaceVariant,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: cs.outlineVariant),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: FutureBuilder<String>(
                              future: _loadParentName(widget.parentId, widget.categoryType),
                              builder: (context, snapshot) {
                                final text = snapshot.hasData ? snapshot.data! : '加载中...';
                                return Text(
                                  '父级分类：$text',
                                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                );
                              },
                            ),
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
                          onChanged: (_) => _computeDirty(),
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
                          subtitle: '未设置时显示默认图标',
                          value: _icon,
                          defaultIconName: AppIcon.categoryFallback,
                          enabled: !_saving,
                          onChanged: (v) {
                            setState(() {
                              _icon = v;
                            });
                            _computeDirty();
                          },
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          dense: false,
                          contentPadding: EdgeInsets.zero,
                          title: Text('启用状态（必填）', style: tt.bodyMedium),
                          value: _enable,
                          onChanged: _saving
                              ? null
                              : (v) {
                                  setState(() {
                                    _enable = v;
                                  });
                                  _computeDirty();
                                },
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
                          onChanged: (_) => _computeDirty(),
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
                          onChanged: (_) => _computeDirty(),
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