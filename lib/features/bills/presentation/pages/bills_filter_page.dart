import 'package:flutter/material.dart';
import 'package:fortuneboot/features/bills/data/bills_filter.dart';
import 'package:fortuneboot/features/bills/presentation/widgets/bills_filter_sheet.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 账单筛选的页面级骨架：表单滚动，主要操作始终固定在底部。
class BillsFilterPage extends StatefulWidget {
  const BillsFilterPage({
    super.key,
    required this.initial,
    required this.onApply,
    this.bookId,
    this.groupId,
  });

  final BillsFilter initial;
  final ValueChanged<BillsFilter> onApply;
  final int? bookId;
  final int? groupId;

  @override
  State<BillsFilterPage> createState() => _BillsFilterPageState();
}

class _BillsFilterPageState extends State<BillsFilterPage> {
  final _formKey = GlobalKey<BillsFilterSheetState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: BillsFilterSheet(
              key: _formKey,
              initial: widget.initial,
              bookId: widget.bookId,
              groupId: widget.groupId,
              onApply: widget.onApply,
            ),
          ),
        ),
        Material(
          key: const ValueKey('bills-filter-actions'),
          color: FxPalette.of(context).surface,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                FxSpacing.lg,
                FxSpacing.md,
                FxSpacing.lg,
                FxSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FxButton.text(
                      label: S.of(context).billsReset,
                      onPressed: () => _formKey.currentState?.reset(),
                    ),
                  ),
                  const SizedBox(width: FxSpacing.md),
                  Expanded(
                    flex: 2,
                    child: FxButton(
                      label: S.of(context).billsApply,
                      expand: true,
                      onPressed: () => _formKey.currentState?.apply(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
