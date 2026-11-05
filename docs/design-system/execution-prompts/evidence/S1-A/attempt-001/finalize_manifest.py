import hashlib
import json
import subprocess
from pathlib import Path

root = Path.cwd()
base = root / 'docs/design-system/execution-prompts/evidence/S1-A/attempt-001'

def run(args):
    result = subprocess.run(args, cwd=root, text=True, capture_output=True)
    return {'command': args, 'exitCode': result.returncode, 'stdout': result.stdout, 'stderr': result.stderr}

status = [
    run(['git', 'rev-parse', 'HEAD']),
    run(['git', 'branch', '--show-current']),
    run(['git', 'status', '--short']),
    run(['git', 'diff', '--stat']),
    run(['git', 'diff', '--check']),
]
(base / 'final-repo-status.json').write_text(json.dumps(status, ensure_ascii=False, indent=2) + '\n')
required = [
    'docs/design-system/execution-prompts/handoff/S1-A.md',
    'docs/design-system/execution-prompts/runtime/issue-checks/S1-A.json',
    'docs/design-system/execution-prompts/runtime/progress.json',
    'docs/design-system/execution-prompts/reference/contracts-current.md',
    'docs/design-system/execution-prompts/reference/component-consumers.json',
    'docs/design-system/execution-prompts/evidence/S1-A/attempt-001/results.json',
    'docs/design-system/execution-prompts/evidence/S1-A/attempt-001/commands.json',
    'docs/design-system/execution-prompts/evidence/S1-A/attempt-001/screenshot-index.json',
    'docs/design-system/execution-prompts/evidence/S1-A/attempt-001/validation.json',
    'docs/design-system/execution-prompts/evidence/S1-A/attempt-001/source-sha256.json',
    'docs/design-system/execution-prompts/evidence/S1-A/attempt-001/final-repo-status.json',
]
manifest = []
for path in required:
    data = (root / path).read_bytes()
    manifest.append({'path': path, 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()})
(base / 'artifact-manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')
print(f'validated final repo state and {len(manifest)} artifacts')
