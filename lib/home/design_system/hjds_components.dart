import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'hjds_theme.dart';

/// 1. 全局状态容器 (UIStateHandler)
class UIStateHandler extends StatelessWidget {
  final UIState state;
  final Widget child;
  final VoidCallback? onRetry;

  const UIStateHandler(
      {super.key, required this.state, required this.child, this.onRetry});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case UIState.loading:
        return const Center(
            child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(HJColors.primary))));
      case UIState.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: HJColors.expense.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline,
                    color: HJColors.expense, size: 36),
              ),
              const SizedBox(height: HJSpacing.md),
              const Text('加载失败',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: HJColors.textPrimary)),
              if (onRetry != null) ...[
                const SizedBox(height: HJSpacing.lg),
                SizedBox(
                  width: 120,
                  child: HJButton.secondary(text: '重试', onPressed: onRetry!),
                )
              ]
            ],
          ),
        );
      case UIState.empty:
        return const Center(
            child: Text('暂无数据',
                style: TextStyle(
                    color: HJColors.textSecondary,
                    fontWeight: FontWeight.w500)));
      case UIState.success:
      case UIState.disabled:
        return IgnorePointer(
          ignoring: state == UIState.disabled,
          child: Opacity(
              opacity: state == UIState.disabled ? 0.38 : 1.0, child: child),
        );
    }
  }
}

/// 2. Profile & Settings 页面标准模板
class HJSettingsTemplate extends StatelessWidget {
  final Widget header;
  final List<Widget> sections;
  final Widget footer;

  const HJSettingsTemplate(
      {super.key,
        required this.header,
        required this.sections,
        required this.footer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HJColors.background,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        slivers:[
          const SliverAppBar(
            backgroundColor: HJColors.background,
            elevation: 0,
            pinned: true,
            title: Text('我的',
                style: TextStyle(
                    color: HJColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          SliverToBoxAdapter(child: header),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: HJSpacing.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                      (context, index) => sections[index],
                  childCount: sections.length),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.all(HJSpacing.lg), child: footer),
          ),
        ],
      ),
    );
  }
}

