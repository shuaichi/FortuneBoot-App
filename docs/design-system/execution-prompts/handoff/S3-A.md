# S3-A 交接｜主壳导航、当前范围与跨页返回

最新结论：**PASSED（attempt-001）**。`localGate=PASSED`；`visualGate=PASSED`（12 张真实 Flutter 主壳 fixture 已实际打开查看）；`externalGate=PARTIAL`（真机、读屏、平台编译、真实 Web 刷新未执行）。按用户要求已在本地提交 `f12d07d603c82b39a230ad6312e9c8b7119abecd`；未推送、未发布。

## 1. 范围与真实起点

- 工作目录 `/Users/zhangchi118/代码/FortuneBoot-App`，分支 `master`，起点 HEAD `afe309a60ef095cd817721f23188a926c12bfa59`（S1-B 已提交）。
- 本轮 S3-A 源码与证据已按用户要求本地提交 `f12d07d603c82b39a230ad6312e9c8b7119abecd`；未 reset/clean/stash/restore，未改服务端、数据库、SDK、依赖、包版本或签名。
- 只修改本阶段允许路径：`lib/core/shell/`、`lib/core/navigation/`、`lib/core/session/`、`lib/core/app/fx_app.dart`、`lib/features/*/*registration.dart`，以及同域测试和中英文文案。

## 2. 实际修改

- **范围一致性**：`SessionState` 增加 `pendingGroup`；`SessionCubit` 用请求代号拒绝快速切换的过期响应，切换中保留旧 `currentGroup/currentBook/books`，成功时原子提交；失败保留旧范围并暴露可重试目标。`switchBook` 会取消在途分组切换。
- **范围说明**：新增 `SessionScopeStrip`（分组/账本两级、更新中、失败重试、只读、无账本）与 `SessionScopedPage`（管理/统计子页显示范围并在真正切换后按 scope key 重建数据）。主壳账单/统计/我的显示范围条；看板保留自身切换头，仅在 loading/error/只读/无账本时补范围条。
- **主壳避让**：`ShellContentInsets` 不再重复预留导航高度/安全区；FAB 页 88、无 FAB 24、宽屏 32+底部安全区；键盘、只读、无账本、切换中隐藏 FAB。新增末项与横屏命中测试。
- **主导航**：用内容驱动的 `_ShellBottomNav` 替换固定 64 高 `NavigationBar`，不夹断 TextScaler；四 tab 选中态、图标胶囊、≥48 触区和语义保留。
- **记账入口与权限**：手机四 tab 均可记账（可写且 ready），宽屏 rail 一致；访客在渲染期隐藏 FAB，并看到“只读”徽标/rail 说明。
- **深链恢复**：`DeepLinkTarget` + `PendingDeepLink` 保留 route/query；`StartupRouteGuard` 先捕获再清栈；`MainShell` 等会话 ready 后恢复 tab/二级页。缺参、未知路由、无写权限、会话未恢复均进入 `FxRouteUnavailablePage`，有返回/重试出口。`AppRouter` 增加 `deepLinkRestorable`、`requiredDeepLinkKeys`、`requiresWriteAccess` 与 `onUnknownRoute`。
- **订单空页**：`orders_registration` 容错解析 `bookId/orderId`，缺参不再返回 `SizedBox.shrink()`；详情/核对声明必需深链键。
- **编辑器范围绑定**：BillEditor 路由优先使用 `presetBookId` 对应账本及其所属分组；请求的账本不在当前会话时显示缺参出口，避免深链/单据悄悄记到当前账本。
- **Apple 返回**：`AppRouter` 继续使用 CupertinoPageRoute；`FxRouteUnavailablePage` 使用带返回控件的 `FxPageScaffold`，loading/error 不替换返回骨架。
- **文案**：只新增本阶段必要键，更新 `intl_zh.arb`/`intl_en.arb` 并用 `intl_utils` 重新生成 `lib/generated`。

## 3. 逐项结果

主责：**DS-003、BO-071、FB-NAV-02/03/04/05/06 均 VERIFIED_LOCAL**（仅 S3-A scope 实例）。

共性实例：**MG-C17 VERIFIED_LOCAL**（账户/归物/成员/分类/标签/交易对象/单据/导入导出/资产/借贷/口径入口）；**DT-31/35/43/44/45 VERIFIED_LOCAL**；其余 DT 在本阶段壳层/范围条实例 **DISPROVED**；**FB-AUT-11、FB-NAV-01 CONFIRMED**，分别归 S12 与 S13（页面内部动画/资料页 PopScope 不在本阶段写入范围）。

逐项源码 SHA、观察、证据路径见 `runtime/issue-checks/S3-A.json`；未写 `VERIFIED_CLOSED`。

## 4. 真实验证与计数

Flutter 3.41.9 / Dart 3.11.5。

- 定向：`test/core/navigation` + `test/core/session` + `test/core/shell`，**41 通过、0 跳过、0 失败**，runner success=true。
- 全量：**450 个真实测试，449 通过、1 跳过、0 失败**，runner success=true；唯一跳过仍为既有 Apple IAP donation。
- 渲染：12/12 fixture 通过；12 张 PNG 已实际打开查看。
- 分析：最终 **1179＝0 error / 260 warning / 919 info**；HEAD 临时副本 **1183＝0/260/923**。0 新增 error/warning，减少 4 条既有 `prefer_final_locals` info；本阶段源码文件无 error/warning。
- `git diff --check` 通过；`validate_pack.py` 通过。

## 5. 视觉、设备与联调分层

- 已查看：390/1x 亮四 tab、320/1x、320/2x、440/2x 暗、访客只读、无账本、深链缺参、640×320 横屏 2x、键盘 viewInsets 模拟。
- 观察：长账本名在 390/1x 两行、320/2x 三行完整；2x 底部导航增高不裁切；只读无 FAB；无账本不显示 0；深链失败保留标题/返回/返回首页；横屏无额外大片空白。
- 模拟键盘是 `viewInsets=300`，不是系统键盘；主壳页面槽位是明确标注的 fixture，壳层/范围条/导航为真实组件。
- 真机、Dynamic Type 系统级、VoiceOver/TalkBack、iOS 侧滑、Web 刷新端到端、服务端联调：**NOT_RUN**。

## 6. 未完成与边界

- 资料详情 `PopScope(canPop:false)` 仍需 S13 处理；本轮只保证路由层 Apple 原生语义与失败页返回骨架。
- 认证页内部 180/220ms 动画仍需 S12 接入 `MediaQuery.disableAnimations`；本轮只确认路由层已遵循。
- DS-003 的“净资产=分组总资产”文案、统计顶栏账本/显隐入口、资产/借贷口径说明分别由 S7-A、S8-A、S8-C 落地；本轮提供共享范围条和管理页实例。
- 统计/账单/看板真实页面在本轮没有改结构；截图中的 tab 内容槽位是 fixture，不能当作业务页面视觉验收。

## 7. 精确下一步

- 下一提示词：**S4-A**，路径 `docs/design-system/execution-prompts/prompts/05-S4-A.md`。
- 本轮未执行 S4-A。

## 8. 证据

- `evidence/S3-A/attempt-001/`：`decisive-tests.json`、`full-tests.json`、`flutter-analyze.txt`、`analysis-comparison.json`、`source-snapshot.json`、`screenshot-index.json`、12 张 PNG、`s3_a_shell_render_test.dart`、`verification-commands.md`。
- `runtime/issue-checks/S3-A.json`。
