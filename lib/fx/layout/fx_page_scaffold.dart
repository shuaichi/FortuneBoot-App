import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 二级页面统一骨架：顶部返回 + 标题 + 页面操作，内容占满剩余高度。
///
/// 日志、导入导出、核对报告、设置等页面不再各自搭建 AppBar / 自定义页头。
class FxPageScaffold extends StatelessWidget {
  const FxPageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.onBack,
    this.showBack = true,
    this.safeAreaBottom = true,
    this.resizeToAvoidBottomInset = true,
  });

  /// 页面标题。
  final String title;

  /// 页面主体。
  final Widget child;

  /// 标题右侧操作。
  final List<Widget> actions;

  /// 返回回调；为空时执行 `Navigator.maybePop`。
  final VoidCallback? onBack;

  /// 是否展示返回按钮；主壳内一级页面可关闭。
  final bool showBack;

  /// 是否让页面主体避开底部安全区。
  final bool safeAreaBottom;

  /// 键盘弹起时是否压缩页面。
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final localizations = MaterialLocalizations.of(context);
    return Scaffold(
      backgroundColor: palette.canvas,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(
        bottom: safeAreaBottom,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FxSpacing.sm,
                FxSpacing.sm,
                FxSpacing.lg,
                FxSpacing.sm,
              ),
              child: Row(
                children: [
                  if (showBack)
                    FxIconButton(
                      icon: Icons.chevron_left_rounded,
                      tooltip: localizations.backButtonTooltip,
                      onPressed:
                          onBack ?? () => Navigator.of(context).maybePop(),
                    )
                  else
                    const SizedBox(width: FxSpacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      style: FxTypography.title.copyWith(
                        color: palette.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  for (final action in actions) ...[
                    const SizedBox(width: FxSpacing.xs),
                    action,
                  ],
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
