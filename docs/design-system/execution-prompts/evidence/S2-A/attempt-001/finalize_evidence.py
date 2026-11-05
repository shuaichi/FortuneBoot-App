import hashlib
import json
from pathlib import Path

root = Path.cwd()
out = root / 'docs/design-system/execution-prompts/evidence/S2-A/attempt-001'

def summarize(name):
    events = [json.loads(line) for line in (out / f'{name}.json').read_text().splitlines() if line.strip()]
    starts = {e['test']['id']: e['test']['name'] for e in events if e.get('type') == 'testStart'}
    done = [e for e in events if e.get('type') == 'testDone']
    real = [
        e for e in done
        if not starts[e['testID']].startswith('loading ')
        and starts[e['testID']] not in {'(setUpAll)', '(tearDownAll)'}
    ]
    skipped = [starts[e['testID']] for e in real if e.get('skipped')]
    failed = [starts[e['testID']] for e in real if e.get('result') != 'success' and not e.get('skipped')]
    result = {
        'testDoneEvents': len(done),
        'realTests': len(real),
        'passed': len(real) - len(skipped) - len(failed),
        'skipped': len(skipped),
        'failed': len(failed),
        'skippedTests': skipped,
        'failedTests': failed,
        'loadingEvents': sum(starts[e['testID']].startswith('loading ') for e in done),
        'lifecycleEvents': sum(starts[e['testID']] in {'(setUpAll)', '(tearDownAll)'} for e in done),
        'errorEvents': [e.get('error') for e in events if e.get('type') == 'error'],
        'runner': [e for e in events if e.get('type') == 'done'],
        'countingRule': 'realTests excludes synthetic loading/setUpAll/tearDownAll entries; testDoneEvents retains all reporter testDone events',
    }
    (out / f'{name}-summary.json').write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')

for name in ['decisive-tests', 'visual-render', 'modal-probe', 'modal-probe-final', 'affected-consumer-tests', 'full-tests']:
    summarize(name)

snapshot = json.loads((out / 'source-snapshot.json').read_text())
production_snapshot_sha = hashlib.sha256(
    json.dumps(snapshot['files'], sort_keys=True).encode()
).hexdigest()
head = snapshot['head']
shared_probe = out / 's2_a_component_preview_test.dart'
modal_probe = out / 's2_a_modal_probe_test.dart'
shared_sha = hashlib.sha256(shared_probe.read_bytes()).hexdigest()
modal_sha = hashlib.sha256(modal_probe.read_bytes()).hexdigest()

def path_sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

entries = []
for theme in ['light', 'dark']:
    for width in [320, 390]:
        for scale in [1, 2]:
            name = f'shared-{theme}-{width}-{scale}x.png'
            path = out / name
            if scale == 1 and width == 320:
                observation = '已打开查看：品牌卡、输入框、选择器及长文本完整可见；主金额把 .12 单独换到下一行，千分位组与小数未被作为不可拆分的财务阅读单元，视觉门槛不通过。'
            elif scale == 2 and width == 320:
                observation = '已打开查看：无横向溢出，但主金额拆成 ¥1,234, / 567,89 / 0.12，列表金额末位换行，Expense 拆为 Expens/e；金额与分段大字视觉门槛不通过。'
            elif scale == 2 and width == 390:
                observation = '已打开查看：无横向溢出，分段标签完整；主金额拆成 ¥1,234,5 / 67,890.1 / 2，千分位组和小数位被拆开，金额大字视觉门槛不通过。'
            else:
                observation = '已打开查看：亮暗层级、品牌实色卡前景、聚焦/错误输入、长中英文、选择行、分段和底部 CTA 完整可见，未见横向溢出或关键内容省略；此图不证明其它宽度/字号。'
            entries.append({
                'page': 'Fx shared component contract fixture',
                'state': f'{theme}-{width}-{scale}x',
                'theme': theme.upper(),
                'logicalSize': [width, 1900 if scale == 1 else (3500 if width == 320 else 3000)],
                'textScale': scale,
                'sourceHead': head,
                'sourceSha256': shared_sha,
                'productionSourceSnapshotSha256': production_snapshot_sha,
                'path': str(path.relative_to(root)),
                'pathSha256': path_sha(path),
                'actuallyViewed': True,
                'observation': observation,
            })
modal_path = out / 'modal-keyboard-busy-light-390-1x.png'
entries.append({
    'page': 'FxSheet busy guarded form fixture',
    'state': 'busy-dirty-keyboard-inset',
    'theme': 'LIGHT',
    'logicalSize': [390, 844],
    'textScale': 1,
    'sourceHead': head,
    'sourceSha256': modal_sha,
    'productionSourceSnapshotSha256': production_snapshot_sha,
    'path': str(modal_path.relative_to(root)),
    'pathSha256': path_sha(modal_path),
    'actuallyViewed': True,
    'keyboardRepresentation': 'SIMULATED_240_LOGICAL_PIXEL_VIEW_INSET_NOT_PLATFORM_KEYBOARD',
    'observation': '已打开查看：弹层位于模拟键盘 inset 上方，未保存输入、标题、关闭出口和加载底部动作均可见，inset 只应用一次；空白下部是模拟占位，不是真实系统键盘或真机证据。',
})
(out / 'screenshot-index.json').write_text(json.dumps(entries, ensure_ascii=False, indent=2) + '\n')

s1_hashes = json.loads((root / 'docs/design-system/execution-prompts/evidence/S1-A/attempt-001/source-sha256.json').read_text())
changed = []
missing = []
for name, old_hash in s1_hashes.items():
    path = root / name
    if not path.exists():
        missing.append(name)
    elif path_sha(path) != old_hash:
        changed.append(name)
comparison = {
    's1EvidenceFileCount': len(s1_hashes),
    'changed': changed,
    'missing': missing,
    'currentHead': head,
    'note': 'S1-A was later committed as 00a8f2f; all 36 recorded production/test/preview files still match the S1-A uncommitted evidence byte-for-byte.',
}
(out / 'production-source-comparison.json').write_text(json.dumps(comparison, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({'screenshots': len(entries), 'sourceComparison': comparison}, ensure_ascii=False, indent=2))
