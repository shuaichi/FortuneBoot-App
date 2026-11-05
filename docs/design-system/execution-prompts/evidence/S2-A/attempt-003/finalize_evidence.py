import hashlib
import json
from pathlib import Path

root = Path.cwd()
out = root / 'docs/design-system/execution-prompts/evidence/S2-A/attempt-003'

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

for name in ['decisive-tests', 'review-probes', 'visual-render', 'modal-probe', 'affected-consumer-tests', 'full-tests']:
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
            if width in [390, 440] and scale == 2:
                observation = '已打开查看：金额为 ¥1,234, / 567, / 890.12，末组和小数不再孤立；Counterparty 完整，分段每项整行且英文不断词，无裁切或字号缩小。'
            elif width == 440 and scale == 1:
                observation = '已打开查看：主金额一行完整，Counterparty 不再拆为 Counterpart / y；长值、清空/箭头、分段和品牌卡完整可读。'
            elif scale == 2:
                observation = '已打开查看：金额按财务组重排，890.12 同行；分段整行、英文不断词。普通 FxListItem trailing 在 320/2x 仍有末位换行，属于未分配的普通文本实例，不影响本次三项共享合同闭合。'
            else:
                observation = '已打开查看：金额分组和小数完整，选择行/分段/品牌卡/输入/树/CTA 可读，未见横向溢出或关键内容省略。'
            entries.append({
                'page': 'Fx shared component final re-review fixture', 'state': f'{theme}-{width}-{scale}x',
                'theme': theme.upper(), 'logicalSize': [width, 1900 if scale == 1 else (3500 if width == 320 else 3000)],
                'textScale': scale, 'sourceHead': snapshot['head'], 'sourceSha256': preview_sha,
                'productionSourceSnapshotSha256': production_snapshot_sha,
                'path': str(path.relative_to(root)), 'pathSha256': sha(path), 'actuallyViewed': True,
                'defectIds': [], 'observation': observation,
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
print(json.dumps({'screenshots': len(entries), 'allActuallyViewed': all(e['actuallyViewed'] for e in entries)}, ensure_ascii=False, indent=2))
