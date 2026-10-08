import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/preferences/dashboard_display_preferences.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_card_catalog.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 仪表盘布局读写辅助：从 Preferences 解析当前可见/隐藏，并持久化变更。
abstract final class DashboardLayoutController {
  static ({
    List<DashboardCardId> order,
    Set<DashboardCardId> hidden,
    List<DashboardCardId> visible,
    List<DashboardCardId> placeable,
  })
  snapshot(DashboardDisplayPreferences dashboard) {
    final order = DashboardCardCatalog.normalizeOrder(dashboard.cardOrder);
    final hidden = DashboardCardCatalog.normalizeHidden(
      dashboard.hiddenCardIds,
      layoutConfigured: dashboard.layoutConfigured,
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
    required List<DashboardCardId> order,
    required Set<DashboardCardId> hidden,
  }) async {
    final saved = await context.read<PreferencesCubit>().setDashboardLayout(
      order: order,
      hidden: hidden,
    );
    if (!saved && context.mounted) {
      FxFeedback.error(context, message: S.of(context).profileSaveFailedRetry);
    }
  }

  static Future<void> hide(
    BuildContext context, {
    required DashboardCardId id,
    required List<DashboardCardId> order,
    required Set<DashboardCardId> hidden,
  }) async {
    HapticFeedback.lightImpact();
    await persist(context, order: order, hidden: {...hidden, id});
  }

  static Future<void> place(
    BuildContext context, {
    required DashboardCardId id,
    required List<DashboardCardId> visible,
    required List<DashboardCardId> placeable,
    required Set<DashboardCardId> hidden,
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
    final saved = await context.read<PreferencesCubit>().resetDashboardLayout();
    if (!saved && context.mounted) {
      FxFeedback.error(context, message: S.of(context).profileSaveFailedRetry);
    }
  }
}
