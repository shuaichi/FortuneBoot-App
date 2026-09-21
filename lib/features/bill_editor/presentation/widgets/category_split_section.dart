import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/features/bill_editor/data/editor_options_service.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_bloc.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/amount_field.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/tree/fx_tree_picker.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

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
    final palette = FxPalette.of(context);
    final bloc = context.read<BillEditorBloc>();
    // 支出/垫付/报销用支出分类；收入用收入分类。保留完整树，叶子可选。
    final categories = state.isIncome
        ? state.options.incomeCategories
        : state.options.expenseCategories;

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
                Text(
                  S.of(context).billEditorCategorySplit,
                  style: FxTypography.label.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                Text(
                  S.of(context).billEditorItemCount(state.categoryRows.length),
                  style: FxTypography.caption.copyWith(
                    color: palette.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          for (final row in state.categoryRows)
            _CategoryRow(
              key: ValueKey(row.rowId),
              row: row,
              currencyCode: currencyCode,
              canRemove: state.categoryRows.length > 1,
              onPickCategory: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                final picked = await FxTreePicker.show<CategoryNode>(
                  context,
                  roots: categories,
                  childrenOf: (c) => c.children,
                  labelOf: (c) => c.categoryName ?? '',
                  idOf: (c) => c.categoryId,
                  initialSelected: row.categoryId == null
                      ? const {}
                      : {row.categoryId! as Object},
                  leafOnly: true,
                  initiallyCollapsed: true,
                  title: S.of(context).billEditorSelectCategory,
                );
                if (!context.mounted || picked == null || picked.isEmpty) return;
                final category = picked.first;
                bloc.add(
                  CategoryRowCategoryChanged(
                    row.rowId,
                    category.categoryId,
                    category.categoryName,
                  ),
                );
              },
              onAmount: (value) =>
                  bloc.add(CategoryRowAmountChanged(row.rowId, value)),
              onRemove: () {
                FocusManager.instance.primaryFocus?.unfocus();
                bloc.add(CategoryRowRemoved(row.rowId));
              },
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
                    Icon(Icons.add_rounded, size: 18, color: palette.primary),
                    const SizedBox(width: FxSpacing.xs),
                    Text(
                      S.of(context).billEditorAddCategory,
                      style: FxTypography.bodyStrong.copyWith(
                        color: palette.primary,
                      ),
                    ),
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
    super.key,
    required this.row,
    required this.currencyCode,
    required this.canRemove,
    required this.onPickCategory,
    required this.onAmount,
    required this.onRemove,
  });

  final CategoryAmountRow row;
  final String currencyCode;
  final bool canRemove;
  final VoidCallback onPickCategory;
  final ValueChanged<double> onAmount;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
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
                  color: palette.surfaceMuted,
                  borderRadius: FxRadius.tileBorder,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasCat
                            ? row.categoryName!
                            : S.of(context).billEditorSelectCategory,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FxTypography.body.copyWith(
                          color: hasCat
                              ? palette.textPrimary
                              : palette.textTertiary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: palette.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: FxSpacing.sm),
          Expanded(
            flex: 3,
            child: AmountField(
              key: ValueKey('cat_amount_${row.rowId}'),
              value: row.amount,
              currencyCode: currencyCode,
              large: false,
              onChanged: onAmount,
            ),
          ),
          if (canRemove)
            FxIconButton(
              icon: Icons.remove_circle_outline_rounded,
              tooltip: S.of(context).accountsDelete,
              color: palette.textTertiary,
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
