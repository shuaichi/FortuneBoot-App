import 'package:flutter/material.dart';
import 'package:hjproject/Home/account_manage/constants/design_system.dart' as ds;
import 'package:hjproject/Home/account_manage/models/fortune_account.dart';
import 'package:hjproject/util/app_icon.dart';

/// 增强版账户卡片组件
/// 包含手势操作、动画效果和优化的视觉层次
class EnhancedAccountCard extends StatefulWidget {
  const EnhancedAccountCard({
    super.key,
    required this.account,
    required this.onTap,
    required this.onEdit,
    required this.onBalanceAdjust,
    required this.onMoveToRecycle,
  });

  final FortuneAccount account;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onBalanceAdjust;
  final VoidCallback onMoveToRecycle;

  @override
  State<EnhancedAccountCard> createState() => _EnhancedAccountCardState();
}

class _EnhancedAccountCardState extends State<EnhancedAccountCard>
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
    final accountType = widget.account.accountType ?? 1;
    final typeColor = ds.AccountDesignSystem.getAccountTypeColor(accountType);
    final typeLightColor = ds.AccountDesignSystem.getAccountTypeLightColor(accountType);
    final typeIcon = ds.AccountDesignSystem.getAccountTypeIcon(accountType);

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
                  shadowColor: typeColor.withOpacity(0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: ds.BorderRadii.card,
                      border: Border.all(
                        color: _isHovered 
                            ? typeColor.withOpacity(0.3)
                            : theme.colorScheme.outlineVariant,
                        width: _isHovered ? 2.0 : 1.0,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.surface,
                          typeLightColor.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: ds.Paddings.card,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(theme, typeColor, typeIcon),
                          SizedBox(height: ds.Spacing.sm),
                          _buildBalance(theme, typeColor),
                          if (widget.account.remark?.isNotEmpty == true) ...[
                            SizedBox(height: ds.Spacing.sm),
                            _buildRemark(theme),
                          ],
                          SizedBox(height: ds.Spacing.md),
                          _buildStatusIndicators(theme),
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

  Widget _buildHeader(ThemeData theme, Color typeColor, IconData typeIcon) {
    // 用户自定义图标优先，未设置时沿用账户类型图标
    final IconData headerIcon =
        AppIcon.resolve(widget.account.icon) ?? typeIcon;
    return Row(
      children: [
        // 账户图标（自定义 / 类型默认）
        Container(
          padding: EdgeInsets.all(ds.Spacing.sm),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ds.BorderRadiusValues.sm),
          ),
          child: Icon(
            headerIcon,
            color: typeColor,
            size: 20,
          ),
        ),
        SizedBox(width: ds.Spacing.md),
        // 账户名称
        Expanded(
          child: Text(
            widget.account.accountName ?? '未命名账户',
            style: ds.TextStyles.accountName.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // 更多操作按钮
        _buildMoreButton(theme, typeColor),
      ],
    );
  }

  Widget _buildMoreButton(ThemeData theme, Color typeColor) {
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
            widget.onBalanceAdjust();
            break;
          case 3:
            widget.onMoveToRecycle();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: typeColor, size: 18),
              SizedBox(width: ds.Spacing.sm),
              Text('编辑账户', style: ds.TextStyles.remark),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.swap_vert, color: typeColor, size: 18),
              SizedBox(width: ds.Spacing.sm),
              Text('余额调整', style: ds.TextStyles.remark),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 18),
              SizedBox(width: ds.Spacing.sm),
              Text('移入回收站', style: ds.TextStyles.remark.copyWith(
                color: theme.colorScheme.error,
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalance(ThemeData theme, Color typeColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            widget.account.balanceText,
            style: ds.TextStyles.balanceAmount.copyWith(
              color: typeColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.account.currencyCode?.isNotEmpty == true)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ds.Spacing.sm,
              vertical: ds.Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(ds.BorderRadiusValues.xs),
            ),
            child: Text(
              widget.account.currencyCode!,
              style: ds.TextStyles.currencyCode.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
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
          SizedBox(width: ds.Spacing.xs),
          Expanded(
            child: Text(
              widget.account.remark!,
              style: ds.TextStyles.remark.copyWith(
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

  Widget _buildStatusIndicators(ThemeData theme) {
    final indicators = <Widget>[];

    // 收支权限指示器
    if (widget.account.canIncome) {
      indicators.add(_buildStatusChip(
        theme,
        Icons.arrow_upward,
        '收入',
        ds.FinanceColors.income,
      ));
    }

    if (widget.account.canExpense) {
      indicators.add(_buildStatusChip(
        theme,
        Icons.arrow_downward,
        '支出',
        ds.FinanceColors.expense,
      ));
    }

    // 转账权限指示器
    if (widget.account.canTransferIn) {
      indicators.add(_buildStatusChip(
        theme,
        Icons.call_received,
        '转入',
        ds.FinanceColors.transfer,
      ));
    }

    if (widget.account.canTransferOut) {
      indicators.add(_buildStatusChip(
        theme,
        Icons.call_made,
        '转出',
        ds.FinanceColors.transfer,
      ));
    }

    // 状态指示器
    if (!widget.account.enable) {
      indicators.add(_buildStatusChip(
        theme,
        Icons.pause_circle_outline,
        '已停用',
        theme.colorScheme.error,
      ));
    }

    if (!widget.account.include) {
      indicators.add(_buildStatusChip(
        theme,
        Icons.visibility_off_outlined,
        '不计入资产',
        theme.colorScheme.outline,
      ));
    }

    if (indicators.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: ds.Spacing.xs,
      runSpacing: ds.Spacing.xs,
      children: indicators,
    );
  }

  Widget _buildStatusChip(ThemeData theme, IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ds.Spacing.sm,
        vertical: ds.Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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
            size: 12,
            color: color,
          ),
          SizedBox(width: ds.Spacing.xs),
          Text(
            label,
            style: ds.TextStyles.statusChip.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}