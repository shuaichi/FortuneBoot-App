import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/auth/auth_version_checker.dart';
import 'package:fortuneboot/core/errors/fx_failure.dart';
import 'package:fortuneboot/core/errors/fx_failure_mapper.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/security/app_lock_cubit.dart';
import 'package:fortuneboot/core/shell/main_shell.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/login/auth_version_source.dart';
import 'package:fortuneboot/login/model/users.dart';
import 'package:fortuneboot/login/server/server_endpoint.dart';
import 'package:fortuneboot/util/dio_client.dart';

sealed class MainAccessResult {
  const MainAccessResult();
}

final class MainAccessAllowed extends MainAccessResult {
  const MainAccessAllowed();
}

final class MainAccessBlocked extends MainAccessResult {
  const MainAccessBlocked(this.failure);

  final FxFailure failure;
}

class MainVersionGate extends StatefulWidget {
  const MainVersionGate({super.key});

  @override
  State<MainVersionGate> createState() => _MainVersionGateState();
}

class _MainVersionGateState extends State<MainVersionGate> {
  late final Future<MainAccessResult> _accessResult = _checkAccess();

  Future<MainAccessResult> _checkAccess() async {
    final userData = UserDataSingleton();
    try {
      final userInfo = await userData.getMap(UserDataSingleton.userInfo);
      final token = await userData.getMap(UserDataSingleton.userToken);
      final protocol = await userData.getStr(UserDataSingleton.baseUrlProtocol);
      final domain = await userData.getStr(UserDataSingleton.baseUrlDomain);
      final port = await userData.getStr(UserDataSingleton.baseUrlPort);
      if (userInfo?.isEmpty != false ||
          token?.isEmpty != false ||
          protocol?.isEmpty != false ||
          domain?.isEmpty != false) {
        return const MainAccessBlocked(
          FxFailure(kind: FxFailureKind.validation),
        );
      }

      final endpoint = ServerEndpoint.parse(
        protocol: protocol!,
        host: domain!,
        port: port,
      );
      DioClient().updateBaseUrl(endpoint.apiBaseUri.toString());
      DioClient().setAuthHeader(token!);

      final check = await AuthVersionChecker(
        source: LoginApiVersionSource(),
      ).check();
      if (!check.isCompatible) {
        return const MainAccessBlocked(
          FxFailure(kind: FxFailureKind.serverUnavailable),
        );
      }

      final response = await DioClient().dio.get<dynamic>(
        '/system/user/profile',
      );
      final responseData = response.data;
      if (responseData is! Map) {
        return const MainAccessBlocked(
          FxFailure(kind: FxFailureKind.invalidResponse),
        );
      }
      if (responseData['code'] == 0) return const MainAccessAllowed();

      return _blockedForFailure(
        FxFailureMapper.map(
          FxApiException(
            int.tryParse(responseData['code']?.toString() ?? '') ?? -1,
            responseData['msg']?.toString() ?? '',
          ),
        ),
        userData,
      );
    } on Object catch (error) {
      return _blockedForFailure(FxFailureMapper.map(error), userData);
    }
  }

  Future<MainAccessResult> _blockedForFailure(
    FxFailure failure,
    UserDataSingleton userData,
  ) async {
    if (failure.shouldClearAuth) {
      DioClient().clearAuthHeader();
      await userData.clearAuth();
    }
    return MainAccessBlocked(failure);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MainAccessResult>(
      future: _accessResult,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.requireData is MainAccessAllowed) {
          context.read<AppLockCubit>().enterProtectedArea();
          return const MainShell();
        }
        return const _BlockedMainPage();
      },
    );
  }
}

class _BlockedMainPage extends StatelessWidget {
  const _BlockedMainPage();

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
