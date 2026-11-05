import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

class FxSheetAction {
  const FxSheetAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.enabled = true,
    this.destructive = false,
    this.selected = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool enabled;
  final bool destructive;
  final bool selected;
}

abstract final class FxActionSheet {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<FxSheetAction> actions,
  }) {
    final palette = FxPalette.of(context);
    return FxSheet.show<void>(
      context,
      title: title,
      child: Column(
        children: [
          for (final action in actions)
            Semantics(
              button: true,
              enabled: action.enabled,
              selected: action.selected,
              label: action.label,
              child: ListTile(
                minTileHeight: 48,
                leading: action.icon == null ? null : Icon(action.icon),
                title: Text(action.label),
                trailing: action.selected
                    ? Icon(Icons.check_rounded, color: palette.primary)
                    : null,
                enabled: action.enabled,
                iconColor: action.destructive
                    ? palette.danger
                    : action.selected
                    ? palette.primary
                    : palette.textSecondary,
                textColor: action.destructive ? palette.danger : null,
                onTap: action.enabled
                    ? () {
                        Navigator.of(context).pop();
                        action.onPressed();
                      }
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
