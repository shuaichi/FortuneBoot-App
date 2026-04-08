import 'package:flutter/material.dart';
import 'package:fortuneboot/home/payee_manage/constants/design_system.dart' as ds;

/// 增强版交易对象类型选择器
/// 支持响应式布局和优化的交互体验
/// 用于筛选不同权限状态的交易对象
class EnhancedPayeeTypeSelector extends StatefulWidget {
  const EnhancedPayeeTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    this.enabled = true,
  });

  final PayeeFilterType selectedType;
  final ValueChanged<PayeeFilterType> onTypeChanged;
  final bool enabled;

  @override
  State<EnhancedPayeeTypeSelector> createState() => _EnhancedPayeeTypeSelectorState();
}

class _EnhancedPayeeTypeSelectorState extends State<EnhancedPayeeTypeSelector>
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
      constraints: const BoxConstraints(maxWidth: 800),
      child: Row(
        children: _buildTypeChips(context, isCompact: false)
            .map((chip) => Expanded(child: chip))
            .toList(),
      ),
    );
  }

  List<Widget> _buildTypeChips(BuildContext context, {required bool isCompact}) {
    final types = [
      _PayeeTypeInfo(PayeeFilterType.all, '全部', ds.PayeeStatusIcons.payee),
      _PayeeTypeInfo(PayeeFilterType.incomeEnabled, '收入', ds.PayeeStatusIcons.incomeEnabled),
      _PayeeTypeInfo(PayeeFilterType.expenseEnabled, '支出', ds.PayeeStatusIcons.expenseEnabled),
      _PayeeTypeInfo(PayeeFilterType.enabled, '启用', ds.PayeeStatusIcons.enabled),
      _PayeeTypeInfo(PayeeFilterType.disabled, '停用', ds.PayeeStatusIcons.disabled),
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
    _PayeeTypeInfo type, {
    required bool isSelected,
    required bool isCompact,
  }) {
    final theme = Theme.of(context);
    final typeColor = _getTypeColor(type.value);
    final typeLightColor = _getTypeLightColor(type.value);

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
    _PayeeTypeInfo type,
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
          style: ds.PayeeTextStyles.remark.copyWith(
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
    _PayeeTypeInfo type,
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
          style: ds.PayeeTextStyles.remark.copyWith(
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

  /// 获取类型对应的颜色
  Color _getTypeColor(PayeeFilterType type) {
    switch (type) {
      case PayeeFilterType.incomeEnabled:
        return ds.PayeeColors.incomeEnabled;
      case PayeeFilterType.expenseEnabled:
        return ds.PayeeColors.expenseEnabled;
      case PayeeFilterType.enabled:
        return ds.PayeeColors.enabled;
      case PayeeFilterType.disabled:
        return ds.PayeeColors.disabled;
      case PayeeFilterType.all:
      default:
        return ds.PayeeColors.primary;
    }
  }

  /// 获取类型对应的浅色背景
  Color _getTypeLightColor(PayeeFilterType type) {
    switch (type) {
      case PayeeFilterType.incomeEnabled:
        return ds.PayeeColors.incomeEnabledLight;
      case PayeeFilterType.expenseEnabled:
        return ds.PayeeColors.expenseEnabledLight;
      case PayeeFilterType.enabled:
        return ds.PayeeColors.enabledLight;
      case PayeeFilterType.disabled:
        return ds.PayeeColors.disabledLight;
      case PayeeFilterType.all:
      default:
        return ds.PayeeColors.primaryLight;
    }
  }
}

/// 交易对象筛选类型
enum PayeeFilterType {
  all,           // 全部
  incomeEnabled, // 收入权限
  expenseEnabled,// 支出权限
  enabled,       // 启用状态
  disabled,      // 停用状态
}

/// 交易对象类型信息数据类
class _PayeeTypeInfo {
  final PayeeFilterType value;
  final String label;
  final IconData icon;

  const _PayeeTypeInfo(this.value, this.label, this.icon);
}

/// 交易对象统计卡片
class PayeeTypeStatsCard extends StatefulWidget {
  const PayeeTypeStatsCard({
    super.key,
    required this.filterType,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final PayeeFilterType filterType;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<PayeeTypeStatsCard> createState() => _PayeeTypeStatsCardState();
}

class _PayeeTypeStatsCardState extends State<PayeeTypeStatsCard>
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
      end: 0.98,
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
    final theme = Theme.of(context);
    final typeColor = _getTypeColor(widget.filterType);
    final typeLightColor = _getTypeLightColor(widget.filterType);
    final typeLabel = _getTypeLabel(widget.filterType);
    final typeIcon = _getTypeIcon(widget.filterType);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: ds.Durations.normal,
              curve: ds.AnimationCurves.easeOut,
              padding: EdgeInsets.all(ds.Spacing.md),
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          typeColor,
                          typeColor.withOpacity(0.8),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.surface,
                          typeLightColor.withOpacity(0.1),
                        ],
                      ),
                borderRadius: ds.BorderRadii.card,
                border: Border.all(
                  color: widget.isSelected 
                      ? typeColor
                      : theme.colorScheme.outline.withOpacity(0.2),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: widget.isSelected 
                    ? ds.Shadows.elevation3
                    : ds.Shadows.elevation1,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(ds.Spacing.sm),
                    decoration: BoxDecoration(
                      color: widget.isSelected 
                          ? Colors.white.withOpacity(0.2)
                          : typeLightColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(ds.BorderRadiusValues.md),
                    ),
                    child: Icon(
                      typeIcon,
                      size: 28,
                      color: widget.isSelected 
                          ? Colors.white
                          : typeColor,
                    ),
                  ),
                  SizedBox(height: ds.Spacing.sm),
                  Text(
                    typeLabel,
                    style: ds.PayeeTextStyles.remark.copyWith(
                      color: widget.isSelected 
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontWeight: ds.FontWeights.medium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ds.Spacing.xs),
                  Text(
                    '${widget.count}个',
                    style: ds.PayeeTextStyles.pageTitle.copyWith(
                      color: widget.isSelected 
                          ? Colors.white
                          : typeColor,
                      fontWeight: ds.FontWeights.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getTypeColor(PayeeFilterType type) {
    switch (type) {
      case PayeeFilterType.incomeEnabled:
        return ds.PayeeColors.incomeEnabled;
      case PayeeFilterType.expenseEnabled:
        return ds.PayeeColors.expenseEnabled;
      case PayeeFilterType.enabled:
        return ds.PayeeColors.enabled;
      case PayeeFilterType.disabled:
        return ds.PayeeColors.disabled;
      case PayeeFilterType.all:
      default:
        return ds.PayeeColors.primary;
    }
  }

  Color _getTypeLightColor(PayeeFilterType type) {
    switch (type) {
      case PayeeFilterType.incomeEnabled:
        return ds.PayeeColors.incomeEnabledLight;
      case PayeeFilterType.expenseEnabled:
        return ds.PayeeColors.expenseEnabledLight;
      case PayeeFilterType.enabled:
        return ds.PayeeColors.enabledLight;
      case PayeeFilterType.disabled:
        return ds.PayeeColors.disabledLight;
      case PayeeFilterType.all:
      default:
        return ds.PayeeColors.primaryLight;
    }
  }

  String _getTypeLabel(PayeeFilterType type) {
    switch (type) {
      case PayeeFilterType.all:
        return '全部';
      case PayeeFilterType.incomeEnabled:
        return '收入权限';
      case PayeeFilterType.expenseEnabled:
        return '支出权限';
      case PayeeFilterType.enabled:
        return '启用状态';
      case PayeeFilterType.disabled:
        return '停用状态';
    }
  }

  IconData _getTypeIcon(PayeeFilterType type) {
    switch (type) {
      case PayeeFilterType.all:
        return ds.PayeeStatusIcons.payee;
      case PayeeFilterType.incomeEnabled:
        return ds.PayeeStatusIcons.incomeEnabled;
      case PayeeFilterType.expenseEnabled:
        return ds.PayeeStatusIcons.expenseEnabled;
      case PayeeFilterType.enabled:
        return ds.PayeeStatusIcons.enabled;
      case PayeeFilterType.disabled:
        return ds.PayeeStatusIcons.disabled;
    }
  }
}