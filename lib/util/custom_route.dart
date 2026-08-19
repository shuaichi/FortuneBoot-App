import 'package:flutter/material.dart';

import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/login/view/login_screen.dart';

class FadePageRoute<T> extends MaterialPageRoute<T> {
  FadePageRoute({required super.builder, super.settings});

  @override
  Duration get transitionDuration => FxMotion.page;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (settings.name == LoginScreen.routeName ||
        MediaQuery.disableAnimationsOf(context)) {
      return child;
    }

    return FadeTransition(opacity: animation, child: child);
  }
}
