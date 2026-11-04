import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

void main() {
  test('light text roles remain readable on every page surface', () {
    for (final surface in [
      FxPalette.light.surface,
      FxPalette.light.surfaceMuted,
      FxPalette.light.canvas,
    ]) {
      expect(
        _contrastRatio(FxPalette.light.textSecondary, surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(FxPalette.light.textTertiary, surface),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  test('dark text roles remain readable on every page surface', () {
    for (final surface in [
      FxPalette.dark.surface,
      FxPalette.dark.surfaceMuted,
      FxPalette.dark.canvas,
    ]) {
      expect(
        _contrastRatio(FxPalette.dark.textSecondary, surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(FxPalette.dark.textTertiary, surface),
        greaterThanOrEqualTo(4.5),
      );
    }
  });
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = _relativeLuminance(foreground);
  final backgroundLuminance = _relativeLuminance(background);
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(Color color) {
  final red = _linearChannel(color.r);
  final green = _linearChannel(color.g);
  final blue = _linearChannel(color.b);
  return 0.2126 * red + 0.7152 * green + 0.0722 * blue;
}

double _linearChannel(double channel) {
  return channel <= 0.04045
      ? channel / 12.92
      : ((channel + 0.055) / 1.055) *
            ((channel + 0.055) / 1.055) *
            ((channel + 0.055) / 1.055);
}
