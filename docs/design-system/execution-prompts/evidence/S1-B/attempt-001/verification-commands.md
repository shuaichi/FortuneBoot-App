# S1-B attempt-001 验证命令

```sh
flutter test --no-pub test/fx/components/fx_s1_b_repair_test.dart
# 初始 RED：两项审查问题复现；最终 GREEN：布局矩阵通过

flutter test --no-pub docs/design-system/execution-prompts/evidence/S1-B/attempt-001/s1_b_component_preview_test.dart
# exit 0；12 张真实 Flutter 图，全部实际查看

flutter test --no-pub --reporter json test/fx test/core/money test/core/errors
# exit 0；87 passed / 0 failed / 0 skipped

flutter test --no-pub --reporter json test/features/bill_editor test/features/recurring test/features/orders test/features/stats test/features/books test/features/goods test/features/manage_shared test/features/accounts test/features/dashboard test/features/bills
# exit 0；225 passed / 0 failed / 0 skipped

flutter test --no-pub --reporter json
# exit 0；534 total / 533 passed / 1 skipped / 0 failed / 0 error events

flutter analyze --no-pub
# exit 1；1159 = 0 error / 252 warning / 907 info；新增 0、移除 0

python3 docs/design-system/execution-prompts/tools/validate_pack.py
# 最终包结构、runtime、ID 校验
```

原始 JSON、RED/GREEN、被证伪方案、截图索引和源码 SHA 均在本目录。测试计数按 testDone 事件，IAP 的 `success + skipped=true` 单独计为跳过。
