# 当前共享合同（S1-A 冻结）

来源：`master@6061359de0d6db6597176a9158ee826de490f6c4` 加 S1-A 当前工作区差异。本文冻结本轮已实现的 Dart 接口与默认行为，不代表服务器、真机、VoiceOver/TalkBack 或发布验收已通过。全部直接调用方索引见 `component-consumers.json`，后续合同变更走 S1-E。

## 1. 路由与页面边界

- 启动路由是 `BaseUrlConfigPage.routeName`；`Routes.auth` 由 `AuthVersionGate` 进入 `LoginScreen`。主壳及二级页经 `AppRouter.onGenerateRoute` 使用 `buildFxRoute`。
- `AppRouter.push<T>` 以 `dynamic` 入栈后做 `result is T` 收敛；二级页参数通过 `RouteSettings.arguments`。账户、分类、标签、交易对象、成员、归物、账本/分组也存在 sheet 或 feature 内部 `MaterialPageRoute`，不能只迁移集中路由表。
- 主壳 tab：`/dashboard`、`/bills`、`/stats`、`/profile`。已注册二级路由以 `Routes`/`AppRouter` 当前源码为准；账本/分组详情另有 `books/group-detail`、`books/book-detail`。
- 金额隐私不依赖页面局部 InheritedWidget 的隐式跨 route 继承。调用方必须在路由边界显式读取现有偏好并绑定 `masked`/`FxAmountVisibility`。

## 2. 账本、分组与币种范围

- `SessionCubit` 是当前分组/账本/默认币种的共享来源；`SessionState.currentGroupId/currentBookId/defaultCurrency` 从当前对象派生。
- `switchGroup` 会重拉账本；`switchBook` 只切当前账本；`selectGroupAndBook` 保证分组和账本同属一组。默认币种优先账本，其次分组。
- 常规账单、统计、单据和 IO 以当前 `bookId` 请求；账户以当前 `groupId` 请求；周期记账另有跨所有分组账本的聚合服务。选择器本身不改变请求范围。
- 不允许只过滤当前页冒充全局搜索，不允许合并不同币种或不同百分比分母。

## 3. 金额格式、精度、隐私与前景

- 唯一持久化隐藏开关仍为 `PreferencesCubit._hideAmountsKey = fortune.preferences.dashboard.hideAmounts`，状态保存在 `DashboardDisplayPreferences.hideAmounts`。本轮没有新增第二份开关或修改持久化逻辑。
- `FxMoneyText` 不自行读取偏好；默认 `masked=false`、`maskedText=FxMoneyFormatter.hiddenPlaceholder`、`fontSize=17`、`fontWeight=600`。金额格式继续使用 `FxMoneyFormatter`、现有整数分/财务服务路径和币种符号，本轮未用浮点重算业务账目。
- 默认 `compactWhenNeeded=false`：可见金额保持系统 TextScaler 和完整精确值。空间足够时保留单个完整字符串 `Text`，不改变短金额消费者结构；空间不足时按货币/符号、千分位数字组和小数 token 重排（例如 `¥1,234,` / `567,` / `890.` / `12`），不拆数字组，最后整数组与小数合并（如 `890.12`），不孤立小数位、不裁切。`Semantics.label` 始终保留完整值；未掩码且紧凑显示时，Tooltip 保留完整精确值。
- `masked=true`：可见文本与 Semantics 均为掩码，不生成包含精确值的 Tooltip。显示、读屏和 Tooltip 的本地行为测试见 `test/fx/components/fx_money_text_test.dart`。分享/导出仍由各自 owner 显式绑定同一偏好，本轮未改文件交付。
- `compactWhenNeeded=true` 是调用方明确选择的紧凑模式，可能压缩或省略可见文本；不能据此把精确值暴露给掩码语义。
- 用户保存的 `FxFinanceColors`/`FinanceColorPreferences` 业务色不改写，继续用于色点、色条和图形填色。`FxMoneyText` 未显式传 `color` 时默认使用当前主题的 `textPrimary`，不再把低对比业务色直接当作普通金额小字前景。

迁移示例：

```dart
// before：紧凑可见值与读屏/隐私边界容易混淆，默认可能 ellipsis。
FxMoneyText(amount: amount, billType: type, compactWhenNeeded: true);

// after：路由边界显式绑定唯一偏好；默认完整换行，业务色不代替可读前景。
FxMoneyText(
  amount: amount,
  billType: type,
  masked: preferences.dashboard.hideAmounts,
);
```

## 4. 取消、明确清空与选中

| 入口 | 取消 | 明确清空 | 提交选中 |
| --- | --- | --- | --- |
| `showFxOptionPickerResult<T>` | `FxSelectionResult.cancelled()` | `FxSelectionResult.cleared()` | `FxSelectionResult.selected(value)` |
| `showFxOptionPicker<T>`（兼容旧入口） | `null` | `null` | `T` |
| `showFxMultiOptionPicker<T>` | `null` | 确认空集 `[]` | 非空或空 `List<T>` |
| `FxTreePicker.show<T>` | `null` | 单选清空立即返回 `[]`；多选清空草稿后确认返回 `[]` | `List<T>` |
| `FxSelectRow` | 由上层选择器决定 | 独立 `onClear`，语义名称包含字段名，最小触区 44×48 | 主行 `onTap` |

`FxSelectionKind` 只有 `cancelled / cleared / selected`。只有 `selected` 的 `value` 非空；取消不得调用 save/clear，清空必须显式到达调用者。需要区分清空的调用方必须使用 Result 入口或既有 `List + null` 合同，旧 nullable 包装仅保留兼容，不能新增“取消和清空都为 null”的业务调用。

