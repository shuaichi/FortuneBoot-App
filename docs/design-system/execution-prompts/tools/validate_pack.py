#!/usr/bin/env python3
"""Validate staged prompt coverage and artifacts; never mark a stage passed."""
from pathlib import Path
import argparse
import collections
import hashlib
import json
import re
import sys

PACK = Path(__file__).resolve().parents[1]
ROOT = PACK.parents[2]
AUDIT = PACK.parent


def load(path):
    return json.loads(path.read_text())


def require(condition, message):
    if not condition:
        raise ValueError(message)


def audit_ids():
    found = []
    patterns = {
        'audit-dashboard-stats.md': r'^\*\*(DS-\d+)\s',
        'audit-management.md': r'^### (MG-[A-Z]\d+)\s',
        'audit-bills-orders.md': r'^### (BO-\d+)\s',
        'audit-system.md': r'^### (FB-[A-Z]+-\d+)\s',
        '2026-11-05-global-audit.md': r'^\| (DT-\d+) P\d|^- \*\*(CX-\d+) P\d',
    }
    for filename, pattern in patterns.items():
        for match in re.finditer(pattern, (AUDIT / filename).read_text(), re.M):
            found.extend(group for group in match.groups() if group)
    require(len(found) == len(set(found)) == 334, 'Source audit IDs changed or duplicated')
    return set(found)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--runtime', action='store_true', help='Also check produced stage artifacts')
    parser.add_argument('--generation-baseline', action='store_true', help='Verify this prompt-generation turn did not change business source')
    args = parser.parse_args()
    plan = load(PACK / 'stage-map.json')
    issues = load(PACK / 'issues.json')
    progress = load(PACK / 'runtime/progress.json')
    stages = plan['stages']
    repairs = plan['conditionalRepairs']
    all_stages = {stage['id']: stage for stage in stages + repairs}
    order = [stage['id'] for stage in stages]
    require(len(stages) == 28 and len(repairs) == 16, 'Expected 28 main + 16 conditional prompts')
    require(len(all_stages) == 44, 'Duplicate stage IDs')
    require(order == plan['mainSequence'], 'Main sequence differs from stage list')
    require(order[0] == 'S0-A' and order[-1] == 'S0-B', 'Missing entry or final delivery')
    require(order.index('S1-C') > order.index('S15-B'), 'Shared integration is too early')
    require(order.index('S2-B') > order.index('S1-C'), 'Review is before integration')
    require(set(all_stages) == set(progress['stages']), 'Progress omits or invents stages')
    indexed = {item['id']: item for item in issues['items']}
    require(len(indexed) == issues['total'] == 334, 'Issue IDs missing or duplicated')
    require(set(indexed) == audit_ids(), 'Mapping does not exactly cover source audits')
    primary = collections.Counter()
    for stage in stages:
        require(stage['session'] == stage['id'].split('-')[0], 'Session does not match ID')
        for predecessor in stage['requires']:
            require(predecessor in order and order.index(predecessor) < order.index(stage['id']),
                    'Forward/cyclic main dependency: ' + stage['id'])
        primary.update(stage['primaryIssues'])
        for issue_id in stage['primaryIssues']:
            require(indexed[issue_id]['primaryStage'] == stage['id'], 'Owner mismatch: ' + issue_id)
        for issue_id in stage['contributingIssues']:
            require(stage['id'] in indexed[issue_id]['contributingStages'], 'Contributor mismatch')
        content = (PACK / stage['prompt']).read_text()
        for phrase in ['本轮只执行', '不commit', '决定性验证', '视觉证据与验收', '停止', 'runtime/progress.json']:
            require(phrase in content, stage['id'] + ': missing ' + phrase)
        for issue_id in stage['primaryIssues'] + stage['contributingIssues']:
            require('| ' + issue_id + ' |' in content, stage['id'] + ': issue omitted from prompt')
        if stage['session'] == 'S2':
            require(stage['kind'] == 'review', 'Reviewer assigned implementation')
            require('业务源码、测试源码' in content and '只读' in content, 'Review write boundary missing')
    require(set(primary) == set(indexed) and all(value == 1 for value in primary.values()),
            'Every audit ID must have exactly one primary owner')
    for issue_id, item in indexed.items():
        require(item['primaryStage'] in order, 'Unknown primary owner')
        expected = {item['primaryStage'], *item['contributingStages']}
        require(expected == {entry['stage'] for entry in item['instances']}, 'Instance coverage mismatch')
        require(item['repairPrompt'] in all_stages, 'Missing owner repair prompt')
        for contributor in item['contributingStages']:
            require(contributor in order, 'Unknown contributor')
    for repair in repairs:
        require(repair['id'].split('-')[0] == repair['session'], 'Repair returns to wrong session')
        require(repair['trigger'] and repair['returnTo'], 'Repair missing trigger/return')
        require((PACK / repair['prompt']).exists(), 'Missing repair prompt')
    for path in PACK.rglob('*.md'):
        if any(part in ['evidence', 'handoff', 'reviews'] for part in path.relative_to(PACK).parts):
            continue
        content = path.read_text()
        require(len(re.findall(r'^```', content, re.M)) % 2 == 0, 'Unclosed code fence: ' + str(path))
        require(not re.search(r'\bTBD\b|TODO|待补充提示词|此处省略', content), 'Unfinished content: ' + str(path))
        for angle, plain in re.findall(r'\]\((?:<([^>]+)>|([^\)]+))\)', content):
            target = angle or plain
            if target.startswith(('http:', 'https:', '#')):
                continue
            target = re.sub(r':\d+$', '', target.split('#')[0])
            destination = Path(target)
            if not destination.is_absolute():
                destination = path.parent / destination
            require(destination.exists(), 'Broken link: ' + str(path) + ' -> ' + target)
    bundle = (PACK / 'ALL-PROMPTS.md').read_text()
    for stage in stages + repairs:
        require((PACK / stage['prompt']).read_text() in bundle, 'Bundle drift: ' + stage['id'])
    known_states = {'NOT_STARTED', 'IN_PROGRESS', 'PASSED', 'PARTIAL', 'FAILED', 'BLOCKED', 'NOT_REQUIRED'}
    for stage_id, state in progress['stages'].items():
        require(state['status'] in known_states, 'Unknown execution state: ' + stage_id)
        if args.runtime and state['status'] in {'PASSED', 'PARTIAL', 'FAILED', 'BLOCKED'}:
            handoff = PACK / 'handoff' / (stage_id + '.md')
            require(handoff.exists(), 'Executed stage lacks handoff: ' + stage_id)
            require(bool(state['evidence']), 'Executed stage lacks evidence: ' + stage_id)
            for evidence in state['evidence']:
                target = Path(evidence)
                if not target.is_absolute():
                    target = PACK / evidence
                require(target.exists(), 'Missing evidence: ' + str(target))
            if state['status'] == 'PASSED':
                require(state['localGate'] == 'PASSED', 'PASSED hides unpassed local gate: ' + stage_id)
                require(state['visualGate'] in {'PASSED', 'NOT_APPLICABLE'}, 'PASSED hides unreviewed visuals')
    if args.generation_baseline:
        baseline = load(PACK / 'reference/generation-baseline.json')
        changed = []
        for filename, expected_hash in baseline['productionAndTestHashes'].items():
            path = ROOT / filename
            if not path.exists() or hashlib.sha256(path.read_bytes()).hexdigest() != expected_hash:
                changed.append(filename)
        require(not changed, 'Business source changed since pack generation; use --runtime after execution: ' + ', '.join(changed[:8]))
        for filename, expected_hash in baseline['auditSourceHashes'].items():
            require(hashlib.sha256((AUDIT / filename).read_bytes()).hexdigest() == expected_hash,
                    'Original audit artifact changed: ' + filename)
    print('PASS: 28 main + 16 conditional prompts; 334 audit IDs; unique owners and complete instances')
    print('PASS: dependencies, return sessions, review boundaries, links and complete bundle')
    if args.runtime:
        print('PASS: executed-stage artifact records')
    if args.generation_baseline:
        print('PASS: original lib/test/tool and audit artifacts unchanged')
    counts = collections.Counter(state['status'] for state in progress['stages'].values())
    print('Stage states:', dict(counts))
    print('This validates prompt artifacts only; it does not execute or approve any implementation stage.')


if __name__ == '__main__':
    try:
        main()
    except (ValueError, KeyError, OSError, json.JSONDecodeError) as error:
        print('FAIL:', error, file=sys.stderr)
        sys.exit(1)
