# S2-A 独立审查｜attempt-001

结论：**FAILED，退回 S1-B，不放行 S3-A。** 行为合同、隐私和忙碌/取消路径通过本地审查；两项共享大字视觉缺陷未通过。审查未修改业务源码、既有测试、依赖或原审计报告。

## 快照与前置判断

- 当前 `master@00a8f2f4e682eda9dd04c9372d95bc054673708b`，初始工作区干净；S1-A 成果已由 `6061359` 后的 `00a8f2f` 提交承载。
- 当前 36 个 S1-A 记录文件与其实现期 SHA256 全部一致，无缺失或漂移，见 `../../evidence/S2-A/attempt-001/production-source-comparison.json`。
- S1-A 保持 `PARTIAL`。本审查只依赖已冻结共享合同和 fixture，不依赖其后续页面、设备或平台缺口，因此允许执行；没有把 S1-A 改写为 PASSED。

## 真实缺陷

### S2A-001｜P1｜金额在数字组和小数中间任意换行

- 位置：`lib/fx/components/fx_money_text.dart:87`、`:113`、`:119`。
- 复现：真实 `FxMoneyText`，CNY `1,234,567,890.12`，20 页面边距，保持系统 TextScaler。
- 320/1x：`.12` 被单独放到第二行；320/2x：`¥1,234, / 567,89 / 0.12`；390/2x：`¥1,234,5 / 67,890.1 / 2`。
- 影响：字符虽未省略，但财务数字组和小数不再作为可快速核对的阅读单元；默认非 compact 的所有金额消费者都受影响。
- 根因边界：当前实现只把 `maxLines` 改为 null，现有测试也只断言“不 ellipsis”，没有验证财务分组换行。
- 证据：`shared-light-320-1x.png`、`shared-dark-320-2x.png`、`shared-light-390-2x.png` 及 `screenshot-index.json`，均已实际打开查看。
- 修复路由：`ownerSession=S1`，`repairPrompt=S1-B`；要求保留完整值、隐私、系统字号和默认中性前景，并补可失败的布局验证。

### S2A-002｜P2｜分段控件在 320/2x 下拆分选项单词

- 位置：`lib/fx/components/fx_segmented.dart:24`、`:29`、`:94`。
- 复现：两项真实 `FxSegmented`，“收入分类 / Income”与“支出分类 / Expense”，320 宽、2x TextScaler。
- 实际：等宽 Row 始终两列，`Expense` 显示为 `Expens/e`；现有测试只断言不 ellipsis，未判断重排后的可读性。
- 影响：记账、周期、统计、日志、账本与管理页等直接消费者。
- 证据：`shared-light-320-2x.png`、`shared-dark-320-2x.png`，亮暗均已实际查看。
- 修复路由：`ownerSession=S1`，`repairPrompt=S1-B`；要求少量分段在大字下采用可辨认重排，保留完整标签和触区。

机器可读复现、expected/actual、受影响合同和 requiredChecks 见同目录 `review.json`；有序返修见 `repair-routing.json`。

## 已独立通过的合同

- 三态 picker：`cancelled/cleared/selected` 可区分；记账交易对象、单据、附加费用直接调用均按结果类型分支，树选择器保留 `List + null`。
- 弹层：未改直接退出、有改确认、忙碌阻止退出、失败保持打开；额外独立探针确认成功返回 `true` 并关闭。
- 主题/平台：全局输入主题没有注入边框；原无边框金额正常/聚焦均保留。按钮只以 `minHeight` 增高，不占满底部导航剩余高度；Material 标准密度保留。
- 财务色与隐私：`FinanceColorPreferences` 未改，默认金额使用可读中性前景；掩码可见文本、Semantics 和 Tooltip 不泄露精确值。
- 可访问性与输入：清空目标、静态/操作标签、长列表项、持久字段错误、粘贴规范化和结束编辑的既有决定性测试均通过。

## 本轮验证计数

计数规则：`realTests` 排除 Flutter JSON reporter 的 synthetic `loading/setUpAll/tearDownAll`；同时保留 `testDoneEvents`，避免把加载事件冒充业务测试。

| 命令范围 | realTests | 通过 | 跳过 | 失败 | testDoneEvents | runner |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| `test/fx` + `bill_editor_order_flow_test.dart` | 63 | 63 | 0 | 0 | 80 | success=true |
| `test/features/bill_editor` + `test/features/recurring` | 45 | 45 | 0 | 0 | 54 | success=true |
| 全量 Flutter 测试 | 414 | 413 | 1 | 0 | 523 | success=true |
| 共享渲染探针 | 8 | 8 | 0 | 0 | 11 | success=true |
| 最终弹层/键盘探针 | 2 | 2 | 0 | 0 | 5 | success=true |

唯一跳过仍为 Apple 平台 IAP donation 测试，未启用入口。

最终 `flutter analyze --no-pub` 退出码 1：1159 项＝0 error / 252 warning / 907 info；与 S1-A 基线按 severity/path/line/column/code/message 比较，新增 0、移除 0。首次分析曾多出审查探针自身 1 条 `unnecessary_async`，修正探针后保留首次日志并以最终 1159 项为准，不能称为 lint 全绿。

## 视觉与设备边界

- 本轮重新生成并实际查看 9 张图：LIGHT/DARK × 320/390 × 1x/2x，加 1 张 LIGHT/390/1x 忙碌弹层图。
- 320/390 的大字缺陷见上；其余品牌实色卡、输入焦点/错误、选择行、长文本和底部 CTA 未见横向溢出或关键内容省略。
- 弹层图使用 240 逻辑像素模拟 viewInset，输入和加载底部动作可见且 inset 只应用一次；空白区域不是系统键盘。
- 模拟器/真机、VoiceOver/TalkBack、平台编译、真实接口均为 NOT_RUN。上述本地通过与缺陷均不替代这些验收。

## 下一步

执行 `docs/design-system/execution-prompts/repairs/S1-B.md`，只修复 S2A-001、S2A-002 及其必要回归；完成后回到本 S2 会话重新执行 `prompts/03-S2-A.md`，使用 `attempt-002`。本轮未执行 S1-B 或 S3-A。
