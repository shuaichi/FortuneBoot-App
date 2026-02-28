import 'package:flutter/material.dart';
import 'package:hjproject/home/setting_page/models/mine_setting.dart';

/// 通用的设置项列表组件 - Refactored for Design Skill
/// - Height: 56px
/// - Typography: Title 15px W500, Subtitle 13px Grey
/// - Interaction: InkWell feedback
class SettingItemTile extends StatelessWidget {
  final Setting element;
  final ValueChanged<Setting> onSelectSetting;
  final ValueChanged<Setting> onTapSetting;

  const SettingItemTile({
    super.key,
    required this.element,
    required this.onSelectSetting,
    required this.onTapSetting,
  });

  @override
  Widget build(BuildContext context) {
    // Determine content based on type
    Widget? leading = element.leadingWidget;
    String title = element.type.title;
    String? subtitle = element.content ?? element.detail;
    VoidCallback onTap = () => onTapSetting(element);

    if (element.type == SettingType.currentGroup) {
      leading = leading ??
          const Icon(
            Icons.group_outlined,
            color: Colors.black87,
            size: 20,
          );
      subtitle = element.content ?? '未选择';
      onTap = () => onSelectSetting(element);
    } else if (element.type == SettingType.currentBook) {
      leading = leading ??
          const Icon(
            Icons.book_outlined,
            color: Colors.black87,
            size: 20,
          );
      subtitle = element.content ?? '未选择';
      onTap = () => onSelectSetting(element);
    } else if (element.type == SettingType.accountOverview) {
      leading = leading ??
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: Colors.black87,
            size: 20,
          );
      title = '账户概览';
      subtitle = element.detail;
      onTap = () => onTapSetting(element);
    } else {
      // Default icon handling if not provided
      leading = leading ??
          Icon(
            _getIconForType(element.type),
            color: Colors.black87,
            size: 20,
          );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 56, // Component Standard: Min height 56
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Icon Circle (Optional: can be removed if prefer plain icon)
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  shape: BoxShape.circle,
                ),
                child: leading,
              ),
              const SizedBox(width: 16),
              
              // Title
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87, // Token: Primary Text
                  ),
                ),
              ),

              // Subtitle & Trailing
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500], // Token: Hint Text
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 8),
              ],
              
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(SettingType type) {
    switch (type) {
      case SettingType.username:
        return Icons.person_outline;
      case SettingType.currentTheme:
        return Icons.color_lens_outlined;
      case SettingType.currentLanguage:
        return Icons.language_outlined;
      case SettingType.api:
        return Icons.api_outlined;
      case SettingType.currentVersion:
        return Icons.info_outline;
      case SettingType.apiVersion:
        return Icons.cloud_outlined;
      default:
        return Icons.settings_outlined;
    }
  }
}