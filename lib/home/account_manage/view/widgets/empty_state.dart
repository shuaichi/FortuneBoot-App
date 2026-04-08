import 'package:flutter/material.dart';
import 'package:fortuneboot/Home/account_manage/constants/design_system.dart' as ds;

/// 增强版空状态组件
/// 提供更好的视觉引导和用户体验
class EnhancedEmptyState extends StatefulWidget {
  const EnhancedEmptyState({
    super.key,
    required this.accountType,
    required this.onAddAccount,
  });

  final int accountType;
  final VoidCallback onAddAccount;

  @override
  State<EnhancedEmptyState> createState() => _EnhancedEmptyStateState();
}

class _EnhancedEmptyStateState extends State<EnhancedEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ds.Durations.slow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: ds.AnimationCurves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: ds.AnimationCurves.bounce),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: ds.AnimationCurves.easeOut),
    ));

    // 延迟启动动画，让页面加载更自然
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String get _accountTypeLabel {
    switch (widget.accountType) {
      case 1:
        return '活期账户';
      case 2:
        return '信用账户';
      case 3:
        return '资产账户';
      case 4:
        return '贷款账户';
      default:
        return '账户';
    }
  }

  String get _emptyMessage {
    switch (widget.accountType) {
      case 1:
        return '还没有活期账户\n创建一个开始管理您的日常资金';
      case 2:
        return '还没有信用账户\n添加信用卡来跟踪您的消费';
      case 3:
        return '还没有资产账户\n记录您的投资和储蓄';
      case 4:
        return '还没有贷款账户\n管理您的借贷信息';
      default:
        return '还没有相关账户\n创建一个开始记账吧';
    }
  }

  IconData get _emptyIcon {
    return ds.AccountDesignSystem.getAccountTypeIcon(widget.accountType);
  }

  Color get _typeColor {
    return ds.AccountDesignSystem.getAccountTypeColor(widget.accountType);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(ds.Spacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIllustration(theme),
                    SizedBox(height: ds.Spacing.lg),
                    _buildTitle(theme),
                    SizedBox(height: ds.Spacing.md),
                    _buildDescription(theme),
                    SizedBox(height: ds.Spacing.xl),
                    _buildActionButton(theme),
                    SizedBox(height: ds.Spacing.lg),
                    _buildHelpText(theme),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIllustration(ThemeData theme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            _typeColor.withOpacity(0.1),
            _typeColor.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景圆圈
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _typeColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: _typeColor.withOpacity(0.2),
                width: 2,
              ),
            ),
          ),
          // 主图标
          Icon(
            _emptyIcon,
            size: 48,
            color: _typeColor.withOpacity(0.6),
          ),
          // 装饰性小图标
          Positioned(
            top: 15,
            right: 15,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: ds.Shadows.elevation1,
              ),
              child: Icon(
                Icons.add,
                size: 16,
                color: _typeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      '暂无$_accountTypeLabel',
      style: ds.TextStyles.emptyStateTitle.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      _emptyMessage,
      style: ds.TextStyles.emptyStateDescription.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: widget.onAddAccount,
        icon: Icon(Icons.add, size: 20),
        label: Text('创建$_accountTypeLabel'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _typeColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: ds.Spacing.lg,
            vertical: ds.Spacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: ds.BorderRadii.button,
          ),
          elevation: 2,
          shadowColor: _typeColor.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildHelpText(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ds.Spacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: ds.BorderRadii.button,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: ds.Spacing.sm),
          Expanded(
            child: Text(
              _getHelpText(),
              style: ds.TextStyles.remark.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getHelpText() {
    switch (widget.accountType) {
      case 1:
        return '活期账户用于管理您的日常收支，如工资卡、零钱等';
      case 2:
        return '信用账户帮助跟踪信用卡消费和还款情况';
      case 3:
        return '资产账户记录投资理财产品，如基金、股票等';
      case 4:
        return '贷款账户管理房贷、车贷等借贷信息';
      default:
        return '选择合适的账户类型开始您的记账之旅';
    }
  }
}