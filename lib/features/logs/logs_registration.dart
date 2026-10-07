import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/features/logs/presentation/logs_page.dart';

/// 注册系统日志 feature 路由。由 main.dart 在启动时统一调用。
void registerLogsFeature() {
  AppRouter.register(Routes.logs, (args) => const LogsPage());
}
