# S2-A 独立复审｜attempt-003

结论：**PASSED，本地共享底座审查通过，可进入下一提示词 S3-A。** 三项 S2-A 缺陷均有本轮独立探针和实际 Flutter 图片闭合证据，未发现新的基础返修项。外部设备、读屏、平台编译和真实接口仍为 NOT_RUN。

## 快照与证据来源

- 当前 HEAD 为 `00a8f2f4e682eda9dd04c9372d95bc054673708b`，S1-A/S1-B 以未提交工作区差异存在。
- S1-B attempt-002 记录的 9 个源码/测试/预览文件与当前 SHA256 全部一致，本轮未修改这些业务文件。
- S1-A 保持 PARTIAL；S1-B 实现者记录保持 PASSED。本审查只更新 S2-A 自身状态、issue-checks 和空返修路由。

## 三项缺陷闭合

### S2A-001｜P1｜VERIFIED_CLOSED（共享金额实例）

- `lib/fx/components/fx_money_text.dart:170` 将最后整数组、小数点和小数位合并为 `890.12`。
- 390/440、2x 原失败条件本轮探针通过，不再把 `12` 孤立到第三行。
- 320/390/440、1x/2x 亮暗图已实际查看：空间足够金额一行，不足时按货币/千分位组重排，末组与小数完整，无裁切或字号缩小。
- masked/compact、精确 Semantics/Tooltip、短金额单 Text 和 176 个业务消费者回归通过。

### S2A-002｜P2｜VERIFIED_CLOSED（共享分段实例）

- 保持 attempt-002 已闭合实现：TextScaler > 1.3 每项独占整行。
- 本轮 320/390/440 图中英文不断词，独立探针再次验证至少 48 高触区和点击切换。
- 不扩大为更多项选择列表或全部页面迁移完成。

### S2A-003｜P2｜VERIFIED_CLOSED（共享选择行实例）

- `FxSelectRow` 按实际标签排版宽度与 TextScaler 决定重排，重排标签按空格 token 保持英文完整。
- 440/1x 的 `Counterparty` 原失败探针通过；亮暗图不再出现 `Counterpart / y`。
- 长值、清空/chevron 可见，44×48 清空目标及三个直接消费者回归通过。

## 其余合同

三态 picker、树清空、未保存离开、忙碌退出、成功确认、字段语义、掩码不泄露、无边框金额、按钮底部区域和财务色存储均通过。弹层成功退出与忙碌键盘 inset 探针通过，图中输入和加载动作在模拟 inset 上方，未出现双重 inset。

## 真实验证与计数

`realTests` 排除 synthetic loading/setUpAll/tearDownAll；同时保留 testDone events。

| 范围 | realTests | 通过 | 跳过 | 失败 | testDoneEvents | runner |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 决定性 `test/fx` + editor order flow | 73 | 73 | 0 | 0 | 91 | success=true |
| 金额/选择行/分段独立复审探针 | 4 | 4 | 0 | 0 | 7 | success=true |
| 受影响业务消费者 | 176 | 176 | 0 | 0 | 225 | success=true |
| 全量 Flutter 测试 | 424 | 423 | 1 | 0 | 534 | success=true |
| 共享渲染 | 12 | 12 | 0 | 0 | 15 | success=true |
| 弹层探针 | 2 | 2 | 0 | 0 | 5 | success=true |

全量唯一跳过仍为 Apple IAP donation。最终 `flutter analyze --no-pub` 退出码 1：1159＝0 error / 252 warning / 907 info；与 S1-A 基线逐项新增 0、移除 0，不能称 lint 全绿。

## 视觉与设备边界

- 重新生成并实际打开 13 张图：LIGHT/DARK × 320/390/440 × 1x/2x，加 LIGHT/390/1x 忙碌弹层。
- 品牌实色卡、输入焦点/错误、选择器、长文本、分段、树和 CTA 未见本轮分配实例的裁切、隐藏或字号缩小。
- 普通 `FxListItem` 自由文本 trailing 在 320/2x 下仍有末位换行；它不是本轮 FxMoneyText/FxSelectRow 实例，未扩大返修范围，也不据此宣布全部文本/页面完成。
- 键盘为 240 逻辑像素模拟 viewInset，不是系统键盘。
- 模拟器/真机、VoiceOver/TalkBack、平台编译、真实接口均 NOT_RUN；它们保留在外部验收层，不影响本轮本地共享底座 PASSED 的证据边界。

## 下一步

下一提示词：**S3-A**，路径 `docs/design-system/execution-prompts/prompts/04-S3-A.md`。本轮未执行 S3-A。`repair-routing.json` 的 `orderedRepairs=[]`，无 S1-B 返修任务。
