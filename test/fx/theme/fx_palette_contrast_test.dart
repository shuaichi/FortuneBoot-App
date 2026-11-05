import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

void main() {
  test('enabled action labels remain readable in both themes', () {
    for (final palette in [FxPalette.light, FxPalette.dark]) {
      expect(
        _contrastRatio(palette.onPrimary, palette.primary),
        greaterThanOrEqualTo(4.5),
        reason: 'primary action label',
      );
      expect(
        _contrastRatio(palette.onDanger, palette.danger),
        greaterThanOrEqualTo(4.5),
        reason: 'critical action label',
      );
    }
  });
  test('light text roles remain readable on every page surface', () {
    for (final surface in [
      FxPalette.light.surface,
      FxPalette.light.surfaceMuted,
      FxPalette.light.canvas,
      FxPalette.light.surfaceRaised,
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
      FxPalette.dark.surfaceRaised,
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

double _relativeLuminance(Color color) => color.computeLuminance();