/// 3. 分组卡片容器 (高斯/白卡系统)
class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const SectionCard({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: HJSpacing.md, vertical: HJSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Padding(
            padding:
            const EdgeInsets.only(left: HJSpacing.sm, bottom: HJSpacing.sm),
            child: Text(title.toUpperCase(),
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: HJColors.textSecondary)),
          ),
          Container(
            decoration: BoxDecoration(
              color: HJColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow:[
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final isLast = entry.key == items.length - 1;
                return Column(
                  children:[
                    entry.value,
                    if (!isLast)
                      const Divider(
                          height: 0.5,
                          thickness: 0.5,
                          indent: 64,
                          color: HJColors.divider),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 4. 列表项组件 (Fintech 规范优化)
abstract class HJBaseListItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final double height;

  const HJBaseListItem(
      {super.key,
        required this.icon,
        this.iconColor = HJColors.primary,
        required this.title,
        this.subtitle,
        required this.onTap,
        required this.height});

  bool get expandLeft => false;

  Widget buildTrailing(BuildContext context);

  @override
  Widget build(BuildContext context) {
    Widget leftContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children:[
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: HJColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!,
              style: const TextStyle(fontSize: 14, color: HJColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: HJSpacing.md, vertical: 12.0),
            child: Row(
              children:[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.12),
                      shape: BoxShape.circle),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: HJSpacing.md),
                Expanded(
                  child: Row(
                    children:[
                      expandLeft
                          ? Expanded(child: leftContent)
                          : ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 160),
                        child: leftContent,
                      ),
                      const SizedBox(width: HJSpacing.sm),
                      buildTrailing(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HJChevronItem extends HJBaseListItem {
  const HJChevronItem(
      {super.key,
        required super.icon,
        super.iconColor = HJColors.primary,
        required super.title,
        required super.onTap})
      : super(height: 56.0);

  @override
  bool get expandLeft => true;

  @override
  Widget buildTrailing(BuildContext context) {
    return const Icon(Icons.chevron_right, size: 16, color: HJColors.textSecondary);
  }
}

class HJValueItem extends HJBaseListItem {
  final String? valueText;
  final Color? valueColor;

  const HJValueItem(
      {super.key,
        required super.icon,
        super.iconColor = HJColors.primary,
        required super.title,
        this.valueText,
        this.valueColor,
        required super.onTap})
      : super(height: 56.0);

  @override
  Widget buildTrailing(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children:[
          if (valueText != null)
            Expanded(
              child: Text(
                valueText!,
                style: HJTypography.tabularBody
                    .copyWith(color: valueColor ?? HJColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
          const SizedBox(width: HJSpacing.sm),
          const Icon(Icons.chevron_right, size: 16, color: HJColors.textSecondary),
        ],
      ),
    );
  }
}

class HJAccountItem extends HJBaseListItem {
  const HJAccountItem(
      {super.key,
        required super.icon,
        super.iconColor = HJColors.primary,
        required super.title,
        required super.subtitle,
        required super.onTap})
      : super(height: 72.0);

  @override
  bool get expandLeft => true;

  @override
  Widget buildTrailing(BuildContext context) {
    return const Icon(Icons.chevron_right, size: 16, color: HJColors.textSecondary);
  }
}

/// 5. 通用对话框 (圆角化及空间扩展)
class HJDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final Widget primaryAction;
  final Widget? secondaryAction;
  final IconData? headerIcon;
  final Color? headerIconColor;

  const HJDialog({
    super.key,
    required this.title,
    required this.content,
    required this.primaryAction,
    this.secondaryAction,
    this.headerIcon,
    this.headerIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: HJColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Row(
              children: [
                if (headerIcon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (headerIconColor ?? HJColors.primary)
                          .withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(headerIcon,
                        color: headerIconColor ?? HJColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: HJColors.textPrimary)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            content,
            const SizedBox(height: 28),
            Row(
              children:[
                if (secondaryAction != null) ...[
                  Expanded(child: secondaryAction!),
                  const SizedBox(width: 12),
                ],
                Expanded(child: primaryAction),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 6. 按钮与头像系统
class HJButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isCritical;
  final bool isSecondary;

  const HJButton.primary(
      {super.key, required this.text, required this.onPressed})
      : isCritical = false,
        isSecondary = false;

  const HJButton.secondary(
      {super.key, required this.text, required this.onPressed})
      : isCritical = false,
        isSecondary = true;

  const HJButton.critical(
      {super.key, required this.text, required this.onPressed})
      : isCritical = true,
        isSecondary = false;

  @override
  State<HJButton> createState() => _HJButtonState();
}

class _HJButtonState extends State<HJButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isCritical
        ? HJColors.expense
        : (widget.isSecondary ? HJColors.background : HJColors.primary);
    final fgColor = widget.isCritical
        ? Colors.white
        : (widget.isSecondary ? HJColors.textPrimary : Colors.white);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.mediumImpact();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: bgColor, borderRadius: BorderRadius.circular(16)),
          child: Text(widget.text,
              style: TextStyle(
                  color: fgColor, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class HJAvatarSection extends StatelessWidget {
  final String name;
  final String role;
  final VoidCallback onViewProfile;
  final VoidCallback onShowQRCode;

  const HJAvatarSection(
      {super.key,
        required this.name,
        required this.role,
        required this.onViewProfile,
        required this.onShowQRCode});

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: HJSpacing.md),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: HJColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow:[
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 4),
            )
          ]),
      child: Row(
        children:[
          CircleAvatar(
              radius: 32,
              backgroundColor: HJColors.primary.withOpacity(0.12),
              child: Text(initials,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: HJColors.primary))),
          const SizedBox(width: HJSpacing.md),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Text(name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: HJColors.textPrimary)),
                    const SizedBox(height: 4),
                    GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onViewProfile();
                        },
                        child: Row(children:[
                          const Text('查看个人资料',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: HJColors.textSecondary)),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios,
                              size: 12, color: HJColors.textSecondary)
                        ]))
                  ])),
          IconButton(
              icon: const Icon(Icons.qr_code, color: HJColors.textSecondary),
              onPressed: () {
                HapticFeedback.lightImpact();
                onShowQRCode();
              }),
        ],
      ),
    );
  }
}
// ==========================================
// 以下为基于 Fintech 规范新增的 HJDS 表单与卡片系统
// ==========================================

/// 7. 高级纯白柔和阴影卡片 (用于表单和内容包裹)
class HJPremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const HJPremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(HJSpacing.md),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: HJColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow:[
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 8. 金融级无边框输入框
class HJCustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final bool autoFocus;

  const HJCustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      maxLines: maxLines,
      autofocus: autoFocus,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: HJColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: HJColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: HJSpacing.md, vertical: HJSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: HJColors.background, // 与底色融为一体
        counterText: "",
      ),
    );
  }
}

/// 9. 动态点缀色开关行 (支持触觉反馈)
class HJSwitchRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  const HJSwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: HJSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: HJColors.textPrimary,
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: activeColor ?? HJColors.primary,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

/// 10. 柔和背景图标
class HJSoftIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const HJSoftIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 2,
      height: size * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size, color: color),
    );
  }
}

/// 11. 支持 Loading 状态的表单提交按钮
class HJSubmitButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const HJSubmitButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: isLoading ? null : () {
          if (onPressed != null) {
            HapticFeedback.mediumImpact();
            onPressed!();
          }
        },
        style: FilledButton.styleFrom(
          backgroundColor: HJColors.primary,
          disabledBackgroundColor: HJColors.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}