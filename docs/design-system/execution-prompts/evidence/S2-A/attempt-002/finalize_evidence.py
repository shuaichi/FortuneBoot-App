import hashlib
import json
from pathlib import Path

root = Path.cwd()
out = root / 'docs/design-system/execution-prompts/evidence/S2-A/attempt-002'

def summarize(name):
    events = [json.loads(line) for line in (out / f'{name}.json').read_text().splitlines() if line.strip()]
    starts = {e['test']['id']: e['test']['name'] for e in events if e.get('type') == 'testStart'}
    done = [e for e in events if e.get('type') == 'testDone']
    real = [e for e in done if not starts[e['testID']].startswith('loading ') and starts[e['testID']] not in {'(setUpAll)', '(tearDownAll)'}]
    skipped = [starts[e['testID']] for e in real if e.get('skipped')]
    failed = [starts[e['testID']] for e in real if e.get('result') != 'success' and not e.get('skipped')]
    result = {
        'testDoneEvents': len(done), 'realTests': len(real),
        'passed': len(real) - len(skipped) - len(failed),
        'skipped': len(skipped), 'failed': len(failed),
        'skippedTests': skipped, 'failedTests': failed,
        'loadingEvents': sum(starts[e['testID']].startswith('loading ') for e in done),
        'lifecycleEvents': sum(starts[e['testID']] in {'(setUpAll)', '(tearDownAll)'} for e in done),
        'errorEvents': [e.get('error') for e in events if e.get('type') == 'error'],
        'runner': [e for e in events if e.get('type') == 'done'],
        'countingRule': 'realTests excludes synthetic loading/setUpAll/tearDownAll entries',
    }
    (out / f'{name}-summary.json').write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')

for name in ['decisive-tests', 'visual-render', 'modal-probe', 'decimal-reprobe', 'segmented-reprobe', 'segmented-reprobe-final', 'select-row-reprobe', 'select-row-reprobe-final', 'affected-consumer-tests', 'full-tests']:
    summarize(name)

snapshot_path = out / 'source-snapshot.json'
snapshot = json.loads(snapshot_path.read_text())
probes = sorted(out.glob('*_test.dart'))
snapshot['probeSha256'] = {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest() for p in probes}
snapshot_path.write_text(json.dumps(snapshot, ensure_ascii=False, indent=2) + '\n')
production_snapshot_sha = hashlib.sha256(json.dumps(snapshot['files'], sort_keys=True).encode()).hexdigest()
preview_sha = snapshot['probeSha256'][str((out / 's2_a_component_preview_test.dart').relative_to(root))]
modal_sha = snapshot['probeSha256'][str((out / 's2_a_modal_probe_test.dart').relative_to(root))]

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

entries = []
for theme in ['light', 'dark']:
    for width in [320, 390, 440]:
        for scale in [1, 2]:
            name = f'shared-{theme}-{width}-{scale}x.png'
            path = out / name
            defects = []
            if width in [390, 440] and scale == 2:
                defects.append('S2A-001')
            if width == 440 and scale == 1:
                defects.append('S2A-003')
            if defects == ['S2A-001']:
                observation = '已打开查看：大字分段每项整行且英文不断词；金额为 ¥1,234, / 567,890. / 12，小数位 12 独占第三行，S2A-001 未闭合。'
            elif defects == ['S2A-003']:
                observation = '已打开查看：主金额一行完整，普通分段完整；FxSelectRow 标签 Counterparty 拆为 Counterpart / y，S2A-003 确认。'
            elif scale == 2:
                observation = '已打开查看：金额按千分位组重排，末组 890.12 同行；分段每项整行且 Income/Expense 不断词，长文本、品牌卡、输入和 CTA 无裁切。'
            else:
                observation = '已打开查看：金额分组和小数完整，选择行/分段/品牌卡/输入/树/CTA 可读，未见横向溢出或关键内容省略。'
            entries.append({
                'page': 'Fx shared component re-review fixture', 'state': f'{theme}-{width}-{scale}x',
                'theme': theme.upper(), 'logicalSize': [width, 1900 if scale == 1 else (3500 if width == 320 else 3000)],
                'textScale': scale, 'sourceHead': snapshot['head'], 'sourceSha256': preview_sha,
                'productionSourceSnapshotSha256': production_snapshot_sha,
                'path': str(path.relative_to(root)), 'pathSha256': sha(path), 'actuallyViewed': True,
                'defectIds': defects, 'observation': observation,
            })
modal = out / 'modal-keyboard-busy-light-390-1x.png'
entries.append({
    'page': 'FxSheet busy guarded form fixture', 'state': 'busy-dirty-keyboard-inset',
    'theme': 'LIGHT', 'logicalSize': [390, 844], 'textScale': 1,
    'sourceHead': snapshot['head'], 'sourceSha256': modal_sha,
    'productionSourceSnapshotSha256': production_snapshot_sha,
    'path': str(modal.relative_to(root)), 'pathSha256': sha(modal), 'actuallyViewed': True,
    'keyboardRepresentation': 'SIMULATED_240_LOGICAL_PIXEL_VIEW_INSET_NOT_PLATFORM_KEYBOARD',
    'defectIds': [],
    'observation': '已打开查看：弹层位于模拟键盘 inset 上方，未保存输入、标题、关闭出口与加载动作可见，inset 只应用一次；不是系统键盘或真机证据。',
})
(out / 'screenshot-index.json').write_text(json.dumps(entries, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({'screenshots': len(entries), 'defectImages': sum(bool(e['defectIds']) for e in entries)}, ensure_ascii=False, indent=2))
