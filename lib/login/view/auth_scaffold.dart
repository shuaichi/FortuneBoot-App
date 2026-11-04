import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 首启与认证共用骨架：所有宽度均使用居中的安静单列。
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight - 48;
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: availableHeight > 0 ? availableHeight : 0,
                ),
                child: Center(
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
            );
          },
        ),
      ),
    );
  }
}

/// 认证表单统一输入装饰，保持亮暗主题、焦点和边框一致。
InputDecoration authInputDecoration(
  BuildContext context, {
  required String label,
  IconData? icon,
  String? hint,
  Widget? suffixIcon,
}) {
  final palette = FxPalette.of(context);
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: icon == null ? null : Icon(icon, size: 20),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: palette.surfaceMuted,
    labelStyle: FxTypography.label.copyWith(color: palette.textSecondary),
    hintStyle: FxTypography.body.copyWith(color: palette.textTertiary),
    prefixIconColor: palette.textSecondary,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: FxRadius.tileBorder,
      borderSide: BorderSide(color: palette.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: FxRadius.tileBorder,
      borderSide: BorderSide(color: palette.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: FxRadius.tileBorder,
      borderSide: BorderSide(color: palette.primary, width: 1.5),
    ),
  );
}
