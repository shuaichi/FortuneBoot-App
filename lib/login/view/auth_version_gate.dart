import 'package:flutter/material.dart';
import 'package:fortuneboot/core/app_constants.dart';
import 'package:fortuneboot/core/auth/auth_version_checker.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/login/auth_version_source.dart';
import 'package:fortuneboot/login/model/users.dart';
import 'package:fortuneboot/login/server/server_endpoint.dart';
import 'package:fortuneboot/login/view/login_screen.dart';
import 'package:fortuneboot/util/dio_client.dart';

class AuthVersionGate extends StatefulWidget {
  const AuthVersionGate({super.key});

  @override
  State<AuthVersionGate> createState() => _AuthVersionGateState();
}

class _AuthVersionGateState extends State<AuthVersionGate> {
  late final Future<_AuthGateState> _state = _loadState();

  Future<_AuthGateState> _loadState() async {
    final userData = UserDataSingleton();
    final protocol = await userData.getStr(UserDataSingleton.baseUrlProtocol);
    final domain = await userData.getStr(UserDataSingleton.baseUrlDomain);
    final port = await userData.getStr(UserDataSingleton.baseUrlPort);
    if (protocol?.isEmpty != false || domain?.isEmpty != false) {
      return const _AuthGateState.missingConfiguration();
    }

    try {
      final endpoint = ServerEndpoint.parse(
        protocol: protocol!,
        host: domain!,
        port: port,
        apiPrefix: ServerEndpoint.sessionApiPrefix,
      );
      DioClient().updateBaseUrl(endpoint.apiBaseUri.toString());
    } on ServerEndpointFormatException {
      return const _AuthGateState.missingConfiguration();
    }
    try {
      final check = await AuthVersionChecker(
        source: LoginApiVersionSource(),
      ).check();
      return _AuthGateState.checked(check);
    } on Exception {
      return const _AuthGateState.checked(
        ApiVersionCheckResult(status: ApiVersionStatus.connectionFailed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AuthGateState>(
      future: _state,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _AuthVersionFailurePage(
            state: _AuthGateState.checked(
              ApiVersionCheckResult(status: ApiVersionStatus.connectionFailed),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final state = snapshot.requireData;
        if (state.check?.isCompatible == true) return const LoginScreen();
        return _AuthVersionFailurePage(state: state);
      },
    );
  }
}

class _AuthVersionFailurePage extends StatelessWidget {
  const _AuthVersionFailurePage({required this.state});

  final _AuthGateState state;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final check = state.check;
    final message = switch (check?.status) {
      ApiVersionStatus.versionTooLow => s.apiVersionTooLow(
        check!.actualVersion,
        AppConstants.minApiVersion,
      ),
      ApiVersionStatus.versionTooHigh => s.apiVersionTooHigh(
        check!.actualVersion,
        AppConstants.maxApiVersion,
      ),
      ApiVersionStatus.endpointUnavailable => s.apiVersionEndpointUnavailable(
        AppConstants.minApiVersion,
      ),
      ApiVersionStatus.versionInvalid => s.apiVersionUnavailable,
      ApiVersionStatus.connectionFailed => s.serverConnectionFailed,
      ApiVersionStatus.compatible => '',
      null => s.apiVersionUnavailable,
    };

    return Scaffold(
      appBar: AppBar(title: Text(s.baseUrlConfig)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFFF3B30),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(s.error, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.baseUrlConfig,
                  (route) => false,
                ),
                child: Text(s.baseUrlConfig),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthGateState {
  const _AuthGateState.checked(this.check) : isMissingConfiguration = false;

  const _AuthGateState.missingConfiguration()
    : check = null,
      isMissingConfiguration = true;

  final ApiVersionCheckResult? check;
  final bool isMissingConfiguration;
}
