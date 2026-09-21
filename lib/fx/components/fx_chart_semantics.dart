import 'package:flutter/material.dart';

/// Invisible, focusable semantics nodes layered over custom-painted charts.
class FxChartSemanticsOverlay extends StatelessWidget {
  final List<String> labels;
  final String? hint;

  const FxChartSemanticsOverlay({super.key, required this.labels, this.hint});

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                container: true,
                label: labels[i],
                hint: i == 0 ? hint : null,
                readOnly: true,
                child: const SizedBox.expand(),
              ),
            ),
        ],
      ),
    );
  }
}
