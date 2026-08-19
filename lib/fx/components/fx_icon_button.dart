import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

/// Icon-only action with a mandatory accessible name and 48dp hit target.
class FxIconButton extends StatelessWidget {
  const FxIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.loading = false,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool loading;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? FxPalette.of(context).textPrimary;
    final enabled = onPressed != null && !loading;
    return Semantics(
      button: true,
      enabled: enabled,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: IconButton(
          tooltip: null,
          onPressed: enabled ? onPressed : null,
          icon: loading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foreground,
                  ),
                )
              : Icon(icon),
          color: foreground,
          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
        ),
      ),
    );
  }
}
