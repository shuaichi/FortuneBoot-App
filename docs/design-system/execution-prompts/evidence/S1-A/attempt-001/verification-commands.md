# S1-A attempt-001 验证命令

```sh
flutter --version
# exit 0；Flutter 3.41.9 / Dart 3.11.5

python3 docs/design-system/execution-prompts/tools/validate_pack.py
# exit 0；提示词包结构校验，不等于实现验收

flutter test --no-pub --reporter json test/fx test/core/money test/core/errors
# exit 0；76 passed / 0 failed / 0 skipped

flutter test --no-pub --reporter json test/features/bill_editor test/features/recurring
# exit 0；54 passed / 0 failed / 0 skipped

flutter test --no-pub --reporter json
# exit 0；523 total / 522 passed / 1 skipped / 0 failed / 0 error events

flutter analyze --no-pub
# exit 1；1159 = 0 error / 252 warning / 907 info；与基线新增 0、移除 0

flutter test --no-pub tool/s1_a_component_preview_test.dart
# exit 0；8 张真实 Flutter fixture，8 张均已实际查看

python3 docs/design-system/execution-prompts/tools/validate_pack.py
# exit 0；最终 runtime/路径/ID 结构校验
```

原始 JSON、文本日志、RED/GREEN、截图索引和源码 SHA 均在本目录。`testDone.result=success` 且 `skipped=true` 的 IAP 项单独计为跳过，没有计入通过。
