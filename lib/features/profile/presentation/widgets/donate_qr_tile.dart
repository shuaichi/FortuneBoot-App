import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/util/image_save_service.dart';

typedef DonateQrSaveCallback =
    Future<ImageSaveResult> Function(String assetPath, String fileName);

class DonateQrTile extends StatefulWidget {
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
  State<DonateQrTile> createState() => _DonateQrTileState();
}

class _DonateQrTileState extends State<DonateQrTile> {
  ImageSaveResult? _result;
  var _isSaving = false;

  Future<void> _save() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
      _result = null;
    });
    try {
      final result = await widget.onSave(widget.assetPath, widget.fileName);
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _result = result;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _result = ImageSaveResult.failed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final strings = S.of(context);
    final feedback = _feedback(strings);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 16, color: widget.tint),
            const SizedBox(width: FxSpacing.xs),
            Text(
              widget.label,
              style: FxTypography.label.copyWith(color: widget.tint),
            ),
          ],
        ),
        const SizedBox(height: FxSpacing.sm),
        Semantics(
          key: DonateQrTile.qrKey,
          label: '${widget.semanticsLabel}${_semanticsSuffix(strings)}',
          enabled: !_isSaving,
          onLongPress: _isSaving ? null : _save,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: _isSaving ? null : _save,
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: FxRadius.cardBorder,
                      border: Border.all(color: palette.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    padding: const EdgeInsets.all(FxSpacing.sm),
                    child: Image.asset(
                      widget.assetPath,
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
                  if (_isSaving)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: palette.surface.withValues(alpha: 0.82),
                        borderRadius: FxRadius.cardBorder,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: widget.tint,
                              ),
                            ),
                            const SizedBox(height: FxSpacing.sm),
                            Text(
                              strings.imageSaveSaving,
                              style: FxTypography.caption.copyWith(
                                color: palette.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: Tooltip(
            message: strings.commonSave,
            child: TextButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.save_alt_rounded),
              label: Text(strings.commonSave),
            ),
          ),
        ),
        if (feedback != null) ...[
          const SizedBox(height: FxSpacing.xs),
          Semantics(
            liveRegion: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(feedback.icon, size: 14, color: feedback.color),
                const SizedBox(width: FxSpacing.xs),
                Flexible(
                  child: Text(
                    feedback.message,
                    textAlign: TextAlign.center,
                    style: FxTypography.caption.copyWith(color: feedback.color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  _DonateQrFeedback? _feedback(S strings) {
    return switch (_result) {
      ImageSaveResult.saved => _DonateQrFeedback(
        message: strings.imageSaveSuccess,
        color: Colors.green,
        icon: Icons.check_circle_rounded,
      ),
      ImageSaveResult.downloadStarted => _DonateQrFeedback(
        message: strings.imageSaveDownloadStarted,
        color: Colors.green,
        icon: Icons.check_circle_rounded,
      ),
      ImageSaveResult.failed => _DonateQrFeedback(
        message: strings.imageSaveFailed,
        color: Colors.red,
        icon: Icons.error_rounded,
      ),
      ImageSaveResult.unsupported => _DonateQrFeedback(
        message: strings.imageSaveUnsupported,
        color: Colors.orange,
        icon: Icons.warning_rounded,
      ),
      null => null,
    };
  }

  String _semanticsSuffix(S strings) {
    if (_isSaving) return '，${strings.imageSaveSaving}';
    return switch (_result) {
      ImageSaveResult.saved => '，${strings.imageSaveSuccess}',
      ImageSaveResult.downloadStarted => '，${strings.imageSaveDownloadStarted}',
      ImageSaveResult.failed => '，${strings.imageSaveFailed}',
      ImageSaveResult.unsupported => '，${strings.imageSaveUnsupported}',
      null => '',
    };
  }
}

class _DonateQrFeedback {
  const _DonateQrFeedback({
    required this.message,
    required this.color,
    required this.icon,
  });

  final String message;
  final Color color;
  final IconData icon;
}
