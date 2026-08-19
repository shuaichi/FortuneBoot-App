import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/core/app_lock/pattern_path_resolver.dart';

void main() {
  group('PatternPathResolver', () {
    test('keeps direct input separate from the traditional canonical path', () {
      final resolution = PatternPathResolver.resolve(
        selectedPath: const [0],
        endpoint: 2,
      );

      expect(resolution.directPath, [0, 2]);
      expect(resolution.traditionalCanonicalPath, [0, 1, 2]);
    });

    test('uses the fixed zero through eight grid indices', () {
      final resolution = PatternPathResolver.resolve(
        selectedPath: const [6],
        endpoint: 8,
      );

      expect(resolution.directPath, [6, 8]);
      expect(resolution.traditionalCanonicalPath, [6, 7, 8]);
    });

    test(
      'inserts an unselected midpoint for horizontal, vertical, and diagonal jumps',
      () {
        final horizontal = PatternPathResolver.resolve(
          selectedPath: const [0],
          endpoint: 2,
        );
        final vertical = PatternPathResolver.resolve(
          selectedPath: const [0],
          endpoint: 6,
        );
        final descendingDiagonal = PatternPathResolver.resolve(
          selectedPath: const [0],
          endpoint: 8,
        );
        final ascendingDiagonal = PatternPathResolver.resolve(
          selectedPath: const [2],
          endpoint: 6,
        );

        expect(horizontal.traditionalCanonicalPath, [0, 1, 2]);
        expect(vertical.traditionalCanonicalPath, [0, 3, 6]);
        expect(descendingDiagonal.traditionalCanonicalPath, [0, 4, 8]);
        expect(ascendingDiagonal.traditionalCanonicalPath, [2, 4, 6]);
      },
    );

    test('retains prior midpoints across a multi-segment path', () {
      var resolution = PatternPathResolver.resolve(
        selectedPath: const [0],
        endpoint: 2,
      );
      resolution = PatternPathResolver.resolve(
        selectedPath: resolution.directPath,
        endpoint: 3,
      );
      resolution = PatternPathResolver.resolve(
        selectedPath: resolution.directPath,
        endpoint: 4,
      );

      expect(resolution.directPath, [0, 2, 3, 4]);
      expect(resolution.traditionalCanonicalPath, [0, 1, 2, 3, 4]);
    });

    test('does not duplicate a midpoint already selected in the path', () {
      final resolution = PatternPathResolver.resolve(
        selectedPath: const [0, 4],
        endpoint: 8,
      );

      expect(resolution.directPath, [0, 4, 8]);
      expect(resolution.traditionalCanonicalPath, [0, 4, 8]);
    });

    test('ignores an endpoint that has already been selected', () {
      final resolution = PatternPathResolver.resolve(
        selectedPath: const [0, 4, 8],
        endpoint: 4,
      );

      expect(resolution.directPath, [0, 4, 8]);
      expect(resolution.traditionalCanonicalPath, [0, 4, 8]);
    });

    test('serializes both paths as stable comma-separated values', () {
      final resolution = PatternPathResolver.resolve(
        selectedPath: const [2],
        endpoint: 6,
      );

      expect(resolution.directCsv, '2,6');
      expect(resolution.traditionalCanonicalCsv, '2,4,6');
    });

    test(
      'does not retain a mutable caller path or expose mutable result paths',
      () {
        final callerPath = [0];
        final resolution = PatternPathResolver.resolve(
          selectedPath: callerPath,
          endpoint: 2,
        );
        callerPath.add(8);

        expect(resolution.directPath, [0, 2]);
        expect(resolution.traditionalCanonicalPath, [0, 1, 2]);
        expect(() => resolution.directPath.add(8), throwsUnsupportedError);
        expect(
          () => resolution.traditionalCanonicalPath.removeLast(),
          throwsUnsupportedError,
        );
      },
    );
  });
}
