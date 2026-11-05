import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:intl/intl.dart';

/// 以年月直接定位连续账单流中的账期。
class BillsPeriodPicker extends StatefulWidget {
  const BillsPeriodPicker({
    super.key,
    required this.loadedAnchors,
    required this.currentAnchor,
    required this.onSelected,
  });

  final List<DateTime> loadedAnchors;
  final DateTime currentAnchor;
  final ValueChanged<DateTime> onSelected;

  @override
  State<BillsPeriodPicker> createState() => _BillsPeriodPickerState();
}

class _BillsPeriodPickerState extends State<BillsPeriodPicker> {
  late int _year = widget.currentAnchor.year;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final latestYear = DateTime.now().year + 1;
    final years = [for (var year = latestYear; year >= 2000; year--) year];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: _year,
            decoration: InputDecoration(
              labelText: S.of(context).billsPeriodYear,
            ),
            items: [
              for (final year in years)
                DropdownMenuItem(value: year, child: Text('$year')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _year = value);
            },
          ),
          const SizedBox(height: FxSpacing.lg),
          Wrap(
            spacing: FxSpacing.sm,
            runSpacing: FxSpacing.sm,
            children: [
              for (var month = 1; month <= 12; month++)
                _monthOption(context, DateTime(_year, month), locale),
            ],
          ),
          const SizedBox(height: FxSpacing.md),
          Text(
            S.of(context).billsPeriodLoadedHint,
            style: FxTypography.caption.copyWith(
              color: FxPalette.of(context).textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthOption(BuildContext context, DateTime anchor, String locale) {
    final selected =
        anchor.year == widget.currentAnchor.year &&
        anchor.month == widget.currentAnchor.month;
    final loaded = widget.loadedAnchors.any(
      (item) => item.year == anchor.year && item.month == anchor.month,
    );
    final month = DateFormat.MMMM(locale).format(anchor);
    final label = loaded ? '$month ·' : month;
    return Semantics(
      button: true,
      selected: selected,
      label: loaded ? '$month，${S.of(context).billsPeriodLoaded}' : month,
      child: FxTagChip(
        key: ValueKey(
          'bills-period-option-${anchor.year}-${anchor.month.toString().padLeft(2, '0')}',
        ),
        label: label,
        selected: selected,
        onTap: () => widget.onSelected(anchor),
      ),
    );
  }
}
