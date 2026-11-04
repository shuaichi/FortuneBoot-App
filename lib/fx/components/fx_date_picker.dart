import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 统一日期 / 日期时间选择器：FxSheet 风格底部弹层 + Cupertino 滚轮 + 快捷项。
///
/// - [showFxDatePicker]：仅日期。
/// - [showFxDateTimePicker]：日期 + 时间（24 小时）。
///
/// 取代散落各页的 `showDatePicker` / `showOmniDateTimePicker`，保证亮暗一致。
Future<DateTime?> showFxDateTimePicker(
  BuildContext context, {
  DateTime? initial,
  DateTime? firstDate,
  DateTime? lastDate,
  String? title,
}) {
  return _showFxPicker(
    context,
    mode: CupertinoDatePickerMode.dateAndTime,
    initial: initial,
    firstDate: firstDate,
    lastDate: lastDate,
    title: title ?? S.of(context).fxDatePickerDateTimeTitle,
  );
}

Future<DateTime?> showFxDatePicker(
  BuildContext context, {
  DateTime? initial,
  DateTime? firstDate,
  DateTime? lastDate,
  String? title,
}) {
  return _showFxPicker(
    context,
    mode: CupertinoDatePickerMode.date,
    initial: initial,
    firstDate: firstDate,
    lastDate: lastDate,
    title: title ?? S.of(context).fxDatePickerDateTitle,
  );
}

Future<DateTime?> _showFxPicker(
  BuildContext context, {
  required CupertinoDatePickerMode mode,
  DateTime? initial,
  DateTime? firstDate,
  DateTime? lastDate,
  required String title,
}) {
  return FxSheet.show<DateTime>(
    context,
    title: title,
    child: _FxDatePickerSheet(
      mode: mode,
      initial: initial ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    ),
  );
}

class _FxDatePickerSheet extends StatefulWidget {
  final CupertinoDatePickerMode mode;
  final DateTime initial;
  final DateTime firstDate;
  final DateTime lastDate;

