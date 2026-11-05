# S2-A attempt-003 验证命令

工作目录均为仓库根，Flutter 3.41.9 / Dart 3.11.5。未升级 SDK/依赖，未修改业务源码或既有测试。

| 命令/范围 | 退出码 | 证据 |
| --- | ---: | --- |
| `flutter --version` | 0 | `flutter-version.txt` |
| `python3 docs/design-system/execution-prompts/tools/validate_pack.py --runtime` | 0 | `pack-validation-before.txt` |
| `flutter test --no-pub --reporter json test/fx test/features/bill_editor/presentation/bill_editor_order_flow_test.dart` | 0 | `decisive-tests.json`：73 realTests 全通过 |
| 金额/选择行/分段独立复审探针 | 0 | `review-probes.json`：4 realTests 全通过 |
| 共享组件渲染探针 | 0 | `visual-render.json`：12 realTests，12 PNG |
| 弹层探针 | 0 | `modal-probe.json`：2 realTests 全通过 |
| 十个业务消费者目录 | 0 | `affected-consumer-tests.json`：176 realTests 全通过 |
| 全量 `flutter test --no-pub --reporter json` | 0 | `full-tests.json`：424 realTests，423 通过、1 跳过 |
| 最终 `flutter analyze --no-pub` | 1 | `flutter-analyze.txt`：1159，基线新增/移除均 0 |

全量计数口径：424 realTests＝423 通过＋1 跳过；534 testDone events＝424 realTests＋106 loading＋4 lifecycle。IAP 跳过保留，未启用入口。

13 张 PNG 均实际打开查看，索引见 `screenshot-index.json`。真机、VoiceOver/TalkBack、平台编译和真实接口均 NOT_RUN。
