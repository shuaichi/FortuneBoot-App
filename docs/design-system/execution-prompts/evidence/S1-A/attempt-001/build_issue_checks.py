import hashlib
import json
from pathlib import Path

root = Path.cwd()
base = 'docs/design-system/execution-prompts'
evidence = f'{base}/evidence/S1-A/attempt-001'
issues = json.loads((root / f'{base}/issues.json').read_text())['items']
selected = [item for item in issues if any(x['stage'] == 'S1-A' for x in item['instances'])]

component_paths = {
    'DS': ['lib/fx/layout/fx_bento_grid.dart', 'lib/features/dashboard/presentation/widgets/dashboard_draggable_card.dart', 'lib/features/stats/presentation/widgets/stats_layout_editor.dart'],
    'BO': ['lib/fx/components/fx_text_field.dart', 'lib/fx/components/fx_amount_input.dart'],
    'CX-01': ['lib/fx/components/fx_tag_chip.dart'],
    'CX-02': ['lib/fx/components/fx_select_row.dart'],
    'CX-03': ['lib/fx/tree/fx_tree_picker.dart'],
    'CX-04': ['lib/fx/components/fx_segmented.dart', 'lib/core/session/widgets/session_switcher_sheet.dart'],
    'CX-05': ['lib/fx/components/fx_action_sheet.dart'],
    'CX-06': ['lib/fx/components/fx_list_item.dart'],
    'CX-07': ['lib/fx/components/fx_segmented.dart', 'lib/fx/components/fx_option_picker.dart'],
    'CX-08': ['lib/fx/layout/fx_bento_grid.dart'],
    'CX-09': ['lib/fx/components/fx_state_view.dart'],
    'CX-10': ['lib/core/feedback/fx_feedback.dart', 'lib/fx/components/fx_text_field.dart'],
    'CX-11': ['lib/fx/components/fx_confirm_sheet.dart', 'lib/fx/components/fx_sheet.dart'],
    'CX-12': ['lib/fx/components/fx_line_chart.dart', 'lib/fx/components/fx_bar_chart.dart', 'lib/fx/components/fx_donut_chart.dart'],
}

disproved = {
    'DT-01': 'FxPalette 已有独立 surfaceRaised，FxSheet 与模态弹层使用该浮层表面。',
    'DT-02': '当前 canvas/surfaceMuted/surface 为可区分的中性色阶，亮暗 fixture 已查看。',
    'DT-03': '当前暗色为中性 #101012/#18181B/#202024，不再使用原蓝色底调。',
    'DT-04': '卡片 border、输入 borderStrong、分隔 separator 与图表网格 separator 已分工。',
    'DT-05': 'FxListSection 使用 separator，不再对 border 叠加 0.72 alpha。',
    'DT-06': '暗色 primary 与 onPrimary 已成对设置，现有对比测试通过。',
    'DT-07': 'danger 与 onDanger 已成对设置，现有对比测试通过。',
    'DT-08': 'ColorScheme 次级/第三级不再借用 info/warning 作为文字角色。',
    'DT-09': 'ColorScheme 已显式设置 surface 容器层级，不只设置最高层。',
    'DT-10': 'scrim 独立于 shadow，弹层使用 palette.scrim。',
    'DT-11': 'textSecondary/textTertiary 为独立中性阶，不再只有约 1.13:1 的彼此差异。',
    'DT-16': 'TextTheme 已接入 FxTypography 的完整角色，不再只改颜色。',
    'DT-17': 'display34 为 700，titleLarge22/title18 为 600，不再全部 700。',
    'DT-18': '共享正文/标签/辅助字阶为 17/15/13。',
    'DT-19': '本阶段共享组件不再使用原 9/10/11 字号；甜甜圈中心金额为 17、标题为 13。',
    'DT-20': '共享字阶保留可读的 height，不再使用标题 1.1、caption 1.3 或局部 height 1。',
    'DT-21': '金额使用系统字体 tabular figures，不引用未注册 RobotoMono。',
    'DT-22': 'FxTypography 明确 letterSpacing=0，避免默认字距进入中文。',
    'DT-24': '正文、标签、金额和次级操作按角色使用 400/500/600，不再同层全部 600。',
    'DT-26': '现有对比测试使用正确 sRGB 2.4 指数并通过。',
    'DT-27': 'FxSpacing 以 4pt 网格和 page/card/field 等用途组织，不再自称纯 8pt 序列。',
    'DT-29': '共享 pageH 为 20、sheet 标题为 17；本阶段没有新增 16 的页面导航标题。',
    'DT-30': 'FxButton 以 48 为最小高度并按内容增高，现有多行 CTA 测试和 8 图通过。',
    'DT-39': 'FxCard 默认 elevated=false，注释与当前无重阴影行为一致。',
    'DT-41': 'FxCard 的按压/焦点与表面在同一 Material 上绘制，亮暗 pressed/focus 测试通过。',
}

