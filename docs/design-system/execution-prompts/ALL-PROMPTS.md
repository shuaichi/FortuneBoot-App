# 完整可复制提示词合集

按README的01—28序号执行；条件提示词仅按触发条件使用，每份完整独立。


---

主线 01 · 新开S0会话

# S0-A｜基线接管、问题分诊与跨阶段验收约定

**使用位置：新开S0会话。本轮只执行S0-A。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S0-A。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S0-A以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S0-A/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S0-A.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S0-A.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S0-A及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：无；这是本包入口。
必须读对应handoff与runtime。S0-A需创建reference/contracts-current.md和`reference/component-consumers.json`的事实初稿；S1-A完善后冻结兼容合同。

## 本阶段允许写入范围

本阶段业务源码、测试源码、pubspec/平台配置、原审计报告均只读；只可写本包当前阶段报告、evidence、当前阶段runtime记录。必要的独立验证探针仅放本阶段evidence，不改已有测试来制造通过。

## 必须完成的具体工作

1. 只读接管当前工作区与既有底座，不重做主题、不清理未提交成果。逐一核对本包334个审计ID（277模块、45 DT、12 CX），原报告只读；为已修复/不可复现/外部依赖保留证据，不能为追求清零删除条目。
2. 核对reference/generation-baseline.json、原verification.json、真实HEAD/分支/diff/未跟踪文件；既有387通过1跳过和1159诊断只是历史基线，记录本轮实跑，不把87f7203 reset回来。
3. 读取参考契约和所有主线阶段文件，建立contracts-current.md、page-migration-map.md和external-gaps.md；确认页面路由、共同组件调用方、账本/分组范围、金额隐私源、取消/清空/确认语义、常用选择器与草稿离开策略。具体API由S1-A兼容实现，不在本轮编写业务代码。
4. 先核有争议接口的现有文档和客户端请求/响应模型：统计区间、混币报告、协作角色、周期时区及模板、验证码替代通道、性别清空、导入导出能力。能证明的写来源和准确语义；不能证明的标外部缺口并说明哪些阶段不能声称已闭环，不臆造服务端接口或改财务算法。
5. 为V01—V69建立页面/状态/源文件对应；另补没有原图的账户、错误/空态、暗色、年历/小票、单据创建/核对等覆盖计划。截图基线没有提交哈希，不能将它当精确像素golden。
6. 明确阶段状态、来源SHA、截图产物、审查回流与交接格式；缺失的环境准备在授权的本地目录完成。纯环境缺口可以分层记录，不能偷偷降低验收标准。

## 本阶段主责问题

本小节没有额外分配条目；仍须完成上文具体任务和验收。

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

本小节没有额外分配条目；仍须完成上文具体任务和验收。

## 决定性验证

按下列验收要求执行必要的定向/全量检查，不能凭历史计数判定。

1. 执行一轮当前全套Flutter测试与分析，解析真实测试数量、失败、错误和跳过；保存诊断列表用于后续差异比较。
2. 确认原审计334个ID与映射逐一一致；本轮不把任何待审条目标为VERIFIED_CLOSED。
3. 只读核对现有输入框兼容/品牌卡反馈/按钮大字/附件回归测试及明暗预览，不复制旧成功为本轮成功。

## 视觉证据与验收

- 打开原69图联系表或原图检查已记录的映射；预览仅作底座参照。没有图片读取能力时明确视觉证据缺口。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S0-A.md`、`runtime/issue-checks/S0-A.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S1-A，新开S1会话，文件docs/design-system/execution-prompts/prompts/02-S1-A.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 02 · 新开S1会话

# S1-A｜共享令牌、交互与可访问性契约补齐

