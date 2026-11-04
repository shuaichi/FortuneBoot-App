import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';

/// 具备原生反馈、键盘焦点与最小热区的通用点击区域。
///
/// @author JoyCode
/// @since 2026/11/04
class FxPressable extends StatelessWidget {
  /// 创建一个最小 44×44 的点击区域。
  const FxPressable({
    super.key,
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.borderRadius,
  });

  /// 展示内容。
  final Widget child;

  /// 点击回调；为空时禁用交互。
  final VoidCallback? onPressed;

  /// 无障碍按钮名称。
  final String semanticLabel;

  /// 内容内边距。
  final EdgeInsetsGeometry padding;

  /// 水波纹与焦点边框圆角。
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          canRequestFocus: onPressed != null,
          mouseCursor: onPressed == null
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          borderRadius: borderRadius ?? FxRadius.tileBorder,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            child: Padding(
              padding: padding,
              child: Center(widthFactor: 1, heightFactor: 1, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
