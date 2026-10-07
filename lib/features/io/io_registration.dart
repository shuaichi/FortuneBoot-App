import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/features/io/presentation/io_page.dart';

/// 注册 IO（导入导出）feature 路由。由 main.dart 在启动时统一调用。
void registerIoFeature() {
  AppRouter.register(Routes.io, (args) => const IoPage());
}