**使用位置：新开S1会话。本轮只执行S1-A。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S1-A。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S1-A以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S1-A/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S1-A.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S1-A.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S1-A及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S0-A。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/fx/`
- `lib/core/money/`
- `lib/core/errors/`
- `lib/core/feedback/`
- `lib/core/preferences/finance_color_preferences.dart`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 先核现有主题、FxText、FxCard和已通过的回归；保持34/22/17/15/13字阶、400/500/600/700用途、4pt网格、44/48最小触区、12/16/24圆角和表面/边框职责，不重新发明另一套品牌语言。对已修复DT项只验行为。
2. 补齐FxTagChip/FxSelectRow/FxTreePicker/FxChip/FxSegmented/FxListItem/FxStateView/FxConfirmSheet的确切剩余问题：触区、键盘/读屏、选中与禁用语义、长值大字重排、可见反馈。静态标签不伪装按钮，可操作chip不以不透明Container遮住Ink。
3. 为选择器冻结取消/明确清空/选中三种可区分结果，优先复用现有list+null语义；单值nullable不足时仅在共享边界引入一个最小结果类型。保留旧入口或原子迁移其直接调用方，禁止每模块建立自己的返回协议。
4. 为弹层提供可组合的未保存离开与忙碌期退出机制；未改动直接退出，有变更才提示，取消确认继续编辑，成功提交解除保护。键盘和安全区只在明确责任层处理一次；不要把所有sheet一律改成不可关闭。
5. 金额格式、隐私、精确值与前景色冻结契约：继承既有用户偏好源，不新增第二份持久化隐藏开关；路由边界显式传递/绑定；显示值、Semantics、Tooltip、分享导出分别验证；用户保存的业务色不改写，可读金额前景与装饰色区分。
6. 保留无边框金额输入：全局InputDecorationTheme不注入会覆盖InputBorder.none的几何；FxTextField负责自己的边界。保留品牌实色卡可见反馈、按钮按内容增高，禁用状态也需提供有意义名称。
7. 把新增/修改接口、默认行为、迁移前后示例和全部消费者写入本包reference/contracts-current.md、component-consumers.json；共享变化只能改必要的直接调用适配，不顺便重排业务页。

## 本阶段主责问题

本小节没有额外分配条目；仍须完成上文具体任务和验收。

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| DS-021 | P2 | 长按拖动是唯一排序方式，缺少可访问的等效操作 | docs/design-system/audit-dashboard-stats.md:177 |
| DS-022 | P2 | 拖动时禁止列表滚动，跨屏排序缺少路径 | docs/design-system/audit-dashboard-stats.md:185 |
| DS-023 | P2 | 统计拖动占位骤缩为 72，打乱当前布局参照 | docs/design-system/audit-dashboard-stats.md:193 |
| DS-024 | P2 | 移动浏览器编辑首页时直接按下即拖，和滚动竞争 | docs/design-system/audit-dashboard-stats.md:201 |
| BO-004 | P2 | 共性｜表单的视觉标签没有形成明确的输入语义 | docs/design-system/audit-bills-orders.md:69 |
| BO-005 | P2 | 共性｜数字键盘与长表单缺少一致的结束编辑路径 | docs/design-system/audit-bills-orders.md:78 |
| BO-006 | P2 | 共性｜金额输入对常见粘贴内容静默拒绝 | docs/design-system/audit-bills-orders.md:87 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |
| CX-01 | P2 | FxTagChip 的删除图标13px、裸GestureDetector，无最小触区与明确删除对象；将静态tag与可操作chip分成清楚的呈现。 | docs/design-system/2026-11-05-global-audit.md:339 |
| CX-02 | P2 | FxSelectRow清空目标32×48，固定96标签列、单行当前值；大字时应上下重排，清除语义带字段名。 | docs/design-system/2026-11-05-global-audit.md:340 |
| CX-03 | P2 | FxTreePicker展开按钮40×40，树深度缩进进一步减少名称宽度；搜索后仍需父路径上下文和足够触区。 | docs/design-system/2026-11-05-global-audit.md:341 |
| CX-04 | P2 | 分组切换_GroupPill以caption+上下8生成约32px高目标；没有selected/button语义和键盘路径。不能因颜色显著就当可访问性完成。 | docs/design-system/2026-11-05-global-audit.md:342 |
| CX-05 | P2 | FxActionSheet普通操作图标统一primary，导航、复制、编辑全部蓝；用中性图标，选中和危险才强调。 | docs/design-system/2026-11-05-global-audit.md:343 |
| CX-06 | P2 | FxListItem主标题/副标题常单行；trailing没有预留长值预算；保持行内关联，并提供大字重排。 | docs/design-system/2026-11-05-global-audit.md:344 |
| CX-07 | P2 | FxSegmented先按等分列宽再单行ellipsis，增高无法修复长名称宽度；少项分段/更多项选择列表，避免同一个控件承接所有基数。 | docs/design-system/2026-11-05-global-audit.md:345 |
| CX-08 | P2 | FxBentoGrid固定2列起和rowSpan，不考虑文字内容高度，且animationDuration未统一resolve；对编辑态提供紧凑摘要清单，减少动态时避免位移动画。 | docs/design-system/2026-11-05-global-audit.md:346 |
| CX-09 | P2 | FxStateView空态/失败都使用48图标＋居中短文，场景上下文弱；真实空态、筛选零结果、首次创建与加载失败使用不同任务说明和恢复动作。 | docs/design-system/2026-11-05-global-audit.md:347 |
| CX-10 | P2 | FxFeedback读屏标签拼入英文tone.name，4秒toast承载字段错误且新提示替掉旧提示；字段错误改持久就地，状态播报使用本地化文本。 | docs/design-system/2026-11-05-global-audit.md:348 |
| CX-11 | P2 | FxConfirmSheet等待期间只禁内部按钮，外层默认可dismiss；failureMessage缺失时失败没有可见解释。调用侧明确忙碌期退出和失败文案。 | docs/design-system/2026-11-05-global-audit.md:349 |
| CX-12 | P2 | 图表网格线仍复用border、甜甜圈金额12、中心标题11；图和表的视图切换不应让数据可读性退化。 | docs/design-system/2026-11-05-global-audit.md:350 |

## 决定性验证

```sh
flutter test --no-pub test/fx test/core/money test/core/errors
```

1. 运行test/fx、test/core/money、test/core/errors和受接口变化影响的已有测试；补充三态选择、离开保护、忙碌关闭、长文本/金额、明暗反馈与隐私语义行为测试。
2. 320宽/2倍字下所有操作可达；无边框金额正常/聚焦仍不出现主题描边；蓝底卡按压亮度有变化且Tab焦点可见。
3. 取消不得触发save/clear，clear应能明确到达调用者；校验最小区域而不是只检查Icon.size。

## 视觉证据与验收

- 生成/打开共享控件亮暗展示，至少含320/390宽、1与2倍字、长中文/英文、控件焦点/禁用/选中、长金额及多行CTA；不使用合成HTML替代Flutter。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S1-A.md`、`runtime/issue-checks/S1-A.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S2-A，新开S2会话，文件docs/design-system/execution-prompts/prompts/03-S2-A.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 03 · 新开S2会话

# S2-A｜共享底座独立审查

**使用位置：新开S2会话。本轮只执行S2-A。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S2-A。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S2-A以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S2-A/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S2-A.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S2-A.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S2-A及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S1-A。
必须读对应handoff与runtime。

## 本阶段允许写入范围

本阶段业务源码、测试源码、pubspec/平台配置、原审计报告均只读；只可写本包当前阶段报告、evidence、当前阶段runtime记录。必要的独立验证探针仅放本阶段evidence，不改已有测试来制造通过。

## 必须完成的具体工作

1. 只读独立检查S1-A实际diff、接口契约、所有直接调用适配和新旧测试，不能使用实现者的“已完成”代替判断；只写本轮审查及证据。
2. 检查全局主题没有意外改变无边框金额、平台系统控件、按钮底部区域高度、财务色存储；验证picker取消与清空、modal离开/忙碌、语义与隐私合同可供业务消费。
3. 重新执行关键行为测试并打开实际Flutter图片。核对源码SHA与渲染来源；仅有组件代码或截图文件存在不算视觉通过。
4. 将每个真实缺陷写入reviews/S2-A/attempt-N/review.md与review.json，包含复现、文件行、级别、ownerSession=S1、repairPrompt=S1-B、受影响契约。存在基础问题就停止，下一步明确返回S1-B，再回本S2会话重新执行S2-A。
5. 基础通过才放行S3-A；如果没有问题，S1-B记NOT_REQUIRED。外部契约缺口保留在外部验收层，不冒充本地已修。

## 本阶段主责问题

本小节没有额外分配条目；仍须完成上文具体任务和验收。

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

本小节没有额外分配条目；仍须完成上文具体任务和验收。

## 决定性验证

```sh
flutter test --no-pub test/fx test/features/bill_editor/presentation/bill_editor_order_flow_test.dart
```

1. 独立运行test/fx及受影响的直接调用测试；需要新增探针时只能写evidence目录，不修改仓库既有测试。
2. 确认S1-A各必须交付的契约门槛通过；读取新增诊断，基线差异不能仅比较总数。

## 视觉证据与验收

- 独立查看亮暗、大字、键盘、品牌卡/输入框/选择器图，并记录观察事实与设计判断。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S2-A.md`、`runtime/issue-checks/S2-A.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：通过：S3-A。需修复：回S1执行repairs/S1-B.md，再回本S2重新执行当前S2-A提示词，使用新attempt。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 04 · 新开S3会话

# S3-A｜主壳导航、当前范围与跨页返回

**使用位置：新开S3会话。本轮只执行S3-A。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S3-A。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S3-A以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S3-A/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S3-A.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S3-A.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S3-A及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S2-A。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/core/shell/`
- `lib/core/navigation/`
- `lib/core/session/`
- `lib/core/app/fx_app.dart`
- `lib/features/*/*registration.dart`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 统一当前分组/账本与进入页面的范围说明。快速切换时旧数据不能继续以新范围名展示并可操作；保留合法旧内容时明确更新中，操作绑定实际对象与范围。
2. 按真实约束确认主壳/Scaffold/页面安全区、导航栏和FAB避让责任，移除重复预留；最后一行可见可点，旋转/键盘时不额外出现大片空白。
3. 主导航选中态、标签大字和Tab状态保留统一；记账主操作在有意义页面可达，只读身份在入口表达权限，不让用户连续点击无结果。
4. 修Web深链恢复与缺路由参数时空白页，保留目标并等会话恢复后进入；需登录/无权限/目标失效有明确返回出口。不得绕过登录或强行恢复不存在对象。
5. 保留Apple原生路由与返回语义；给后续页面阶段提供相同入口骨架，loading/error不能把返回控件一起替换。直接修改注册入口仅限本轮范围/参数契约。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| DS-003 | P2 | 账本、分组两种数据范围缺少就地说明 | docs/design-system/audit-dashboard-stats.md:31 |
| BO-071 | P2 | 单据入口｜缺少必需路由参数时显示完全空白页 | docs/design-system/audit-bills-orders.md:674 |
| FB-NAV-02 | P2 | 主壳底部避让量可能重复预留导航栏，末尾留下大空白 | docs/design-system/audit-system.md:624 |
| FB-NAV-03 | P2 | Web 深链恢复直接回首页，原目标丢失 | docs/design-system/audit-system.md:632 |
| FB-NAV-04 | P2 | 手机主操作随 Tab 消失，宽屏却保持全局可用 | docs/design-system/audit-system.md:640 |
| FB-NAV-05 | P2 | 只读身份仍看到可执行的记账按钮，点击后才解释权限 | docs/design-system/audit-system.md:648 |
| FB-NAV-06 | P3 | 手机底部导航固定高度，需验证大字标签与选中态 | docs/design-system/audit-system.md:656 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| MG-C17 | P2 | 多数管理页缺少当前账本/分组的可见上下文 | docs/design-system/audit-management.md:211 |
| FB-AUT-11 | P3 | 认证页内部动画没有遵循减少动态效果设置 | docs/design-system/audit-system.md:156 |
| FB-NAV-01 | P2 | 资料详情主动禁止 pop，使 Apple 原生返回手势难以成立 | docs/design-system/audit-system.md:616 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/core/navigation test/core/session test/core/shell
```

1. 运行test/core/navigation、test/core/session、test/core/shell；覆盖切换分组/账本竞态、旧数据动作、登录后深链、参数缺失、返回结果。
2. 320/390/440宽、2倍字、横屏、键盘/SafeArea下测最后一个条目与FAB命中，区分真实重复inset与设计留白。

## 视觉证据与验收

- 主壳四tab、长账本名、只读身份、无账本、深链失败；亮暗与大字。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S3-A.md`、`runtime/issue-checks/S3-A.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S4-A，新开S4会话，文件docs/design-system/execution-prompts/prompts/05-S4-A.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 05 · 新开S4会话

# S4-A｜账单列表、账期导航与筛选

**使用位置：新开S4会话。本轮只执行S4-A。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S4-A。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S4-A以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S4-A/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S4-A.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S4-A.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S4-A及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S3-A。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/features/bills/`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 保持连续流水单一表面；明确本账期起止和筛选摘要，历史月份可定位，已加载月份不被错误禁用；提供合理的快速账期跳转而非无限点箭头。
2. 把常用条件与高级筛选分层，显示有效范围和当前条件，空结果可以清除/调整；金额区间错误绑定具体字段，不只有泛化toast。
3. 金额、标题、日期与费用信息重新排主次，当前与历史汇总使用一致表面；金额优先完整，日期粘性头大字按内容增高。
4. 标题/筛选/汇总等固定控制在小高度或大字时收敛，不永久吞掉正文；不能用缩小字号或隐藏金额达到布局通过。
5. 保留侧滑复制/删除的明确语义与确认，配对前景、权限提示、加载/分页/刷新不抹去已读上下文。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| BO-011 | P1 | 账单｜已加载历史月份仍可能被禁用的“更早”箭头挡住 | docs/design-system/audit-bills-orders.md:133 |
| BO-012 | P2 | 账单｜月份定位只有逐次箭头，没有快速跳到指定账期 | docs/design-system/audit-bills-orders.md:142 |
| BO-013 | P2 | 账单｜筛选条件只剩数量角标，空结果不能就地恢复 | docs/design-system/audit-bills-orders.md:151 |
| BO-014 | P2 | 账单｜日期粘性头固定 32 高度，没有适配字号和行高 | docs/design-system/audit-bills-orders.md:160 |
| BO-015 | P2 | 账单｜当前汇总和历史月份仍使用两种表面语言 | docs/design-system/audit-bills-orders.md:169 |
| BO-016 | P2 | 账单｜紧凑摘要和历史标题缺少窄屏重排 | docs/design-system/audit-bills-orders.md:178 |
| BO-017 | P2 | 账单筛选｜校验只显示泛化金额错误，不定位不可见字段 | docs/design-system/audit-bills-orders.md:187 |
| BO-018 | P2 | 账单筛选｜大量异构条件等权展开，缺少常用与高级层级 | docs/design-system/audit-bills-orders.md:196 |
| BO-019 | P3 | 账单｜图标说明与徽标文案不够贴合业务任务 | docs/design-system/audit-bills-orders.md:205 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| BO-004 | P2 | 共性｜表单的视觉标签没有形成明确的输入语义 | docs/design-system/audit-bills-orders.md:69 |
| BO-006 | P2 | 共性｜金额输入对常见粘贴内容静默拒绝 | docs/design-system/audit-bills-orders.md:87 |
| BO-009 | P2 | 共性｜关键状态和对账辅助金额被压到小号字层级 | docs/design-system/audit-bills-orders.md:114 |
| BO-010 | P2 | 共性｜强色表面的配对前景已部分修正，媒体预览关闭对比仍待核对 | docs/design-system/audit-bills-orders.md:123 |
| BO-021 | P2 | 记账编辑器｜表单不显示手续费/优惠后的最终收付款核对结果 | docs/design-system/audit-bills-orders.md:223 |
| BO-063 | P2 | 账单详情｜列表与详情主金额口径不同，但没有明确标注 | docs/design-system/audit-bills-orders.md:602 |
| BO-074 | P2 | 共性｜列表顶部多层控制始终固定，缺少小高度和大字时的收敛 | docs/design-system/audit-bills-orders.md:701 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/features/bills
```

1. 运行test/features/bills，覆盖多月历史已加载、快速跳转、有效筛选0结果、非法金额区间、短列表刷新和分页失败。
2. 金额隐藏下Text/语义/Tooltip都无原值；长标题/大金额/2倍字粘性头不溢出；点击滑动后的操作对象正确。

## 视觉证据与验收

- 原V08/V13/V14对照；追加历史跨年、多币种分组、隐藏、失败与2倍字样本。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S4-A.md`、`runtime/issue-checks/S4-A.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S4-B，回到已有S4会话，文件docs/design-system/execution-prompts/prompts/06-S4-B.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 06 · 回到已有S4会话

# S4-B｜账单详情、金额口径与附件阅读

**使用位置：回到已有S4会话。本轮只执行S4-B。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S4-B。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S4-B以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S4-B/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S4-B.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S4-B.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S4-B及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S4-A。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/features/shared/presentation/bills/`
- `lib/features/shared/data/bill_attachment*`
- `lib/features/bills/presentation/widgets/bill_tile.dart`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 详情主金额与列表金额口径一致或显式标明交易额/实付额差异，费用/优惠说明可核对，不修改账务存储算法。
2. 详情完整呈现标签、附加分类/备注、是否统计/确认等关键状态；“+N”必须有查看完整内容的路径，长备注按段落阅读而非右对齐字段值。
3. 非图片附件有文件名、类型和已支持的打开/保存动作，图片预览关闭按钮在黑底保持对比；宽屏详情有明确关闭。无平台能力时清楚解释，不伪造打开成功。
4. 来自单据流水的详情继承来源动作/权限/业务组件，不能把来源禁用动作在通用详情里重新放开；路由参数保留，跨单据契约由S6消费。
5. 编辑/确认等主要动作稳定可达，复制/删除次级；关闭、返回和保存后返回原处一致，金额隐藏完整跨详情与附件相关说明。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| BO-063 | P2 | 账单详情｜列表与详情主金额口径不同，但没有明确标注 | docs/design-system/audit-bills-orders.md:602 |
| BO-064 | P1 | 账单详情｜详情中的“+N”仍不可展开，完整标签无法查看 | docs/design-system/audit-bills-orders.md:611 |
| BO-065 | P2 | 账单详情｜附加费用的分类与备注信息在阅读中丢失 | docs/design-system/audit-bills-orders.md:620 |
| BO-066 | P2 | 账单详情｜非图片附件只有相同文件图标，没有可见名称或打开方式 | docs/design-system/audit-bills-orders.md:629 |
| BO-067 | P2 | 账单详情｜长备注仍按固定键值表右对齐，标题也永久截成两行 | docs/design-system/audit-bills-orders.md:638 |
| BO-068 | P2 | 账单详情｜阅读页没有明确说明是否纳入统计等关键状态 | docs/design-system/audit-bills-orders.md:647 |
| BO-069 | P1 | 共享账单详情｜从单据流水进入预览后，动作可用性与来源行不一致 | docs/design-system/audit-bills-orders.md:656 |
| BO-070 | P2 | 账单详情｜宽屏弹窗缺少显式关闭入口 | docs/design-system/audit-bills-orders.md:665 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| BO-007 | P2 | 共性｜确认、作废、归档等请求进行中没有对应的可见忙碌状态 | docs/design-system/audit-bills-orders.md:96 |
| BO-010 | P2 | 共性｜强色表面的配对前景已部分修正，媒体预览关闭对比仍待核对 | docs/design-system/audit-bills-orders.md:123 |
| BO-072 | P3 | 共性｜部分用户文案绕过本地化且日期格式不一致 | docs/design-system/audit-bills-orders.md:683 |
| BO-073 | P1 | 单据详情｜利息或费用动作进入编辑器时未带对应业务组件 | docs/design-system/audit-bills-orders.md:692 |
| BO-074 | P2 | 共性｜列表顶部多层控制始终固定，缺少小高度和大字时的收敛 | docs/design-system/audit-bills-orders.md:701 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/features/shared/presentation/bills test/features/bills/presentation/widgets/bill_tile_test.dart
```

1. 运行test/features/shared/presentation/bills及bill_tile_test；覆盖超过默认tag展示数、含费用/优惠、长备注、图片/非图片附件、黑底关闭、来源权限与宽屏。
2. 生成交易额与实付不同fixture逐值核对；隐藏后语义和确认文字不泄漏；来源单据编辑带正确component。

## 视觉证据与验收

- 原V09/V10及完整备注、多标签、文件附件、错误详情、暗色/宽屏关闭。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S4-B.md`、`runtime/issue-checks/S4-B.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S5-A，新开S5会话，文件docs/design-system/execution-prompts/prompts/07-S5-A.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 07 · 新开S5会话

# S5-A｜记账编辑器与输入保全

**使用位置：新开S5会话。本轮只执行S5-A。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S5-A。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S5-A以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S5-A/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S5-A.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S5-A.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S5-A及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S4-B。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/features/bill_editor/`
- `lib/features/shared/data/bill_attachment*`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 日常单分类记账以真正可编辑的金额/分类为主；拆分按需展开，保留多分类支持及总额/实际收付款核对，不能删已有业务能力换简洁。
2. 用行为测试覆盖离开脏状态、只改借贷金额、切类型清空、取消选择被当清空、重复校验无提示。修改类型会丢现值时明确保留或确认；取消不发变更事件。
3. 账号、类别、对象、单据、成员、标签选择使用S1合同，空/加载/失败可恢复，账户可检索且区分同名/币种/尾号。锁定字段说明原因。
4. 金额粘贴支持经已确认locale解析的常见格式，不能把无法解析/空值静默存0；转账/单据输入显示币种。保持整数分/精度路径，不引入浮点误差。
5. 分类与金额布局随窄宽和大字重排；增加/移除分类费用有足够触区与恢复，键盘下一项/完成、拖动收起、首错聚焦和底部保存一致。
6. 附件已随字体增长的修复必须保留；继续补全预览、可读文件名、移除对象语义与进度/失败对象。提交时快照与可见输入一致，不允许忙碌期间修改成未提交值。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| BO-020 | P2 | 记账编辑器｜日常单分类记账仍先呈现只读大金额和完整拆分结构 | docs/design-system/audit-bills-orders.md:214 |
| BO-021 | P2 | 记账编辑器｜表单不显示手续费/优惠后的最终收付款核对结果 | docs/design-system/audit-bills-orders.md:223 |
| BO-022 | P1 | 记账编辑器｜表单校验靠瞬时反馈，重复提交可能完全无新提示 | docs/design-system/audit-bills-orders.md:232 |
| BO-023 | P1 | 记账编辑器｜仅修改借贷单笔金额不会触发未保存提醒 | docs/design-system/audit-bills-orders.md:241 |
| BO-024 | P1 | 记账编辑器｜切换类型会立即清空已输入核心内容 | docs/design-system/audit-bills-orders.md:250 |
| BO-025 | P1 | 记账编辑器｜单选弹层取消与清空没有区分 | docs/design-system/audit-bills-orders.md:259 |
| BO-026 | P2 | 记账编辑器｜单据金额输入传入币种却没有显示 | docs/design-system/audit-bills-orders.md:268 |
| BO-027 | P2 | 记账编辑器｜分类与金额固定 4:3 横排，窄屏上核心输入空间不足 | docs/design-system/audit-bills-orders.md:277 |
| BO-028 | P2 | 记账编辑器｜新增分类和费用是按文字自然高度的目标 | docs/design-system/audit-bills-orders.md:286 |
| BO-029 | P2 | 记账编辑器｜必填原因与锁定理由未在字段旁解释 | docs/design-system/audit-bills-orders.md:295 |
| BO-030 | P2 | 记账编辑器｜删除有内容的分类/附加项后缺少撤销 | docs/design-system/audit-bills-orders.md:304 |
| BO-031 | P2 | 记账编辑器｜附件移除目标伸出缩略图且说明未表达删除 | docs/design-system/audit-bills-orders.md:313 |
| BO-032 | P2 | 记账编辑器｜保存前无法放大检查附件，处理过程和失败对象不明 | docs/design-system/audit-bills-orders.md:322 |
| BO-033 | P2 | 记账编辑器｜固定高度附件 tile 在 caption 升级后溢出，已改为随文字行高增长 | docs/design-system/audit-bills-orders.md:331 |
| BO-034 | P2 | 记账编辑器｜账户选择依赖逐组浏览，空选项没有下一步 | docs/design-system/audit-bills-orders.md:341 |
| BO-035 | P2 | 记账编辑器｜保存进行中表单主体仍可修改，结果与最后所见可能不一致 | docs/design-system/audit-bills-orders.md:350 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| BO-004 | P2 | 共性｜表单的视觉标签没有形成明确的输入语义 | docs/design-system/audit-bills-orders.md:69 |
| BO-005 | P2 | 共性｜数字键盘与长表单缺少一致的结束编辑路径 | docs/design-system/audit-bills-orders.md:78 |
| BO-006 | P2 | 共性｜金额输入对常见粘贴内容静默拒绝 | docs/design-system/audit-bills-orders.md:87 |
| BO-009 | P2 | 共性｜关键状态和对账辅助金额被压到小号字层级 | docs/design-system/audit-bills-orders.md:114 |
| BO-065 | P2 | 账单详情｜附加费用的分类与备注信息在阅读中丢失 | docs/design-system/audit-bills-orders.md:620 |
| BO-068 | P2 | 账单详情｜阅读页没有明确说明是否纳入统计等关键状态 | docs/design-system/audit-bills-orders.md:647 |
| BO-069 | P1 | 共享账单详情｜从单据流水进入预览后，动作可用性与来源行不一致 | docs/design-system/audit-bills-orders.md:656 |
| BO-073 | P1 | 单据详情｜利息或费用动作进入编辑器时未带对应业务组件 | docs/design-system/audit-bills-orders.md:692 |
| BO-074 | P2 | 共性｜列表顶部多层控制始终固定，缺少小高度和大字时的收敛 | docs/design-system/audit-bills-orders.md:701 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/features/bill_editor test/features/shared/data/bill_attachment_validator_test.dart
```

1. 运行test/features/bill_editor与shared/data/bill_attachment_validator_test；保留现有三种普通单、垫付报销、借贷分/精度用例。
2. 逐一触发切类型、返回/遮罩取消、只改单金额、选择器取消/清空；核对bloc事件/请求payload而非只找widget。
3. 320宽+2倍字+键盘，保存可达、无边框金额保留；多附件/失败重试不丢其它输入。

## 视觉证据与验收

- 原V11/V12；单分类/多分类/转账/借贷/报销、错误、键盘、隐藏及文件附件。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S5-A.md`、`runtime/issue-checks/S5-A.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S6-A，新开S6会话，文件docs/design-system/execution-prompts/prompts/08-S6-A.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 08 · 新开S6会话

# S6-A｜单据列表与创建流程

**使用位置：新开S6会话。本轮只执行S6-A。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S6-A。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S6-A以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S6-A/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S6-A.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S6-A.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S6-A及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S5-A。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/features/orders/presentation/orders_page.dart`
- `lib/features/orders/presentation/widgets/order_card.dart`
- `lib/features/orders/presentation/widgets/order_filter_sheet.dart`
- `lib/features/orders/presentation/widgets/order_form_sheet.dart`
- `lib/features/orders/presentation/bloc/`
- `lib/features/orders/data/`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 列表让默认进行中条件可见，提供状态总览/重置、搜索快速清除；刷新/搜索/分页保留旧结果并明确更新范围。
2. 新建默认继承当前类型，核心字段按任务顺序排，常用对象选择可搜索，加载/失败/无选项有解释；到期日整行可操作并清楚可选。
3. 保存草稿与下一步必须是不同意图：各自忙碌状态、冻结相关输入、首错定位、固定操作区和离开保护。下一步实际已保存草稿时，取消后必须能找到该草稿，不回到隐去它的列表而无提示。
4. 所有图标有实际动作名称；窄宽和大字下筛选/汇总区收敛，当前账本可见，权限禁止提前说明。
5. 模型/服务改动限于正确表达已有契约及等待/分页状态，不新增服务器不支持的状态筛选或假分页。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| BO-038 | P2 | 单据列表｜默认仅“进行中”的条件不可见，状态筛选缺少总览 | docs/design-system/audit-bills-orders.md:377 |
| BO-039 | P2 | 单据列表｜新建流程忽略列表当前类型 | docs/design-system/audit-bills-orders.md:386 |
| BO-040 | P2 | 单据列表｜搜索每次更新都替换整个结果区，且缺少快速清除 | docs/design-system/audit-bills-orders.md:395 |
| BO-041 | P2 | 单据列表｜下拉刷新动画不等待真实刷新完成 | docs/design-system/audit-bills-orders.md:404 |
| BO-048 | P2 | 单据表单｜保存与下一步放在滚动内容尾部，错误也远离字段 | docs/design-system/audit-bills-orders.md:467 |
| BO-049 | P1 | 单据表单｜已输入内容没有局部离开保护 | docs/design-system/audit-bills-orders.md:476 |
| BO-050 | P2 | 单据表单｜保存草稿时却由“下一步”按钮显示忙碌，其他控件继续可改 | docs/design-system/audit-bills-orders.md:485 |
| BO-051 | P2 | 单据表单｜对方选择器没有加载/空态/失败解释或搜索 | docs/design-system/audit-bills-orders.md:494 |
| BO-052 | P2 | 单据表单｜到期日看似整行可点，实际只有日历图标打开 | docs/design-system/audit-bills-orders.md:503 |
| BO-053 | P2 | 单据表单｜多处裸 IconButton 没有可理解的动作名称 | docs/design-system/audit-bills-orders.md:512 |
| BO-054 | P2 | 单据新建流程｜下一步已保存草稿，取消记账后却默认返回隐藏草稿的列表 | docs/design-system/audit-bills-orders.md:521 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| BO-003 | P1 | 共性｜未知金额被展示为零，未知计数被展示为零笔 | docs/design-system/audit-bills-orders.md:60 |
| BO-004 | P2 | 共性｜表单的视觉标签没有形成明确的输入语义 | docs/design-system/audit-bills-orders.md:69 |
| BO-005 | P2 | 共性｜数字键盘与长表单缺少一致的结束编辑路径 | docs/design-system/audit-bills-orders.md:78 |
| BO-007 | P2 | 共性｜确认、作废、归档等请求进行中没有对应的可见忙碌状态 | docs/design-system/audit-bills-orders.md:96 |
| BO-009 | P2 | 共性｜关键状态和对账辅助金额被压到小号字层级 | docs/design-system/audit-bills-orders.md:114 |
| BO-019 | P3 | 账单｜图标说明与徽标文案不够贴合业务任务 | docs/design-system/audit-bills-orders.md:205 |
| BO-028 | P2 | 记账编辑器｜新增分类和费用是按文字自然高度的目标 | docs/design-system/audit-bills-orders.md:286 |
| BO-036 | P1 | 单据详情｜只展示前两个业务动作，其余合法动作没有入口 | docs/design-system/audit-bills-orders.md:359 |
| BO-042 | P2 | 单据详情｜整账本汇总被放在单张详情主金额下方，却未标范围 | docs/design-system/audit-bills-orders.md:413 |
| BO-043 | P2 | 单据详情｜已填写的对方、到期日、备注和生命周期缺少阅读出口 | docs/design-system/audit-bills-orders.md:422 |
| BO-047 | P2 | 单据详情｜流水筛选和操作刷新会让整张详情消失 | docs/design-system/audit-bills-orders.md:458 |
| BO-055 | P2 | 单据审计｜记录页展示原始动作与机器时间，缺少谁改了什么 | docs/design-system/audit-bills-orders.md:530 |
| BO-058 | P2 | 核对报告｜从某单据点查看报告，却进入未定位的全账本报告 | docs/design-system/audit-bills-orders.md:557 |
| BO-060 | P1 | 核对报告｜多币种报告统一套用第一个币种 | docs/design-system/audit-bills-orders.md:575 |
| BO-062 | P2 | 核对报告｜金额结论展示不完整，难以比较核对前后 | docs/design-system/audit-bills-orders.md:593 |
| BO-069 | P1 | 共享账单详情｜从单据流水进入预览后，动作可用性与来源行不一致 | docs/design-system/audit-bills-orders.md:656 |
| BO-071 | P2 | 单据入口｜缺少必需路由参数时显示完全空白页 | docs/design-system/audit-bills-orders.md:674 |
| BO-072 | P3 | 共性｜部分用户文案绕过本地化且日期格式不一致 | docs/design-system/audit-bills-orders.md:683 |
| BO-074 | P2 | 共性｜列表顶部多层控制始终固定，缺少小高度和大字时的收敛 | docs/design-system/audit-bills-orders.md:701 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/features/orders/presentation/orders_page_test.dart test/features/orders/presentation/order_form_sheet_test.dart test/features/orders/presentation/orders_bloc_test.dart test/features/orders/data/orders_service_test.dart
```

1. 运行orders_page_test、order_form_sheet_test、orders_bloc_test、data/orders_service_test；覆盖默认筛选、新建继承、草稿取消、两种提交忙碌、对象加载失败和竞态。
2. 提交前后保留对象ID/版本/类型正确；服务不支持的查询参数不得臆造。

## 视觉证据与验收

- 原V52对照；另生成单据新建/筛选/草稿返回/长对象名/大字键盘，这些没有原截图。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S6-A.md`、`runtime/issue-checks/S6-A.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S6-B，回到已有S6会话，文件docs/design-system/execution-prompts/prompts/09-S6-B.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 09 · 回到已有S6会话

# S6-B｜单据详情、业务动作与金额隐私

**使用位置：回到已有S6会话。本轮只执行S6-B。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S6-B。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S6-B以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S6-B/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S6-B.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S6-B.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S6-B及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S6-A。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/features/orders/presentation/order_detail_page.dart`
- `lib/features/orders/presentation/widgets/order_entry_tile.dart`
- `lib/features/orders/presentation/widgets/order_summary_strip.dart`
- `lib/features/orders/presentation/bloc/`
- `lib/features/orders/data/`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 详情保留返回骨架且明确单据自身范围；整账本汇总不能伪装单据值。主金额、分解、流水层级重排，辅助分解默认适当折叠但可完整核对。
2. 未知值不是0，金额和次数分别处理null/loading/error/0；主金额、分解、核对入口、结清/作废说明及Semantics遵守同一隐藏状态。
3. 审计允许动作列表不能取前两项静默删除后续合法动作；本金/利息/费用/核销入口带正确业务component、orderId和版本，返回详情数据更新且滚动位置稳定。
4. 完整显示对方、到期、备注和生命周期；流水的状态/账户/时间有层级，编辑/回退/作废变成有名称的合理动作，权限与共享详情一致。
5. 每动作有对象级忙碌/失败/完成反馈，筛选流水不清空整张详情；请求进行中不出现重复提交或不可恢复关闭。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| BO-001 | P1 | 共性｜金额隐藏没有覆盖汇总的无障碍标签 | docs/design-system/audit-bills-orders.md:42 |
| BO-002 | P1 | 共性｜单据详情主金额、核对金额和确认文案未遵循隐藏偏好 | docs/design-system/audit-bills-orders.md:51 |
| BO-003 | P1 | 共性｜未知金额被展示为零，未知计数被展示为零笔 | docs/design-system/audit-bills-orders.md:60 |
| BO-036 | P1 | 单据详情｜只展示前两个业务动作，其余合法动作没有入口 | docs/design-system/audit-bills-orders.md:359 |
| BO-037 | P1 | 单据详情｜加载与错误状态没有保留页内返回入口 | docs/design-system/audit-bills-orders.md:368 |
| BO-042 | P2 | 单据详情｜整账本汇总被放在单张详情主金额下方，却未标范围 | docs/design-system/audit-bills-orders.md:413 |
| BO-043 | P2 | 单据详情｜已填写的对方、到期日、备注和生命周期缺少阅读出口 | docs/design-system/audit-bills-orders.md:422 |
| BO-044 | P2 | 单据详情｜六项金额全部展开并排在主操作前，主次不分 | docs/design-system/audit-bills-orders.md:431 |
| BO-045 | P2 | 单据详情｜窄屏金额分解和核对金额行缺少有效弹性 | docs/design-system/audit-bills-orders.md:440 |
| BO-046 | P2 | 单据详情｜流水把状态、账户、日期混成一条副标题，动作成为重复图标条 | docs/design-system/audit-bills-orders.md:449 |
| BO-047 | P2 | 单据详情｜流水筛选和操作刷新会让整张详情消失 | docs/design-system/audit-bills-orders.md:458 |
| BO-073 | P1 | 单据详情｜利息或费用动作进入编辑器时未带对应业务组件 | docs/design-system/audit-bills-orders.md:692 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| BO-007 | P2 | 共性｜确认、作废、归档等请求进行中没有对应的可见忙碌状态 | docs/design-system/audit-bills-orders.md:96 |
| BO-008 | P2 | 共性｜只读状态被绘制成可点击但无结果的控件 | docs/design-system/audit-bills-orders.md:105 |
| BO-049 | P1 | 单据表单｜已输入内容没有局部离开保护 | docs/design-system/audit-bills-orders.md:476 |
| BO-053 | P2 | 单据表单｜多处裸 IconButton 没有可理解的动作名称 | docs/design-system/audit-bills-orders.md:512 |
| BO-069 | P1 | 共享账单详情｜从单据流水进入预览后，动作可用性与来源行不一致 | docs/design-system/audit-bills-orders.md:656 |
| BO-072 | P3 | 共性｜部分用户文案绕过本地化且日期格式不一致 | docs/design-system/audit-bills-orders.md:683 |
| BO-074 | P2 | 共性｜列表顶部多层控制始终固定，缺少小高度和大字时的收敛 | docs/design-system/audit-bills-orders.md:701 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/features/orders/presentation/order_detail_page_test.dart test/features/orders/data/order_money_test.dart test/features/bill_editor/presentation/bill_editor_order_flow_test.dart
```

1. 运行order_detail_page_test、orders_bloc_test、order_money_test及bill_editor_order_flow_test；覆盖至少三种合法动作同时存在和利息/费用component落点。
2. 隐藏金额扫描语义/确认文案；null/0/正负值区分；加载/失败时返回仍可达。
3. 对方/备注/到期/版本更新与详情回显一致，错误保留其它已知信息。

## 视觉证据与验收

- 原V53/V54对照；隐藏、空值、长金额、三种业务动作、流水错误、明暗大字。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S6-B.md`、`runtime/issue-checks/S6-B.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S6-C，回到已有S6会话，文件docs/design-system/execution-prompts/prompts/10-S6-C.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 10 · 回到已有S6会话

# S6-C｜核对报告与单据审计阅读

**使用位置：回到已有S6会话。本轮只执行S6-C。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S6-C。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S6-C以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S6-C/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S6-C.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S6-C.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S6-C及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S6-B。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/features/orders/presentation/order_reconciliation_page.dart`
- `lib/features/orders/presentation/widgets/order_audit_sheet.dart`
- `lib/features/orders/data/`
- `lib/features/orders/presentation/order_detail_page.dart`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 从单据进入全账本核对报告时先定位当前单据或明确切换范围；只有billId无orderId仍能使用既有账单详情入口继续核对，路由目标缺失有解释。
2. 混币按服务端真实行币种或分组展示，不把第一行币种套所有金额；缺字段时标未知并登记接口缺口，不猜汇率、不合计不可比较金额。
3. 核对前后金额、差额、原因、影响与下一步清楚；内部错误码/ID放次级可复制诊断，用户语言先解释问题。
4. 审计日志表达谁/何时/什么动作/结果，正确时区与时间格式；正常翻页叫加载更多，失败才重试，分页失败保留已读内容，空记录有说明。
5. 金额隐藏及加载/错误骨架保持，所有改变财务状态动作沿用业务服务与确认，核对页不暗中改数据。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| BO-055 | P2 | 单据审计｜记录页展示原始动作与机器时间，缺少谁改了什么 | docs/design-system/audit-bills-orders.md:530 |
| BO-056 | P1 | 单据审计｜失败页没有重试入口，加载下一页失败也丢掉已读记录视图 | docs/design-system/audit-bills-orders.md:539 |
| BO-057 | P2 | 单据审计｜正常翻页写“重试”，空记录是无说明空白 | docs/design-system/audit-bills-orders.md:548 |
| BO-058 | P2 | 核对报告｜从某单据点查看报告，却进入未定位的全账本报告 | docs/design-system/audit-bills-orders.md:557 |
| BO-059 | P1 | 核对报告｜有 billId 而无 orderId 的报告没有继续查看入口 | docs/design-system/audit-bills-orders.md:566 |
| BO-060 | P1 | 核对报告｜多币种报告统一套用第一个币种 | docs/design-system/audit-bills-orders.md:575 |
| BO-061 | P2 | 核对报告｜问题码与数字编号主导页面，用户语言不足 | docs/design-system/audit-bills-orders.md:584 |
| BO-062 | P2 | 核对报告｜金额结论展示不完整，难以比较核对前后 | docs/design-system/audit-bills-orders.md:593 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| BO-002 | P1 | 共性｜单据详情主金额、核对金额和确认文案未遵循隐藏偏好 | docs/design-system/audit-bills-orders.md:51 |
| BO-008 | P2 | 共性｜只读状态被绘制成可点击但无结果的控件 | docs/design-system/audit-bills-orders.md:105 |
| BO-045 | P2 | 单据详情｜窄屏金额分解和核对金额行缺少有效弹性 | docs/design-system/audit-bills-orders.md:440 |
| BO-072 | P3 | 共性｜部分用户文案绕过本地化且日期格式不一致 | docs/design-system/audit-bills-orders.md:683 |
| BO-074 | P2 | 共性｜列表顶部多层控制始终固定，缺少小高度和大字时的收敛 | docs/design-system/audit-bills-orders.md:701 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/features/orders/presentation/order_reconciliation_page_test.dart test/features/orders/data/orders_service_test.dart
```

1. 运行order_reconciliation_page_test与orders_service_test；构造多币种/币种缺失、billId-only、指定单据定位、空/分页失败/重试fixture。
2. 审计同名不同人、长原因、不同时间偏移；核对前后数值逐项可读且不能靠tooltip唯一暴露精确金额。

## 视觉证据与验收

- 核对报告和审计页无原图，生成真实Flutter亮暗、大字、混币、错误/分页样本。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S6-C.md`、`runtime/issue-checks/S6-C.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S7-A，新开S7会话，文件docs/design-system/execution-prompts/prompts/11-S7-A.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 11 · 新开S7会话

# S7-A｜仪表盘信息层级与布局编辑

**使用位置：新开S7会话。本轮只执行S7-A。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S7-A。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S7-A以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S7-A/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S7-A.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S7-A.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S7-A及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S6-C。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/features/dashboard/`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 保留净资产主区和最近账单内容高度；空账本仅让账本流水出现创建引导，已有分组资产不消失。分组资产/账本收支各有范围。
2. 浏览态与编辑态同一位置规则；固定区明确不可拖或真正按保存排序展示，不能完成后回弹。编辑态采用紧凑可读摘要，不把完整多行流水硬塞固定格。
3. 补排序上移/下移等效动作、对象语义、边缘移动与稳定占位；触屏Web不以kIsWeb直接即时拖抢滚动。共享网格变更须用S1合同。
4. 趋势保留成功序列，失败图例标暂不可用可重试，不能把收入失败当零；起止/量级/变化结论可理解，整卡能否点击与去向可见。
5. 分类颜色消费共享稳定规则，条长分母唯一且显式；控制细碎元数据与阴影，失效头像去掉操作形态或接有意义入口。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| DS-018 | P1 | 空账本会把已经存在的分组净资产换成记账引导 | docs/design-system/audit-dashboard-stats.md:153 |
| DS-019 | P1 | 首页允许拖动的顺序与退出编辑后的顺序不一致 | docs/design-system/audit-dashboard-stats.md:161 |
| DS-020 | P1 | 内容自适应只覆盖浏览态，编辑网格和分类卡仍可能压住内容 | docs/design-system/audit-dashboard-stats.md:169 |
| DS-026 | P3 | 顶部头像占用操作位但实际不可操作 | docs/design-system/audit-dashboard-stats.md:217 |
| DS-027 | P2 | 首页趋势部分失败时仍表现成完整收支趋势 | docs/design-system/audit-dashboard-stats.md:225 |
| DS-028 | P2 | 首页趋势缺少时间与尺度线索，整卡导航也不明显 | docs/design-system/audit-dashboard-stats.md:233 |
| DS-029 | P2 | 分类条在两种不同分母之间静默切换 | docs/design-system/audit-dashboard-stats.md:241 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| DS-003 | P2 | 账本、分组两种数据范围缺少就地说明 | docs/design-system/audit-dashboard-stats.md:31 |
| DS-005 | P2 | 时间标签缺少足以复核的年份和账期起止 | docs/design-system/audit-dashboard-stats.md:47 |
| DS-012 | P2 | 首页及统计卡错误可能暴露技术异常，且切断识别上下文 | docs/design-system/audit-dashboard-stats.md:103 |
| DS-017 | P2 | 同一分类在首页与统计中使用不同且含义冲突的颜色规则 | docs/design-system/audit-dashboard-stats.md:143 |
| DS-021 | P2 | 长按拖动是唯一排序方式，缺少可访问的等效操作 | docs/design-system/audit-dashboard-stats.md:177 |
| DS-022 | P2 | 拖动时禁止列表滚动，跨屏排序缺少路径 | docs/design-system/audit-dashboard-stats.md:185 |
| DS-023 | P2 | 统计拖动占位骤缩为 72，打乱当前布局参照 | docs/design-system/audit-dashboard-stats.md:193 |
| DS-024 | P2 | 移动浏览器编辑首页时直接按下即拖，和滚动竞争 | docs/design-system/audit-dashboard-stats.md:201 |
| DS-025 | P2 | 若干局部操作目标明显比常规按钮小 | docs/design-system/audit-dashboard-stats.md:209 |
| DS-030 | P2 | 表面层级仍混用抬升卡、彩色内卡和高阴影编辑反馈 | docs/design-system/audit-dashboard-stats.md:249 |
| DS-042 | P2 | 小票出入方向与转账类型缺少一致的非颜色表达 | docs/design-system/audit-dashboard-stats.md:347 |
| DS-049 | P2 | 无账本/分组与空数据状态缺少就地可行动引导 | docs/design-system/audit-dashboard-stats.md:405 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/features/dashboard test/core/shell/main_shell_recent_bills_navigation_test.dart
```

1. 运行test/features/dashboard与main_shell_recent_bills_navigation_test；空账本有资产、不同组账本、保存布局前后一致、长流水与分类。
2. 拖拽跨屏/键盘排序/触屏滚动、只失败一条趋势、百分比缺失、大金额隐藏；2倍字浏览/编辑都不溢出。

## 视觉证据与验收

- 原V04/V05/V07，重拍亮暗和编辑布局；净资产全值、最近流水及明确内容范围。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S7-A.md`、`runtime/issue-checks/S7-A.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S8-A，新开S8会话，文件docs/design-system/execution-prompts/prompts/12-S8-A.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 12 · 新开S8会话

# S8-A｜统计分析、时间范围与图表数据一致性

**使用位置：新开S8会话。本轮只执行S8-A。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S8-A。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S8-A以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S8-A/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S8-A.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S8-A.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S8-A及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S7-A。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/features/stats/presentation/stats_page.dart`
- `lib/features/stats/presentation/widgets/stats_*`
- `lib/features/stats/data/`
- `lib/features/stats/presentation/bloc/`
- `lib/fx/components/fx_*chart.dart`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 统计概览明确loading/error/unknown/0，维度摘要状态与图表一致；保留已有数据刷新而非高度骤缩，独立区域失败不掩盖其它结果。
2. 日历独立自然月与分析账期范围显式分开；日期含必要年份和真实起止，五年限制需有契约依据，无依据不任意缩短历史可查范围。
3. 减少重复概览/洞察/维度预览，洞察表达新增结论；资产/借贷/口径入口可快速抵达，编辑固定项说明。
4. 饼图/条图与表格覆盖一致，不能完整图+前五表；TopN须说明且可看全部。表格只显示有意义列，按内容展开，不在小固定图高里双向滚动。
5. 正/负/零和缺失日期按现有统计契约表达；不能静默过滤后称无记录，不能将不存在的数据补成确定零。趋势请求覆盖范围与界面标签一致，不伪造接口能力。
6. 稳定分类色映射与财务色分离，同一对象跨首页与统计保持含义；共享图表仅限合同兼容的消费者适配，不能在此重写主题。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| DS-001 | P1 | 非就绪概览仍呈现为真实财务结果 | docs/design-system/audit-dashboard-stats.md:15 |
| DS-002 | P2 | 维度摘要把加载失败解释为本期没有记录 | docs/design-system/audit-dashboard-stats.md:23 |
| DS-004 | P2 | 顶部筛选看似作用全页，日历实际独立运行 | docs/design-system/audit-dashboard-stats.md:39 |
| DS-005 | P2 | 时间标签缺少足以复核的年份和账期起止 | docs/design-system/audit-dashboard-stats.md:47 |
| DS-006 | P2 | 默认主线重复展示数据，日历日期取得过高视觉权重 | docs/design-system/audit-dashboard-stats.md:55 |
| DS-007 | P2 | 资产、借贷和口径入口被固定在全部分析之后 | docs/design-system/audit-dashboard-stats.md:63 |
| DS-008 | P1 | 饼图的文字替代只保留前五项 | docs/design-system/audit-dashboard-stats.md:71 |
| DS-009 | P2 | 图表文字替代仍是固定小窗口内的双向滚动表 | docs/design-system/audit-dashboard-stats.md:79 |
| DS-010 | P2 | 图表筛掉非正值及 Top10，却未向用户说明范围 | docs/design-system/audit-dashboard-stats.md:87 |
| DS-011 | P3 | 返回图表的图标始终是饼图 | docs/design-system/audit-dashboard-stats.md:95 |
| DS-013 | P2 | 刷新时页面高度收缩，慢依赖延迟整片结果 | docs/design-system/audit-dashboard-stats.md:111 |
| DS-014 | P1 | 自定义分析区间与趋势请求无法保持同一范围（需核契约） | docs/design-system/audit-dashboard-stats.md:119 |
| DS-015 | P2 | 月趋势缺少无交易日期，时间跨度可能被压缩 | docs/design-system/audit-dashboard-stats.md:127 |
| DS-017 | P2 | 同一分类在首页与统计中使用不同且含义冲突的颜色规则 | docs/design-system/audit-dashboard-stats.md:143 |
| DS-043 | P2 | 基础统计的百分比没有说明分母 | docs/design-system/audit-dashboard-stats.md:357 |
| DS-051 | P2 | 自定义日期只允许过去五年，却没有在入口说明限制 | docs/design-system/audit-dashboard-stats.md:421 |
| DS-053 | P2 | 大字号下隐私饼图图例仍固定五行非滚动列 | docs/design-system/audit-dashboard-stats.md:437 |
| DS-055 | P3 | 维度预览尾注使用统计口径入口副标题，但没有入口动作 | docs/design-system/audit-dashboard-stats.md:453 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| DS-003 | P2 | 账本、分组两种数据范围缺少就地说明 | docs/design-system/audit-dashboard-stats.md:31 |
| DS-012 | P2 | 首页及统计卡错误可能暴露技术异常，且切断识别上下文 | docs/design-system/audit-dashboard-stats.md:103 |
| DS-016 | P2 | 财务摘要仍以固定多列分配宽度，大字号缺少局部重排 | docs/design-system/audit-dashboard-stats.md:135 |
| DS-021 | P2 | 长按拖动是唯一排序方式，缺少可访问的等效操作 | docs/design-system/audit-dashboard-stats.md:177 |
| DS-022 | P2 | 拖动时禁止列表滚动，跨屏排序缺少路径 | docs/design-system/audit-dashboard-stats.md:185 |
| DS-023 | P2 | 统计拖动占位骤缩为 72，打乱当前布局参照 | docs/design-system/audit-dashboard-stats.md:193 |
| DS-024 | P2 | 移动浏览器编辑首页时直接按下即拖，和滚动竞争 | docs/design-system/audit-dashboard-stats.md:201 |
| DS-025 | P2 | 若干局部操作目标明显比常规按钮小 | docs/design-system/audit-dashboard-stats.md:209 |
| DS-030 | P2 | 表面层级仍混用抬升卡、彩色内卡和高阴影编辑反馈 | docs/design-system/audit-dashboard-stats.md:249 |
| DS-035 | P1 | 金额隐藏状态可能在小票弹层边界丢失 | docs/design-system/audit-dashboard-stats.md:291 |
| DS-040 | P1 | 小票明细数量上限与汇总口径不一致，缺少部分数据标记 | docs/design-system/audit-dashboard-stats.md:331 |
| DS-044 | P1 | 资产与负债合到一个饼图却保留各端点原始百分比 | docs/design-system/audit-dashboard-stats.md:365 |
| DS-045 | P2 | 信用卡金额没有指标标签，也没有后续任务入口 | docs/design-system/audit-dashboard-stats.md:373 |
| DS-048 | P1 | 口径页把所有请求异常都转成“默认全部计入”的肯定陈述 | docs/design-system/audit-dashboard-stats.md:397 |
| DS-049 | P2 | 无账本/分组与空数据状态缺少就地可行动引导 | docs/design-system/audit-dashboard-stats.md:405 |
| DS-054 | P2 | 日格目标只增长高度，七列宽度仍缺少小屏兜底 | docs/design-system/audit-dashboard-stats.md:445 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/features/stats
```

1. 运行test/features/stats及受影响共享图表测试，至少8分类、12标签、负/零混合、缺失日期、跨年/非自然月账期。
2. 本期范围与请求payload/横轴逐一核对；趋势失败/摘要失败/只成功一部分与ready-zero区别。
3. 2倍字完整数据表、长类名、大数、多页内容可读，图表/表/语义的总数一致。

## 视觉证据与验收

- 原V15—V17/V22及图表/表格、加载/失败、大字；不可仅截图零值空表。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S8-A.md`、`runtime/issue-checks/S8-A.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S8-B，回到已有S8会话，文件docs/design-system/execution-prompts/prompts/13-S8-B.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 13 · 回到已有S8会话

# S8-B｜日历、日小票与分享完整性

**使用位置：回到已有S8会话。本轮只执行S8-B。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S8-B。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S8-B以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S8-B/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S8-B.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S8-B.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S8-B及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S8-A。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/features/stats/presentation/widgets/stats_income_expense_calendar_card.dart`
- `lib/features/stats/presentation/widgets/calendar_day_summary_sheet.dart`
- `lib/features/stats/presentation/widgets/stats_formatters.dart`
- `lib/features/stats/presentation/widgets/stats_privacy.dart`
- `lib/features/stats/data/chinese_calendar_day.dart`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 降低无任务意义的大日期权重，日格保留日期和必要活动线索，小额/农历不强塞9号字；小宽/大字改显示模式或由选中摘要承接，今天与选中态区分并能回本月。
2. 给收/支活动点明确视觉图例和非颜色说明，农历按应用语言合理表达；年/历史网格不让金额不可读。
3. 连续比较日期先有日摘要，小票为进一步查看/分享；整条长小票的查看流水/保存主操作不排在宣传文案之后。
4. 进入新route携带当前隐藏状态，Text/Semantics/Tooltip/导出快照一致；金额列不固定30%裁切，费用/优惠徽标前景可读，装饰分隔不进读屏。
5. 明细与汇总数量一致；超过单次上限可分页取完或明确部分，失败小票不得伪装完整可分享。失败保留上下文并可原位重试；事务方向有文字/符号。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| DS-031 | P1 | 年/月格中的有用信息仍明确使用 9 号字 | docs/design-system/audit-dashboard-stats.md:259 |
| DS-032 | P2 | 日历活动点仅用颜色编码，没有视觉图例 | docs/design-system/audit-dashboard-stats.md:267 |
| DS-033 | P2 | 选中日期与今天未区分，缺少快速回到本月 | docs/design-system/audit-dashboard-stats.md:275 |
| DS-034 | P2 | 日格点选直接弹出长小票，连续比较日期被打断 | docs/design-system/audit-dashboard-stats.md:283 |
| DS-035 | P1 | 金额隐藏状态可能在小票弹层边界丢失 | docs/design-system/audit-dashboard-stats.md:291 |
| DS-036 | P1 | 小票金额被限制在 30% 列宽并直接省略 | docs/design-system/audit-dashboard-stats.md:299 |
| DS-037 | P1 | 费用/优惠徽标字号 10 且本地颜色对比不足 | docs/design-system/audit-dashboard-stats.md:307 |
| DS-038 | P2 | 查看流水/保存按钮被放在长小票和宣传页脚之后 | docs/design-system/audit-dashboard-stats.md:315 |
| DS-039 | P2 | 明细加载失败后不能就地重试，却允许保存失败小票 | docs/design-system/audit-dashboard-stats.md:323 |
| DS-040 | P1 | 小票明细数量上限与汇总口径不一致，缺少部分数据标记 | docs/design-system/audit-dashboard-stats.md:331 |
| DS-041 | P2 | 小票装饰性分隔文本会进入读屏阅读顺序 | docs/design-system/audit-dashboard-stats.md:339 |
| DS-042 | P2 | 小票出入方向与转账类型缺少一致的非颜色表达 | docs/design-system/audit-dashboard-stats.md:347 |
| DS-052 | P3 | 农历文案没有随应用语言调整 | docs/design-system/audit-dashboard-stats.md:429 |
| DS-054 | P2 | 日格目标只增长高度，七列宽度仍缺少小屏兜底 | docs/design-system/audit-dashboard-stats.md:445 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| DS-004 | P2 | 顶部筛选看似作用全页，日历实际独立运行 | docs/design-system/audit-dashboard-stats.md:39 |
| DS-006 | P2 | 默认主线重复展示数据，日历日期取得过高视觉权重 | docs/design-system/audit-dashboard-stats.md:55 |
| DS-025 | P2 | 若干局部操作目标明显比常规按钮小 | docs/design-system/audit-dashboard-stats.md:209 |
| DS-030 | P2 | 表面层级仍混用抬升卡、彩色内卡和高阴影编辑反馈 | docs/design-system/audit-dashboard-stats.md:249 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/features/stats/presentation/widgets/stats_income_expense_calendar_card_test.dart test/features/stats/data/income_expense_calendar_models_test.dart test/features/stats/chinese_calendar_day_test.dart
```

1. 运行stats_income_expense_calendar_card_test、income_expense_calendar_models_test、chinese_calendar_day_test及新增小票行为测试。
2. 201条明细分页/部分/失败，金额隐藏后新route与导出均无值，费用/优惠明暗对比，超长金额和名称不截。
3. 320/390/440宽、2倍字、7列目标与等效日期选择、今天/选中/回本月、连续比较验证。

## 视觉证据与验收

- 原V15日历对照；补年/历史/小票、>200明细、大字和隐藏导出图片；这些原截图未覆盖。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S8-B.md`、`runtime/issue-checks/S8-B.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S8-C，回到已有S8会话，文件docs/design-system/execution-prompts/prompts/14-S8-C.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 14 · 回到已有S8会话

# S8-C｜资产、借贷与统计口径报告

**使用位置：回到已有S8会话。本轮只执行S8-C。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S8-C。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S8-C以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S8-C/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S8-C.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S8-C.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S8-C及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S8-B。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/features/stats/presentation/stats_assets_page.dart`
- `lib/features/stats/presentation/stats_loans_page.dart`
- `lib/features/stats/presentation/stats_policy_page.dart`
- `lib/features/stats/data/`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 资产/负债/净资产分别表达，不能合并成饼图却使用不同分母原始百分比；每个图声明分母，极端集中资产可用排行/摘要呈现，不强制大圆环。
2. 核心金额全值、币种、千分位清楚，名称/图例/信用卡指标有明确标签。避免主金额被彩色小内框限制，财务色不代替层级。
3. 借贷待收/待还/待报销、逾期、待核对提供正确过滤的继续处理入口；信用卡说明金额究竟是余额、额度还是待还，不猜业务定义。
4. 统计策略请求失败显示未知/获取失败，不能声称默认全部计入；本地已知默认与服务端实际口径分层。
5. 无分组/账本、无数据、错误各有正确引导；页面安全区/底部避让、2倍字多列重排，沿用S3导航返回。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| DS-044 | P1 | 资产与负债合到一个饼图却保留各端点原始百分比 | docs/design-system/audit-dashboard-stats.md:365 |
| DS-045 | P2 | 信用卡金额没有指标标签，也没有后续任务入口 | docs/design-system/audit-dashboard-stats.md:373 |
| DS-046 | P2 | 借贷金额没有币种、分组格式和数值层级 | docs/design-system/audit-dashboard-stats.md:381 |
| DS-047 | P2 | 借贷逾期与需要核对项只显示静态数值，无法继续处理 | docs/design-system/audit-dashboard-stats.md:389 |
| DS-048 | P1 | 口径页把所有请求异常都转成“默认全部计入”的肯定陈述 | docs/design-system/audit-dashboard-stats.md:397 |
| DS-050 | P2 | 资产与口径页没有声明底部/横向安全区适配 | docs/design-system/audit-dashboard-stats.md:413 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| DS-003 | P2 | 账本、分组两种数据范围缺少就地说明 | docs/design-system/audit-dashboard-stats.md:31 |
| DS-013 | P2 | 刷新时页面高度收缩，慢依赖延迟整片结果 | docs/design-system/audit-dashboard-stats.md:111 |
| DS-016 | P2 | 财务摘要仍以固定多列分配宽度，大字号缺少局部重排 | docs/design-system/audit-dashboard-stats.md:135 |
| DS-030 | P2 | 表面层级仍混用抬升卡、彩色内卡和高阴影编辑反馈 | docs/design-system/audit-dashboard-stats.md:249 |
| DS-049 | P2 | 无账本/分组与空数据状态缺少就地可行动引导 | docs/design-system/audit-dashboard-stats.md:405 |
| DS-053 | P2 | 大字号下隐私饼图图例仍固定五行非滚动列 | docs/design-system/audit-dashboard-stats.md:437 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/features/stats
```

1. 运行stats相关测试并新增资产/借贷/策略fixture；合并分母、混币/超大值/空值、策略失败与真默认区别。
2. 逾期/核对下钻参数与目标数量相符；无假0、无错误币种、无顶部金额ellipsis。

## 视觉证据与验收

- 原V18—V21对照：极端大资产、负债、平直趋势、信用卡、借贷逾期、口径失败，亮暗大字。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S8-C.md`、`runtime/issue-checks/S8-C.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S9-A，新开S9会话，文件docs/design-system/execution-prompts/prompts/15-S9-A.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 15 · 新开S9会话

# S9-A｜账本、分组与协作管理

**使用位置：新开S9会话。本轮只执行S9-A。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S9-A。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S9-A以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S9-A/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S9-A.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S9-A.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S9-A及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S8-C。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/features/books/`
- `lib/features/group_users/`
- `lib/features/shared/invite_member_sheet.dart`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 默认账户取消与清空不同，保存/成员维护完成后只刷新原详情，不能再次打开编辑表单；loading/error保留返回，编辑回显并保留当前对象。
2. 切换分组时账本集合与当前分组原子匹配，旧数据不能以新分组身份执行动作；首次无分组不是访客身份，按当前会话能力提供建立分组入口。
3. 分组/账本/协作成员列表减少每条卡片边界、同级说明和固定头部；长名称、身份和角色优先，角色pill可弹性布局。未配置默认账户的状态有明确下一步。
4. 币种改常用/最近+可搜索完整列表；CNY等现有默认契约不被字母排序首项替换；加载失败有重试，不静默变任意文本。模板说明选择后果，低频排序/备注进次级。
5. 两个邀请入口使用同一已核实角色含义与默认值，不猜角色编号、不因为第一项为管理员就默认选它；身份确认清楚，移除有对象确认/目标级忙碌和权限说明。
6. 大集合真正分页/可继续加载；禁止静默500上限，筛选没有结果可恢复，回收站动作风险与可逆性匹配。只读行不画无结果的箭头。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| MG-B01 | P1 | 取消默认账户选择仍进入保存，取消与清空没有区别 | docs/design-system/audit-management.md:344 |
| MG-B02 | P1 | 保存默认配置或维护成员后意外打开编辑表单 | docs/design-system/audit-management.md:351 |
| MG-B03 | P1 | 详情加载/错误状态没有屏内返回按钮 | docs/design-system/audit-management.md:358 |
| MG-B04 | P1 | 分组详情点击移除即执行，缺少对象确认 | docs/design-system/audit-management.md:365 |
| MG-B05 | P2 | 分组详情成员只显示昵称和角色，无法辨别同名账号 | docs/design-system/audit-management.md:372 |
| MG-B06 | P2 | 账本/分组编辑返回详情后缺少结果回显 | docs/design-system/audit-management.md:379 |
| MG-B07 | P1 | 切分组时可能把旧账本暂时呈现在新分组名下 | docs/design-system/audit-management.md:386 |
| MG-B08 | P2 | 菜单中的禁用动作没有呈现阻断原因 | docs/design-system/audit-management.md:393 |
| MG-B09 | P1 | 没有任何分组时，新建分组会被解释成访客不可用 | docs/design-system/audit-management.md:400 |
| MG-B10 | P2 | “还有更多分组”仅展示标签，无法加载剩余结果 | docs/design-system/audit-management.md:407 |
| MG-B11 | P2 | 账本页固定头部层级过多，挤压内容区 | docs/design-system/audit-management.md:414 |
| MG-B12 | P2 | 账本与协作成员仍是逐项卡片，弱信息占用大面积 | docs/design-system/audit-management.md:421 |
| MG-B13 | P3 | 分组选择器仍单独画浮起阴影，与克制表面不一致 | docs/design-system/audit-management.md:428 |
| MG-B14 | P2 | 币种铺满 chip，加载失败又静默变成自由输入 | docs/design-system/audit-management.md:435 |
| MG-B15 | P2 | 新增账本模板只给名称，缺少选择后果说明 | docs/design-system/audit-management.md:442 |
| MG-B16 | P2 | 只读默认账户行仍画可进入的箭头但点击无反应 | docs/design-system/audit-management.md:449 |
| MG-B17 | P2 | 默认账户选择列表没有筛选，确认按钮跟在全部条目后 | docs/design-system/audit-management.md:456 |
| MG-B18 | P3 | 详情页标题与卡片标题/留白仍有明显等级跳变 | docs/design-system/audit-management.md:463 |
| MG-U01 | P1 | 两个邀请入口默认角色不同，协作页依赖角色排序选第一项 | docs/design-system/audit-management.md:540 |
| MG-U02 | P2 | 两个邀请入口对账号格式与确认步骤的承诺不一致 | docs/design-system/audit-management.md:547 |
| MG-U03 | P2 | 协作成员角色 pill 不参与弹性布局，会挤压姓名与账号 | docs/design-system/audit-management.md:554 |
| MG-U04 | P2 | 移除协作成员时所有移除按钮变灰，目标行没有进行中标识 | docs/design-system/audit-management.md:561 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| MG-C01 | P1 | 长表单校验错误落在末尾，缺少就地定位 | docs/design-system/audit-management.md:99 |
| MG-C04 | P2 | 表单可见标签未与输入控件建立明确的语义关联 | docs/design-system/audit-management.md:120 |
| MG-C05 | P1 | 重复开关缺少明确对象/用途的可访问名称 | docs/design-system/audit-management.md:127 |
| MG-C07 | P2 | 无数据、无搜索结果、筛选为空共用空态，缺少就地恢复动作 | docs/design-system/audit-management.md:141 |
| MG-C08 | P2 | 多页下拉刷新回调在数据返回前完成 | docs/design-system/audit-management.md:148 |
| MG-C10 | P2 | 停用记录的“业务状态”被处理成整行低透明度 | docs/design-system/audit-management.md:162 |
| MG-C11 | P2 | 普通移入回收站仍被要求勾选并完整输入名称 | docs/design-system/audit-management.md:169 |
| MG-C12 | P2 | 更多菜单没有对象上下文，辅助操作也只叫“更多” | docs/design-system/audit-management.md:176 |
| MG-C14 | P2 | 错误文案与反馈语气仍不一致 | docs/design-system/audit-management.md:190 |
| MG-C17 | P2 | 多数管理页缺少当前账本/分组的可见上下文 | docs/design-system/audit-management.md:211 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/features/books test/features/group_users test/core/session/session_cubit_test.dart
```

1. 运行test/features/books、group_users及session_cubit_test；测试取消默认账户不写入、明确清空只写一次、编辑完成无额外弹窗。
2. 切组竞态、无组初次创建、>500加载、同名成员、两个入口角色一致及移除失败回滚。
3. 币种搜索/默认/加载失败、模板说明、长标题大字、只读/停用可读。

## 视觉证据与验收

- 原V28—V35；新增账本/分组详情、默认账户、空组/回收站/币种错误，亮暗大字。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S9-A.md`、`runtime/issue-checks/S9-A.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S10-A，新开S10会话，文件docs/design-system/execution-prompts/prompts/16-S10-A.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 16 · 新开S10会话

# S10-A｜分类、标签、交易对象与成员管理

**使用位置：新开S10会话。本轮只执行S10-A。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S10-A。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S10-A以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S10-A/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S10-A.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S10-A.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S10-A及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S9-A。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/features/manage_shared/`
- `lib/features/categories/`
- `lib/features/tags/`
- `lib/features/payees/`
- `lib/features/members/`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 完整树用于整支移动/恢复，搜索/过滤只影响展示，不能改变实际子树范围；未找到父级不能显示无父级后保留隐藏旧值，删除/恢复不会错误覆盖。
2. 树节点提供展开/折叠语义、命中/祖先路径差异、从父节点创建子项；父级选择显示完整路径排除循环/无效候选，重名可辨。
3. 停止用整行低透明度表示业务停用，名称/金额/恢复操作可读，状态有文字；回收站点击与菜单语义一致。
4. 基础资料先名称和核心能力，排序/备注次级；采用一致保存机制，不把立即写服务器的开关与草稿保存混用。每个开关有对象与用途，失败回滚真实状态。
5. 共有ManageScaffold空态区分首次/筛选无结果/回收站空/错误，刷新等待请求终态，移动恢复有目标级忙碌/结果/可逆撤销，菜单带对象上下文。
6. 交易对象收支能力全关闭明确说明不可用于哪类记账；成员名称不被开关菜单挤没。当前账本/分组范围可见并继承S3契约。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| MG-T01 | P1 | 搜索/筛选会改变树形“整支移动/恢复”的实际操作范围 | docs/design-system/audit-management.md:470 |
| MG-T02 | P2 | 分类/标签停用状态只通过颜色表达 | docs/design-system/audit-management.md:477 |
| MG-T03 | P2 | 树节点缺少展开/折叠状态语义 | docs/design-system/audit-management.md:484 |
| MG-T04 | P2 | 搜索保留祖先但不区分命中项与路径项 | docs/design-system/audit-management.md:491 |
| MG-T05 | P2 | 新增子分类/标签缺少从父节点就地开始的入口 | docs/design-system/audit-management.md:498 |
| MG-T06 | P2 | 父级选择以名称平铺，标签重名路径不可辨 | docs/design-system/audit-management.md:505 |
| MG-T07 | P2 | 父级不在选项中时显示“无父级”，提交仍保留原父级值 | docs/design-system/audit-management.md:512 |
| MG-T08 | P2 | 回收站的行点击仍直接进入编辑，菜单却不提供编辑 | docs/design-system/audit-management.md:519 |
| MG-P01 | P2 | 交易对象所有收支能力都关闭时，列表不解释为何不可用 | docs/design-system/audit-management.md:526 |
| MG-M01 | P2 | 成员列表把开关、菜单、名字塞在一行，主体名称容易让位 | docs/design-system/audit-management.md:533 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| MG-C01 | P1 | 长表单校验错误落在末尾，缺少就地定位 | docs/design-system/audit-management.md:99 |
| MG-C02 | P1 | 同一编辑表单混用“立即保存”和“点保存才生效” | docs/design-system/audit-management.md:106 |
| MG-C03 | P1 | 开关失败后，仍打开的表单可能继续显示成功值 | docs/design-system/audit-management.md:113 |
| MG-C04 | P2 | 表单可见标签未与输入控件建立明确的语义关联 | docs/design-system/audit-management.md:120 |
| MG-C05 | P1 | 重复开关缺少明确对象/用途的可访问名称 | docs/design-system/audit-management.md:127 |
| MG-C06 | P2 | 键盘流程缺少“下一项/完成”和明确退出路径 | docs/design-system/audit-management.md:134 |
| MG-C07 | P2 | 无数据、无搜索结果、筛选为空共用空态，缺少就地恢复动作 | docs/design-system/audit-management.md:141 |
| MG-C08 | P2 | 多页下拉刷新回调在数据返回前完成 | docs/design-system/audit-management.md:148 |
| MG-C09 | P2 | 移动/恢复后的等待和完成反馈不完整 | docs/design-system/audit-management.md:155 |
| MG-C10 | P2 | 停用记录的“业务状态”被处理成整行低透明度 | docs/design-system/audit-management.md:162 |
| MG-C11 | P2 | 普通移入回收站仍被要求勾选并完整输入名称 | docs/design-system/audit-management.md:169 |
| MG-C12 | P2 | 更多菜单没有对象上下文，辅助操作也只叫“更多” | docs/design-system/audit-management.md:176 |
| MG-C13 | P2 | 只读权限提示太晚，仍引导用户进入编辑 | docs/design-system/audit-management.md:183 |
| MG-C14 | P2 | 错误文案与反馈语气仍不一致 | docs/design-system/audit-management.md:190 |
| MG-C15 | P2 | 少数关键状态/能力仍写死中文 | docs/design-system/audit-management.md:197 |
| MG-C16 | P2 | 轻量基础资料表单把排序/备注放在启用等核心设置之前 | docs/design-system/audit-management.md:204 |
| MG-C17 | P2 | 多数管理页缺少当前账本/分组的可见上下文 | docs/design-system/audit-management.md:211 |
| MG-U04 | P2 | 移除协作成员时所有移除按钮变灰，目标行没有进行中标识 | docs/design-system/audit-management.md:561 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/features/categories test/features/tags test/features/payees test/features/manage_shared
```

1. 运行test/features/categories、tags、payees、members（存在则执行）、manage_shared；无已有members用例须补真实行为测试，不能用空目录当通过。
2. 构造过滤树遗漏子节点、重名父路径、失效父级、停用节点、混合保存、请求失败回滚、短列表刷新。
3. 320宽2倍字与读屏节点检查，名称/状态/展开/菜单只表达一次且可执行。

## 视觉证据与验收

- 原V36—V47，树搜索/恢复/空态/表单首错/大字，明暗。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S10-A.md`、`runtime/issue-checks/S10-A.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S11-A，新开S11会话，文件docs/design-system/execution-prompts/prompts/17-S11-A.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 17 · 新开S11会话

# S11-A｜账户管理与余额表达

**使用位置：新开S11会话。本轮只执行S11-A。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S11-A。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S11-A以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S11-A/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S11-A.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S11-A.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S11-A及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S10-A。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/features/accounts/`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 账户名、尾号、余额、菜单合理分组，长金额优先精确可读，停用账户仍可识别和恢复。资产/负债汇总有范围与币种，隐私模式不通过比例条泄漏未承诺显示的信息。
2. 类型筛选明确全部/当前选中，计数不用10号；提供按名称/尾号的检索，账户数增加仍可定位。
3. 账单日/还款日用已知合法范围选择，利率/金额输入非法时就地拒绝并保留；不能tryParse失败丢弃后保存。
4. “编辑余额”与“调整余额”依照已核实业务后果说明；不改余额写入模型或偷偷生成/省略账单。不同类型仅显示相关字段，低频项分组。
5. 回收站恢复防重复、原位忙碌/失败；表单取消/清空、只读、未保存保护与通用合同一致。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| MG-A01 | P2 | 账户名与尾号被金额和菜单挤到同一条窄行 | docs/design-system/audit-management.md:218 |
| MG-A02 | P2 | 类型筛选没有显式“全部”，计数为 10px 且选择语义不足 | docs/design-system/audit-management.md:225 |
| MG-A03 | P2 | 账单日/还款日仍要求手输日期 | docs/design-system/audit-management.md:232 |
| MG-A04 | P1 | 无效金额/利率输入可能被静默丢弃后保存 | docs/design-system/audit-management.md:239 |
| MG-A05 | P2 | 编辑余额与“调整余额”并存，但没有说明后果差异 | docs/design-system/audit-management.md:246 |
| MG-A06 | P2 | 隐藏金额时资产/负债比例条仍呈现真实比例 | docs/design-system/audit-management.md:253 |
| MG-A07 | P2 | 账户与归物缺少按名称快速定位的入口 | docs/design-system/audit-management.md:260 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| DS-003 | P2 | 账本、分组两种数据范围缺少就地说明 | docs/design-system/audit-dashboard-stats.md:31 |
| MG-C01 | P1 | 长表单校验错误落在末尾，缺少就地定位 | docs/design-system/audit-management.md:99 |
| MG-C02 | P1 | 同一编辑表单混用“立即保存”和“点保存才生效” | docs/design-system/audit-management.md:106 |
| MG-C03 | P1 | 开关失败后，仍打开的表单可能继续显示成功值 | docs/design-system/audit-management.md:113 |
| MG-C04 | P2 | 表单可见标签未与输入控件建立明确的语义关联 | docs/design-system/audit-management.md:120 |
| MG-C05 | P1 | 重复开关缺少明确对象/用途的可访问名称 | docs/design-system/audit-management.md:127 |
| MG-C06 | P2 | 键盘流程缺少“下一项/完成”和明确退出路径 | docs/design-system/audit-management.md:134 |
| MG-C07 | P2 | 无数据、无搜索结果、筛选为空共用空态，缺少就地恢复动作 | docs/design-system/audit-management.md:141 |
| MG-C08 | P2 | 多页下拉刷新回调在数据返回前完成 | docs/design-system/audit-management.md:148 |
| MG-C09 | P2 | 移动/恢复后的等待和完成反馈不完整 | docs/design-system/audit-management.md:155 |
| MG-C10 | P2 | 停用记录的“业务状态”被处理成整行低透明度 | docs/design-system/audit-management.md:162 |
| MG-C12 | P2 | 更多菜单没有对象上下文，辅助操作也只叫“更多” | docs/design-system/audit-management.md:176 |
| MG-C14 | P2 | 错误文案与反馈语气仍不一致 | docs/design-system/audit-management.md:190 |
| MG-C17 | P2 | 多数管理页缺少当前账本/分组的可见上下文 | docs/design-system/audit-management.md:211 |
| MG-G04 | P2 | 购买日期与金额硬性双列，日期文字空间不足 | docs/design-system/audit-management.md:288 |
| MG-U04 | P2 | 移除协作成员时所有移除按钮变灰，目标行没有进行中标识 | docs/design-system/audit-management.md:561 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/features/accounts
```

1. 运行test/features/accounts及相关shared金额测试；覆盖负/零/未知、大余额、不同币种、非法利率、日期、停用/只读和隐私比例。
2. 同名不同尾号检索，恢复慢请求只一次，字段错误与余额操作说明可核对。

## 视觉证据与验收

- 该模块没有对应原截图，生成账户列表/不同类型表单/余额调整/回收站/隐藏及错误态亮暗大字证据。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S11-A.md`、`runtime/issue-checks/S11-A.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S11-B，回到已有S11会话，文件docs/design-system/execution-prompts/prompts/18-S11-B.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 18 · 回到已有S11会话

# S11-B｜归物列表、生命周期与详情编辑

**使用位置：回到已有S11会话。本轮只执行S11-B。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S11-B。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S11-B以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S11-B/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S11-B.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S11-B.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S11-B及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S11-A。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/features/goods/`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 保留物品图片和身份，按内容/字体决定单列或双列；名称、价格、状态与持有成本分层，大字不硬撑两列。支持已存在API能力内的名称定位与分页，>200不能静默失踪。
2. 必填分类不能同时无解释允许清空；选项加载失败有恢复入口，父路径/重名区分。购买日期/金额窄宽上下排列，少一层内卡和重复边距。
3. 保修、生命周期、处置、备注、附件按任务分组，日期清空/附件移除保持≥44命中区；状态、显示字段和提交合法性一致。
4. 已上传附件在详情和重新编辑可找回，支持的预览/打开明确；数据接口未返回附件时记录缺口，不伪造恢复。
5. 详情显示币种和完整价格/日均/售价/盈亏，关键内容优先；就地编辑并回更新后的同物品详情。更多tooltip对应真实菜单。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| MG-G01 | P1 | 归物分类允许清空，提交却必须有分类 | docs/design-system/audit-management.md:267 |
| MG-G02 | P1 | 必选分类选项加载失败后没有恢复入口 | docs/design-system/audit-management.md:274 |
| MG-G03 | P2 | 归物表单存在多层容器与左右留白叠加 | docs/design-system/audit-management.md:281 |
| MG-G04 | P2 | 购买日期与金额硬性双列，日期文字空间不足 | docs/design-system/audit-management.md:288 |
| MG-G05 | P1 | 日期清除和附件移除触控目标仅 16/18px | docs/design-system/audit-management.md:295 |
| MG-G06 | P2 | 已上传附件无法从归物详情或再次编辑中找回 | docs/design-system/audit-management.md:302 |
| MG-G07 | P2 | 两列网格没有随文字缩放降低列数 | docs/design-system/audit-management.md:309 |
| MG-G08 | P3 | 归物“更多”按钮的提示却写成详情 | docs/design-system/audit-management.md:316 |
| MG-G09 | P2 | 归物详情没有就地编辑动作 | docs/design-system/audit-management.md:323 |
| MG-G10 | P2 | 归物数量超过首批后没有继续浏览的提示或入口 | docs/design-system/audit-management.md:330 |
| MG-G11 | P2 | 次级数值缺少币种，详情像字段清单，信息层级偏平 | docs/design-system/audit-management.md:337 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| MG-C01 | P1 | 长表单校验错误落在末尾，缺少就地定位 | docs/design-system/audit-management.md:99 |
| MG-C04 | P2 | 表单可见标签未与输入控件建立明确的语义关联 | docs/design-system/audit-management.md:120 |
| MG-C05 | P1 | 重复开关缺少明确对象/用途的可访问名称 | docs/design-system/audit-management.md:127 |
| MG-C06 | P2 | 键盘流程缺少“下一项/完成”和明确退出路径 | docs/design-system/audit-management.md:134 |
| MG-C08 | P2 | 多页下拉刷新回调在数据返回前完成 | docs/design-system/audit-management.md:148 |
| MG-C12 | P2 | 更多菜单没有对象上下文，辅助操作也只叫“更多” | docs/design-system/audit-management.md:176 |
| MG-C14 | P2 | 错误文案与反馈语气仍不一致 | docs/design-system/audit-management.md:190 |
| MG-C15 | P2 | 少数关键状态/能力仍写死中文 | docs/design-system/audit-management.md:197 |
| MG-C17 | P2 | 多数管理页缺少当前账本/分组的可见上下文 | docs/design-system/audit-management.md:211 |
| MG-A07 | P2 | 账户与归物缺少按名称快速定位的入口 | docs/design-system/audit-management.md:260 |
| MG-U04 | P2 | 移除协作成员时所有移除按钮变灰，目标行没有进行中标识 | docs/design-system/audit-management.md:561 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/features/goods
```

1. 运行test/features/goods；分类失败重试、必填清空、日期清除、已有附件再次编辑、处置状态与提交、201条分页。
2. 详情编辑返回不跳别对象、长金额/名称/备注2倍字、同币种单位一致。

## 视觉证据与验收

- 原V48—V51对照；补新增、售出、保修过期、长名称/多附件、失败及大字单列。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S11-B.md`、`runtime/issue-checks/S11-B.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S12-A，新开S12会话，文件docs/design-system/execution-prompts/prompts/19-S12-A.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 19 · 新开S12会话

# S12-A｜服务器配置、登录与注册闭环

**使用位置：新开S12会话。本轮只执行S12-A。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S12-A。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S12-A以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S12-A/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S12-A.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S12-A.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S12-A及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S11-B。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/login/`
- `lib/core/auth/`
- `lib/core/navigation/startup_route_guard.dart`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 服务器地址输入保留完整粘贴和已有协议/域名/端口能力，字段错误明确；历史切换的实际协议/提交地址一致。登录页有可用改服务器入口，返回/连接错误能原位重试。
2. 短暂会话/版本检查失败不等于用户退出；无有效凭证与暂不可验证分别处理，绝不在不明状态绕过认证。
3. 多角色注册成功、用户取消、失败分别表达；提交/刷新验证码互斥，旧挑战在更新中不能继续提交，完成结果只处理一次。
4. 注册聚焦必需资料，选填可后置或清楚标注；密码规则依据真实后端合同，在注册/修改一致，不能为了省字段删除服务端必填值。
5. 验证码仅用服务器已提供的替代通道；没有非视觉通道必须记录外部阻断，不得关闭验证码校验或伪造通过。条款链接目标/不可打开反馈核对但不做法律自判。
6. 减少动态设置生效，键盘下所有输入/主要动作可达，角色/性别/错误关联完整；复用S1组件而非另起认证风格。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| FB-AUT-01 | P1 | 登录页没有可用的换服务器入口 | docs/design-system/audit-system.md:76 |
| FB-AUT-02 | P1 | 多角色注册成功被显示为取消 | docs/design-system/audit-system.md:84 |
| FB-AUT-03 | P1 | 短暂会话检查失败被当成退出登录 | docs/design-system/audit-system.md:92 |
| FB-AUT-04 | P2 | 版本检查失败只有改服务器，没有原位重试 | docs/design-system/audit-system.md:100 |
| FB-AUT-05 | P2 | 地址输入要求用户理解拆分结构，错误却不指出字段 | docs/design-system/audit-system.md:108 |
| FB-AUT-06 | P2 | 注册首屏要求过多资料，必填和选填不清楚 | docs/design-system/audit-system.md:116 |
| FB-AUT-07 | P2 | 密码规则在提示、注册校验和修改密码之间不一致 | docs/design-system/audit-system.md:124 |
| FB-AUT-08 | P1 | 启用图形验证码后没有非视觉完成路径 | docs/design-system/audit-system.md:132 |
| FB-AUT-09 | P2 | 验证码刷新时仍可提交旧内容 | docs/design-system/audit-system.md:140 |
| FB-AUT-10 | P3 | 主动取消被呈现成失败 | docs/design-system/audit-system.md:148 |
| FB-AUT-11 | P3 | 认证页内部动画没有遵循减少动态效果设置 | docs/design-system/audit-system.md:156 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| FB-SYS-01 | P2 | 表单错误缺少字段定位与可恢复的阅读路径 | docs/design-system/audit-system.md:26 |
| FB-SYS-02 | P2 | 异步操作只锁住部分入口，用户缺少稳定的处理中状态 | docs/design-system/audit-system.md:34 |
| FB-NAV-03 | P2 | Web 深链恢复直接回首页，原目标丢失 | docs/design-system/audit-system.md:632 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/login test/core/auth test/core/navigation/startup_route_guard_test.dart
```

1. 运行test/login与test/core/auth、startup_route_guard_test；改服务器、历史协议同步、暂时离线、版本失败重试、多角色结果与取消。
2. 验证码刷新/提交竞态、密码真实契约、长注册首错、键盘/2倍字和reduce motion。

## 视觉证据与验收

- 原V01—V03/V68—V69；失败、角色选择、验证码加载/失败、暗色键盘、320宽注册。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S12-A.md`、`runtime/issue-checks/S12-A.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S13-A，新开S13会话，文件docs/design-system/execution-prompts/prompts/20-S13-A.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 20 · 新开S13会话

# S13-A｜个人中心、资料、偏好与帮助

**使用位置：新开S13会话。本轮只执行S13-A。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S13-A。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S13-A以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S13-A/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S13-A.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S13-A.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S13-A及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S12-A。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/features/profile/`
- `lib/core/preferences/`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 个人中心按当前身份、常用偏好、管理、支持分层，常用设置不埋到长页末尾；详情身份/头像有明确操作，长姓名和账号可读。
2. 保存资料回原详情并更新；头像上传失败回原图，更新后刷新失败明确显示同步状态；性别未设置含义与清空payload依据现有契约区分。
3. 改密有新旧自动填充与显示/隐藏，输入错误就地，未保存和忙碌状态一致；注销提交途中退出不能造成会话清理或结果反馈丢失，不改后端账户删除范围。
4. 主题/语言/账期选择有真实selected语义和当前值；账期选择预览具体起止，清楚区分月末边界。
5. 配色从真实金额预览开始，色盲方案/自选色保留存储值，选中勾号与背景配对；不能一次90色块挤掉任务说明或把可读性责任转给用户。
6. 帮助按任务连续阅读、减少每段套卡；捐赠二维码窄宽改单列、保存反馈跟主题。当前Apple内购入口仍关闭，FB-IAP只检查条件并标适用性，禁止擅自重新启用或改变支付规则。
7. 本阶段避开app_lock_settings_page及应用锁逻辑，交由S13-B；其余跨共享文本/选择器只消费S1合同。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| FB-PRO-01 | P2 | 管理与偏好全部铺在单页，常用设置处于很深的位置 | docs/design-system/audit-system.md:166 |
| FB-PRO-02 | P2 | 个人资料入口与头像更换缺少可见操作提示 | docs/design-system/audit-system.md:174 |
| FB-PRO-03 | P2 | 资料页身份区域在窄屏给姓名的空间过少 | docs/design-system/audit-system.md:182 |
| FB-PRO-04 | P2 | 保存资料后同时退出详情页，缺少原位确认 | docs/design-system/audit-system.md:190 |
| FB-PRO-05 | P2 | 头像失败仍显示新图，形成已保存的假象 | docs/design-system/audit-system.md:198 |
| FB-PRO-06 | P2 | 性别的空值按钮“－”含义不明，且清空意图未提交 | docs/design-system/audit-system.md:206 |
| FB-PRO-07 | P2 | 修改密码无法核对明文，自动填充也没有区分新旧 | docs/design-system/audit-system.md:214 |
| FB-PRO-08 | P2 | 配色编辑一次展示 90 个色块，缺少实际金额预览 | docs/design-system/audit-system.md:222 |
| FB-PRO-09 | P2 | 选中色块统一白色勾号，在亮色上不够清楚 | docs/design-system/audit-system.md:230 |
| FB-PRO-10 | P2 | 捐赠双列布局在窄屏与大字下过于拥挤 | docs/design-system/audit-system.md:238 |
| FB-PRO-11 | P3 | 二维码保存反馈使用固定色，未随主题语义调整 | docs/design-system/audit-system.md:246 |
| FB-PRO-12 | P3 | 帮助内容逐项套卡，阅读连续性被反复打断 | docs/design-system/audit-system.md:254 |
| FB-PRO-13 | P2 | 资料更新后刷新失败静默保留旧值，成功反馈与页面不一致 | docs/design-system/audit-system.md:262 |
| FB-NAV-01 | P2 | 资料详情主动禁止 pop，使 Apple 原生返回手势难以成立 | docs/design-system/audit-system.md:616 |
| FB-PRO-14 | P1 | 注销请求途中关闭弹层，成功后可能没有结果反馈与会话清理 | docs/design-system/audit-system.md:666 |
| FB-IAP-01 | P2 | 恢复入口后，用户取消购买会得到失败提示【条件问题】 | docs/design-system/audit-system.md:678 |
| FB-IAP-02 | P2 | 反馈和金额缺少明确的购买结果层级【条件问题】 | docs/design-system/audit-system.md:686 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| FB-SYS-01 | P2 | 表单错误缺少字段定位与可恢复的阅读路径 | docs/design-system/audit-system.md:26 |
| FB-SYS-02 | P2 | 异步操作只锁住部分入口，用户缺少稳定的处理中状态 | docs/design-system/audit-system.md:34 |
| FB-SYS-03 | P2 | 长编辑流程没有本地草稿离开保护 | docs/design-system/audit-system.md:42 |
| FB-SYS-04 | P2 | 关键说明和操作状态被降到过弱的文字层 | docs/design-system/audit-system.md:50 |
| FB-SYS-05 | P2 | 局部视觉选择态、标签和可点击语义没有完整对应 | docs/design-system/audit-system.md:58 |
| FB-AUT-07 | P2 | 密码规则在提示、注册校验和修改密码之间不一致 | docs/design-system/audit-system.md:124 |
| FB-REC-19 | P2 | 执行时间的时区显示规则不一致 | docs/design-system/audit-system.md:606 |
| FB-NAV-02 | P2 | 主壳底部避让量可能重复预留导航栏，末尾留下大空白 | docs/design-system/audit-system.md:624 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/features/profile test/core/preferences
```

1. 运行test/features/profile、test/core/preferences和相关auth用例；头像失败/资料更新后刷新失败、性别未设/清空、改密、注销中关闭。
2. 主题/语言/月起始日selected节点、配色高低明度勾号、长姓名、大字二维码；IAP关闭入口不回归开启。

## 视觉证据与验收

- 原V23—V27/V60—V62/V64—V67，资料编辑失败、配色金额预览、帮助大字、暗色。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S13-A.md`、`runtime/issue-checks/S13-A.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S13-B，回到已有S13会话，文件docs/design-system/execution-prompts/prompts/21-S13-B.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 21 · 回到已有S13会话

# S13-B｜应用锁、恢复与无障碍解锁

**使用位置：回到已有S13会话。本轮只执行S13-B。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S13-B。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S13-B以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S13-B/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S13-B.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S13-B.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S13-B及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S13-A。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/core/app_lock/`
- `lib/features/profile/presentation/app_lock_settings_page.dart`
- `lib/core/security/`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 区分凭证不存在、读取失败、正常锁定。提供经过真实身份验证的恢复/重新登录路线；不能直接清锁放行受保护内容、不能因存储异常降级为已解锁。
2. 锁屏自身键盘避让与滚动完整；读屏手势选点有明确完成/清除，节点位置与视觉坐标匹配，未完成手势不跨尝试累积。
3. 验证失败留在当前输入层并解释如何重试，成功立即进入确定结果；本地凭证验证显示忙碌，避免重复触发。
4. 设置解锁方式与备用凭证的关系清楚，支持经过旧凭证验证后的方式变更，不要求先关保护；所有改变保持原安全边界与跨平台能力检测。
5. 只修改交互/状态表达与有证据的本地缺陷，不自创密码恢复后门、不弱化尝试限制/安全存储/生命周期保护。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| FB-LCK-01 | P1 | 凭证丢失/读取失败的锁屏没有恢复出口 | docs/design-system/audit-system.md:272 |
| FB-LCK-02 | P1 | 锁屏没有自己的键盘避让和滚动容器 | docs/design-system/audit-system.md:280 |
| FB-LCK-03 | P1 | 手势锁的读屏选点缺少完成动作 | docs/design-system/audit-system.md:288 |
| FB-LCK-04 | P2 | 手势节点的语义位置与绘制位置不重合 | docs/design-system/audit-system.md:296 |
| FB-LCK-05 | P2 | 未完成手势会残留并续接，锁屏缺少清除入口 | docs/design-system/audit-system.md:304 |
| FB-LCK-06 | P2 | 手势确认成功后仍要求确认，失败关闭验证只剩红色网格 | docs/design-system/audit-system.md:312 |
| FB-LCK-07 | P2 | 关闭 PIN 锁先关闭输入层，验证失败必须重新开始 | docs/design-system/audit-system.md:320 |
| FB-LCK-08 | P2 | 设置页把简单开锁偏好变成两组重复选择 | docs/design-system/audit-system.md:328 |
| FB-LCK-09 | P2 | 修改解锁方式需要先关闭保护，缺少直接修改入口 | docs/design-system/audit-system.md:336 |
| FB-LCK-10 | P2 | 本地凭证验证没有用户可见的验证中反馈 | docs/design-system/audit-system.md:344 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| FB-SYS-01 | P2 | 表单错误缺少字段定位与可恢复的阅读路径 | docs/design-system/audit-system.md:26 |
| FB-SYS-04 | P2 | 关键说明和操作状态被降到过弱的文字层 | docs/design-system/audit-system.md:50 |
| FB-SYS-05 | P2 | 局部视觉选择态、标签和可点击语义没有完整对应 | docs/design-system/audit-system.md:58 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/core/app_lock test/core/security
```

1. 运行test/core/app_lock、test/core/security及profile/app_lock相关测试；安全存储缺失/异常、有效错误凭证、读取恢复路径。
2. 仅语义节点完成手势、清除/短路径/跨次不续接，键盘PIN失败重试、验证中禁重复、锁后底层点击和语义仍隔离。

## 视觉证据与验收

- 原V63；补真实锁屏PIN/手势/错误/恢复入口、键盘、2倍字与亮暗，记录VoiceOver实机是否执行。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S13-B.md`、`runtime/issue-checks/S13-B.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S14-A，新开S14会话，文件docs/design-system/execution-prompts/prompts/22-S14-A.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 22 · 新开S14会话

# S14-A｜周期记账调度、模板保全与执行结果

**使用位置：新开S14会话。本轮只执行S14-A。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S14-A。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S14-A以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S14-A/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S14-A.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S14-A.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S14-A及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S13-B。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/features/recurring/`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 列表每条明确所属账本、类型、金额/币种、账户、启停和下次执行；不是以当前账本标题覆盖多账本集合。主点击打开可理解详情，日志/编辑明确可达。
2. 旧调度无法无损解析时保留原值并提示不支持可视编辑，不能保存成每天09:00；旧模板多分类/标签/附加字段不能静默删减。修改必须保留未编辑字段或明确阻止有损保存。
3. 月末不是31日，月日组合和跳过月份规则来自已知调度语义；下次执行与时区显示一致，未证实的服务器时区不能盲目toLocal。
4. 表单先交易任务、再频率/日期/时间、再限制/补偿策略；有下一次生成预览和实际后果解释，日期/金额校验即时，忙碌包含调度验证全过程。
5. 选项失效保留“原值已不可选”的事实，不自动变成未选择/默认；七列日期有可达替代，长调度文案可完整阅读。
6. 日志有结果与生成账单入口；未知执行状态不默认成功，暂停不虚报正常下次执行；首次空态引导创建，刷新保留旧结果，删除目标级状态。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| FB-REC-01 | P1 | 列表聚合多个账本，却用当前账本名作为页面上下文 | docs/design-system/audit-system.md:462 |
| FB-REC-02 | P1 | 编辑无法解析的旧调度会自动改成每天 09:00 | docs/design-system/audit-system.md:470 |
| FB-REC-03 | P1 | 旧账单模板在编辑时被静默简化 | docs/design-system/audit-system.md:478 |
| FB-REC-04 | P1 | “月末”在摘要中被当成“31日” | docs/design-system/audit-system.md:486 |
| FB-REC-05 | P2 | 月日选择可以组合不存在的日期，缺少跳过月份的说明 | docs/design-system/audit-system.md:494 |
| FB-REC-06 | P2 | 周期日期和金额仍是自由文本，错误到提交时才出现 | docs/design-system/audit-system.md:502 |
| FB-REC-07 | P2 | 提交先验证调度再检查基本输入，等待期间按钮不转圈 | docs/design-system/audit-system.md:510 |
| FB-REC-08 | P2 | 长表单把限制条件排在账单内容之前，核心交易内容靠后 | docs/design-system/audit-system.md:518 |
| FB-REC-09 | P2 | 规则列表没有金额、类型和账户，难以识别自动交易 | docs/design-system/audit-system.md:526 |
| FB-REC-10 | P2 | 卡片点击默认打开日志，编辑隐藏在更多菜单 | docs/design-system/audit-system.md:534 |
| FB-REC-11 | P2 | 调度和下次时间强制单行，长规则信息会被省略 | docs/design-system/audit-system.md:542 |
| FB-REC-12 | P2 | 空规则列表主动作是重试，缺少建立第一条规则的引导 | docs/design-system/audit-system.md:550 |
| FB-REC-13 | P2 | 刷新整页转圈，删除也没有条目级处理中反馈 | docs/design-system/audit-system.md:558 |
| FB-REC-14 | P2 | 日期网格固定七列，触区宽度与文字缩放没有适配 | docs/design-system/audit-system.md:566 |
| FB-REC-15 | P2 | 分类/账户选项失去区分上下文，旧选中值可能显示成未选择 | docs/design-system/audit-system.md:574 |
| FB-REC-16 | P2 | 补偿策略只显示标签，缺少对自动生成账单后果的解释 | docs/design-system/audit-system.md:582 |
| FB-REC-17 | P2 | 执行日志暴露内部编号，却不能进入生成的账单 | docs/design-system/audit-system.md:590 |
| FB-REC-18 | P2 | 未知执行状态被默认染成成功，暂停规则仍展示下一次执行 | docs/design-system/audit-system.md:598 |
| FB-REC-19 | P2 | 执行时间的时区显示规则不一致 | docs/design-system/audit-system.md:606 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| FB-SYS-01 | P2 | 表单错误缺少字段定位与可恢复的阅读路径 | docs/design-system/audit-system.md:26 |
| FB-SYS-03 | P2 | 长编辑流程没有本地草稿离开保护 | docs/design-system/audit-system.md:42 |
| FB-SYS-04 | P2 | 关键说明和操作状态被降到过弱的文字层 | docs/design-system/audit-system.md:50 |
| FB-SYS-05 | P2 | 局部视觉选择态、标签和可点击语义没有完整对应 | docs/design-system/audit-system.md:58 |
| FB-SYS-06 | P2 | 技术异常直接成为面向用户的错误文案 | docs/design-system/audit-system.md:66 |
| FB-IO-03 | P2 | 无账本空态只有说明，没有完成前置条件的入口 | docs/design-system/audit-system.md:370 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

