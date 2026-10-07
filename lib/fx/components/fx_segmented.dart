import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// iOS 风滑动指示块分段控件。
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
    final index = segments.indexWhere((s) => s.value == value);
    final height = (40 * MediaQuery.textScalerOf(context).scale(1)).clamp(
      48.0,
      96.0,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = segments.length;
        final segWidth = constraints.maxWidth / count;
        final selectedSegment = index < 0 ? null : segments[index];
        final selectedIsDangerous =
            selectedSegment?.dangerWhenSelected ?? false;
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: palette.surfaceMuted,
            borderRadius: FxRadius.tileBorder,
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: FxMotion.resolve(context, FxMotion.normal),
                curve: Curves.easeOutCubic,
                left: (index < 0 ? 0 : index) * segWidth + 3,
                top: 3,
                bottom: 3,
                width: segWidth - 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedIsDangerous
                        ? palette.danger.withValues(alpha: 0.08)
                        : palette.surface,
                    borderRadius: BorderRadius.circular(FxRadius.tile - 2),
                    boxShadow: [
                      BoxShadow(
                        color: palette.shadow,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: segments.map((s) {
                  final selected = s.value == value;
                  return Expanded(
                    child: Semantics(
                      inMutuallyExclusiveGroup: true,
                      selected: selected,
                      label: s.label,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (!selected) {
                              HapticFeedback.selectionClick();
                              onChanged(s.value);
                            }
                          },
                          child: Center(
                            child: Text(
                              s.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FxTypography.label.copyWith(
                                color: selected
                                    ? s.dangerWhenSelected
                                          ? palette.danger
                                          : palette.textPrimary
                                    : palette.textSecondary,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FxSegment<T> {
  const FxSegment(this.value, this.label, {this.dangerWhenSelected = false});

  final T value;
  final String label;
  final bool dangerWhenSelected;
}
