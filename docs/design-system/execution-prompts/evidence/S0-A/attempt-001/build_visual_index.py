from pathlib import Path
import csv, hashlib, json
ROOT=Path(__file__).resolve().parents[6]
PACK=ROOT/'docs/design-system/execution-prompts'
OUT=PACK/'evidence/S0-A/attempt-001'
HEAD='6061359de0d6db6597176a9158ee826de490f6c4'
M={
1:('基础URL配置','/base_url_config',['lib/login/view/base_url_config_page.dart'],'历史地址、协议、域名、端口与确认按钮可辨；映射一致。'),
2:('登录页与键盘','/auth',['lib/login/view/login_screen.dart','lib/login/view/auth_page.dart'],'登录表单、密码焦点与系统键盘可见；未复测键盘真机行为。'),
3:('登录图形验证码','/auth + captcha sheet',['lib/login/view/login_screen.dart'],'图形验证码、输入、刷新、取消/确认与数字键盘可见；没有非视觉通道证据。'),
4:('仪表盘上半屏','/dashboard',['lib/features/dashboard/presentation/dashboard_page.dart'],'账期、净资产、收支与趋势层级可辨；截图未绑定当前构建。'),
5:('仪表盘下半屏','/dashboard',['lib/features/dashboard/presentation/dashboard_page.dart'],'分类摘要、最近账单、底部导航和快捷记账入口可辨。'),
6:('分组与账本切换','/dashboard + session sheet',['lib/core/session/widgets/session_switcher_sheet.dart'],'分组 pill、账本列表、当前选择与默认标记可辨。'),
7:('仪表盘布局编辑','/dashboard + layout editor',['lib/features/dashboard/presentation/widgets/dashboard_layout_editor.dart'],'布局编辑清单、显示开关、排序和完成动作可辨。'),
8:('账单列表','/bills',['lib/features/bills/presentation/bills_page.dart'],'连续账期列表、账期导航、汇总与金额掩码入口可辨。'),
9:('账单详情','/bills + detail sheet',['lib/features/shared/presentation/bills/bill_detail_sheet.dart'],'标题、分类拆分、交易属性、附件和底部动作可辨。'),
10:('账单详情更多菜单','/bills + detail actions',['lib/features/shared/presentation/bills/bill_detail_sheet.dart'],'详情更多菜单中的复制与删除可辨，危险动作有区分。'),
11:('记账编辑上半屏','/bill_editor',['lib/features/bill_editor/presentation/bill_editor_page.dart'],'两级记账类型、金额、分类拆分、账户与保存动作可辨。'),
12:('记账编辑下半屏','/bill_editor',['lib/features/bill_editor/presentation/bill_editor_page.dart'],'费用、附件、确认/计入开关和底部保存动作可辨。'),
13:('账单筛选上半屏','/bills + filter sheet',['lib/features/bills/presentation/widgets/bills_filter_sheet.dart'],'标题搜索、类型、金额区间、账期和重置/应用可辨。'),
14:('账单筛选下半屏','/bills + filter sheet',['lib/features/bills/presentation/widgets/bills_filter_sheet.dart'],'确认状态、统计范围、分类、标签、账户、交易对象和成员可辨。'),
15:('统计日历','/stats',['lib/features/stats/presentation/stats_page.dart','lib/features/stats/presentation/widgets/stats_income_expense_calendar_card.dart'],'月/年/历史分段、月历与选中日期详情可辨；小字问题保留给S8-B。'),
16:('统计分析与趋势','/stats',['lib/features/stats/presentation/stats_page.dart','lib/features/stats/presentation/widgets/stats_trend_card.dart'],'账期、收支方向、空维度状态和趋势卡可辨。'),
17:('统计下半屏','/stats',['lib/features/stats/presentation/stats_page.dart'],'资产、借贷、统计口径入口位于分析内容之后，映射一致。'),
18:('资产统计上半屏','/stats/assets',['lib/features/stats/presentation/stats_assets_page.dart'],'资产/负债摘要、占比图、账户列表与趋势可辨；金额有截断风险。'),
19:('资产统计下半屏','/stats/assets',['lib/features/stats/presentation/stats_assets_page.dart'],'趋势、账户类型和信用卡摘要可辨；未证明百分比分母一致。'),
20:('借贷理财','/stats/loans',['lib/features/stats/presentation/stats_loans_page.dart'],'借贷汇总、逾期/核对数值和已归档信息可辨。'),
21:('统计策略说明','/stats/policy',['lib/features/stats/presentation/stats_policy_page.dart'],'统计口径与账单类型说明可辨；不代表请求失败时仍正确。'),
22:('统计时间范围菜单','/stats + range sheet',['lib/features/stats/presentation/widgets/stats_top_bar.dart'],'本周/账期/本年/自定义及年月日选择可辨；实际请求范围需另验。'),
23:('我的上半屏','/profile',['lib/features/profile/presentation/profile_page.dart'],'用户摘要、账本协作和基础数据管理入口可辨。'),
24:('个人资料','/profile_edit',['lib/features/profile/presentation/profile_edit_page.dart'],'资料字段与系统记录可辨，截图含个人数据但未外传。'),
25:('注销账号','/profile_edit + deletion sheet',['lib/features/profile/presentation/widgets/account_deletion_sheet.dart'],'危险说明、密码、确认注销与取消可辨；未执行真实注销。'),
26:('修改密码','/profile_edit + password sheet',['lib/features/profile/presentation/profile_edit_page.dart'],'旧密码、新密码、确认与提交可辨；未执行真实修改。'),
27:('编辑资料','/profile_edit + details sheet',['lib/features/profile/presentation/profile_edit_page.dart'],'昵称、电话、邮箱、性别和保存可辨；清空语义未由截图证明。'),
28:('账本分组管理','/groups',['lib/features/books/presentation/books_page.dart'],'分组列表、搜索、状态筛选、默认标识与新增入口可辨。'),
29:('账本管理','/books',['lib/features/books/presentation/books_page.dart'],'账本列表、当前/默认标识、币种与新增入口可辨。'),
30:('新增账本币种','/books + book form',['lib/features/books/presentation/widgets/book_form_sheet.dart'],'高基数币种 chip 墙与创建动作可辨；仅作原问题基线。'),
31:('新增账本下半屏','/books + book form',['lib/features/books/presentation/widgets/book_form_sheet.dart'],'其余币种、模板、启用、备注和创建动作可辨。'),
32:('新增分组币种','/groups + group form',['lib/features/books/presentation/widgets/group_form_sheet.dart'],'分组名称、默认币种和创建动作可辨。'),
33:('新增分组下半屏','/groups + group form',['lib/features/books/presentation/widgets/group_form_sheet.dart'],'其余币种、启用、备注与创建动作可辨。'),
34:('协作成员管理','/group_users',['lib/features/group_users/presentation/group_users_page.dart'],'成员身份、角色与邀请入口可辨；角色权限未由截图证明。'),
35:('邀请用户','/group_users + invite sheet',['lib/features/shared/invite_member_sheet.dart'],'账号、角色选项和发送邀请可辨；未执行真实邀请。'),
36:('分类管理','/categories',['lib/features/categories/presentation/categories_page.dart'],'两级分类树、状态筛选、搜索和新增入口可辨。'),
37:('新增分类','/categories + form',['lib/features/categories/presentation/widgets/category_form_sheet.dart'],'名称、类型、父级、排序、启用和创建动作可辨。'),
38:('编辑分类','/categories + form',['lib/features/categories/presentation/widgets/category_form_sheet.dart'],'既有分类值与保存动作可辨；未执行修改。'),
39:('标签管理','/tags',['lib/features/tags/presentation/tags_page.dart'],'标签树、状态筛选、回收站与新增入口可辨。'),
40:('新增标签','/tags + form',['lib/features/tags/presentation/widgets/tag_form_sheet.dart'],'名称、父级、类型开关和创建动作可辨。'),
41:('编辑标签','/tags + form',['lib/features/tags/presentation/widgets/tag_form_sheet.dart'],'既有标签值、类型开关和保存动作可辨。'),
42:('标签回收站','/tags + recycle segment',['lib/features/tags/presentation/tags_page.dart'],'回收站列表与返回入口可辨，空/失败分支未覆盖。'),
43:('交易对象管理','/payees',['lib/features/payees/presentation/payees_page.dart'],'交易对象列表、类型说明、状态筛选和新增入口可辨。'),
44:('编辑交易对象','/payees + form',['lib/features/payees/presentation/widgets/payee_form_sheet.dart'],'名称、排序、类型开关和保存动作可辨。'),
45:('成员管理','/members',['lib/features/members/presentation/members_page.dart'],'成员列表、启停和新增入口可辨。'),
46:('新增成员','/members + form',['lib/features/members/presentation/widgets/member_form_sheet.dart'],'姓名、排序、备注、启用和创建动作可辨。'),
47:('成员创建后的列表','/members',['lib/features/members/presentation/members_page.dart'],'创建后两名成员及启用状态可辨；不是本轮新操作证据。'),
48:('归物列表','/goods',['lib/features/goods/presentation/goods_page.dart'],'归物卡片、金额、状态和汇总可辨；未覆盖新增与空态。'),
49:('归物详情','/goods + detail',['lib/features/goods/presentation/widgets/goods_detail_sheet.dart'],'购买信息、成本、分类、标签、保修和状态可辨。'),
50:('编辑归物上半屏','/goods_editor',['lib/features/goods/presentation/widgets/goods_form_sheet.dart'],'基础信息、分类标签、保修状态与保存动作可辨。'),
51:('编辑归物下半屏','/goods_editor',['lib/features/goods/presentation/widgets/goods_form_sheet.dart'],'分类标签、日期、状态、备注附件与保存动作可辨。'),
52:('单据管理','/orders',['lib/features/orders/presentation/orders_page.dart'],'单据汇总、类型、搜索、筛选和列表可辨；创建流程未覆盖。'),
53:('单据详情','/orders/detail',['lib/features/orders/presentation/order_detail_page.dart'],'金额、业务动作、流水和条目动作可辨；未执行真实动作。'),
54:('单据详情重复采样','/orders/detail',['lib/features/orders/presentation/order_detail_page.dart'],'与V53为同一状态的重复采样，不计算独立页面。'),
55:('周期记账列表','/recurring',['lib/features/recurring/presentation/recurring_page.dart'],'规则、调度摘要、下次执行、执行次数和启停可辨。'),
56:('编辑周期规则上半屏','/recurring_editor',['lib/features/recurring/presentation/recurring_editor_page.dart','lib/features/recurring/presentation/widgets/cron_schedule_editor.dart'],'频率、日期网格、时间、限制与账单模板可辨。'),
57:('编辑周期规则下半屏','/recurring_editor',['lib/features/recurring/presentation/recurring_editor_page.dart'],'起止日期、补偿、启停、模板字段和保存动作可辨。'),
58:('导入导出','/io',['lib/features/io/presentation/io_page.dart'],'导出、模板、导入三个入口可辨；用户实际文件交付未证明。'),
59:('日志列表','/logs',['lib/features/logs/presentation/logs_page.dart'],'操作/登录日志、搜索、状态与详情入口可辨。'),
60:('语言选择','/profile + locale sheet',['lib/features/profile/presentation/profile_page.dart'],'跟随系统、中文、English与选中勾可辨；语义需另验。'),
61:('主题模式','/profile + theme sheet',['lib/features/profile/presentation/profile_page.dart'],'跟随系统、亮色、暗色选项可辨；截图本身仍是浅色。'),
62:('账单月开始日','/profile + month start sheet',['lib/features/profile/presentation/profile_page.dart'],'日期逐项列表和当前选择可辨；实际账期预览未覆盖。'),
63:('应用锁设置','/profile + app lock',['lib/features/profile/presentation/app_lock_settings_page.dart'],'回退方式、默认解锁方式和能力说明可辨；未做解锁实测。'),
64:('账单颜色','/profile + finance colors',['lib/features/profile/presentation/widgets/finance_color_editor.dart'],'预设与收入/支出/转账色板可辨；未证明所有金额前景对比。'),
65:('关于好记','/profile + about sheet',['lib/features/profile/presentation/profile_page.dart'],'应用/API版本与备案信息可辨；属原页面基线。'),
66:('帮助','/profile + help sheet',['lib/features/profile/presentation/profile_page.dart'],'帮助文段与任务分组可辨；长文阅读和小字仍需S13-A。'),
67:('退出登录','/profile + logout sheet',['lib/features/profile/presentation/profile_page.dart'],'危险退出、取消与关闭入口可辨；未执行退出。'),
68:('注册上半屏','/auth + register',['lib/login/view/login_screen.dart','lib/login/view/auth_page.dart'],'账号、密码、昵称、性别、邮箱、手机号与条款入口可辨。'),
69:('注册下半屏','/auth + register',['lib/login/view/login_screen.dart','lib/login/view/auth_page.dart'],'密码、资料、条款和创建账户动作可辨；未执行真实注册。'),
}
with (ROOT/'docs/design-system/screenshots.tsv').open() as f: rows=list(csv.reader(f,delimiter='\t'))
meta=json.loads((OUT/'screenshot-metadata.json').read_text())
index=[]
for (vid,path,state),m in zip(rows,meta):
 n=int(vid); page,route,sources,observation=M[n]
 index.append({'id':f'V{n:02d}','page':page,'state':state,'route':route,'theme':'LIGHT_OBSERVED','logicalSize':'UNKNOWN_NOT_RECORDED_IN_PNG','textScale':'UNKNOWN_NOT_RECORDED_IN_PNG','pixelSize':m['pixelSize'],'sourceSha':HEAD,'sourceSha256':{p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in sources},'sourceFiles':sources,'path':path,'pathSha256':m['sha256'],'contactSheet':f'evidence/S0-A/attempt-001/contact-sheet-{((n-1)//12)+1:02d}.jpg','actuallyViewed':True,'viewMethod':'6张本地联系表逐张打开，覆盖全部69张原图；未上传原图','observation':observation,'goldenEligible':False,'goldenReason':'截图无构建SHA、logicalSize或TextScaler记录，且本轮未重拍当前业务页面'})
