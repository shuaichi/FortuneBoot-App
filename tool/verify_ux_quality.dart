import 'dart:io';

const _sourceRoot = 'lib';
const _ignoredPaths = {'lib/generated/'};
const _rules = <_Rule>[
  _Rule(
    id: 'raw-ui-error',
    pattern: r'\b(?:e|error)\.toString\(\)',
    message: 'Do not render raw exceptions in user-facing state.',
  ),
  _Rule(
    id: 'raw-snapshot-error',
    pattern: r'snapshot\.error\.toString\(\)',
    message: 'Do not render raw async errors in user-facing state.',
  ),
  _Rule(
    id: 'display-fixed-money',
    pattern: r'\.toStringAsFixed\(',
    message: 'Use FxMoneyFormatter for displayed money values.',
  ),
];

Future<void> main() async {
  final exceptions = _readExceptions();
  final findings = <String>[];

  await for (final entity in Directory(_sourceRoot).list(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final normalizedPath = entity.path.replaceAll('\\', '/');
    if (_ignoredPaths.any(normalizedPath.startsWith)) continue;
    final lines = await entity.readAsLines();
    for (var index = 0; index < lines.length; index++) {
      for (final rule in _rules) {
        if (!RegExp(rule.pattern).hasMatch(lines[index])) continue;
        final key = '${rule.id}:$normalizedPath:${index + 1}';
        if (exceptions.contains(key)) continue;
        findings.add('$key ${rule.message}');
      }
    }
  }

  if (findings.isEmpty) {
    stdout.writeln('UX quality gate passed.');
    return;
  }

  stderr.writeln('UX quality gate found ${findings.length} issue(s):');
  for (final finding in findings) {
    stderr.writeln('- $finding');
  }
  exitCode = 1;
}

Set<String> _readExceptions() {
  final file = File('docs/quality-gate-exceptions.md');
  if (!file.existsSync()) return const {};
  return file
      .readAsLinesSync()
      .map((line) => line.trim())
      .where((line) => line.startsWith('`') && line.endsWith('`'))
      .map((line) => line.substring(1, line.length - 1))
      .toSet();
}

class _Rule {
  const _Rule({required this.id, required this.pattern, required this.message});

  final String id;
  final String pattern;
  final String message;
}
