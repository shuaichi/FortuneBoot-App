import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/profile/data/profile_service.dart';
import 'package:fortuneboot/features/profile/presentation/widgets/account_deletion_sheet.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

class _FakeProfileService extends ProfileService {
  _FakeProfileService({this.shouldThrow = false});

  final bool shouldThrow;
  final List<String> submittedPasswords = [];

  @override
  Future<void> deleteAccount({required String password}) async {
    submittedPasswords.add(password);
    if (shouldThrow) {
      throw FxApiException(10510, '用户密码错误');
    }
  }
}

Future<String> _encrypt(String password) async => 'encrypted:$password';

Widget _app({
  required ProfileService service,
  required ValueNotifier<bool?> result,
}) {
  return MaterialApp(
    theme: FxTheme.light,
    locale: const Locale('zh'),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      S.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              result.value = await FxSheet.show<bool>(
                context,
                title: '注销账号',
                child: AccountDeletionSheet(
                  service: service,
                  encryptPassword: _encrypt,
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('requires the current password before submitting', (
    tester,
  ) async {
    final service = _FakeProfileService();
    final result = ValueNotifier<bool?>(null);

    await tester.pumpWidget(_app(service: service, result: result));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('确认注销'));
    await tester.pumpAndSettle();

    expect(find.text('请输入当前密码'), findsOneWidget);
    expect(service.submittedPasswords, isEmpty);
    expect(result.value, isNull);
  });

  testWidgets('encrypts password, deletes account and closes with true', (
    tester,
  ) async {
    final service = _FakeProfileService();
    final result = ValueNotifier<bool?>(null);

    await tester.pumpWidget(_app(service: service, result: result));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'admin123');
    await tester.tap(find.text('确认注销'));
    await tester.pumpAndSettle();

    expect(service.submittedPasswords, ['encrypted:admin123']);
    expect(result.value, isTrue);
  });

  testWidgets('keeps the sheet open and shows API error message', (
    tester,
  ) async {
    final service = _FakeProfileService(shouldThrow: true);
    final result = ValueNotifier<bool?>(null);

    await tester.pumpWidget(_app(service: service, result: result));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'admin123');
    await tester.tap(find.text('确认注销'));
    await tester.pumpAndSettle();

    expect(find.text('用户密码错误'), findsOneWidget);
    expect(result.value, isNull);
  });
}
