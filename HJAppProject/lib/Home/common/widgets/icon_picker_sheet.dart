import 'package:flutter/material.dart';
import 'package:hjproject/util/app_icon.dart';

/// 用户点击「恢复默认」时返回的标记值。
///
/// 选择器统一返回 `String?`：
/// - `null`：用户取消（未做选择）
/// - 空字符串 [kIconPickerReset]：用户选择「恢复默认」
/// - 其它：选中的图标名
const String kIconPickerReset = '';

/// 弹出图标选择器，返回用户选择的图标名。
///
/// - [selected]：当前已选图标名，用于高亮；
/// - [defaultIconName]：传入后标题栏显示「恢复默认」按钮，点击返回 [kIconPickerReset]；
/// - [groups]：自定义分组，默认使用 [AppIcon.groups]。
///
/// 与项目其它底部弹窗保持一致：`useRootNavigator + isScrollControlled`，
/// 内容用带圆角的容器承载。
Future<String?> showIconPickerSheet({
  required BuildContext context,
  required String title,
  String? selected,
  String? defaultIconName,
  List<AppIconGroup>? groups,
}) {
  final List<AppIconGroup> data = groups ?? AppIcon.groups;
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) {
      final ThemeData theme = Theme.of(ctx);
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (defaultIconName != null)
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, kIconPickerReset),
                      child: const Text('恢复默认'),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  final AppIconGroup group = data[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 8),
                        child: Text(
                          group.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: group.names
                            .map((String name) => _buildCell(ctx, name, selected))
                            .whereType<Widget>()
                            .toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// 构建单个图标格子；映射表未收录的图标名返回 null 由调用方过滤。
Widget? _buildCell(BuildContext ctx, String name, String? selected) {
  final IconData? icon = AppIcon.resolve(name);
  if (icon == null) return null;
  return _IconCell(
    icon: icon,
    selected: selected != null && selected == name,
    onTap: () => Navigator.pop(ctx, name),
  );
}

class _IconCell extends StatelessWidget {
  const _IconCell({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primary = theme.colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: selected
              ? primary.withOpacity(0.12)
              : theme.colorScheme.surfaceVariant.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Icon(
          icon,
          size: 22,
          color: selected ? primary : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
