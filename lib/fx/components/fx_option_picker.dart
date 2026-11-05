import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_list_section.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 单值选择的三种互斥结果。
enum FxSelectionKind { cancelled, cleared, selected }

/// 单值选择结果；只有 [FxSelectionKind.selected] 带有非空 [value]。
class FxSelectionResult<T> {
  const FxSelectionResult._(this.kind, this.value);

  const FxSelectionResult.cancelled() : this._(FxSelectionKind.cancelled, null);

  const FxSelectionResult.cleared() : this._(FxSelectionKind.cleared, null);

  const FxSelectionResult.selected(T value)
    : this._(FxSelectionKind.selected, value);

  final FxSelectionKind kind;
  final T? value;
}

/// 通用单选属性选择器，明确区分取消、清空和选中。
Future<FxSelectionResult<T>> showFxOptionPickerResult<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required String Function(T) labelOf,
  required int? Function(T) idOf,
  String Function(T)? subtitleOf,
  int? selectedId,
  bool allowClear = false,
  String? clearLabel,
  String? emptyText,
  bool? searchable,
  String? searchHint,
}) async {
  final result = await FxSheet.show<FxSelectionResult<T>>(
    context,
    title: title,
    maxHeightFactor: FxSheet.pickerHeightFactor,
    child: _FxOptionPickerBody<T>(
      options: options,
      labelOf: labelOf,
      subtitleOf: subtitleOf,
      idOf: idOf,
      initialSelected: selectedId == null ? const {} : {selectedId},
      multiSelect: false,
      allowClear: allowClear,
      clearLabel: clearLabel,
      emptyText: emptyText,
      searchable: searchable,
      searchHint: searchHint,
    ),
  );
  return result ?? FxSelectionResult<T>.cancelled();
}

/// 兼容旧调用方；新代码使用 [showFxOptionPickerResult] 区分取消与清空。
Future<T?> showFxOptionPicker<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required String Function(T) labelOf,
  required int? Function(T) idOf,
  String Function(T)? subtitleOf,
  int? selectedId,
  bool allowClear = false,
  String? clearLabel,
  String? emptyText,
  bool? searchable,
  String? searchHint,
}) async {
  final result = await showFxOptionPickerResult<T>(
    context,
    title: title,
    options: options,
    labelOf: labelOf,
    idOf: idOf,
    subtitleOf: subtitleOf,
    selectedId: selectedId,
    allowClear: allowClear,
    clearLabel: clearLabel,
    emptyText: emptyText,
    searchable: searchable,
    searchHint: searchHint,
  );
  return result.kind == FxSelectionKind.selected ? result.value : null;
}

/// 通用多选属性选择器：搜索 + 连续分组列表 + 确认按钮。
Future<List<T>?> showFxMultiOptionPicker<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required String Function(T) labelOf,
  required int? Function(T) idOf,
  String Function(T)? subtitleOf,
  Set<int> selectedIds = const {},
  String? emptyText,
  bool? searchable,
  String? searchHint,
}) {
  return FxSheet.show<List<T>>(
    context,
    title: title,
    maxHeightFactor: FxSheet.pickerHeightFactor,
    child: _FxOptionPickerBody<T>(
      options: options,
      labelOf: labelOf,
      subtitleOf: subtitleOf,
      idOf: idOf,
      initialSelected: selectedIds,
      multiSelect: true,
      emptyText: emptyText,
      searchable: searchable,
      searchHint: searchHint,
    ),
  );
}

class _FxOptionPickerBody<T> extends StatefulWidget {
  const _FxOptionPickerBody({
    required this.options,
    required this.labelOf,
    required this.idOf,
    required this.initialSelected,
    required this.multiSelect,
    this.subtitleOf,
    this.allowClear = false,
    this.clearLabel,
    this.emptyText,
    this.searchable,
    this.searchHint,
  });

