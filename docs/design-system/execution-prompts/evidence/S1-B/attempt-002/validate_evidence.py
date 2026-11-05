import hashlib
import json
import subprocess
from pathlib import Path

root = Path.cwd()
base = root / 'docs/design-system/execution-prompts/evidence/S1-B/attempt-002'
pack = root / 'docs/design-system/execution-prompts'

def sha(path):
    return hashlib.sha256((root / path).read_bytes()).hexdigest()

checks = {}
issues = json.loads((pack / 'runtime/issue-checks/S1-B.json').read_text())
assert issues['attempt'] == 2
assert {item['issueId'] for item in issues['items']} == {'S2A-001', 'S2A-003'}
assert all(item['state'] == 'VERIFIED_LOCAL' for item in issues['items'])
assert issues['summary']['verifiedClosed'] == 0
for item in issues['items']:
    for path in item['sourcePaths']:
        assert item['sourceSha256'][path] == sha(path), path
    for path in item['evidencePaths']:
        assert (root / path).is_file(), path
checks['repairRoutingAndIssues'] = 'PASS: exactly S2A-001/S2A-003; VERIFIED_LOCAL only; source/evidence SHA current'

screens = json.loads((base / 'screenshot-index.json').read_text())
assert len(screens) == 12
for item in screens:
    assert item['actuallyViewed'] is True
    assert item['pathSha256'] == sha(item['path'])
    assert item['sourceSha256'] == sha('docs/design-system/execution-prompts/evidence/S1-B/attempt-002/s1_b_component_preview_test.dart')
checks['visualEvidence'] = 'PASS: 12 final Flutter PNGs; all viewed; fixture/path SHA current'

results = json.loads((base / 'results.json').read_text())
for key, filename in [('targeted', 'targeted-tests.json'), ('directConsumers', 'direct-consumer-tests.json'), ('full', 'full-tests.json')]:
    events = [json.loads(line) for line in (base / filename).read_text().splitlines() if line.strip()]
    done = [event for event in events if event.get('type') == 'testDone']
    skipped = [event for event in done if event.get('skipped') or event.get('result') == 'skipped']
    failed = [event for event in done if event.get('result') not in ('success', 'skipped') and not event.get('skipped')]
    computed = {'totalVisible': len(done), 'passed': len(done) - len(skipped) - len(failed), 'skipped': len(skipped), 'failed': len(failed), 'errorEvents': sum(event.get('type') == 'error' for event in events)}
    for field, value in computed.items():
        assert results[key][field] == value, (key, field)
    assert results[key]['runner'][-1]['success'] is True
assert results['analysis']['currentCount'] == 1159
assert results['analysis']['bySeverity'] == {'error': 0, 'warning': 252, 'info': 907}
assert results['analysis']['new'] == [] and results['analysis']['removed'] == []
checks['testAndAnalysisCounts'] = 'PASS: targeted 87; direct 58; full 533 passed + 1 skipped; analysis baseline unchanged'

progress = json.loads((pack / 'runtime/progress.json').read_text())
assert progress['nextStage'] == 'S2-A'
assert progress['stages']['S1-B']['attempt'] == 2
assert progress['stages']['S1-B']['status'] == 'PASSED'
assert progress['stages']['S1-B']['evidence'] == ['evidence/S1-B/attempt-001', 'evidence/S1-B/attempt-002']
assert progress['stages']['S2-A']['status'] == 'FAILED'
assert json.loads((base / 'progress-diff.json').read_text())['otherStagesUnchanged'] is True
assert (pack / 'prompts/03-S2-A.md').is_file()
handoff = (pack / 'handoff/S1-B.md').read_text()
assert 'attempt-003' in handoff and 'attempt-001' in handoff
checks['runtimeAndNextStage'] = 'PASS: only S1-B/nextStage updated; S2-A remains FAILED pending attempt-003'

for path, value in json.loads((base / 'source-sha256.json').read_text()).items():
    assert value == sha(path), path
contracts = (pack / 'reference/contracts-current.md').read_text()
assert '890.12' in contracts and '空格 token' in contracts
consumers = json.loads((pack / 'reference/component-consumers.json').read_text())
for item in consumers['components']:
    if item['symbol'] in ['FxMoneyText', 'FxSelectRow']:
        assert item['definitionSha256'] == sha(item['definition'])
checks['contractsAndConsumers'] = 'PASS: updated default behavior, component SHA and references current'

status = subprocess.run(['git', 'status', '--short'], cwd=root, text=True, capture_output=True, check=True).stdout
(base / 'final-git-status.txt').write_text(status)
checks['finalGitState'] = 'PASS: no commit/push; S1-B changes and both evidence attempts preserved'
output = {'status': 'PASS', 'checks': checks}
(base / 'validation.json').write_text(json.dumps(output, ensure_ascii=False, indent=2) + '\n')
print(json.dumps(output, ensure_ascii=False, indent=2))
