import 'package:flutter/widgets.dart';
import 'package:fortuneboot/core/errors/fx_failure.dart';
import 'package:fortuneboot/core/errors/fx_failure_mapper.dart';
import 'package:fortuneboot/generated/l10n.dart';

class StatsLoadError implements Exception {
  const StatsLoadError(this.failure);

  factory StatsLoadError.from(Object error) {
    return StatsLoadError(FxFailureMapper.map(error));
  }

  final FxFailure failure;
}

String statsLoadErrorMessage(BuildContext context, Object? error) {
  final s = S.of(context);
  if (error is StatsLoadError) {
    return switch (error.failure.kind) {
      FxFailureKind.network ||
      FxFailureKind.timeout ||
      FxFailureKind.serverUnavailable => s.serverConnectionFailed,
      _ => s.dashboardLoadFailed,
    };
  }
  return s.dashboardLoadFailed;
}
