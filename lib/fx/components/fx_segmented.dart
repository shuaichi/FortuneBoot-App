import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 少量选项的分段控件；更多或很长选项应使用选择列表。
class FxSegmented<T> extends StatelessWidget {
  final List<FxSegment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;

  const FxSegmented({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: FxRadius.tileBorder,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final segment in segments)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: _FxSegmentButton<T>(
                    segment: segment,
                    selected: segment.value == value,
                    onChanged: onChanged,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FxSegmentButton<T> extends StatelessWidget {
  const _FxSegmentButton({
    required this.segment,
    required this.selected,
    required this.onChanged,
  });

  final FxSegment<T> segment;
  final bool selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Semantics(
      button: true,
      enabled: true,
      inMutuallyExclusiveGroup: true,
      selected: selected,
      label: segment.label,
      child: Material(
        color: selected
            ? segment.dangerWhenSelected
                  ? palette.danger.withValues(alpha: 0.08)
                  : palette.surface
            : Colors.transparent,
        borderRadius: BorderRadius.circular(FxRadius.tile - 2),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (!selected) {
              HapticFeedback.selectionClick();
              onChanged(segment.value);
            }
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FxSpacing.sm,
                vertical: FxSpacing.sm,
              ),
              child: Center(
                child: Text(
                  segment.label,
                  textAlign: TextAlign.center,
                  style: FxTypography.label.copyWith(
                    color: selected
                        ? segment.dangerWhenSelected
                              ? palette.danger
                              : palette.textPrimary
                        : palette.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FxSegment<T> {
  const FxSegment(this.value, this.label, {this.dangerWhenSelected = false});

  final T value;
  final String label;
  final bool dangerWhenSelected;
}
