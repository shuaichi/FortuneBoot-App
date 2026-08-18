import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/tree/fx_tree_utils.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 树形选择器：展开/收起、缩进、路径、搜索、清空。支持单选与多选。
///
/// 泛型 [T] 为节点类型，通过访问器适配任意树模型。
/// [idOf] 返回稳定 id（可空表示不可选，如虚拟父节点）；[leafOnly] 为 true 时
/// 只有叶子节点可选（分支节点仅用于展开）。
class FxTreePicker<T> extends StatefulWidget {
  final List<T> roots;
  final List<T> Function(T node) childrenOf;
  final String Function(T node) labelOf;
  final Object? Function(T node) idOf;
  final Set<Object> initialSelected;
  final bool multiSelect;
  final bool leafOnly;
  final bool initiallyCollapsed;
  final String title;

  const FxTreePicker({
    super.key,
    required this.roots,
    required this.childrenOf,
    required this.labelOf,
    required this.idOf,
    this.initialSelected = const {},
    this.multiSelect = false,
    this.leafOnly = false,
    this.initiallyCollapsed = false,
    this.title = '选择',
  });

  /// 弹出选择器，返回选中的节点列表（取消返回 null）。
  static Future<List<T>?> show<T>(
    BuildContext context, {
    required List<T> roots,
    required List<T> Function(T node) childrenOf,
    required String Function(T node) labelOf,
    required Object? Function(T node) idOf,
    Set<Object> initialSelected = const {},
    bool multiSelect = false,
    bool leafOnly = false,
    bool initiallyCollapsed = false,
    String title = '选择',
  }) {
    final palette = FxPalette.of(context);
    return showModalBottomSheet<List<T>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: FxRadius.sheetRadius),
      ),
      builder: (ctx) => FractionallySizedBox(
        heightFactor: FxSheet.pickerHeightFactor,
        child: FxTreePicker<T>(
          roots: roots,
          childrenOf: childrenOf,
          labelOf: labelOf,
          idOf: idOf,
          initialSelected: initialSelected,
          multiSelect: multiSelect,
          leafOnly: leafOnly,
          initiallyCollapsed: initiallyCollapsed,
          title: title,
        ),
      ),
    );
  }

  @override
  State<FxTreePicker<T>> createState() => _FxTreePickerState<T>();
}

class _FxTreePickerState<T> extends State<FxTreePicker<T>> {
  late final List<FxFlatNode<T>> _all = flattenTreeWithDepth(
    widget.roots,
    childrenOf: widget.childrenOf,
    labelOf: widget.labelOf,
  );

  late Set<Object> _selected = {...widget.initialSelected};
  late final Set<FxFlatNode<T>> _collapsed;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _collapsed = {
      if (widget.initiallyCollapsed)
        for (final f in _all)
          if (f.hasChildren) f,
    };
  }

  bool _selectable(FxFlatNode<T> f) {
    if (widget.idOf(f.node) == null) return false;
    if (widget.leafOnly && f.hasChildren) return false;
    return true;
  }

  void _toggle(FxFlatNode<T> f) {
    final id = widget.idOf(f.node);
    if (id == null) return;
    HapticFeedback.selectionClick();
    setState(() {
      if (widget.multiSelect) {
        if (_selected.contains(id)) {
          _selected.remove(id);
        } else {
          _selected.add(id);
        }
      } else {
        _selected = {id};
      }
    });
    if (!widget.multiSelect) {
      _confirm();
    }
  }

  void _confirm() {
    final picked = _all
        .where((f) => _selected.contains(widget.idOf(f.node)))
        .map((f) => f.node)
        .toList();
    Navigator.of(context).pop(picked);
  }

  /// 搜索时展开全部；否则按折叠集合隐藏被折叠分支的后代。
  List<FxFlatNode<T>> get _visible {
    if (_query.trim().isNotEmpty) {
      return filterFlat(_all, _query);
    }
    final result = <FxFlatNode<T>>[];
    int? hideDepth;
    for (final f in _all) {
      if (hideDepth != null) {
        if (f.depth > hideDepth) continue;
        hideDepth = null;
      }
      result.add(f);
      if (f.hasChildren && _collapsed.contains(f)) {
        hideDepth = f.depth;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final visible = _visible;
    return SafeArea(
      top: false,
      child: Column(
        children: [
          const SizedBox(height: FxSpacing.sm),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: palette.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          Padding(
            padding: FxSpacing.pageH,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: FxTypography.title.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _selected.clear()),
                      child: Text(
                        '清空',
                        style: FxTypography.body.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                    if (widget.multiSelect) ...[
                      const SizedBox(width: FxSpacing.lg),
                      GestureDetector(
                        onTap: _confirm,
                        child: Text(
                          '完成',
                          style: FxTypography.bodyStrong.copyWith(
                            color: palette.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: FxSpacing.sm),
          Padding(
            padding: FxSpacing.pageH,
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: FxTypography.body.copyWith(color: palette.textPrimary),
              decoration: InputDecoration(
                hintText: '搜索',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: palette.textTertiary,
                ),
                filled: true,
                fillColor: palette.surfaceMuted,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: FxSpacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: FxRadius.tileBorder,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: FxSpacing.sm),
          Expanded(
            child: visible.isEmpty
                ? Center(
                    child: Text(
                      '无匹配项',
                      style: FxTypography.caption.copyWith(
                        color: palette.textTertiary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: FxSpacing.lg),
                    itemCount: visible.length,
                    itemBuilder: (context, i) => _row(palette, visible[i]),
                  ),
          ),
          if (widget.multiSelect)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FxSpacing.lg,
                FxSpacing.sm,
                FxSpacing.lg,
                FxSpacing.lg,
              ),
              child: FxButton(
                label: '确定（${_selected.length}）',
                expand: true,
                onPressed: _confirm,
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(FxPalette palette, FxFlatNode<T> f) {
    final id = widget.idOf(f.node);
    final selectable = _selectable(f);
    final selected = id != null && _selected.contains(id);
    final searching = _query.trim().isNotEmpty;
    final collapsed = _collapsed.contains(f);
    final indent = searching ? 0.0 : f.depth * 16.0;

    return InkWell(
      onTap: selectable ? () => _toggle(f) : null,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          FxSpacing.lg + indent,
          FxSpacing.md,
          FxSpacing.lg,
          FxSpacing.md,
        ),
        child: Row(
          children: [
            if (f.hasChildren && !searching)
              GestureDetector(
                onTap: () => setState(() {
                  if (collapsed) {
                    _collapsed.remove(f);
                  } else {
                    _collapsed.add(f);
                  }
                }),
                child: Icon(
                  collapsed
                      ? Icons.chevron_right_rounded
                      : Icons.expand_more_rounded,
                  size: 20,
                  color: palette.textTertiary,
                ),
              )
            else
              const SizedBox(width: 20),
            const SizedBox(width: FxSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.labelOf(f.node),
                    style: FxTypography.body.copyWith(
                      color: selectable
                          ? (selected ? palette.primary : palette.textPrimary)
                          : palette.textTertiary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (searching && f.path.length > 1) ...[
                    const SizedBox(height: 2),
                    Text(
                      f.pathLabel,
                      style: FxTypography.caption.copyWith(
                        color: palette.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (selected)
              Icon(
                widget.multiSelect
                    ? Icons.check_box_rounded
                    : Icons.check_rounded,
                size: 20,
                color: palette.primary,
              )
            else if (selectable && widget.multiSelect)
              Icon(
                Icons.check_box_outline_blank_rounded,
                size: 20,
                color: palette.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}
