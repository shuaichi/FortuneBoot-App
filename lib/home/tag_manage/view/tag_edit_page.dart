import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/repository/repository/bills_repository.dart';
import 'package:fortuneboot/home/design_system/hjds_theme.dart';
import 'package:fortuneboot/home/design_system/hjds_components.dart';

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
  String _parentNameDisplay = '加载中...';
  bool _showAdvancedOptions = false;

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

    void listener() => _computeDirty();
    _nameController.addListener(listener);
    _sortController.addListener(listener);
    _remarkController.addListener(listener);

    _initParentName();
  }

  Future<void> _initParentName() async {
    try {
      final name = await _loadParentName(_parentId);
      if (mounted) setState(() => _parentNameDisplay = name);
    } catch (e) {
      if (mounted) setState(() => _parentNameDisplay = '未知');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sortController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _computeDirty() {
    final changed = _nameController.text != widget.name ||
        _sortController.text != widget.sort.toString() ||
        _remarkController.text != (widget.remark ?? '') ||
        _enable != widget.enable ||
        _canExpense != widget.canExpense ||
        _canIncome != widget.canIncome ||
        _canTransfer != widget.canTransfer;

    if (_dirty != changed) {
      setState(() => _dirty = changed);
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
    if (widget.parentId == parentId && widget.parentName != null) {
      return widget.parentName!;
    }
    final bookId = context.read<BillsRepository>().bookId() ?? 1;
    final roots = await _service.fetchList(bookId: bookId, recycleBin: false);

    String? findNameById(List<TagNode> nodes, int id) {
      for (final n in nodes) {
        if (n.id == id) return n.tagName;
        final found = findNameById(n.children, id);
        if (found != null) return found;
      }
      return null;
    }
    return findNameById(roots, parentId) ?? '未知';
  }

  Future<void> _onSave() async {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请检查表单填写是否正确'),
          backgroundColor: HJColors.expense,
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
        const SnackBar(
            content: Text('保存成功'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: HJColors.income
        ),
      );
      setState(() => _dirty = false);
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: HJColors.expense,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _confirmLeave() async {
    if (!_dirty || _saving) return true;
    HapticFeedback.lightImpact();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => HJDialog(
        title: '放弃更改？',
        headerIcon: Icons.warning_amber_rounded,
        headerIconColor: HJColors.expense,
        content: const Text(
            '当前页面存在未保存的更改，确定要离开吗？',
            style: TextStyle(color: HJColors.textSecondary, height: 1.5)
        ),
        secondaryAction: HJButton.secondary(text: '取消', onPressed: () => Navigator.pop(ctx, false)),
        primaryAction: HJButton.critical(text: '离开', onPressed: () => Navigator.pop(ctx, true)),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldLeave = await _confirmLeave();
        if (shouldLeave && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: HJColors.background,
        appBar: AppBar(
          title: const Text('修改标签', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: HJColors.textPrimary)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: HJColors.background,
          iconTheme: const IconThemeData(color: HJColors.textPrimary),
        ),
        body: Column(
          children:[
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: HJSpacing.md, vertical: HJSpacing.sm),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children:[
                      HJPremiumCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            const Text('层级关系 (只读)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: HJColors.textSecondary)),
                            const SizedBox(height: HJSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: HJSpacing.md, vertical: 14),
                              decoration: BoxDecoration(color: HJColors.background, borderRadius: BorderRadius.circular(16)),
                              child: Row(
                                children:[
                                  const Icon(Icons.lock_outline, size: 18, color: HJColors.textSecondary),
                                  const SizedBox(width: HJSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      _parentId == -1 ? '根标签 (一级标签)' : _parentNameDisplay,
                                      style: const TextStyle(fontSize: 16, color: HJColors.textSecondary, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Padding(padding: EdgeInsets.symmetric(vertical: HJSpacing.md), child: Divider(height: 1, thickness: 0.5, color: HJColors.divider)),
                            const Text('标签名称', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: HJColors.textSecondary)),
                            const SizedBox(height: HJSpacing.sm),
                            HJCustomTextField(
                              controller: _nameController,
                              hint: '例如：餐饮、交通...',
                              maxLength: 32,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: HJSpacing.md),

                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _showAdvancedOptions = !_showAdvancedOptions);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: HJSpacing.sm),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:[
                              Text(
                                _showAdvancedOptions ? '收起高级设置' : '展开高级设置',
                                style: const TextStyle(color: HJColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              const SizedBox(width: HJSpacing.xs),
                              AnimatedRotation(
                                turns: _showAdvancedOptions ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: const Icon(Icons.keyboard_arrow_down, color: HJColors.primary, size: 18),
                              ),
                            ],
                          ),
                        ),
                      ),

                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        child: !_showAdvancedOptions ? const SizedBox.shrink() : Column(
                          children:[
                            const SizedBox(height: HJSpacing.sm),
                            HJPremiumCard(
                              child: Column(
                                children:[
                                  HJSwitchRow(title: '启用此标签', value: _enable, onChanged: (v) { setState(() => _enable = v); _computeDirty(); }),
                                  const Divider(height: 1, thickness: 0.5, color: HJColors.divider),
                                  HJSwitchRow(title: '允许作为支出', value: _canExpense, activeColor: HJColors.expense, onChanged: (v) { setState(() => _canExpense = v); _computeDirty(); }),
                                  const Divider(height: 1, thickness: 0.5, color: HJColors.divider),
                                  HJSwitchRow(title: '允许作为收入', value: _canIncome, activeColor: HJColors.income, onChanged: (v) { setState(() => _canIncome = v); _computeDirty(); }),
                                  const Divider(height: 1, thickness: 0.5, color: HJColors.divider),
                                  HJSwitchRow(title: '允许作为转账', value: _canTransfer, activeColor: HJColors.primary, onChanged: (v) { setState(() => _canTransfer = v); _computeDirty(); }),
                                ],
                              ),
                            ),
                            const SizedBox(height: HJSpacing.md),
                            HJPremiumCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:[
                                  const Text('排序权重', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: HJColors.textSecondary)),
                                  const SizedBox(height: HJSpacing.sm),
                                  HJCustomTextField(
                                    controller: _sortController,
                                    hint: '数字越小越靠前',
                                    keyboardType: TextInputType.number,
                                    inputFormatters:[FilteringTextInputFormatter.digitsOnly],
                                  ),
                                  const SizedBox(height: HJSpacing.md),
                                  const Text('备注信息', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: HJColors.textSecondary)),
                                  const SizedBox(height: HJSpacing.sm),
                                  HJCustomTextField(
                                    controller: _remarkController,
                                    hint: '选填，输入详细备注',
                                    maxLines: 3,
                                    maxLength: 200,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: HJSpacing.xl),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(HJSpacing.md, HJSpacing.md, HJSpacing.md, HJSpacing.md + MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: HJColors.surface,
                boxShadow:[
                  BoxShadow(color: Colors.black.withOpacity(0.03), offset: const Offset(0, -4), blurRadius: 16),
                ],
              ),
              child: HJSubmitButton(
                text: '保存修改',
                isLoading: _saving,
                onPressed: _onSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}