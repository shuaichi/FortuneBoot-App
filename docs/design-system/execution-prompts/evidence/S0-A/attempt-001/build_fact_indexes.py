from pathlib import Path
import collections, hashlib, json, re, subprocess

ROOT = Path(__file__).resolve().parents[6]
PACK = ROOT / 'docs/design-system/execution-prompts'
OUT = PACK / 'evidence/S0-A/attempt-001'
HEAD = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
AUDIT_HEAD = '87f72032a4c9b98c13f5b13597c89e4cf88fa6fa'

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def owner_stage(path):
    rules = [
        ('lib/features/bill_editor/', 'S5-A'), ('lib/features/bills/', 'S4-A'),
        ('lib/features/orders/presentation/order_reconciliation_page.dart', 'S6-C'),
        ('lib/features/orders/presentation/order_detail_page.dart', 'S6-B'),
        ('lib/features/orders/', 'S6-A'), ('lib/features/dashboard/', 'S7-A'),
        ('lib/features/stats/presentation/widgets/calendar_day_summary_sheet.dart', 'S8-B'),
        ('lib/features/stats/presentation/widgets/stats_income_expense_calendar_card.dart', 'S8-B'),
        ('lib/features/stats/presentation/stats_assets_page.dart', 'S8-C'),
        ('lib/features/stats/presentation/stats_loans_page.dart', 'S8-C'),
        ('lib/features/stats/', 'S8-A'), ('lib/features/books/', 'S9-A'),
        ('lib/features/group_users/', 'S9-A'), ('lib/features/shared/invite_member_sheet.dart', 'S9-A'),
        ('lib/features/categories/', 'S10-A'), ('lib/features/tags/', 'S10-A'),
        ('lib/features/payees/', 'S10-A'), ('lib/features/members/', 'S10-A'),
        ('lib/features/manage_shared/', 'S10-A'), ('lib/features/accounts/', 'S11-A'),
        ('lib/features/goods/', 'S11-B'), ('lib/login/', 'S12-A'),
        ('lib/features/profile/presentation/app_lock_settings_page.dart', 'S13-B'),
        ('lib/features/profile/', 'S13-A'), ('lib/features/recurring/', 'S14-A'),
        ('lib/features/io/', 'S15-A'), ('lib/features/logs/', 'S15-B'),
        ('lib/core/navigation/', 'S3-A'), ('lib/core/session/', 'S3-A'),
        ('lib/core/shell/', 'S3-A'), ('lib/core/app/', 'S3-A'),
    ]
    for prefix, stage in rules:
        if path.startswith(prefix):
            return stage
    return 'S1-A'

# Component consumers: direct lib references only; tests are indexed separately.
definition_paths = sorted((ROOT / 'lib/fx').rglob('*.dart')) + [ROOT / 'lib/core/feedback/fx_feedback.dart']
lib_files = sorted((ROOT / 'lib').rglob('*.dart'))
test_files = sorted((ROOT / 'test').rglob('*.dart')) + sorted((ROOT / 'tool').rglob('*.dart'))
components = []
for definition in definition_paths:
    rel = definition.relative_to(ROOT).as_posix()
    text = definition.read_text()
    symbols = set(re.findall(r'\b(?:class|enum)\s+(Fx[A-Z][A-Za-z0-9_]*)', text))
    symbols.update(re.findall(r'\b(showFx[A-Z][A-Za-z0-9_]*)\s*\(', text))
    for symbol in sorted(symbols):
        reference = re.compile(r'\b' + re.escape(symbol) + r'(?:\s*\(|\s*\.)')
        consumers = [p.relative_to(ROOT).as_posix() for p in lib_files if p != definition and reference.search(p.read_text())]
        tests = [p.relative_to(ROOT).as_posix() for p in test_files if reference.search(p.read_text())]
        components.append({
            'symbol': symbol, 'definition': rel, 'definitionSha256': sha(definition),
            'directConsumers': consumers, 'consumerCount': len(consumers),
            'consumerStages': sorted({owner_stage(p) for p in consumers}),
            'testAndPreviewReferences': tests,
        })
