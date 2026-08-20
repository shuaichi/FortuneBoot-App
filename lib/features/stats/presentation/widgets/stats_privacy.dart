import 'package:flutter/widgets.dart';

class StatsPrivacy extends InheritedWidget {
  const StatsPrivacy({
    super.key,
    required this.hideAmounts,
    required super.child,
  });

  final bool hideAmounts;

  static bool hideAmountsOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<StatsPrivacy>()
            ?.hideAmounts ??
        false;
  }

  @override
  bool updateShouldNotify(StatsPrivacy oldWidget) {
    return hideAmounts != oldWidget.hideAmounts;
  }
}
