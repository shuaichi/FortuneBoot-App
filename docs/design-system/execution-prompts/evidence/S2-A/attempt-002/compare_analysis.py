import collections
import json
import pathlib
import re

root = pathlib.Path('docs/design-system/execution-prompts/evidence')
current_path = root / 'S2-A/attempt-002/flutter-analyze-final.txt'
baseline_path = root / 'S1-A/attempt-001/analysis-diagnostics.json'
pattern = re.compile(
    r'^\s*(error|warning|info)\s+•\s+(.*?)\s+•\s+([^:]+):(\d+):(\d+)\s+•\s+(\S+)\s*$'
)
current = []
for line in current_path.read_text().splitlines():
    match = pattern.match(line)
    if match:
        severity, message, path, line_number, column, code = match.groups()
        current.append({
            'severity': severity,
            'message': message,
            'path': path,
            'line': int(line_number),
            'column': int(column),
            'code': code,
        })
baseline = json.loads(baseline_path.read_text())
def key(item):
    return (
        item['severity'], item['message'], item['path'], item['line'],
        item['column'], item['code'],
    )
baseline_keys = {key(item) for item in baseline}
current_keys = {key(item) for item in current}
new = [item for item in current if key(item) not in baseline_keys]
removed = [item for item in baseline if key(item) not in current_keys]
result = {
    'baselineCount': len(baseline),
    'currentCount': len(current),
    'bySeverity': dict(collections.Counter(item['severity'] for item in current)),
    'new': new,
    'removed': removed,
}
(root / 'S2-A/attempt-002/analysis-diagnostics.json').write_text(
    json.dumps(current, ensure_ascii=False, indent=2) + '\n'
)
(root / 'S2-A/attempt-002/analysis-comparison.json').write_text(
    json.dumps(result, ensure_ascii=False, indent=2) + '\n'
)
print(json.dumps(result, ensure_ascii=False, indent=2))
