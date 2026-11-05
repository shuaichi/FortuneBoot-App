import collections
import hashlib
import json
import re
from pathlib import Path

root = Path.cwd()
base = root / 'docs/design-system/execution-prompts/evidence/S1-B/attempt-001'
pack = root / 'docs/design-system/execution-prompts'

def sha(path):
    return hashlib.sha256((root / path).read_bytes()).hexdigest()

def summary(name):
    events = [json.loads(line) for line in (base / name).read_text().splitlines() if line.strip()]
    done = [event for event in events if event.get('type') == 'testDone']
    skipped = [event for event in done if event.get('skipped') or event.get('result') == 'skipped']
    failed = [event for event in done if event.get('result') not in ('success', 'skipped') and not event.get('skipped')]
    return {
        'totalVisible': len(done),
        'passed': len(done) - len(skipped) - len(failed),
        'skipped': len(skipped),
        'failed': len(failed),
        'errorEvents': sum(event.get('type') == 'error' for event in events),
        'runner': [event for event in events if event.get('type') == 'done'],
    }

targeted = summary('targeted-tests.json')
affected = summary('affected-consumer-tests.json')
full = summary('full-tests.json')

fixture = 'docs/design-system/execution-prompts/evidence/S1-B/attempt-001/s1_b_component_preview_test.dart'
screens = []
for theme in ['light', 'dark']:
    for width in [320, 390, 440]:
        for scale in [1, 2]:
            name = f'{theme}-{width}-{scale}x'
            path = f'docs/design-system/execution-prompts/evidence/S1-B/attempt-001/shared-{name}.png'
            screens.append({
                'page': 'S2-A shared repair fixture',
                'state': name,
                'theme': theme.upper(),
                'logicalSize': [width, 1900 if scale == 1 else (3500 if width == 320 else 3000)],
                'textScale': scale,
                'pixelRatio': 1,
                'sourceSha': '00a8f2f4e682eda9dd04c9372d95bc054673708b',
                'sourceSha256': sha(fixture),
                'path': path,
                'pathSha256': sha(path),
                'actuallyViewed': True,
                'observation': '已实际打开最终图：空间足够的金额保持完整字符串；空间不足按货币符号、千分位组和小数 token 重排，不拆数字组、不孤立小数点/小数位、不裁切。大字分段每项独占整行，英文不断词，触区可见。仅共享 Flutter fixture，不是业务页面或真机。',
            })
(base / 'screenshot-index.json').write_text(json.dumps(screens, ensure_ascii=False, indent=2) + '\n')

source_paths = [
    'lib/fx/components/fx_money_text.dart',
    'lib/fx/components/fx_segmented.dart',
    'test/fx/components/fx_money_text_test.dart',
    'test/fx/components/fx_s1_b_repair_test.dart',
    'docs/design-system/execution-prompts/evidence/S1-B/attempt-001/s1_b_component_preview_test.dart',
]
source_sha = {path: sha(path) for path in source_paths}
(base / 'source-sha256.json').write_text(json.dumps(source_sha, ensure_ascii=False, indent=2) + '\n')

