import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

class StatsChartTableRow {
  final String label;
  final String value;
  final String? percent;
  final String? detail;
  final Color? color;
  final IconData? icon;

  const StatsChartTableRow({
    required this.label,
    required this.value,
    this.percent,
    this.detail,
    this.color,
    this.icon,
  });
}

/// A thin chart/table toggle used as the WCAG text equivalent for charts.
class StatsChartTableToggle extends StatefulWidget {
  final Widget chart;
  final List<StatsChartTableRow> rows;
  final ValueNotifier<bool>? tableViewNotifier;

  const StatsChartTableToggle({
    super.key,
    required this.chart,
    required this.rows,
    this.tableViewNotifier,
  });

  @override
  State<StatsChartTableToggle> createState() => _StatsChartTableToggleState();
}

class _StatsChartTableToggleState extends State<StatsChartTableToggle> {
  late final ValueNotifier<bool> _internalNotifier;
  ValueNotifier<bool> get _notifier =>
      widget.tableViewNotifier ?? _internalNotifier;

  @override
  void initState() {
    super.initState();
    _internalNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _internalNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _notifier,
      builder: (context, showTable, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FxIconButton(
                icon: showTable
                    ? Icons.pie_chart_rounded
                    : Icons.table_chart_rounded,
                tooltip: showTable
                    ? S.of(context).statsViewChart
                    : S.of(context).statsViewTable,
                onPressed: () => _notifier.value = !showTable,
              ),
            ),
            const SizedBox(height: FxSpacing.xs),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                child: showTable
                    ? _StatsChartDataTable(
                        key: const ValueKey('table'),
                        rows: widget.rows,
                      )
                    : KeyedSubtree(
                        key: const ValueKey('chart'),
                        child: widget.chart,
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatsChartDataTable extends StatelessWidget {
  final List<StatsChartTableRow> rows;

  const _StatsChartDataTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Semantics(
      container: true,
      label: S.of(context).statsTableSemantics(rows.length),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: FxTypography.caption.copyWith(
                color: palette.textSecondary,
                fontWeight: FontWeight.w700,
              ),
              dataTextStyle: FxTypography.caption.copyWith(
                color: palette.textPrimary,
              ),
              horizontalMargin: FxSpacing.sm,
              columnSpacing: FxSpacing.lg,
              columns: [
                DataColumn(label: Text(S.of(context).statsTableItem)),
                DataColumn(label: Text(S.of(context).statsTableValue)),
                DataColumn(label: Text(S.of(context).statsTableShare)),
                DataColumn(label: Text(S.of(context).statsTableDetail)),
              ],
              rows: [
                for (final row in rows)
                  DataRow(
                    cells: [
                      DataCell(_LabelCell(row: row)),
                      DataCell(Text(row.value)),
                      DataCell(Text(row.percent ?? '-')),
                      DataCell(Text(row.detail ?? '-')),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LabelCell extends StatelessWidget {
  final StatsChartTableRow row;

  const _LabelCell({required this.row});

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: (row.color ?? palette.primary).withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: (row.color ?? palette.primary).withValues(alpha: 0.38),
            ),
          ),
          child: row.icon == null
              ? Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: row.color ?? palette.primary,
                    shape: BoxShape.circle,
                  ),
                )
              : Icon(row.icon, size: 12, color: row.color ?? palette.primary),
        ),
        const SizedBox(width: FxSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(row.label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
