# S2-A attempt-001 验证命令

所有命令工作目录均为仓库根。Flutter 首次沙箱运行因 SDK `engine.stamp` 权限退出 1；按环境要求申请权限后复跑，未删除 SDK 锁、未升级工具链。

| 命令 | 退出码 | 证据 |
| --- | ---: | --- |
| `flutter --version` | 0 | `flutter-version.txt` |
| `python3 docs/design-system/execution-prompts/tools/validate_pack.py --runtime` | 0 | `pack-validation-before-runtime.txt`（runtime 更新前） |
| `flutter test --no-pub --reporter json test/fx test/features/bill_editor/presentation/bill_editor_order_flow_test.dart` | 0 | `decisive-tests.json` / `decisive-tests-summary.json` |
| `flutter test --no-pub --reporter json docs/.../s2_a_component_preview_test.dart` | 0 | `visual-render.json` / `visual-render-summary.json` |
| `flutter test --no-pub --reporter json docs/.../s2_a_modal_probe_test.dart`（首次） | 0 | `modal-probe.json` |
| `flutter test --no-pub --reporter json test/features/bill_editor test/features/recurring` | 0 | `affected-consumer-tests.json` / 对应 summary |
| `flutter test --no-pub --reporter json` | 0 | `full-tests.json` / `full-tests-summary.json` |
| `flutter analyze --no-pub`（首次） | 1 | `flutter-analyze.txt`：1160，含探针自身 1 info |
| `flutter test --no-pub --reporter json docs/.../s2_a_modal_probe_test.dart`（探针 lint 修正后） | 0 | `modal-probe-final.json` / 对应 summary |
| `flutter analyze --no-pub`（最终） | 1 | `flutter-analyze-final.txt`：1159；0 error，基线新增/移除均 0 |
| `git diff --check 6061359de0d6db6597176a9158ee826de490f6c4..HEAD` | 2 | 已提交文档/历史证据空白，未修改这些只读材料 |

最终全量测试计数：414 realTests＝413 通过＋1 跳过；523 testDone events＝414 realTests＋105 loading＋4 lifecycle。`full-tests.json` runner `success=true`，无 error event。
