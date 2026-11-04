import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

/// 首启页骨架：宽度使用居中的安静单列，内容从顶部开始阅读。
///
/// @author JoyCode
/// @since 2026/11/04
class AuthScaffold extends StatelessWidget {
  /// 创建认证页面骨架。
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions = const [],
    this.onTitleTap,
  });

  /// 主标题。
  final String title;

  /// 辅助说明。
  final String subtitle;

  /// 表单或加载内容。
  final Widget child;

  /// 页面级操作，例如语言切换。
  final List<Widget> actions;

  /// 标题点击回调，用于保留首启页无视觉干扰的开发者入口。
  final VoidCallback? onTitleTap;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      backgroundColor: palette.surface,
      body: SafeArea(
        bottom: !keyboardVisible,
        // 首启页内容保持从上到下阅读，不再用 Center 在桌面 / 平板上制造
        // 上下各数百像素的空白。
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (actions.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTitleTap,
                    child: Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: textTheme.headlineSmall?.copyWith(
                          fontSize: 28,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  if (subtitle.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
