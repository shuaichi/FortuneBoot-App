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

/// 4. 列表项组件 (已完美修复 Flex 约束溢出 BUG)
class HJListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? valueText;
  final Widget? trailing;
  final VoidCallback onTap;
  final double height;
  final Color? valueColor;

  const HJListItem.chevron({super.key, required this.icon, required this.title, required this.onTap})
      : height = 56.0, trailing = const Icon(Icons.chevron_right, size: 16, color: Colors.grey), valueText = null, valueColor = null, subtitle = null;

  const HJListItem.value({super.key, required this.icon, required this.title, required this.valueText, required this.onTap, this.valueColor})
      : height = 56.0, subtitle = null, trailing = const Icon(Icons.chevron_right, size: 16, color: Colors.grey);

  const HJListItem.account({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap})
      : height = 72.0, trailing = const Icon(Icons.chevron_right, size: 16, color: Colors.grey), valueText = null, valueColor = null;

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
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: Colors.grey[50], shape: BoxShape.circle),
                  child: Icon(icon, size: 18, color: Colors.black87),
                ),
                const SizedBox(width: HJSpacing.md),
                // 【修复核心】：使用内部 Row + Expanded(flex:1) + Flexible(flex:2) 严格管控边界
                Expanded(
                  child: Row(
                    children:[
                      Expanded(
                        flex: 1, // 确保标题至少能占据1份空间，不会被挤成竖排
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
                      if (valueText != null) ...[
                        const SizedBox(width: HJSpacing.sm),
                        Flexible(
                          flex: 2, // 允许超长内容(如API URL)占据最多2份空间，超出则截断
                          child: Text(
                            valueText!,
                            style: HJTypography.tabularBody.copyWith(color: valueColor ?? Colors.grey[500]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: HJSpacing.sm), trailing!]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 5. 按钮系统
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
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
          child: Text(widget.text, style: TextStyle(color: fgColor, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

/// 6. 头像区域
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
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Text(initials, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
          ),
          const SizedBox(width: HJSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onViewProfile,
                  child: Row(
                    children:[
                      Text('查看个人资料', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 11, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(icon: Icon(Icons.qr_code, color: Colors.grey[600]), onPressed: onShowQRCode),
        ],
      ),
    );
  }
}