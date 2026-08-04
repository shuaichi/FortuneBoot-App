import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';

/// 一个 Bento 卡片单元：指定跨列数与跨行数（行高为 [FxBentoGrid.rowHeight] 的倍数）。
class FxBentoTile {
  final int colSpan;
  final int rowSpan;
  final Widget child;

  const FxBentoTile({
    this.colSpan = 1,
    this.rowSpan = 1,
    required this.child,
  });
}

/// Sliver 自实现 Bento 网格（零新依赖）。2 列为主，大屏自动展宽。
/// 采用固定行高 * rowSpan 的规整拼贴（非瀑布流），保证跨行卡片高度可预测。
class FxBentoGrid extends StatelessWidget {
  final List<FxBentoTile> tiles;
  final double spacing;
  final double rowHeight;
  final EdgeInsets padding;

  const FxBentoGrid({
    super.key,
    required this.tiles,
    this.spacing = FxSpacing.md,
    this.rowHeight = 92,
    this.padding = const EdgeInsets.all(FxSpacing.lg),
  });

  int _columnsFor(double width) {
    if (width >= 1200) return 4;
    if (width >= 800) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsFor(constraints.maxWidth);
        final innerWidth = constraints.maxWidth - padding.horizontal;
        final cellWidth = (innerWidth - spacing * (columns - 1)) / columns;

        // 贪心排布：逐 tile 找当前行剩余列是否放得下，放不下则换行。
        final List<_PositionedTile> positioned = [];
        int cursorCol = 0;
        double cursorTop = 0;
        double rowMaxHeight = 0;

        for (final tile in tiles) {
          final span = tile.colSpan.clamp(1, columns);
          if (cursorCol + span > columns) {
            // 换行
            cursorTop += rowMaxHeight + spacing;
            cursorCol = 0;
            rowMaxHeight = 0;
          }
          final tileWidth = cellWidth * span + spacing * (span - 1);
          final tileHeight = rowHeight * tile.rowSpan + spacing * (tile.rowSpan - 1);
          final left = cursorCol * (cellWidth + spacing);
          positioned.add(_PositionedTile(
            left: left,
            top: cursorTop,
            width: tileWidth,
            height: tileHeight,
            child: tile.child,
          ));
          cursorCol += span;
          if (tileHeight > rowMaxHeight) rowMaxHeight = tileHeight;
          if (cursorCol >= columns) {
            cursorTop += rowMaxHeight + spacing;
            cursorCol = 0;
            rowMaxHeight = 0;
          }
        }

        final totalHeight = cursorTop + rowMaxHeight;

        return Padding(
          padding: padding,
          child: SizedBox(
            height: totalHeight,
            width: innerWidth,
            child: Stack(
              children: positioned
                  .map((p) => Positioned(
                        left: p.left,
                        top: p.top,
                        width: p.width,
                        height: p.height,
                        child: p.child,
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

class _PositionedTile {
  final double left;
  final double top;
  final double width;
  final double height;
  final Widget child;
  const _PositionedTile({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.child,
  });
}
