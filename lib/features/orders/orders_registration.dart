import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/orders/data/orders_service.dart';
import 'package:fortuneboot/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:fortuneboot/features/orders/presentation/order_detail_page.dart';
import 'package:fortuneboot/features/orders/presentation/order_reconciliation_page.dart';
import 'package:fortuneboot/features/orders/presentation/orders_page.dart';

/// 注册 Orders（单据）feature 路由。
void registerOrdersFeature() {
  AppRouter.register(Routes.orders, (args) {
    return Builder(
      builder: (BuildContext context) {
        final session = context.read<SessionCubit>().state;
        return BlocProvider<OrdersBloc>(
          create: (_) =>
              OrdersBloc(bookId: session.currentBookId)
                ..add(const OrdersLoaded()),
          child: const OrdersPage(),
        );
      },
    );
  });

  AppRouter.register(Routes.orderDetail, (args) {
    final map = switch (args) {
      Map<String, dynamic> typed => typed,
      Map<dynamic, dynamic> raw => Map<String, dynamic>.from(raw),
      _ => <String, dynamic>{},
    };
    final bookId = map['bookId'] as int?;
    final orderId = map['orderId'] as int?;
    final service = map['service'] is OrdersService
        ? map['service'] as OrdersService
        : OrdersService();
    if (bookId == null || orderId == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    return OrderDetailPage(service: service, bookId: bookId, orderId: orderId);
  });

  AppRouter.register(Routes.orderReconciliation, (args) {
    final map = switch (args) {
      Map<String, dynamic> typed => typed,
      Map<dynamic, dynamic> raw => Map<String, dynamic>.from(raw),
      _ => <String, dynamic>{},
    };
    final bookId = map['bookId'] as int?;
    final service = map['service'] is OrdersService
        ? map['service'] as OrdersService
        : OrdersService();
    if (bookId == null) return const Scaffold(body: SizedBox.shrink());
    return OrderReconciliationPage(service: service, bookId: bookId);
  });
}
