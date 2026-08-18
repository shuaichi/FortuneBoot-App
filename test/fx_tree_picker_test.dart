import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tree/fx_tree_picker.dart';

@immutable
class _Node {
  const _Node(this.id, this.label, [this.children = const []]);

  final String id;
  final String label;
  final List<_Node> children;
}

const _tree = [
  _Node('expenses', '支出', [_Node('food', '餐饮'), _Node('transport', '交通')]),
  _Node('income', '收入', [_Node('salary', '工资')]),
];

Widget _picker({bool initiallyCollapsed = false}) {
  return MaterialApp(
    theme: FxTheme.light,
    home: Scaffold(
      body: FxTreePicker<_Node>(
        roots: _tree,
        childrenOf: (node) => node.children,
        labelOf: (node) => node.label,
        idOf: (node) => node.id,
        initiallyCollapsed: initiallyCollapsed,
      ),
    ),
  );
}

void main() {
  group('FxTreePicker initiallyCollapsed', () {
    testWidgets('keeps all branches expanded by default', (tester) async {
      await tester.pumpWidget(_picker());

      expect(find.text('餐饮'), findsOneWidget);
      expect(find.text('交通'), findsOneWidget);
      expect(find.text('工资'), findsOneWidget);
    });

    testWidgets('collapses all branch descendants initially', (tester) async {
      await tester.pumpWidget(_picker(initiallyCollapsed: true));

      expect(find.text('支出'), findsOneWidget);
      expect(find.text('收入'), findsOneWidget);
      expect(find.text('餐饮'), findsNothing);
      expect(find.text('交通'), findsNothing);
      expect(find.text('工资'), findsNothing);
    });

    testWidgets('expands branches independently', (tester) async {
      await tester.pumpWidget(_picker(initiallyCollapsed: true));

      await tester.tap(find.byIcon(Icons.chevron_right_rounded).first);
      await tester.pump();

      expect(find.text('餐饮'), findsOneWidget);
      expect(find.text('交通'), findsOneWidget);
      expect(find.text('工资'), findsNothing);
    });

    testWidgets('collapses virtual parent nodes without an id', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: FxTheme.light,
          home: Scaffold(
            body: FxTreePicker<_Node>(
              roots: _tree,
              childrenOf: (node) => node.children,
              labelOf: (node) => node.label,
              idOf: (node) => node.id == 'expenses' ? null : node.id,
              initiallyCollapsed: true,
            ),
          ),
        ),
      );

      expect(find.text('餐饮'), findsNothing);

      await tester.tap(find.byIcon(Icons.chevron_right_rounded).first);
      await tester.pump();

      expect(find.text('餐饮'), findsOneWidget);
    });

    testWidgets('searches descendants in collapsed branches', (tester) async {
      await tester.pumpWidget(_picker(initiallyCollapsed: true));

      await tester.enterText(find.byType(TextField), '餐饮');
      await tester.pump();

      expect(find.text('餐饮').last, findsOneWidget);
      expect(find.text('支出 / 餐饮'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      expect(find.text('餐饮'), findsNothing);
    });
  });
}
