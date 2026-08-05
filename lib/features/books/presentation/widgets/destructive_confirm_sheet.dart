import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

class DestructiveConfirmSheet extends StatefulWidget {
  const DestructiveConfirmSheet({
    super.key,
    required this.title,
    required this.objectName,
    required this.warning,
    this.checkboxLabel,
    this.confirmLabel,
  });

  final String title;
  final String objectName;
  final String warning;
  final String? checkboxLabel;
  final String? confirmLabel;

  @override
  State<DestructiveConfirmSheet> createState() =>
      _DestructiveConfirmSheetState();
}

class _DestructiveConfirmSheetState extends State<DestructiveConfirmSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _checked = false;

  bool get _enabled => _checked && _controller.text == widget.objectName;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: FxTypography.title),
          const SizedBox(height: FxSpacing.sm),
          Text(
            widget.warning,
            style: FxTypography.body.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: FxSpacing.md),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _checked,
            onChanged: (value) => setState(() => _checked = value ?? false),
            title: Text(
              widget.checkboxLabel ??
                  S.of(context).booksDefaultDestructiveCheckbox,
              style: FxTypography.caption,
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: FxSpacing.sm),
          TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: S.of(context).booksConfirmObjectHint(widget.objectName),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: FxSpacing.xl),
          FxButton.critical(
            label: widget.confirmLabel ?? S.of(context).booksPermanentlyDelete,
            expand: true,
            onPressed: _enabled ? () => Navigator.of(context).pop(true) : null,
          ),
        ],
      ),
    );
  }
}
