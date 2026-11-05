# S4-B attempt-001 验证命令与结果

Flutter 3.41.9 / Dart 3.11.5；未升级依赖或 SDK，未写真实账务数据。

| 命令 | 退出码 | 结果 |
| --- | --- | --- |
| `flutter test --no-pub --reporter json test/features/shared/presentation/bills test/features/bills/presentation/widgets/bill_tile_test.dart`（基线） | 0 | 17 通过、0 失败、0 跳过；`baseline-tests.json`。 |
| 同命令（最终决定性） | 0 | 34 通过、0 失败、0 跳过；`decisive-tests-final-008.json`。 |
| `flutter test --no-pub --reporter json`（最终全量） | 0 | 602 个真实测试，601 通过、1 跳过、0 失败；唯一跳过既有 Apple IAP donation；`full-tests-final-007.json`、`full-test-summary.json`。 |
| `flutter test --no-pub --reporter json docs/design-system/execution-prompts/evidence/S4-B/attempt-001/s4_b_detail_render_test.dart` | 0 | 10 个真实详情渲染场景通过；runner 含 setUp/tearDown 共 13 个测试事件；`render-tests-final-005.json`。 |
| `flutter analyze --no-pub`（最终） | 1 | 1174＝0 error / 260 warning / 914 info；`flutter-analyze-final-007.txt`。 |
| S4-A 诊断多重集比较 | 0 | 基线 1175＝0/260/919；无新增，减少 1 条既有 info；`analysis-comparison.json`。 |
| `git diff --check` | 0 | 无空白错误。 |
| 模拟器 `flutter run --debug --no-pub --no-resident -t .../s4_b_simulator_app.dart` | 0 | 隔离真实 BillDetailFlow＋虚构账单/附件构建启动；亮色、暗色、系统最大无障碍字号实际查看。 |
| 生产入口恢复 `flutter run --debug --no-pub --no-resident` | 0 | 恢复默认亮色/large 字号并重新启动生产入口；`simulator-production-launch.txt`。 |

## 验证边界

- 100+3−5=98 的列表/详情共用口径、全部标签、附加分类ID/备注、段落备注、统计/确认、来源组件、权限、宽屏关闭、确认忙碌、component/version 路由均有测试。
- 文件 reader 保存成功/不支持有测试；原生文本/JSON/CSV 系统查看器、其它原生保存、Web 下载有平台分支，但未在真实系统查看器/分享面板中联调。
- 模拟器使用真实 BillDetailFlow 和虚构服务，不是测试站契约；模拟器原生点击工具不可用，相关动作由 Widget/Bloc 测试覆盖。
- 真机、VoiceOver/TalkBack、真实服务端和系统文件查看器 NOT_RUN；按用户 2026-11-05 规则不阻塞分配问题完成。
- S4-A 临时模拟器入口移动到 `/private/tmp/s4_a_simulator_app.dart` 保存，未纳入本轮提交/分析。
