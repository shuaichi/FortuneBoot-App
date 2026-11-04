import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';

void main() {
  testWidgets('Apple routes retain native push and back behavior', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    AppRouter.register('/native-test', (_) => const SizedBox.shrink());

    final route = AppRouter.onGenerateRoute(
      const RouteSettings(name: '/native-test'),
    );

    expect(route, isA<CupertinoPageRoute<dynamic>>());
    debugDefaultTargetPlatformOverride = null;
  });
}