(OUT/'screenshot-index.json').write_text(json.dumps(index,ensure_ascii=False,indent=2)+'\n')
lines=['# 页面迁移与视觉覆盖地图（S0-A）','',f'来源：`master@{HEAD}`。V01—V69已通过6张本地联系表实际查看，映射与`screenshots.tsv`一致。截图没有构建SHA、逻辑视口或TextScaler记录，只能作可见结构基线，不能作当前提交的精确像素golden。每图哈希、源码哈希、主题、未知逻辑尺寸/字号和观察结论见`evidence/S0-A/attempt-001/screenshot-index.json`。','', '| ID | 页面/状态 | 路由或边界 | 当前源文件 | 本轮观察与迁移边界 |','| --- | --- | --- | --- | --- |']
for e in index:
 lines.append(f"| {e['id']} | {e['page']} | `{e['route']}` | "+'<br>'.join(f'`{p}`' for p in e['sourceFiles'])+f" | {e['observation']} |")
lines += ['', '## 未覆盖状态与补拍计划','', '以下均为计划，不是本轮已生成或已验收的截图。真实业务Widget必须绑定当前源码SHA；每个关键状态至少覆盖320与390/440逻辑宽、1与2倍系统字、亮暗主题。长中文/英文、零/负/大额/空值、只读/隐藏/失败按页面实际业务加入。','', '| 覆盖缺口 | 真实组件/源文件 | 责任阶段 | 必补状态 |','| --- | --- | --- | --- |',
'| 账户与余额 | `accounts_page.dart`、`account_form_sheet.dart`、`balance_adjust_sheet.dart`、`recycle_bin_sheet.dart` | S11-A | 列表、创建/编辑、余额调整、回收站、未知余额、隐藏金额、空/失败、亮暗与大字 |',
'| 分组/账本详情 | `group_detail_page.dart`、`book_detail_page.dart`、`default_account_sheet.dart` | S9-A | 角色能力、默认账户缺失、回收站、长名称、空/失败、只读 |',
'| 归物新增 | `goods_form_sheet.dart` | S11-B | 新建草稿、附件、无保修、长名称、金额零/大额、失败保留输入 |',
'| 单据创建与筛选 | `order_form_sheet.dart`、`order_filter_sheet.dart` | S6-A | 两种单据、草稿离开、忙碌快照、筛选零结果、失败恢复、320/2倍字 |',
'| 单据核对与审计 | `order_reconciliation_page.dart`、`order_audit_sheet.dart` | S6-C | 混币、未知现金影响、分页失败、空报告、长审计、隐藏金额 |',
'| 年历/历史/日小票 | `stats_income_expense_calendar_card.dart`、`calendar_day_summary_sheet.dart` | S8-B | 年/历史、无交易日、明细部分加载、失败重试、保存取消/失败、隐私跨route |',
'| 暗色业务页 | 全部主线页面，优先金额/图表/实色按钮/危险动作 | 各owner，S1-C收口 | 真实暗色主题下的前景、边界、图表替代、掩码和焦点；不能用底座预览替代 |',
'| 错误/空态/加载 | 各列表、详情、表单和跨route页面 | 各owner，S1-C收口 | 首次空、筛选零结果、无账本/分组、未知、加载、局部失败、重试后恢复；失败不得伪装空数据 |',
'| 无障碍与设备 | 导航、选择器、布局排序、验证码、应用锁、文件交付 | 对应owner，S2复审 | VoiceOver/TalkBack、键盘/手势、系统大字、原生返回；未执行前保持NOT_RUN |',
'', '## 截图产物约定','', '后续索引字段固定为页面、状态、主题、logicalSize、textScale、sourceSha、sourceSha256、路径、actuallyViewed和观察结论。图片存在但未打开时`actuallyViewed=false`；合成fixture只证明本地组件，必须另列真实接口和设备边界。']
(PACK/'reference/page-migration-map.md').write_text('\n'.join(lines)+'\n')
print('visual index',len(index),'sources missing',[(e['id'],p) for e in index for p in e['sourceFiles'] if not (ROOT/p).exists()])
