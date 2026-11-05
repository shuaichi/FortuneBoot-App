# S1-A 交接｜共享令牌、交互与可访问性契约补齐

阶段结论：**PARTIAL**。`localGate=PASSED`，`visualGate=PASSED`（仅本阶段真实 Flutter 共享 fixture），`externalGate=PARTIAL`。本轮共享实现、合同和本地证据已完成；9 个页面/拖拽实例保持 CONFIRMED，6 个实例只完成共享部分，独立 S2 审查和消费者迁移未完成。没有把任何条目写成 `VERIFIED_CLOSED`。

## 1. 范围与真实起点

- 工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`；分支 `master`。
- before/after Git SHA 均为 `6061359de0d6db6597176a9158ee826de490f6c4`；after 是本轮未提交工作区，逐文件 SHA256 见 `evidence/S1-A/attempt-001/source-sha256.json`。
- S0-A 前置为 PASSED，已读取其 handoff、runtime、334 项分诊和 6 张原图联系表索引。本轮开始时工作区干净；既有底座已经在本地提交中，没有 reset/clean/stash/restore。
- 未 commit/push/发布/部署，未运行真实账本、账号、云端写入，未改服务端/数据库/账务存储/SDK/依赖/包版本/签名。
- 证据仅 `attempt-001`；历次 RED/GREEN 和最终验证均保留在该目录，未另建工程根台账。

## 2. 本轮实现与修改范围

### 共享合同与组件

- `fx_option_picker.dart`：新增 `FxSelectionKind/FxSelectionResult` 与 `showFxOptionPickerResult`，区分 cancelled/cleared/selected；保留旧 `showFxOptionPicker` 兼容入口。多选继续 `null/List`。
- `fx_tree_picker.dart`：单选清空返回 `[]`，取消仍为 `null`；展开目标至少 44，长名称/父路径可换行，清除按钮使用共享 FxButton。
- `fx_sheet.dart`：新增可组合 `FxSheetPopGuard`，未改直接退出、有改确认、忙碌阻止退出；键盘和安全区仍由 FxSheet 负责。
- `fx_confirm_sheet.dart`：pending 接入忙碌退出保护，false/异常保持打开并提供本地化默认失败解释。
- `fx_select_row.dart`、`fx_list_item.dart`、`fx_segmented.dart`：触区、完整长文本、上下重排、内容增高、selected/button 语义；普通导航不再发 selection haptic。
- `fx_tag_chip.dart`、`fx_chip.dart`：静态标签不暴露按钮语义；删除/选择有命名 44 目标；背景移到 Material 下，Ink 不再被不透明 Container 遮住。
- `fx_state_view.dart`：loading/error/empty 增加可选 `title`，保留 message 和恢复动作。
- `fx_amount_input.dart`、`fx_text_field.dart`：常见货币粘贴规范化且光标有效；Done/点击外部结束编辑；原无边框金额输入合同保持不变。
- `fx_action_sheet.dart`：普通图标中性，选中/危险才强调。
- `fx_bento_grid.dart`：窄屏/大字转固有高度单列摘要清单，动画统一 `FxMotion.resolve`。这不是拖动排序协议。
- `fx_money_text.dart`：默认完整换行；masked 的可见文本/Semantics/Tooltip 不泄露精确值；默认金额前景使用 textPrimary，不改用户业务色。
- `fx_line_chart.dart`、`fx_bar_chart.dart`：网格改 separator，默认分类填色随亮暗；`fx_donut_chart.dart` 中心金额使用默认 17、标题 13；`fx_chart_palette.dart` 新增暗色图形填色。
- `core/feedback/fx_feedback.dart`：不再拼接英文 `tone.name`，不主动替换未结束旧提示。
- `lib/l10n/intl_zh.arb`、`intl_en.arb`：新增未保存离开、继续编辑、放弃修改、确认失败、清除/删除语义；已按 `dart run intl_utils:generate` 更新现有生成输出，未手改生成 Dart。

### 必要的直接消费者适配

- `bill_editor_page.dart`、`widgets/editor_pickers.dart`、`widgets/extras_section.dart`：全部 `showOptionPicker` 直接调用原子迁移到共享三态，取消不再误清空；树选择器消费者继续使用 `List + null`。
- `profile_edit_page.dart`：移除与 FxListItem 新默认 `subtitleMaxLines=3` 重复的显式参数，无页面重排。
- 没有创建 `runtime/contract-requests.json` 请求；本轮需要的共享变化已在 S1-A 授权范围内完成。

### 测试、预览与合同台账

- 新增/更新 `test/fx/components/` 与 `test/fx/layout/` 的决定性测试，覆盖选择三态、离开保护、忙碌关闭、长文本/金额、明暗反馈、隐私语义、粘贴/结束编辑、图表和触感。
- 新增 `tool/s1_a_component_preview_test.dart`，直接渲染生产 FxWidget，输出 8 张亮暗/宽窄/1x/2x 图。
- 更新 `reference/contracts-current.md`、`reference/component-consumers.json`、`runtime/issue-checks/S1-A.json`、本 handoff 和 `runtime/progress.json`。

## 3. 64 个 S1-A 实例结果

- 总数 64：`VERIFIED_LOCAL=24`、`DISPROVED=25`、`IMPLEMENTED_LOCAL=6`、`CONFIRMED=9`、`VERIFIED_CLOSED=0`。
- 6 个只完成共享部分：DT-13、DT-32、DT-33、DT-36、DT-45、CX-04。StatsPalette/页面图表布局、胶囊密度、局部尺寸、StateView 消费者及 `_GroupPill` 仍待各自 owner。
- 9 个保持 CONFIRMED：DS-021—DS-024（拖动等效操作、跨屏、占位、手势竞争），DT-14、DT-15、DT-28、DT-35、DT-38（具体页面色彩/小票/嵌套/底部留白）。本轮没有伪造共享排序能力或越权改页面。
- 每项的 observed、implemented、verified/disproved、blocked_external、源码 SHA、证据和未验证项见 `runtime/issue-checks/S1-A.json`。

## 4. 真实验证与计数

- Flutter 3.41.9 / Dart 3.11.5。
- 接管基线定向：43 通过、0 失败、0 跳过。
- 最终决定性定向 `flutter test --no-pub --reporter json test/fx test/core/money test/core/errors`：**76 通过、0 失败、0 跳过**，runner `success=true`。
- 受影响既有消费者 `test/features/bill_editor test/features/recurring`：**54 通过、0 失败、0 跳过**。曾发现 FxSegmented 无界高度回归，修复后同组通过；编译期接口外溢也已全部适配。
- 最终全量 `flutter test --no-pub --reporter json`：**523 个测试条目，522 通过、1 跳过、0 失败、0 error event**，runner `success=true`。唯一跳过仍为 Apple 平台 IAP donation 测试，未启用入口。
- 最终 `flutter analyze --no-pub`：退出码 1，**1159 诊断＝0 error / 252 warning / 907 info**；与 S0-A 当前基线按 path/code/message 对比新增 0、移除 0。不能称 lint 全绿。
- 真实 RED/GREEN 证据：`red-tests.txt`、`interaction-red.txt`、`secondary-red.txt`、`chart-haptic-red.txt`、`chart-palette-red.txt` 及对应 green 文件；测试自身语法/时序修正也保留诊断记录。
- 汇总：`evidence/S1-A/attempt-001/results.json`；命令与退出码：`commands.json`、`verification-commands.md`。

## 5. 视觉、设备与联调分层

- 真实 Flutter fixture 共 8 张：LIGHT/DARK × 320/390 × 1x/2x，全部已实际打开查看，索引见 `evidence/S1-A/attempt-001/screenshot-index.json`。
- 查看结论：长中英文、长金额、选中/禁用/焦点、持久错误、多行 CTA、树和恢复动作完整可见；实色卡前景配对，320/2x 选择行标签与动作上下重排，无横向溢出或关键金额省略。首轮发现的动作挤压和卡片前景已修正后复拍。
- 这些图只证明共享 fixture，不证明业务页面改后视觉、真实系统字体、全部平台排版或 69 个业务状态完成。
- 模拟器/真机：NOT_RUN；VoiceOver/TalkBack：NOT_RUN；平台编译：NOT_RUN；真实接口/服务器联调：NOT_RUN。需要这些能力闭合的内容不得标为外部验收通过。

## 6. 未完成与精确下一步

- S1-A 为 PARTIAL，不自行把本地绿合并成消费者、设备或独立审查通过；S2-A 应重点审查共享 Result/Guard 合同、直接消费者完整性、64 项实例证据及未完成路由。
- 下一提示词：**S2-A**，新开 S2 会话，文件 `docs/design-system/execution-prompts/prompts/03-S2-A.md`。本轮未执行它。
