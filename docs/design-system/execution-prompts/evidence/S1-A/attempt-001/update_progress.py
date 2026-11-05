import hashlib
import json
import os
from pathlib import Path

root = Path.cwd()
path = root / 'docs/design-system/execution-prompts/runtime/progress.json'
data = json.loads(path.read_text())
before = json.dumps({key: value for key, value in data['stages'].items() if key != 'S1-A'}, sort_keys=True)
data['stages']['S1-A'] = {
    'status': 'PARTIAL',
    'localGate': 'PASSED',
    'visualGate': 'PASSED',
    'externalGate': 'PARTIAL',
    'attempt': 1,
    'handoff': 'handoff/S1-A.md',
    'evidence': ['evidence/S1-A/attempt-001'],
    'blockingIssues': [
        'DS-021', 'DS-022', 'DS-023', 'DS-024',
        'DT-13', 'DT-14', 'DT-15', 'DT-28', 'DT-32', 'DT-33',
        'DT-35', 'DT-36', 'DT-38', 'DT-45', 'CX-04',
        'S2_INDEPENDENT_REVIEW', 'DEVICE_AND_PLATFORM_ACCEPTANCE',
    ],
}
data['nextStage'] = 'S2-A'
after = json.dumps({key: value for key, value in data['stages'].items() if key != 'S1-A'}, sort_keys=True)
assert before == after, 'A stage other than S1-A changed'
temporary = path.with_name('.progress.S1-A.tmp.json')
temporary.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')
json.loads(temporary.read_text())
os.replace(temporary, path)
report = {
    'updated': ['stages.S1-A', 'nextStage'],
    'nextStage': data['nextStage'],
    'otherStagesUnchanged': True,
    'otherStagesSha256': hashlib.sha256(after.encode()).hexdigest(),
}
(root / 'docs/design-system/execution-prompts/evidence/S1-A/attempt-001/progress-diff.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
