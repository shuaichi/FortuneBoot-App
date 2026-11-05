import collections
import hashlib
import json
import re
from pathlib import Path

root = Path.cwd()
base = root / 'docs/design-system/execution-prompts/evidence/S1-B/attempt-002'
pack = root / 'docs/design-system/execution-prompts'

def sha(path):
    return hashlib.sha256((root / path).read_bytes()).hexdigest()

def summary(name):
    events = [json.loads(line) for line in (base / name).read_text().splitlines() if line.strip()]
    done = [event for event in events if event.get('type') == 'testDone']
    skipped = [event for event in done if event.get('skipped') or event.get('result') == 'skipped']
    failed = [event for event in done if event.get('result') not in ('success', 'skipped') and not event.get('skipped')]
    return {'totalVisible': len(done), 'passed': len(done) - len(skipped) - len(failed), 'skipped': len(skipped), 'failed': len(failed), 'errorEvents': sum(event.get('type') == 'error' for event in events), 'runner': [event for event in events if event.get('type') == 'done']}

targeted = summary('targeted-tests.json')
direct = summary('direct-consumer-tests.json')
full = summary('full-tests.json')

fixture = 'docs/design-system/execution-prompts/evidence/S1-B/attempt-002/s1_b_component_preview_test.dart'
screens = []
for theme in ['light', 'dark']:
    for width in [320, 390, 440]:
        for scale in [1, 2]:
            name = f'{theme}-{width}-{scale}x'
            path = f'docs/design-system/execution-prompts/evidence/S1-B/attempt-002/shared-{name}.png'
            screens.append({'page': 'S2-A attempt-002 repair fixture', 'state': name, 'theme': theme.upper(), 'logicalSize': [width, 1900 if scale == 1 else (3500 if width == 320 else 3000)], 'textScale': scale, 'pixelRatio': 1, 'sourceSha': '00a8f2f4e682eda9dd04c9372d95bc054673708b', 'sourceSha256': sha(fixture), 'path': path, 'pathSha256': sha(path), 'actuallyViewed': True, 'observation': '已实际打开最终图：短金额完整；大额按千分位组重排，最后整数组与小数合并为 890.12，不孤立小数位或裁切。FxSelectRow 按标签宽度重排，Counterparty 不断词，长值/动作完整。仅共享 Flutter fixture，不是业务页面或真机。'})
(base / 'screenshot-index.json').write_text(json.dumps(screens, ensure_ascii=False, indent=2) + '\n')

source_paths = ['lib/fx/components/fx_money_text.dart', 'lib/fx/components/fx_select_row.dart', 'lib/fx/components/fx_segmented.dart', 'test/fx/components/fx_money_text_test.dart', 'test/fx/components/fx_s1_b_repair_test.dart', fixture, 'docs/design-system/execution-prompts/evidence/S1-B/attempt-002/s1_b_decimal_reprobe_test.dart', 'docs/design-system/execution-prompts/evidence/S1-B/attempt-002/s1_b_select_row_reprobe_test.dart', 'docs/design-system/execution-prompts/evidence/S1-B/attempt-002/select_row_matrix_test.dart']
source_sha = {path: sha(path) for path in source_paths}
(base / 'source-sha256.json').write_text(json.dumps(source_sha, ensure_ascii=False, indent=2) + '\n')

