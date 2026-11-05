# S4-A 交接｜账单列表、账期导航与筛选

最新结论：**PASSED（attempt-001）**。`localGate=PASSED`；`visualGate=PASSED`（11 张真实 Flutter 账单业务 fixture 已实际打开查看）；`externalGate=PASSED`（按用户 2026-11-05 新规则，iPhone 模拟器可替代真机，分配问题完成不依赖测试站联调）。未 commit/push/发布/部署，未写真实账本、账号或云端数据。

## 1. 范围与真实起点

- 工作目录 `/Users/zhangchi118/代码/FortuneBoot-App`，分支 `master`，起点/当前 HEAD `878b2dafa8fc18a3f5e7f2e08372b9b491f256de`；开始时 `git status --short` 干净。
- 前置 S3-A 为 PASSED，合同与视觉证据完整；本轮只依赖本地账单/共享组件合同，不依赖真机或外部验收。
- 实现范围：`lib/features/bills/`、同域测试、`lib/l10n/intl_{zh,en}.arb` 与现有 `intl_utils` 生成文件，以及本阶段 evidence/runtime/handoff。
- 未修改服务端、数据库、账务存储规则、SDK/依赖、包版本、签名、发布配置或冻结的共享 Fx 实现。

## 2. 实际修改与原因

- **账期导航**：旧/新箭头按已加载账期索引；新增年月选择器。已加载账期直接定位，未加载历史按真实分页加载；末段短列表和 `maxScrollExtent=0` 不再回选最新月。
- **可滚动控制区**：只固定账单标题/筛选入口；账期起止、汇总、筛选摘要、刷新失败均进入连续 CustomScrollView。小高度和 2x 下控制区可滚走。
- **统一汇总**：新增 `BillsPeriodSummary`，当前与历史共用无阴影、0.5 边框、13 标签/17 金额表面；首屏已含历史月时也请求各月统计，不再只在后续分页请求。
- **筛选恢复与分层**：显示条件数与真实条件摘要；空结果提供清除/调整。常用标题、类型、金额、日期在前，高级确认/统计/分类/标签/账户/对象/成员折叠。
- **字段校验**：标题/金额使用显式 Fx 输入标签；金额粘贴复用共享正规化；非法最小/最大分别提示，min>max 绑定最大字段并聚焦/滚动首错。
- **账单行**：金额不 compact；主口径、时间、原额/手续费/优惠分层。待确认/附件语义与筛选角标可读；侧滑复制/删除及确认保留。
- **失败恢复**：首屏失败保留上下文骨架；刷新/分页失败保留旧列表并提供重试。
- **加载布局**：加载/失败区由内容驱动并可滚动，修复横屏 2x 固定 128 高的 28px 过渡帧溢出。

## 3. 逐项结果

- 主责 **BO-011—BO-019** 均为 `VERIFIED_LOCAL`。
- 本阶段共性实例 **BO-004/006/009/010/021/063/074** 均为 `VERIFIED_LOCAL`，仅账单域实例。
- DT-01—DT-45 的账单域实例：43 项 `VERIFIED_LOCAL`；DT-13/DT-33 因本阶段无图表为 `NOT_APPLICABLE`。
- 共 61 项：59 `VERIFIED_LOCAL`、2 `NOT_APPLICABLE`。没有 `VERIFIED_CLOSED`，没有代其它 owner 关闭全局编号。
- 精确源码 SHA、观察、证据见 `runtime/issue-checks/S4-A.json`。

边界：BO-021 的编辑器最终收付款核对由 S5-A；BO-063 的详情主金额口径统一由 S4-B；媒体预览关闭对比不在本轮。BillTile 的大金额方向适配解决账单域可见问题，但共享 `FxMoneyText` 的负数＋币种 Wrap 根因仍需 S1-C/S2 全局核对，本轮未宣称共享层已修。

## 4. 真实验证与计数

Flutter 3.41.9 / Dart 3.11.5。

