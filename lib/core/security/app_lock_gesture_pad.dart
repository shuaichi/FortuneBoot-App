import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

/// 3×3 自定义手势。松手后回传至少 4 个点的序号（0–8，从左到右、从上到下）。
class AppLockGesturePad extends StatefulWidget {
  const AppLockGesturePad({
    super.key,
    required this.onCompleted,
    this.enabled = true,
  });

  final ValueChanged<List<int>> onCompleted;
  final bool enabled;

  @override
  State<AppLockGesturePad> createState() => _AppLockGesturePadState();
}

class _AppLockGesturePadState extends State<AppLockGesturePad> {
  final _cells = <int>[];
  Offset? _pointer;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          return GestureDetector(
            onPanStart: widget.enabled
                ? (details) => _hit(details.localPosition, size, reset: true)
                : null,
            onPanUpdate: widget.enabled
                ? (details) => _hit(details.localPosition, size)
                : null,
            onPanEnd: widget.enabled ? (_) => _finish() : null,
            child: CustomPaint(
              painter: _GesturePainter(
                cells: _cells,
                pointer: _pointer,
                size: size,
                line: palette.primary,
                dot: palette.border,
                active: palette.primary,
              ),
            ),
          );
        },
      ),
    );
  }

  void _hit(Offset local, Size size, {bool reset = false}) {
    if (reset) {
      _cells.clear();
      _pointer = local;
    } else {
      _pointer = local;
    }
    final cell = _cellAt(local, size);
    if (cell != null && (_cells.isEmpty || _cells.last != cell)) {
      _cells.add(cell);
    }
    setState(() {});
  }

  void _finish() {
    final path = List<int>.of(_cells);
    setState(() {
      _cells.clear();
      _pointer = null;
    });
    if (path.length >= 4) widget.onCompleted(path);
  }

  int? _cellAt(Offset local, Size size) {
    const gap = 3;
    final cellW = size.width / gap;
    final cellH = size.height / gap;
    final col = (local.dx / cellW).floor().clamp(0, 2);
    final row = (local.dy / cellH).floor().clamp(0, 2);
    final cx = (col + 0.5) * cellW;
    final cy = (row + 0.5) * cellH;
    if ((local - Offset(cx, cy)).distance > cellW * 0.28) return null;
    return row * 3 + col;
  }
}

class _GesturePainter extends CustomPainter {
  _GesturePainter({
    required this.cells,
    required this.pointer,
    required this.size,
    required this.line,
    required this.dot,
    required this.active,
  });

  final List<int> cells;
  final Offset? pointer;
  final Size size;
  final Color line;
  final Color dot;
  final Color active;

  Offset _center(int cell) {
    final col = cell % 3;
    final row = cell ~/ 3;
    return Offset(
      (col + 0.5) * size.width / 3,
      (row + 0.5) * size.height / 3,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = line
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 9; i++) {
      final selected = cells.contains(i);
      canvas.drawCircle(
        _center(i),
        selected ? 16 : 12,
        Paint()..color = selected ? active : dot,
      );
    }
    if (cells.length >= 2) {
      final path = Path()..moveTo(_center(cells.first).dx, _center(cells.first).dy);
      for (final cell in cells.skip(1)) {
        path.lineTo(_center(cell).dx, _center(cell).dy);
      }
      canvas.drawPath(path, linePaint);
    }
    if (cells.isNotEmpty && pointer != null) {
      canvas.drawLine(_center(cells.last), pointer!, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GesturePainter oldDelegate) => true;
}
