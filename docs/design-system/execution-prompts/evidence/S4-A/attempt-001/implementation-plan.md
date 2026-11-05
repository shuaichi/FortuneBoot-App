# S4-A 实施计划

目标：在 `878b2dafa8fc18a3f5e7f2e08372b9b491f256de` 起点上完成账单连续流的账期定位、筛选恢复、统一汇总和大字/窄屏重排，不修改服务端契约或真实账务数据。

约束：只改 `lib/features/bills/`、同域测试/渲染 fixture、本阶段必要 ARB 与生成文案，以及本阶段 evidence/runtime/handoff；不 commit/push，不开启 S4-B。

## 1. 基线与 RED

- 保存工具版本、源码 SHA、当前 `flutter test --no-pub test/features/bills` JSON 与真实计数。
- 新建 BillsBloc fake-service 测试，先证明多月加载、快速定位所需的翻页/失败保留、刷新和分页行为；失败断言必须对应当前缺陷。
- 新建 BillsPage/BillsPeriodPicker/BillsFilterSheet/BillTile widget 测试，先证明旧箭头、快速跳转、筛选零结果恢复、字段定位、动态日头、金额隐私与滑动对象问题。

## 2. 账期导航与可滚动控制区

- 仅固定标题与筛选入口；账期导航、账期起止、汇总和有效筛选摘要进入同一个连续 CustomScrollView。
- 旧/新箭头按已加载 anchors 的真实索引计算，并保留按需分页；新增年月选择器，已加载账期直接定位，未加载历史账期按页加载直到出现或明确无更多/失败。
- 分页失败保留已读列表并显示错误与重试；刷新失败保留旧内容。空筛选结果提供清除和调整。

## 3. 统一业务排版

- 抽取账期汇总组件，当前与历史共用无阴影、0.5 装饰线的表面；13px 标签、17px 中等字重金额，中性文字配方向标签，不用财务色充当小字前景。
- 窄屏/2x 字下汇总和历史标题按内容换行；金额完整显示并延续统一 masked 合同。
- 日粘性头根据系统 TextScaler 与行高计算 extent；侧滑仍分别复制/删除并确认，附件/待确认/筛选徽章使用业务语义。

## 4. 筛选分层与字段校验

- 常用条件保留标题、类型、金额、日期；确认/统计/分类/标签/账户/对象/成员归入高级筛选，已有高级条件时默认展开。
- 标题与金额使用带显式标签的 Fx 输入；金额粘贴复用共享正规化；非法最小/最大值和 min>max 显示不同字段错误并聚焦/滚动到首错。
- 列表显示实际生效条件摘要；清除会发起真实空 filter 请求，不在客户端过滤当前页。

## 5. 验证与交接

- 每个行为缺陷保存 RED 日志，最小实现后跑 GREEN；仅格式化本阶段 Dart 文件。
- 跑 `test/features/bills`、真实业务 Widget 渲染矩阵、全量 `flutter test --no-pub --reporter json`、`flutter analyze --no-pub`、diff check 和 pack runtime 校验。
- 生成并实际查看跨年、多币种、隐藏、失败、320/390/440、1x/2x、亮暗截图；记录设备/读屏/联调 NOT_RUN。
- 写逐项 issue-checks、源码 SHA、命令/退出码/计数和 handoff；原子更新仅 S4-A 与 nextStage=S4-B，不写 VERIFIED_CLOSED。