```sh
flutter test --no-pub test/features/recurring
```

1. 运行test/features/recurring；无法解析cron、月末/31号、2月/闰年、不同明确时区/无时区、旧多分类模板往返不变。
2. 模板选项缺失、补偿策略确认、调度校验慢请求、暂停/未知状态、日志关联账单；验证请求快照。

## 视觉证据与验收

- 原V55—V57；复杂规则/旧模板/错误/暂停/执行日志、明暗大字。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S14-A.md`、`runtime/issue-checks/S14-A.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S15-A，新开S15会话，文件docs/design-system/execution-prompts/prompts/23-S15-A.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 23 · 新开S15会话

# S15-A｜导入导出文件交付与结果检查

**使用位置：新开S15会话。本轮只执行S15-A。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S15-A。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S15-A以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S15-A/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S15-A.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S15-A.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S15-A及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S14-A。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/features/io/`
- `lib/util/web_download.dart`
- `lib/util/web_download_stub.dart`
- `lib/util/image_save_service.dart`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 导出/下载模板必须让用户实际得到文件：使用已有平台能力的系统保存/分享/打开，不能只报内部临时路径成功。先核iOS/Android/Web/鸿蒙现有插件支持，复用可用接口。
2. 导入形成明确步骤：当前目标账本→选文件→确认文件名/类型/大小与目标→提交→结果；没有账本提供建立/切换入口。用户取消选文件是取消不是失败。
3. 导出、模板、导入三个同型卡改成任务清晰的工具区和步骤，结果成功/部分失败/全失败区分；可查看导入账单、获取错误文件和重试。
4. 长路径不用toast承载，下载/处理各有忙碌与结果；多列统计大字重排，异常首层为用户语言。
5. 不修改服务器导入/导出格式、财务数据、权限或偷偷加入不可用平台插件。若现有依赖确实不能交付系统文件，在本轮先提供具体能力证据/最小依赖变更方案，列外部/依赖阻断，不伪装已交付。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| FB-IO-01 | P1 | 普通原生平台导出只落临时目录，用户没有拿到文件 | docs/design-system/audit-system.md:354 |
| FB-IO-02 | P1 | 导入前看不到目标账本和已选文件确认 | docs/design-system/audit-system.md:362 |
| FB-IO-03 | P2 | 无账本空态只有说明，没有完成前置条件的入口 | docs/design-system/audit-system.md:370 |
| FB-IO-04 | P2 | 导出、模板、导入被拆成三个同型卡片，导入步骤不连续 | docs/design-system/audit-system.md:378 |
| FB-IO-05 | P2 | 导入结果只有数字，没有把用户送到可检查的结果 | docs/design-system/audit-system.md:386 |
| FB-IO-06 | P2 | 所有结果都用同一种短提示，长文件路径和失败难以辨认 | docs/design-system/audit-system.md:394 |
| FB-IO-07 | P2 | 导入统计固定三列，大字和大计数缺少布局余量 | docs/design-system/audit-system.md:402 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| FB-SYS-02 | P2 | 异步操作只锁住部分入口，用户缺少稳定的处理中状态 | docs/design-system/audit-system.md:34 |
| FB-SYS-04 | P2 | 关键说明和操作状态被降到过弱的文字层 | docs/design-system/audit-system.md:50 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

本轮没有现成模块测试目录时必须建立真实行为用例再执行；不得用空目录/未发现测试当通过。

1. 运行/新增test/features/io，使用临时文件和可控平台适配器验证目标/选中文件/取消/输出字节与文件名/结果状态，不写真实账本。
2. 平台工具返回失败/取消/成功区别，错误文件可重取；系统文件保存是否真可取需模拟器/设备证据单列。

## 视觉证据与验收

- 原V58；导出成功可取文件、选文件确认、导入部分失败、无账本、亮暗大字。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S15-A.md`、`runtime/issue-checks/S15-A.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S15-B，回到已有S15会话，文件docs/design-system/execution-prompts/prompts/24-S15-B.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 24 · 回到已有S15会话

# S15-B｜操作日志、搜索与事件详情

**使用位置：回到已有S15会话。本轮只执行S15-B。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S15-B。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S15-B以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S15-B/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S15-B.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S15-B.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S15-B及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S15-A。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/features/logs/`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 搜索请求/结果有明确当前条件，失败时保留旧结果必须标旧条件/更新失败；防抖不能让晚到旧请求覆盖新查询。清除和零结果有恢复入口。
2. 分页失败保留已读列表、明确加载失败可重试，不把失败当到底；刷新等待真实结束，空态/错误不同。
3. 日志先表达行为主体、动作、结果、时间，状态不重复；长正文和机器参数不抢首屏，详情参数/堆栈折叠可复制，安全脱敏。
4. 时间/状态筛选只使用真实已支持API；没有能力时不对当前页本地过滤冒充全局筛选，标查询能力缺口。状态0/1含义先核实，不能按别工程习惯翻转颜色。
5. 真实异常映射用户任务文案，技术诊断留折叠区；日期/时区按服务端合同，不猜原始时间含义。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| FB-LOG-01 | P1 | 已有结果时搜索失败仍呈现旧结果，用户可能误读查询范围 | docs/design-system/audit-system.md:412 |
| FB-LOG-02 | P2 | 分页失败无反馈、无重试，列表看似已经结束 | docs/design-system/audit-system.md:420 |
| FB-LOG-03 | P2 | 状态在一行中重复，时间和行为主体被长句挤压 | docs/design-system/audit-system.md:428 |
| FB-LOG-04 | P2 | 日志详情把参数和堆栈全部展开在同一阅读层 | docs/design-system/audit-system.md:436 |
| FB-LOG-05 | P2 | 搜索清除和零结果恢复不足 | docs/design-system/audit-system.md:444 |
| FB-LOG-06 | P2 | 查询只能按用户名，缺少定位失败事件的基本时间/状态条件 | docs/design-system/audit-system.md:452 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| FB-SYS-06 | P2 | 技术异常直接成为面向用户的错误文案 | docs/design-system/audit-system.md:66 |
| FB-REC-19 | P2 | 执行时间的时区显示规则不一致 | docs/design-system/audit-system.md:606 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |

