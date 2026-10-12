import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hjproject/home/payee_manage/model/payee.dart';
import 'package:hjproject/home/payee_manage/data/payee_service.dart';
import 'package:hjproject/home/payee_manage/constants/design_system.dart' as ds;
import 'package:hjproject/Home/common/widgets/icon_form_field.dart';
import 'package:hjproject/util/app_icon.dart';

/// 增强版交易对象编辑页面
/// 基于设计系统重构，提供现代化的用户体验和一致的视觉设计
class EnhancedPayeeEditPage extends StatefulWidget {
  final Payee payee;
  final int bookId;
  
  const EnhancedPayeeEditPage({
    Key? key,
    required this.payee,
    required this.bookId,
  }) : super(key: key);

  @override
  State<EnhancedPayeeEditPage> createState() => _EnhancedPayeeEditPageState();
}

class _EnhancedPayeeEditPageState extends State<EnhancedPayeeEditPage>
    with TickerProviderStateMixin {
  
  // 动画控制器
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // 表单控制器
  late final TextEditingController _nameController;
  late final TextEditingController _sortController;
  late final TextEditingController _remarkController;

  // 焦点节点
  late final FocusNode _nameNode;
  late final FocusNode _sortNode;
  late final FocusNode _remarkNode;

  // 状态变量
  late bool _canExpense;
  late bool _canIncome;
  late bool _enable;

  // 自定义图标名（为空表示使用默认图标）
  String? _icon;

  // UI状态
  bool _saving = false;
  bool _dirty = false;
  String? _errorMessage;

  // 初始数据用于脏数据检测
  late final Map<String, dynamic> _initialData;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initControllers();
    _loadPayeeData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: ds.Durations.normal,
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: ds.Durations.fast,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: ds.AnimationCurves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: ds.AnimationCurves.easeOut,
    ));

    // 启动动画
    _fadeController.forward();
    _scaleController.forward();
  }

  void _initControllers() {
    _nameController = TextEditingController();
    _sortController = TextEditingController();
    _remarkController = TextEditingController();
    
    _nameNode = FocusNode();
    _sortNode = FocusNode();
    _remarkNode = FocusNode();

    // 添加监听器检测变化
    _nameController.addListener(_computeDirty);
    _sortController.addListener(_computeDirty);
    _remarkController.addListener(_computeDirty);
  }

  void _loadPayeeData() {
    final payee = widget.payee;
    
    _nameController.text = payee.payeeName;
    _sortController.text = payee.sort?.toString() ?? '';
    _remarkController.text = payee.remark ?? '';
    
    _canExpense = payee.canExpense;
    _canIncome = payee.canIncome;
    _enable = payee.enable;
    _icon = payee.icon;

    // 保存初始数据
    _initialData = {
      'name': payee.payeeName,
      'sort': payee.sort?.toString() ?? '',
      'remark': payee.remark ?? '',
      'canExpense': payee.canExpense,
      'canIncome': payee.canIncome,
      'enable': payee.enable,
      'icon': payee.icon,
    };
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _nameController.dispose();
    _sortController.dispose();
    _remarkController.dispose();
    _nameNode.dispose();
    _sortNode.dispose();
    _remarkNode.dispose();
    super.dispose();
  }

  void _computeDirty() {
    final currentData = {
      'name': _nameController.text,
      'sort': _sortController.text,
      'remark': _remarkController.text,
      'canExpense': _canExpense,
      'canIncome': _canIncome,
      'enable': _enable,
      'icon': _icon,
    };
    
    final isDirty = currentData.entries.any((entry) => 
        _initialData[entry.key] != entry.value);
    
    if (_dirty != isDirty) {
      setState(() {
        _dirty = isDirty;
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

  Future<void> _onSave() async {
    if (!_isValid) {
      _showErrorMessage('请检查表单填写是否正确');
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      await PayeeService().modify(
        payeeId: widget.payee.payeeId,
        bookId: widget.bookId,
        payeeName: _nameController.text.trim(),
        sort: _sortController.text.trim().isEmpty
            ? null
            : int.parse(_sortController.text.trim()),
        canExpense: _canExpense,
        canIncome: _canIncome,
        enable: _enable,
        remark: _remarkController.text.trim().isEmpty 
            ? null 
            : _remarkController.text.trim(),
        icon: _icon,
      );

      if (!mounted) return;

      // 显示成功消息
      _showSuccessMessage('保存成功');
      
      // 更新脏数据状态
      setState(() {
        _dirty = false;
      });

      // 延迟返回以显示成功消息
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: ds.PayeeColors.incomeEnabled,
            ),
            SizedBox(width: ds.Spacing.sm),
            Text(message),
          ],
        ),
        backgroundColor: ds.PayeeColors.incomeEnabledLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: ds.BorderRadii.button,
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: ds.PayeeColors.expenseEnabled,
            ),
            SizedBox(width: ds.Spacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: ds.PayeeColors.expenseEnabledLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: ds.BorderRadii.button,
        ),
      ),
    );
  }

  Future<bool> _confirmLeave() async {
    if (!_dirty || _saving) return true;

    final theme = Theme.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: ds.BorderRadii.card,
        ),
        title: Text(
          '放弃更改？',
          style: ds.PayeeTextStyles.pageTitle.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          '当前页面存在未保存的更改，确定要离开并丢弃这些更改吗？',
          style: ds.PayeeTextStyles.remark.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '取消',
              style: ds.PayeeTextStyles.buttonText.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: ds.PayeeColors.expenseEnabled,
            ),
            child: Text(
              '离开',
              style: ds.PayeeTextStyles.buttonText,
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: ds.Paddings.cardMargin,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: ds.BorderRadii.card,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: ds.Shadows.elevation1,
      ),
      child: Padding(
        padding: EdgeInsets.all(ds.Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(title, subtitle),
            SizedBox(height: ds.Spacing.md),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String? subtitle) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ds.PayeeTextStyles.pageTitle.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: ds.Spacing.xs),
          Text(
            subtitle,
            style: ds.PayeeTextStyles.caption.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    String? hint,
    required IconData icon,
    bool hasError = false,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      labelText: label,
      labelStyle: ds.PayeeTextStyles.remark.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      hintStyle: ds.PayeeTextStyles.remark.copyWith(
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
      prefixIcon: Icon(
        icon,
        color: hasError
            ? ds.PayeeColors.expenseEnabled
            : theme.colorScheme.onSurfaceVariant,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: hasError 
              ? ds.PayeeColors.expenseEnabled 
              : theme.colorScheme.outline,
          width: 1,
        ),
        borderRadius: ds.BorderRadii.button,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: hasError 
              ? ds.PayeeColors.expenseEnabled 
              : ds.PayeeColors.primary,
          width: 2,
        ),
        borderRadius: ds.BorderRadii.button,
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ds.PayeeColors.expenseEnabled,
          width: 2,
        ),
        borderRadius: ds.BorderRadii.button,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ds.PayeeColors.expenseEnabled,
          width: 2,
        ),
        borderRadius: ds.BorderRadii.button,
      ),
      filled: true,
      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      contentPadding: EdgeInsets.symmetric(
        horizontal: ds.Spacing.md,
        vertical: ds.Spacing.md,
      ),
    );
  }

  Widget _buildPermissionSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(ds.Spacing.md),
      decoration: BoxDecoration(
        color: value 
            ? activeColor.withOpacity(0.1)
            : theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: ds.BorderRadii.button,
        border: Border.all(
          color: value 
              ? activeColor.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ds.Spacing.sm),
            decoration: BoxDecoration(
              color: value ? activeColor : theme.colorScheme.surfaceVariant,
              borderRadius: ds.BorderRadii.chip,
            ),
            child: Icon(
              icon,
              size: 20,
              color: value 
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(width: ds.Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ds.PayeeTextStyles.payeeName.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: ds.FontSizes.body,
                  ),
                ),
                Text(
                  subtitle,
                  style: ds.PayeeTextStyles.caption.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: _saving ? null : onChanged,
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    return PopScope(
      canPop: !_dirty || _saving,
      onPopInvoked: (didPop) async {
        if (!didPop && (_dirty && !_saving)) {
          final shouldLeave = await _confirmLeave();
          if (shouldLeave && mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 1,
          title: Text(
            '编辑交易对象',
            style: ds.PayeeTextStyles.pageTitle.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          actions: [
            if (_dirty && _isValid && !_saving)
              TextButton.icon(
                onPressed: _onSave,
                icon: Icon(
                  Icons.check,
                  size: 18,
                  color: ds.PayeeColors.incomeEnabled,
                ),
                label: Text(
                  '保存',
                  style: ds.PayeeTextStyles.buttonText.copyWith(
                    color: ds.PayeeColors.incomeEnabled,
                  ),
                ),
              ),
            SizedBox(width: ds.Spacing.sm),
          ],
        ),
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: CupertinoScrollbar(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: mediaQuery.padding.bottom + ds.Spacing.xxxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: ds.Spacing.sm),
                        
                        // 基本信息卡片
                        _buildSectionCard(
                          title: '基本信息',
                          subtitle: '设置交易对象的名称和排序',
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                focusNode: _nameNode,
                                enabled: !_saving,
                                decoration: _buildInputDecoration(
                                  label: '名称',
                                  hint: '请输入交易对象名称（必填）',
                                  icon: ds.PayeeStatusIcons.payee,
                                ),
                                maxLength: 32,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(_sortNode);
                                },
                                validator: (value) {
                                  final text = (value ?? '').trim();
                                  if (text.isEmpty) return '名称不能为空';
                                  if (text.length > 32) return '名称长度不能超过32个字符';
                                  return null;
                                },
                              ),
                              SizedBox(height: ds.Spacing.md),
                              IgnorePointer(
                                ignoring: _saving,
                                child: IconFormField(
                                  title: '交易对象图标',
                                  value: _icon,
                                  defaultIconName: AppIcon.payeeFallback,
                                  onChanged: (v) {
                                    setState(() {
                                      _icon = v;
                                    });
                                    _computeDirty();
                                  },
                                ),
                              ),
                              SizedBox(height: ds.Spacing.md),
                              TextFormField(
                                controller: _sortController,
                                focusNode: _sortNode,
                                enabled: !_saving,
                                decoration: _buildInputDecoration(
                                  label: '排序',
                                  hint: '可选，用于控制显示顺序',
                                  icon: Icons.sort_outlined,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                textAlign: TextAlign.end,
                                maxLength: 9,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(_remarkNode);
                                },
                                validator: (value) {
                                  final text = (value ?? '').trim();
                                  if (text.isEmpty) return null;
                                  final number = int.tryParse(text);
                                  if (number == null) return '必须为整数';
                                  if (number < 0) return '必须为非负数';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        // 权限设置卡片
                        _buildSectionCard(
                          title: '权限设置',
                          subtitle: '控制该交易对象的使用范围',
                          child: Column(
                            children: [
                              _buildPermissionSwitch(
                                title: '支出权限',
                                subtitle: '允许在支出记录中使用',
                                value: _canExpense,
                                onChanged: (value) {
                                  setState(() {
                                    _canExpense = value;
                                  });
                                  _computeDirty();
                                },
                                activeColor: ds.PayeeColors.expenseEnabled,
                                icon: ds.PayeeStatusIcons.expenseEnabled,
                              ),
                              SizedBox(height: ds.Spacing.md),
                              _buildPermissionSwitch(
                                title: '收入权限',
                                subtitle: '允许在收入记录中使用',
                                value: _canIncome,
                                onChanged: (value) {
                                  setState(() {
                                    _canIncome = value;
                                  });
                                  _computeDirty();
                                },
                                activeColor: ds.PayeeColors.incomeEnabled,
                                icon: ds.PayeeStatusIcons.incomeEnabled,
                              ),
                              SizedBox(height: ds.Spacing.md),
                              _buildPermissionSwitch(
                                title: '启用状态',
                                subtitle: '控制是否在列表中显示',
                                value: _enable,
                                onChanged: (value) {
                                  setState(() {
                                    _enable = value;
                                  });
                                  _computeDirty();
                                },
                                activeColor: ds.PayeeColors.enabled,
                                icon: _enable 
                                    ? ds.PayeeStatusIcons.enabled 
                                    : ds.PayeeStatusIcons.disabled,
                              ),
                            ],
                          ),
                        ),

                        // 备注信息卡片
                        _buildSectionCard(
                          title: '备注信息',
                          subtitle: '可选的补充说明',
                          child: TextFormField(
                            controller: _remarkController,
                            focusNode: _remarkNode,
                            enabled: !_saving,
                            decoration: _buildInputDecoration(
                              label: '备注',
                              hint: '可选，最多200个字符',
                              icon: Icons.note_outlined,
                            ),
                            maxLines: 3,
                            maxLength: 200,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              final text = value ?? '';
                              if (text.length > 200) return '备注长度不能超过200个字符';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: _dirty && _isValid
            ? FloatingActionButton.extended(
                onPressed: _saving ? null : _onSave,
                backgroundColor: ds.PayeeColors.primary,
                foregroundColor: Colors.white,
                icon: _saving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.check),
                label: Text(
                  _saving ? '保存中...' : '保存',
                  style: ds.PayeeTextStyles.buttonText,
                ),
              )
            : null,
      ),
    );
  }
}