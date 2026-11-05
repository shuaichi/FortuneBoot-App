import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/deep_link_target.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

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

  test('deep-link restore requires declared route context', () {
    AppRouter.register('/restore/list', (_) => const SizedBox.shrink());
    AppRouter.register(
      '/restore/detail',
      (_) => const SizedBox.shrink(),
      requiredDeepLinkKeys: const ['bookId', 'orderId'],
    );
    AppRouter.register(
      '/restore/profile',
      (_) => const SizedBox.shrink(),
      deepLinkRestorable: false,
    );

    expect(
      AppRouter.canRestore(DeepLinkTarget.tryParse('/restore/list')!),
      isTrue,
    );
    expect(
      AppRouter.canRestore(
        DeepLinkTarget.tryParse('/restore/detail?bookId=1')!,
      ),
      isFalse,
    );
    expect(
      AppRouter.canRestore(
        DeepLinkTarget.tryParse('/restore/detail?bookId=1&orderId=2')!,
      ),
      isTrue,
    );
    expect(
      AppRouter.canRestore(DeepLinkTarget.tryParse('/restore/profile')!),
      isFalse,
    );
  });

  testWidgets('unknown route shows a page with an explicit back exit', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.light,
        locale: const Locale('zh'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: const Scaffold(body: Text('home')),
        onGenerateRoute: AppRouter.onGenerateRoute,
        onUnknownRoute: AppRouter.onUnknownRoute,
      ),
    );

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/missing-route');
    await tester.pumpAndSettle();

    expect(find.text('无法打开此页面'), findsOneWidget);
    expect(find.text('链接指向的页面不存在或已失效。'), findsOneWidget);
    await tester.tap(find.byTooltip('返回'));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });
}