## 决定性验证

本轮没有现成模块测试目录时必须建立真实行为用例再执行；不得用空目录/未发现测试当通过。

1. 运行/新增test/features/logs；旧结果+新查询失败、搜索乱序、分页失败重试、清除、空/权限/长错误。
2. 状态枚举fixture与接口文档对照；复制诊断不包含凭证，筛选范围真实，不减少日志可追溯性。

## 视觉证据与验收

- 原V59实际为操作日志（以screenshots.tsv最新映射核实）；补详情、分页/搜索失败、明暗大字。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S15-B.md`、`runtime/issue-checks/S15-B.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S1-C，回到已有S1会话，文件docs/design-system/execution-prompts/prompts/25-S1-C.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 25 · 回到已有S1会话

# S1-C｜回到共享底座会话，完成全工程一致性收口

**使用位置：回到已有S1会话。本轮只执行S1-C。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S1-C。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S1-C以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S1-C/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S1-C.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S1-C.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S1-C及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S1-A, S3-A, S4-A, S4-B, S5-A, S6-A, S6-B, S6-C, S7-A, S8-A, S8-B, S8-C, S9-A, S10-A, S11-A, S11-B, S12-A, S13-A, S13-B, S14-A, S15-A, S15-B。
必须读对应handoff与runtime。

