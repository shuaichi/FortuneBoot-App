import 'package:flutter/material.dart';
import 'package:hjproject/Home/account_manage/constants/design_system.dart' as ds;

/// 增强版移入回收站确认对话框
/// 基于原有功能，使用统一设计系统，提升UI/UX体验
class AccountMoveToRecycleDialog extends StatefulWidget {
  const AccountMoveToRecycleDialog({
    super.key,
    required this.accountName,
    required this.onConfirm,
  });

  final String accountName;
  final Future<void> Function() onConfirm;

  @override
  State<AccountMoveToRecycleDialog> createState() => _AccountMoveToRecycleDialogState();
}

class _AccountMoveToRecycleDialogState extends State<AccountMoveToRecycleDialog>
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
          style: ds.TextStyles.sectionTitle.copyWith(
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
          // 账户信息
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ds.Spacing.xs),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ds.BorderRadiusValues.xs),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: ds.Spacing.sm),
              Expanded(
                child: Text(
                  widget.accountName,
                  style: ds.TextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: ds.FontWeights.semiBold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ds.Spacing.md),
          
          // 主要说明
          Text(
            '确认将此账户移入回收站？',
            style: ds.TextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface,
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
                    style: ds.TextStyles.caption.copyWith(
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
          style: ds.TextStyles.caption.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: ds.FontWeights.medium,
          ),
        ),
        SizedBox(height: ds.Spacing.xs),
        
        ...[
          '• 账户将从主界面隐藏',
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
                  style: ds.TextStyles.caption.copyWith(
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
              style: ds.TextStyles.buttonText.copyWith(
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
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onError,
                          ),
                        ),
                      ),
                      SizedBox(width: ds.Spacing.sm),
                      Text(
                        '处理中...',
                        style: ds.TextStyles.buttonText.copyWith(
                          color: theme.colorScheme.onError,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: theme.colorScheme.onError,
                      ),
                      SizedBox(width: ds.Spacing.sm),
                      Text(
                        '移入回收站',
                        style: ds.TextStyles.buttonText.copyWith(
                          color: theme.colorScheme.onError,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleCancel() async {
    // 退出动画
    await _fadeController.reverse();
    await _scaleController.reverse();
    
    if (mounted) {
      Navigator.of(context).pop(false);
    }
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);
    
    try {
      await widget.onConfirm();
      
      if (mounted) {
        // 成功动画
        await _fadeController.reverse();
        await _scaleController.reverse();
        
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        
        // 显示错误提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onError,
                ),
                SizedBox(width: ds.Spacing.sm),
                Expanded(
                  child: Text(
                    '操作失败: ${e.toString()}',
                    style: ds.TextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ds.BorderRadiusValues.sm),
            ),
          ),
        );
      }
    }
  }

  /// 静态方法：显示增强版移入回收站对话框
  static Future<bool?> show(
    BuildContext context, {
    required String accountName,
    required Future<void> Function() onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AccountMoveToRecycleDialog(
        accountName: accountName,
        onConfirm: onConfirm,
      ),
    );
  }
}