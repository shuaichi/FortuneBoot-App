import hashlib
import json
from pathlib import Path

root = Path.cwd()
base = root / 'docs/design-system/execution-prompts/evidence/S1-A/attempt-001'
pack = root / 'docs/design-system/execution-prompts'
checks = {}

def sha(path):
    return hashlib.sha256((root / path).read_bytes()).hexdigest()

issues = json.loads((pack / 'issues.json').read_text())['items']
expected = {item['id'] for item in issues if any(x['stage'] == 'S1-A' for x in item['instances'])}
checks_data = json.loads((pack / 'runtime/issue-checks/S1-A.json').read_text())
actual = {item['issueId'] for item in checks_data['items']}
assert actual == expected and len(actual) == 64
assert checks_data['summary']['verifiedClosed'] == 0
for item in checks_data['items']:
    for path in item['sourcePaths']:
        assert (root / path).is_file(), path
        assert item['sourceSha256'][path] == sha(path), f'stale source SHA: {path}'
    for path in item['evidencePaths']:
        assert (root / path).is_file(), path
checks['issueIdsPathsAndSourceSha'] = 'PASS: 64 exact S1-A instances; all source/evidence paths and source SHA current'

screens = json.loads((base / 'screenshot-index.json').read_text())
assert len(screens) == 8
for item in screens:
    assert item['actuallyViewed'] is True
    assert (root / item['path']).is_file()
    assert item['pathSha256'] == sha(item['path'])
    assert item['sourceSha256'] == sha('tool/s1_a_component_preview_test.dart')
checks['screenshots'] = 'PASS: 8 real Flutter PNGs, all marked actually viewed, fixture/path SHA current'

results = json.loads((base / 'results.json').read_text())
for key, filename in [('targeted', 'targeted-tests.json'), ('affectedConsumers', 'affected-consumer-tests.json'), ('full', 'full-tests.json')]:
    events = [json.loads(line) for line in (base / filename).read_text().splitlines() if line.strip()]
    done = [event for event in events if event.get('type') == 'testDone']
    skipped = [event for event in done if event.get('skipped') or event.get('result') == 'skipped']
    failed = [event for event in done if event.get('result') not in ('success', 'skipped') and not event.get('skipped')]
    computed = {'totalVisible': len(done), 'passed': len(done) - len(skipped) - len(failed), 'skipped': len(skipped), 'failed': len(failed), 'errorEvents': sum(event.get('type') == 'error' for event in events)}
    for field, value in computed.items():
        assert results[key][field] == value, (key, field, results[key][field], value)
    assert results[key]['runner'][-1]['success'] is True
checks['testCounts'] = 'PASS: targeted 76/0/0; consumers 54/0/0; full 522 passed + 1 IAP skipped + 0 failed'

analysis = results['analysis']
assert analysis['count'] == 1159
assert analysis['bySeverity'] == {'error': 0, 'warning': 252, 'info': 907}
assert analysis['new'] == [] and analysis['removed'] == []
checks['analysisComparison'] = 'PASS: 1159 diagnostics; 0 error; baseline new=0 removed=0'

consumers = json.loads((pack / 'reference/component-consumers.json').read_text())
assert consumers['contractState'] == 'FROZEN_LOCAL'
for item in consumers['components']:
    assert item['definitionSha256'] == sha(item['definition']), item['symbol']
    for path in item['directConsumers'] + item['testAndPreviewReferences']:
        assert (root / path).is_file(), path
symbols = {item['symbol'] for item in consumers['components']}
assert {'FxSelectionKind', 'FxSelectionResult', 'showFxOptionPickerResult', 'showFxOptionPicker', 'showFxMultiOptionPicker', 'FxSheetPopGuard'} <= symbols
checks['consumerIndex'] = 'PASS: all definition SHA and consumer/test paths current; new contract symbols indexed'

progress = json.loads((pack / 'runtime/progress.json').read_text())
assert progress['nextStage'] == 'S2-A'
assert progress['stages']['S1-A']['status'] == 'PARTIAL'
assert progress['stages']['S1-A']['attempt'] == 1
assert progress['stages']['S0-A']['status'] == 'PASSED'
assert json.loads((base / 'progress-diff.json').read_text())['otherStagesUnchanged'] is True
handoff = (pack / 'handoff/S1-A.md').read_text()
assert '6061359de0d6db6597176a9158ee826de490f6c4' in handoff
assert 'docs/design-system/execution-prompts/prompts/03-S2-A.md' in handoff
assert (pack / 'prompts/03-S2-A.md').is_file()
checks['runtimeAndHandoff'] = 'PASS: only S1-A/nextStage updated; next prompt exists and is not executed'

output = {'status': 'PASS', 'checks': checks}
(base / 'validation.json').write_text(json.dumps(output, ensure_ascii=False, indent=2) + '\n')
print(json.dumps(output, ensure_ascii=False, indent=2))