## 本阶段允许写入范围

- `lib/fx/`
- `lib/core/money/`
- `lib/core/errors/`
- `lib/core/feedback/`
- `lib/core/preferences/finance_color_preferences.dart`
- `各阶段已经登记的共享组件直接调用点`
允许同域必要测试、当前阶段渲染fixture与中英文新增文案；不允许顺手改其它域。范围是上界，只改当前任务所需文件。引用的跨域问题只处理当前scope实例，后续消费者由其owner落地。

## 必须完成的具体工作

1. 这是回到S1的集成轮次。先读取所有阶段handoff和问题实例状态，从当前累积代码继续；不能用S1-A时旧版本文件覆盖页面迁移。
2. 逐一关闭所有DT/CX和共性MG-C/FB-SYS/BO共性实例，核对每个调用模块的证据。底座完成不等于页面已消费，source paths中的每个受影响页面都必须有已迁入/已证伪/外部阻断判定。
3. 全局扫描显式字号/字重/圆角/opacity/边界/固定高度/硬编码前景，逐处判断用途。图形尺寸、品牌资产背景、技术等宽字符串可合理保留，不能机械替换所有数字或把所有文字都变17。
4. 统一共享参数、语义、选中态、隐藏状态跨route、错误文案和反馈；只允许必要直接调用适配，禁止在此重写任何业务页面或改财务规则。发现缺失业务闭环登记给原owner，不越界包办。
5. 核对组件contract版本、所有消费者、返回结果协议和页面inset责任；修复接口漂移、重复包装、丢适配等真实集成缺陷，补必要回归。
6. 刷新设计底座代码合集与组件目录的当前版本副本，原2026-11-05审计/代码合集作为历史只读；本包内记录新交付来源与例外清单。

## 本阶段主责问题

