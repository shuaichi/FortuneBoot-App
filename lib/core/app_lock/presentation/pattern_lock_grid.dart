import 'package:flutter/material.dart';
import 'package:fortuneboot/core/app_lock/pattern_path_resolver.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

class PatternLockGrid extends StatefulWidget {
  const PatternLockGrid({
    required this.onCompleted,
    required this.semanticLabel,
    required this.nodeSemanticLabel,
    required this.progressSemanticLabel,
    required this.minimumPointsMessage,
    super.key,
    this.enabled = true,
    this.error = false,
    this.resetToken = 0,
  });

  final ValueChanged<PatternPathResolution> onCompleted;
  final String semanticLabel;
  final String Function(int row, int column, bool selected) nodeSemanticLabel;
  final String Function(int count) progressSemanticLabel;
  final String minimumPointsMessage;
  final bool enabled;
  final bool error;
  final int resetToken;

  @override
  State<PatternLockGrid> createState() => _PatternLockGridState();
}

class _PatternLockGridState extends State<PatternLockGrid> {
  List<int> _directPath = const [];
  List<int> _canonicalPath = const [];
  Offset? _dragPosition;
  int _resetToken = 0;

  @override
  void didUpdateWidget(covariant PatternLockGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resetToken != _resetToken || !widget.enabled) {
      _resetToken = widget.resetToken;
      _clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final color = widget.error ? palette.danger : palette.primary;
    return Semantics(
      label: widget.semanticLabel,
      value: widget.progressSemanticLabel(_canonicalPath.length),
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size.square(constraints.maxWidth);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: widget.enabled
                  ? (details) => _addNodeAt(details.localPosition, size)
                  : null,
              onPanUpdate: widget.enabled
                  ? (details) {
                      setState(() => _dragPosition = details.localPosition);
                      _addNodeAt(details.localPosition, size);
                    }
                  : null,
              onPanEnd: widget.enabled ? (_) => _complete() : null,
              onPanCancel: widget.enabled ? _complete : null,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _PatternLockPainter(
                      path: _canonicalPath,
                      dragPosition: _dragPosition,
                      color: color,
                      disabledColor: palette.textSecondary,
                      enabled: widget.enabled,
                    ),
                  ),
                  for (var node = 0; node < 9; node++)
                    _NodeSemantics(
                      node: node,
                      selected: _canonicalPath.contains(node),
                      enabled: widget.enabled,
                      label: widget.nodeSemanticLabel(
                        node ~/ 3,
                        node % 3,
                        _canonicalPath.contains(node),
                      ),
                      onTap: () => _addNode(node),
                    ),
                  if (_canonicalPath.isNotEmpty && _canonicalPath.length < 4)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          widget.minimumPointsMessage,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _addNodeAt(Offset position, Size size) {
    final node = _nodeAt(position, size);
    if (node != null) _addNode(node);
  }

  void _addNode(int node) {
    if (!widget.enabled || _canonicalPath.contains(node)) return;
    final resolution = PatternPathResolver.resolve(
      selectedPath: _directPath,
      endpoint: node,
    );
    setState(() {
      _directPath = resolution.directPath;
      _canonicalPath = resolution.traditionalCanonicalPath;
    });
  }

  void _complete() {
    if (_canonicalPath.length >= 4) {
      widget.onCompleted(
        PatternPathResolution(
          directPath: _directPath,
          traditionalCanonicalPath: _canonicalPath,
        ),
      );
    }
    setState(() => _dragPosition = null);
  }

  void _clear() {
    if (_directPath.isEmpty &&
        _canonicalPath.isEmpty &&
        _dragPosition == null) {
      return;
    }
    setState(() {
      _directPath = const [];
      _canonicalPath = const [];
      _dragPosition = null;
    });
  }

  int? _nodeAt(Offset position, Size size) {
    final cellSize = size.width / 3;
    const hitRadiusFactor = .32;
    for (var node = 0; node < 9; node++) {
      final center = _nodeCenter(node, size);
      if ((position - center).distance <= cellSize * hitRadiusFactor) {
        return node;
      }
    }
    return null;
  }
}

class _NodeSemantics extends StatelessWidget {
  const _NodeSemantics({
    required this.node,
    required this.selected,
    required this.enabled,
    required this.label,
    required this.onTap,
  });

  final int node;
  final bool selected;
  final bool enabled;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: _nodeAlignment(node),
        child: Semantics(
          button: true,
          enabled: enabled,
          selected: selected,
          label: label,
          onTap: enabled ? onTap : null,
          child: const SizedBox.square(dimension: 48),
        ),
      ),
    );
  }
}

class _PatternLockPainter extends CustomPainter {
  const _PatternLockPainter({
    required this.path,
    required this.dragPosition,
    required this.color,
    required this.disabledColor,
    required this.enabled,
  });

  final List<int> path;
  final Offset? dragPosition;
  final Color color;
  final Color disabledColor;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final pathColor = enabled ? color : disabledColor;
    final linePaint = Paint()
      ..color = pathColor
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final nodePaint = Paint()
      ..color = pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final selectedPaint = Paint()
      ..color = pathColor
      ..style = PaintingStyle.fill;
    final selectedPath = Path();
    for (var index = 0; index < path.length; index++) {
      final center = _nodeCenter(path[index], size);
      if (index == 0) {
        selectedPath.moveTo(center.dx, center.dy);
      } else {
        selectedPath.lineTo(center.dx, center.dy);
      }
    }
    if (path.length > 1) canvas.drawPath(selectedPath, linePaint);
    if (path.isNotEmpty && dragPosition != null) {
      canvas.drawLine(_nodeCenter(path.last, size), dragPosition!, linePaint);
    }
    final radius = size.width / 18;
    for (var node = 0; node < 9; node++) {
      final center = _nodeCenter(node, size);
      final selected = path.contains(node);
      canvas.drawCircle(center, radius, nodePaint);
      if (selected) canvas.drawCircle(center, radius * .45, selectedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PatternLockPainter oldDelegate) =>
      oldDelegate.path != path ||
      oldDelegate.dragPosition != dragPosition ||
      oldDelegate.color != color ||
      oldDelegate.disabledColor != disabledColor ||
      oldDelegate.enabled != enabled;
}

Offset _nodeCenter(int node, Size size) {
  final cellSize = size.width / 3;
  return Offset(cellSize * (node % 3 + .5), cellSize * (node ~/ 3 + .5));
}

Alignment _nodeAlignment(int node) =>
    Alignment((node % 3 - 1).toDouble(), (node ~/ 3 - 1).toDouble());