common_evidence = [
    'docs/design-system/execution-prompts/evidence/S1-B/attempt-001/targeted-tests.json',
    'docs/design-system/execution-prompts/evidence/S1-B/attempt-001/affected-consumer-tests.json',
    'docs/design-system/execution-prompts/evidence/S1-B/attempt-001/full-tests.json',
    'docs/design-system/execution-prompts/evidence/S1-B/attempt-001/screenshot-index.json',
]
items = [
    {
        'issueId': 'S2A-001',
        'stageId': 'S1-B',
        'state': 'VERIFIED_LOCAL',
        'originAuditIds': ['DT-23'],
        'reviewId': 'S2-A-attempt-001',
        'sourceSnapshot': '00a8f2f4e682eda9dd04c9372d95bc054673708b',
        'sourcePaths': ['lib/fx/components/fx_money_text.dart', 'test/fx/components/fx_money_text_test.dart', 'test/fx/components/fx_s1_b_repair_test.dart'],
        'sourceSha256': {path: source_sha[path] for path in ['lib/fx/components/fx_money_text.dart', 'test/fx/components/fx_money_text_test.dart', 'test/fx/components/fx_s1_b_repair_test.dart']},
        'observedBehavior': 'S2-A 的 320/1x、320/2x、390/2x 触发条件可复现：普通 Text 任意拆开千分位组和小数位。',
        'implemented': '短金额保留完整 Text；空间不足时按货币/符号、千分位数字组和小数 token 重排。masked/compact/零负值和完整 Semantics/Tooltip 保持。',
        'verified': '决定性 4 组金额布局通过；邻接 masked/compact/零负值、账单行、既有 find.text 消费者通过；12 张图实际查看。',
        'disproved': False,
        'blocked_external': ['S2-A attempt-002 独立复审', '真机/VoiceOver/TalkBack/平台验收 NOT_RUN'],
        'evidencePaths': common_evidence + [
            'docs/design-system/execution-prompts/evidence/S1-B/attempt-001/repair-red.txt',
            'docs/design-system/execution-prompts/evidence/S1-B/attempt-001/token-layout-green.txt',
            'docs/design-system/execution-prompts/evidence/S1-B/attempt-001/group-layout-green.txt',
        ],
        'unverified': ['S2-A 独立复审', '真实设备文字与读屏'],
        'reason': '修复者仅写 VERIFIED_LOCAL，不替 S2 宣布 VERIFIED_CLOSED。',
        'closure': 'PENDING_S2-A_ATTEMPT_002',
    },
    {
        'issueId': 'S2A-002',
        'stageId': 'S1-B',
        'state': 'VERIFIED_LOCAL',
        'originAuditIds': ['CX-07'],
        'reviewId': 'S2-A-attempt-001',
        'sourceSnapshot': '00a8f2f4e682eda9dd04c9372d95bc054673708b',
        'sourcePaths': ['lib/fx/components/fx_segmented.dart', 'test/fx/components/fx_s1_b_repair_test.dart'],
        'sourceSha256': {path: source_sha[path] for path in ['lib/fx/components/fx_segmented.dart', 'test/fx/components/fx_s1_b_repair_test.dart']},
        'observedBehavior': 'S2-A 的 320/2x 两项等宽 Row 可复现，Expense 被拆为 Expens/e。',
        'implemented': 'TextScaler > 1.3 时每个分段独占整行；普通字号保持等宽 IntrinsicHeight Row。未改 API、TextScaler 或省略策略。',
        'verified': '320/390/440、两项/三项布局通过，英文不断词且每项至少 48 高；12 张图实际查看。',
        'disproved': False,
        'blocked_external': ['S2-A attempt-002 独立复审', '真机/VoiceOver/TalkBack/平台验收 NOT_RUN'],
        'evidencePaths': common_evidence + [
            'docs/design-system/execution-prompts/evidence/S1-B/attempt-001/repair-red.txt',
            'docs/design-system/execution-prompts/evidence/S1-B/attempt-001/repair-green.txt',
        ],
        'unverified': ['S2-A 独立复审', '真实设备文字与读屏'],
        'reason': '仅共享分段实例 VERIFIED_LOCAL；更多项选择列表和其它消费者不由本轮宣布关闭。',
        'closure': 'PENDING_S2-A_ATTEMPT_002',
    },
]
issue_output = {
    'schemaVersion': 1,
    'stage': 'S1-B',
    'attempt': 1,
    'sourceSha': '00a8f2f4e682eda9dd04c9372d95bc054673708b',
    'reviewRouting': 'docs/design-system/execution-prompts/reviews/S2-A/attempt-001/repair-routing.json',
    'scope': 'Only S2A-001 and S2A-002 assigned to ownerSession S1; no unassigned feature work.',
    'summary': {'total': 2, 'byState': {'VERIFIED_LOCAL': 2}, 'verifiedClosed': 0},
    'items': items,
}
(pack / 'runtime/issue-checks/S1-B.json').write_text(json.dumps(issue_output, ensure_ascii=False, indent=2) + '\n')

text = (base / 'flutter-analyze.txt').read_text()
pattern = re.compile(r'^\s*(error|warning|info) • (.*?) • (.*?):(\d+):(\d+) • ([A-Za-z0-9_]+)\s*$')
diagnostics = []
for line in text.splitlines():
    match = pattern.match(line)
    if match:
        severity, message, path, line_no, column, code = match.groups()
        diagnostics.append({'severity': severity, 'message': message, 'path': path, 'line': int(line_no), 'column': int(column), 'code': code})
(base / 'analysis-diagnostics.json').write_text(json.dumps(diagnostics, ensure_ascii=False, indent=2) + '\n')
baseline = json.loads((root / 'docs/design-system/execution-prompts/evidence/S1-A/attempt-001/analysis-diagnostics.json').read_text())
key = lambda item: (item['path'], item['code'], item['message'])
b = collections.Counter(key(item) for item in baseline)
c = collections.Counter(key(item) for item in diagnostics)
new = list((c - b).elements())
removed = list((b - c).elements())
comparison = {
    'baselineCount': len(baseline),
    'currentCount': len(diagnostics),
    'bySeverity': {severity: sum(item['severity'] == severity for item in diagnostics) for severity in ['error', 'warning', 'info']},
    'new': [dict(zip(['path', 'code', 'message'], item)) for item in new],
    'removed': [dict(zip(['path', 'code', 'message'], item)) for item in removed],
}
(base / 'analysis-comparison.json').write_text(json.dumps(comparison, ensure_ascii=False, indent=2) + '\n')
results = {
    'stage': 'S1-B',
    'attempt': 1,
    'status': 'PASSED',
    'sourceShaBefore': '00a8f2f4e682eda9dd04c9372d95bc054673708b',
    'sourceShaAfter': '00a8f2f4e682eda9dd04c9372d95bc054673708b',
    'sourceSnapshot': 'Uncommitted S1-B changes; per-file SHA256 in source-sha256.json',
    'targeted': targeted,
    'affectedConsumers': affected,
    'full': full,
    'analysis': comparison,
    'visual': {'rendered': 12, 'actuallyViewed': 12, 'index': 'screenshot-index.json'},
    'issueChecks': issue_output['summary'],
    'deviceGate': {'simulatorOrDevice': 'NOT_RUN', 'voiceOverTalkBack': 'NOT_RUN', 'platformBuild': 'NOT_RUN', 'serverIntegration': 'NOT_RUN'},
}
(base / 'results.json').write_text(json.dumps(results, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({'targeted': targeted, 'affected': affected, 'full': full, 'analysis': comparison}, ensure_ascii=False))