迁移示例：

```dart
// before：取消与清空都进入 picked == null。
final picked = await showOptionPicker<PayeeOption>(...);
bloc.add(PayeeChanged(picked?.payeeId, picked?.payeeName));

// after：取消不改状态；清空明确写空；选中写具体值。
final result = await showOptionPicker<PayeeOption>(...);
if (result.kind == FxSelectionKind.cancelled) return;
final payee = result.value;
bloc.add(PayeeChanged(payee?.payeeId, payee?.payeeName));
```

已原子适配全部 `showOptionPicker` 直接消费者：`bill_editor_page.dart` 的交易对象/单据，`extras_section.dart` 的附加费用类别。其它 `showFxOptionPicker` 旧入口消费者保持原行为；树选择器三个直接消费者继续消费 `List + null`。

## 5. 弹层、未保存离开与忙碌退出

- 新增可组合 `FxSheetPopGuard(hasUnsavedChanges:, isBusy:, child:)`。未修改直接退出；有修改时提供“继续编辑/放弃修改”；确认放弃后才 pop；忙碌时阻止遮罩、返回、拖拽与关闭按钮退出。
- 成功提交前由调用方把 `hasUnsavedChanges` 设为 false，再正常 pop，从而解除保护。不要把所有 sheet 一律改为不可关闭。
- `FxSheetPopGuard` 不处理键盘或安全区；`FxSheet` 仍是唯一 inset 责任层，避免双重 padding。
- `FxConfirmSheet` 在 `onConfirm` pending 期间内部挂接 `isBusy=true`，外层不能再 dismiss。false 或异常保持打开并显示 `failureMessage`；未提供时显示本地化默认“操作未完成，请重试”。成功 `pop(true)`，取消 `pop(false)`。

```dart
FxSheetPopGuard(
  hasUnsavedChanges: dirty && !submitSucceeded,
  isBusy: submitting,
  child: form,
);
```

## 6. 输入、按钮、卡片、文本与共享组件

- 主题保持 34/22/17/15/13 字阶、400/500/600/700 用途、4pt 网格、44/48 最小触区和 12/16/24 圆角。全局 `InputDecorationTheme` 不注入几何边框；`FxTextField` 自己管理 1px/2px 边界，原有无边框金额输入合同不变。
- `FxTextField` 默认点击外部 unfocus；`FxAmountInput` 的数字键盘 Done 也结束编辑。常见粘贴内容先去除空格、千分位和 `¥/￥/$/€/£`，兼容全角数字/小数点/负号，再执行原两位小数校验；非法内容不被静默改为 0。
- `FxSelectRow` 清除目标至少 44×48，字段名进入清除语义；标签按实际排版宽度与 TextScaler 决定行内或上下重排，重排时按空格 token 保持英文单词完整；完整值与动作不缩水。`FxListItem` 标题默认完整换行，副标题默认最多 3 行，长 trailing 在大字时移到下一行。
- `FxTagChip` 静态标签无按钮语义；可操作/删除标签使用 Ink 和至少 44 的命名目标。`FxChip` 背景与边框绘制在 Material 上，Ink 之上不再放不透明 Container。`FxSegmented` 面向少量选项，内容决定高度、不使用单行省略；TextScaler > 1.3 时每个选项独占整行，避免长中英文在等宽列中断词，更多或很长选项使用共享选择列表。
- `FxStateView.loading/error/empty` 均新增可选 `title`，用于保留对象和任务上下文；恢复动作继续使用 `onRetry/retryLabel`。`FxFeedback` 不再向读屏拼接英文 `tone.name`，也不再主动替换尚未结束的旧 SnackBar；字段错误继续由 `FxTextField.errorText` 持久承载。
- `FxActionSheet` 普通图标使用 `textSecondary`，仅选中/危险强调。普通 `FxCard/FxSelectRow/FxListItem` 激活不发送 selection haptic，避免与回调重复触感；实际选择 chip/segmented/tree 保留选择反馈。
- `FxBentoGrid` 在窄于 360 或中等宽度且大字时转为内容固有高度的单列摘要清单；普通网格动画统一 `FxMotion.resolve`。这不是可访问排序协议，Dashboard/Stats 的上移/下移、跨屏拖动和占位行为仍由 S7-A/S8-A 实现。
- 折线/柱状网格使用 `separator` 而非输入/卡片 `border`；甜甜圈中心金额 17、标题 13。`FxChartPalette.colorAt` 支持 Brightness，Bar/Donut 默认分类填色随亮暗主题，显式业务色优先且不改存储；StatsPalette 等显式消费者后续核对。图表数据替代语义保持原有 `FxChartSemanticsOverlay`。

## 7. 数据和文件结果

- loading/error/unknown/zero/empty 不可互相替代；取消、失败和明确空集不可混同。
- 文件导出必须交付 bytes/文件名和用户可取动作；临时路径 toast 不等于导出完成。本轮未改文件交付或真实业务数据。

## 8. 合同变更与验收门槛

- S1-A 本地合同已冻结；任何共享签名、默认行为或返回协议变化须走 S1-E，附全部消费者适配与回归证据。
- `localGate` 只代表当前源码的测试、分析和实际 Flutter fixture 查看；不等于真机、VoiceOver/TalkBack、平台编译、服务器联调或发布通过。
- DS-021—DS-024 的排序等效操作、跨屏路径、拖动占位和按下即拖属于 Dashboard/Stats 消费者，S1-A 未关闭。DT/CX 全局编号也不得由本阶段单独宣布 `VERIFIED_CLOSED`。
