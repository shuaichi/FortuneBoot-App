import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/preferences/stats_display_preferences.dart';
import 'package:fortuneboot/features/stats/data/stats_card_catalog.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

String statsCardTitle(BuildContext context, StatsCardId id, {bool expense = true}) {
  final s = S.of(context);
  return switch (id) {
    StatsCardId.moreReports => s.statsMoreReports,
    StatsCardId.overview => '${s.statsExpense} / ${s.statsIncome}',
    StatsCardId.calendar => s.statsIncomeExpenseCalendar,
    StatsCardId.insight => s.statsBasicTitle,
    StatsCardId.dimensionPreview =>
      expense ? s.statsExpenseAnalytics : s.statsIncomeAnalytics,
    StatsCardId.trend => expense ? s.statsExpenseTrend : s.statsIncomeTrend,
    StatsCardId.categoryShare =>
      expense ? s.statsExpenseCategoryShare : s.statsIncomeCategoryShare,
    StatsCardId.tags => expense ? s.statsExpenseTags : s.statsIncomeTags,
    StatsCardId.payees => expense ? s.statsExpensePayees : s.statsIncomePayees,
  };
}

/// 统计布局读写。
abstract final class StatsLayoutController {
  static ({
    List<StatsCardId> order,
    Set<StatsCardId> hidden,
    List<StatsCardId> visible,
    List<StatsCardId> placeable,
  })
  snapshot(StatsDisplayPreferences prefs) {
    final order = StatsCardCatalog.normalizeOrder(prefs.cardOrder);
    final hidden = StatsCardCatalog.normalizeHidden(
      prefs.hiddenCardIds,
      layoutConfigured: prefs.layoutConfigured,
    );
    final visible = order.where((id) => !hidden.contains(id)).toList();
    final placeable = order.where(hidden.contains).toList();
    return (
      order: order,
      hidden: hidden,
      visible: visible,
      placeable: placeable,
    );
  }

  static Future<void> persist(
    BuildContext context, {
    required List<StatsCardId> order,
    required Set<StatsCardId> hidden,
  }) async {
    final saved = await context.read<PreferencesCubit>().setStatsLayout(
      order: order,
      hidden: hidden,
    );
    if (!saved && context.mounted) {
      FxFeedback.error(context, message: S.of(context).profileSaveFailedRetry);
    }
  }

  static Future<void> hide(
    BuildContext context, {
    required StatsCardId id,
    required List<StatsCardId> order,
    required Set<StatsCardId> hidden,
  }) async {
    HapticFeedback.lightImpact();
    await persist(context, order: order, hidden: {...hidden, id});
  }

  static Future<void> place(
    BuildContext context, {
    required StatsCardId id,
    required List<StatsCardId> visible,
    required List<StatsCardId> placeable,
    required Set<StatsCardId> hidden,
  }) async {
    HapticFeedback.selectionClick();
    final nextHidden = {...hidden}..remove(id);
    await persist(
      context,
      order: [...visible, id, ...placeable.where((e) => e != id)],
      hidden: nextHidden,
    );
  }

  static Future<void> reset(BuildContext context) async {
    HapticFeedback.selectionClick();
    final saved = await context.read<PreferencesCubit>().resetStatsLayout();
    if (!saved && context.mounted) {
      FxFeedback.error(context, message: S.of(context).profileSaveFailedRetry);
    }
  }
}

/// 编辑态：长按拖到另一张卡片上换位。
class StatsDraggableCard extends StatefulWidget {
  const StatsDraggableCard({
    super.key,
    required this.id,
    required this.child,
    required this.onRemove,
    required this.onInsertNear,
    this.onDragStarted,
    this.onDragEnded,
  });

  final StatsCardId id;
  final Widget child;
  final VoidCallback onRemove;
  final void Function(StatsCardId from, StatsCardId to, {required bool after})
  onInsertNear;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;

  @override
  State<StatsDraggableCard> createState() => _StatsDraggableCardState();
}

