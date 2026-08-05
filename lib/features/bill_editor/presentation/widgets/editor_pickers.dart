import 'package:flutter/material.dart';
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
