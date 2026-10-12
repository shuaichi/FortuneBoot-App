import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';
import 'package:hjproject/Home/payee_manage/data/payee_service.dart';
import 'package:hjproject/home/payee_manage/constants/design_system.dart' as ds;
import 'package:hjproject/home/payee_manage/view/widgets/enhanced_payee_form.dart';

/// 增强版交易对象添加页面
/// 基于设计系统重构，提供现代化的用户体验和一致的视觉设计
class EnhancedPayeeAddPage extends StatefulWidget {
  const EnhancedPayeeAddPage({Key? key}) : super(key: key);

  @override
  State<EnhancedPayeeAddPage> createState() => _EnhancedPayeeAddPageState();
}

class _EnhancedPayeeAddPageState extends State<EnhancedPayeeAddPage>
    with TickerProviderStateMixin {
  
  // 动画控制器
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _fabController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fabScaleAnimation;

  // 表单控制器
  late final TextEditingController _nameController;
  late final TextEditingController _sortController;
  late final TextEditingController _remarkController;

  // 焦点节点
  late final FocusNode _nameNode;
  late final FocusNode _sortNode;
  late final FocusNode _remarkNode;

  // 状态变量
  bool _canExpense = true;
  bool _canIncome = true;
  bool _enable = true;

  // 自定义图标名（为空表示使用默认图标）
  String? _icon;

  // UI状态
  bool _saving = false;
  bool _dirty = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initControllers();
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

    _fabController = AnimationController(
      duration: ds.Durations.normal,
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

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: ds.AnimationCurves.bounce,
    ));

    // 启动动画
    _fadeController.forward();
    _scaleController.forward();
    // FAB动画延迟启动
    Future.delayed(ds.Durations.fast, () {
      if (mounted) {
        _fabController.forward();
      }
    });
  }

  void _initControllers() {
    _nameController = TextEditingController();
    _sortController = TextEditingController();
    _remarkController = TextEditingController();
    
    _nameNode = FocusNode();
    _sortNode = FocusNode();
    _remarkNode = FocusNode();

    // 添加监听器检测变化
    _nameController.addListener(_markDirty);
    _sortController.addListener(_markDirty);
    _remarkController.addListener(_markDirty);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _fabController.dispose();
    _nameController.dispose();
    _sortController.dispose();
    _remarkController.dispose();
    _nameNode.dispose();
    _sortNode.dispose();
    _remarkNode.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) {
      setState(() {
        _dirty = true;
      });
    }
  }

  void _onPermissionChanged() {
    _markDirty();
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
      final bookId = context.read<BillsRepository>().bookId() ?? 1;
      await PayeeService().add(
        bookId: bookId,
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
      _showSuccessMessage('添加成功');
      
      // 重置表单状态
      _resetForm();
      
      // 延迟返回以显示成功消息
      Future.delayed(const Duration(milliseconds: 800), () {
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

  void _resetForm() {
    _nameController.clear();
    _sortController.clear();
    _remarkController.clear();
    setState(() {
      _canExpense = true;
      _canIncome = true;
      _enable = true;
      _icon = null;
      _dirty = false;
    });
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
        duration: const Duration(milliseconds: 1500),
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
        duration: const Duration(milliseconds: 2000),
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
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.outline),
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: ds.BorderRadii.button,
              ),
            ),
            child: Text(
              '取消',
              style: ds.PayeeTextStyles.buttonText,
            ),
          ),
          SizedBox(width: ds.Spacing.sm),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ds.PayeeColors.expenseEnabled,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: ds.BorderRadii.button,
              ),
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

  void _onReset() {
    if (_saving) return;
    
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: theme.colorScheme.surfaceTint,
          shape: RoundedRectangleBorder(
            borderRadius: ds.BorderRadii.card,
          ),
          title: Text(
            '重置表单？',
            style: ds.PayeeTextStyles.pageTitle.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Text(
            '确定要清空所有已填写的内容吗？',
            style: ds.PayeeTextStyles.remark.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.outline),
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: ds.BorderRadii.button,
                ),
              ),
              child: Text(
                '取消',
                style: ds.PayeeTextStyles.buttonText,
              ),
            ),
            SizedBox(width: ds.Spacing.sm),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ds.PayeeColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: ds.BorderRadii.button,
                ),
              ),
              child: Text(
                '重置',
                style: ds.PayeeTextStyles.buttonText,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _confirmLeave();
        if (shouldPop && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        appBar: AppBar(
          title: Text(
            '新增交易对象',
            style: ds.PayeeTextStyles.pageTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          elevation: 0,
          actions: [
            if (_dirty && !_saving)
              IconButton(
                onPressed: _onReset,
                icon: Icon(
                  Icons.refresh_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                tooltip: '重置表单',
              ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: ds.Spacing.md,
                      vertical: ds.Spacing.lg,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - ds.Spacing.lg * 2,
                      ),
                      child: Column(
                        children: [
                          // 页面说明卡片
                          _buildWelcomeCard(),
                          
                          SizedBox(height: ds.Spacing.lg),
                          
                          // 表单内容
                          EnhancedPayeeForm(
                            nameController: _nameController,
                            sortController: _sortController,
                            remarkController: _remarkController,
                            nameNode: _nameNode,
                            sortNode: _sortNode,
                            remarkNode: _remarkNode,
                            canExpense: _canExpense,
                            canIncome: _canIncome,
                            enable: _enable,
                            icon: _icon,
                            onIconChanged: (v) {
                              setState(() {
                                _icon = v;
                              });
                              _markDirty();
                            },
                            onCanExpenseChanged: (v) {
                              setState(() {
                                _canExpense = v;
                              });
                              _onPermissionChanged();
                            },
                            onCanIncomeChanged: (v) {
                              setState(() {
                                _canIncome = v;
                              });
                              _onPermissionChanged();
                            },
                            onEnableChanged: (v) {
                              setState(() {
                                _enable = v;
                              });
                              _onPermissionChanged();
                            },
                            onChanged: _markDirty,
                            isBusy: _saving,
                          ),
                          
                          // 底部间距，为FAB让出空间
                          SizedBox(height: ds.Spacing.xxxl + ds.Spacing.lg),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        floatingActionButton: ScaleTransition(
          scale: _fabScaleAnimation,
          child: FloatingActionButton.extended(
            onPressed: _saving || !_isValid ? null : _onSave,
            backgroundColor: _isValid 
                ? ds.PayeeColors.primary 
                : Theme.of(context).colorScheme.surfaceVariant,
            foregroundColor: _isValid 
                ? Colors.white 
                : Theme.of(context).colorScheme.onSurfaceVariant,
            elevation: _isValid ? 6 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ds.BorderRadiusValues.lg),
            ),
            icon: _saving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isValid ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Icon(
                    Icons.check_rounded,
                    size: 24,
                  ),
            label: Text(
              _saving ? '保存中...' : '保存',
              style: ds.PayeeTextStyles.buttonText.copyWith(
                color: _isValid 
                    ? Colors.white 
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: ds.Spacing.xs),
      padding: EdgeInsets.all(ds.Spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ds.PayeeColors.primaryLight,
            ds.PayeeColors.primaryLight.withOpacity(0.7),
          ],
        ),
        borderRadius: ds.BorderRadii.card,
        border: Border.all(
          color: ds.PayeeColors.primary.withOpacity(0.2),
        ),
        boxShadow: ds.Shadows.elevation2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ds.Spacing.sm),
                decoration: BoxDecoration(
                  color: ds.PayeeColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ds.BorderRadiusValues.md),
                ),
                child: Icon(
                  ds.PayeeStatusIcons.payee,
                  color: ds.PayeeColors.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: ds.Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '创建新的交易对象',
                      style: ds.PayeeTextStyles.pageTitle.copyWith(
                        color: ds.PayeeColors.primaryDark,
                        fontWeight: ds.FontWeights.semiBold,
                      ),
                    ),
                    SizedBox(height: ds.Spacing.xs),
                    Text(
                      '填写基本信息，设置权限范围',
                      style: ds.PayeeTextStyles.remark.copyWith(
                        color: ds.PayeeColors.primaryDark.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}