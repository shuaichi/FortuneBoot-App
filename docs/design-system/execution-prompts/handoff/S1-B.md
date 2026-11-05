# S1-B 交接｜共享底座初审返修

最新阶段结论：**PASSED（attempt-002 两项分配返修的本地实现与视觉验证完成）**。`localGate=PASSED`，`visualGate=PASSED`（仅本轮共享 Flutter fixture），`externalGate=PARTIAL`。S2A-001、S2A-003 均为 `VERIFIED_LOCAL`；S2A-002 已由 S2-A attempt-002 独立关闭，本轮未改它。下一步回 S2-A attempt-003。

## 1. 范围、前置与真实起点

- 工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`；分支 `master`。
- before/after Git SHA 均为 `00a8f2f4e682eda9dd04c9372d95bc054673708b`；after 是 S1-A 与 S1-B 两轮未提交工作区，逐文件 SHA256 见 `evidence/S1-B/attempt-002/source-sha256.json`。
- 读取 S2-A attempt-002 的 review、repair-routing 和原始探针。仅领取 **S2A-001、S2A-003**；没有修改 S2A-002 或增加分配外功能。
- attempt-001 证据完整保留，未覆盖；本轮使用 `evidence/S1-B/attempt-002/`。S2-A 已写 runtime 与先前未提交实现均保留，没有 reset/clean/stash/restore。
- 未 commit/push/发布/部署，未写真实账本/账号/云端数据，未改服务端/数据库/SDK/依赖/包版本/签名，未改审查报告或原审计报告。

## 2. 本轮修改与原因

- `lib/fx/components/fx_money_text.dart`：将最后整数组、小数点和小数位合并为 token（如 `890.12`），避免 390/440、2x 孤立 `12`。短金额完整 Text、masked/compact 和完整 Semantics/Tooltip 不变。
- `lib/fx/components/fx_select_row.dart`：按实际标签排版宽度和 TextScaler 决定行内/上下重排；重排标签按空格 token 保持英文单词完整，短标签保留单 Text。清空语义、44×48 目标、长值和只读行为保持。
- `test/fx/components/fx_money_text_test.dart`、`test/fx/components/fx_s1_b_repair_test.dart`：金额 token 预期更新为 `890.12`，继续检查真实行布局和精确语义。
- attempt-002 证据探针：`s1_b_decimal_reprobe_test.dart`、`s1_b_select_row_reprobe_test.dart`、`select_row_matrix_test.dart`、`s1_b_component_preview_test.dart`。
- `reference/contracts-current.md`、`reference/component-consumers.json`：同步 S1 返修允许的默认行为、SHA 和测试引用，无接口签名变化。
- `runtime/issue-checks/S1-B.json`、本 handoff、`runtime/progress.json`：attempt-002 结果与返回 S2-A attempt-003 路由。

## 3. 审查缺陷逐项结果

### S2A-001 / DT-23 / P1

- 根因：千分位 token 化时把最后整数组与小数位拆开，390/440、2x 出现 `890.` 与孤立 `12`。
- RED：原始审查探针两项均失败，整数 top=308、小数 top=404。
- 修复：`890.12` 作为不可拆分财务 token；短金额消费者兼容路径不变。
- 结果：`VERIFIED_LOCAL`。新合同下探针验证 `890.12` 同排；金额布局、masked/compact/零负值、既有消费者和 12 张图通过。
- 未闭合：S2-A attempt-003、真机和读屏。

### S2A-003 / CX-02 / P2

- 根因：固定 96 标签列和 360 宽度阈值，440/1x 下 `Counterparty` 仍被拆词。
- 修复：按标签实际宽度重排，并在重排标签内部按空格 token 保证英文不断词；短标签保留单 Text 结构。
- 结果：`VERIFIED_LOCAL`。原探针通过；320/390/440 × 1x/2x × 清空/只读 12 组通过；三个直接消费者 58 通过；12 张图实际查看。
- 未闭合：S2-A attempt-003、真机和读屏。

## 4. 真实验证与计数

Flutter 3.41.9 / Dart 3.11.5。

- 最终共享定向 `test/fx test/core/money test/core/errors`：**87 通过、0 跳过、0 失败**。
- FxSelectRow 三个直接消费者（bill_editor、recurring、goods）：**58 通过、0 跳过、0 失败**。
- 最终全量 `flutter test --no-pub --reporter json`：**534 个测试条目，533 通过、1 跳过、0 失败、0 error event**。唯一跳过仍为原 Apple IAP donation。
- 最终 `flutter analyze --no-pub`：退出码 1，**1159＝0 error / 252 warning / 907 info**；与 S1-A 基线按 path/code/message 新增 0、移除 0。证据探针文件命名曾多 1 条 info，重命名后回到基线。
- 原始 RED/GREEN、选择行矩阵、视觉渲染、测试 JSON、分析差异和源码 SHA 均保存在 attempt-002。

## 5. 视觉、设备与联调分层

- 真实 Flutter 图 12 张：LIGHT/DARK × 320/390/440 × 1x/2x，全部已实际打开，索引 `evidence/S1-B/attempt-002/screenshot-index.json`。
- 观察：390/440、2x 的 `890.12` 与前导整数组同排，不再孤立；440/1x 的 `Counterparty` 完整显示；长值和清空/箭头动作完整。短金额一行，大额按财务组重排。
- 320/2x 的普通 trailing 文本仍可出现单独末位换行，它不是本轮 FxMoneyText/FxSelectRow 实例，未扩大修改。
- 模拟器/真机 NOT_RUN；VoiceOver/TalkBack NOT_RUN；平台编译 NOT_RUN；真实接口 NOT_RUN。视觉 PASSED 不与设备/联调合并。

## 6. 未完成与精确下一步

- 两项只由修复者标为 `VERIFIED_LOCAL`；独立复审、真实设备与平台验收未完成。
- 下一提示词：回到已有 **S2** 会话，重新执行 `docs/design-system/execution-prompts/prompts/03-S2-A.md`，使用 `evidence/S2-A/attempt-003/`。S2-A 通过后才进入 S3-A；本轮未执行下一阶段。

## 7. 历次证据

- attempt-001：`evidence/S1-B/attempt-001/`；S2A-001、S2A-002 的首次返修。
- attempt-002：`evidence/S1-B/attempt-002/`；S2A-001、S2A-003 的本次返修。
