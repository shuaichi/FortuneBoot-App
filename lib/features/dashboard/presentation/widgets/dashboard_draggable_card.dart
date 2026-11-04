import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fortuneboot/features/dashboard/data/dashboard_card_catalog.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
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
  final void Function(
    DashboardCardId from,
    DashboardCardId to, {
    required bool after,
  })
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
            final feedback = Material(
              elevation: 4,
              color: Colors.transparent,
              borderRadius: FxRadius.cardBorder,
              child: SizedBox(
                width: width,
                height: height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: FxRadius.cardBorder,
                    border: Border.all(color: palette.border),
                  ),
                  child: Opacity(opacity: 0.96, child: widget.child),
                ),
              ),
            );
            final placeholder = DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: FxRadius.cardBorder,
                border: Border.all(color: palette.border),
                color: palette.surfaceMuted,
              ),
            );
            final editorContent = Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: IgnorePointer(child: widget.child)),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: FxRadius.cardBorder,
                      border: Border.all(
                        color: dropTarget || _dragging
                            ? palette.primary
                            : palette.border,
                        width: dropTarget || _dragging ? 2 : 1,
                      ),
                      color: dropTarget
                          ? palette.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: FxIconButton(
                    icon: Icons.remove_circle_outline_rounded,
                    tooltip: S.of(context).dashboardRemoveCard,
                    color: palette.danger,
                    onPressed: widget.onRemove,
                  ),
                ),
              ],
            );
            final immediateDrag =
                kIsWeb ||
                defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.linux;
            if (immediateDrag) {
              return MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: Draggable<DashboardCardId>(
                  data: widget.id,
                  rootOverlay: true,
                  onDragStarted: () => _setDragging(true),
                  onDragEnd: (_) => _setDragging(false),
                  feedback: feedback,
                  childWhenDragging: placeholder,
                  child: editorContent,
                ),
              );
            }
            return LongPressDraggable<DashboardCardId>(
              data: widget.id,
              delay: const Duration(milliseconds: 280),
              rootOverlay: true,
              onDragStarted: () => _setDragging(true),
              onDragEnd: (_) => _setDragging(false),
              feedback: feedback,
              childWhenDragging: placeholder,
              child: editorContent,
            );
          },
        );
      },
    );
  }
}
