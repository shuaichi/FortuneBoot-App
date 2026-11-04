import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

/// 连续业务列表的单一表面：行间使用细分隔线，不为每行重复制造卡片。
class FxListSection extends StatelessWidget {
  const FxListSection({
    super.key,
    required this.children,
    this.dividerIndent = 64,
  });

  final List<Widget> children;
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Material(
      color: palette.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: palette.border.withValues(alpha: 0.72)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0)
              Divider(
                height: 1,
                thickness: 0.5,
                indent: dividerIndent,
                color: palette.border.withValues(alpha: 0.72),
              ),
            children[index],
          ],
        ],
      ),
    );
  }
}