verified = {
    'BO-004': ('FxTextField 的框外 label 通过 MergeSemantics 与输入关联。', '保留持久 label/error，并验证字段语义。', 'test/fx/components/fx_amount_input_test.dart'),
    'BO-005': ('数字键盘 Done 与点击外部原先缺少一致结束路径。', 'FxAmountInput Done unfocus；FxTextField 默认点击外部 unfocus。', 'test/fx/components/fx_amount_input_test.dart'),
    'BO-006': ('金额粘贴货币符号/千分位原先被整体静默拒绝。', '规范化常见货币符号、空格、千分位、全角数字后校验，修正光标范围。', 'test/fx/components/fx_amount_input_test.dart'),
    'DT-12': ('用户业务色直接作为金额小字前景可能低对比。', '默认金额使用 textPrimary；显式 color 与用户业务色存储不改。', 'test/fx/components/fx_money_text_test.dart'),
    'DT-23': ('主金额默认单行 ellipsis，大字下精确值不完整。', '默认完整换行；只有显式 compactWhenNeeded 才紧凑/省略。', 'test/fx/components/fx_money_text_test.dart'),
    'DT-25': ('FxListItem/FxSelectRow 名称和值永久单行截断。', '标题、值和长 trailing 支持内容增高与上下重排。', 'test/fx/components/fx_interaction_accessibility_test.dart'),
    'DT-31': ('固定网格和控件高度无法容纳大字内容。', 'Bento 窄屏/大字转固有高度摘要清单；分段和列表内容增高。', 'test/fx/layout/fx_bento_grid_test.dart'),
    'DT-34': ('选择行清空 32 宽、树展开 40×40。', '清除至少 44×48，树展开至少 44×44。', 'test/fx/components/fx_interaction_accessibility_test.dart'),
    'DT-37': ('静态 tag 与可操作 chip 语义混淆。', '静态无按钮语义；选择/删除有命名、选中、键盘/Ink 路径。', 'test/fx/components/fx_interaction_accessibility_test.dart'),
    'DT-40': ('分段选中另加阴影，与默认无重阴影不一致。', '分段选中只用表面/文字角色，不加阴影。', 'test/fx/components/fx_interaction_accessibility_test.dart'),
    'DT-42': ('FxChip Ink 下有不透明 Container，TagChip 使用裸 GestureDetector。', '背景移到 Material；TagChip 使用 Ink/InkResponse 和 44 触区。', 'test/fx/components/fx_interaction_accessibility_test.dart'),
    'DT-43': ('Bento animationDuration 未 resolve 减少动态。', 'AnimatedSize/AnimatedPositioned 统一 FxMotion.resolve。', 'test/fx/layout/fx_bento_grid_test.dart'),
    'DT-44': ('普通卡片和回调可能重复 selection haptic。', '普通 FxCard/FxSelectRow/FxListItem 激活不再发送 selection haptic。', 'test/fx/components/fx_foundation_integration_test.dart'),
    'CX-01': ('删除图标 13px 且无命名触区，静态标签像按钮。', '删除命名包含对象、44×44 InkResponse；静态标签无按钮语义。', 'test/fx/components/fx_interaction_accessibility_test.dart'),
    'CX-02': ('SelectRow 清除目标小、固定标签列且单行值。', '44×48 字段命名清除，窄屏/大字上下重排完整值。', 'test/fx/components/fx_interaction_accessibility_test.dart'),
    'CX-03': ('树展开 40×40，长名称和搜索父路径被截断。', '展开 44×44，名称/父路径可换行，选中语义补齐。', 'test/fx/components/fx_selection_contract_test.dart'),
    'CX-05': ('ActionSheet 普通导航/复制/编辑图标全部 primary。', '普通图标 textSecondary，仅选中/危险强调。', 'test/fx/components/fx_interaction_accessibility_test.dart'),
    'CX-06': ('ListItem 主标题/副标题和 trailing 挤在同一行。', '标题换行、副标题最多 3 行，大字 trailing 下行关联。', 'test/fx/components/fx_interaction_accessibility_test.dart'),
    'CX-07': ('Segmented 等宽后单行 ellipsis，增高不能恢复名称。', '少量分段按内容增高并完整换行；更多项合同指向共享选择列表。', 'test/fx/components/fx_interaction_accessibility_test.dart'),
    'CX-08': ('Bento 固定列/行高且动画不尊重减少动态。', '窄屏/大字单列固有高度摘要清单，动画统一 resolve。', 'test/fx/layout/fx_bento_grid_test.dart'),
    'CX-09': ('StateView 空态/失败缺少对象与任务上下文。', '三种工厂支持 title，保留 message 与恢复动作。', 'test/fx/components/fx_interaction_accessibility_test.dart'),
    'CX-10': ('Feedback 拼入英文 tone.name，字段错误依赖短暂 toast。', '播报只用本地化 message，不主动替换旧提示；字段错误继续持久显示。', 'test/fx/components/fx_interaction_accessibility_test.dart'),
    'CX-11': ('ConfirmSheet 忙碌可 dismiss，失败可无可见解释。', 'FxSheetPopGuard 忙碌锁退出；失败默认本地化文案并保持打开。', 'test/fx/components/fx_sheet_guard_test.dart'),
    'CX-12': ('图表网格复用 border，中心金额 11。', '折线/柱状网格改 separator；中心金额 17、标题 13。', 'test/fx/components/fx_chart_test.dart'),
}

