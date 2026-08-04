import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_bloc.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/amount_field.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 附加费用区（仅支出/转账）：手续费1/优惠2 + 金额 + 方向(转账时)。
class ExtrasSection extends StatelessWidget {
  const ExtrasSection({
    super.key,
    required this.state,
    required this.currencyCode,
  });

  final BillEditorState state;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BillEditorBloc>();
    return FxCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              FxSpacing.lg,
              FxSpacing.md,
              FxSpacing.lg,
              FxSpacing.sm,
            ),
            child: Text('附加费用', style: FxTypography.label),
          ),
          for (int i = 0; i < state.extras.length; i++)
            _ExtraRowEditor(
              index: i,
              row: state.extras[i],
              currencyCode: currencyCode,
              showSide: state.isTransfer,
              onChanged: (r) => bloc.add(ExtraRowChanged(i, r)),
              onRemove: () => bloc.add(ExtraRowRemoved(i)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg,
              FxSpacing.sm,
              FxSpacing.lg,
              FxSpacing.md,
            ),
            child: InkWell(
              onTap: () => bloc.add(const ExtraRowAdded()),
              borderRadius: FxRadius.tileBorder,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: FxSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded,
                        size: 18, color: FxColors.primary),
                    const SizedBox(width: FxSpacing.xs),
                    Text('添加手续费/优惠',
                        style: FxTypography.bodyStrong
                            .copyWith(color: FxColors.primary)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtraRowEditor extends StatelessWidget {
  const _ExtraRowEditor({
    required this.index,
    required this.row,
    required this.currencyCode,
    required this.showSide,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final ExtraRow row;
  final String currencyCode;
  final bool showSide;
  final ValueChanged<ExtraRow> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FxSpacing.lg,
        vertical: FxSpacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FxSegmented<int>(
                  value: row.extraType,
                  onChanged: (v) => onChanged(row.copyWith(extraType: v)),
                  segments: const [
                    FxSegment(1, '手续费'),
                    FxSegment(2, '优惠'),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded,
                    size: 20, color: FxColors.textTertiary),
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.sm),
          AmountField(
            key: ValueKey('extra_amount_$index'),
            value: row.amount,
            currencyCode: currencyCode,
            large: false,
            onChanged: (v) => onChanged(row.copyWith(amount: v)),
          ),
          if (showSide) ...[
            const SizedBox(height: FxSpacing.sm),
            FxSegmented<int>(
              value: row.accountSide,
              onChanged: (v) => onChanged(row.copyWith(accountSide: v)),
              segments: const [
                FxSegment(1, '转出账户'),
                FxSegment(2, '转入账户'),
              ],
            ),
          ],
          const Divider(height: FxSpacing.lg, color: FxColors.border),
        ],
      ),
    );
  }
}
