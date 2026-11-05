# S3-A attempt-001 验证命令

工作目录 `/Users/zhangchi118/代码/FortuneBoot-App`，Flutter 3.41.9 / Dart 3.11.5。

| 命令 | 退出码 | 结果 |
| --- | --- | --- |
| `flutter test --no-pub test/core/navigation test/core/session test/core/shell --reporter json` | 0 | 41 个真实测试，41 通过，0 跳过，0 失败；runner success=true。日志 `decisive-tests.json`。 |
| `flutter test --no-pub --reporter json` | 0 | 450 个真实测试，449 通过，1 跳过，0 失败；runner success=true。唯一跳过仍为既有 Apple IAP donation 测试。日志 `full-tests.json`。 |
| `flutter test --no-pub docs/design-system/execution-prompts/evidence/S3-A/attempt-001/s3_a_shell_render_test.dart` | 0 | 12 个主壳渲染 fixture 全部通过；12 张 PNG 输出到本目录。 |
| `flutter analyze --no-pub` | 1 | 1179 诊断：0 error、260 warning、919 info；与 HEAD 临时副本 1183（0/260/923）相比 0 新增 warning/error，减少 4 条既有 `prefer_final_locals` info。日志 `flutter-analyze.txt`、`analysis-comparison.json`。 |
| `python3 docs/design-system/execution-prompts/tools/validate_pack.py` | 0 | 提示词包结构与 334 个审计 ID 校验通过；不代表实现验收。日志 `pack-validation.txt`。 |
| `git diff --check` | 0 | 无空白错误。 |

说明：`flutter analyze` 非零退出是既有诊断基线，不代表本阶段新增 error；本阶段源码文件无 error/warning。
