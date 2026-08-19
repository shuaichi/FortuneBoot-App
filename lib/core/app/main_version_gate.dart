import 'package:flutter/material.dart';
import 'package:fortuneboot/core/auth/auth_version_checker.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/shell/main_shell.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/login/auth_version_source.dart';
import 'package:fortuneboot/login/model/users.dart';
import 'package:fortuneboot/util/dio_client.dart';

class MainVersionGate extends StatefulWidget {
  const MainVersionGate({super.key});

  @override
  State<MainVersionGate> createState() => _MainVersionGateState();
}

class _MainVersionGateState extends State<MainVersionGate> {
  late final Future<bool> _canEnterMain = _checkAccess();

  Future<bool> _checkAccess() async {
    final userData = UserDataSingleton();
    final userInfo = await userData.getMap(UserDataSingleton.userInfo);
    final token = await userData.getMap(UserDataSingleton.userToken);
    final protocol = await userData.getStr(UserDataSingleton.baseUrlProtocol);
    final domain = await userData.getStr(UserDataSingleton.baseUrlDomain);
    final port = await userData.getStr(UserDataSingleton.baseUrlPort);
    if (userInfo?.isEmpty != false ||
        token?.isEmpty != false ||
        protocol?.isEmpty != false ||
        domain?.isEmpty != false) {
      return false;
    }

    final portSegment = port?.isNotEmpty == true ? ':$port' : '';
    DioClient().updateBaseUrl('$protocol://$domain$portSegment/prod-api');
    DioClient().setAuthHeader(token!);
    var canEnterMain = false;
    try {
      final check = await AuthVersionChecker(
        source: LoginApiVersionSource(),
      ).check();
      if (!check.isCompatible) return false;

      final response = await DioClient().dio.get<dynamic>(
        '/system/user/profile',
      );
      final responseData = response.data;
      if (responseData is! Map) return false;
      canEnterMain = responseData['code'] == 0;
      return canEnterMain;
    } on Exception {
      return false;
    } finally {
      if (!canEnterMain) {
        DioClient().clearAuthHeader();
        await userData.clearAuth();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _canEnterMain,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.requireData) return const MainShell();
        return _BlockedMainPage();
      },
    );
  }
}

class _BlockedMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.baseUrlConfig, (route) => false),
          child: Text(S.of(context).baseUrlConfig),
        ),
      ),
    );
  }
}