class _StatsDraggableCardState extends State<StatsDraggableCard> {
  bool _dragging = false;

  void _setDragging(bool value) {
    if (_dragging == value) return;
    setState(() => _dragging = value);
    if (value) {
      widget.onDragStarted?.call();
    } else {
      widget.onDragEnded?.call();
    }
  }

  void _maybeInsert(DragTargetDetails<StatsCardId> details) {
    if (details.data == widget.id) return;
    final box = context.findRenderObject();
    var after = false;
    if (box is RenderBox && box.hasSize) {
      final local = box.globalToLocal(details.offset);
      after = local.dy > box.size.height * 0.45;
    }
    widget.onInsertNear(details.data, widget.id, after: after);
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return DragTarget<StatsCardId>(
      onWillAcceptWithDetails: (details) => details.data != widget.id,
      onMove: _maybeInsert,
      builder: (context, candidateData, rejectedData) {
        final dropTarget = candidateData.isNotEmpty;
        return LongPressDraggable<StatsCardId>(
          data: widget.id,
          delay: const Duration(milliseconds: 280),
          hapticFeedbackOnStart: true,
          rootOverlay: true,
          onDragStarted: () => _setDragging(true),
          onDragEnd: (_) => _setDragging(false),
          feedback: Material(
            elevation: 10,
            color: Colors.transparent,
            borderRadius: FxRadius.tileBorder,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width - FxSpacing.lg * 2,
              child: Opacity(opacity: 0.95, child: widget.child),
            ),
          ),
          childWhenDragging: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: FxRadius.tileBorder,
              border: Border.all(
                color: palette.primary.withValues(alpha: 0.35),
                width: 2,
              ),
              color: palette.primary.withValues(alpha: 0.06),
            ),
            child: const SizedBox(height: 72, width: double.infinity),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IgnorePointer(child: widget.child),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: FxRadius.tileBorder,
                    border: Border.all(
                      color: dropTarget || _dragging
                          ? palette.primary
                          : palette.primary.withValues(alpha: 0.4),
                      width: dropTarget || _dragging ? 2 : 1,
                    ),
                    color: dropTarget
                        ? palette.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Material(
                  color: palette.surface,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: widget.onRemove,
                    child: Padding(
                      padding: const EdgeInsets.all(FxSpacing.xs),
                      child: Icon(
                        Icons.remove_circle_rounded,
                        size: 22,
                        color: palette.danger,
                        semanticLabel: S.of(context).dashboardRemoveCard,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 编辑态底部：可添加卡片 + 恢复默认。
class StatsLayoutTray extends StatelessWidget {
  const StatsLayoutTray({super.key, this.expense = true});

  final bool expense;

  @override
  Widget build(BuildContext context) {
    final prefs = context.select<PreferencesCubit, StatsDisplayPreferences>(
      (c) => c.state.stats,
    );
    final snap = StatsLayoutController.snapshot(prefs);
    final palette = FxPalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: FxSpacing.md),
        Text(
          S.of(context).dashboardDragToReorder,
          style: FxTypography.caption.copyWith(color: palette.textTertiary),
        ),
        if (snap.placeable.isNotEmpty) ...[
          const SizedBox(height: FxSpacing.md),
          Text(
            S.of(context).dashboardHiddenCards,
            style: FxTypography.label.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: FxSpacing.sm),
          Wrap(
            spacing: FxSpacing.sm,
            runSpacing: FxSpacing.sm,
            children: snap.placeable.map((id) {
              return FxTagChip(
                label: statsCardTitle(context, id, expense: expense),
                onTap: () => StatsLayoutController.place(
                  context,
                  id: id,
                  visible: snap.visible,
                  placeable: snap.placeable,
                  hidden: snap.hidden,
                ),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: FxSpacing.md),
        FxButton.text(
          label: S.of(context).dashboardResetLayout,
          onPressed: () => StatsLayoutController.reset(context),
        ),
      ],
    );
  }
}
