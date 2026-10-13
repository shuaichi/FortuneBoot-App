import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/profile/data/donation_models.dart';
import 'package:fortuneboot/features/profile/data/profile_models.dart';
import 'package:fortuneboot/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fortuneboot/features/profile/presentation/profile_edit_page.dart';
import 'package:fortuneboot/features/profile/presentation/profile_page.dart';
import 'package:fortuneboot/features/profile/presentation/widgets/donate_qr_tile.dart';
import 'package:fortuneboot/features/profile/presentation/widgets/iap_donation_section.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

const _profile = UserProfile(userId: 7, nickname: 'fortune', username: 'admin');

class _FakeDonationApi implements DonationApi {
  final List<String> purchasedIds = [];

  @override
  Future<List<DonationProduct>> loadProducts() async => const [
    DonationProduct(
      id: 'fortuneboot_donation_small',
      title: '小额支持',
      price: '¥6',
    ),
  ];

  @override
  Future<bool> startPurchase(DonationProduct product) async {
    purchasedIds.add(product.id);
    return true;
  }

  @override
  Stream<DonationPurchaseEvent> get purchaseStream => const Stream.empty();

  @override
  void dispose() {}
}

class _TestProfileBloc extends ProfileBloc {
  _TestProfileBloc() : super();

  void setProfile(ProfileState state) => emit(state);
}

Widget _page({
  required ProfileBloc profileBloc,
  required SessionCubit sessionCubit,
  required PreferencesCubit preferencesCubit,
  DonationApi? donationApi,
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<ProfileBloc>.value(value: profileBloc),
      BlocProvider<SessionCubit>.value(value: sessionCubit),
      BlocProvider<PreferencesCubit>.value(value: preferencesCubit),
    ],
    child: MaterialApp(
      theme: FxTheme.light,
      locale: const Locale('zh'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        S.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: ProfilePage(donationApi: donationApi),
    ),
  );
}

void main() {
  late _TestProfileBloc profileBloc;
  late SessionCubit sessionCubit;
  late PreferencesCubit preferencesCubit;

  setUp(() {
    profileBloc = _TestProfileBloc()
      ..setProfile(
        const ProfileState(status: ProfileStatus.ready, profile: _profile),
      );
    sessionCubit = SessionCubit();
    preferencesCubit = PreferencesCubit();
  });

  tearDown(() async {
    await profileBloc.close();
    await sessionCubit.close();
    await preferencesCubit.close();
  });

  testWidgets('opens donation sheet from the profile QR code only', (
    tester,
  ) async {
    await tester.pumpWidget(
      _page(
        profileBloc: profileBloc,
        sessionCubit: sessionCubit,
        preferencesCubit: preferencesCubit,
      ),
    );
    await tester.pumpAndSettle();

    // 注销账号入口已移至“查看个人资料”页。
    expect(find.text('注销账号'), findsNothing);

    await tester.tap(find.byTooltip('捐赠'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(FxSheet), matching: find.text('捐赠')),
      findsOneWidget,
    );
    expect(find.text('微信'), findsOneWidget);
    expect(find.text('支付宝'), findsOneWidget);
    expect(find.byType(DonateQrTile), findsNWidgets(2));
    expect(find.byType(ProfileEditPage), findsNothing);
  });

  testWidgets('opens the profile editor from the remaining user card area', (
    tester,
  ) async {
    await tester.pumpWidget(
      _page(
        profileBloc: profileBloc,
        sessionCubit: sessionCubit,
        preferencesCubit: preferencesCubit,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('fortune'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileEditPage), findsOneWidget);
    expect(find.byType(DonateQrTile), findsNothing);
  });

  testWidgets(
    'uses In-App Purchase for donations on Apple platforms',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final donationApi = _FakeDonationApi();

      try {
        await tester.pumpWidget(
          _page(
            profileBloc: profileBloc,
            sessionCubit: sessionCubit,
            preferencesCubit: preferencesCubit,
            donationApi: donationApi,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.qr_code_rounded), findsNothing);

        await tester.tap(find.byTooltip('捐赠'));
        await tester.pumpAndSettle();

        expect(find.byType(IapDonationSection), findsOneWidget);
        expect(find.text('小额支持'), findsOneWidget);
        expect(find.byType(DonateQrTile), findsNothing);
        expect(find.text('微信'), findsNothing);
        expect(find.text('支付宝'), findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
    // Apple 平台内购入口本期隐藏，待内购功能上线后恢复（非 Apple 平台不受影响）。
    skip: true,
  );

  testWidgets('hides donation entries on Apple platforms only', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        _page(
          profileBloc: profileBloc,
          sessionCubit: sessionCubit,
          preferencesCubit: preferencesCubit,
          donationApi: _FakeDonationApi(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('捐赠'), findsNothing);
      expect(find.text('捐赠'), findsNothing);
      expect(find.byIcon(Icons.favorite_rounded), findsNothing);
      expect(find.byIcon(Icons.qr_code_rounded), findsNothing);
      expect(find.byType(DonateQrTile), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
