part of 'order_detail_bloc.dart';

enum OrderDetailStatus { initial, loading, ready, error }

class OrderDetailState extends Equatable {
  final OrderDetailStatus status;
  final FinanceOrderDetail? detail;
  final FinanceOrderSummary? summary;
  final List<FinanceOrderEntry> entries;
  final String entryStatus;
  final int page;
  final int total;
  final bool loadingMore;
  final String? loadMoreError;
  final bool actionLoading;
  final bool removed;
  final String? errorMessage;
  final String? toastMessage;
  final int requestGeneration;

  const OrderDetailState({
    this.status = OrderDetailStatus.initial,
    this.detail,
    this.summary,
    this.entries = const [],
    this.entryStatus = 'ACTIVE',
    this.page = 1,
    this.total = 0,
    this.loadingMore = false,
    this.loadMoreError,
    this.actionLoading = false,
    this.removed = false,
    this.errorMessage,
    this.toastMessage,
    this.requestGeneration = 0,
  });

  bool get hasMore => entries.length < total;

  OrderDetailState copyWith({
    OrderDetailStatus? status,
    FinanceOrderDetail? detail,
    FinanceOrderSummary? summary,
    List<FinanceOrderEntry>? entries,
    String? entryStatus,
    int? page,
    int? total,
    bool? loadingMore,
    String? loadMoreError,
    bool? actionLoading,
    bool? removed,
    String? errorMessage,
    String? toastMessage,
    int? requestGeneration,
  }) {
    return OrderDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      summary: summary ?? this.summary,
      entries: entries ?? this.entries,
      entryStatus: entryStatus ?? this.entryStatus,
      page: page ?? this.page,
      total: total ?? this.total,
      loadingMore: loadingMore ?? this.loadingMore,
      loadMoreError: loadMoreError,
      actionLoading: actionLoading ?? this.actionLoading,
      removed: removed ?? this.removed,
      errorMessage: errorMessage,
      toastMessage: toastMessage,
      requestGeneration: requestGeneration ?? this.requestGeneration,
    );
  }

  @override
  List<Object?> get props => [
    status,
    detail,
    summary,
    entries,
    entryStatus,
    page,
    total,
    loadingMore,
    loadMoreError,
    actionLoading,
    removed,
    errorMessage,
    toastMessage,
    requestGeneration,
  ];
}