  final List<T> options;
  final String Function(T) labelOf;
  final String Function(T)? subtitleOf;
  final int? Function(T) idOf;
  final Set<int> initialSelected;
  final bool multiSelect;
  final bool allowClear;
  final String? clearLabel;
  final String? emptyText;
  final bool? searchable;
  final String? searchHint;

  @override
  State<_FxOptionPickerBody<T>> createState() => _FxOptionPickerBodyState<T>();
}

class _FxOptionPickerBodyState<T> extends State<_FxOptionPickerBody<T>> {
  late final Set<int> _selected = {...widget.initialSelected};
  String _query = '';

  bool get _showSearch => widget.searchable ?? widget.options.length >= 8;

  List<T> get _visible {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.options;
    return widget.options.where((option) {
      final label = widget.labelOf(option).toLowerCase();
      final subtitle = widget.subtitleOf?.call(option).toLowerCase() ?? '';
      return label.contains(query) || subtitle.contains(query);
    }).toList();
  }

  void _select(T option) {
    HapticFeedback.selectionClick();
    if (widget.multiSelect) {
      final id = widget.idOf(option);
      if (id == null) return;
      setState(() {
        if (_selected.contains(id)) {
          _selected.remove(id);
        } else {
          _selected.add(id);
        }
      });
      return;
    }
    Navigator.of(context).pop(FxSelectionResult<T>.selected(option));
  }

  void _confirm() {
    final picked = widget.options
        .where((option) => _selected.contains(widget.idOf(option)))
        .toList();
    Navigator.of(context).pop<List<T>>(picked);
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final s = S.of(context);
    final visible = _visible;
    final rows = <Widget>[
      if (widget.allowClear)
        _FxOptionRow(
          label: widget.clearLabel ?? s.billEditorNoSelection,
          selected: _selected.isEmpty,
          multiSelect: false,
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).pop(FxSelectionResult<T>.cleared());
          },
        ),
      for (final option in visible)
        _FxOptionRow(
          label: widget.labelOf(option),
          subtitle: widget.subtitleOf?.call(option),
          selected: _selected.contains(widget.idOf(option)),
          multiSelect: widget.multiSelect,
          onTap: () => _select(option),
        ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_showSearch)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg,
              FxSpacing.xs,
              FxSpacing.lg,
              FxSpacing.sm,
            ),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              style: FxTypography.body.copyWith(color: palette.textPrimary),
              decoration: InputDecoration(
                hintText: widget.searchHint ?? s.fxTreePickerSearch,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: palette.textTertiary,
                ),
                filled: true,
                fillColor: palette.surfaceMuted,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: FxSpacing.md,
                  vertical: FxSpacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: FxRadius.tileBorder,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.all(FxSpacing.xxl),
            child: Text(
              widget.emptyText ?? s.billEditorNoOptions,
              textAlign: TextAlign.center,
              style: FxTypography.caption.copyWith(color: palette.textTertiary),
            ),
          )
        else
          FxListSection(dividerIndent: 16, children: rows),
        if (widget.multiSelect)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg,
              FxSpacing.md,
              FxSpacing.lg,
              FxSpacing.lg,
            ),
            child: FxButton(label: s.ok, expand: true, onPressed: _confirm),
          ),
      ],
    );
  }
}

class _FxOptionRow extends StatelessWidget {
  const _FxOptionRow({
    required this.label,
    required this.selected,
    required this.multiSelect,
    required this.onTap,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final bool multiSelect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: subtitle == null ? label : '$label, $subtitle',
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FxSpacing.lg,
              vertical: FxSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FxTypography.body.copyWith(
                          color: palette.textPrimary,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
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
                if (selected)
                  Icon(
                    multiSelect ? Icons.check_box_rounded : Icons.check_rounded,
                    size: 20,
                    color: palette.primary,
                  )
                else if (multiSelect)
                  Icon(
                    Icons.check_box_outline_blank_rounded,
                    size: 20,
                    color: palette.textTertiary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
