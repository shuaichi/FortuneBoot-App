import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../data/tag_service.dart';
import 'package:hjproject/Home/common/widgets/icon_form_field.dart';
import 'package:hjproject/util/app_icon.dart';

class TagAddPage extends StatefulWidget {
  final int initialParentId;
  final int bookId;
  final String? initialParentName;

  const TagAddPage({
    Key? key,
    required this.initialParentId,
    required this.bookId,
    this.initialParentName,
  }) : super(key: key);

  @override
  State<TagAddPage> createState() => _TagAddPageState();
}

class _TagAddPageState extends State<TagAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sortController = TextEditingController(text: '100');
  final _remarkController = TextEditingController();
  
  bool _enable = true;
  bool _canExpense = true;
  bool _canIncome = true;
  bool _canTransfer = true;
  bool _isLoading = false;
  bool _dirty = false;
  String? _parentTagName;

  /// 自定义图标名（Iconify 名称），为空表示使用默认图标
  String? _icon;

  final TagPageService _service = TagPageService();

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

  void _markDirty() {
    if (!_dirty) {
      setState(() {
        _dirty = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_markDirty);
    _sortController.addListener(_markDirty);
    _remarkController.addListener(_markDirty);
    
    // 如果是添加子标签，显示父标签名称（来自树结构）
    if (widget.initialParentId != -1) {
      _loadParentTagName();
    }
  }

  Future<void> _loadParentTagName() async {
    // 复用树结构传入的父标签名称，避免新增接口
    setState(() {
      _parentTagName = widget.initialParentName;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sortController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialParentId == -1 ? '新增标签' : '新增子标签',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 16),
                if (widget.initialParentId != -1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '添加子标签',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_parentTagName != null)
                              Text(
                                '父标签: $_parentTagName',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            Text(
                              '将作为子标签添加到上述父标签下',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (widget.initialParentId != -1) const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '基本信息',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: '标签名称',
                              border: OutlineInputBorder(),
                              hintText: '请输入标签名称',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '请输入标签名称';
                              }
                              if (value.trim().length > 32) {
                                return '标签名称不能超过32个字符';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          IconFormField(
                            title: '标签图标',
                            subtitle: '未设置时显示默认图标',
                            value: _icon,
                            defaultIconName: AppIcon.tagFallback,
                            enabled: !_isLoading,
                            onChanged: (v) {
                              setState(() => _icon = v);
                              _markDirty();
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _sortController,
                            decoration: const InputDecoration(
                              labelText: '排序',
                              border: OutlineInputBorder(),
                              helperText: '数字越小排序越靠前',
                              hintText: '请输入排序数字',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '请输入排序数字';
                              }
                              final sort = int.tryParse(value.trim());
                              if (sort == null || sort < 0) {
                                return '请输入有效的排序数字';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 0),
                          // 备注字段已移至表单底部（复用“交易对象管理”文案与样式）
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '标签设置',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('启用'),
                            subtitle: const Text('是否启用此标签'),
                            value: _enable,
                            onChanged: (value) {
                              setState(() {
                                _enable = value;
                                _markDirty();
                              });
                            },
                          ),
                          const Divider(),
                          SwitchListTile(
                            title: const Text('可支出'),
                            subtitle: const Text('是否可用于支出记录'),
                            value: _canExpense,
                            onChanged: (value) {
                              setState(() {
                                _canExpense = value;
                                _markDirty();
                              });
                            },
                          ),
                          const Divider(),
                          SwitchListTile(
                            title: const Text('可收入'),
                            subtitle: const Text('是否可用于收入记录'),
                            value: _canIncome,
                            onChanged: (value) {
                              setState(() {
                                _canIncome = value;
                                _markDirty();
                              });
                            },
                          ),
                          const Divider(),
                          SwitchListTile(
                            title: const Text('可转账'),
                            subtitle: const Text('是否可用于转账记录'),
                            value: _canTransfer,
                            onChanged: (value) {
                              setState(() {
                                _canTransfer = value;
                                _markDirty();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '备注',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _remarkController,
                            decoration: const InputDecoration(
                              labelText: '备注',
                              hintText: '可选，最长200个字符',
                              prefixIcon: Icon(Icons.note),
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
                            validator: (value) {
                              if (value != null && value.length > 200) {
                                return '备注长度不能超过200';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '保存',
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        onPressed: _isLoading || !_isValid ? null : _handleSave,
        child: _isLoading
            ? const CupertinoActivityIndicator()
            : const Icon(Icons.check_rounded),
      ),
    );
  }

  Future<void> _handleSave() async {
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

    setState(() => _isLoading = true);
    try {
      await _service.addTag(
        enable: _enable,
        parentId: widget.initialParentId,
        tagName: _nameController.text.trim(),
        bookId: widget.bookId,
        sort: _sortController.text.trim().isEmpty
            ? 100
            : int.parse(_sortController.text.trim()),
        canExpense: _canExpense,
        canIncome: _canIncome,
        canTransfer: _canTransfer,
        remark: _remarkController.text.trim().isEmpty
            ? null
            : _remarkController.text.trim(),
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
        setState(() => _isLoading = false);
      }
    }
  }
}