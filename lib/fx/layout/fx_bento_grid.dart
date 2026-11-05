import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';

/// 一个 Bento 卡片单元：指定跨列数与跨行数（行高为 [FxBentoGrid.rowHeight] 的倍数）。
class FxBentoTile {
  static const int fullSpan = 999;

  final Object? id;
  final int colSpan;
  final int rowSpan;
  final Widget child;

  const FxBentoTile({
    this.id,
    this.colSpan = 1,
    this.rowSpan = 1,
    required this.child,
  });

  const FxBentoTile.fullWidth({this.id, this.rowSpan = 1, required this.child})
    : colSpan = fullSpan;
}

/// Sliver 自实现 Bento 网格（零新依赖）。2 列为主，大屏自动展宽。
/// 采用固定行高 * rowSpan 的规整拼贴（非瀑布流），保证跨行卡片高度可预测。
class FxBentoGrid extends StatelessWidget {
  final List<FxBentoTile> tiles;
  final double spacing;
  final double rowHeight;
  final EdgeInsets padding;
  final Duration animationDuration;

  /// 为 false 时禁止回填更早的空洞（编辑拖拽时保证顺序变化可见）。
  final bool allowBackfill;

  const FxBentoGrid({
    super.key,
    required this.tiles,
    this.spacing = FxSpacing.md,
    this.rowHeight = 92,
    this.padding = const EdgeInsets.all(FxSpacing.lg),
    this.animationDuration = const Duration(milliseconds: 240),
    this.allowBackfill = true,
  });

  int _columnsFor(double width) {
    if (width >= 1200) return 4;
    if (width >= 800) return 3;
    return 2;
  }

  int _effectiveColSpan(FxBentoTile tile, int columns) {
    if (tile.colSpan >= FxBentoTile.fullSpan) return columns;
    if (tile.colSpan < 1) return 1;
    if (tile.colSpan > columns) return columns;
    return tile.colSpan;
  }

  _GridSlot _findSlot(
    List<List<bool>> occupied,
    int columns,
    int colSpan,
    int rowSpan, {
    int minRow = 0,
  }) {
    var row = minRow < 0 ? 0 : minRow;
    while (true) {
      _ensureRows(occupied, columns, row + rowSpan);
      for (var col = 0; col <= columns - colSpan; col++) {
        if (_canPlace(occupied, row, col, colSpan, rowSpan)) {
          return _GridSlot(row: row, col: col);
        }
      }
      row++;
    }
  }

  bool _canPlace(
    List<List<bool>> occupied,
    int row,
    int col,
    int colSpan,
    int rowSpan,
  ) {
    for (var r = row; r < row + rowSpan; r++) {
      for (var c = col; c < col + colSpan; c++) {
        if (occupied[r][c]) return false;
      }
    }
    return true;
  }

  void _markOccupied(
    List<List<bool>> occupied,
    int columns,
    int row,
    int col,
    int colSpan,
    int rowSpan,
  ) {
    _ensureRows(occupied, columns, row + rowSpan);
    for (var r = row; r < row + rowSpan; r++) {
      for (var c = col; c < col + colSpan; c++) {
        occupied[r][c] = true;
      }
    }
  }

  void _ensureRows(List<List<bool>> occupied, int columns, int rowCount) {
    while (occupied.length < rowCount) {
      occupied.add(List<bool>.filled(columns, false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedDuration = FxMotion.resolve(context, animationDuration);
        final useSummaryList =
            constraints.maxWidth < 360 ||
            (constraints.maxWidth < 600 &&
                MediaQuery.textScalerOf(context).scale(1) > 1.3);
        if (useSummaryList) {
          return Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < tiles.length; index++) ...[
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: rowHeight * tiles[index].rowSpan,
                    ),
                    child: tiles[index].child,
                  ),
                  if (index < tiles.length - 1) SizedBox(height: spacing),
                ],
              ],
            ),
          );
        }
        final columns = _columnsFor(constraints.maxWidth);
        final innerWidth = constraints.maxWidth - padding.horizontal;
        final cellWidth = (innerWidth - spacing * (columns - 1)) / columns;

        final positioned = <_PositionedTile>[];
        final occupied = <List<bool>>[];
        var occupiedRows = 0;
        // 禁止回填时：后续卡片不能排到已放置卡片更靠上的行，避免大卡上移被小卡填洞抵消。
        var minRow = 0;

        for (final tile in tiles) {
          final span = _effectiveColSpan(tile, columns);
          final rowSpan = tile.rowSpan < 1 ? 1 : tile.rowSpan;
          final position = _findSlot(
            occupied,
            columns,
            span,
            rowSpan,
            minRow: allowBackfill ? 0 : minRow,
          );
          _markOccupied(
            occupied,
            columns,
            position.row,
            position.col,
            span,
            rowSpan,
          );
          if (!allowBackfill) {
            minRow = position.row;
          }
          occupiedRows = occupiedRows > position.row + rowSpan
              ? occupiedRows
              : position.row + rowSpan;

          final tileWidth = cellWidth * span + spacing * (span - 1);
          final tileHeight = rowHeight * rowSpan + spacing * (rowSpan - 1);
          final left = position.col * (cellWidth + spacing);
          final top = position.row * (rowHeight + spacing);
          positioned.add(
            _PositionedTile(
              id: tile.id ?? positioned.length,
              left: left,
              top: top,
              width: tileWidth,
              height: tileHeight,
              child: tile.child,
            ),
          );
        }

        final totalHeight = occupiedRows == 0
            ? 0.0
            : occupiedRows * rowHeight + (occupiedRows - 1) * spacing;

        return Padding(
          padding: padding,
          child: AnimatedSize(
            duration: resolvedDuration,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: totalHeight,
              width: innerWidth,
              child: Stack(
                clipBehavior: Clip.none,
                children: positioned
                    .map(
                      (p) => AnimatedPositioned(
                        key: ValueKey(p.id),
                        duration: resolvedDuration,
                        curve: Curves.easeOutCubic,
                        left: p.left,
                        top: p.top,
                        width: p.width,
                        height: p.height,
                        child: p.child,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GridSlot {
  final int row;
  final int col;

  const _GridSlot({required this.row, required this.col});
}

class _PositionedTile {
  final Object id;
  final double left;
  final double top;
  final double width;
  final double height;
  final Widget child;
  const _PositionedTile({
    required this.id,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.child,
  });
}
