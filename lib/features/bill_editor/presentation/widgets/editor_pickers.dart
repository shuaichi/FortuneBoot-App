import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/features/accounts/data/account_models.dart';
import 'package:fortuneboot/features/accounts/presentation/widgets/account_type_filter_bar.dart';
import 'package:fortuneboot/features/accounts/presentation/widgets/bank_icon.dart';
import 'package:fortuneboot/features/bill_editor/data/editor_options_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
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
  final palette = FxPalette.of(context);
  return FxSheet.show<T>(
    context,
    title: title,
    child: options.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(FxSpacing.xxxl),
            child: Center(child: Text(S.of(context).billEditorNoOptions)),
          )
        : ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: FxSpacing.lg),
            children: [
              if (allowClear)
                ListTile(
                  title: Text(
                    S.of(context).billEditorNoSelection,
                    style: FxTypography.body.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop<T?>(),
                ),
              ...options.map((o) {
                final selected = idOf(o) == selectedId;
                return ListTile(
                  title: Text(
                    labelOf(o),
                    style: FxTypography.body.copyWith(
                      color: palette.textPrimary,
                    ),
                  ),
                  trailing: selected
                      ? Icon(Icons.check_rounded, color: palette.primary)
                      : null,
                  onTap: () => Navigator.of(context).pop<T>(o),
                );
              }),
            ],
          ),
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

  Widget? _accountSubtitle(
    BuildContext context,
    AccountOption account,
    FxPalette palette,
  ) {
    final lastFour = account.lastFour;
    final remark = account.remark?.trim();
    final hasRemark = remark != null && remark.isNotEmpty;
    if (lastFour == null && !hasRemark) return null;

    return Text.rich(
      TextSpan(
        children: [
          if (lastFour != null)
            TextSpan(
              text: '···$lastFour',
              style: FxTypography.caption.copyWith(
                color: palette.textSecondary,
              ),
            ),
          if (lastFour != null && hasRemark)
            TextSpan(
              text: '  ',
              style: FxTypography.caption.copyWith(
                color: palette.textSecondary,
              ),
            ),
          if (hasRemark)
            TextSpan(
              text: remark,
              style: FxTypography.caption.copyWith(color: palette.primary),
            ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
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
                      _AccountTypeHeader(meta: group.meta),
                      for (final account in group.accounts)
                        ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          // 相对类型标题缩进一个 tab（xl），形成层级。
                          contentPadding: const EdgeInsets.only(
                            left: FxSpacing.lg + FxSpacing.xl,
                            right: FxSpacing.lg,
                          ),
                          minVerticalPadding: 0,
                          leading: BankIcon.resolve(
                            accountName: account.accountName,
                            cardNo: account.cardNo,
                            accountType: account.accountType,
                            size: 32,
                            iconSize: 16,
                          ),
                          title: Text(
                            account.accountName ?? '',
                            style: FxTypography.body.copyWith(
                              color: palette.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: _accountSubtitle(context, account, palette),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FxMoneyText(
                                amount: account.balance,
                                currencyCode: account.currencyCode,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: palette.textSecondary,
                                masked: hideAmounts,
                              ),
                              if (account.accountId == widget.selectedId) ...[
                                const SizedBox(width: FxSpacing.sm),
                                Icon(
                                  Icons.check_rounded,
                                  color: palette.primary,
                                ),
                              ],
                            ],
                          ),
                          onTap: () =>
                              Navigator.of(context).pop<AccountOption>(account),
                        ),
                    ],
                  ],
                ),
        ),
      ],
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

class _AccountTypeHeader extends StatelessWidget {
  const _AccountTypeHeader({required this.meta});
  final AccountTypeMeta meta;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        FxSpacing.sm,
        FxSpacing.lg,
        2,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: meta.tint(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: FxSpacing.sm),
          Expanded(
            child: Text(
              meta.localizedName(context),
              style: FxTypography.label.copyWith(color: palette.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
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
  return FxSheet.show<List<T>>(
    context,
    title: title,
    child: _MultiSelectBody<T>(
      options: options,
      labelOf: labelOf,
      idOf: idOf,
      initialSelected: selectedIds,
    ),
  );
}

class _MultiSelectBody<T> extends StatefulWidget {
  const _MultiSelectBody({
    required this.options,
    required this.labelOf,
    required this.idOf,
    required this.initialSelected,
  });

  final List<T> options;
  final String Function(T) labelOf;
  final int Function(T) idOf;
  final List<int> initialSelected;

  @override
  State<_MultiSelectBody<T>> createState() => _MultiSelectBodyState<T>();
}

class _MultiSelectBodyState<T> extends State<_MultiSelectBody<T>> {
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelected};
  }

  @override
  Widget build(BuildContext context) {
    if (widget.options.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(FxSpacing.xxxl),
        child: Center(child: Text(S.of(context).billEditorNoOptions)),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: widget.options.map((o) {
              final id = widget.idOf(o);
              final checked = _selected.contains(id);
              return CheckboxListTile.adaptive(
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: FxPalette.of(context).primary,
                title: Text(widget.labelOf(o), style: FxTypography.body),
                value: checked,
                onChanged: (v) => setState(() {
                  if (v == true) {
                    _selected.add(id);
                  } else {
                    _selected.remove(id);
                  }
                }),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(FxSpacing.lg),
          child: FxButton(
            label: S.of(context).ok,
            expand: true,
            onPressed: () {
              final result = widget.options
                  .where((o) => _selected.contains(widget.idOf(o)))
                  .toList();
              Navigator.of(context).pop<List<T>>(result);
            },
          ),
        ),
      ],
    );
  }
}
