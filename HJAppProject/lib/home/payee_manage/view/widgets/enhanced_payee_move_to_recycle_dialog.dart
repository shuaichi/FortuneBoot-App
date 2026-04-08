import 'package:flutter/material.dart';
import 'package:fortuneboot/home/payee_manage/constants/design_system.dart' as ds;
import 'package:fortuneboot/home/payee_manage/model/payee.dart';

/// 增强版交易对象移入回收站确认对话框
/// 基于账户管理对话框设计，使用交易对象专用设计系统
class EnhancedPayeeMoveToRecycleDialog extends StatefulWidget {
  const EnhancedPayeeMoveToRecycleDialog({
    super.key,
    required this.payee,
    required this.onConfirm,
  });

  final Payee payee;
  final Future<void> Function() onConfirm;

  @override
  State<EnhancedPayeeMoveToRecycleDialog> createState() => _EnhancedPayeeMoveToRecycleDialogState();
}

class _EnhancedPayeeMoveToRecycleDialogState extends State<EnhancedPayeeMoveToRecycleDialog>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  
  // 动画控制器
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _scaleController = AnimationController(
      duration: ds.Durations.normal,
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: ds.Durations.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: ds.AnimationCurves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: ds.AnimationCurves.easeOut,
    ));

    // 启动动画
    _scaleController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ds.BorderRadiusValues.xl),
          ),
          elevation: 8,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.85,
              minWidth: 280,
            ),
            padding: EdgeInsets.all(ds.Spacing.xl),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(ds.BorderRadiusValues.xl),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                SizedBox(height: ds.Spacing.lg),
                _buildContent(context),
                SizedBox(height: ds.Spacing.xl),
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(ds.Spacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(ds.BorderRadiusValues.pill),
          ),
          child: Icon(
            Icons.delete_outline,
            size: 32,
            color: theme.colorScheme.error,
          ),
        ),
        SizedBox(height: ds.Spacing.md),
        Text(
          '移入回收站',
          style: ds.PayeeTextStyles.pageTitle.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: ds.FontWeights.semiBold,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(ds.Spacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(ds.BorderRadiusValues.md),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 交易对象信息
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ds.Spacing.xs),
                decoration: BoxDecoration(
                  color: ds.PayeeColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ds.BorderRadiusValues.xs),
                ),
                child: Icon(
                  _getPayeeIcon(),
                  size: 16,
                  color: ds.PayeeColors.primary,
                ),
              ),
              SizedBox(width: ds.Spacing.sm),
              Expanded(
                child: Text(
                  widget.payee.payeeName,
                  style: ds.PayeeTextStyles.payeeName.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: ds.FontSizes.body,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ds.Spacing.md),
          
          // 主要说明
          Text(
            '确认将"${widget.payee.payeeName}"移入回收站？',
            style: ds.PayeeTextStyles.remark.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: ds.FontSizes.body,
            ),
          ),
          SizedBox(height: ds.Spacing.sm),
          
          // 提示信息
          Container(
            padding: EdgeInsets.all(ds.Spacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(ds.BorderRadiusValues.sm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: ds.Spacing.sm),
                Expanded(
                  child: Text(
                    '该操作不会删除数据，可在回收站恢复',
                    style: ds.PayeeTextStyles.caption.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ds.Spacing.sm),
          
          // 影响说明
          _buildImpactInfo(context),
        ],
      ),
    );
  }

  Widget _buildImpactInfo(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '操作影响：',
          style: ds.PayeeTextStyles.caption.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: ds.FontWeights.medium,
          ),
        ),
        SizedBox(height: ds.Spacing.xs),
        
        ...[
          '• 交易对象将从主界面隐藏',
          '• 相关交易记录保持不变',
          '• 可随时从回收站恢复',
        ].map((text) => Padding(
          padding: EdgeInsets.only(bottom: ds.Spacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: ds.Spacing.sm),
              Expanded(
                child: Text(
                  text,
                  style: ds.PayeeTextStyles.caption.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : _handleCancel,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: ds.Spacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ds.BorderRadiusValues.md),
              ),
            ),
            child: Text(
              '取消',
              style: ds.PayeeTextStyles.buttonText.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        SizedBox(width: ds.Spacing.md),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: _isLoading ? null : _handleConfirm,
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              padding: EdgeInsets.symmetric(vertical: ds.Spacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ds.BorderRadiusValues.md),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onError,
                      ),
                    ),
                  )
                : Text(
                    '确认移入回收站',
                    style: ds.PayeeTextStyles.buttonText.copyWith(
                      color: theme.colorScheme.onError,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  IconData _getPayeeIcon() {
    // 根据交易对象类型返回相应图标
    if (widget.payee.payeeName.contains('公司') || widget.payee.payeeName.contains('企业')) {
      return ds.PayeeStatusIcons.company;
    } else if (widget.payee.payeeName.contains('店') || widget.payee.payeeName.contains('商')) {
      return ds.PayeeStatusIcons.shop;
    }
    return ds.PayeeStatusIcons.payee;
  }

  void _handleCancel() {
    Navigator.of(context).pop(false);
  }

  Future<void> _handleConfirm() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onConfirm();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败：${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(ds.Spacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ds.BorderRadiusValues.sm),
            ),
          ),
        );
      }
    }
  }

  /// 显示对话框的静态方法
  static Future<bool?> show(
    BuildContext context, {
    required Payee payee,
    required Future<void> Function() onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => EnhancedPayeeMoveToRecycleDialog(
        payee: payee,
        onConfirm: onConfirm,
      ),
    );
  }
}

/// 响应式扩展
extension _ResponsiveContext on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < ds.Breakpoints.mobile;
  bool get isTablet => MediaQuery.of(this).size.width >= ds.Breakpoints.mobile && 
                      MediaQuery.of(this).size.width < ds.Breakpoints.desktop;
  bool get isDesktop => MediaQuery.of(this).size.width >= ds.Breakpoints.desktop;
}