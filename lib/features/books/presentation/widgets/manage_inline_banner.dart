import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

class ManageInlineBanner extends StatelessWidget {
  const ManageInlineBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.danger = false,
  });

  final String message;
  final IconData icon;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final tint = danger ? palette.danger : palette.info;
    return Container(
      padding: const EdgeInsets.all(FxSpacing.md),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: FxRadius.tileBorder,
        border: Border.all(color: tint.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: tint),
          const SizedBox(width: FxSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: FxTypography.caption.copyWith(color: palette.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
