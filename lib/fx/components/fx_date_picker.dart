import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
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
  final palette = FxPalette.of(context);
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: palette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: FxRadius.sheetRadius),
    ),
    builder: (ctx) => _FxDatePickerSheet(
      mode: mode,
      initial: initial ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      title: title,
    ),
  );
}

class _FxDatePickerSheet extends StatefulWidget {
  final CupertinoDatePickerMode mode;
  final DateTime initial;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;

  const _FxDatePickerSheet({
    required this.mode,
    required this.initial,
    required this.firstDate,
    required this.lastDate,
    required this.title,
  });

  @override
  State<_FxDatePickerSheet> createState() => _FxDatePickerSheetState();
}

class _FxDatePickerSheetState extends State<_FxDatePickerSheet> {
  late DateTime _value = _clamp(widget.initial);

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
    setState(() => _value = _clamp(next));
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final now = DateTime.now();
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: FxSpacing.sm),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: palette.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          Padding(
            padding: FxSpacing.pageH,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: FxTypography.title.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_value),
                  child: Text(
                    S.of(context).fxDatePickerDone,
                    style: FxTypography.bodyStrong.copyWith(
                      color: palette.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: FxSpacing.sm),
          Padding(
            padding: FxSpacing.pageH,
            child: Wrap(
              spacing: FxSpacing.sm,
              children: [
                _quickChip(
                  palette,
                  S.of(context).fxDatePickerToday,
                  () => _setQuick(now),
                ),
                _quickChip(
                  palette,
                  S.of(context).fxDatePickerYesterday,
                  () => _setQuick(now.subtract(const Duration(days: 1))),
                ),
                _quickChip(
                  palette,
                  S.of(context).fxDatePickerStartOfMonth,
                  () => _setQuick(DateTime(now.year, now.month, 1)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 216,
            child: CupertinoTheme(
              data: CupertinoThemeData(
                brightness: Theme.of(context).brightness,
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: FxTypography.body.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
              ),
              child: CupertinoDatePicker(
                // 用值派生 key，使快捷项 setState 后滚轮重建到新值；
                // 普通滚动不 setState，故不会打断用户滑动。
                key: ValueKey(_value),
                mode: widget.mode,
                initialDateTime: _value,
                minimumDate: widget.firstDate,
                maximumDate: widget.lastDate,
                use24hFormat: true,
                onDateTimeChanged: (d) => _value = d,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg,
              FxSpacing.md,
              FxSpacing.lg,
              FxSpacing.lg,
            ),
            child: FxButton(
              label: S.of(context).commonConfirm,
              expand: true,
              onPressed: () => Navigator.of(context).pop(_value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickChip(FxPalette palette, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      borderRadius: FxRadius.pillBorder,
      child: InkWell(
        borderRadius: FxRadius.pillBorder,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: FxSpacing.md),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              borderRadius: FxRadius.pillBorder,
              border: Border.all(color: palette.border),
            ),
            child: Text(
              label,
              style: FxTypography.caption.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
