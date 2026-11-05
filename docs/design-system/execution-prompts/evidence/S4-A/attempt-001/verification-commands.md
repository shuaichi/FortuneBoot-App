# S4-A attempt-001 验证命令与结果

工作目录 `/Users/zhangchi118/代码/FortuneBoot-App`，Flutter 3.41.9 / Dart 3.11.5；未升级 SDK/依赖，未写真实业务数据。

| 命令 | 退出码 | 真实结果与日志 |
| --- | --- | --- |
| `flutter test --no-pub --reporter json test/features/bills`（基线） | 0 | 16 通过、0 失败、0 跳过；`baseline-tests.json`。 |
| 同一命令（RED） | 1 | 33 项中 23 通过、10 按当前缺陷失败；`red-tests-final.json`、`red-summary.json`。 |
| 同一命令（最终账单域） | 0 | 39 通过、0 失败、0 跳过；`decisive-tests-final.json`。 |
| `flutter test --no-pub --reporter json`（最终全量） | 0 | 585 个真实测试，584 通过、1 跳过、0 失败；唯一跳过既有 Apple IAP donation；`full-tests-final.json`、`full-test-summary.json`。 |
| `flutter test --no-pub --reporter json docs/design-system/execution-prompts/evidence/S4-A/attempt-001/s4_a_bills_render_test.dart` | 0 | 11/11 真实业务渲染场景通过，11 张 PNG；`render-tests-final-007.json`、`render-summary.json`。 |
| `flutter analyze --no-pub`（最终） | 1 | 1175＝0 error / 260 warning / 915 info；`flutter-analyze-final-002.txt`。 |
| S3-A 诊断多重集比较 | 0 | 基线 1179＝0/260/919；最终无新增，减少 4 条既有 info；`analysis-comparison.json`。 |
| `git diff --check` | 0 | 无空白错误。 |
| `python3 docs/design-system/execution-prompts/tools/validate_pack.py --runtime` | 1 | 原 `2026-11-05-global-audit.md` 有重复 ID 块，391 次出现/334 唯一；未改原报告，诊断见 `pack-source-audit-diagnostic.json`。 |

## RED→GREEN 关键证据

- 账期旧箭头、快速跳转、筛选恢复、字段错误、高级分层、动态粘性头、首屏历史统计均在当前实现上先失败后修复。
- 快速定位还复现并修复了“短列表不可滚动、末段账期被回选为最新月”的真实边界。
- 横屏 2x 加载态固定 128 高产生 28px RenderFlex 溢出；改为内容驱动可滚动后复验通过。
- 实际查看 PNG 发现大金额 Wrap 双负号/丢币种，账单边界做方向适配并补隐私断言；未修改共享冻结实现。
- 全量与渲染最终运行均发生在源码、ARB、生成 Dart 和 fixture 最终变化之后。

## 分层边界

- 本地单测/Widget/Bloc/全量：PASSED。
- Flutter 业务 fixture 视觉：PASSED，11 张均已实际打开查看；索引 `screenshot-index.json`。
- 真机、系统 Dynamic Type、VoiceOver/TalkBack、平台编译、真实服务端联调：NOT_RUN。
- `validate_pack.py` 的原审计重复问题不属于 S4-A 业务回归，未通过修改审计或校验规则掩盖。

## 模拟器补充验收（用户新规则）

- `flutter devices`：发现 iPhone 18 Pro Max iOS 27.0 模拟器。
- 生产入口 `flutter run --debug --no-pub --no-resident`：iOS 构建/启动成功；实际截图确认 demo 测试站配置页，无登录态。
- 隔离 evidence 入口在同一模拟器运行真实 BillsPage/BillsBloc＋虚构服务：跨年/多币种、系统最大无障碍字号、暗色均实际查看。
- 验收后恢复亮色/默认 large 字号并重新启动生产入口。
- 模拟器原生点击因工具/权限不可用 NOT_RUN；筛选/账期点击由 Widget/Bloc 测试覆盖，未声称原生点击通过。
- 测试站真实接口未登录、未写数据，NOT_RUN；按用户新规则不阻塞分配问题完成。
