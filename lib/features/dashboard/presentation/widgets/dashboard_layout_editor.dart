import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/dashboard_display_preferences.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/dashboard_card_titles.dart';
import 'package:fortuneboot/features/dashboard/presentation/widgets/dashboard_layout_controller.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 编辑态底部工具区：可放置卡片 + 恢复默认（排序在首页网格上长按拖拽完成）。
class DashboardLayoutTray extends StatelessWidget {
  const DashboardLayoutTray({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard =
        context.select<PreferencesCubit, DashboardDisplayPreferences>(
          (c) => c.state.dashboard,
        );
    final snap = DashboardLayoutController.snapshot(dashboard);
    final palette = FxPalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            FxSpacing.lg,
            FxSpacing.sm,
            FxSpacing.lg,
            FxSpacing.sm,
          ),
          child: Text(
            S.of(context).dashboardDragToReorder,
            style: FxTypography.caption.copyWith(color: palette.textTertiary),
          ),
        ),
        if (snap.placeable.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg,
              FxSpacing.sm,
              FxSpacing.lg,
              FxSpacing.sm,
            ),
            child: Text(
              S.of(context).dashboardHiddenCards,
              style: FxTypography.label.copyWith(color: palette.textSecondary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: FxSpacing.lg),
            child: Wrap(
              spacing: FxSpacing.sm,
              runSpacing: FxSpacing.sm,
              children: snap.placeable.map((id) {
                return FxTagChip(
                  label: dashboardCardTitle(context, id),
                  onTap: () => DashboardLayoutController.place(
                    context,
                    id: id,
                    visible: snap.visible,
                    placeable: snap.placeable,
                    hidden: snap.hidden,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(
            FxSpacing.lg,
            FxSpacing.md,
            FxSpacing.lg,
            FxSpacing.lg,
          ),
          child: FxButton.text(
            label: S.of(context).dashboardResetLayout,
            onPressed: () => DashboardLayoutController.reset(context),
          ),
        ),
      ],
    );
  }
}
