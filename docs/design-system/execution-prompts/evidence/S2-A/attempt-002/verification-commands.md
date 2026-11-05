# S2-A attempt-002 验证命令

工作目录均为仓库根，Flutter 3.41.9 / Dart 3.11.5。未升级 SDK/依赖。

| 命令/范围 | 退出码 | 证据 |
| --- | ---: | --- |
| `flutter --version` | 0 | `flutter-version.txt` |
| `python3 docs/design-system/execution-prompts/tools/validate_pack.py --runtime` | 0 | `pack-validation-before.txt` |
| `flutter test --no-pub --reporter json test/fx test/features/bill_editor/presentation/bill_editor_order_flow_test.dart` | 0 | `decisive-tests.json`：73 realTests 全通过 |
| 共享组件渲染探针 | 0 | `visual-render.json`：12 realTests，12 PNG |
| 弹层探针 | 0 | `modal-probe.json`：2 realTests；首次审批服务 429 未执行，重试成功 |
| 小数独立探针 | **1（预期复现开放缺陷）** | `decimal-reprobe.json`：390/440 两项均失败 |
| 分段独立探针（首次） | 1 | `segmented-reprobe.json`：探针语义定位 No element |
| 分段独立探针（最终） | 0 | `segmented-reprobe-final.json`：48 触区和点击通过 |
| 十个业务消费者目录 | 0 | `affected-consumer-tests.json`：176 realTests 全通过 |
| 全量 `flutter test --no-pub --reporter json` | 0 | `full-tests.json`：424 realTests，423 通过、1 跳过 |
| 选择行探针（首次） | 1 | `select-row-reprobe.json`：探针缺少 S.delegate |
| 选择行探针（最终） | **1（确认开放缺陷）** | `select-row-reprobe-final.json`：Counterparty 两个行 top |
| 最终 `flutter analyze --no-pub` | 1 | `flutter-analyze-final.txt`：1159，基线新增/移除均 0 |

全量计数口径：424 realTests＝423 通过＋1 跳过；534 testDone events＝424 realTests＋106 loading＋4 lifecycle。IAP 跳过保留，未启用入口。
