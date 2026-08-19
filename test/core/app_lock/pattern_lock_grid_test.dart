import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/app_lock/pattern_path_resolver.dart';
import 'package:fortuneboot/core/app_lock/presentation/pattern_lock_grid.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';

void main() {
  group('PatternLockGrid', () {
    testWidgets(
      'reports the direct and canonical paths after dragging 0 through 2 and 5',
      (tester) async {
        PatternPathResolution? completedPath;

        await _pumpGrid(tester, onCompleted: (path) => completedPath = path);

        await _drawPath(tester, const [0, 2, 5]);

        expect(completedPath?.directPath, [0, 2, 5]);
        expect(completedPath?.traditionalCanonicalPath, [0, 1, 2, 5]);
      },
    );

    testWidgets(
      'does not report a path with fewer than four canonical points',
      (tester) async {
        var completionCount = 0;

        await _pumpGrid(tester, onCompleted: (_) => completionCount += 1);

        await _drawPath(tester, const [0, 3, 4]);

        expect(completionCount, 0);
      },
    );

    testWidgets('clears the previous path when resetToken changes', (
      tester,
    ) async {
      final completedPaths = <PatternPathResolution>[];
      late StateSetter setHostState;
      var resetToken = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: FxTheme.light,
          home: StatefulBuilder(
            builder: (context, setState) {
              setHostState = setState;
              return Scaffold(
                body: SizedBox(
                  width: 300,
                  height: 300,
                  child: PatternLockGrid(
                    onCompleted: completedPaths.add,
                    semanticLabel: 'Pattern lock',
                    nodeSemanticLabel: _nodeSemanticLabel,
                    progressSemanticLabel: _progressSemanticLabel,
                    minimumPointsMessage: 'Connect at least four points',
                    resetToken: resetToken,
                  ),
                ),
              );
            },
          ),
        ),
      );

      await _drawPath(tester, const [0, 2, 5]);
      setHostState(() => resetToken = 1);
      await tester.pump();
      await _drawPath(tester, const [6, 8, 5]);

      expect(completedPaths, hasLength(2));
      expect(completedPaths.last.directPath, [6, 8, 5]);
      expect(completedPaths.last.traditionalCanonicalPath, [6, 7, 8, 5]);
    });

    testWidgets('does not report a path while disabled', (tester) async {
      var completionCount = 0;

      await _pumpGrid(
        tester,
        enabled: false,
        onCompleted: (_) => completionCount += 1,
      );

      await _drawPath(tester, const [0, 2, 5]);

      expect(completionCount, 0);
    });

    testWidgets('exposes semantic labels for all nine nodes', (tester) async {
      await _pumpGrid(tester, onCompleted: (_) {});

      for (var row = 0; row < 3; row++) {
        for (var column = 0; column < 3; column++) {
          expect(
            find.bySemanticsLabel(_nodeSemanticLabel(row, column, false)),
            findsOneWidget,
          );
        }
      }
    });
  });
}

Future<void> _pumpGrid(
  WidgetTester tester, {
  required ValueChanged<PatternPathResolution> onCompleted,
  bool enabled = true,
}) => tester.pumpWidget(
  MaterialApp(
    theme: FxTheme.light,
    home: Scaffold(
      body: SizedBox(
        width: 300,
        height: 300,
        child: PatternLockGrid(
          onCompleted: onCompleted,
          semanticLabel: 'Pattern lock',
          nodeSemanticLabel: _nodeSemanticLabel,
          progressSemanticLabel: _progressSemanticLabel,
          minimumPointsMessage: 'Connect at least four points',
          enabled: enabled,
        ),
      ),
    ),
  ),
);

Future<void> _drawPath(WidgetTester tester, List<int> nodes) async {
  final grid = find.byType(PatternLockGrid);
  final topLeft = tester.getTopLeft(grid);
  const gridSize = 300.0;
  final gesture = await tester.startGesture(
    _nodePosition(topLeft, nodes.first),
  );
  for (final node in nodes.skip(1)) {
    await gesture.moveTo(_nodePosition(topLeft, node));
  }
  await gesture.up();
  await tester.pump();
}

Offset _nodePosition(Offset topLeft, int node) {
  const cellSize = 100.0;
  return topLeft +
      Offset(cellSize * (node % 3 + .5), cellSize * (node ~/ 3 + .5));
}

String _nodeSemanticLabel(int row, int column, bool selected) =>
    'Node ${row + 1}, ${column + 1}${selected ? ', selected' : ''}';

String _progressSemanticLabel(int count) => '$count selected';