component_doc = {
    'schemaVersion': 1, 'stage': 'S0-A', 'sourceSha': HEAD,
    'contractState': 'FACT_DRAFT_NOT_FROZEN',
    'method': 'Current Dart symbol declarations plus direct textual constructor/static references under lib; S1-A must review semantic use and named constructors before freezing.',
    'components': components,
}
(PACK / 'reference/component-consumers.json').write_text(json.dumps(component_doc, ensure_ascii=False, indent=2) + '\n')

issues = json.loads((PACK / 'issues.json').read_text())['items']
dt_fully_implemented = {'DT-01','DT-03','DT-06','DT-07','DT-08','DT-09','DT-10','DT-11','DT-16','DT-17','DT-20','DT-21','DT-22','DT-26','DT-27','DT-30','DT-41'}
dt_partially_implemented = {'DT-02','DT-04','DT-05','DT-14','DT-18','DT-23','DT-24','DT-25','DT-28','DT-29','DT-34','DT-36','DT-38','DT-39'}
external = {
    'DS-014': ['statistics-interval'], 'BO-060': ['mixed-currency-reconciliation'],
    'MG-U01': ['collaboration-role-contract'], 'FB-REC-03': ['recurring-template-samples'],
    'FB-REC-19': ['recurring-timezone'], 'FB-AUT-08': ['captcha-alternative-channel'],
    'FB-PRO-06': ['gender-clear-semantics'], 'FB-IO-01': ['native-file-delivery'],
}
records = []
for item in issues:
    paths = []
    for rel in item['paths']:
        path = ROOT / rel
        unchanged = subprocess.run(['git', 'diff', '--quiet', AUDIT_HEAD + '..HEAD', '--', rel], cwd=ROOT).returncode == 0
        paths.append({'path': rel, 'exists': path.exists(), 'sha256': sha(path) if path.exists() else None,
                      'unchangedSince87f7203': unchanged})
    item_external = external.get(item['id'], [])
    if item['id'] == 'BO-033':
        observed = 'PREEXISTING_FIX_PRESENT'
        implemented = 'PREEXISTING_26e959d_NOT_S0'
        verified = 'PASS_CURRENT_FULL_RUN_2_ATTACHMENT_GRID_TESTS'
        disproved = 'NOT_DISPROVED'
    elif item['id'].startswith('FB-IAP-'):
        observed = 'ENTRY_DISABLED_NOT_REPRODUCIBLE_IN_CURRENT_PRODUCT'
        implemented = 'NO_S0_IMPLEMENTATION_ENTRY_REMAINS_DISABLED'
        verified = 'CURRENT_SOURCE_FLAG_FALSE_AND_FULL_RUN_1_IAP_SKIP'
        disproved = 'CONDITIONALLY_NOT_APPLICABLE_WHILE_ENTRY_DISABLED'
    elif item_external:
        observed = 'CLIENT_FACTS_INDEXED_OWNER_BEHAVIOR_RECHECK_REQUIRED'
        implemented = 'NO_S0_IMPLEMENTATION'
        verified = 'NOT_VERIFIED_CLOSED_EXTERNAL_CONTRACT_OR_DEVICE_GAP'
        disproved = 'NOT_DISPROVED'
    elif item['id'] in dt_fully_implemented:
        observed = 'PREEXISTING_FOUNDATION_FIX_PRESENT'
        implemented = 'PREEXISTING_26e959d_NOT_S0'
        verified = 'CURRENT_SOURCE_HASH_FULL_REGRESSION_AND_PREVIEW_REVIEW_PASS'
        disproved = 'ORIGINAL_BASELINE_ISSUE_DISPROVED_ON_CURRENT_SOURCE_NOT_VERIFIED_CLOSED'
    elif item['id'] in dt_partially_implemented:
        observed = 'PREEXISTING_FOUNDATION_PARTIAL_CONSUMERS_PENDING'
        implemented = 'PREEXISTING_26e959d_PARTIAL_NOT_S0'
        verified = 'FOUNDATION_REGRESSION_PASS_CONSUMER_MIGRATION_NOT_CLOSED'
        disproved = 'PARTIALLY_DISPROVED_REMAINING_CONSUMER_INSTANCES_NOT_DISPROVED'
    elif not paths:
        observed = 'AUDIT_TEXT_AND_GLOBAL_COMPONENT_FACTS_INDEXED_OWNER_RECHECK_REQUIRED'
        implemented = 'NO_S0_IMPLEMENTATION'
        verified = 'FULL_REGRESSION_AND_PREVIEW_REVIEW_NOT_ITEM_CLOSURE'
        disproved = 'NOT_DISPROVED'
    elif any(not p['unchangedSince87f7203'] for p in paths):
        observed = 'RELATED_SOURCE_CHANGED_AFTER_AUDIT_OWNER_RECHECK_REQUIRED'
        implemented = 'PREEXISTING_BASELINE_CHANGE_ONLY_NO_S0_IMPLEMENTATION'
        verified = 'FULL_REGRESSION_PASS_NOT_ITEM_CLOSURE'
        disproved = 'NOT_DISPROVED'
    else:
        observed = 'REFERENCED_SOURCE_UNCHANGED_BEHAVIOR_PENDING_OWNER_RECHECK'
        implemented = 'NO_S0_IMPLEMENTATION'
        verified = 'NOT_ITEM_VERIFIED_FULL_REGRESSION_ONLY'
        disproved = 'NOT_DISPROVED'
    records.append({
        'id': item['id'], 'priority': item['priority'], 'title': item['title'],
        'source': item['source'], 'sourceLine': item['line'],
        'primaryStage': item['primaryStage'], 'contributingStages': item['contributingStages'],
        'mappingVerified': True, 'paths': paths,
        'observed': observed, 'implemented': implemented, 'verified': verified,
        'disproved': disproved, 'blocked_external': item_external,
        'closure': 'PENDING_OWNER_AND_INDEPENDENT_REVIEW',
    })
