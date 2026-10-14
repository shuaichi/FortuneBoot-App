import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('orders detail visit is remembered and restores with parent list route', () async {
    SharedPreferences.setMockInitialValues({});

    await AppRouter.persistRestorableRoute(const RouteSettings(name: Routes.orders));
    await AppRouter.persistRestorableRoute(
      const RouteSettings(
        name: Routes.orderDetail,
        arguments: {'bookId': 7, 'orderId': 11, 'service': Object()},
      ),
    );

    final stack = await AppRouter.restoreRouteStack();
    expect(stack.map((entry) => entry.name), [Routes.orders, Routes.orderDetail]);
    expect(stack.last.args, {'bookId': 7, 'orderId': 11});
  });

  test('list-only visit restores a single route', () async {
    SharedPreferences.setMockInitialValues({});
    await AppRouter.persistRestorableRoute(const RouteSettings(name: Routes.orders));
    final stack = await AppRouter.restoreRouteStack();
    expect(stack.map((entry) => entry.name), [Routes.orders]);
  });

  test('non-whitelisted routes are not persisted', () async {
    SharedPreferences.setMockInitialValues({});
    await AppRouter.persistRestorableRoute(
      const RouteSettings(name: Routes.billEditor, arguments: {'x': 1}),
    );
    expect(await AppRouter.restoreRouteStack(), isEmpty);
  });

  test('corrupt stored value restores nothing', () async {
    SharedPreferences.setMockInitialValues({'last_feature_route_v1': '{broken'});
    expect(await AppRouter.restoreRouteStack(), isEmpty);
  });
}