partial = {
    'DT-13': ('分类色只有静态亮色列表，显式财务/排名色与默认分类色并存。', 'FxChartPalette 新增 darkCategorical，FxBarChart/FxDonutChart 默认填色随亮度；显式业务色不变。', 'StatsPalette 及其它显式排名色消费者由 S8/S1-C 核对。'),
    'DT-32': ('胶囊同时高频表达状态、筛选和标签。', '共享静态 tag 与 44 触区操作 chip 已在语义和尺寸上区分。', '各页面胶囊密度与是否改列表由消费者 owner 处理。'),
    'DT-33': ('图表容器留白与小中心文字失衡。', '中心金额/标题提升为 17/13，暗色分类填色补齐。', '图表容器尺寸、图例布局与页面留白由 S8 页面 owner 验收。'),
    'DT-36': ('共享 token 与消费者局部 10/14/18 尺寸并存。', '本阶段共享触区、圆角与内容增高按 token/用途修复。', '消费者局部尺寸由 S1-C 全工程核对。'),
    'DT-45': ('多页 loading/error 把对象上下文替换成小转圈/错误。', 'FxStateView 新增可选 title 并保留恢复动作。', '未传 title 的页面消费者仍需各自迁移，未宣布全局完成。'),
    'CX-04': ('_GroupPill 约 32px 且缺少完整 button/selected/键盘路径。', '共享 FxSegmented 已补 button/selected、Ink、48 最小高度与长文本。', 'lib/core/session 的 _GroupPill 超出本阶段允许写入范围，由 S3-A 迁移。'),
}

pending = {
    'DS-021': 'Dashboard/Stats 当前仍只有拖动排序，没有上移/下移或 CustomSemanticsAction；本阶段未创建无真实调用方的共享排序协议。',
    'DS-022': '拖动时列表滚动和跨屏路径属于 Dashboard/Stats 编辑器，本阶段未改。',
    'DS-023': '统计拖动占位 72 的行为不在 lib/fx 共享组件内，本阶段未改。',
    'DS-024': '移动浏览器按下即拖与滚动竞争属于具体编辑器手势，本阶段未改。',
    'DT-14': '净资产、借贷、资产/负债页面的大面积业务色不在本阶段允许的消费者范围，未改。',
    'DT-15': '日小票费用/优惠文案样式属于 S8-B 页面，本阶段未改。',
    'DT-28': '页面、sheet、内卡多层 padding 的消费者组合未在本阶段重排。',
    'DT-35': '列表底部导航/FAB/安全区叠加属于页面消费者，本阶段未改。',
    'DT-38': '卡片标题—内卡—输入框—图标底座的页面嵌套未在本阶段重排。',
}