summary = {
    'total': len(records),
    'module': sum(not r['id'].startswith(('DT-', 'CX-')) for r in records),
    'DT': sum(r['id'].startswith('DT-') for r in records),
    'CX': sum(r['id'].startswith('CX-') for r in records),
    'verifiedClosed': 0,
    'preexistingFixBehaviorVerified': sum(r['verified'] == 'PASS_CURRENT_FULL_RUN_2_ATTACHMENT_GRID_TESTS' for r in records),
    'conditionalEntryDisabled': sum(r['id'].startswith('FB-IAP-') for r in records),
    'preexistingFoundationFixes': len(dt_fully_implemented),
    'preexistingFoundationPartials': len(dt_partially_implemented),
    'externalLinked': sum(bool(r['blocked_external']) for r in records),
    'byObserved': dict(collections.Counter(r['observed'] for r in records)),
}
issue_doc = {
    'schemaVersion': 1, 'stage': 'S0-A', 'attempt': 1, 'sourceSha': HEAD,
    'scope': '334-item triage and source/index verification; S0 has no primary or contributing issue owner assignment and does not close owner behavior items.',
    'summary': summary, 'items': records,
}
(PACK / 'runtime/issue-checks/S0-A.json').write_text(json.dumps(issue_doc, ensure_ascii=False, indent=2) + '\n')
(OUT / 'fact-index-summary.json').write_text(json.dumps({'components': len(components), 'componentConsumerEdges': sum(c['consumerCount'] for c in components), 'issues': summary}, ensure_ascii=False, indent=2) + '\n')
print(json.dumps({'components': len(components), 'issues': summary}, ensure_ascii=False, indent=2))
