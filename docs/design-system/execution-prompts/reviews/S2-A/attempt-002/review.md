# S2-A 独立复审｜attempt-002

结论：**FAILED，继续退回 S1-B，不放行 S3-A。** S2A-002 已在共享实例范围闭合；S2A-001 只在部分宽度修复，另确认 S2A-003。审查未修改业务源码、既有测试、依赖或原审计报告。

## 快照与修复来源

- 当前 HEAD 仍为 `00a8f2f4e682eda9dd04c9372d95bc054673708b`，S1-B 以未提交工作区差异存在。
- S1-B 记录的 5 个源码/测试/预览文件与当前 SHA256 全部一致，复审没有拿旧图或实现者“已通过”替代当前验证。
- S1-A 保持 PARTIAL；S1-B 的实现者记录保持 PASSED，本审查只更新 S2-A 自身状态和返修路由。

## 逐项结论

### S2A-001｜P1｜仍未闭合

- 位置：`lib/fx/components/fx_money_text.dart:141`、`:145`、`:170`。
- 已通过部分：320/1x 为 `¥1,234,567,` / `890.12`；320/2x 为 `¥1,234,` / `567,` / `890.12`，数字组与小数可辨认。
- 未通过部分：390/440、2x 亮暗均为 `¥1,234,` / `567,890.` / `12`，小数位 `12` 独占第三行。
- 独立 `decimal-reprobe` 两个测试均失败：`890.` 的 `top=308`，`12` 的 `top=404`。这直接违反 attempt-001 的“不能孤立小数位”要求。
- 根因边界：当前 `Wrap` 将 `890.` 与 `12` 作为可分离 token；S1-B 测试只检查 token 自己不拆行，没有断言小数位与前导整数组同行。
- 修复路由：ownerSession=S1，repairPrompt=S1-B。必须补同行断言，并保留 masked/compact、精确语义、短金额单 Text 兼容和不裁切要求。

### S2A-002｜P2｜VERIFIED_CLOSED（仅共享实例）

- `FxSegmented` 在 TextScaler > 1.3 时改为整行布局。
- 320/390/440、2x 亮暗图中的 `Income`、`Expense` 均不再断词。
- 独立 `segmented-reprobe-final` 验证两项触区高度至少 48，点击“支出分类 / Expense”后值变为 `expense`。
- 首次探针因语义节点定位方式发生 `No element`，属于探针定位问题；修正后最终探针通过，首次记录保留。
- 此闭合不代替更多项选择列表、页面迁移或真机读屏验收。

### S2A-003｜P2｜新确认，OPEN

- 位置：`lib/fx/components/fx_select_row.dart:17`、`:86`、`:125`。
- 复现：440 逻辑宽、1x、20 页面边距，`label=交易对象 / Counterparty`，长中英文值，同时显示清空和 chevron。
- 实际：`Counterparty` 被拆为 `Counterpart` / `y`，亮暗图一致。最终 `select-row-reprobe-final` 对英文选择范围取得 2 个行 top，期望 1，稳定失败。
- 原因：内部可用宽 368 大于 360 重排阈值，进入固定 `labelWidth=96` 的 Row；320/2x 测试无法覆盖这个正常字号边界。
- 影响三个直接消费者：bill_editor、goods_form_sheet、recurring_editor_page。
- 修复路由：ownerSession=S1，repairPrompt=S1-B。需保留完整字段名/值、语义与 44×48 清空目标。

## 其余合同

三态 picker、树清空、未保存离开、忙碌退出、成功确认、字段语义、掩码不泄露、无边框金额、按钮底部区域与财务色存储均通过本轮行为回归。忙碌弹层图显示输入与加载动作在模拟 inset 上方，未出现双重 inset。

## 真实验证与计数

`realTests` 排除 synthetic loading/setUpAll/tearDownAll；同时保留 testDone events。

| 范围 | realTests | 通过 | 跳过 | 失败 | testDoneEvents | runner |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 决定性 `test/fx` + editor order flow | 73 | 73 | 0 | 0 | 91 | success=true |
| 受影响业务消费者 | 176 | 176 | 0 | 0 | 225 | success=true |
| 全量 Flutter 测试 | 424 | 423 | 1 | 0 | 534 | success=true |
| 共享渲染 | 12 | 12 | 0 | 0 | 15 | success=true |
| 弹层探针 | 2 | 2 | 0 | 0 | 5 | success=true |
| 小数独立探针 | 2 | 0 | 0 | **2** | 3 | **success=false** |
| 分段最终独立探针 | 1 | 1 | 0 | 0 | 2 | success=true |
| 选择行最终独立探针 | 1 | 0 | 0 | **1** | 2 | **success=false** |

全量唯一跳过仍为 Apple IAP donation。全量绿不包含 evidence 中刻意用于复现开放缺陷的独立探针，不能据此宣称审查通过。

最终 `flutter analyze --no-pub` 退出码 1：1159＝0 error / 252 warning / 907 info；与 S1-A 基线逐项新增 0、移除 0。选择行探针初次缺少本地化委托的失败日志保留，补齐后仍因实际断词失败。

## 视觉与设备边界

- 本轮重新生成并实际打开 13 张图：LIGHT/DARK × 320/390/440 × 1x/2x，加 1 张 LIGHT/390/1x 忙碌弹层。
- 金额和分段结果见上；440/1x 的选择行断词也已实际查看，不只是代码推断。
- 品牌实色卡、输入焦点/错误、长值、标签、树和 CTA 除已列缺陷外未见横向裁切或关键内容省略。
- 键盘为 240 逻辑像素模拟 viewInset，不是系统键盘。
- 模拟器/真机、VoiceOver/TalkBack、平台编译、真实接口均 NOT_RUN。

## 下一步

再次执行 `docs/design-system/execution-prompts/repairs/S1-B.md`，仅处理 S2A-001 和 S2A-003；S2A-002 不需返修。完成后回本 S2 会话执行 `prompts/03-S2-A.md`，使用 `evidence/S2-A/attempt-003/`。本轮未执行 S1-B 或 S3-A。