sha_cache = {}
def sha(path):
    if path not in sha_cache:
        sha_cache[path] = hashlib.sha256((root / path).read_bytes()).hexdigest()
    return sha_cache[path]

items = []
for issue in selected:
    issue_id = issue['id']
    paths = list(issue.get('paths', []))
    if issue_id.startswith('DS-') or issue_id.startswith('BO-'):
        paths += component_paths[issue_id.split('-')[0]]
    elif issue_id.startswith('CX-'):
        paths += component_paths[issue_id]
    else:
        paths += ['lib/fx/theme/fx_theme.dart', 'lib/fx/tokens/fx_typography.dart']
    if issue_id in verified:
        paths.append(verified[issue_id][2])
    if issue_id.startswith('DT-13'):
        paths.append('lib/fx/components/fx_chart_palette.dart')
    paths = sorted(set(paths))
    evidence_paths = [f'{evidence}/full-tests.json', f'{evidence}/flutter-analyze.txt']
    unverified = ['S2 独立审查', '真机、VoiceOver/TalkBack、平台编译与相关消费者验收']
    blocked = ['S2_INDEPENDENT_REVIEW', 'DEVICE_AND_PLATFORM_ACCEPTANCE']
    disproved_flag = False
    if issue_id in verified:
        observed, implemented, test_path = verified[issue_id]
        state = 'VERIFIED_LOCAL'
        verification = f'当前决定性测试通过：{test_path}；最终全量 521 通过、1 跳过、0 失败。'
        evidence_paths += [test_path, f'{evidence}/screenshot-index.json']
        reason = '仅 S1-A 共享实例本地验证，不代替全局 owner 或独立审查关闭。'
    elif issue_id in disproved:
        state = 'DISPROVED'
        observed = disproved[issue_id]
        implemented = '既有底座或本轮当前源码已包含反证；未为凑工作量重改。'
        verification = '当前源码 SHA、相关回归、分析以及适用的已查看 Flutter fixture 支持原审计描述在本共享实例不成立。'
        evidence_paths.append(f'{evidence}/screenshot-index.json')
        disproved_flag = True
        reason = '仅证伪原报告对当前共享实例的描述，不抹掉历史审计。'
    elif issue_id in partial:
        observed, implemented, remaining = partial[issue_id]
        state = 'IMPLEMENTED_LOCAL'
        verification = '共享改动有当前测试和/或实际 Flutter 渲染证据；消费者部分未验证。'
        unverified.append(remaining)
        reason = remaining
    else:
        state = 'CONFIRMED'
        observed = pending[issue_id]
        implemented = 'NO_S1-A_IMPLEMENTATION_OUTSIDE_ALLOWED_SHARED_SCOPE'
        verification = 'NOT_VERIFIED_CONSUMER_BEHAVIOR_UNCHANGED'
        blocked = []
        reason = '保留给对应消费者 owner；S1-A 不宣布完成，也不伪造共享能力。'
    items.append({
        'issueId': issue_id,
        'stageId': 'S1-A',
        'state': state,
        'priority': issue['priority'],
        'title': issue['title'],
        'sourcePaths': paths,
        'sourceSha256': {path: sha(path) for path in paths},
        'observedBehavior': observed,
        'implemented': implemented,
        'verified': verification,
        'disproved': disproved_flag,
        'blocked_external': blocked,
        'evidencePaths': sorted(set(evidence_paths)),
        'unverified': unverified,
        'reason': reason,
        'closure': 'PENDING_S2_INDEPENDENT_REVIEW_NO_VERIFIED_CLOSED',
    })

summary = {
    'total': len(items),
    'byState': {state: sum(item['state'] == state for item in items) for state in sorted(set(item['state'] for item in items))},
    'verifiedClosed': 0,
}
output = {
    'schemaVersion': 1,
    'stage': 'S1-A',
    'attempt': 1,
    'sourceSha': '6061359de0d6db6597176a9158ee826de490f6c4',
    'scope': '64 S1-A contributing instances; local shared contracts and behavior only, no global VERIFIED_CLOSED.',
    'summary': summary,
    'items': items,
}
(root / f'{base}/runtime/issue-checks/S1-A.json').write_text(json.dumps(output, ensure_ascii=False, indent=2) + '\n')
print(json.dumps(summary, ensure_ascii=False))
