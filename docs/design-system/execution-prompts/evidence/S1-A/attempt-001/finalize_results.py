import collections
import hashlib
import json
import re
import subprocess
from pathlib import Path

root = Path.cwd()
base = root / 'docs/design-system/execution-prompts/evidence/S1-A/attempt-001'

def events(name):
    return [json.loads(line) for line in (base / name).read_text().splitlines() if line.strip()]

def test_summary(name):
    data = events(name)
    done = [event for event in data if event.get('type') == 'testDone']
    skipped = [event for event in done if event.get('skipped') or event.get('result') == 'skipped']
    failed = [event for event in done if event.get('result') not in ('success', 'skipped') and not event.get('skipped')]
    starts = {event['test']['id']: event['test'] for event in data if event.get('type') == 'testStart'}
    return {
        'totalVisible': len(done),
        'passed': len(done) - len(skipped) - len(failed),
        'skipped': len(skipped),
        'failed': len(failed),
        'errorEvents': sum(event.get('type') == 'error' for event in data),
        'runner': [event for event in data if event.get('type') == 'done'],
        'skippedTests': [starts[event['testID']]['name'] for event in skipped],
        'failedTests': [starts.get(event['testID'], {}).get('name') for event in failed],
    }

targeted = test_summary('targeted-tests.json')
affected = test_summary('affected-consumer-tests.json')
full = test_summary('full-tests.json')
text = (base / 'flutter-analyze.txt').read_text()
pattern = re.compile(r'^\s*(error|warning|info) • (.*?) • (.*?):(\d+):(\d+) • ([A-Za-z0-9_]+)\s*$')
diagnostics = []
for line in text.splitlines():
    match = pattern.match(line)
    if match:
        severity, message, path, line_no, column, code = match.groups()
        diagnostics.append({'severity': severity, 'message': message, 'path': path, 'line': int(line_no), 'column': int(column), 'code': code})
(base / 'analysis-diagnostics.json').write_text(json.dumps(diagnostics, ensure_ascii=False, indent=2) + '\n')
baseline = json.loads((root / 'docs/design-system/execution-prompts/evidence/S0-A/attempt-001/analysis-diagnostics.json').read_text())
key = lambda item: (item['path'], item['code'], item['message'])
b = collections.Counter(key(item) for item in baseline)
c = collections.Counter(key(item) for item in diagnostics)
new = list((c - b).elements())
removed = list((b - c).elements())
comparison = {
    'baselineCount': len(baseline),
    'currentCount': len(diagnostics),
    'bySeverity': {severity: sum(item['severity'] == severity for item in diagnostics) for severity in ['error', 'warning', 'info']},
    'new': [dict(zip(['path', 'code', 'message'], item)) for item in new],
    'removed': [dict(zip(['path', 'code', 'message'], item)) for item in removed],
}
(base / 'analysis-comparison.json').write_text(json.dumps(comparison, ensure_ascii=False, indent=2) + '\n')

source_paths = subprocess.check_output(['git', 'diff', '--name-only', '--', 'lib', 'test', 'tool'], text=True).splitlines()
source_paths += subprocess.check_output(['git', 'ls-files', '--others', '--exclude-standard', '--', 'test', 'tool'], text=True).splitlines()
source_paths = sorted(set(source_paths))
source_sha = {path: hashlib.sha256((root / path).read_bytes()).hexdigest() for path in source_paths}
(base / 'source-sha256.json').write_text(json.dumps(source_sha, ensure_ascii=False, indent=2) + '\n')

results = {
    'stage': 'S1-A',
    'attempt': 1,
    'status': 'PARTIAL',
    'sourceShaBefore': '6061359de0d6db6597176a9158ee826de490f6c4',
    'sourceShaAfter': '6061359de0d6db6597176a9158ee826de490f6c4',
    'sourceSnapshot': 'Uncommitted working-tree changes; per-file SHA256 in source-sha256.json',
    'baselineTargeted': {'totalVisible': 43, 'passed': 43, 'skipped': 0, 'failed': 0},
    'targeted': targeted,
    'affectedConsumers': affected,
    'full': full,
    'analysis': {'exitCode': 1, 'count': len(diagnostics), **comparison},
    'visual': {'rendered': 8, 'actuallyViewed': 8, 'index': 'screenshot-index.json'},
    'issueChecks': json.loads((root / 'docs/design-system/execution-prompts/runtime/issue-checks/S1-A.json').read_text())['summary'],
    'deviceGate': {'simulatorOrDevice': 'NOT_RUN', 'voiceOverTalkBack': 'NOT_RUN', 'platformBuild': 'NOT_RUN', 'serverIntegration': 'NOT_RUN'},
}
(base / 'results.json').write_text(json.dumps(results, ensure_ascii=False, indent=2) + '\n')

commands = [
    {'command': 'flutter --version', 'exitCode': 0, 'evidence': 'flutter-version.txt'},
    {'command': 'flutter test --no-pub --reporter json test/fx test/core/money test/core/errors', 'exitCode': 0, 'evidence': 'targeted-tests.json', 'counts': targeted},
    {'command': 'flutter test --no-pub --reporter json test/features/bill_editor test/features/recurring', 'exitCode': 0, 'evidence': 'affected-consumer-tests.json', 'counts': affected},
    {'command': 'flutter test --no-pub --reporter json', 'exitCode': 0, 'evidence': 'full-tests.json', 'counts': full},
    {'command': 'flutter analyze --no-pub', 'exitCode': 1, 'evidence': 'flutter-analyze.txt', 'counts': comparison['bySeverity']},
    {'command': 'flutter test --no-pub tool/s1_a_component_preview_test.dart', 'exitCode': 0, 'evidence': 'visual-render.txt', 'counts': {'rendered': 8}},
    {'command': 'python3 docs/design-system/execution-prompts/tools/validate_pack.py', 'exitCode': 0, 'evidence': 'pack-validation.txt'},
]
(base / 'commands.json').write_text(json.dumps(commands, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({'targeted': targeted, 'affected': affected, 'full': full, 'analysis': comparison}, ensure_ascii=False))
