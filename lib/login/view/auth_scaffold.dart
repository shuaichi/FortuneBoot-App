import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 首启与认证共用骨架：窄屏单列，宽屏品牌区与固定宽度表单并列。
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
  });

  /// 主标题。
  final String title;

  /// 辅助说明。
  final String subtitle;

  /// 表单或加载内容。
  final Widget child;

  /// 页面级操作，例如语言切换。
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Scaffold(
      backgroundColor: palette.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 960;
            final introduction = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FORTUNEBOOT',
                  style: FxTypography.label.copyWith(
                    color: palette.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: FxSpacing.xl),
                Text(
                  title,
                  style: FxTypography.display.copyWith(
                    color: palette.textPrimary,
                    fontSize: wide ? 42 : 34,
                    height: 1.12,
                    letterSpacing: -1.1,
                  ),
                ),
                const SizedBox(height: FxSpacing.md),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Text(
                    subtitle,
                    style: FxTypography.body.copyWith(
                      color: palette.textSecondary,
                      height: 1.65,
                    ),
                  ),
                ),
              ],
            );
            final formPanel = Container(
              width: wide ? 420 : double.infinity,
              padding: EdgeInsets.all(wide ? FxSpacing.xxl : 0),
              decoration: wide
                  ? BoxDecoration(
                      color: palette.surface,
                      borderRadius: FxRadius.cardBorder,
                      border: Border.all(color: palette.border),
                    )
                  : null,
              child: child,
            );

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 48 : 20,
                vertical: wide ? 48 : 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    children: [
                      if (actions.isNotEmpty)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: actions,
                          ),
                        ),
                      SizedBox(height: wide ? 64 : 32),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: introduction),
                            const SizedBox(width: 96),
                            formPanel,
                          ],
                        )
                      else ...[
                        introduction,
                        const SizedBox(height: 40),
                        formPanel,
                      ],
                    ],
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