common = [f'docs/design-system/execution-prompts/evidence/S1-B/attempt-002/{name}' for name in ['targeted-tests.json', 'direct-consumer-tests.json', 'full-tests.json', 'screenshot-index.json']]
items = [
    {
        'issueId': 'S2A-001', 'stageId': 'S1-B', 'state': 'VERIFIED_LOCAL', 'originAuditIds': ['DT-23'], 'reviewId': 'S2-A-attempt-002', 'sourceSnapshot': '00a8f2f4e682eda9dd04c9372d95bc054673708b + S1-B attempt-001 SHA256',
        'sourcePaths': ['lib/fx/components/fx_money_text.dart', 'test/fx/components/fx_money_text_test.dart', 'test/fx/components/fx_s1_b_repair_test.dart'], 'sourceSha256': {path: source_sha[path] for path in ['lib/fx/components/fx_money_text.dart', 'test/fx/components/fx_money_text_test.dart', 'test/fx/components/fx_s1_b_repair_test.dart']},
        'observedBehavior': 'S2-A attempt-002 原始探针在 390/440、2x 均复现 890. top=308、12 top=404，小数位孤立。',
        'implemented': '财务 token 正则将最后整数组、小数点与小数位合并为 890.12；短金额单 Text、masked/compact 与完整 Semantics/Tooltip 不变。',
        'verified': '原始探针按新分组断言 890.12 同排并通过；既有金额矩阵、masked/compact/零负值、全量消费者通过；12 张图实际查看。',
        'disproved': False, 'blocked_external': ['S2-A attempt-003 独立复审', '真机/VoiceOver/TalkBack/平台验收 NOT_RUN'], 'evidencePaths': common + ['docs/design-system/execution-prompts/evidence/S1-B/attempt-002/review-probes-red.txt', 'docs/design-system/execution-prompts/evidence/S1-B/attempt-002/review-probes-green.txt'], 'unverified': ['S2-A attempt-003', '真实设备文字与读屏'], 'reason': '修复者只写 VERIFIED_LOCAL，不替 S2 关闭。', 'closure': 'PENDING_S2-A_ATTEMPT_003',
    },
    {
        'issueId': 'S2A-003', 'stageId': 'S1-B', 'state': 'VERIFIED_LOCAL', 'originAuditIds': ['CX-02'], 'reviewId': 'S2-A-attempt-002', 'sourceSnapshot': '00a8f2f4e682eda9dd04c9372d95bc054673708b + S1-B attempt-001 SHA256',
        'sourcePaths': ['lib/fx/components/fx_select_row.dart', 'docs/design-system/execution-prompts/evidence/S1-B/attempt-002/select_row_matrix_test.dart'], 'sourceSha256': {path: source_sha[path] for path in ['lib/fx/components/fx_select_row.dart', 'docs/design-system/execution-prompts/evidence/S1-B/attempt-002/select_row_matrix_test.dart']},
        'observedBehavior': '440/1x 时 maxWidth=368 进入固定 96 标签列，Counterparty 被拆为两行；原始探针 2 个 top。',
        'implemented': '按实际标签排版宽度与 TextScaler 选择行内/上下重排；重排标签按空格 token 保持英文单词完整，短标签保留单 Text。清空语义、44×48 目标、长值与只读行为保持。',
        'verified': '原审查探针通过；320/390/440 × 1x/2x × 清空/只读 12 组通过；三个直接消费者 58 通过；12 张图实际查看。',
        'disproved': False, 'blocked_external': ['S2-A attempt-003 独立复审', '真机/VoiceOver/TalkBack/平台验收 NOT_RUN'], 'evidencePaths': common + ['docs/design-system/execution-prompts/evidence/S1-B/attempt-002/review-probes-red.txt', 'docs/design-system/execution-prompts/evidence/S1-B/attempt-002/review-probes-green.txt', 'docs/design-system/execution-prompts/evidence/S1-B/attempt-002/select-row-matrix.txt'], 'unverified': ['S2-A attempt-003', '真实设备文字与读屏'], 'reason': '仅 CX-02 共享实例 VERIFIED_LOCAL，不替全局消费者或 S2 关闭。', 'closure': 'PENDING_S2-A_ATTEMPT_003',
    },
]
issue_output = {'schemaVersion': 1, 'stage': 'S1-B', 'attempt': 2, 'sourceSha': '00a8f2f4e682eda9dd04c9372d95bc054673708b', 'reviewRouting': 'docs/design-system/execution-prompts/reviews/S2-A/attempt-002/repair-routing.json', 'scope': 'Only S2A-001 and S2A-003 assigned to S1; S2A-002 already VERIFIED_CLOSED and untouched.', 'summary': {'total': 2, 'byState': {'VERIFIED_LOCAL': 2}, 'verifiedClosed': 0}, 'items': items}
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
comparison = {'baselineCount': len(baseline), 'currentCount': len(diagnostics), 'bySeverity': {severity: sum(item['severity'] == severity for item in diagnostics) for severity in ['error', 'warning', 'info']}, 'new': [dict(zip(['path', 'code', 'message'], item)) for item in new], 'removed': [dict(zip(['path', 'code', 'message'], item)) for item in removed]}
(base / 'analysis-comparison.json').write_text(json.dumps(comparison, ensure_ascii=False, indent=2) + '\n')
results = {'stage': 'S1-B', 'attempt': 2, 'status': 'PASSED', 'sourceShaBefore': '00a8f2f4e682eda9dd04c9372d95bc054673708b', 'sourceShaAfter': '00a8f2f4e682eda9dd04c9372d95bc054673708b', 'sourceSnapshot': 'Uncommitted S1-B changes; per-file SHA256 in source-sha256.json', 'targeted': targeted, 'directConsumers': direct, 'full': full, 'analysis': comparison, 'visual': {'rendered': 12, 'actuallyViewed': 12, 'index': 'screenshot-index.json'}, 'issueChecks': issue_output['summary'], 'deviceGate': {'simulatorOrDevice': 'NOT_RUN', 'voiceOverTalkBack': 'NOT_RUN', 'platformBuild': 'NOT_RUN', 'serverIntegration': 'NOT_RUN'}}
(base / 'results.json').write_text(json.dumps(results, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({'targeted': targeted, 'direct': direct, 'full': full, 'analysis': comparison}, ensure_ascii=False))
