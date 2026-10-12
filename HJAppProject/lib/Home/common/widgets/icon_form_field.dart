import 'package:flutter/material.dart';
import 'package:hjproject/Home/common/widgets/icon_picker_sheet.dart';
import 'package:hjproject/util/app_icon.dart';

/// 表单中的「图标」选择行。
///
/// 点击后弹出 [showIconPickerSheet]，选中结果通过 [onChanged] 回传：
/// - 选择具体图标 → 回传图标名；
/// - 点击「恢复默认」 → 回传 `null`（表示不使用自定义图标）。
///
/// [value] 为空时展示 [defaultIconName] 对应的预览，并标注为「默认」。
class IconFormField extends StatelessWidget {
  const IconFormField({
    super.key,
    required this.title,
    required this.value,
    required this.defaultIconName,
    required this.onChanged,
    this.subtitle,
    this.enabled = true,
  });

  /// 行标题，如「账户图标」
  final String title;

  /// 可选副标题，用于说明用途
  final String? subtitle;

  /// 当前自定义图标名；为空表示使用默认图标
  final String? value;

  /// 默认图标名（未自定义时展示与「恢复默认」使用）
  final String defaultIconName;

  /// 选择结果回调，`null` 表示恢复默认
  final ValueChanged<String?> onChanged;

  /// 是否可交互（保存中可置为 false 避免重复操作）
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isCustom = value != null && value!.trim().isNotEmpty;
    final String effective = isCustom ? value!.trim() : defaultIconName;
    final IconData preview = AppIcon.resolveOr(effective, Icons.label_outline);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (subtitle != null) ...<Widget>[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pick(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    preview,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isCustom ? effective : '默认图标',
                    style: TextStyle(
                      fontSize: 14,
                      color: isCustom
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    if (!enabled) return;
    final String? picked = await showIconPickerSheet(
      context: context,
      title: title,
      selected: value,
      defaultIconName: defaultIconName,
    );
    // null 表示用户取消，不做改动
    if (picked == null) return;
    onChanged(picked == kIconPickerReset ? null : picked);
  }
}
