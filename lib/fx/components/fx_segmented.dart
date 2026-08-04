import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
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
    final index = segments.indexWhere((s) => s.value == value);
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = segments.length;
        final segWidth = constraints.maxWidth / count;
        return Container(
          height: 40,
          decoration: BoxDecoration(
            color: FxColors.surfaceMuted,
            borderRadius: FxRadius.tileBorder,
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: (index < 0 ? 0 : index) * segWidth + 3,
                top: 3,
                bottom: 3,
                width: segWidth - 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: FxColors.surface,
                    borderRadius: BorderRadius.circular(FxRadius.tile - 2),
                    boxShadow: const [
                      BoxShadow(
                        color: FxColors.shadow,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: segments.map((s) {
                  final selected = s.value == value;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (!selected) {
                          HapticFeedback.selectionClick();
                          onChanged(s.value);
                        }
                      },
                      child: Center(
                        child: Text(
                          s.label,
                          style: FxTypography.label.copyWith(
                            color: selected
                                ? FxColors.textPrimary
                                : FxColors.textSecondary,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w500,
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
  final T value;
  final String label;
  const FxSegment(this.value, this.label);
}
