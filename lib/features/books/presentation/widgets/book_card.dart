import 'package:flutter/material.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_chart_palette.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.isDefault,
    required this.isCurrent,
    required this.inRecycleBin,
    required this.onTap,
    required this.onMenu,
    required this.onMissingAccountTap,
  });

  final FortuneBookVo book;
  final bool isDefault;
  final bool isCurrent;
  final bool inRecycleBin;
  final VoidCallback onTap;
  final VoidCallback onMenu;
  final VoidCallback onMissingAccountTap;

  bool get hasMissingAccount =>
      book.defaultExpenseAccountId == null ||
      book.defaultIncomeAccountId == null ||
      book.defaultTransferOutAccountId == null ||
      book.defaultTransferInAccountId == null;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final accent = _accentFor(book.bookId ?? book.bookName.hashCode);
    return Opacity(
      opacity: book.enable ? 1 : 0.62,
      child: FxCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.menu_book_rounded, color: accent),
                ),
                const SizedBox(width: FxSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.bookName?.trim().isNotEmpty == true
                            ? book.bookName!.trim()
                            : S.of(context).booksUnnamedBook,
                        style: FxTypography.title.copyWith(
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: FxSpacing.xs),
                      Text(
                        book.remark?.trim().isNotEmpty == true
                            ? book.remark!.trim()
                            : S
                                  .of(context)
                                  .booksDefaultExpenseAccountValue(
                                    book.defaultExpenseAccountName ??
                                        S.of(context).commonPleaseSelect,
                                  ),
                        style: FxTypography.caption.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _menuButton(context),
              ],
            ),
            const SizedBox(height: FxSpacing.md),
            Wrap(
              spacing: FxSpacing.xs,
              runSpacing: FxSpacing.xs,
              children: [
                FxTagChip(label: book.defaultCurrency ?? 'CNY'),
                if (isDefault)
                  FxTagChip(
                    label: S.of(context).booksDefaultBookTag,
                    selected: true,
                  ),
                if (isCurrent)
                  FxTagChip(
                    label: S.of(context).booksCurrentUsingTag,
                    selected: true,
                  ),
                if (!book.enable)
                  FxTagChip(
                    label: S.of(context).booksDisabled,
                    dotColor: palette.warning,
                  ),
                if (inRecycleBin)
                  FxTagChip(
                    label: S.of(context).booksRecycleBin,
                    dotColor: palette.danger,
                  ),
              ],
            ),
            if (hasMissingAccount && !inRecycleBin) ...[
              const SizedBox(height: FxSpacing.sm),
              GestureDetector(
                onTap: onMissingAccountTap,
                child: Text(
                  S.of(context).booksDefaultAccountMissing,
                  style: FxTypography.caption.copyWith(color: palette.warning),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context) {
    final tooltip = MaterialLocalizations.of(context).showMenuTooltip;
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: InkResponse(
          onTap: onMenu,
          radius: 24,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              Icons.more_horiz_rounded,
              color: FxPalette.of(context).textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Color _accentFor(int seed) => FxChartPalette.colorAt(seed.abs());
}
