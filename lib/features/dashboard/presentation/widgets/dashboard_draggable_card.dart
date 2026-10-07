import 'package:flutter/material.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_card_catalog.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 编辑态：长按拖拽；悬停另一张卡片时由父级重排网格，把对方挤开。
class DashboardDraggableCard extends StatefulWidget {
  const DashboardDraggableCard({
    super.key,
    required this.id,
    required this.child,
    required this.onRemove,
    required this.onInsertNear,
    this.onDragStarted,
    this.onDragEnded,
  });

  final DashboardCardId id;
  final Widget child;
  final VoidCallback onRemove;
  final void Function(DashboardCardId from, DashboardCardId to, {required bool after})
      onInsertNear;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;

  @override
  State<DashboardDraggableCard> createState() => _DashboardDraggableCardState();
}

class _DashboardDraggableCardState extends State<DashboardDraggableCard> {
  bool _dragging = false;

  void _setDragging(bool value) {
    if (_dragging == value) return;
    setState(() => _dragging = value);
    if (value) {
      widget.onDragStarted?.call();
    } else {
      widget.onDragEnded?.call();
    }
  }

  void _maybeInsert(DragTargetDetails<DashboardCardId> details) {
    if (details.data == widget.id) return;
    final box = context.findRenderObject();
    var after = false;
    if (box is RenderBox && box.hasSize) {
      // 用手指位置相对卡片中线判断插到上方还是下方，目标卡片会被挤开。
      final local = box.globalToLocal(details.offset);
      after = local.dy > box.size.height * 0.45;
    }
    widget.onInsertNear(details.data, widget.id, after: after);
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        return DragTarget<DashboardCardId>(
          onWillAcceptWithDetails: (details) => details.data != widget.id,
          onMove: _maybeInsert,
          builder: (context, candidateData, rejectedData) {
            final dropTarget = candidateData.isNotEmpty;
            return LongPressDraggable<DashboardCardId>(
              data: widget.id,
              delay: const Duration(milliseconds: 280),
              hapticFeedbackOnStart: true,
              rootOverlay: true,
              onDragStarted: () => _setDragging(true),
              onDragEnd: (_) => _setDragging(false),
              feedback: Material(
                elevation: 12,
                color: Colors.transparent,
                borderRadius: FxRadius.tileBorder,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: FxRadius.tileBorder,
                      border: Border.all(color: palette.primary, width: 2),
                    ),
                    child: Opacity(opacity: 0.95, child: widget.child),
                  ),
                ),
              ),
              childWhenDragging: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: FxRadius.tileBorder,
                  border: Border.all(
                    color: palette.primary.withValues(alpha: 0.35),
                    width: 2,
                  ),
                  color: palette.primary.withValues(alpha: 0.06),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: IgnorePointer(child: widget.child)),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: FxRadius.tileBorder,
                        border: Border.all(
                          color: dropTarget || _dragging
                              ? palette.primary
                              : palette.primary.withValues(alpha: 0.45),
                          width: dropTarget || _dragging ? 2 : 1,
                        ),
                        color: dropTarget
                            ? palette.primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Material(
                      color: palette.surface,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: widget.onRemove,
                        child: Padding(
                          padding: const EdgeInsets.all(FxSpacing.xs),
                          child: Icon(
                            Icons.remove_circle_rounded,
                            size: 22,
                            color: palette.danger,
                            semanticLabel: S.of(context).dashboardRemoveCard,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
