class PatternPathResolution {
  PatternPathResolution({
    required List<int> directPath,
    required List<int> traditionalCanonicalPath,
  }) : directPath = List.unmodifiable(directPath),
       traditionalCanonicalPath = List.unmodifiable(traditionalCanonicalPath);

  final List<int> directPath;
  final List<int> traditionalCanonicalPath;

  String get directCsv => directPath.join(',');
  String get traditionalCanonicalCsv => traditionalCanonicalPath.join(',');
}

class PatternPathResolver {
  const PatternPathResolver._();

  static PatternPathResolution resolve({
    required List<int> selectedPath,
    required int endpoint,
  }) {
    final directPath = List<int>.of(selectedPath);
    if (_isValidNode(endpoint) && !directPath.contains(endpoint)) {
      directPath.add(endpoint);
    }
    return PatternPathResolution(
      directPath: directPath,
      traditionalCanonicalPath: _traditionalCanonicalPath(directPath),
    );
  }

  static List<int> _traditionalCanonicalPath(List<int> directPath) {
    final canonicalPath = <int>[];
    for (final endpoint in directPath) {
      if (!_isValidNode(endpoint) || canonicalPath.contains(endpoint)) continue;
      if (canonicalPath.isNotEmpty) {
        final midpoint = _midpointBetween(canonicalPath.last, endpoint);
        if (midpoint != null && !canonicalPath.contains(midpoint)) {
          canonicalPath.add(midpoint);
        }
      }
      canonicalPath.add(endpoint);
    }
    return canonicalPath;
  }

  static int? _midpointBetween(int start, int end) {
    if (!_isValidNode(start) || !_isValidNode(end)) return null;
    final startRow = start ~/ 3;
    final startColumn = start % 3;
    final endRow = end ~/ 3;
    final endColumn = end % 3;
    final rowDelta = endRow - startRow;
    final columnDelta = endColumn - startColumn;
    if (!_hasMidpoint(rowDelta.abs(), columnDelta.abs())) return null;
    return ((startRow + endRow) ~/ 2) * 3 + ((startColumn + endColumn) ~/ 2);
  }

  static bool _hasMidpoint(int rowDelta, int columnDelta) =>
      (rowDelta == 2 && (columnDelta == 0 || columnDelta == 2)) ||
      (columnDelta == 2 && rowDelta == 0);

  static bool _isValidNode(int node) => node >= 0 && node < 9;
}
