import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 按平台创建页面路由，保留 Apple 返回手势与 Web 的轻量切换。
///
/// @author JoyCode
/// @since 2026/11/04
Route<T> buildFxRoute<T>({
  required WidgetBuilder builder,
  required RouteSettings settings,
}) {
  if (kIsWeb) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, _, _) => builder(context),
      transitionDuration: const Duration(milliseconds: 140),
      reverseTransitionDuration: const Duration(milliseconds: 100),
      transitionsBuilder: (context, animation, _, child) {
        if (MediaQuery.disableAnimationsOf(context)) {
          return child;
        }
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  if (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    return CupertinoPageRoute<T>(settings: settings, builder: builder);
  }

  return MaterialPageRoute<T>(settings: settings, builder: builder);
}
