import 'package:equatable/equatable.dart';

/// Stable, presentation-safe categories for recoverable application failures.
enum FxFailureKind {
  network,
  timeout,
  unauthorized,
  forbidden,
  serverUnavailable,
  businessApi,
  invalidResponse,
  persistence,
  validation,
  unknown,
}

/// A failure value that may cross Core and presentation boundaries safely.
///
/// Raw exceptions, server messages, URLs and headers deliberately do not form
/// part of this value. They must be logged separately by the transport layer.
class FxFailure extends Equatable {
  const FxFailure({required this.kind, this.apiCode, this.httpStatusCode});

  final FxFailureKind kind;
  final int? apiCode;
  final int? httpStatusCode;

  bool get isRetryable => switch (kind) {
    FxFailureKind.network ||
    FxFailureKind.timeout ||
    FxFailureKind.serverUnavailable ||
    FxFailureKind.businessApi ||
    FxFailureKind.invalidResponse ||
    FxFailureKind.persistence ||
    FxFailureKind.unknown => true,
    FxFailureKind.unauthorized ||
    FxFailureKind.forbidden ||
    FxFailureKind.validation => false,
  };

  bool get shouldClearAuth =>
      kind == FxFailureKind.unauthorized || kind == FxFailureKind.forbidden;

  /// Kept for testable assurance that no raw diagnostic is exposed here.
  String? get diagnostic => null;

  @override
  List<Object?> get props => [kind, apiCode, httpStatusCode];
}
