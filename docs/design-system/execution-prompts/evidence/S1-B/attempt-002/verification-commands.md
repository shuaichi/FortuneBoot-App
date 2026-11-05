# S1-B attempt-002 验证命令

```sh
flutter test --no-pub docs/design-system/execution-prompts/evidence/S1-B/attempt-002/s1_b_decimal_reprobe_test.dart docs/design-system/execution-prompts/evidence/S1-B/attempt-002/s1_b_select_row_reprobe_test.dart
# 原始 RED：390/440 小数孤立、440/1x Counterparty 断词；最终 GREEN

flutter test --no-pub docs/design-system/execution-prompts/evidence/S1-B/attempt-002/select_row_matrix_test.dart
# 12 组选择行矩阵通过：320/390/440 × 1x/2x × 清空/只读

flutter test --no-pub docs/design-system/execution-prompts/evidence/S1-B/attempt-002/s1_b_component_preview_test.dart
# exit 0；12 张真实 Flutter 图，全部实际查看

flutter test --no-pub --reporter json test/fx test/core/money test/core/errors
# exit 0；87 passed / 0 failed / 0 skipped

flutter test --no-pub --reporter json test/features/bill_editor test/features/recurring test/features/goods
# exit 0；58 passed / 0 failed / 0 skipped

flutter test --no-pub --reporter json
# exit 0；534 total / 533 passed / 1 skipped / 0 failed / 0 error events

flutter analyze --no-pub
# exit 1；1159 = 0 error / 252 warning / 907 info；新增 0、移除 0

python3 docs/design-system/execution-prompts/tools/validate_pack.py
# 最终包结构、runtime、ID 校验
```

原始 JSON、RED/GREEN、截图索引、分析差异和源码 SHA 均在本目录。IAP 的 `success + skipped=true` 单独计为跳过。