| ID | 优先级 | 问题与本阶段边界 | 原报告 |
| --- | --- | --- | --- |
| DS-012 | P2 | 首页及统计卡错误可能暴露技术异常，且切断识别上下文 | docs/design-system/audit-dashboard-stats.md:103 |
| DS-016 | P2 | 财务摘要仍以固定多列分配宽度，大字号缺少局部重排 | docs/design-system/audit-dashboard-stats.md:135 |
| DS-021 | P2 | 长按拖动是唯一排序方式，缺少可访问的等效操作 | docs/design-system/audit-dashboard-stats.md:177 |
| DS-022 | P2 | 拖动时禁止列表滚动，跨屏排序缺少路径 | docs/design-system/audit-dashboard-stats.md:185 |
| DS-023 | P2 | 统计拖动占位骤缩为 72，打乱当前布局参照 | docs/design-system/audit-dashboard-stats.md:193 |
| DS-024 | P2 | 移动浏览器编辑首页时直接按下即拖，和滚动竞争 | docs/design-system/audit-dashboard-stats.md:201 |
| DS-025 | P2 | 若干局部操作目标明显比常规按钮小 | docs/design-system/audit-dashboard-stats.md:209 |
| DS-030 | P2 | 表面层级仍混用抬升卡、彩色内卡和高阴影编辑反馈 | docs/design-system/audit-dashboard-stats.md:249 |
| DS-049 | P2 | 无账本/分组与空数据状态缺少就地可行动引导 | docs/design-system/audit-dashboard-stats.md:405 |
| MG-C01 | P1 | 长表单校验错误落在末尾，缺少就地定位 | docs/design-system/audit-management.md:99 |
| MG-C02 | P1 | 同一编辑表单混用“立即保存”和“点保存才生效” | docs/design-system/audit-management.md:106 |
| MG-C03 | P1 | 开关失败后，仍打开的表单可能继续显示成功值 | docs/design-system/audit-management.md:113 |
| MG-C04 | P2 | 表单可见标签未与输入控件建立明确的语义关联 | docs/design-system/audit-management.md:120 |
| MG-C05 | P1 | 重复开关缺少明确对象/用途的可访问名称 | docs/design-system/audit-management.md:127 |
| MG-C06 | P2 | 键盘流程缺少“下一项/完成”和明确退出路径 | docs/design-system/audit-management.md:134 |
| MG-C07 | P2 | 无数据、无搜索结果、筛选为空共用空态，缺少就地恢复动作 | docs/design-system/audit-management.md:141 |
| MG-C08 | P2 | 多页下拉刷新回调在数据返回前完成 | docs/design-system/audit-management.md:148 |
| MG-C09 | P2 | 移动/恢复后的等待和完成反馈不完整 | docs/design-system/audit-management.md:155 |
| MG-C10 | P2 | 停用记录的“业务状态”被处理成整行低透明度 | docs/design-system/audit-management.md:162 |
| MG-C11 | P2 | 普通移入回收站仍被要求勾选并完整输入名称 | docs/design-system/audit-management.md:169 |
| MG-C12 | P2 | 更多菜单没有对象上下文，辅助操作也只叫“更多” | docs/design-system/audit-management.md:176 |
| MG-C13 | P2 | 只读权限提示太晚，仍引导用户进入编辑 | docs/design-system/audit-management.md:183 |
| MG-C14 | P2 | 错误文案与反馈语气仍不一致 | docs/design-system/audit-management.md:190 |
| MG-C15 | P2 | 少数关键状态/能力仍写死中文 | docs/design-system/audit-management.md:197 |
| MG-C16 | P2 | 轻量基础资料表单把排序/备注放在启用等核心设置之前 | docs/design-system/audit-management.md:204 |
| MG-C17 | P2 | 多数管理页缺少当前账本/分组的可见上下文 | docs/design-system/audit-management.md:211 |
| BO-004 | P2 | 共性｜表单的视觉标签没有形成明确的输入语义 | docs/design-system/audit-bills-orders.md:69 |
| BO-005 | P2 | 共性｜数字键盘与长表单缺少一致的结束编辑路径 | docs/design-system/audit-bills-orders.md:78 |
| BO-006 | P2 | 共性｜金额输入对常见粘贴内容静默拒绝 | docs/design-system/audit-bills-orders.md:87 |
| BO-007 | P2 | 共性｜确认、作废、归档等请求进行中没有对应的可见忙碌状态 | docs/design-system/audit-bills-orders.md:96 |
| BO-008 | P2 | 共性｜只读状态被绘制成可点击但无结果的控件 | docs/design-system/audit-bills-orders.md:105 |
| BO-009 | P2 | 共性｜关键状态和对账辅助金额被压到小号字层级 | docs/design-system/audit-bills-orders.md:114 |
| BO-010 | P2 | 共性｜强色表面的配对前景已部分修正，媒体预览关闭对比仍待核对 | docs/design-system/audit-bills-orders.md:123 |
| BO-072 | P3 | 共性｜部分用户文案绕过本地化且日期格式不一致 | docs/design-system/audit-bills-orders.md:683 |
| BO-074 | P2 | 共性｜列表顶部多层控制始终固定，缺少小高度和大字时的收敛 | docs/design-system/audit-bills-orders.md:701 |
| FB-SYS-01 | P2 | 表单错误缺少字段定位与可恢复的阅读路径 | docs/design-system/audit-system.md:26 |
| FB-SYS-02 | P2 | 异步操作只锁住部分入口，用户缺少稳定的处理中状态 | docs/design-system/audit-system.md:34 |
| FB-SYS-03 | P2 | 长编辑流程没有本地草稿离开保护 | docs/design-system/audit-system.md:42 |
| FB-SYS-04 | P2 | 关键说明和操作状态被降到过弱的文字层 | docs/design-system/audit-system.md:50 |
| FB-SYS-05 | P2 | 局部视觉选择态、标签和可点击语义没有完整对应 | docs/design-system/audit-system.md:58 |
| FB-SYS-06 | P2 | 技术异常直接成为面向用户的错误文案 | docs/design-system/audit-system.md:66 |
| DT-01 | P2 | 原 palette 只有 canvas/surface/surfaceMuted，sheet 也取 surface；fx_theme.dart、fx_sheet.dart（S） | docs/design-system/2026-11-05-global-audit.md:75 |
| DT-02 | P2 | 原亮色 canvas #F7F8FA、muted #F5F6F8 与白表面极近（S/V） | docs/design-system/2026-11-05-global-audit.md:76 |
| DT-03 | P2 | 原暗色 #0B0F17/#161B24/#1F2630 带明显蓝色底调（S） | docs/design-system/2026-11-05-global-audit.md:77 |
| DT-04 | P2 | border 同时用于卡片轮廓、分隔线、输入框、图表网格（S） | docs/design-system/2026-11-05-global-audit.md:78 |
| DT-05 | P2 | FxListSection 对 border 再加 0.72 alpha；其他调用各用不同 alpha（S） | docs/design-system/2026-11-05-global-audit.md:79 |
| DT-06 | P1 | 原暗色 primary #4D94FF 搭白字约3.00:1（T） | docs/design-system/2026-11-05-global-audit.md:80 |
| DT-07 | P1 | 原 danger #EF4444 配白字约3.76:1（T） | docs/design-system/2026-11-05-global-audit.md:81 |
| DT-08 | P2 | secondary 与 tertiary 分别借用 info 蓝、warning 橙（S） | docs/design-system/2026-11-05-global-audit.md:82 |
| DT-09 | P2 | ColorScheme 只设置最高 surfaceContainer，其余依赖默认（S） | docs/design-system/2026-11-05-global-audit.md:83 |
| DT-10 | P2 | scrim 原先借用 shadow（S） | docs/design-system/2026-11-05-global-audit.md:84 |
| DT-11 | P2 | textSecondary #5B6470 与 tertiary #646C78 彼此约1.13:1（T） | docs/design-system/2026-11-05-global-audit.md:85 |
| DT-12 | P1 | income/expense/adjust 等财务默认色由偏好直接用作文字，明暗共用；亮色绿/橙等普通小字对比不足（S/T） | docs/design-system/2026-11-05-global-audit.md:86 |
| DT-13 | P2 | 图表 categorical 是一套静态亮色列表，财务色、排名色、分类色混用（S） | docs/design-system/2026-11-05-global-audit.md:87 |
| DT-14 | P2 | 净资产、借贷、资产/负债条和卡片色域大面积红绿；V04/V18/V20（V） | docs/design-system/2026-11-05-global-audit.md:88 |
| DT-15 | P1 | 小票费用 #C47A2C/#FFF0DD≈3.04；优惠 #D14343/#FFE8E8≈3.91，10号字；DS-037（S/T） | docs/design-system/2026-11-05-global-audit.md:89 |
| DT-16 | P2 | 原 TextTheme 只改颜色，FxTypography 单独设15/13/12（S） | docs/design-system/2026-11-05-global-audit.md:95 |
| DT-17 | P2 | display34/titleLarge22/title18 全部700（S/V） | docs/design-system/2026-11-05-global-audit.md:96 |
| DT-18 | P1 | 原正文15、标签13、辅助12，而账单时间/账户/状态大量降到caption（S/V） | docs/design-system/2026-11-05-global-audit.md:97 |
| DT-19 | P1 | 日历农历/年月金额9、状态10、图表11/12；还有12.5/13.5等游离字号（S） | docs/design-system/2026-11-05-global-audit.md:98 |
| DT-20 | P2 | 原标题height1.1/1.2、label/caption1.3，部分局部height1（S） | docs/design-system/2026-11-05-global-audit.md:99 |
| DT-21 | P2 | RobotoMono 未在 pubspec 注册，金额却显式指向它（S） | docs/design-system/2026-11-05-global-audit.md:100 |
| DT-22 | P2 | 默认 Material 字距可能继承进中文自定义字号（S） | docs/design-system/2026-11-05-global-audit.md:101 |
| DT-23 | P1 | 主金额普遍单行ellipsis；V18直接看到金额末尾“…”（V/S） | docs/design-system/2026-11-05-global-audit.md:102 |
| DT-24 | P2 | 行标题600、金额600、次级操作600同时出现（S/V） | docs/design-system/2026-11-05-global-audit.md:103 |
| DT-25 | P2 | FxListItem/FxSelectRow 的名称、当前值常永久单行截断（S） | docs/design-system/2026-11-05-global-audit.md:104 |
| DT-26 | P2 | 原颜色对比测试使用sRGB指数3而非2.4（S/T） | docs/design-system/2026-11-05-global-audit.md:105 |
| DT-27 | P2 | FxSpacing自称8pt，但包含4/12/20，且仅大小序列无用途（S） | docs/design-system/2026-11-05-global-audit.md:111 |
| DT-28 | P2 | 页面、sheet、内卡、字段多层16叠加，归物尤其明显；V50—51（V/S） | docs/design-system/2026-11-05-global-audit.md:112 |
| DT-29 | P2 | 自定义导航标题常16，FxSheet/pageH原16；更新后部分显式16仍存在（S） | docs/design-system/2026-11-05-global-audit.md:113 |
| DT-30 | P1 | FxButton原固定48＋单行ellipsis（T） | docs/design-system/2026-11-05-global-audit.md:114 |
| DT-31 | P2 | 固定网格行高、固定图高、固定导航高与局部大字策略并存（S） | docs/design-system/2026-11-05-global-audit.md:115 |
| DT-32 | P2 | 小字号标签反复呈现为胶囊，但一屏出现几十上百个；V30—33（V） | docs/design-system/2026-11-05-global-audit.md:116 |
| DT-33 | P2 | 图表留白巨大而图例/金额很小，V18—20（V） | docs/design-system/2026-11-05-global-audit.md:117 |
| DT-34 | P1 | 局部clear16/18、select clear32宽、tree40，与44/48按钮并存（S） | docs/design-system/2026-11-05-global-audit.md:118 |
| DT-35 | P2 | 列表底部重复预留导航、FAB、安全区；部分末尾留白过长（S/I） | docs/design-system/2026-11-05-global-audit.md:119 |
| DT-36 | P2 | token12/16/20，但列表14、彩色内框18及多处10/8（S） | docs/design-system/2026-11-05-global-audit.md:125 |
| DT-37 | P2 | 胶囊同时表达筛选、状态、颜色、树属性和导航（V/S） | docs/design-system/2026-11-05-global-audit.md:126 |
| DT-38 | P2 | “卡片标题—内卡—输入框—圆图标底座”层层造框；V18/V50—51/V63/V66（V/S） | docs/design-system/2026-11-05-global-audit.md:127 |
| DT-39 | P2 | FxCard注释仍称柔阴影，默认已false；DashboardShell却显式true（S） | docs/design-system/2026-11-05-global-audit.md:128 |
| DT-40 | P2 | 统计拖动elevation10、首页4、移除按钮2、分段选中另加阴影（S） | docs/design-system/2026-11-05-global-audit.md:129 |
| DT-41 | P2 | 原卡片InkWell下面绘制不透明Container，又以缩放反馈（S） | docs/design-system/2026-11-05-global-audit.md:130 |
| DT-42 | P2 | FxChip仍是Material→InkWell→不透明Container，TagChip用裸GestureDetector（S） | docs/design-system/2026-11-05-global-audit.md:131 |
| DT-43 | P2 | Motion已支持disableAnimations，但分组160ms、部分认证/网格仍直接写动画（S） | docs/design-system/2026-11-05-global-audit.md:132 |
| DT-44 | P2 | 普通操作普遍selectionClick，卡和回调可能重复触感（S） | docs/design-system/2026-11-05-global-audit.md:133 |
| DT-45 | P2 | 多页loading/error把有标题内容换成无上下文小转圈/错误（S） | docs/design-system/2026-11-05-global-audit.md:134 |
| CX-01 | P2 | FxTagChip 的删除图标13px、裸GestureDetector，无最小触区与明确删除对象；将静态tag与可操作chip分成清楚的呈现。 | docs/design-system/2026-11-05-global-audit.md:339 |
| CX-02 | P2 | FxSelectRow清空目标32×48，固定96标签列、单行当前值；大字时应上下重排，清除语义带字段名。 | docs/design-system/2026-11-05-global-audit.md:340 |
| CX-03 | P2 | FxTreePicker展开按钮40×40，树深度缩进进一步减少名称宽度；搜索后仍需父路径上下文和足够触区。 | docs/design-system/2026-11-05-global-audit.md:341 |
| CX-04 | P2 | 分组切换_GroupPill以caption+上下8生成约32px高目标；没有selected/button语义和键盘路径。不能因颜色显著就当可访问性完成。 | docs/design-system/2026-11-05-global-audit.md:342 |
| CX-05 | P2 | FxActionSheet普通操作图标统一primary，导航、复制、编辑全部蓝；用中性图标，选中和危险才强调。 | docs/design-system/2026-11-05-global-audit.md:343 |
| CX-06 | P2 | FxListItem主标题/副标题常单行；trailing没有预留长值预算；保持行内关联，并提供大字重排。 | docs/design-system/2026-11-05-global-audit.md:344 |
| CX-07 | P2 | FxSegmented先按等分列宽再单行ellipsis，增高无法修复长名称宽度；少项分段/更多项选择列表，避免同一个控件承接所有基数。 | docs/design-system/2026-11-05-global-audit.md:345 |
| CX-08 | P2 | FxBentoGrid固定2列起和rowSpan，不考虑文字内容高度，且animationDuration未统一resolve；对编辑态提供紧凑摘要清单，减少动态时避免位移动画。 | docs/design-system/2026-11-05-global-audit.md:346 |
| CX-09 | P2 | FxStateView空态/失败都使用48图标＋居中短文，场景上下文弱；真实空态、筛选零结果、首次创建与加载失败使用不同任务说明和恢复动作。 | docs/design-system/2026-11-05-global-audit.md:347 |
| CX-10 | P2 | FxFeedback读屏标签拼入英文tone.name，4秒toast承载字段错误且新提示替掉旧提示；字段错误改持久就地，状态播报使用本地化文本。 | docs/design-system/2026-11-05-global-audit.md:348 |
| CX-11 | P2 | FxConfirmSheet等待期间只禁内部按钮，外层默认可dismiss；failureMessage缺失时失败没有可见解释。调用侧明确忙碌期退出和失败文案。 | docs/design-system/2026-11-05-global-audit.md:349 |
| CX-12 | P2 | 图表网格线仍复用border、甜甜圈金额12、中心标题11；图和表的视图切换不应让数据可读性退化。 | docs/design-system/2026-11-05-global-audit.md:350 |

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

本小节没有额外分配条目；仍须完成上文具体任务和验收。

## 决定性验证

```sh
flutter test --no-pub test/fx
```

1. 运行完整flutter test与全量analyze差异；核对受控文本/颜色/圆角例外清单，不因旧1159诊断加ignore。
2. 跨流程至少：配置→登录→切账本→记账→账单详情→单据动作→统计日历→归物→周期→导出；使用本地fixture/测试环境授权边界。
3. 334 ID主责/实例/证据映射守恒，无阶段缺报，无使用旧SHA截图冒充新图；完整精确金额、隐藏与取消语义跨域一致。

## 视觉证据与验收

- 同屏并列比较所有重构页面的亮暗字体/边距/边框，检查新截图不是换颜色的旧布局；至少核心任务链320/390/440与2倍字。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S1-C.md`、`runtime/issue-checks/S1-C.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：S2-B，回到已有S2会话，文件docs/design-system/execution-prompts/prompts/26-S2-B.md。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 26 · 回到已有S2会话

# S2-B｜回到独立审查会话，全工程审计验收

**使用位置：回到已有S2会话。本轮只执行S2-B。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S2-B。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S2-B以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S2-B/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S2-B.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S2-B.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S2-B及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S1-C。
必须读对应handoff与runtime。

## 本阶段允许写入范围

本阶段业务源码、测试源码、pubspec/平台配置、原审计报告均只读；只可写本包当前阶段报告、evidence、当前阶段runtime记录。必要的独立验证探针仅放本阶段evidence，不改已有测试来制造通过。

## 必须完成的具体工作

1. 只读业务代码、测试和已有报告，读取所有阶段当前SHA、diff、问题实例、测试日志和截图；不接受实现者自评。对照原334个ID逐项判断闭合，不仅看总测试绿。
2. 审查审美与任务两轮：先信息主次/排版/间距/表面/组件状态，再金额精确/隐私/范围/取消/输入保全/角色/周期/文件实际交付；已有能力不得因改版丢失。
3. 独立运行关键行为测试与全量回归，打开实际Flutter生成的全部新页面状态证据；真机/读屏/外部API没做就写NOT_RUN，不把组件预览当业务全验收。
4. 逐项核对原源码推断，已证伪必须附当前可复现反证；外部契约/平台缺口保留BLOCKED_EXTERNAL，不能用降级或未覆盖测试写“解决”。
5. 生成review.json与repair-routing.json：每个缺陷含ownerSession、repairPrompt、范围、复现、最小修复、验证要求和依赖。共享契约缺陷先派S1-D，其余只回本包对应owner修复提示；多个会话修复严格串行。
6. 无缺陷则下一步S2-C；有缺陷给精确有序提示词路径，然后回本S2执行S2-C。审查本轮停止，禁止自己修代码。

## 本阶段主责问题

本小节没有额外分配条目；仍须完成上文具体任务和验收。

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

本小节没有额外分配条目；仍须完成上文具体任务和验收。

## 决定性验证

按下列验收要求执行必要的定向/全量检查，不能凭历史计数判定。

1. 独立运行全量flutter test和分析差异，必要fixture探针仅写evidence；实际检查禁用/隐藏/未知/负金额/失败路径，不用源代码字样检测代替行为。
2. 校验问题数量334和所有primary/contributor实例，业务页列表与截图清单对应，隐含跳过/未跑不能按通过。

## 视觉证据与验收

- 打开所有新截图与关键原图对照，重核金额不会被省略、长表单可操作、暗色前景、原生返回和键盘；截图无法证明的动作必须用行为或设备证据。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S2-B.md`、`runtime/issue-checks/S2-B.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：没有缺陷：留在S2执行S2-C。有缺陷：依reviews/最新轮次/repair-routing.json顺序，仅执行列出的owner修复提示，再回S2执行S2-C。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 27 · 回到已有S2会话

# S2-C｜回到独立审查会话，逐项复审与最终结论

**使用位置：回到已有S2会话。本轮只执行S2-C。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S2-C。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S2-C以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S2-C/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S2-C.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S2-C.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S2-C及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S2-B。
必须读对应handoff与runtime。

## 本阶段允许写入范围

本阶段业务源码、测试源码、pubspec/平台配置、原审计报告均只读；只可写本包当前阶段报告、evidence、当前阶段runtime记录。必要的独立验证探针仅放本阶段evidence，不改已有测试来制造通过。

## 必须完成的具体工作

1. 读取最近S2-B审查及repair-routing，逐条核对原问题、owner修复、当前diff/文件SHA；“已修复”文字和实现者截图文件名都不能替代证据。
2. 独立重新执行每条修复的决定性测试并打开对应重渲染图片；若修复后又发生共享/调用方变动，扩大到实际影响范围，不能仅复跑最小片段。
3. 若S2-B没有修复项，只核本轮代码/截图SHA仍一致和无新改动，可引用同一代码快照下S2-B实跑证据，注明未重复执行；不编造新的测试次数。
4. 最后输出分层结论：本地功能/视觉、平台构建/设备、后端/真实数据、上线条件。只有所有要求都有证据时才声称全闭环；外部阻断保持PARTIAL。
5. 若发现未关闭问题，只追加新的审查轮次与有序返修路由，回对应既有修复会话，再回本S2重跑S2-C；不得修改早期审查结论来消除问题。通过或只有明确外部验收缺口则交S0-B汇总。

## 本阶段主责问题

本小节没有额外分配条目；仍须完成上文具体任务和验收。

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

本小节没有额外分配条目；仍须完成上文具体任务和验收。

## 决定性验证

按下列验收要求执行必要的定向/全量检查，不能凭历史计数判定。

1. 每个原问题复现测试从失败转通过且验证正确路径；新旧snapshot一致性；最终必要时全量测试/分析/平台编译。
2. 校验P1无本地未闭合项；P2/P3不能只因级别低直接忽略，延期须保留真实状态与用户决策，审查员无权替用户接受风险。

## 视觉证据与验收

- 逐条返修前后截图查看，关键操作复现；本地渲染、模拟器、真机、读屏证据分列。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S2-C.md`、`runtime/issue-checks/S2-C.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：本地审查通过或明确外部缺口分层后：回S0执行S0-B。本地仍失败：按新返修路由修复，再回S2重执行S2-C。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---

主线 28 · 回到已有S0会话

# S0-B｜回到统筹会话，交付清单与后续验收

**使用位置：回到已有S0会话。本轮只执行S0-B。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S0-B。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S0-B以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S0-B/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S0-B.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S0-B.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S0-B及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 本阶段前置

前置编号：S2-C。
必须读对应handoff与runtime。

## 本阶段允许写入范围

本阶段业务源码、测试源码、pubspec/平台配置、原审计报告均只读；只可写本包当前阶段报告、evidence、当前阶段runtime记录。必要的独立验证探针仅放本阶段evidence，不改已有测试来制造通过。

## 必须完成的具体工作

1. 只读最终业务代码及审查产物，不替实现会话修代码。核对S2-C结论、334项状态、所有返修轮次和当前SHA，发现审查后新改动就退回S2-C复核。
2. 输出FINAL-DELIVERY.md、最终页面迁移矩阵、组件合同版本、关闭/证伪/外部阻断明细、测试与图片目录、未提交文件归属；标注本地/平台/真实联调证据边界。
3. 若有外部缺口，将每条化为可执行的验证前置、操作、预期、负责人范围，不凭UI完成就写可发布。用户未来决定接入依赖/改后端/真机测试时另开授权任务。
4. 交付从本包主线和条件修复中已执行的精确顺序；所有状态与实际证据一致，未运行阶段不补写通过。
5. 保留代码未提交、不推送、不发布。到此停止，不自行开始新一轮优化或清理未提交文件。

## 本阶段主责问题

本小节没有额外分配条目；仍须完成上文具体任务和验收。

## 必须同步落地的跨页面共性实例

以下ID只处理本阶段scope内的出现点；全局责任方会在S1-C核对所有实例，不允许因为“归共享会话负责”而不接组件。

本小节没有额外分配条目；仍须完成上文具体任务和验收。

## 决定性验证

按下列验收要求执行必要的定向/全量检查，不能凭历史计数判定。

1. 运行本包结构校验，检查必需handoff/review/证据是否存在、SHA是否匹配、状态与计数一致。
2. 本轮若未改代码且S2-C快照仍有效，不重复假装执行测试；引用明确的S2-C运行记录。

## 视觉证据与验收

- 核对最终页面索引的视觉验收状态，未复拍/未看图/未真机均明示。

新增render/golden必须绑定真实业务Widget。既有`tool/design_system_preview_test.dart`只可验证底座，不能覆盖业务页面。截图索引至少含页面、状态、主题、logicalSize、textScale、sourceSha256、路径、是否已实际查看、观察结论。缺图片查看能力不能代码自评精美。

## 交接与本轮停止

把结果写到`docs/design-system/execution-prompts/handoff/S0-B.md`、`runtime/issue-checks/S0-B.json`和本轮evidence目录。先验证路径/ID/计数/SHA，再原子更新runtime。

下一步：无下一实施阶段，交付后停止。未完成外部验收另列，不自动接着做。

最终只汇报本阶段：完成/未完成、测试真实计数、视觉与设备边界、修改范围、下一提示词。不要执行下一阶段。


---
# 条件返修与共享补缺


---

# S1-B｜共享底座初审返修

**回到已有S1会话。本轮只执行S1-B。不要新建实现会话丢失上下文；原会话不可用时可新开替代会话，但必须先读其全部相关handoff和当前源码，不能从旧快照重做。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S1-B。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S1-B以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S1-B/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S1-B.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S1-B.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S1-B及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 触发与范围

仅在以下条件执行：S2-A指出共享底座或兼容合同真实缺陷。

允许写入当前会话原始业务范围及必要测试/中英文文案：
- `lib/core/errors/`
- `lib/core/feedback/`
- `lib/core/money/`
- `lib/core/preferences/finance_color_preferences.dart`
- `lib/fx/`

## 修复流程

1. 从最近有效审查的repair-routing.json只领取ownerSession与当前会话一致的缺陷。审查阶段、缺陷ID、触发路径、要求测试和source SHA必须明确；不存在分配则记录NOT_REQUIRED，不顺便找新功能做。
2. 核对当前HEAD/diff/未提交来源；先前页面可能已消费新版组件，禁止整文件覆盖回早期实现。
3. 每条先独立复现原审查问题，证伪就给具体证据，不无条件照改。需要代码修复的先有能抓住原失败的行为或可测视觉证据。
4. 只做最小、完整的修复，同步必要调用者和测试；不得改审查报告、删断言、夹字号、略过错误分支或标记缺陷为测试无关。
5. 对每条记录审查ID→根因→before/after SHA→真实验证命令/数量→改后图片路径。影响共享合同要检查全部直接调用；不能只修触发截图的一个页面。
6. 同一修复涉及不同owner时，先共享后调用方，按照返修路由串行；当前scope外的业务改动给其owner，不在本会话替做。
7. 运行所有决定性定向验证，再按影响运行全量回归/分析；若只是同快照证伪，明确未改代码与反证。保留不可运行/外部缺口原状态。
8. 新证据放evidence/S1-B/attempt-N，写handoff/S1-B.md、runtime/issue-checks/S1-B.json；修复者只写VERIFIED_LOCAL，不替独立审查员宣布闭合。

