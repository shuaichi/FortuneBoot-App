import 'package:flutter/material.dart';
import 'package:fortuneboot/home/payee_manage/data/payee_service.dart';
import 'package:fortuneboot/home/payee_manage/model/payee.dart';

class PayeeEditPage extends StatefulWidget {
  final Payee payee;
  final int bookId;

  const PayeeEditPage({
    Key? key,
    required this.payee,
    required this.bookId,
  }) : super(key: key);

  @override
  State<PayeeEditPage> createState() => _PayeeEditPageState();
}

class _PayeeEditPageState extends State<PayeeEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _sortController;
  late final TextEditingController _remarkController;

  late bool _canExpense;
  late bool _canIncome;
  late bool _enable;

  bool _saving = false;
  bool _dirty = false;
  late final Map<String, dynamic> _initial;

  final PayeeService _service = PayeeService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.payee.payeeName);
    _sortController = TextEditingController(text: (widget.payee.sort ?? 0).toString());
    _remarkController = TextEditingController(text: widget.payee.remark ?? '');
    
    _canExpense = widget.payee.canExpense;
    _canIncome = widget.payee.canIncome;
    _enable = widget.payee.enable;

    _initial = {
      'name': widget.payee.payeeName,
      'sort': (widget.payee.sort ?? 0).toString(),
      'remark': widget.payee.remark ?? '',
      'canExpense': widget.payee.canExpense,
      'canIncome': widget.payee.canIncome,
      'enable': widget.payee.enable,
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
      'canExpense': _canExpense,
      'canIncome': _canIncome,
      'enable': _enable,
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
    if (!_canExpense && !_canIncome) return false;
    return true;
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
      await _service.modify(
        payeeId: widget.payee.payeeId,
        bookId: widget.bookId,
        payeeName: _nameController.text.trim(),
        canExpense: _canExpense,
        canIncome: _canIncome,
        enable: _enable,
        sort: _sortController.text.trim().isEmpty ? 0 : int.parse(_sortController.text.trim()),
        remark: _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim(),
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
            '修改交易对象',
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
                              label: '名称',
                              hint: '请输入交易对象名称',
                              maxLength: 32,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '支出状态',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                Switch.adaptive(
                                  value: _canExpense,
                                  onChanged: (v) {
                                    setState(() {
                                      _canExpense = v;
                                    });
                                    _computeDirty();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '收入状态',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                Switch.adaptive(
                                  value: _canIncome,
                                  onChanged: (v) {
                                    setState(() {
                                      _canIncome = v;
                                    });
                                    _computeDirty();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '启用状态',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                Switch.adaptive(
                                  value: _enable,
                                  onChanged: (v) {
                                    setState(() {
                                      _enable = v;
                                    });
                                    _computeDirty();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Optional Info Card
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
                              '选填信息',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _sortController,
                              label: '排序值',
                              hint: '越小越靠前 (默认0)',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _remarkController,
                              label: '备注',
                              hint: '选填',
                              maxLength: 200,
                              maxLines: 3,
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
            
            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
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
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('保存', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    String? hint,
    int? maxLength,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
            ),
            counterText: '',
          ),
          style: const TextStyle(fontSize: 15),
          maxLength: maxLength,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textInputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}