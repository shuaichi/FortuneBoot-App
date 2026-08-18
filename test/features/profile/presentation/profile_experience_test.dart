import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/profile/data/profile_models.dart';
import 'package:fortuneboot/features/profile/presentation/profile_edit_page.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

const _profile = UserProfile(
  userId: 7,
  nickname: 'fortune',
  username: 'admin',
  sex: 1,
  phoneNumber: '15888888888',
  email: 'work.chi.zhang@gmail.com',
  roleName: '超级管理员',
);

Widget _page({ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? FxTheme.light,
    locale: const Locale('zh'),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      S.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: const ProfileEditPage(profile: _profile),
  );
}

void main() {
  testWidgets('renders profile details in grouped cards', (tester) async {
    await tester.pumpWidget(_page());
    await tester.pumpAndSettle();

    expect(find.text('个人资料'), findsOneWidget);
    expect(find.text('fortune'), findsOneWidget);
    expect(find.text('详细信息'), findsOneWidget);
    expect(find.text('系统记录'), findsOneWidget);
    expect(find.text('15888888888'), findsOneWidget);
    expect(find.text('work.chi.zhang@gmail.com'), findsOneWidget);
    expect(find.text('admin'), findsOneWidget);
    expect(find.text('超级管理员'), findsNWidgets(2));
  });

  testWidgets('opens the edit sheet from the identity card', (tester) async {
    await tester.pumpWidget(_page());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('编辑资料'));
    await tester.pumpAndSettle();

    expect(find.text('编辑资料'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('男'), findsNWidgets(2));
    expect(find.text('女'), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
  });

  testWidgets('supports dark theme and missing profile values', (tester) async {
    const incompleteProfile = UserProfile(nickname: 'F');
    await tester.pumpWidget(
      MaterialApp(
        theme: FxTheme.dark,
        locale: const Locale('zh'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: const ProfileEditPage(profile: incompleteProfile),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('F'), findsNWidgets(2));
    expect(find.text('未设置'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
