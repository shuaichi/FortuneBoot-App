import 'package:flutter/widgets.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';

@immutable
class BillsNavigationRequest {
  const BillsNavigationRequest({
    required this.revision,
    required this.entryRequest,
  });

  final int revision;
  final BillsEntryRequest entryRequest;
}

class BillsNavigationController extends ChangeNotifier {
  BillsNavigationRequest? _request;
  var _revision = 0;

  BillsNavigationRequest? get request => _request;

  void open(BillsEntryRequest entryRequest) {
    _request = BillsNavigationRequest(
      revision: ++_revision,
      entryRequest: entryRequest,
    );
    notifyListeners();
  }
}

class BillsNavigationScope
    extends InheritedNotifier<BillsNavigationController> {
  const BillsNavigationScope({
    super.key,
    required BillsNavigationController controller,
    required super.child,
  }) : super(notifier: controller);

  static BillsNavigationController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<BillsNavigationScope>()
      ?.notifier;
}
