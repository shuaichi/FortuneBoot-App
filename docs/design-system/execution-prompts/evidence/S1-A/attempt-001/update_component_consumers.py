import hashlib
import json
from pathlib import Path

root = Path.cwd()
path = root / 'docs/design-system/execution-prompts/reference/component-consumers.json'
data = json.loads(path.read_text())
data.update({
    'stage': 'S1-A',
    'sourceSha': '6061359de0d6db6597176a9158ee826de490f6c4',
    'contractState': 'FROZEN_LOCAL',
    'method': 'S1-A reviewed current Dart declarations, direct lib consumers, affected tests and real Flutter preview references; definitionSha256 identifies the current working snapshot.',
})
components = data['components']
by_symbol = {item['symbol']: item for item in components}
for item in components:
    definition = root / item['definition']
    item['definitionSha256'] = hashlib.sha256(definition.read_bytes()).hexdigest()

references = {
    'FxActionSheet': ['test/fx/components/fx_interaction_accessibility_test.dart'],
    'FxAmountInput': ['test/fx/components/fx_amount_input_test.dart'],
    'FxBarChart': ['test/fx/components/fx_chart_test.dart'],
    'FxCard': ['test/fx/components/fx_foundation_integration_test.dart'],
    'FxChip': ['test/fx/components/fx_interaction_accessibility_test.dart'],
    'FxConfirmSheet': ['test/fx/components/fx_sheet_guard_test.dart'],
    'FxDonutChart': ['test/fx/components/fx_chart_test.dart'],
    'FxLineChart': ['test/fx/components/fx_chart_test.dart'],
    'FxListItem': ['test/fx/components/fx_interaction_accessibility_test.dart'],
    'FxMoneyText': ['test/fx/components/fx_money_text_test.dart'],
    'FxSegmented': ['test/fx/components/fx_interaction_accessibility_test.dart'],
    'FxSelectRow': ['test/fx/components/fx_interaction_accessibility_test.dart', 'test/fx/components/fx_select_row_test.dart'],
    'FxSheet': ['test/fx/components/fx_sheet_guard_test.dart', 'test/fx/components/fx_sheet_test.dart'],
    'FxStateView': ['test/fx/components/fx_interaction_accessibility_test.dart'],
    'FxTagChip': ['test/fx/components/fx_interaction_accessibility_test.dart'],
    'FxTextField': ['test/fx/components/fx_amount_input_test.dart', 'test/fx/components/fx_foundation_integration_test.dart'],
    'FxBentoGrid': ['test/fx/layout/fx_bento_grid_test.dart'],
    'FxTreePicker': ['test/fx/components/fx_selection_contract_test.dart'],
    'FxFeedback': ['test/fx/components/fx_interaction_accessibility_test.dart'],
}
for symbol, refs in references.items():
    item = by_symbol[symbol]
    item['testAndPreviewReferences'] = sorted(set(item.get('testAndPreviewReferences', []) + refs + ['tool/s1_a_component_preview_test.dart']))

new_items = [
    {
        'symbol': 'FxSelectionKind',
        'definition': 'lib/fx/components/fx_option_picker.dart',
        'directConsumers': [
            'lib/features/bill_editor/presentation/bill_editor_page.dart',
            'lib/features/bill_editor/presentation/widgets/extras_section.dart',
        ],
        'consumerStages': ['S5-A'],
        'testAndPreviewReferences': ['test/fx/components/fx_selection_contract_test.dart'],
    },
    {
        'symbol': 'FxSelectionResult',
        'definition': 'lib/fx/components/fx_option_picker.dart',
        'directConsumers': [
            'lib/features/bill_editor/presentation/widgets/editor_pickers.dart',
        ],
        'consumerStages': ['S5-A'],
        'testAndPreviewReferences': ['test/fx/components/fx_selection_contract_test.dart'],
    },
    {
        'symbol': 'showFxOptionPickerResult',
        'definition': 'lib/fx/components/fx_option_picker.dart',
        'directConsumers': [
            'lib/features/bill_editor/presentation/widgets/editor_pickers.dart',
        ],
        'consumerStages': ['S5-A'],
        'testAndPreviewReferences': ['test/fx/components/fx_selection_contract_test.dart'],
    },
    {
        'symbol': 'showFxOptionPicker',
        'definition': 'lib/fx/components/fx_option_picker.dart',
        'directConsumers': [
            'lib/features/bill_editor/presentation/widgets/editor_pickers.dart',
            'lib/features/goods/presentation/widgets/goods_form_sheet.dart',
            'lib/features/recurring/presentation/recurring_editor_page.dart',
        ],
        'consumerStages': ['S5-A', 'S11-B', 'S14-A'],
        'testAndPreviewReferences': ['test/fx/components/fx_option_picker_test.dart', 'test/fx/components/fx_selection_contract_test.dart'],
    },
    {
        'symbol': 'showFxMultiOptionPicker',
        'definition': 'lib/fx/components/fx_option_picker.dart',
        'directConsumers': [
            'lib/features/bill_editor/presentation/widgets/editor_pickers.dart',
            'lib/features/recurring/presentation/recurring_editor_page.dart',
        ],
        'consumerStages': ['S5-A', 'S14-A'],
        'testAndPreviewReferences': ['test/fx/components/fx_option_picker_test.dart'],
    },
    {
        'symbol': 'FxSheetPopGuard',
        'definition': 'lib/fx/components/fx_sheet.dart',
        'directConsumers': ['lib/fx/components/fx_confirm_sheet.dart'],
        'consumerStages': ['S1-A'],
        'testAndPreviewReferences': ['test/fx/components/fx_sheet_guard_test.dart'],
    },
]
for item in new_items:
    item['definitionSha256'] = hashlib.sha256((root / item['definition']).read_bytes()).hexdigest()
    item['consumerCount'] = len(item['directConsumers'])
    by_symbol[item['symbol']] = item
components[:] = sorted(by_symbol.values(), key=lambda item: item['symbol'])
path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')
