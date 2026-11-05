import hashlib
import json
import os
from pathlib import Path

root = Path.cwd()
path = root / 'docs/design-system/execution-prompts/runtime/progress.json'
data = json.loads(path.read_text())
before = json.dumps({key: value for key, value in data['stages'].items() if key != 'S1-B'}, sort_keys=True)
data['stages']['S1-B'] = {'status': 'PASSED', 'localGate': 'PASSED', 'visualGate': 'PASSED', 'externalGate': 'PARTIAL', 'attempt': 2, 'handoff': 'handoff/S1-B.md', 'evidence': ['evidence/S1-B/attempt-001', 'evidence/S1-B/attempt-002'], 'blockingIssues': ['S2-A_ATTEMPT_003_REVIEW', 'DEVICE_AND_PLATFORM_ACCEPTANCE']}
data['nextStage'] = 'S2-A'
after = json.dumps({key: value for key, value in data['stages'].items() if key != 'S1-B'}, sort_keys=True)
assert before == after, 'A stage other than S1-B changed'
temporary = path.with_name('.progress.S1-B-attempt-002.tmp.json')
temporary.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')
json.loads(temporary.read_text())
os.replace(temporary, path)
report = {'updated': ['stages.S1-B', 'nextStage'], 'nextStage': 'S2-A', 'nextAttempt': 3, 'otherStagesUnchanged': True, 'otherStagesSha256': hashlib.sha256(after.encode()).hexdigest()}
(root / 'docs/design-system/execution-prompts/evidence/S1-B/attempt-002/progress-diff.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
