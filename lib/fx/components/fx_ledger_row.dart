import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 高密度流水行：统一标题、元信息、金额和行内操作。
///
/// 320px 窄屏或无障碍字体放大时，金额自动移动到内容下方。
/// 适用于账单、单据、账户流水、转账记录；外层使用 FxListSection 分组，
/// 不再为每一行叠加独立卡片、边框和阴影。
class FxLedgerRow extends StatelessWidget {
  const FxLedgerRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.amount,
    this.amountCaption,
    this.titleAccessory,
    this.details,
    this.actions,
    this.onTap,
    this.semanticLabel,
    this.compact = false,
  });

  /// 用于验证窄屏与字体放大后的自适应布局。
  static const Key stackedContentKey = ValueKey('fx-ledger-stacked-content');

  /// 流水主标题，最多两行。
  final String title;

  /// 分类、账户、时间等次要元信息。
  final String? subtitle;

  /// 业务图标或头像。
  final Widget? leading;

  /// 主金额；由 FxMoneyText 负责格式、隐私和财务语义。
  final Widget? amount;

  /// 金额下方的次要时间或业务说明。
  final String? amountCaption;

  /// 附件、待确认等标题附属状态，不占据主标题层级。
  final Widget? titleAccessory;

  /// 标签或补充明细；无内容时传 null，避免保留空间距。
  final Widget? details;

  /// 行内业务操作；每个操作必须保留独立语义和至少 44pt 热区。
  final List<Widget>? actions;

  /// 打开详情的回调；为空时整行不呈现按钮语义。
  final VoidCallback? onTap;

  /// 整行的无障碍名称。
  final String? semanticLabel;

  /// 紧凑模式减少纵向留白，不改变字号和热区。
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final verticalPadding = compact ? FxSpacing.sm : FxSpacing.md;
    final row = LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 300 || textScale > 1.2;
        final description = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FxTypography.bodyStrong.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (titleAccessory != null) ...[
                  const SizedBox(width: FxSpacing.xs),
                  titleAccessory!,
                ],
              ],
            ),
            if (subtitle?.isNotEmpty == true) ...[
              const SizedBox(height: 3),
              Text(
                subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FxTypography.caption.copyWith(
                  color: palette.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ],
        );
        final amountColumn = amount == null
            ? null
            : SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: amount,
                    ),
                    if (amountCaption?.isNotEmpty == true) ...[
                      const SizedBox(height: 3),
                      Text(
                        amountCaption!,
                        textAlign: TextAlign.end,
                        style: FxTypography.caption.copyWith(
                          color: palette.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              );
        return Column(
          key: stacked ? stackedContentKey : null,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: FxSpacing.md),
                ],
                Expanded(
                  child: stacked
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            description,
                            if (amountColumn != null) ...[
                              const SizedBox(height: FxSpacing.sm),
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: amountColumn,
                              ),
                            ],
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: description),
                            if (amountColumn != null) ...[
                              const SizedBox(width: FxSpacing.md),
                              Flexible(fit: FlexFit.tight, child: amountColumn),
                            ],
                          ],
                        ),
                ),
              ],
            ),
            if (details != null) ...[
              const SizedBox(height: FxSpacing.sm),
              details!,
            ],
            if (actions?.isNotEmpty == true) ...[
              const SizedBox(height: FxSpacing.xs),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Wrap(
                  spacing: FxSpacing.xs,
                  runSpacing: FxSpacing.xs,
                  children: actions!,
                ),
              ),
            ],
          ],
        );
      },
    );
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: FxSpacing.lg,
          vertical: verticalPadding,
        ),
        child: row,
      ),
    );
    if (onTap == null) return content;
    return Semantics(
      button: true,
      enabled: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap!();
          },
          borderRadius: FxRadius.tileBorder,
          hoverColor: palette.surfaceMuted.withValues(alpha: 0.7),
          splashColor: palette.primary.withValues(alpha: 0.06),
          highlightColor: palette.primary.withValues(alpha: 0.04),
          child: content,
        ),
      ),
    );
  }
}
