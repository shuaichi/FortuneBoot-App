import 'package:flutter/material.dart';
import 'package:fortuneboot/features/accounts/data/account_models.dart';
import 'package:fortuneboot/features/bill_editor/data/editor_options_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
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
    expand: true,
    expandHeightFactor: FxSheet.pickerHeightFactor,
    child: options.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(FxSpacing.xxxl),
            child: Center(child: Text(S.of(context).billEditorNoOptions)),
          )
        : ListView(
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

/// 记账选账户：按账户类型分组（现金 / 信用卡 / 资产 / 贷款），与账户管理一致。
Future<AccountOption?> showAccountOptionPicker(
  BuildContext context, {
  required String title,
  required List<AccountOption> accounts,
  int? selectedId,
}) {
  final palette = FxPalette.of(context);
  final groups = _groupAccountsByType(accounts);
  return FxSheet.show<AccountOption>(
    context,
    title: title,
    expand: true,
    expandHeightFactor: FxSheet.pickerHeightFactor,
    child: accounts.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(FxSpacing.xxxl),
            child: Center(child: Text(S.of(context).billEditorNoOptions)),
          )
        : ListView(
            padding: const EdgeInsets.only(bottom: FxSpacing.lg),
            children: [
              for (final group in groups) ...[
                _AccountTypeHeader(meta: group.meta),
                for (final account in group.accounts)
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.only(
                      left: FxSpacing.lg + FxSpacing.xl,
                      right: FxSpacing.lg,
                      top: 0,
                      bottom: 0,
                    ),
                    minVerticalPadding: 0,
                    title: Text(
                      account.accountName ?? '',
                      style: FxTypography.body.copyWith(
                        color: palette.textPrimary,
                      ),
                    ),
                    trailing: account.accountId == selectedId
                        ? Icon(Icons.check_rounded, color: palette.primary)
                        : null,
                    onTap: () =>
                        Navigator.of(context).pop<AccountOption>(account),
                  ),
              ],
            ],
          ),
  );
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
    expand: true,
    expandHeightFactor: FxSheet.pickerHeightFactor,
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
      children: [
        Expanded(
          child: ListView(
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
