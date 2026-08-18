import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

typedef DonateQrSaveCallback =
    Future<void> Function(String assetPath, String fileName);

class DonateQrTile extends StatelessWidget {
  const DonateQrTile({
    super.key,
    required this.assetPath,
    required this.fileName,
    required this.label,
    required this.semanticsLabel,
    required this.tint,
    required this.icon,
    required this.onSave,
  });

  static const qrKey = Key('donate-qr');

  final String assetPath;
  final String fileName;
  final String label;
  final String semanticsLabel;
  final Color tint;
  final IconData icon;
  final DonateQrSaveCallback onSave;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: tint),
            const SizedBox(width: FxSpacing.xs),
            Text(label, style: FxTypography.label.copyWith(color: tint)),
          ],
        ),
        const SizedBox(height: FxSpacing.sm),
        Semantics(
          key: qrKey,
          label: semanticsLabel,
          onLongPress: () => onSave(assetPath, fileName),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () => onSave(assetPath, fileName),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: FxRadius.cardBorder,
                  border: Border.all(color: palette.border),
                ),
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.all(FxSpacing.sm),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) => Center(
                    child: Icon(
                      Icons.qr_code_2_rounded,
                      size: 48,
                      color: palette.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
