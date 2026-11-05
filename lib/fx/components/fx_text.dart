import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

/// 内容角色决定字号，语义强调决定颜色。
enum FxTextRole { display, section, title, body, bodyStrong, label, caption }

/// 文本色阶始终使用可读前景，禁用控件不应通过正文色模拟。
enum FxTextTone { primary, secondary, tertiary }

/// 可换行、跟随系统字号且带标题语义的通用文本。
///
/// @author JoyCode
/// @since 2026/11/05
class FxText extends StatelessWidget {
  /// 未指定行数时完整显示内容；仅在明确的摘要位置显式限制 [maxLines]。
  const FxText(
    this.text, {
    super.key,
    this.role = FxTextRole.body,
    this.tone = FxTextTone.primary,
    this.textAlign,
    this.maxLines,
    this.semanticsLabel,
  });

  /// 展示内容。
  final String text;

  /// 内容在页面中的角色。
  final FxTextRole role;

  /// 前景强调级别。
  final FxTextTone tone;

  /// 文本对齐方式。
  final TextAlign? textAlign;

  /// 可选摘要行数。
  final int? maxLines;

  /// 可选辅助技术朗读内容。
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final typography = Theme.of(context).textTheme;
    final style = switch (role) {
      FxTextRole.display => typography.displaySmall,
      FxTextRole.section => typography.titleLarge,
      FxTextRole.title => typography.titleMedium,
      FxTextRole.body => typography.bodyLarge,
      FxTextRole.bodyStrong => typography.titleSmall,
      FxTextRole.label => typography.labelMedium,
      FxTextRole.caption => typography.bodySmall,
    };
    final color = switch (tone) {
      FxTextTone.primary => palette.textPrimary,
      FxTextTone.secondary => palette.textSecondary,
      FxTextTone.tertiary => palette.textTertiary,
    };
    return Semantics(
      header:
          role == FxTextRole.display ||
          role == FxTextRole.section ||
          role == FxTextRole.title,
      child: Text(
        text,
        style: style?.copyWith(color: color),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: maxLines == null
            ? TextOverflow.visible
            : TextOverflow.ellipsis,
        semanticsLabel: semanticsLabel,
      ),
    );
  }
}
