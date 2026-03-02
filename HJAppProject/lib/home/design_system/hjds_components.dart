import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'hjds_theme.dart';

/// 1. 全局状态容器 (UIStateHandler)
class UIStateHandler extends StatelessWidget {
  final UIState state;
  final Widget child;
  final VoidCallback? onRetry;

  const UIStateHandler({super.key, required this.state, required this.child, this.onRetry});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case UIState.loading:
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      case UIState.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: HJSpacing.md),
              const Text('加载失败'),
              if (onRetry != null) ...[
                const SizedBox(height: HJSpacing.md),
                HJButton.secondary(text: '重试', onPressed: onRetry!),
              ]
            ],
          ),
        );
      case UIState.empty:
        return const Center(child: Text('暂无数据', style: TextStyle(color: Colors.grey)));
      case UIState.success:
      case UIState.disabled:
        return IgnorePointer(
          ignoring: state == UIState.disabled,
          child: Opacity(opacity: state == UIState.disabled ? 0.38 : 1.0, child: child),
        );
    }
  }
}

/// 2. Profile & Settings 页面标准模板
class HJSettingsTemplate extends StatelessWidget {
  final Widget header;
  final List<Widget> sections;
  final Widget footer;

  const HJSettingsTemplate({super.key, required this.header, required this.sections, required this.footer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers:[
          SliverAppBar(
            backgroundColor: Colors.grey[50],
            elevation: 0,
            pinned: true,
            title: const Text('我的', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          SliverToBoxAdapter(child: header),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: HJSpacing.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) => sections[index], childCount: sections.length),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(padding: const EdgeInsets.all(HJSpacing.lg), child: footer),
          ),
        ],
      ),
    );
  }
}

/// 3. 分组卡片容器
class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const SectionCard({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HJSpacing.md, vertical: HJSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Padding(
            padding: const EdgeInsets.only(left: HJSpacing.sm, bottom: HJSpacing.sm),
            child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[600])),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final isLast = entry.key == items.length - 1;
                return Column(
                  children:[
                    entry.value,
                    if (!isLast) Divider(height: 1, indent: 56, color: Colors.grey[100]),
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

/// 4. 列表项组件 (已完美修复左对齐BUG：强制推向最右侧且防溢出)
abstract class HJBaseListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final double height;

  const HJBaseListItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    required this.height
  });

  Widget buildTrailing(BuildContext context);

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: HJSpacing.md, vertical: HJSpacing.sm),
            child: Row(
              children:[
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: Colors.grey[50], shape: BoxShape.circle),
                  child: Icon(icon, size: 18, color: Colors.black87),
                ),
                const SizedBox(width: HJSpacing.md),
                Expanded(
                  child: Row(
                    children:[
                      // 使用 Expanded 强制占据剩余空间，将后面的 Trailing 推向最右侧
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                            if (subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(subtitle!, style: TextStyle(fontSize: 13, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: HJSpacing.sm), // 保证左右中间留有间距
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
  const HJChevronItem({super.key, required super.icon, required super.title, required super.onTap}) : super(height: 56.0);

  @override
  Widget buildTrailing(BuildContext context) {
    return const Icon(Icons.chevron_right, size: 16, color: Colors.grey);
  }
}

class HJValueItem extends HJBaseListItem {
  final String? valueText;
  final Color? valueColor;

  const HJValueItem({super.key, required super.icon, required super.title, this.valueText, this.valueColor, required super.onTap}) : super(height: 56.0);

  @override
  Widget buildTrailing(BuildContext context) {
    // 灵活收缩包裹右侧内容，不主动扩张
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:[
          if (valueText != null)
            Flexible(
              child: Text(
                valueText!,
                style: HJTypography.tabularBody.copyWith(color: valueColor ?? Colors.grey[500]),
                maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,
              ),
            ),
          const SizedBox(width: HJSpacing.sm),
          const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}

class HJAccountItem extends HJBaseListItem {
  const HJAccountItem({super.key, required super.icon, required super.title, required super.subtitle, required super.onTap}) : super(height: 72.0);

  @override
  Widget buildTrailing(BuildContext context) {
    return const Icon(Icons.chevron_right, size: 16, color: Colors.grey);
  }
}

/// 5. 通用对话框
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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Row(
              children: [
                if (headerIcon != null) ...[
                  Icon(headerIcon, color: headerIconColor ?? Theme.of(context).primaryColor, size: 24),
                  const SizedBox(width: 12),
                ],
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 16),
            content,
            const SizedBox(height: 24),
            Row(
              children: [
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

  const HJButton.primary({super.key, required this.text, required this.onPressed}) : isCritical = false, isSecondary = false;
  const HJButton.secondary({super.key, required this.text, required this.onPressed}) : isCritical = false, isSecondary = true;
  const HJButton.critical({super.key, required this.text, required this.onPressed}) : isCritical = true, isSecondary = false;

  @override
  State<HJButton> createState() => _HJButtonState();
}

class _HJButtonState extends State<HJButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isCritical ? Colors.red : (widget.isSecondary ? Colors.grey[100] : Theme.of(context).primaryColor);
    final fgColor = widget.isCritical ? Colors.white : (widget.isSecondary ? Colors.black87 : Colors.white);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) { setState(() => _isPressed = false); HapticFeedback.lightImpact(); widget.onPressed(); },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0, duration: const Duration(milliseconds: 100),
        child: Container(
          height: 50, alignment: Alignment.center,
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
          child: Text(widget.text, style: TextStyle(color: fgColor, fontSize: 16, fontWeight: FontWeight.bold)),
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

  const HJAvatarSection({super.key, required this.name, required this.role, required this.onViewProfile, required this.onShowQRCode});

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: HJSpacing.md),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children:[
          CircleAvatar(radius: 30, backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1), child: Text(initials, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor))),
          const SizedBox(width: HJSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(height: 4), GestureDetector(onTap: onViewProfile, child: Row(children:[Text('查看个人资料', style: TextStyle(fontSize: 13, color: Colors.grey[600])), const SizedBox(width: 4), Icon(Icons.arrow_forward_ios, size: 11, color: Colors.grey[400])]))])),
          IconButton(icon: Icon(Icons.qr_code, color: Colors.grey[600]), onPressed: onShowQRCode),
        ],
      ),
    );
  }
}