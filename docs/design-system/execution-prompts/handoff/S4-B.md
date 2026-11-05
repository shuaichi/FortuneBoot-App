# S4-B 交接｜账单详情、金额口径与附件阅读

最新结论：**PASSED（attempt-001）**。`localGate=PASSED`；`visualGate=PASSED`（10 张 Flutter 详情图与 2 张 iPhone 模拟器图已实际查看）；`externalGate=PASSED`（按用户 2026-11-05 规则，模拟器可替代真机，分配问题不依赖测试站联调）。未 commit/push/发布/部署，未写真实账务或账号数据。

## 1. 范围与起点

- 起点 HEAD/提交基线 `1243a5b3e4eb2603ca7ea7c0641f724b5ccd5e8e`，开始时工作区干净；前置 S4-A 为 PASSED。
- 修改 `lib/features/shared/presentation/bills/`、`lib/features/shared/data/bill_attachment*`、`lib/features/bills/presentation/widgets/bill_tile.dart`，同域测试/渲染 fixture、必要 ARB 与生成文案及 S4-B 台账。
- 未修改服务端、数据库、账务算法、冻结 Fx 实现、SDK/依赖、签名或发布配置。

## 2. 实现

- `BillFlowAmount` 统一列表与详情的 settled/display、方向、币种和掩码；详情实付为主并展示原额+手续费−优惠分解，不修改计算。
- 详情完整标签、附加分类ID/备注、段落备注、统计/确认、来源组件和只读原因；标题不截断，2x键值上下重排。
- `BillAttachmentCard` 显示文件名/MIME/打开/保存；原生文本/JSON/CSV 系统查看器，其它原生保存应用文档目录，Web 下载；unsupported/失败明确反馈。
- 图片黑底预览白底黑字关闭，宽屏 dialog 显式关闭。
- `BillDetailPermissions` 继承 allowedActions/readOnlyReason，禁用动作不重新放开；无动作时隐藏footer。
- 编辑/复制携带账单自身 bookId、orderId、orderComponent、orderLedgerVersion 和锁定上下文。
- 确认/删除 pending 更新可见状态并防重复；编辑/确认主操作稳定，复制/删除次级。

## 3. 逐项结果

- 主责 BO-063—BO-070 全部 `VERIFIED_LOCAL`。
- 共性 BO-007/010/072/073/074 本阶段实例 `VERIFIED_LOCAL`。
- DT 实例 43 个 `VERIFIED_LOCAL`，DT-13/DT-33 无图表为 `NOT_APPLICABLE`。
- 共 58 项：56 `VERIFIED_LOCAL`、2 `NOT_APPLICABLE`；无 `VERIFIED_CLOSED`，不代其它 owner 关闭全局编号。
- 精确 SHA/证据见 `runtime/issue-checks/S4-B.json`。

## 4. 真实验证

- 基线：17 通过、0 失败、0 跳过。
- 最终决定性：**34 通过、0 失败、0 跳过**。
- 最终全量：**602 个真实测试，601 通过、1 跳过、0 失败**；唯一跳过既有 Apple IAP donation。
- 渲染：10/10 真实详情场景通过；10 张 PNG 已实际查看。
- 最终分析：**1174＝0 error / 260 warning / 914 info**；对照 S4-A 的 1175＝0/260/919，无新增，减少 1 条既有 info。
- `git diff --check` 通过。

## 5. 视觉与设备

已查看：亮/暗完整详情、320/2x、440/2x 掩码、PDF附件、附件失败、黑底图片关闭、只读来源、1440宽屏关闭、英文2x；以及 iPhone 模拟器亮色与系统最大无障碍字号暗色详情。

模拟器确认实付 `-¥98.00`、100+3−5分解、6个标签、附加备注、固定动作和滚动正文。验收后恢复默认亮色/large 字号及生产入口。

真实服务端、系统文件查看器/分享面板、VoiceOver/TalkBack、模拟器原生点击均 **NOT_RUN**。reader 测试不等于系统查看器联调；按用户规则这些缺口不阻塞分配问题完成。

## 6. 证据

- `evidence/S4-B/attempt-001/implementation-plan.md`
- `source-before.json`、`source-snapshot.json`
- `baseline-tests.json`、`red-tests.json`、`decisive-tests-final-008.json`
- `full-tests-final-007.json`、`full-test-summary.json`
- `flutter-analyze-final-007.txt`、`analysis-comparison.json`
- `s4_b_detail_render_test.dart`、`render-tests-final-005.json`、`render-summary.json`
- `screenshot-index.json` 与 10 张 PNG
- `s4_b_simulator_app.dart`、`simulator-validation.json` 与 2 张模拟器 PNG
- `simulator-production-launch.txt`
- `verification-commands.md`
- `runtime/issue-checks/S4-B.json`

## 7. 精确下一步

- 附加分类只有 categoryId，无名称字段；本轮显示明确ID，不伪造名称。若需要名称，由真实服务契约/同账本分类缓存后续提供。
- 原生系统查看器/分享面板、读屏、真实接口和原生点击待需要时另行验证，不默认阻塞。
- 下一提示词：**S5-A**，新开 S5 会话，文件 `docs/design-system/execution-prompts/prompts/07-S5-A.md`。
- 本轮未执行 S5-A。
