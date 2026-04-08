import 'package:flutter/material.dart';
import 'package:fortuneboot/Home/account_manage/constants/design_system.dart' as ds;

/// 增强版账户类型选择器
/// 支持响应式布局和优化的交互体验
class EnhancedTypeSelector extends StatefulWidget {
  const EnhancedTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    this.enabled = true,
  });

  final int selectedType;
  final ValueChanged<int> onTypeChanged;
  final bool enabled;

  @override
  State<EnhancedTypeSelector> createState() => _EnhancedTypeSelectorState();
}

class _EnhancedTypeSelectorState extends State<EnhancedTypeSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ds.Durations.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 响应式布局判断
        if (constraints.maxWidth < ds.Breakpoints.mobile) {
          return _buildCompactLayout(context);
        } else if (constraints.maxWidth < ds.Breakpoints.tablet) {
          return _buildTabletLayout(context);
        } else {
          return _buildDesktopLayout(context);
        }
      },
    );
  }

  /// 紧凑布局（手机竖屏）
  Widget _buildCompactLayout(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: ds.Spacing.xs),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _buildTypeChips(context, isCompact: true),
        ),
      ),
    );
  }

  /// 平板布局
  Widget _buildTabletLayout(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: ds.Spacing.sm),
      child: Row(
        children: _buildTypeChips(context, isCompact: false)
            .map((chip) => Expanded(child: chip))
            .toList(),
      ),
    );
  }

  /// 桌面布局
  Widget _buildDesktopLayout(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Row(
        children: _buildTypeChips(context, isCompact: false)
            .map((chip) => Expanded(child: chip))
            .toList(),
      ),
    );
  }

  List<Widget> _buildTypeChips(BuildContext context, {required bool isCompact}) {
    final types = [
      _TypeInfo(1, '活期', Icons.account_balance_wallet_outlined),
      _TypeInfo(2, '信用', Icons.credit_card_outlined),
      _TypeInfo(3, '资产', Icons.savings_outlined),
      _TypeInfo(4, '贷款', Icons.trending_down_outlined),
    ];

    return types.map((type) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: ds.Spacing.xs),
        child: _buildTypeChip(
          context,
          type,
          isSelected: widget.selectedType == type.value,
          isCompact: isCompact,
        ),
      );
    }).toList();
  }

  Widget _buildTypeChip(
    BuildContext context,
    _TypeInfo type, {
    required bool isSelected,
    required bool isCompact,
  }) {
    final theme = Theme.of(context);
    final typeColor = ds.AccountDesignSystem.getAccountTypeColor(type.value);
    final typeLightColor = ds.AccountDesignSystem.getAccountTypeLightColor(type.value);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onTapDown: (_) {
              if (widget.enabled && isSelected) {
                _animationController.forward();
              }
            },
            onTapUp: (_) {
              if (widget.enabled && isSelected) {
                _animationController.reverse();
              }
            },
            onTapCancel: () {
              if (widget.enabled && isSelected) {
                _animationController.reverse();
              }
            },
            onTap: widget.enabled ? () => widget.onTypeChanged(type.value) : null,
            child: AnimatedContainer(
              duration: ds.Durations.normal,
              curve: ds.AnimationCurves.easeOut,
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? ds.Spacing.md : ds.Spacing.lg,
                vertical: ds.Spacing.md,
              ),
              decoration: BoxDecoration(
                color: isSelected 
                    ? typeColor
                    : theme.colorScheme.surface,
                borderRadius: ds.BorderRadii.button,
                border: Border.all(
                  color: isSelected 
                      ? typeColor
                      : theme.colorScheme.outline.withOpacity(0.5),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected 
                    ? [
                        BoxShadow(
                          color: typeColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isCompact 
                  ? _buildCompactContent(theme, type, isSelected, typeColor)
                  : _buildFullContent(theme, type, isSelected, typeColor),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactContent(
    ThemeData theme,
    _TypeInfo type,
    bool isSelected,
    Color typeColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          type.icon,
          size: 18,
          color: isSelected 
              ? Colors.white
              : typeColor,
        ),
        SizedBox(width: ds.Spacing.xs),
        Text(
          type.label,
          style: ds.TextStyles.remark.copyWith(
            color: isSelected 
                ? Colors.white
                : theme.colorScheme.onSurface,
            fontWeight: isSelected 
                ? ds.FontWeights.semiBold
                : ds.FontWeights.regular,
          ),
        ),
      ],
    );
  }

  Widget _buildFullContent(
    ThemeData theme,
    _TypeInfo type,
    bool isSelected,
    Color typeColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(ds.Spacing.sm),
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.white.withOpacity(0.2)
                : typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ds.BorderRadiusValues.sm),
          ),
          child: Icon(
            type.icon,
            size: 24,
            color: isSelected 
                ? Colors.white
                : typeColor,
          ),
        ),
        SizedBox(height: ds.Spacing.sm),
        Text(
          type.label,
          style: ds.TextStyles.remark.copyWith(
            color: isSelected 
                ? Colors.white
                : theme.colorScheme.onSurface,
            fontWeight: isSelected 
                ? ds.FontWeights.semiBold
                : ds.FontWeights.regular,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// 类型信息数据类
class _TypeInfo {
  final int value;
  final String label;
  final IconData icon;

  const _TypeInfo(this.value, this.label, this.icon);
}

/// 账户类型统计卡片
class AccountTypeStatsCard extends StatefulWidget {
  const AccountTypeStatsCard({
    super.key,
    required this.accountType,
    required this.count,
    required this.totalAmount,
    required this.currencySymbol,
    required this.isSelected,
    required this.onTap,
  });

  final int accountType;
  final int count;
  final double totalAmount;
  final String currencySymbol;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<AccountTypeStatsCard> createState() => _AccountTypeStatsCardState();
}

class _AccountTypeStatsCardState extends State<AccountTypeStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

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
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: ds.AnimationCurves.easeOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
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

  void _onHoverChange(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  String get _typeLabel {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = ds.AccountDesignSystem.getAccountTypeColor(widget.accountType);
    final typeLightColor = ds.AccountDesignSystem.getAccountTypeLightColor(widget.accountType);
    final typeIcon = ds.AccountDesignSystem.getAccountTypeIcon(widget.accountType);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _onHoverChange(true),
            onExit: (_) => _onHoverChange(false),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                margin: EdgeInsets.all(ds.Spacing.xs),
                child: Material(
                  elevation: _elevationAnimation.value,
                  borderRadius: ds.BorderRadii.card,
                  shadowColor: typeColor.withOpacity(0.2),
                  child: Container(
                    padding: ds.Paddings.card,
                    decoration: BoxDecoration(
                      borderRadius: ds.BorderRadii.card,
                      border: Border.all(
                        color: widget.isSelected 
                            ? typeColor
                            : theme.colorScheme.outlineVariant,
                        width: widget.isSelected ? 2 : 1,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.isSelected 
                              ? typeLightColor.withOpacity(0.1)
                              : theme.colorScheme.surface,
                          widget.isSelected 
                              ? typeLightColor.withOpacity(0.05)
                              : theme.colorScheme.surface,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(ds.Spacing.sm),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(ds.BorderRadiusValues.sm),
                              ),
                              child: Icon(
                                typeIcon,
                                color: typeColor,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: ds.Spacing.md),
                            Expanded(
                              child: Text(
                                _typeLabel,
                                style: ds.TextStyles.accountName.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ds.Spacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.count}个账户',
                                  style: ds.TextStyles.remark.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: ds.Spacing.xs),
                                Text(
                                  '${widget.currencySymbol}${widget.totalAmount.toStringAsFixed(2)}',
                                  style: ds.TextStyles.balanceAmount.copyWith(
                                    color: typeColor,
                                    fontSize: ds.FontSizes.title,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.isSelected)
                              Container(
                                padding: EdgeInsets.all(ds.Spacing.xs),
                                decoration: BoxDecoration(
                                  color: typeColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ],
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
}