import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/features/accounts/data/account_models.dart';
import 'package:fortuneboot/features/accounts/presentation/widgets/account_type_filter_bar.dart';
import 'package:fortuneboot/features/accounts/presentation/widgets/bank_icon.dart';
import 'package:fortuneboot/features/bill_editor/data/editor_options_service.dart';
import 'package:fortuneboot/fx/components/fx_list_section.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_option_picker.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 单选选项弹窗。返回所选项（可清除时返回 null 表示清空）。
Future<T?> showOptionPicker<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required String Function(T) labelOf,
  required int? Function(T) idOf,
  int? selectedId,
  bool allowClear = false,
}) {
  return showFxOptionPicker<T>(
    context,
    title: title,
    options: options,
    labelOf: labelOf,
    idOf: idOf,
    selectedId: selectedId,
    allowClear: allowClear,
  );
}

/// 记账选账户：按账户类型分组（现金 / 信用卡 / 资产 / 贷款），顶部可筛选类型。
Future<AccountOption?> showAccountOptionPicker(
  BuildContext context, {
  required String title,
  required List<AccountOption> accounts,
  int? selectedId,
}) {
  return FxSheet.show<AccountOption>(
    context,
    title: title,
    maxHeightFactor: FxSheet.pickerHeightFactor,
    child: accounts.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(FxSpacing.xxxl),
            child: Center(child: Text(S.of(context).billEditorNoOptions)),
          )
        : _AccountOptionPickerBody(accounts: accounts, selectedId: selectedId),
  );
}

class _AccountOptionPickerBody extends StatefulWidget {
  const _AccountOptionPickerBody({required this.accounts, this.selectedId});

  final List<AccountOption> accounts;
  final int? selectedId;

  @override
  State<_AccountOptionPickerBody> createState() =>
      _AccountOptionPickerBodyState();
}

class _AccountOptionPickerBodyState extends State<_AccountOptionPickerBody> {
  int? _filterType;

  Map<int, int> get _counts {
    final counts = <int, int>{};
    for (final a in widget.accounts) {
      final id = AccountTypeMeta.of(a.accountType).id;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final hideAmounts = context
        .watch<PreferencesCubit>()
        .state
        .dashboard
        .hideAmounts;
    final groups = _groupAccountsByType(
      widget.accounts,
    ).where((g) => _filterType == null || g.meta.id == _filterType).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            FxSpacing.lg,
            FxSpacing.xs,
            FxSpacing.lg,
            FxSpacing.sm,
          ),
          child: AccountTypeFilterBar(
            selectedType: _filterType,
            counts: _counts,
            onChanged: (type) => setState(() => _filterType = type),
          ),
        ),
        Flexible(
          child: groups.isEmpty
              ? Center(
                  child: Text(
                    S.of(context).billEditorNoOptions,
                    style: FxTypography.body.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                )
              : ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: FxSpacing.lg),
                  children: [
                    for (final group in groups) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          FxSpacing.lg,
                          FxSpacing.md,
                          FxSpacing.lg,
                          FxSpacing.xs,
                        ),
                        child: Text(
                          group.meta.localizedName(context),
                          style: FxTypography.label.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FxSpacing.lg,
                        ),
                        child: FxListSection(
                          children: [
                            for (final account in group.accounts)
                              _AccountOptionRow(
                                account: account,
                                selected:
                                    account.accountId == widget.selectedId,
                                hideAmounts: hideAmounts,
                                onTap: () => Navigator.of(
                                  context,
                                ).pop<AccountOption>(account),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _AccountOptionRow extends StatelessWidget {
  const _AccountOptionRow({
    required this.account,
    required this.selected,
    required this.hideAmounts,
    required this.onTap,
  });

  final AccountOption account;
  final bool selected;
  final bool hideAmounts;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final meta = AccountTypeMeta.of(account.accountType);
    final lastFour = account.lastFour;
    final remark = account.remark?.trim();
    final details = [
      if (lastFour != null) '···$lastFour',
      if (remark != null && remark.isNotEmpty) remark,
    ].join(' · ');
    final balanceColor = meta.isLiability ? palette.danger : palette.success;

    return Semantics(
      button: true,
      selected: selected,
      label: account.accountName ?? '',
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg,
              FxSpacing.md,
              FxSpacing.sm,
              FxSpacing.md,
            ),
            child: Row(
              children: [
                BankIcon.resolve(
                  accountName: account.accountName,
                  cardNo: account.cardNo,
                  accountType: account.accountType,
                  size: 36,
                  iconSize: 18,
                ),
                const SizedBox(width: FxSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        account.accountName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FxTypography.body.copyWith(
                          color: palette.textPrimary,
                          fontWeight: selected ? FontWeight.w600 : null,
                        ),
                      ),
                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          details,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FxTypography.caption.copyWith(
                            color: palette.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: FxSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 96),
                  child: FxMoneyText(
                    amount: account.balance,
                    currencyCode: account.currencyCode,
                    fontSize: 13,
                    color: balanceColor,
                    masked: hideAmounts,
                    compactWhenNeeded: true,
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: FxSpacing.xs),
                  Icon(Icons.check_rounded, size: 18, color: palette.primary),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountTypeGroup {
  const _AccountTypeGroup({required this.meta, required this.accounts});
  final AccountTypeMeta meta;
  final List<AccountOption> accounts;
}

List<_AccountTypeGroup> _groupAccountsByType(List<AccountOption> accounts) {
  final byType = <int, List<AccountOption>>{};
  for (final a in accounts) {
    final meta = AccountTypeMeta.of(a.accountType);
    byType.putIfAbsent(meta.id, () => []).add(a);
  }
  final result = <_AccountTypeGroup>[];
  for (final meta in AccountTypeMeta.ordered) {
    final list = byType.remove(meta.id);
    if (list == null || list.isEmpty) continue;
    list.sort((x, y) => (x.sort ?? 0).compareTo(y.sort ?? 0));
    result.add(_AccountTypeGroup(meta: meta, accounts: list));
  }
  for (final entry in byType.entries) {
    if (entry.value.isEmpty) continue;
    entry.value.sort((x, y) => (x.sort ?? 0).compareTo(y.sort ?? 0));
    result.add(
      _AccountTypeGroup(
        meta: AccountTypeMeta.of(entry.key),
        accounts: entry.value,
      ),
    );
  }
  return result;
}

/// 多选弹窗。确认返回所选项列表，取消返回 null。
Future<List<T>?> showMultiSelect<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required String Function(T) labelOf,
  required int Function(T) idOf,
  required List<int> selectedIds,
}) {
  return showFxMultiOptionPicker<T>(
    context,
    title: title,
    options: options,
    labelOf: labelOf,
    idOf: idOf,
    selectedIds: selectedIds.toSet(),
  );
}
