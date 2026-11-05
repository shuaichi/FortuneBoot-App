import hashlib
import json
import os
from pathlib import Path

root = Path.cwd()
path = root / 'docs/design-system/execution-prompts/runtime/progress.json'
data = json.loads(path.read_text())
before = json.dumps({key: value for key, value in data['stages'].items() if key != 'S2-A'}, sort_keys=True)
previous_evidence = data['stages']['S2-A'].get('evidence', [])
evidence = list(dict.fromkeys([*previous_evidence, 'evidence/S2-A/attempt-003']))
data['stages']['S2-A'] = {
    'status': 'PASSED',
    'localGate': 'PASSED',
    'visualGate': 'PASSED',
    'externalGate': 'PARTIAL',
    'attempt': 3,
    'handoff': 'handoff/S2-A.md',
    'evidence': evidence,
    'blockingIssues': ['DEVICE_AND_PLATFORM_ACCEPTANCE'],
}
data['nextStage'] = 'S3-A'
after = json.dumps({key: value for key, value in data['stages'].items() if key != 'S2-A'}, sort_keys=True)
assert before == after, 'A stage other than S2-A changed'
temporary = path.with_name('.progress.S2-A.attempt-003.tmp.json')
temporary.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')
json.loads(temporary.read_text())
os.replace(temporary, path)
report = {
    'updated': ['stages.S2-A', 'nextStage'],
    'nextStage': data['nextStage'],
    'evidence': evidence,
    'otherStagesUnchanged': True,
    'otherStagesSha256': hashlib.sha256(after.encode()).hexdigest(),
}
(root / 'docs/design-system/execution-prompts/evidence/S2-A/attempt-003/progress-diff.json').write_text(
    json.dumps(report, ensure_ascii=False, indent=2) + '\n'
)
