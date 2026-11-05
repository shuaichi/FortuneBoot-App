import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/fx_route_unavailable_page.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/widgets/session_scoped_page.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:fortuneboot/features/orders/presentation/order_detail_page.dart';
import 'package:fortuneboot/features/orders/presentation/order_reconciliation_page.dart';
import 'package:fortuneboot/features/orders/presentation/orders_page.dart';

/// 注册 Orders（单据）feature 路由。
void registerOrdersFeature() {
  AppRouter.register(Routes.orders, (args) {
    return SessionScopedPage(
      child: Builder(
        builder: (BuildContext context) {
          final session = context.read<SessionCubit>().state;
          return BlocProvider<OrdersBloc>(
            create: (_) =>
                OrdersBloc(bookId: session.currentBookId)
                  ..add(const OrdersLoaded()),
            child: const OrdersPage(),
          );
        },
      ),
    );
  });

  AppRouter.register(Routes.orderDetail, (args) {
    final map = _asArgs(args);
    final bookId = _asInt(map['bookId']);
    final orderId = _asInt(map['orderId']);
    final service = map['service'] is OrdersService
        ? map['service'] as OrdersService
        : OrdersService();
    if (bookId == null || orderId == null) {
      return const FxRouteUnavailablePage(
        reason: FxRouteUnavailableReason.missingContext,
      );
    }
    return OrderDetailPage(service: service, bookId: bookId, orderId: orderId);
  }, requiredDeepLinkKeys: const ['bookId', 'orderId']);

  AppRouter.register(Routes.orderReconciliation, (args) {
    final map = _asArgs(args);
    final bookId = _asInt(map['bookId']);
    final focusOrderId = _asInt(map['focusOrderId']);
    final service = map['service'] is OrdersService
        ? map['service'] as OrdersService
        : OrdersService();
    if (bookId == null) {
      return const FxRouteUnavailablePage(
        reason: FxRouteUnavailableReason.missingContext,
      );
    }
    return OrderReconciliationPage(
      service: service,
      bookId: bookId,
      focusOrderId: focusOrderId,
    );
  }, requiredDeepLinkKeys: const ['bookId']);
}

Map<String, dynamic> _asArgs(Object? args) {
  if (args is Map<String, dynamic>) return args;
  if (args is Map) return Map<String, dynamic>.from(args);
  return <String, dynamic>{};
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}
