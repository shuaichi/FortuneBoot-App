import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/features/bill_editor/data/editor_options_service.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_bloc.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/amount_field.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/editor_pickers.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 多分类拆分区：可增删的「分类 + 金额」行，底部实时总额。
class CategorySplitSection extends StatelessWidget {
  const CategorySplitSection({
    super.key,
    required this.state,
    required this.currencyCode,
  });

  final BillEditorState state;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BillEditorBloc>();
    // 支出/垫付/报销用支出分类；收入用收入分类。
    final categories =
        state.isIncome ? state.options.incomeCategories : state.options.expenseCategories;
    final leaves = <CategoryNode>[];
    for (final root in categories) {
      leaves.addAll(root.flatten().where((n) => n.isLeaf));
    }

    return FxCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg,
              FxSpacing.md,
              FxSpacing.lg,
              FxSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('分类拆分', style: FxTypography.label),
                Text('共 ${state.categoryRows.length} 项',
                    style: FxTypography.caption),
              ],
            ),
          ),
          for (int i = 0; i < state.categoryRows.length; i++)
            _CategoryRow(
              index: i,
              row: state.categoryRows[i],
              leaves: leaves,
              currencyCode: currencyCode,
              canRemove: state.categoryRows.length > 1,
              onPickCategory: () async {
                final picked = await showOptionPicker<CategoryNode>(
                  context,
                  title: '选择分类',
                  options: leaves,
                  labelOf: (c) => c.categoryName ?? '',
                  selectedId: state.categoryRows[i].categoryId,
                  idOf: (c) => c.categoryId,
                );
                if (picked != null) {
                  bloc.add(CategoryRowCategoryChanged(
                    i,
                    picked.categoryId,
                    picked.categoryName,
                  ));
                }
              },
              onAmount: (v) => bloc.add(CategoryRowAmountChanged(i, v)),
              onRemove: () => bloc.add(CategoryRowRemoved(i)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg,
              FxSpacing.sm,
              FxSpacing.lg,
              FxSpacing.md,
            ),
            child: InkWell(
              onTap: () => bloc.add(const CategoryRowAdded()),
              borderRadius: FxRadius.tileBorder,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: FxSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded,
                        size: 18, color: FxColors.primary),
                    const SizedBox(width: FxSpacing.xs),
                    Text('添加分类',
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

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.index,
    required this.row,
    required this.leaves,
    required this.currencyCode,
    required this.canRemove,
    required this.onPickCategory,
    required this.onAmount,
    required this.onRemove,
  });

  final int index;
  final CategoryAmountRow row;
  final List<CategoryNode> leaves;
  final String currencyCode;
  final bool canRemove;
  final VoidCallback onPickCategory;
  final ValueChanged<double> onAmount;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasCat = row.categoryName != null && row.categoryName!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FxSpacing.lg,
        vertical: FxSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: InkWell(
              onTap: onPickCategory,
              borderRadius: FxRadius.tileBorder,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FxSpacing.md,
                  vertical: FxSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: FxColors.surfaceMuted,
                  borderRadius: FxRadius.tileBorder,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasCat ? row.categoryName! : '选择分类',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FxTypography.body.copyWith(
                          color: hasCat
                              ? FxColors.textPrimary
                              : FxColors.textTertiary,
                        ),
                      ),
                    ),
                    const Icon(Icons.expand_more_rounded,
                        size: 18, color: FxColors.textTertiary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: FxSpacing.sm),
          Expanded(
            flex: 3,
            child: AmountField(
              key: ValueKey('cat_amount_${index}_${row.categoryId}'),
              value: row.amount,
              currencyCode: currencyCode,
              large: false,
              onChanged: onAmount,
            ),
          ),
          if (canRemove)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded,
                  size: 20, color: FxColors.textTertiary),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