## 验收与返回

- 原触发条件下正确，邻接路径无回归；相关亮暗/大字/键盘/隐私/权限仍满足原合同。
- 每个修复必须关联明确审查缺陷，不存在“顺便调整”的无归属改动。
- 复用同一修复提示进行后续轮次时递增attempt，保留历史失败。

完成后：回到已有S2会话，重新执行prompts/03-S2-A.md；通过后才进入S3-A。
只报告当前修复和准确下一步，不自动执行下一轮。


---

# S1-D｜终审返修：S1负责范围

**回到已有S1会话。本轮只执行S1-D。不要新建实现会话丢失上下文；原会话不可用时可新开替代会话，但必须先读其全部相关handoff和当前源码，不能从旧快照重做。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S1-D。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S1-D以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S1-D/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S1-D.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S1-D.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S1-D及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 触发与范围

仅在以下条件执行：S2-B或S2-C最新repair-routing把缺陷分配到S1。

允许写入当前会话原始业务范围及必要测试/中英文文案：
- `lib/core/errors/`
- `lib/core/feedback/`
- `lib/core/money/`
- `lib/core/preferences/finance_color_preferences.dart`
- `lib/fx/`
- `各阶段已经登记的共享组件直接调用点`

## 修复流程

1. 从最近有效审查的repair-routing.json只领取ownerSession与当前会话一致的缺陷。审查阶段、缺陷ID、触发路径、要求测试和source SHA必须明确；不存在分配则记录NOT_REQUIRED，不顺便找新功能做。
2. 核对当前HEAD/diff/未提交来源；先前页面可能已消费新版组件，禁止整文件覆盖回早期实现。
3. 每条先独立复现原审查问题，证伪就给具体证据，不无条件照改。需要代码修复的先有能抓住原失败的行为或可测视觉证据。
4. 只做最小、完整的修复，同步必要调用者和测试；不得改审查报告、删断言、夹字号、略过错误分支或标记缺陷为测试无关。
5. 对每条记录审查ID→根因→before/after SHA→真实验证命令/数量→改后图片路径。影响共享合同要检查全部直接调用；不能只修触发截图的一个页面。
6. 同一修复涉及不同owner时，先共享后调用方，按照返修路由串行；当前scope外的业务改动给其owner，不在本会话替做。
7. 运行所有决定性定向验证，再按影响运行全量回归/分析；若只是同快照证伪，明确未改代码与反证。保留不可运行/外部缺口原状态。
8. 新证据放evidence/S1-D/attempt-N，写handoff/S1-D.md、runtime/issue-checks/S1-D.json；修复者只写VERIFIED_LOCAL，不替独立审查员宣布闭合。

## 验收与返回

- 原触发条件下正确，邻接路径无回归；相关亮暗/大字/键盘/隐私/权限仍满足原合同。
- 每个修复必须关联明确审查缺陷，不存在“顺便调整”的无归属改动。
- 复用同一修复提示进行后续轮次时递增attempt，保留历史失败。

完成后：按repair-routing继续下一需要的修复；全部所需修复完成后回已有S2执行S2-C。
只报告当前修复和准确下一步，不自动执行下一轮。


---

# S3-B｜终审返修：S3负责范围

**回到已有S3会话。本轮只执行S3-B。不要新建实现会话丢失上下文；原会话不可用时可新开替代会话，但必须先读其全部相关handoff和当前源码，不能从旧快照重做。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S3-B。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S3-B以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S3-B/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S3-B.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S3-B.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S3-B及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 触发与范围

仅在以下条件执行：S2-B或S2-C最新repair-routing把缺陷分配到S3。

允许写入当前会话原始业务范围及必要测试/中英文文案：
- `lib/core/app/fx_app.dart`
- `lib/core/navigation/`
- `lib/core/session/`
- `lib/core/shell/`
- `lib/features/*/*registration.dart`

## 修复流程

1. 从最近有效审查的repair-routing.json只领取ownerSession与当前会话一致的缺陷。审查阶段、缺陷ID、触发路径、要求测试和source SHA必须明确；不存在分配则记录NOT_REQUIRED，不顺便找新功能做。
2. 核对当前HEAD/diff/未提交来源；先前页面可能已消费新版组件，禁止整文件覆盖回早期实现。
3. 每条先独立复现原审查问题，证伪就给具体证据，不无条件照改。需要代码修复的先有能抓住原失败的行为或可测视觉证据。
4. 只做最小、完整的修复，同步必要调用者和测试；不得改审查报告、删断言、夹字号、略过错误分支或标记缺陷为测试无关。
5. 对每条记录审查ID→根因→before/after SHA→真实验证命令/数量→改后图片路径。影响共享合同要检查全部直接调用；不能只修触发截图的一个页面。
6. 同一修复涉及不同owner时，先共享后调用方，按照返修路由串行；当前scope外的业务改动给其owner，不在本会话替做。
7. 运行所有决定性定向验证，再按影响运行全量回归/分析；若只是同快照证伪，明确未改代码与反证。保留不可运行/外部缺口原状态。
8. 新证据放evidence/S3-B/attempt-N，写handoff/S3-B.md、runtime/issue-checks/S3-B.json；修复者只写VERIFIED_LOCAL，不替独立审查员宣布闭合。

## 验收与返回

- 原触发条件下正确，邻接路径无回归；相关亮暗/大字/键盘/隐私/权限仍满足原合同。
- 每个修复必须关联明确审查缺陷，不存在“顺便调整”的无归属改动。
- 复用同一修复提示进行后续轮次时递增attempt，保留历史失败。

完成后：按repair-routing继续下一需要的修复；全部所需修复完成后回已有S2执行S2-C。
只报告当前修复和准确下一步，不自动执行下一轮。


---

# S4-C｜终审返修：S4负责范围

**回到已有S4会话。本轮只执行S4-C。不要新建实现会话丢失上下文；原会话不可用时可新开替代会话，但必须先读其全部相关handoff和当前源码，不能从旧快照重做。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S4-C。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S4-C以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S4-C/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S4-C.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S4-C.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S4-C及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 触发与范围

仅在以下条件执行：S2-B或S2-C最新repair-routing把缺陷分配到S4。

允许写入当前会话原始业务范围及必要测试/中英文文案：
- `lib/features/bills/`
- `lib/features/bills/presentation/widgets/bill_tile.dart`
- `lib/features/shared/data/bill_attachment*`
- `lib/features/shared/presentation/bills/`

## 修复流程

1. 从最近有效审查的repair-routing.json只领取ownerSession与当前会话一致的缺陷。审查阶段、缺陷ID、触发路径、要求测试和source SHA必须明确；不存在分配则记录NOT_REQUIRED，不顺便找新功能做。
2. 核对当前HEAD/diff/未提交来源；先前页面可能已消费新版组件，禁止整文件覆盖回早期实现。
3. 每条先独立复现原审查问题，证伪就给具体证据，不无条件照改。需要代码修复的先有能抓住原失败的行为或可测视觉证据。
4. 只做最小、完整的修复，同步必要调用者和测试；不得改审查报告、删断言、夹字号、略过错误分支或标记缺陷为测试无关。
5. 对每条记录审查ID→根因→before/after SHA→真实验证命令/数量→改后图片路径。影响共享合同要检查全部直接调用；不能只修触发截图的一个页面。
6. 同一修复涉及不同owner时，先共享后调用方，按照返修路由串行；当前scope外的业务改动给其owner，不在本会话替做。
7. 运行所有决定性定向验证，再按影响运行全量回归/分析；若只是同快照证伪，明确未改代码与反证。保留不可运行/外部缺口原状态。
8. 新证据放evidence/S4-C/attempt-N，写handoff/S4-C.md、runtime/issue-checks/S4-C.json；修复者只写VERIFIED_LOCAL，不替独立审查员宣布闭合。

## 验收与返回

- 原触发条件下正确，邻接路径无回归；相关亮暗/大字/键盘/隐私/权限仍满足原合同。
- 每个修复必须关联明确审查缺陷，不存在“顺便调整”的无归属改动。
- 复用同一修复提示进行后续轮次时递增attempt，保留历史失败。

完成后：按repair-routing继续下一需要的修复；全部所需修复完成后回已有S2执行S2-C。
只报告当前修复和准确下一步，不自动执行下一轮。


---

# S5-B｜终审返修：S5负责范围

**回到已有S5会话。本轮只执行S5-B。不要新建实现会话丢失上下文；原会话不可用时可新开替代会话，但必须先读其全部相关handoff和当前源码，不能从旧快照重做。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S5-B。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S5-B以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S5-B/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S5-B.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S5-B.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S5-B及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 触发与范围

仅在以下条件执行：S2-B或S2-C最新repair-routing把缺陷分配到S5。

允许写入当前会话原始业务范围及必要测试/中英文文案：
- `lib/features/bill_editor/`
- `lib/features/shared/data/bill_attachment*`

## 修复流程

1. 从最近有效审查的repair-routing.json只领取ownerSession与当前会话一致的缺陷。审查阶段、缺陷ID、触发路径、要求测试和source SHA必须明确；不存在分配则记录NOT_REQUIRED，不顺便找新功能做。
2. 核对当前HEAD/diff/未提交来源；先前页面可能已消费新版组件，禁止整文件覆盖回早期实现。
3. 每条先独立复现原审查问题，证伪就给具体证据，不无条件照改。需要代码修复的先有能抓住原失败的行为或可测视觉证据。
4. 只做最小、完整的修复，同步必要调用者和测试；不得改审查报告、删断言、夹字号、略过错误分支或标记缺陷为测试无关。
5. 对每条记录审查ID→根因→before/after SHA→真实验证命令/数量→改后图片路径。影响共享合同要检查全部直接调用；不能只修触发截图的一个页面。
6. 同一修复涉及不同owner时，先共享后调用方，按照返修路由串行；当前scope外的业务改动给其owner，不在本会话替做。
7. 运行所有决定性定向验证，再按影响运行全量回归/分析；若只是同快照证伪，明确未改代码与反证。保留不可运行/外部缺口原状态。
8. 新证据放evidence/S5-B/attempt-N，写handoff/S5-B.md、runtime/issue-checks/S5-B.json；修复者只写VERIFIED_LOCAL，不替独立审查员宣布闭合。

## 验收与返回

- 原触发条件下正确，邻接路径无回归；相关亮暗/大字/键盘/隐私/权限仍满足原合同。
- 每个修复必须关联明确审查缺陷，不存在“顺便调整”的无归属改动。
- 复用同一修复提示进行后续轮次时递增attempt，保留历史失败。

完成后：按repair-routing继续下一需要的修复；全部所需修复完成后回已有S2执行S2-C。
只报告当前修复和准确下一步，不自动执行下一轮。


---

# S6-D｜终审返修：S6负责范围

**回到已有S6会话。本轮只执行S6-D。不要新建实现会话丢失上下文；原会话不可用时可新开替代会话，但必须先读其全部相关handoff和当前源码，不能从旧快照重做。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S6-D。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S6-D以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S6-D/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S6-D.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S6-D.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S6-D及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 触发与范围

仅在以下条件执行：S2-B或S2-C最新repair-routing把缺陷分配到S6。

允许写入当前会话原始业务范围及必要测试/中英文文案：
- `lib/features/orders/data/`
- `lib/features/orders/presentation/bloc/`
- `lib/features/orders/presentation/order_detail_page.dart`
- `lib/features/orders/presentation/order_reconciliation_page.dart`
- `lib/features/orders/presentation/orders_page.dart`
- `lib/features/orders/presentation/widgets/order_audit_sheet.dart`
- `lib/features/orders/presentation/widgets/order_card.dart`
- `lib/features/orders/presentation/widgets/order_entry_tile.dart`
- `lib/features/orders/presentation/widgets/order_filter_sheet.dart`
- `lib/features/orders/presentation/widgets/order_form_sheet.dart`
- `lib/features/orders/presentation/widgets/order_summary_strip.dart`

## 修复流程

1. 从最近有效审查的repair-routing.json只领取ownerSession与当前会话一致的缺陷。审查阶段、缺陷ID、触发路径、要求测试和source SHA必须明确；不存在分配则记录NOT_REQUIRED，不顺便找新功能做。
2. 核对当前HEAD/diff/未提交来源；先前页面可能已消费新版组件，禁止整文件覆盖回早期实现。
3. 每条先独立复现原审查问题，证伪就给具体证据，不无条件照改。需要代码修复的先有能抓住原失败的行为或可测视觉证据。
4. 只做最小、完整的修复，同步必要调用者和测试；不得改审查报告、删断言、夹字号、略过错误分支或标记缺陷为测试无关。
5. 对每条记录审查ID→根因→before/after SHA→真实验证命令/数量→改后图片路径。影响共享合同要检查全部直接调用；不能只修触发截图的一个页面。
6. 同一修复涉及不同owner时，先共享后调用方，按照返修路由串行；当前scope外的业务改动给其owner，不在本会话替做。
7. 运行所有决定性定向验证，再按影响运行全量回归/分析；若只是同快照证伪，明确未改代码与反证。保留不可运行/外部缺口原状态。
8. 新证据放evidence/S6-D/attempt-N，写handoff/S6-D.md、runtime/issue-checks/S6-D.json；修复者只写VERIFIED_LOCAL，不替独立审查员宣布闭合。

## 验收与返回

- 原触发条件下正确，邻接路径无回归；相关亮暗/大字/键盘/隐私/权限仍满足原合同。
- 每个修复必须关联明确审查缺陷，不存在“顺便调整”的无归属改动。
- 复用同一修复提示进行后续轮次时递增attempt，保留历史失败。

完成后：按repair-routing继续下一需要的修复；全部所需修复完成后回已有S2执行S2-C。
只报告当前修复和准确下一步，不自动执行下一轮。


---

# S7-B｜终审返修：S7负责范围

**回到已有S7会话。本轮只执行S7-B。不要新建实现会话丢失上下文；原会话不可用时可新开替代会话，但必须先读其全部相关handoff和当前源码，不能从旧快照重做。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S7-B。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S7-B以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S7-B/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S7-B.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S7-B.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S7-B及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 触发与范围

仅在以下条件执行：S2-B或S2-C最新repair-routing把缺陷分配到S7。

允许写入当前会话原始业务范围及必要测试/中英文文案：
- `lib/features/dashboard/`

## 修复流程

1. 从最近有效审查的repair-routing.json只领取ownerSession与当前会话一致的缺陷。审查阶段、缺陷ID、触发路径、要求测试和source SHA必须明确；不存在分配则记录NOT_REQUIRED，不顺便找新功能做。
2. 核对当前HEAD/diff/未提交来源；先前页面可能已消费新版组件，禁止整文件覆盖回早期实现。
3. 每条先独立复现原审查问题，证伪就给具体证据，不无条件照改。需要代码修复的先有能抓住原失败的行为或可测视觉证据。
4. 只做最小、完整的修复，同步必要调用者和测试；不得改审查报告、删断言、夹字号、略过错误分支或标记缺陷为测试无关。
5. 对每条记录审查ID→根因→before/after SHA→真实验证命令/数量→改后图片路径。影响共享合同要检查全部直接调用；不能只修触发截图的一个页面。
6. 同一修复涉及不同owner时，先共享后调用方，按照返修路由串行；当前scope外的业务改动给其owner，不在本会话替做。
7. 运行所有决定性定向验证，再按影响运行全量回归/分析；若只是同快照证伪，明确未改代码与反证。保留不可运行/外部缺口原状态。
8. 新证据放evidence/S7-B/attempt-N，写handoff/S7-B.md、runtime/issue-checks/S7-B.json；修复者只写VERIFIED_LOCAL，不替独立审查员宣布闭合。

## 验收与返回

- 原触发条件下正确，邻接路径无回归；相关亮暗/大字/键盘/隐私/权限仍满足原合同。
- 每个修复必须关联明确审查缺陷，不存在“顺便调整”的无归属改动。
- 复用同一修复提示进行后续轮次时递增attempt，保留历史失败。

完成后：按repair-routing继续下一需要的修复；全部所需修复完成后回已有S2执行S2-C。
只报告当前修复和准确下一步，不自动执行下一轮。


---

# S8-D｜终审返修：S8负责范围

**回到已有S8会话。本轮只执行S8-D。不要新建实现会话丢失上下文；原会话不可用时可新开替代会话，但必须先读其全部相关handoff和当前源码，不能从旧快照重做。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S8-D。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S8-D以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S8-D/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S8-D.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S8-D.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S8-D及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 触发与范围

仅在以下条件执行：S2-B或S2-C最新repair-routing把缺陷分配到S8。

允许写入当前会话原始业务范围及必要测试/中英文文案：
- `lib/features/stats/data/`
- `lib/features/stats/data/chinese_calendar_day.dart`
- `lib/features/stats/presentation/bloc/`
- `lib/features/stats/presentation/stats_assets_page.dart`
- `lib/features/stats/presentation/stats_loans_page.dart`
- `lib/features/stats/presentation/stats_page.dart`
- `lib/features/stats/presentation/stats_policy_page.dart`
- `lib/features/stats/presentation/widgets/calendar_day_summary_sheet.dart`
- `lib/features/stats/presentation/widgets/stats_*`
- `lib/features/stats/presentation/widgets/stats_formatters.dart`
- `lib/features/stats/presentation/widgets/stats_income_expense_calendar_card.dart`
- `lib/features/stats/presentation/widgets/stats_privacy.dart`
- `lib/fx/components/fx_*chart.dart`

## 修复流程

1. 从最近有效审查的repair-routing.json只领取ownerSession与当前会话一致的缺陷。审查阶段、缺陷ID、触发路径、要求测试和source SHA必须明确；不存在分配则记录NOT_REQUIRED，不顺便找新功能做。
2. 核对当前HEAD/diff/未提交来源；先前页面可能已消费新版组件，禁止整文件覆盖回早期实现。
3. 每条先独立复现原审查问题，证伪就给具体证据，不无条件照改。需要代码修复的先有能抓住原失败的行为或可测视觉证据。
4. 只做最小、完整的修复，同步必要调用者和测试；不得改审查报告、删断言、夹字号、略过错误分支或标记缺陷为测试无关。
5. 对每条记录审查ID→根因→before/after SHA→真实验证命令/数量→改后图片路径。影响共享合同要检查全部直接调用；不能只修触发截图的一个页面。
6. 同一修复涉及不同owner时，先共享后调用方，按照返修路由串行；当前scope外的业务改动给其owner，不在本会话替做。
7. 运行所有决定性定向验证，再按影响运行全量回归/分析；若只是同快照证伪，明确未改代码与反证。保留不可运行/外部缺口原状态。
8. 新证据放evidence/S8-D/attempt-N，写handoff/S8-D.md、runtime/issue-checks/S8-D.json；修复者只写VERIFIED_LOCAL，不替独立审查员宣布闭合。

## 验收与返回

- 原触发条件下正确，邻接路径无回归；相关亮暗/大字/键盘/隐私/权限仍满足原合同。
- 每个修复必须关联明确审查缺陷，不存在“顺便调整”的无归属改动。
- 复用同一修复提示进行后续轮次时递增attempt，保留历史失败。

完成后：按repair-routing继续下一需要的修复；全部所需修复完成后回已有S2执行S2-C。
只报告当前修复和准确下一步，不自动执行下一轮。


---

# S9-B｜终审返修：S9负责范围

**回到已有S9会话。本轮只执行S9-B。不要新建实现会话丢失上下文；原会话不可用时可新开替代会话，但必须先读其全部相关handoff和当前源码，不能从旧快照重做。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S9-B。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S9-B以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S9-B/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S9-B.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S9-B.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S9-B及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 触发与范围

仅在以下条件执行：S2-B或S2-C最新repair-routing把缺陷分配到S9。

允许写入当前会话原始业务范围及必要测试/中英文文案：
- `lib/features/books/`
- `lib/features/group_users/`
- `lib/features/shared/invite_member_sheet.dart`

## 修复流程

1. 从最近有效审查的repair-routing.json只领取ownerSession与当前会话一致的缺陷。审查阶段、缺陷ID、触发路径、要求测试和source SHA必须明确；不存在分配则记录NOT_REQUIRED，不顺便找新功能做。
2. 核对当前HEAD/diff/未提交来源；先前页面可能已消费新版组件，禁止整文件覆盖回早期实现。
3. 每条先独立复现原审查问题，证伪就给具体证据，不无条件照改。需要代码修复的先有能抓住原失败的行为或可测视觉证据。
4. 只做最小、完整的修复，同步必要调用者和测试；不得改审查报告、删断言、夹字号、略过错误分支或标记缺陷为测试无关。
5. 对每条记录审查ID→根因→before/after SHA→真实验证命令/数量→改后图片路径。影响共享合同要检查全部直接调用；不能只修触发截图的一个页面。
6. 同一修复涉及不同owner时，先共享后调用方，按照返修路由串行；当前scope外的业务改动给其owner，不在本会话替做。
7. 运行所有决定性定向验证，再按影响运行全量回归/分析；若只是同快照证伪，明确未改代码与反证。保留不可运行/外部缺口原状态。
8. 新证据放evidence/S9-B/attempt-N，写handoff/S9-B.md、runtime/issue-checks/S9-B.json；修复者只写VERIFIED_LOCAL，不替独立审查员宣布闭合。

## 验收与返回

- 原触发条件下正确，邻接路径无回归；相关亮暗/大字/键盘/隐私/权限仍满足原合同。
- 每个修复必须关联明确审查缺陷，不存在“顺便调整”的无归属改动。
- 复用同一修复提示进行后续轮次时递增attempt，保留历史失败。

完成后：按repair-routing继续下一需要的修复；全部所需修复完成后回已有S2执行S2-C。
只报告当前修复和准确下一步，不自动执行下一轮。


---

# S10-B｜终审返修：S10负责范围

**回到已有S10会话。本轮只执行S10-B。不要新建实现会话丢失上下文；原会话不可用时可新开替代会话，但必须先读其全部相关handoff和当前源码，不能从旧快照重做。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S10-B。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S10-B以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S10-B/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S10-B.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S10-B.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S10-B及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 触发与范围

仅在以下条件执行：S2-B或S2-C最新repair-routing把缺陷分配到S10。

允许写入当前会话原始业务范围及必要测试/中英文文案：
- `lib/features/categories/`
- `lib/features/manage_shared/`
- `lib/features/members/`
- `lib/features/payees/`
- `lib/features/tags/`

## 修复流程

1. 从最近有效审查的repair-routing.json只领取ownerSession与当前会话一致的缺陷。审查阶段、缺陷ID、触发路径、要求测试和source SHA必须明确；不存在分配则记录NOT_REQUIRED，不顺便找新功能做。
2. 核对当前HEAD/diff/未提交来源；先前页面可能已消费新版组件，禁止整文件覆盖回早期实现。
3. 每条先独立复现原审查问题，证伪就给具体证据，不无条件照改。需要代码修复的先有能抓住原失败的行为或可测视觉证据。
4. 只做最小、完整的修复，同步必要调用者和测试；不得改审查报告、删断言、夹字号、略过错误分支或标记缺陷为测试无关。
5. 对每条记录审查ID→根因→before/after SHA→真实验证命令/数量→改后图片路径。影响共享合同要检查全部直接调用；不能只修触发截图的一个页面。
6. 同一修复涉及不同owner时，先共享后调用方，按照返修路由串行；当前scope外的业务改动给其owner，不在本会话替做。
7. 运行所有决定性定向验证，再按影响运行全量回归/分析；若只是同快照证伪，明确未改代码与反证。保留不可运行/外部缺口原状态。
8. 新证据放evidence/S10-B/attempt-N，写handoff/S10-B.md、runtime/issue-checks/S10-B.json；修复者只写VERIFIED_LOCAL，不替独立审查员宣布闭合。

## 验收与返回

