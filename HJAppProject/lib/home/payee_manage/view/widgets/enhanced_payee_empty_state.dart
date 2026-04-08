import 'package:flutter/material.dart';
import 'package:fortuneboot/home/payee_manage/constants/design_system.dart' as ds;

/// 增强版交易对象空状态组件
/// 提供更好的视觉引导和用户体验
class EnhancedPayeeEmptyState extends StatefulWidget {
  const EnhancedPayeeEmptyState({
    super.key,
    required this.onAddPayee,
  });

  final VoidCallback onAddPayee;

  @override
  State<EnhancedPayeeEmptyState> createState() => _EnhancedPayeeEmptyStateState();
}

class _EnhancedPayeeEmptyStateState extends State<EnhancedPayeeEmptyState>
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
    final primaryColor = theme.colorScheme.primary;
    
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            primaryColor.withOpacity(0.1),
            primaryColor.withOpacity(0.05),
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
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 2,
              ),
            ),
          ),
          // 主图标
          Icon(
            ds.PayeeStatusIcons.payee,
            size: 48,
            color: primaryColor.withOpacity(0.6),
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
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      '暂无交易对象',
      style: ds.PayeeTextStyles.emptyStateTitle.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      '还没有添加交易对象\n创建一个开始管理您的收支来源',
      style: ds.PayeeTextStyles.emptyStateDescription.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    final primaryColor = theme.colorScheme.primary;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: widget.onAddPayee,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('创建交易对象'),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: ds.Spacing.lg,
            vertical: ds.Spacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: ds.BorderRadii.button,
          ),
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.3),
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
              '交易对象用于记录收支的来源或去向，如工资发放方、消费商家等',
              style: ds.PayeeTextStyles.remark.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}