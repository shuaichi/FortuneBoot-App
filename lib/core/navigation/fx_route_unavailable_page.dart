import 'package:flutter/material.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/layout/fx_page_scaffold.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 无法恢复目标路由时的明确出口。
enum FxRouteUnavailableReason {
  /// 路由没有注册。
  unknownRoute,

  /// 缺少打开对象所需的参数或本地上文。
  missingContext,

  /// 会话未恢复，暂不能安全打开。
  sessionUnavailable,

  /// 当前身份没有该入口权限。
  noPermission,
}

class FxRouteUnavailablePage extends StatelessWidget {
  const FxRouteUnavailablePage({super.key, required this.reason, this.onRetry});

  final FxRouteUnavailableReason reason;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final message = switch (reason) {
      FxRouteUnavailableReason.unknownRoute => s.routeUnavailableUnknown,
      FxRouteUnavailableReason.missingContext =>
        s.routeUnavailableMissingContext,
      FxRouteUnavailableReason.sessionUnavailable => s.routeUnavailableSession,
      FxRouteUnavailableReason.noPermission => s.routeUnavailablePermission,
    };
    return FxPageScaffold(
      title: s.routeUnavailableTitle,
      onBack: () => _leave(context),
      child: FxStateView.error(
        message: message,
        onRetry: onRetry ?? () => _leave(context),
        retryLabel: onRetry == null
            ? s.routeUnavailableBackHome
            : s.commonRetry,
      ),
    );
  }

  void _leave(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    navigator.pushNamedAndRemoveUntil(Routes.main, (_) => false);
  }
}
