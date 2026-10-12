import 'package:flutter/material.dart';
import 'package:hjproject/home/payee_manage/constants/design_system.dart' as ds;
import 'package:hjproject/home/payee_manage/model/payee.dart';
import 'package:hjproject/util/app_icon.dart';

/// 增强版交易对象卡片组件
/// 包含手势操作、动画效果和优化的视觉层次
class EnhancedPayeeCard extends StatefulWidget {
  const EnhancedPayeeCard({
    super.key,
    required this.payee,
    required this.onTap,
    required this.onEdit,
    required this.onMoveToRecycle,
  });

  final Payee payee;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onMoveToRecycle;

  @override
  State<EnhancedPayeeCard> createState() => _EnhancedPayeeCardState();
}

class _EnhancedPayeeCardState extends State<EnhancedPayeeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ds.Durations.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: ds.AnimationCurves.easeOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 1.0,
      end: 4.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: ds.AnimationCurves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onHoverChange(bool isHovered) {
    setState(() => _isHovered = isHovered);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final payeeIcon = ds.PayeeDesignSystem.getPayeeIcon(widget.payee.payeeName);
    final primaryColor = theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _onHoverChange(true),
            onExit: (_) => _onHoverChange(false),
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: widget.onTap,
              child: Container(
                margin: ds.Paddings.cardMargin,
                child: Material(
                  elevation: _isHovered ? _elevationAnimation.value : 1.0,
                  borderRadius: ds.BorderRadii.card,
                  shadowColor: primaryColor.withOpacity(0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: ds.BorderRadii.card,
                      border: Border.all(
                        color: _isHovered 
                            ? primaryColor.withOpacity(0.3)
                            : theme.colorScheme.outlineVariant,
                        width: _isHovered ? 2.0 : 1.0,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.surface,
                          ds.PayeeColors.cardGradientEnd,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: ds.Paddings.card,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(theme, primaryColor, payeeIcon),
                          SizedBox(height: ds.Spacing.sm),
                          _buildStatusIndicators(theme),
                          if (widget.payee.remark?.isNotEmpty == true) ...[
                            SizedBox(height: ds.Spacing.sm),
                            _buildRemark(theme),
                          ],
                          if (widget.payee.sort != null) ...[
                            SizedBox(height: ds.Spacing.sm),
                            _buildSortNumber(theme),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, Color primaryColor, IconData payeeIcon) {
    // 用户自定义图标优先，未设置时沿用按名称推断的图标
    final IconData headerIcon =
        AppIcon.resolve(widget.payee.icon) ?? payeeIcon;
    return Row(
      children: [
        // 交易对象图标（自定义 / 默认）
        Container(
          padding: EdgeInsets.all(ds.Spacing.sm),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ds.BorderRadiusValues.sm),
          ),
          child: Icon(
            headerIcon,
            color: primaryColor,
            size: 20,
          ),
        ),
        SizedBox(width: ds.Spacing.md),
        // 交易对象名称
        Expanded(
          child: Text(
            widget.payee.payeeName,
            style: ds.PayeeTextStyles.payeeName.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // 更多操作按钮
        _buildMoreButton(theme, primaryColor),
      ],
    );
  }

  Widget _buildMoreButton(ThemeData theme, Color primaryColor) {
    return PopupMenuButton<int>(
      icon: Icon(
        Icons.more_vert,
        color: theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      tooltip: '更多操作',
      shape: RoundedRectangleBorder(
        borderRadius: ds.BorderRadii.button,
      ),
      onSelected: (value) {
        switch (value) {
          case 1:
            widget.onEdit();
            break;
          case 2:
            widget.onMoveToRecycle();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: primaryColor, size: 18),
              SizedBox(width: ds.Spacing.sm),
              Text('编辑', style: ds.PayeeTextStyles.remark),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 18),
              SizedBox(width: ds.Spacing.sm),
              Text('移入回收站', style: ds.PayeeTextStyles.remark.copyWith(
                color: theme.colorScheme.error,
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicators(ThemeData theme) {
    return Wrap(
      spacing: ds.Spacing.xs,
      runSpacing: ds.Spacing.xs,
      children: [
        _buildStatusChip(
          context: theme,
          label: ds.PayeeDesignSystem.getIncomePermissionText(widget.payee.canIncome),
          color: ds.PayeeDesignSystem.getIncomePermissionColor(widget.payee.canIncome),
          lightColor: ds.PayeeDesignSystem.getIncomePermissionLightColor(widget.payee.canIncome),
          icon: ds.PayeeStatusIcons.incomeEnabled,
          isEnabled: widget.payee.canIncome,
        ),
        _buildStatusChip(
          context: theme,
          label: ds.PayeeDesignSystem.getExpensePermissionText(widget.payee.canExpense),
          color: ds.PayeeDesignSystem.getExpensePermissionColor(widget.payee.canExpense),
          lightColor: ds.PayeeDesignSystem.getExpensePermissionLightColor(widget.payee.canExpense),
          icon: ds.PayeeStatusIcons.expenseEnabled,
          isEnabled: widget.payee.canExpense,
        ),
        _buildStatusChip(
          context: theme,
          label: ds.PayeeDesignSystem.getEnabledStatusText(widget.payee.enable),
          color: ds.PayeeDesignSystem.getEnabledStatusColor(widget.payee.enable),
          lightColor: ds.PayeeDesignSystem.getEnabledStatusLightColor(widget.payee.enable),
          icon: widget.payee.enable ? ds.PayeeStatusIcons.enabled : ds.PayeeStatusIcons.disabled,
          isEnabled: widget.payee.enable,
        ),
      ],
    );
  }

  Widget _buildStatusChip({
    required ThemeData context,
    required String label,
    required Color color,
    required Color lightColor,
    required IconData icon,
    required bool isEnabled,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ds.Spacing.sm,
        vertical: ds.Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: ds.BorderRadii.chip,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          SizedBox(width: ds.Spacing.xs),
          Text(
            label,
            style: ds.PayeeTextStyles.statusChip.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemark(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(ds.Spacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(ds.BorderRadiusValues.sm),
      ),
      child: Row(
        children: [
          Icon(
            Icons.note_outlined,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: ds.Spacing.sm),
          Expanded(
            child: Text(
              widget.payee.remark!,
              style: ds.PayeeTextStyles.remark.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortNumber(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.sort,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: ds.Spacing.xs),
        Text(
          '排序: ${widget.payee.sort}',
          style: ds.PayeeTextStyles.sortNumber.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// 交易对象卡片骨架加载组件
class PayeeCardSkeleton extends StatefulWidget {
  const PayeeCardSkeleton({super.key});

  @override
  State<PayeeCardSkeleton> createState() => _PayeeCardSkeletonState();
}

class _PayeeCardSkeletonState extends State<PayeeCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: ds.AnimationCurves.easeInOut,
    ));

    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: ds.Paddings.cardMargin,
      child: Material(
        elevation: 1.0,
        borderRadius: ds.BorderRadii.card,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: ds.BorderRadii.card,
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: ds.Paddings.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkeletonHeader(),
                SizedBox(height: ds.Spacing.sm),
                _buildSkeletonStatusChips(),
                SizedBox(height: ds.Spacing.sm),
                _buildSkeletonRemark(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonHeader() {
    return Row(
      children: [
        _buildShimmerBox(40, 40, isCircular: true),
        SizedBox(width: ds.Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerBox(120, 20),
              SizedBox(height: ds.Spacing.xs),
              _buildShimmerBox(80, 14),
            ],
          ),
        ),
        _buildShimmerBox(24, 24, isCircular: true),
      ],
    );
  }

  Widget _buildSkeletonStatusChips() {
    return Wrap(
      spacing: ds.Spacing.xs,
      runSpacing: ds.Spacing.xs,
      children: [
        _buildShimmerBox(60, 24, borderRadius: ds.BorderRadiusValues.pill),
        _buildShimmerBox(70, 24, borderRadius: ds.BorderRadiusValues.pill),
        _buildShimmerBox(50, 24, borderRadius: ds.BorderRadiusValues.pill),
      ],
    );
  }

  Widget _buildSkeletonRemark() {
    return _buildShimmerBox(double.infinity, 40, borderRadius: ds.BorderRadiusValues.sm);
  }

  Widget _buildShimmerBox(
    double width,
    double height, {
    bool isCircular = false,
    double? borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: width == double.infinity ? null : width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: isCircular 
                ? BorderRadius.circular(height / 2)
                : BorderRadius.circular(borderRadius ?? ds.BorderRadiusValues.xs),
            gradient: LinearGradient(
              begin: Alignment(_shimmerAnimation.value - 1, 0),
              end: Alignment(_shimmerAnimation.value, 0),
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
            ),
          ),
        );
      },
    );
  }
}