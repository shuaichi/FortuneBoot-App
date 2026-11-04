import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 分级确认 sheet：LOW 为普通确认，MID 为危险确认，HIGH 额外要求确认名称。
class DestructiveConfirmSheet extends StatefulWidget {
  const DestructiveConfirmSheet({
    super.key,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    this.subMessage,
    this.nameToMatch,
    this.checkboxLabel,
  }) : assert(
         nameToMatch == null || checkboxLabel != null,
         'HIGH confirmation requires a checkbox label.',
       );

  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final String? subMessage;
  final String? nameToMatch;
  final String? checkboxLabel;

  bool get _isHighRisk => nameToMatch != null;
  bool get _isMidRisk => subMessage != null;

  /// 展示统一确认 sheet。传入 [subMessage] 为 MID，传入 [nameToMatch] 和
  /// [checkboxLabel] 为 HIGH；其余为 LOW。
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    String? subMessage,
    String? nameToMatch,
    String? checkboxLabel,
  }) async {
    final content = DestructiveConfirmSheet(
      message: message,
      subMessage: subMessage,
      nameToMatch: nameToMatch,
      checkboxLabel: checkboxLabel,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    );
    if (MediaQuery.widthOf(context) >= 840) {
      return await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              final palette = FxPalette.of(dialogContext);
              return Dialog(
                backgroundColor: palette.surface,
                surfaceTintColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: palette.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  key: const ValueKey('destructive-dialog'),
                  width: 440,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Text(
                            title,
                            style: FxTypography.title.copyWith(
                              color: palette.textPrimary,
                            ),
                          ),
                        ),
                        content,
                      ],
                    ),
                  ),
                ),
              );
            },
          ) ??
          false;
    }
    return await FxSheet.show<bool>(
          context,
          title: title,
          scrollable: nameToMatch != null,
          child: content,
        ) ??
        false;
  }

  @override
  State<DestructiveConfirmSheet> createState() =>
      _DestructiveConfirmSheetState();
}

class _DestructiveConfirmSheetState extends State<DestructiveConfirmSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _checked = false;

  bool get _enabled =>
      !widget._isHighRisk ||
      (_checked && _controller.text == widget.nameToMatch);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final confirm = widget._isMidRisk || widget._isHighRisk
        ? FxButton.critical(
            label: widget.confirmLabel,
            expand: true,
            onPressed: _enabled ? () => Navigator.of(context).pop(true) : null,
          )
        : FxButton(
            label: widget.confirmLabel,
            expand: true,
            onPressed: () => Navigator.of(context).pop(true),
          );

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
          Text(
            widget.message,
            style: FxTypography.body.copyWith(color: palette.textSecondary),
          ),
          if (widget.subMessage != null) ...[
            const SizedBox(height: FxSpacing.sm),
            Text(
              widget.subMessage!,
              style: FxTypography.caption.copyWith(color: palette.danger),
            ),
          ],
          if (widget._isHighRisk) ...[
            const SizedBox(height: FxSpacing.md),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _checked,
              onChanged: (value) => setState(() => _checked = value ?? false),
              title: Text(widget.checkboxLabel!, style: FxTypography.caption),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: FxSpacing.sm),
            TextField(
              controller: _controller,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: S
                    .of(context)
                    .booksConfirmObjectHint(widget.nameToMatch!),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: FxSpacing.xl),
          Row(
            children: [
              Expanded(
                child: FxButton.tonal(
                  label: widget.cancelLabel,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: FxSpacing.sm),
              Expanded(child: confirm),
            ],
          ),
        ],
      ),
    );
  }
}