- 基线：16 通过、0 失败、0 跳过。
- RED：33 项中 23 通过、10 按当前缺陷失败；日志和失败项保留。
- 最终账单域：**39 通过、0 失败、0 跳过**。
- 最终全量：**585 个真实测试，584 通过、1 跳过、0 失败**，runner success=true；唯一跳过仍为既有 Apple IAP donation。
- 渲染：**11/11** 真实业务场景通过，11 张 PNG 均已实际打开查看。
- 最终分析：**1175＝0 error / 260 warning / 915 info**；对照 S3-A 的 1179＝0/260/919，无新增诊断，减少 4 条既有 info。
- `git diff --check` 通过。

`validate_pack.py --runtime` 当前退出 1：原 `2026-11-05-global-audit.md` 同一 DT/CX 块出现两次，扫描 391 次/334 唯一。原报告未修改；`pack-source-audit-diagnostic.json` 保留精确行号与 334 ID 映射一致的只读核验。不把此失败伪装成 PASS，也不因此否定已执行测试。

## 5. 视觉、设备与联调分层

已实际查看 11 张：390 亮/暗跨年与 CNY/USD、320/2x 长大金额、440/2x 暗色掩码、筛选零结果、分页失败、刷新失败、640×320/2x 横屏、常用筛选、320/2x 字段错误、440/2x 英文暗色筛选。

观察：当前/历史汇总一致；金额完整且方向/币种正确；2x 日头与导航增高；掩码不带方向符号且不泄精确值；高级筛选中文完整；字段错误可见；分页/刷新保留已读上下文；重试可辨。

这些 PNG 来自真实 BillsPage/BillsFilterSheet/BillTile/BillsPeriodSummary 与虚构服务，不是 HTML 示意图，也不是服务器契约或真机截图。iPhone 模拟器、系统 Dynamic Type 和平台 debug 构建已执行；VoiceOver/TalkBack、真实服务端联调 **NOT_RUN**。按用户新规则，上述 NOT_RUN 不阻塞本阶段分配问题完成。

## 6. 证据索引

- `evidence/S4-A/attempt-001/implementation-plan.md`
- `evidence/S4-A/attempt-001/source-before.json`、`source-snapshot.json`
- `evidence/S4-A/attempt-001/red-tests-final.json`、`red-summary.json`
- `evidence/S4-A/attempt-001/decisive-tests-final.json`
- `evidence/S4-A/attempt-001/full-tests-final.json`、`full-test-summary.json`
- `evidence/S4-A/attempt-001/flutter-analyze-final-002.txt`、`analysis-comparison.json`
- `evidence/S4-A/attempt-001/s4_a_bills_render_test.dart`、`render-tests-final-007.json`、`render-summary.json`
- `evidence/S4-A/attempt-001/screenshot-index.json` 与 11 张 PNG
- `evidence/S4-A/attempt-001/verification-commands.md`
- `evidence/S4-A/attempt-001/simulator-validation.json`、`simulator-production-launch.txt` 与 4 张模拟器 PNG
- `runtime/issue-checks/S4-A.json`

## 7. 未完成与精确下一步

- 用户 2026-11-05 明确：模拟器可替代真机；如果只是分配的问题，可以认为完成，后续同样适用。因此本轮不再以无实体真机保持 PARTIAL。
- 已在 iPhone 18 Pro Max 模拟器完成生产构建/启动和隔离业务页验证；系统最大无障碍字号、暗色、跨年/多币种均实际查看。真实接口因未提供账号仍 NOT_RUN；没有登录或写真实账务。
- 模拟器原生点击因工具/权限不可用未执行，不能声称已在模拟器点击；账期/筛选交互由 39 项账单域测试覆盖。`simulator-validation.json` 记录证据边界。
- 原审计重复 ID 导致提示词包校验失败，需其 owner 决定修复；本轮未修改原审计。
- 共享金额 Wrap 根因留 S1-C/S2 全局核对；本轮只修账单域消费者。
- 下一提示词：**S4-B**，回到已有 S4 会话，文件 `docs/design-system/execution-prompts/prompts/06-S4-B.md`。
- 本轮未执行 S4-B。

## 8. 后续统一验收口径（用户 2026-11-05）

后续阶段沿用：模拟器可以替代实体真机测试；用户指定的问题完成即可，不把无真实设备或无测试站账号作为默认阻塞。真实接口仍需在获得账号/授权且确有必要时验证，所有记录继续区分模拟器、虚构数据与真实服务，不能把 fixture 说成服务器联调。