- 原触发条件下正确，邻接路径无回归；相关亮暗/大字/键盘/隐私/权限仍满足原合同。
- 每个修复必须关联明确审查缺陷，不存在“顺便调整”的无归属改动。
- 复用同一修复提示进行后续轮次时递增attempt，保留历史失败。

完成后：按repair-routing继续下一需要的修复；全部所需修复完成后回已有S2执行S2-C。
只报告当前修复和准确下一步，不自动执行下一轮。


---

# S11-C｜终审返修：S11负责范围

**回到已有S11会话。本轮只执行S11-C。不要新建实现会话丢失上下文；原会话不可用时可新开替代会话，但必须先读其全部相关handoff和当前源码，不能从旧快照重做。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S11-C。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S11-C以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S11-C/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S11-C.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S11-C.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S11-C及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 触发与范围

仅在以下条件执行：S2-B或S2-C最新repair-routing把缺陷分配到S11。

允许写入当前会话原始业务范围及必要测试/中英文文案：
- `lib/features/accounts/`
- `lib/features/goods/`

## 修复流程

1. 从最近有效审查的repair-routing.json只领取ownerSession与当前会话一致的缺陷。审查阶段、缺陷ID、触发路径、要求测试和source SHA必须明确；不存在分配则记录NOT_REQUIRED，不顺便找新功能做。
2. 核对当前HEAD/diff/未提交来源；先前页面可能已消费新版组件，禁止整文件覆盖回早期实现。
3. 每条先独立复现原审查问题，证伪就给具体证据，不无条件照改。需要代码修复的先有能抓住原失败的行为或可测视觉证据。
4. 只做最小、完整的修复，同步必要调用者和测试；不得改审查报告、删断言、夹字号、略过错误分支或标记缺陷为测试无关。
5. 对每条记录审查ID→根因→before/after SHA→真实验证命令/数量→改后图片路径。影响共享合同要检查全部直接调用；不能只修触发截图的一个页面。
6. 同一修复涉及不同owner时，先共享后调用方，按照返修路由串行；当前scope外的业务改动给其owner，不在本会话替做。
7. 运行所有决定性定向验证，再按影响运行全量回归/分析；若只是同快照证伪，明确未改代码与反证。保留不可运行/外部缺口原状态。
8. 新证据放evidence/S11-C/attempt-N，写handoff/S11-C.md、runtime/issue-checks/S11-C.json；修复者只写VERIFIED_LOCAL，不替独立审查员宣布闭合。

## 验收与返回

- 原触发条件下正确，邻接路径无回归；相关亮暗/大字/键盘/隐私/权限仍满足原合同。
- 每个修复必须关联明确审查缺陷，不存在“顺便调整”的无归属改动。
- 复用同一修复提示进行后续轮次时递增attempt，保留历史失败。

完成后：按repair-routing继续下一需要的修复；全部所需修复完成后回已有S2执行S2-C。
只报告当前修复和准确下一步，不自动执行下一轮。


---

# S12-B｜终审返修：S12负责范围

**回到已有S12会话。本轮只执行S12-B。不要新建实现会话丢失上下文；原会话不可用时可新开替代会话，但必须先读其全部相关handoff和当前源码，不能从旧快照重做。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S12-B。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S12-B以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S12-B/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S12-B.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S12-B.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S12-B及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 触发与范围

仅在以下条件执行：S2-B或S2-C最新repair-routing把缺陷分配到S12。

允许写入当前会话原始业务范围及必要测试/中英文文案：
- `lib/core/auth/`
- `lib/core/navigation/startup_route_guard.dart`
- `lib/login/`

## 修复流程

1. 从最近有效审查的repair-routing.json只领取ownerSession与当前会话一致的缺陷。审查阶段、缺陷ID、触发路径、要求测试和source SHA必须明确；不存在分配则记录NOT_REQUIRED，不顺便找新功能做。
2. 核对当前HEAD/diff/未提交来源；先前页面可能已消费新版组件，禁止整文件覆盖回早期实现。
3. 每条先独立复现原审查问题，证伪就给具体证据，不无条件照改。需要代码修复的先有能抓住原失败的行为或可测视觉证据。
4. 只做最小、完整的修复，同步必要调用者和测试；不得改审查报告、删断言、夹字号、略过错误分支或标记缺陷为测试无关。
5. 对每条记录审查ID→根因→before/after SHA→真实验证命令/数量→改后图片路径。影响共享合同要检查全部直接调用；不能只修触发截图的一个页面。
6. 同一修复涉及不同owner时，先共享后调用方，按照返修路由串行；当前scope外的业务改动给其owner，不在本会话替做。
7. 运行所有决定性定向验证，再按影响运行全量回归/分析；若只是同快照证伪，明确未改代码与反证。保留不可运行/外部缺口原状态。
8. 新证据放evidence/S12-B/attempt-N，写handoff/S12-B.md、runtime/issue-checks/S12-B.json；修复者只写VERIFIED_LOCAL，不替独立审查员宣布闭合。

## 验收与返回

- 原触发条件下正确，邻接路径无回归；相关亮暗/大字/键盘/隐私/权限仍满足原合同。
- 每个修复必须关联明确审查缺陷，不存在“顺便调整”的无归属改动。
- 复用同一修复提示进行后续轮次时递增attempt，保留历史失败。

完成后：按repair-routing继续下一需要的修复；全部所需修复完成后回已有S2执行S2-C。
只报告当前修复和准确下一步，不自动执行下一轮。


---

# S13-C｜终审返修：S13负责范围

**回到已有S13会话。本轮只执行S13-C。不要新建实现会话丢失上下文；原会话不可用时可新开替代会话，但必须先读其全部相关handoff和当前源码，不能从旧快照重做。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S13-C。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S13-C以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S13-C/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S13-C.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S13-C.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S13-C及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 触发与范围

仅在以下条件执行：S2-B或S2-C最新repair-routing把缺陷分配到S13。

允许写入当前会话原始业务范围及必要测试/中英文文案：
- `lib/core/app_lock/`
- `lib/core/preferences/`
- `lib/core/security/`
- `lib/features/profile/`
- `lib/features/profile/presentation/app_lock_settings_page.dart`

## 修复流程

1. 从最近有效审查的repair-routing.json只领取ownerSession与当前会话一致的缺陷。审查阶段、缺陷ID、触发路径、要求测试和source SHA必须明确；不存在分配则记录NOT_REQUIRED，不顺便找新功能做。
2. 核对当前HEAD/diff/未提交来源；先前页面可能已消费新版组件，禁止整文件覆盖回早期实现。
3. 每条先独立复现原审查问题，证伪就给具体证据，不无条件照改。需要代码修复的先有能抓住原失败的行为或可测视觉证据。
4. 只做最小、完整的修复，同步必要调用者和测试；不得改审查报告、删断言、夹字号、略过错误分支或标记缺陷为测试无关。
5. 对每条记录审查ID→根因→before/after SHA→真实验证命令/数量→改后图片路径。影响共享合同要检查全部直接调用；不能只修触发截图的一个页面。
6. 同一修复涉及不同owner时，先共享后调用方，按照返修路由串行；当前scope外的业务改动给其owner，不在本会话替做。
7. 运行所有决定性定向验证，再按影响运行全量回归/分析；若只是同快照证伪，明确未改代码与反证。保留不可运行/外部缺口原状态。
8. 新证据放evidence/S13-C/attempt-N，写handoff/S13-C.md、runtime/issue-checks/S13-C.json；修复者只写VERIFIED_LOCAL，不替独立审查员宣布闭合。

## 验收与返回

- 原触发条件下正确，邻接路径无回归；相关亮暗/大字/键盘/隐私/权限仍满足原合同。
- 每个修复必须关联明确审查缺陷，不存在“顺便调整”的无归属改动。
- 复用同一修复提示进行后续轮次时递增attempt，保留历史失败。

完成后：按repair-routing继续下一需要的修复；全部所需修复完成后回已有S2执行S2-C。
只报告当前修复和准确下一步，不自动执行下一轮。


---

# S14-B｜终审返修：S14负责范围

**回到已有S14会话。本轮只执行S14-B。不要新建实现会话丢失上下文；原会话不可用时可新开替代会话，但必须先读其全部相关handoff和当前源码，不能从旧快照重做。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S14-B。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S14-B以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S14-B/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S14-B.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S14-B.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S14-B及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 触发与范围

仅在以下条件执行：S2-B或S2-C最新repair-routing把缺陷分配到S14。

允许写入当前会话原始业务范围及必要测试/中英文文案：
- `lib/features/recurring/`

## 修复流程

1. 从最近有效审查的repair-routing.json只领取ownerSession与当前会话一致的缺陷。审查阶段、缺陷ID、触发路径、要求测试和source SHA必须明确；不存在分配则记录NOT_REQUIRED，不顺便找新功能做。
2. 核对当前HEAD/diff/未提交来源；先前页面可能已消费新版组件，禁止整文件覆盖回早期实现。
3. 每条先独立复现原审查问题，证伪就给具体证据，不无条件照改。需要代码修复的先有能抓住原失败的行为或可测视觉证据。
4. 只做最小、完整的修复，同步必要调用者和测试；不得改审查报告、删断言、夹字号、略过错误分支或标记缺陷为测试无关。
5. 对每条记录审查ID→根因→before/after SHA→真实验证命令/数量→改后图片路径。影响共享合同要检查全部直接调用；不能只修触发截图的一个页面。
6. 同一修复涉及不同owner时，先共享后调用方，按照返修路由串行；当前scope外的业务改动给其owner，不在本会话替做。
7. 运行所有决定性定向验证，再按影响运行全量回归/分析；若只是同快照证伪，明确未改代码与反证。保留不可运行/外部缺口原状态。
8. 新证据放evidence/S14-B/attempt-N，写handoff/S14-B.md、runtime/issue-checks/S14-B.json；修复者只写VERIFIED_LOCAL，不替独立审查员宣布闭合。

## 验收与返回

- 原触发条件下正确，邻接路径无回归；相关亮暗/大字/键盘/隐私/权限仍满足原合同。
- 每个修复必须关联明确审查缺陷，不存在“顺便调整”的无归属改动。
- 复用同一修复提示进行后续轮次时递增attempt，保留历史失败。

完成后：按repair-routing继续下一需要的修复；全部所需修复完成后回已有S2执行S2-C。
只报告当前修复和准确下一步，不自动执行下一轮。


---

# S15-C｜终审返修：S15负责范围

**回到已有S15会话。本轮只执行S15-C。不要新建实现会话丢失上下文；原会话不可用时可新开替代会话，但必须先读其全部相关handoff和当前源码，不能从旧快照重做。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S15-C。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S15-C以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S15-C/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S15-C.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S15-C.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S15-C及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 触发与范围

仅在以下条件执行：S2-B或S2-C最新repair-routing把缺陷分配到S15。

允许写入当前会话原始业务范围及必要测试/中英文文案：
- `lib/features/io/`
- `lib/features/logs/`
- `lib/util/image_save_service.dart`
- `lib/util/web_download.dart`
- `lib/util/web_download_stub.dart`

## 修复流程

1. 从最近有效审查的repair-routing.json只领取ownerSession与当前会话一致的缺陷。审查阶段、缺陷ID、触发路径、要求测试和source SHA必须明确；不存在分配则记录NOT_REQUIRED，不顺便找新功能做。
2. 核对当前HEAD/diff/未提交来源；先前页面可能已消费新版组件，禁止整文件覆盖回早期实现。
3. 每条先独立复现原审查问题，证伪就给具体证据，不无条件照改。需要代码修复的先有能抓住原失败的行为或可测视觉证据。
4. 只做最小、完整的修复，同步必要调用者和测试；不得改审查报告、删断言、夹字号、略过错误分支或标记缺陷为测试无关。
5. 对每条记录审查ID→根因→before/after SHA→真实验证命令/数量→改后图片路径。影响共享合同要检查全部直接调用；不能只修触发截图的一个页面。
6. 同一修复涉及不同owner时，先共享后调用方，按照返修路由串行；当前scope外的业务改动给其owner，不在本会话替做。
7. 运行所有决定性定向验证，再按影响运行全量回归/分析；若只是同快照证伪，明确未改代码与反证。保留不可运行/外部缺口原状态。
8. 新证据放evidence/S15-C/attempt-N，写handoff/S15-C.md、runtime/issue-checks/S15-C.json；修复者只写VERIFIED_LOCAL，不替独立审查员宣布闭合。

## 验收与返回

- 原触发条件下正确，邻接路径无回归；相关亮暗/大字/键盘/隐私/权限仍满足原合同。
- 每个修复必须关联明确审查缺陷，不存在“顺便调整”的无归属改动。
- 复用同一修复提示进行后续轮次时递增attempt，保留历史失败。

完成后：按repair-routing继续下一需要的修复；全部所需修复完成后回已有S2执行S2-C。
只报告当前修复和准确下一步，不自动执行下一轮。


---

# S1-E｜进行中阶段的共享合同补缺

**回到已有S1会话。本轮只执行S1-E。不要新建实现会话丢失上下文；原会话不可用时可新开替代会话，但必须先读其全部相关handoff和当前源码，不能从旧快照重做。**

工作目录：`/Users/zhangchi118/代码/FortuneBoot-App`。交付语言：中文。
本提示词中的`reference/`、`runtime/`、`handoff/`、`evidence/`、`reviews/`均相对`docs/design-system/execution-prompts/`，不要在工程根目录另建同名台账。
本轮用户只要求执行S1-E。你收到这份提示词即获得本阶段范围内的本地实现/验证授权；不要只给方案或重复请求“是否开始”。需要服务端新契约、真实业务数据写入或其它越界权限时，先完成可独立完成的本地工作，提交具体证据与缺口。

**会话规则**
- S数字代表固定会话；字母代表回到该会话的轮次。S1-E以本提示词为准，不能自行开启下一阶段。
- 全包串行，一个工作区同时只运行一个写代码会话。前序未提交修改是预期成果，先读当前diff、SHA与handoff，不reset/clean/stash/restore到历史版本。
- 不commit、不push、不发布、不部署、不运行会写真实账本/账号/云端数据的操作。不修改服务端工程、数据库或账务存储规则。
- 不升级SDK/依赖、不改包版本/签名/发布配置、不关闭测试/分析规则来换取通过。平台能力缺口只能提出具体最小方案，不能假装已有能力。
- 遵循仓库现有Dart/Flutter惯例和适用的AGENTS规则；Java专属语法/POJO规则不能机械套进Dart。

**必须读取的现有事实**
1. `docs/design-system/execution-prompts/README.md`、`docs/design-system/execution-prompts/stage-map.json`、`runtime/progress.json`、`docs/design-system/execution-prompts/issues.json`，本阶段的前置handoff及最近相关review。
2. `docs/design-system/2026-11-05-global-audit.md`、`docs/design-system/verification.md`、`docs/design-system/verification.json`、`docs/design-system/screenshots.tsv`，以及本提示词列出的模块报告相关条目。
3. `docs/design-system/execution-prompts/reference/contract-requirements.md`、`reference/runtime-format.md`，以及`lib/fx/theme/fx_theme.dart`、`lib/fx/tokens/`、本阶段真实组件与调用链；S1-A之后读取`docs/design-system/execution-prompts/reference/contracts-current.md`和`reference/component-consumers.json`。
4. 所有现有截图均可读取：`/Users/zhangchi118/Desktop/Screenshot iPhone 18 Pro Max 2026-11-05 at *.png`。只读取任务相关内容，不修改/删除原图，不将私人截图上传外部服务。

**当前起点不是原始87f7203裸提交**
已存在未提交的Fx主题、排版、间距、卡片、按钮、文本、弹层、附件适配和测试。2026-11-05上一轮记录为387通过、1跳过；全量分析0error/252warning/907info，与当时HEAD基线相同。它们只作历史参考；先验证当前真实状态，不能照抄为本轮结果。`reference/generation-baseline.json`保存本包生成时证据。

**固定的产品与设计约束**
- 好记是移动财务工具：先完整辨认对象、金额、范围和下一步，再减少装饰。Apple HIG作为移动人体工学参照，Linear/Geist作为层级和克制表面参照；不照搬桌面小字密度。
- 使用当前Fx令牌：大标题34、区块22、主要正文17、label15、caption13；常规400/500、强调600、少量大标题700。用途重要于机械字号替换。
- 4/8/12/16/20/24/32基础节奏；页面20、内容卡16、区块24起；触控至少44、常用48，均是可随内容增长的最小尺寸。卡片0.5装饰线、输入控件1、焦点2；圆角按用途12/16/24。
- 不通过夹断TextScaler、全页FittedBox、缩小关键金额、隐藏内容、删除可访问性或改成只有tooltip才能查精确值来解决布局。
- 已存在的连续账单列表、两级记账类型、默认无重阴影、原生路由、金额掩码和图表数据替代必须保留。
- 财务业务色存储不改；金额文本可读前景与色点/图形填色分工。用符号/标签表达方向，不只靠颜色。未知≠0，未加载≠无记录，失败≠取消。
- 取消、明确清空、提交选中必须可区分；长表单保护未保存内容，忙碌状态覆盖真实任务；请求失败保留已知数据/位置并给恢复动作。
- 所有数据范围与实际请求一致；不能客户端仅过滤当前页伪装全局搜索，也不能合并不同币种/不同百分比分母。

**证据、状态与门槛**
- 先从当前源码/截图/可复现行为确认条目；已修好只验证，审计推断被证伪附证据，不能为了凑工作量重改。原报告只读，更新本包issue-checks而不是抹掉历史。
- 每项主责ID及本阶段共性实例均必须记录：observed、implemented、verified或disproved、blocked_external；最后独立审查前不得自己写VERIFIED_CLOSED。
- `status`使用NOT_STARTED/IN_PROGRESS/PASSED/PARTIAL/FAILED/BLOCKED/NOT_REQUIRED。另列`localGate`、`visualGate`、`externalGate`，不把本地绿与真机/联调绿合并。
- 前置为PASSED才能开始依赖工作。若前置PARTIAL仅因明确的外部验收缺口，且localGate=PASSED、visualGate满足其应交证据、handoff列明可供本阶段使用的完整合同，则核对本阶段不依赖该缺口后可继续；必须记录判断，不把PARTIAL改名为PASSED。缺合同/本地失败/必要视觉未查看则阻塞依赖，不绕过。
- 局部SDK缓存权限/网络失败按环境工具要求申请执行权限；不要删除SDK锁或悄悄换工具链。只读审查不能自行修业务代码/既有测试。

**每轮最小交付格式**
- `evidence/S1-E/attempt-001/`起，重跑递增；保存命令/退出码/测试真实计数/分析差异/源码SHA/截图索引，证据轮次不覆盖。
- `handoff/S1-E.md`保存当前摘要及历次证据链接：范围、before/after SHA、修改文件和原因、主责与共性条目逐项结果、测试/视觉/设备分层、未完成、精确下一提示词。
- `runtime/issue-checks/S1-E.json`保存本阶段每个ID的本地事实与验证，跨模块条目只评本阶段实例；不得代其它owner宣布完成。
- `runtime/progress.json`只原子更新S1-E及明确nextStage，保留其它条目；审查只能更新自身审查状态及返修路由，不能篡改实现者记录。
- 生产界面不得出现审计ID/技术验收/内部实现词；UI文案同时维护`lib/l10n/intl_zh.arb`、`intl_en.arb`中本阶段必要键。按现有生成流程更新，不手改生成Dart；没有新增文案就不动翻译。

**验证的实际含义**
- 行为缺陷使用当前代码可失败的决定性测试再最小修复；纯颜色/间距调整用现有行为回归、对比度和实际Flutter渲染检验，不写只断言常量等于自己的测试。
- 测试中的正常字号/放大字号保持系统TextScaler；包含至少320与390/440逻辑宽、1与2倍字、亮暗、长中文/英文、零/负/大额/空值、只读/隐藏/失败；按本阶段实际业务挑选完整矩阵。
- Widget/单元测试≠真机，合成fixture≠服务器契约，截图存在≠已看图。必须实际打开图片检查层级/留白/文字/金额/边界，记下观察；不能用HTML示意图代替Flutter业务组件。
- 单阶段完成先定向回归，再按改动影响执行一轮全量Flutter测试和分析。无源码变化且同一快照已由本轮验证过可以引用准确证据，不能伪造重复运行；源码或依赖变了必须重跑受影响验证。
- 遇到既有失败应定位归属，保留对照证据，不降低断言、不删除测试。0项或全部skip不是通过。已有IAP跳过保留理由，不擅自打开入口。
- 模拟器/真机、VoiceOver/TalkBack、平台编译和真实接口未执行就记录NOT_RUN；需要它们才能闭合的条目保持PARTIAL/BLOCKED_EXTERNAL。

**常用只读与验证命令（先核当前工具路径，不用旧日志替代）**
```sh
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git diff --stat
flutter --version
python3 docs/design-system/execution-prompts/tools/validate_pack.py
flutter analyze --no-pub
flutter test --no-pub --reporter json
```
格式化仅本阶段修改的Dart文件，不跑全库格式重写。命令日志存本阶段evidence，测试和渲染使用临时/虚构业务数据。共享接口外溢时先做最小兼容适配；若需变更冻结合同，写`runtime/contract-requests.json`并交S1-E，不让页面各自绕开合同。

完成本轮允许范围后立即停止；最终回复必须包含实际结果、剩余项和下一提示词编号/路径，不执行它。


## 触发与范围

仅在以下条件执行：任一实施阶段确认冻结的共享合同无法满足已分配任务，并写入runtime/contract-requests.json；没有明确请求就不执行。

允许写入当前会话原始业务范围及必要测试/中英文文案：
- `lib/core/errors/`
- `lib/core/feedback/`
- `lib/core/money/`
- `lib/core/preferences/finance_color_preferences.dart`
- `lib/fx/`
- `各阶段已经登记的共享组件直接调用点`

## 修复流程

1. 本轮为进行中阶段所需共享合同补缺：读取runtime/contract-requests.json里未解决的request，核对requesterStage、真实调用点、已有合同为何不足和最小需求。只接受已由当前调用证据支持的需求，不借补缺重构全部组件。完成后给caller明确合同版本/适配路径，回原requesterStage重执行它的提示词，不能跳过其验收。
2. 核对当前HEAD/diff/未提交来源；先前页面可能已消费新版组件，禁止整文件覆盖回早期实现。
3. 每条先独立复现原审查问题，证伪就给具体证据，不无条件照改。需要代码修复的先有能抓住原失败的行为或可测视觉证据。
4. 只做最小、完整的修复，同步必要调用者和测试；不得改审查报告、删断言、夹字号、略过错误分支或标记缺陷为测试无关。
5. 对每条记录审查ID→根因→before/after SHA→真实验证命令/数量→改后图片路径。影响共享合同要检查全部直接调用；不能只修触发截图的一个页面。
6. 同一修复涉及不同owner时，先共享后调用方，按照返修路由串行；当前scope外的业务改动给其owner，不在本会话替做。
7. 运行所有决定性定向验证，再按影响运行全量回归/分析；若只是同快照证伪，明确未改代码与反证。保留不可运行/外部缺口原状态。
8. 新证据放evidence/S1-E/attempt-N，写handoff/S1-E.md、runtime/issue-checks/S1-E.json；修复者只写VERIFIED_LOCAL，不替独立审查员宣布闭合。

## 验收与返回

- 原触发条件下正确，邻接路径无回归；相关亮暗/大字/键盘/隐私/权限仍满足原合同。
- 每个修复必须关联明确合同请求ID及其真实调用方，不存在“顺便调整”的无归属改动。
- 复用同一修复提示进行后续轮次时递增attempt，保留历史失败。

完成后：回到contract-requests中明确的requesterStage所在原会话，继续同一阶段并重新验收。
只报告当前修复和准确下一步，不自动执行下一轮。

