part of 'orders_bloc.dart';

enum OrdersLoadStatus { initial, loading, ready, empty, error, noBook }

class OrdersState extends Equatable {
  final OrdersLoadStatus status;
  final FinanceOrderType type;
  final int statusFilter;
  final String? keyword;
  final bool overdueOnly;
  final int page;
  final int total;
  final List<FinanceOrderDetail> orders;
  final bool loadingMore;
  final String? loadMoreError;
  final FinanceOrderSummary? summary;
  final int requestGeneration;
  final String? errorMessage;
  final String? toastMessage;

  const OrdersState({
    this.status = OrdersLoadStatus.initial,
    this.type = FinanceOrderType.receivable,
    this.statusFilter = 200,
    this.keyword,
    this.overdueOnly = false,
    this.page = 1,
    this.total = 0,
    this.orders = const [],
    this.loadingMore = false,
    this.loadMoreError,
    this.summary,
    this.requestGeneration = 0,
    this.errorMessage,
    this.toastMessage,
  });

  bool get hasMore => orders.length < total;

  OrdersState copyWith({
    OrdersLoadStatus? status,
    FinanceOrderType? type,
    int? statusFilter,
    String? keyword,
    bool? overdueOnly,
    int? page,
    int? total,
    List<FinanceOrderDetail>? orders,
    bool? loadingMore,
    String? loadMoreError,
    FinanceOrderSummary? summary,
    int? requestGeneration,
    String? errorMessage,
    String? toastMessage,
  }) {
    return OrdersState(
      status: status ?? this.status,
      type: type ?? this.type,
      statusFilter: statusFilter ?? this.statusFilter,
      keyword: keyword ?? this.keyword,
      overdueOnly: overdueOnly ?? this.overdueOnly,
      page: page ?? this.page,
      total: total ?? this.total,
      orders: orders ?? this.orders,
      loadingMore: loadingMore ?? this.loadingMore,
      loadMoreError: loadMoreError,
      summary: summary ?? this.summary,
      requestGeneration: requestGeneration ?? this.requestGeneration,
      errorMessage: errorMessage,
      toastMessage: toastMessage ?? this.toastMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    type,
    statusFilter,
    keyword,
    overdueOnly,
    page,
    total,
    orders,
    loadingMore,
    loadMoreError,
    summary,
    requestGeneration,
    errorMessage,
    toastMessage,
  ];
}
