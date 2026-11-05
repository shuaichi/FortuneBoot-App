import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_bloc.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/amount_field.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/editor_pickers.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_option_picker.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

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
    final palette = FxPalette.of(context);
    final bloc = context.read<BillEditorBloc>();
    final categories = state.extraCategoryRows;

    Future<void> addExtra() async {
      if (state.isTransfer) {
        bloc.add(const ExtraRowAdded());
        return;
      }
      if (categories.isEmpty) {
        FxFeedback.error(
          context,
          message: S.of(context).billEditorExtraCategoryRequired,
        );
        return;
      }
      final category = await showOptionPicker<CategoryAmountRow>(
        context,
        title: S.of(context).billEditorExtraCategory,
        options: categories,
        labelOf: (row) => row.categoryName ?? '',
        idOf: (row) => row.categoryId,
      );
      if (!context.mounted || category.kind != FxSelectionKind.selected) {
        return;
      }
      final selected = category.value!;
      if (selected.categoryId == null) return;
      bloc.add(ExtraRowAdded(categoryId: selected.categoryId));
    }

    Future<void> pickCategory(ExtraRow row) async {
      final category = await showOptionPicker<CategoryAmountRow>(
        context,
        title: S.of(context).billEditorExtraCategory,
        options: categories,
        labelOf: (item) => item.categoryName ?? '',
        idOf: (item) => item.categoryId,
        selectedId: row.categoryId,
      );
      if (!context.mounted || category.kind != FxSelectionKind.selected) {
        return;
      }
      final selected = category.value!;
      if (selected.categoryId == null) return;
      bloc.add(
        ExtraRowChanged(
          row.rowId,
          row.copyWith(categoryId: selected.categoryId),
        ),
      );
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
            child: Text(
              S.of(context).billEditorExtras,
              style: FxTypography.label.copyWith(color: palette.textSecondary),
            ),
          ),
          for (final row in state.extras)
            _ExtraRowEditor(
              key: ValueKey(row.rowId),
              row: row,
              currencyCode: currencyCode,
              showSide: state.isTransfer,
              categoryName: state.extraCategoryRows
                  .where((category) => category.categoryId == row.categoryId)
                  .map((category) => category.categoryName)
                  .firstOrNull,
              onPickCategory: state.isTransfer ? null : () => pickCategory(row),
              onChanged: (value) => bloc.add(ExtraRowChanged(row.rowId, value)),
              onRemove: () {
                FocusManager.instance.primaryFocus?.unfocus();
                bloc.add(ExtraRowRemoved(row.rowId));
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
              onTap: addExtra,
              borderRadius: FxRadius.tileBorder,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: FxSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, size: 18, color: palette.primary),
                    const SizedBox(width: FxSpacing.xs),
                    Text(
                      S.of(context).billEditorAddExtra,
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

class _ExtraRowEditor extends StatelessWidget {
  const _ExtraRowEditor({
    super.key,
    required this.row,
    required this.currencyCode,
    required this.showSide,
    this.categoryName,
    this.onPickCategory,
    required this.onChanged,
    required this.onRemove,
  });

  final ExtraRow row;
  final String currencyCode;
  final bool showSide;
  final String? categoryName;
  final VoidCallback? onPickCategory;
  final ValueChanged<ExtraRow> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
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
                  segments: [
                    FxSegment(1, S.of(context).billEditorFee),
                    FxSegment(2, S.of(context).billEditorDiscount),
                  ],
                ),
              ),
              FxIconButton(
                icon: Icons.remove_circle_outline_rounded,
                tooltip: S.of(context).accountsDelete,
                color: palette.textTertiary,
                onPressed: onRemove,
              ),
            ],
          ),
          if (!showSide) ...[
            const SizedBox(height: FxSpacing.sm),
            InkWell(
              onTap: onPickCategory,
              borderRadius: FxRadius.tileBorder,
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: FxSpacing.sm,
                  vertical: FxSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  borderRadius: FxRadius.tileBorder,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 18,
                      color: palette.textTertiary,
                    ),
                    const SizedBox(width: FxSpacing.sm),
                    Expanded(
                      child: Text(
                        categoryName ??
                            S.of(context).billEditorSelectExtraCategory,
                        style: FxTypography.body.copyWith(
                          color: categoryName == null
                              ? palette.textTertiary
                              : palette.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: palette.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: FxSpacing.sm),
          AmountField(
            key: ValueKey('extra_amount_${row.rowId}'),
            value: row.amount,
            currencyCode: currencyCode,
            large: false,
            onChanged: (v) => onChanged(row.copyWith(amount: v)),
          ),
          const SizedBox(height: FxSpacing.sm),
          TextFormField(
            key: ValueKey('extra_remark_${row.rowId}'),
            initialValue: row.remark ?? '',
            style: FxTypography.body.copyWith(color: palette.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: Icon(
                Icons.notes_rounded,
                size: 18,
                color: palette.textTertiary,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              hintText: S.of(context).billEditorExtraRemarkHint,
              hintStyle: FxTypography.body.copyWith(
                color: palette.textTertiary,
              ),
              filled: true,
              fillColor: palette.surfaceMuted,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: FxSpacing.sm,
                vertical: FxSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: FxRadius.tileBorder,
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) => onChanged(row.copyWith(remark: v)),
          ),
          if (showSide) ...[
            const SizedBox(height: FxSpacing.sm),
            FxSegmented<int>(
              value: row.accountSide,
              onChanged: (v) => onChanged(row.copyWith(accountSide: v)),
              segments: [
                FxSegment(1, S.of(context).billEditorTransferOutAccount),
                FxSegment(2, S.of(context).billEditorTransferInAccount),
              ],
            ),
          ],
          Divider(height: FxSpacing.lg, color: palette.border),
        ],
      ),
    );
  }
}
