import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';

/// 图标底色语义。
enum FxIconTone {
  /// 普通入口、记录与设置：单色中性。
  neutral,

  /// 删除、注销等不可逆操作。
  danger,
}

/// 设置 / 系统页的统一图标瓦片。
///
/// 普通功能只使用中性色，避免红绿蓝被误读为状态；只有真正危险的操作用
/// [FxIconTone.danger] 提示。
class FxIconTile extends StatelessWidget {
  const FxIconTile({
    super.key,
    required this.icon,
    this.tone = FxIconTone.neutral,
    this.size = 36,
    this.iconSize,
  });

  /// 图标。
  final IconData icon;

  /// 语义色调。
  final FxIconTone tone;

  /// 瓦片边长。
  final double size;

  /// 图标尺寸；默认按瓦片尺寸的一半取整。
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final color = tone == FxIconTone.danger
        ? palette.danger
        : palette.textSecondary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tone == FxIconTone.danger
            ? palette.danger.withValues(alpha: 0.10)
            : palette.surfaceMuted,
        borderRadius: FxRadius.tileBorder,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize ?? size * 0.55, color: color),
    );
  }
}