  const _FxDatePickerSheet({
    required this.mode,
    required this.initial,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_FxDatePickerSheet> createState() => _FxDatePickerSheetState();
}

class _FxDatePickerSheetState extends State<_FxDatePickerSheet> {
  late DateTime _value = _clamp(widget.initial);
  var _pickerRevision = 0;

  DateTime _clamp(DateTime d) {
    if (d.isBefore(widget.firstDate)) return widget.firstDate;
    if (d.isAfter(widget.lastDate)) return widget.lastDate;
    return d;
  }

  bool get _isDateTime => widget.mode == CupertinoDatePickerMode.dateAndTime;

  void _setQuick(DateTime base) {
    // 日期模式取零点；日期时间模式保留当前时分。
    final next = _isDateTime
        ? DateTime(base.year, base.month, base.day, _value.hour, _value.minute)
        : DateTime(base.year, base.month, base.day);
    setState(() {
      _value = _clamp(next);
      _pickerRevision++;
    });
  }

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  DateTime? _shiftedYearValue(int delta) {
    final year = _value.year + delta;
    if (year < widget.firstDate.year || year > widget.lastDate.year) {
      return null;
    }

    final day = _value.day.clamp(1, _daysInMonth(year, _value.month));
    final candidate = _isDateTime
        ? DateTime(year, _value.month, day, _value.hour, _value.minute)
        : DateTime(year, _value.month, day);
    if (candidate.isBefore(widget.firstDate) ||
        candidate.isAfter(widget.lastDate)) {
      return null;
    }
    return candidate;
  }

  bool _canShiftYear(int delta) => _shiftedYearValue(delta) != null;

  void _shiftYear(int delta) {
    final next = _shiftedYearValue(delta);
    if (next == null) return;
    HapticFeedback.selectionClick();
    setState(() {
      _value = next;
      _pickerRevision++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final now = DateTime.now();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: FxSpacing.pageH,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(_value),
              child: Text(
                S.of(context).fxDatePickerDone,
                style: FxTypography.bodyStrong.copyWith(color: palette.primary),
              ),
            ),
          ),
        ),
        Divider(height: 1, color: palette.border),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            FxSpacing.lg,
            FxSpacing.md,
            FxSpacing.lg,
            FxSpacing.sm,
          ),
          child: _valueHeader(context, palette),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: FxSpacing.pageH,
          child: Row(
            spacing: FxSpacing.sm,
            children: [
              _quickAction(
                palette,
                icon: Icons.today_outlined,
                label: S.of(context).fxDatePickerToday,
                onTap: () => _setQuick(now),
              ),
              _quickAction(
                palette,
                icon: Icons.history_rounded,
                label: S.of(context).fxDatePickerYesterday,
                onTap: () => _setQuick(now.subtract(const Duration(days: 1))),
              ),
              _quickAction(
                palette,
                icon: Icons.calendar_month_outlined,
                label: S.of(context).fxDatePickerStartOfMonth,
                onTap: () => _setQuick(DateTime(now.year, now.month)),
              ),
            ],
          ),
        ),
        const SizedBox(height: FxSpacing.md),
        SizedBox(
          height: 216,
          child: CupertinoTheme(
            data: CupertinoThemeData(
              brightness: Theme.of(context).brightness,
              textTheme: CupertinoTextThemeData(
                dateTimePickerTextStyle: FxTypography.bodyStrong.copyWith(
                  color: palette.textPrimary,
                ),
              ),
            ),
            child: CupertinoDatePicker(
              // 快捷项和年份调整时递增 revision 以重建滚轮；
              // 普通滚动只刷新摘要，不会打断用户滑动。
              key: ValueKey(_pickerRevision),
              mode: widget.mode,
              initialDateTime: _value,
              minimumDate: widget.firstDate,
              maximumDate: widget.lastDate,
              use24hFormat: true,
              selectionOverlayBuilder:
                  (context, {required selectedIndex, required columnCount}) =>
                      _selectionOverlay(
                        palette,
                        selectedIndex: selectedIndex,
                        columnCount: columnCount,
                      ),
              onDateTimeChanged: (d) => setState(() => _value = d),
            ),
          ),
        ),
      ],
    );
  }

  Widget _valueHeader(BuildContext context, FxPalette palette) {
    final locale = Localizations.localeOf(context).toString();
    final date = MaterialLocalizations.of(context).formatFullDate(_value);
    final summary = _isDateTime
        ? '$date · ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(_value), alwaysUse24HourFormat: true)}'
        : date;
    final stepper = DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: FxRadius.cardBorder,
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FxIconButton(
            icon: Icons.chevron_left_rounded,
            tooltip: S.of(context).fxDatePickerPreviousYear,
            onPressed: _canShiftYear(-1) ? () => _shiftYear(-1) : null,
            color: palette.textSecondary,
          ),
          Semantics(
            label: '$locale ${_value.year}',
            child: Text(
              '${_value.year}',
              style: FxTypography.bodyStrong.copyWith(
                color: palette.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          FxIconButton(
            icon: Icons.chevron_right_rounded,
            tooltip: S.of(context).fxDatePickerNextYear,
            onPressed: _canShiftYear(1) ? () => _shiftYear(1) : null,
            color: palette.textSecondary,
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.maxWidth < 360 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.5;
        final valueText = Text(
          summary,
          maxLines: isCompact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          style: FxTypography.bodyStrong.copyWith(
            color: palette.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        );
        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              valueText,
              const SizedBox(height: FxSpacing.xs),
              stepper,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: valueText),
            stepper,
          ],
        );
      },
    );
  }

  Widget _selectionOverlay(
    FxPalette palette, {
    required int selectedIndex,
    required int columnCount,
  }) {
    return CupertinoPickerDefaultSelectionOverlay(
      background: palette.surfaceMuted.withValues(alpha: 0.72),
      capStartEdge: selectedIndex != 0,
      capEndEdge: selectedIndex != columnCount - 1,
    );
  }

  Widget _quickAction(
    FxPalette palette, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: FxRadius.tileBorder,
      child: InkWell(
        borderRadius: FxRadius.tileBorder,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: FxSpacing.md),
          decoration: BoxDecoration(
            color: palette.surfaceMuted,
            borderRadius: FxRadius.tileBorder,
            border: Border.all(color: palette.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: palette.textSecondary),
              const SizedBox(width: FxSpacing.xs),
              Text(
                label,
                style: FxTypography.label.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
