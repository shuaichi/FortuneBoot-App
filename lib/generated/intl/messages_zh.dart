// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static String m0(name) => "调整余额 · ${name}";

  static String m1(rate) => "利率 ${rate}";

  static String m2(day) => "账单日 ${day}";

  static String m3(amount) => "当前余额 ${amount}";

  static String m4(name) => "确定彻底删除「${name}」吗？此操作不可撤销。";

  static String m5(name) => "确定将「${name}」移入回收站吗？";

  static String m6(day) => "还款日 ${day}";

  static String m7(required) => "服务端不支持版本检测，无法确认兼容性。请确认服务端并升级至 ${required} 及以上";

  static String m8(actual, supportedMax) =>
      "服务端版本过高（v${actual}），当前客户端仅支持低于 ${supportedMax} 的服务端，请升级客户端或联系管理员";

  static String m9(actual, required) =>
      "服务端版本过低（v${actual}），需 ${required} 及以上，请联系管理员升级服务端";

  static String m10(row, column, state) => "第 ${row} 行第 ${column} 列节点，${state}";

  static String m11(count) => "已连接 ${count} 个点";

  static String m12(type) => "${type}金额";

  static String m13(count) => "共 ${count} 项";

  static String m14(count) => "已选 ${count} 个附件";

  static String m15(name) => "默认「${name}」";

  static String m16(month) => "${month}账期";

  static String m17(amount) => "支 ${amount}";

  static String m18(amount) => "收 ${amount}";

  static String m19(title) => "确定删除「${title}」吗？此操作不可撤销。";

  static String m20(type, side) => "${type}（${side}）";

  static String m21(name) => "请输入「${name}」确认";

  static String m22(tab) => "当前在：${tab}";

  static String m23(name) => "默认账本：${name}";

  static String m24(name) => "默认支出：${name}";

  static String m25(name) => "彻底删除账本「${name}」?";

  static String m26(name) => "永久删除分组「${name}」?";

  static String m27(username) => "将邀请 ${username} 加入当前分组，请确认用户名完全一致。";

  static String m28(username) => "已邀请 ${username}";

  static String m29(count) => "成员（${count}）";

  static String m30(remark) => "备注：${remark}";

  static String m31(name) => "确定彻底删除「${name}」吗？此操作不可撤销。";

  static String m32(name) => "确定删除「${name}」吗？该分组下账本也将无法访问。";

  static String m33(sort) => "显示顺序：${sort}";

  static String m34(name) => "已切换到「${name}」";

  static String m35(kind) => "该账户不支持${kind}";

  static String m36(name) => "确定彻底删除「${name}」吗？此操作不可撤销。";

  static String m37(name) => "确定将「${name}」移入回收站吗？";

  static String m38(label) => "收起 ${label}";

  static String m39(count) => "确定（${count}）";

  static String m40(label) => "展开 ${label}";

  static String m41(amount) => "日均 ${amount}";

  static String m42(days) => "${days} 天";

  static String m43(days) => "持有 ${days} 天";

  static String m44(label) => "${label}（无可选项）";

  static String m45(name) => "确定删除「${name}」吗？此操作不可撤销。";

  static String m46(status) => "当前状态「${status}」暂不可识别，如需修改请重新选择；不选则保留原状态。";

  static String m47(name) => "确定将「${name}」移出该分组吗？";

  static String m48(name) => "成员管理 · ${name}";

  static String m49(filename) => "已开始下载 ${filename}";

  static String m50(path) => "已保存到：${path}";

  static String m51(count) => "该分支有 ${count} 条搜索结果";

  static String m52(name) => "确定彻底删除「${name}」吗？此操作不可撤销。";

  static String m53(name) => "确定将「${name}」移入回收站吗？";

  static String m54(time) => "归档 ${time}";

  static String m55(type) => "编辑${type}";

  static String m56(count) => "${count} 张";

  static String m57(count) => "${count} 条孤立历史流水待核对";

  static String m58(count) => "待确认 ${count} 笔";

  static String m59(id) => "流水 #${id}";

  static String m60(id) => "单据 #${id}";

  static String m61(name) => "确定删除「${name}」吗？";

  static String m62(count) => "${count} 张单据待核对，未计入以上金额";

  static String m63(time) => "提交 ${time}";

  static String m64(type) => "${type}标题";

  static String m65(amount) => "作废后将回滚资金：${amount}。";

  static String m66(amount) => "调整额：${amount}。该操作会计入收支，但不会再次改变账户余额。";

  static String m67(name) => "确定彻底删除「${name}」吗？此操作不可撤销。";

  static String m68(name) => "确定将「${name}」移入回收站吗？";

  static String m69(sort) => "排序 ${sort}";

  static String m70(error) => "刷新失败：${error}";

  static String m71(day) => "每月 ${day} 日";

  static String m72(error) => "修改失败：${error}";

  static String m73(error) => "保存失败：${error}";

  static String m74(days, hours, minutes) =>
      "剩余 ${days} 天 ${hours} 时 ${minutes} 分";

  static String m75(date) => "至 ${date}";

  static String m76(error) => "上传失败：${error}";

  static String m77(day) => "${day} 号";

  static String m78(count) => "${count} 次";

  static String m79(id) => "账单 #${id}";

  static String m80(ms) => "耗时 ${ms}ms";

  static String m81(name) => "执行日志 · ${name}";

  static String m82(month) => "${month} 月";

  static String m83(name) => "确定删除「${name}」吗？此操作不可撤销。";

  static String m84(time) => "每天 ${time}";

  static String m85(day, time) => "每月 ${day} 号 ${time}";

  static String m86(days, time) => "每周 ${days} ${time}";

  static String m87(month, day, time) => "每年 ${month}月${day}号 ${time}";

  static String m88(count) => "柱状图，共 ${count} 项";

  static String m89(count) => "${count} 笔";

  static String m90(date) => "${date} 收支";

  static String m91(count) => "支出 ${count} 笔";

  static String m92(count) => "收入 ${count} 笔";

  static String m93(count) => "共 ${count} 笔";

  static String m94(billing, repayment) => "账单日 ${billing} · 还款日 ${repayment}";

  static String m95(count) => "环形图，共 ${count} 项";

  static String m96(count) => "折线图，共 ${count} 个数据点";

  static String m97(count) => "待确认流水 ${count} 笔";

  static String m98(date) => "日期:${date}";

  static String m99(amount) => "共优惠${amount}";

  static String m100(amount) => "手续费共${amount}";

  static String m101(id) => "流水号:${id}";

  static String m102(count) => "图表数据表，共 ${count} 行";

  static String m103(name) => "确定彻底删除「${name}」吗？此操作不可撤销。";

  static String m104(name) => "确定将「${name}」移入回收站吗？";

  static String m105(todoTitle) => "账单明细「${todoTitle}」已删除。";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "account_valid": MessageLookupByLibrary.simpleMessage("用户名重复，想个新的或者直接登录吧"),
    "accountsAddTitle": MessageLookupByLibrary.simpleMessage("新增账户"),
    "accountsAdjustBalance": MessageLookupByLibrary.simpleMessage("调整余额"),
    "accountsAdjustBalanceNeedBook": MessageLookupByLibrary.simpleMessage(
      "调整余额（需先选账本）",
    ),
    "accountsAdjustTitle": m0,
    "accountsAdjustedAmount": MessageLookupByLibrary.simpleMessage("调整后金额"),
    "accountsAdjustedAmountHint": MessageLookupByLibrary.simpleMessage(
      "调整后的实际金额",
    ),
    "accountsAprChip": m1,
    "accountsAssets": MessageLookupByLibrary.simpleMessage("资产"),
    "accountsBalanceAdjustHint": MessageLookupByLibrary.simpleMessage("余额调整"),
    "accountsBalanceAdjusted": MessageLookupByLibrary.simpleMessage("余额已调整"),
    "accountsBillDayChip": m2,
    "accountsConfirmAdjust": MessageLookupByLibrary.simpleMessage("确认调整"),
    "accountsCreateAccount": MessageLookupByLibrary.simpleMessage("创建账户"),
    "accountsCreditLimit": MessageLookupByLibrary.simpleMessage("额度"),
    "accountsCurrencyRequired": MessageLookupByLibrary.simpleMessage("请输入币种"),
    "accountsCurrentBalance": m3,
    "accountsDefaultName": MessageLookupByLibrary.simpleMessage("该账户"),
    "accountsDelete": MessageLookupByLibrary.simpleMessage("删除"),
    "accountsDeleteConfirm": m4,
    "accountsDeletePermanently": MessageLookupByLibrary.simpleMessage("彻底删除"),
    "accountsDotExpense": MessageLookupByLibrary.simpleMessage("支"),
    "accountsDotIncome": MessageLookupByLibrary.simpleMessage("收"),
    "accountsDotTransferIn": MessageLookupByLibrary.simpleMessage("转入"),
    "accountsDotTransferOut": MessageLookupByLibrary.simpleMessage("转出"),
    "accountsEditTitle": MessageLookupByLibrary.simpleMessage("编辑账户"),
    "accountsEmptyHint": MessageLookupByLibrary.simpleMessage(
      "暂无账户，点击右上角 + 新增",
    ),
    "accountsFieldApr": MessageLookupByLibrary.simpleMessage("年利率 APR"),
    "accountsFieldAprHint": MessageLookupByLibrary.simpleMessage("如：0.045"),
    "accountsFieldBalance": MessageLookupByLibrary.simpleMessage("余额"),
    "accountsFieldBalanceLiabilityHint": MessageLookupByLibrary.simpleMessage(
      "未使用填 0，欠款填负数（勿填额度）",
    ),
    "accountsFieldBillDay": MessageLookupByLibrary.simpleMessage(
      "账单日（yyyy-MM-dd）",
    ),
    "accountsFieldCardNo": MessageLookupByLibrary.simpleMessage("卡号（可选）"),
    "accountsFieldCardNoHint": MessageLookupByLibrary.simpleMessage("用于展示末四位"),
    "accountsFieldCreditLimit": MessageLookupByLibrary.simpleMessage("信用/贷款额度"),
    "accountsFieldCreditLimitHint": MessageLookupByLibrary.simpleMessage(
      "如：50000",
    ),
    "accountsFieldCurrency": MessageLookupByLibrary.simpleMessage("币种"),
    "accountsFieldInitialBalance": MessageLookupByLibrary.simpleMessage("期初余额"),
    "accountsFieldName": MessageLookupByLibrary.simpleMessage("账户名称"),
    "accountsFieldNameHint": MessageLookupByLibrary.simpleMessage("如：招行储蓄卡"),
    "accountsFieldRepayDay": MessageLookupByLibrary.simpleMessage(
      "还款日（yyyy-MM-dd）",
    ),
    "accountsFieldType": MessageLookupByLibrary.simpleMessage("账户类型"),
    "accountsIncludedInNetWorth": MessageLookupByLibrary.simpleMessage("计入净产"),
    "accountsInvalidAmount": MessageLookupByLibrary.simpleMessage("请输入有效金额"),
    "accountsLiabilities": MessageLookupByLibrary.simpleMessage("负债"),
    "accountsMoveIn": MessageLookupByLibrary.simpleMessage("移入"),
    "accountsMoveToRecycleBinConfirm": m5,
    "accountsMoveToRecycleBinTitle": MessageLookupByLibrary.simpleMessage(
      "移入回收站",
    ),
    "accountsNameRequired": MessageLookupByLibrary.simpleMessage("请输入账户名称"),
    "accountsNetWorth": MessageLookupByLibrary.simpleMessage("净资产"),
    "accountsOccurredTime": MessageLookupByLibrary.simpleMessage("发生时间"),
    "accountsRecycleBin": MessageLookupByLibrary.simpleMessage("回收站"),
    "accountsRecycleBinEmpty": MessageLookupByLibrary.simpleMessage("回收站为空"),
    "accountsRemarkHint": MessageLookupByLibrary.simpleMessage("备注"),
    "accountsRemarkOptional": MessageLookupByLibrary.simpleMessage("备注（可选）"),
    "accountsRepayDayChip": m6,
    "accountsRestore": MessageLookupByLibrary.simpleMessage("移出"),
    "accountsSaveChanges": MessageLookupByLibrary.simpleMessage("保存修改"),
    "accountsSelectBookForAdjust": MessageLookupByLibrary.simpleMessage(
      "请先选择账本后再调整余额",
    ),
    "accountsSelectBookGroup": MessageLookupByLibrary.simpleMessage(
      "请先选择账本/分组",
    ),
    "accountsTitle": MessageLookupByLibrary.simpleMessage("账户管理"),
    "accountsTitleOptional": MessageLookupByLibrary.simpleMessage("标题（可选）"),
    "accountsToggleCanExpense": MessageLookupByLibrary.simpleMessage("可支出"),
    "accountsToggleCanIncome": MessageLookupByLibrary.simpleMessage("可收入"),
    "accountsToggleCanTransferIn": MessageLookupByLibrary.simpleMessage("可转入"),
    "accountsToggleCanTransferOut": MessageLookupByLibrary.simpleMessage("可转出"),
    "accountsToggleEnable": MessageLookupByLibrary.simpleMessage("启用"),
    "accountsToggleInclude": MessageLookupByLibrary.simpleMessage("计入净资产"),
    "accountsTypeAsset": MessageLookupByLibrary.simpleMessage("资产账户"),
    "accountsTypeCash": MessageLookupByLibrary.simpleMessage("现金账户"),
    "accountsTypeCredit": MessageLookupByLibrary.simpleMessage("信用卡"),
    "accountsTypeLoan": MessageLookupByLibrary.simpleMessage("贷款账户"),
    "accountsTypeOther": MessageLookupByLibrary.simpleMessage("其他账户"),
    "accountsUnnamed": MessageLookupByLibrary.simpleMessage("未命名账户"),
    "accountsUsed": MessageLookupByLibrary.simpleMessage("已用"),
    "apiPrefixInvalid": MessageLookupByLibrary.simpleMessage(
      "前缀需以 / 开头且不能以 / 结尾（如 /dev-api），留空表示无前缀",
    ),
    "apiPrefixLabel": MessageLookupByLibrary.simpleMessage("接口前缀"),
    "apiVersionEndpointUnavailable": m7,
    "apiVersionTooHigh": m8,
    "apiVersionTooLow": m9,
    "apiVersionUnavailable": MessageLookupByLibrary.simpleMessage(
      "服务端返回的版本信息无效，无法确认兼容性，请联系管理员",
    ),
    "appLockBiometricAvailableSubtitle": MessageLookupByLibrary.simpleMessage(
      "仍需保留密码或手势作为回退方式",
    ),
    "appLockBiometricLocalizedReason": MessageLookupByLibrary.simpleMessage(
      "请验证身份以解锁好记",
    ),
    "appLockBiometricToggleTitle": MessageLookupByLibrary.simpleMessage(
      "使用生物识别快捷解锁",
    ),
    "appLockBiometricUnavailableSubtitle": MessageLookupByLibrary.simpleMessage(
      "当前设备不支持或未设置生物识别",
    ),
    "appLockConfigurationInvalid": MessageLookupByLibrary.simpleMessage(
      "请检查密码或手势格式后重试",
    ),
    "appLockConfirmCredentialLabel": MessageLookupByLibrary.simpleMessage(
      "再次确认",
    ),
    "appLockConfirmPattern": MessageLookupByLibrary.simpleMessage("再次绘制图案以确认"),
    "appLockCredentialMismatch": MessageLookupByLibrary.simpleMessage(
      "两次输入不一致",
    ),
    "appLockCurrentCredentialLabel": MessageLookupByLibrary.simpleMessage(
      "当前密码或手势",
    ),
    "appLockCurrentMethod": MessageLookupByLibrary.simpleMessage("当前解锁方式"),
    "appLockDisable": MessageLookupByLibrary.simpleMessage("关闭应用锁"),
    "appLockDisableDialogTitle": MessageLookupByLibrary.simpleMessage(
      "验证后关闭应用锁",
    ),
    "appLockDisableVerificationFailed": MessageLookupByLibrary.simpleMessage(
      "验证失败，请重试",
    ),
    "appLockDrawPattern": MessageLookupByLibrary.simpleMessage("绘制解锁图案"),
    "appLockEnable": MessageLookupByLibrary.simpleMessage("开启应用锁"),
    "appLockEnableDescription": MessageLookupByLibrary.simpleMessage(
      "设置后，离开应用前台或再次进入主界面时需要验证。",
    ),
    "appLockEnableHeading": MessageLookupByLibrary.simpleMessage("开启应用锁"),
    "appLockEnabledDescription": MessageLookupByLibrary.simpleMessage(
      "离开应用前台后需要重新验证。",
    ),
    "appLockEnabledHeading": MessageLookupByLibrary.simpleMessage("已开启应用锁"),
    "appLockEnterPatternDescription": MessageLookupByLibrary.simpleMessage(
      "请绘制解锁图案以继续",
    ),
    "appLockEnterPinDescription": MessageLookupByLibrary.simpleMessage(
      "请输入数字密码以继续",
    ),
    "appLockFailureBiometric": MessageLookupByLibrary.simpleMessage(
      "生物识别未通过，请重试或使用密码/手势解锁",
    ),
    "appLockFailureBiometricUnavailable": MessageLookupByLibrary.simpleMessage(
      "生物识别暂不可用，请使用密码或手势解锁",
    ),
    "appLockFailureConfigurationSave": MessageLookupByLibrary.simpleMessage(
      "应用锁设置保存失败",
    ),
    "appLockFailureDisable": MessageLookupByLibrary.simpleMessage("应用锁关闭失败"),
    "appLockFailureInvalidCredential": MessageLookupByLibrary.simpleMessage(
      "验证失败，请重试",
    ),
    "appLockFallbackMethodSubtitle": MessageLookupByLibrary.simpleMessage(
      "面容或指纹不可用时使用",
    ),
    "appLockFallbackMethodTitle": MessageLookupByLibrary.simpleMessage("回退方式"),
    "appLockGateTitle": MessageLookupByLibrary.simpleMessage("好记已锁定"),
    "appLockLockNow": MessageLookupByLibrary.simpleMessage("立即锁定"),
    "appLockPatternAccessibilityLabel": MessageLookupByLibrary.simpleMessage(
      "解锁图案九宫格",
    ),
    "appLockPatternHint": MessageLookupByLibrary.simpleMessage("请绘制解锁图案"),
    "appLockPatternMethod": MessageLookupByLibrary.simpleMessage("解锁图案"),
    "appLockPatternMinimumPoints": MessageLookupByLibrary.simpleMessage(
      "请至少连接 4 个点",
    ),
    "appLockPatternMismatch": MessageLookupByLibrary.simpleMessage(
      "两次图案不一致，请重试",
    ),
    "appLockPatternNodeAccessibility": m10,
    "appLockPatternNodeSelected": MessageLookupByLibrary.simpleMessage("已选择"),
    "appLockPatternNodeUnselected": MessageLookupByLibrary.simpleMessage("未选择"),
    "appLockPatternProgress": m11,
    "appLockPatternReset": MessageLookupByLibrary.simpleMessage("重新绘制"),
    "appLockPatternSetupLabel": MessageLookupByLibrary.simpleMessage("绘制解锁图案"),
    "appLockPickMethod": MessageLookupByLibrary.simpleMessage("请选择解锁方式"),
    "appLockPinHint": MessageLookupByLibrary.simpleMessage("6–12 位数字密码"),
    "appLockPinLengthInvalid": MessageLookupByLibrary.simpleMessage(
      "PIN 需为 6–12 位数字",
    ),
    "appLockPinMethod": MessageLookupByLibrary.simpleMessage("数字密码"),
    "appLockPinSetupLabel": MessageLookupByLibrary.simpleMessage(
      "设置 6–12 位数字密码",
    ),
    "appLockPreferredFace": MessageLookupByLibrary.simpleMessage("面容"),
    "appLockPreferredFingerprint": MessageLookupByLibrary.simpleMessage("指纹"),
    "appLockPreferredUnavailable": MessageLookupByLibrary.simpleMessage(
      "当前设备不支持该解锁方式",
    ),
    "appLockPreferredUnlockSubtitle": MessageLookupByLibrary.simpleMessage(
      "锁屏时优先使用；面容/指纹失败时可回退到密码或手势",
    ),
    "appLockPreferredUnlockTitle": MessageLookupByLibrary.simpleMessage(
      "默认解锁方式",
    ),
    "appLockReason": MessageLookupByLibrary.simpleMessage("验证身份以解锁好记"),
    "appLockSaving": MessageLookupByLibrary.simpleMessage("正在保存…"),
    "appLockSettingsTitle": MessageLookupByLibrary.simpleMessage("应用锁"),
    "appLockSetupRequiredDescription": MessageLookupByLibrary.simpleMessage(
      "应用锁配置不完整，请重新登录后在我的页面设置。",
    ),
    "appLockSubtitle": MessageLookupByLibrary.simpleMessage("请选择一种方式解锁"),
    "appLockTitle": MessageLookupByLibrary.simpleMessage("好记已锁定"),
    "appLockUnlock": MessageLookupByLibrary.simpleMessage("验证身份"),
    "appLockUnlockCta": MessageLookupByLibrary.simpleMessage("解锁"),
    "appLockUseBiometrics": MessageLookupByLibrary.simpleMessage("使用生物识别"),
    "appLockUseFace": MessageLookupByLibrary.simpleMessage("使用面容解锁"),
    "appLockUseFingerprint": MessageLookupByLibrary.simpleMessage("使用指纹解锁"),
    "appLockVerify": MessageLookupByLibrary.simpleMessage("验证"),
    "appTitle": MessageLookupByLibrary.simpleMessage("好记"),
    "authenticate": MessageLookupByLibrary.simpleMessage("鉴权"),
    "base64ImageEmpty": MessageLookupByLibrary.simpleMessage("图片数据为空"),
    "base64ImageInvalid": MessageLookupByLibrary.simpleMessage("图片解析失败"),
    "baseUrlConfig": MessageLookupByLibrary.simpleMessage("基础 URL 配置"),
    "billEditorAccount": MessageLookupByLibrary.simpleMessage("账户"),
    "billEditorAddAttachment": MessageLookupByLibrary.simpleMessage("添加附件"),
    "billEditorAddCategory": MessageLookupByLibrary.simpleMessage("添加分类"),
    "billEditorAddExtra": MessageLookupByLibrary.simpleMessage("添加手续费/优惠"),
    "billEditorAddTags": MessageLookupByLibrary.simpleMessage("添加标签"),
    "billEditorAmountHint": MessageLookupByLibrary.simpleMessage("金额按下方分类拆分累加"),
    "billEditorAmountOf": m12,
    "billEditorAttachmentInvalid": MessageLookupByLibrary.simpleMessage(
      "部分附件不可读取或超出大小限制",
    ),
    "billEditorAttachmentPermissionRequired":
        MessageLookupByLibrary.simpleMessage("应用缺少文件访问权限，请更新应用或联系管理员"),
    "billEditorAttachmentPickFailed": MessageLookupByLibrary.simpleMessage(
      "选择附件失败，请重试",
    ),
    "billEditorAttachmentPluginUnavailable":
        MessageLookupByLibrary.simpleMessage("附件组件未正确加载，请重启应用后重试"),
    "billEditorAttachmentUnreadable": MessageLookupByLibrary.simpleMessage(
      "附件不可读取，请重新选择后重试",
    ),
    "billEditorAttachments": MessageLookupByLibrary.simpleMessage("附件"),
    "billEditorCategorySplit": MessageLookupByLibrary.simpleMessage("分类拆分"),
    "billEditorChooseFile": MessageLookupByLibrary.simpleMessage("选择文件"),
    "billEditorChoosePhoto": MessageLookupByLibrary.simpleMessage("选择照片"),
    "billEditorConfirmed": MessageLookupByLibrary.simpleMessage("已确认"),
    "billEditorConfirmedSubtitle": MessageLookupByLibrary.simpleMessage(
      "未确认账单不计入余额",
    ),
    "billEditorDiscardConfirm": MessageLookupByLibrary.simpleMessage("丢弃"),
    "billEditorDiscardMessage": MessageLookupByLibrary.simpleMessage(
      "已填写的内容将丢失，此操作无法撤销。",
    ),
    "billEditorDiscardTitle": MessageLookupByLibrary.simpleMessage("丢弃修改？"),
    "billEditorDiscount": MessageLookupByLibrary.simpleMessage("优惠"),
    "billEditorEditTitle": MessageLookupByLibrary.simpleMessage("编辑账单"),
    "billEditorExtraCategory": MessageLookupByLibrary.simpleMessage("所属分类"),
    "billEditorExtraCategoryRequired": MessageLookupByLibrary.simpleMessage(
      "请先添加或选择分类后再添加附加费用",
    ),
    "billEditorExtraRemark": MessageLookupByLibrary.simpleMessage("说明"),
    "billEditorExtraRemarkHint": MessageLookupByLibrary.simpleMessage(
      "如：跨行转账手续费",
    ),
    "billEditorExtras": MessageLookupByLibrary.simpleMessage("附加费用"),
    "billEditorFee": MessageLookupByLibrary.simpleMessage("手续费"),
    "billEditorInclude": MessageLookupByLibrary.simpleMessage("计入统计"),
    "billEditorIncludeSubtitle": MessageLookupByLibrary.simpleMessage(
      "关闭后不参与收支统计",
    ),
    "billEditorItemCount": m13,
    "billEditorMembers": MessageLookupByLibrary.simpleMessage("成员"),
    "billEditorNewTitle": MessageLookupByLibrary.simpleMessage("记一笔"),
    "billEditorNoOptions": MessageLookupByLibrary.simpleMessage("暂无可选项"),
    "billEditorNoSelection": MessageLookupByLibrary.simpleMessage("不选择"),
    "billEditorOptional": MessageLookupByLibrary.simpleMessage("可选"),
    "billEditorOrder": MessageLookupByLibrary.simpleMessage("关联报销单"),
    "billEditorPayee": MessageLookupByLibrary.simpleMessage("交易对象"),
    "billEditorRemark": MessageLookupByLibrary.simpleMessage("备注"),
    "billEditorRemarkHint": MessageLookupByLibrary.simpleMessage("添加备注…"),
    "billEditorRequired": MessageLookupByLibrary.simpleMessage("必选"),
    "billEditorSaveEdit": MessageLookupByLibrary.simpleMessage("保存修改"),
    "billEditorSaveNew": MessageLookupByLibrary.simpleMessage("保存账单"),
    "billEditorSelectAccount": MessageLookupByLibrary.simpleMessage("选择账户"),
    "billEditorSelectAccountHint": MessageLookupByLibrary.simpleMessage(
      "请选择账户",
    ),
    "billEditorSelectBookFirst": MessageLookupByLibrary.simpleMessage(
      "请先选择一个账本后再记账",
    ),
    "billEditorSelectCategory": MessageLookupByLibrary.simpleMessage("选择分类"),
    "billEditorSelectExtraCategory": MessageLookupByLibrary.simpleMessage(
      "选择所属分类",
    ),
    "billEditorSelectHint": MessageLookupByLibrary.simpleMessage("请选择"),
    "billEditorSelectMembers": MessageLookupByLibrary.simpleMessage("选择成员"),
    "billEditorSelectOrder": MessageLookupByLibrary.simpleMessage("选择使用中的报销单"),
    "billEditorSelectPayee": MessageLookupByLibrary.simpleMessage("选择交易对象"),
    "billEditorSelectTags": MessageLookupByLibrary.simpleMessage("选择标签"),
    "billEditorSelectTransferIn": MessageLookupByLibrary.simpleMessage(
      "选择转入账户",
    ),
    "billEditorSelectTransferInHint": MessageLookupByLibrary.simpleMessage(
      "请选择转入账户",
    ),
    "billEditorSelectTransferOut": MessageLookupByLibrary.simpleMessage(
      "选择转出账户",
    ),
    "billEditorSelectTransferOutHint": MessageLookupByLibrary.simpleMessage(
      "请选择转出账户",
    ),
    "billEditorSelectedCount": m14,
    "billEditorSubmitAuthFailed": MessageLookupByLibrary.simpleMessage(
      "登录已失效，请重新登录后重试",
    ),
    "billEditorSubmitNetworkFailed": MessageLookupByLibrary.simpleMessage(
      "网络异常，请检查网络后重试",
    ),
    "billEditorTags": MessageLookupByLibrary.simpleMessage("标签"),
    "billEditorTime": MessageLookupByLibrary.simpleMessage("时间"),
    "billEditorTitle": MessageLookupByLibrary.simpleMessage("标题"),
    "billEditorTitleDefault": m15,
    "billEditorTitleHint": MessageLookupByLibrary.simpleMessage("请输入标题"),
    "billEditorTradeTime": MessageLookupByLibrary.simpleMessage("交易时间"),
    "billEditorTransferAmount": MessageLookupByLibrary.simpleMessage("转账金额"),
    "billEditorTransferInAccount": MessageLookupByLibrary.simpleMessage("转入账户"),
    "billEditorTransferOutAccount": MessageLookupByLibrary.simpleMessage(
      "转出账户",
    ),
    "billEditorValidateAccount": MessageLookupByLibrary.simpleMessage("请选择账户"),
    "billEditorValidateAmount": MessageLookupByLibrary.simpleMessage("请输入金额"),
    "billEditorValidateCategoryAmount": MessageLookupByLibrary.simpleMessage(
      "分类金额不能为 0",
    ),
    "billEditorValidateCategoryRequired": MessageLookupByLibrary.simpleMessage(
      "请添加分类",
    ),
    "billEditorValidateCategorySelect": MessageLookupByLibrary.simpleMessage(
      "请选择分类",
    ),
    "billEditorValidateExtraCategory": MessageLookupByLibrary.simpleMessage(
      "请为每条附加费用选择所属分类",
    ),
    "billEditorValidateExtraCategoryInSplit":
        MessageLookupByLibrary.simpleMessage("附加费用的所属分类不在当前分类拆分中"),
    "billEditorValidateOrder": MessageLookupByLibrary.simpleMessage("请选择关联报销单"),
    "billEditorValidateTitle": MessageLookupByLibrary.simpleMessage("请填写标题"),
    "billEditorValidateTransferAmount": MessageLookupByLibrary.simpleMessage(
      "转账金额不能为 0",
    ),
    "billEditorValidateTransferExtraAccountSide":
        MessageLookupByLibrary.simpleMessage("附加费用的账户方向无效"),
    "billEditorValidateTransferFrom": MessageLookupByLibrary.simpleMessage(
      "请选择转出账户",
    ),
    "billEditorValidateTransferSame": MessageLookupByLibrary.simpleMessage(
      "转出与转入账户不能相同",
    ),
    "billEditorValidateTransferTo": MessageLookupByLibrary.simpleMessage(
      "请选择转入账户",
    ),
    "billEditorValidateWriteOffReason": MessageLookupByLibrary.simpleMessage(
      "请填写差额结清原因",
    ),
    "billEditorWriteOffAccount": MessageLookupByLibrary.simpleMessage("非现金调整"),
    "billGroupClassic": MessageLookupByLibrary.simpleMessage("记账"),
    "billTypeAdjust": MessageLookupByLibrary.simpleMessage("余额调整"),
    "billTypeAdvance": MessageLookupByLibrary.simpleMessage("垫付"),
    "billTypeExpense": MessageLookupByLibrary.simpleMessage("支出"),
    "billTypeFallback": MessageLookupByLibrary.simpleMessage("账单"),
    "billTypeIncome": MessageLookupByLibrary.simpleMessage("收入"),
    "billTypeLoanIn": MessageLookupByLibrary.simpleMessage("借入"),
    "billTypeLoanOut": MessageLookupByLibrary.simpleMessage("借出"),
    "billTypeLoanRecover": MessageLookupByLibrary.simpleMessage("收回本金"),
    "billTypeLoanRepay": MessageLookupByLibrary.simpleMessage("归还本金"),
    "billTypeReimburse": MessageLookupByLibrary.simpleMessage("报销到账"),
    "billTypeTransfer": MessageLookupByLibrary.simpleMessage("转账"),
    "billsApply": MessageLookupByLibrary.simpleMessage("应用"),
    "billsAttachments": MessageLookupByLibrary.simpleMessage("附件"),
    "billsBalance": MessageLookupByLibrary.simpleMessage("结余"),
    "billsBillDefaultTitle": MessageLookupByLibrary.simpleMessage("账单"),
    "billsBillingCycle": m16,
    "billsCategoryDetail": MessageLookupByLibrary.simpleMessage("分类明细"),
    "billsCharge": MessageLookupByLibrary.simpleMessage("费用"),
    "billsClose": MessageLookupByLibrary.simpleMessage("关闭"),
    "billsCopy": MessageLookupByLibrary.simpleMessage("复制"),
    "billsDayExpense": m17,
    "billsDayIncome": m18,
    "billsDelete": MessageLookupByLibrary.simpleMessage("删除"),
    "billsDeleteConfirm": m19,
    "billsDeleteTitle": MessageLookupByLibrary.simpleMessage("删除账单"),
    "billsDetailTitle": MessageLookupByLibrary.simpleMessage("账单详情"),
    "billsDiscount": MessageLookupByLibrary.simpleMessage("优惠"),
    "billsEdit": MessageLookupByLibrary.simpleMessage("编辑"),
    "billsEmpty": MessageLookupByLibrary.simpleMessage("本账期暂无账单"),
    "billsExpense": MessageLookupByLibrary.simpleMessage("支出"),
    "billsExtraWithSide": m20,
    "billsExtras": MessageLookupByLibrary.simpleMessage("附加费用"),
    "billsFee": MessageLookupByLibrary.simpleMessage("手续费"),
    "billsFilterAmountRange": MessageLookupByLibrary.simpleMessage("金额区间"),
    "billsFilterAny": MessageLookupByLibrary.simpleMessage("不限"),
    "billsFilterBillType": MessageLookupByLibrary.simpleMessage("账单类型"),
    "billsFilterByTitle": MessageLookupByLibrary.simpleMessage("标题"),
    "billsFilterConfirmStatus": MessageLookupByLibrary.simpleMessage("确认状态"),
    "billsFilterConfirmed": MessageLookupByLibrary.simpleMessage("已确认"),
    "billsFilterExcluded": MessageLookupByLibrary.simpleMessage("不计入"),
    "billsFilterIncludeStatus": MessageLookupByLibrary.simpleMessage("是否统计"),
    "billsFilterIncluded": MessageLookupByLibrary.simpleMessage("计入统计"),
    "billsFilterMax": MessageLookupByLibrary.simpleMessage("最大"),
    "billsFilterMin": MessageLookupByLibrary.simpleMessage("最小"),
    "billsFilterTitle": MessageLookupByLibrary.simpleMessage("筛选"),
    "billsFilterTitleHint": MessageLookupByLibrary.simpleMessage("输入标题关键词搜索"),
    "billsFilterUnconfirmed": MessageLookupByLibrary.simpleMessage("未确认"),
    "billsIncome": MessageLookupByLibrary.simpleMessage("收入"),
    "billsMembers": MessageLookupByLibrary.simpleMessage("成员"),
    "billsNoAttachments": MessageLookupByLibrary.simpleMessage("无附件"),
    "billsPayee": MessageLookupByLibrary.simpleMessage("交易对象"),
    "billsPendingConfirm": MessageLookupByLibrary.simpleMessage("待确认"),
    "billsReceivedAmount": MessageLookupByLibrary.simpleMessage("到账金额"),
    "billsRemark": MessageLookupByLibrary.simpleMessage("备注"),
    "billsReset": MessageLookupByLibrary.simpleMessage("重置"),
    "billsSelectBookFirst": MessageLookupByLibrary.simpleMessage("请先选择账本"),
    "billsSideIn": MessageLookupByLibrary.simpleMessage("转入"),
    "billsSideOut": MessageLookupByLibrary.simpleMessage("转出"),
    "billsTags": MessageLookupByLibrary.simpleMessage("标签"),
    "billsTransferInAccount": MessageLookupByLibrary.simpleMessage("转入账户"),
    "billsTransferOutAccount": MessageLookupByLibrary.simpleMessage("转出账户"),
    "billsUncategorized": MessageLookupByLibrary.simpleMessage("未分类"),
    "billsUnconfirm": MessageLookupByLibrary.simpleMessage("取消确认"),
    "billsWeekdayFri": MessageLookupByLibrary.simpleMessage("周五"),
    "billsWeekdayMon": MessageLookupByLibrary.simpleMessage("周一"),
    "billsWeekdaySat": MessageLookupByLibrary.simpleMessage("周六"),
    "billsWeekdaySun": MessageLookupByLibrary.simpleMessage("周日"),
    "billsWeekdayThu": MessageLookupByLibrary.simpleMessage("周四"),
    "billsWeekdayTue": MessageLookupByLibrary.simpleMessage("周二"),
    "billsWeekdayWed": MessageLookupByLibrary.simpleMessage("周三"),
    "booksActiveSegment": MessageLookupByLibrary.simpleMessage("在用"),
    "booksAddBook": MessageLookupByLibrary.simpleMessage("新增账本"),
    "booksAddGroup": MessageLookupByLibrary.simpleMessage("新增分组"),
    "booksAdjustRoleHint": MessageLookupByLibrary.simpleMessage(
      "如需调整角色，请移除后重新邀请。",
    ),
    "booksAlreadyDefaultBook": MessageLookupByLibrary.simpleMessage(
      "该账本已是默认账本",
    ),
    "booksAlreadyDefaultGroup": MessageLookupByLibrary.simpleMessage(
      "该分组已是默认分组",
    ),
    "booksBelongGroup": MessageLookupByLibrary.simpleMessage("所属分组"),
    "booksBookAlreadyDisabled": MessageLookupByLibrary.simpleMessage("该账本已停用"),
    "booksBookAlreadyEnabled": MessageLookupByLibrary.simpleMessage("该账本已启用"),
    "booksBookCreated": MessageLookupByLibrary.simpleMessage("账本已创建"),
    "booksBookDetailTitle": MessageLookupByLibrary.simpleMessage("账本详情"),
    "booksBookFallbackName": MessageLookupByLibrary.simpleMessage("该账本"),
    "booksBookName": MessageLookupByLibrary.simpleMessage("账本名称"),
    "booksBookNameHint": MessageLookupByLibrary.simpleMessage("如：日常开销"),
    "booksBookNameRequired": MessageLookupByLibrary.simpleMessage("请输入账本名称"),
    "booksBookOverview": MessageLookupByLibrary.simpleMessage("账本概览"),
    "booksBookSaved": MessageLookupByLibrary.simpleMessage("账本已保存"),
    "booksBookSearchHint": MessageLookupByLibrary.simpleMessage("搜索账本名称 / 备注"),
    "booksBookTemplateOptional": MessageLookupByLibrary.simpleMessage(
      "账本模板（可选）",
    ),
    "booksCannotRemoveOnlyOwner": MessageLookupByLibrary.simpleMessage(
      "不能移除唯一管理员",
    ),
    "booksCannotRemoveSelf": MessageLookupByLibrary.simpleMessage("不能移除自己"),
    "booksClearSelection": MessageLookupByLibrary.simpleMessage("清除选择"),
    "booksConfirmObjectHint": m21,
    "booksCreateBook": MessageLookupByLibrary.simpleMessage("创建账本"),
    "booksCreateGroup": MessageLookupByLibrary.simpleMessage("创建分组"),
    "booksCreateGroupFirst": MessageLookupByLibrary.simpleMessage("请先创建分组"),
    "booksCurrencyRequired": MessageLookupByLibrary.simpleMessage("请选择默认币种"),
    "booksCurrent": MessageLookupByLibrary.simpleMessage("当前"),
    "booksCurrentAt": m22,
    "booksCurrentUsingTag": MessageLookupByLibrary.simpleMessage("当前使用"),
    "booksDefaultAccountMissing": MessageLookupByLibrary.simpleMessage(
      "默认账户未完整设置，点击补全",
    ),
    "booksDefaultAccountSettings": MessageLookupByLibrary.simpleMessage(
      "默认账户设置",
    ),
    "booksDefaultBook": m23,
    "booksDefaultBookTag": MessageLookupByLibrary.simpleMessage("默认账本"),
    "booksDefaultBookUpdated": MessageLookupByLibrary.simpleMessage("默认账本已更新"),
    "booksDefaultCurrency": MessageLookupByLibrary.simpleMessage("默认币种"),
    "booksDefaultDestructiveCheckbox": MessageLookupByLibrary.simpleMessage(
      "我理解该操作不可恢复，仍要继续",
    ),
    "booksDefaultExpenseAccount": MessageLookupByLibrary.simpleMessage(
      "默认支出账户",
    ),
    "booksDefaultExpenseAccountValue": m24,
    "booksDefaultGroupTag": MessageLookupByLibrary.simpleMessage("默认分组"),
    "booksDefaultIncomeAccount": MessageLookupByLibrary.simpleMessage("默认收入账户"),
    "booksDefaultTag": MessageLookupByLibrary.simpleMessage("默认"),
    "booksDefaultTransferInAccount": MessageLookupByLibrary.simpleMessage(
      "默认转入账户",
    ),
    "booksDefaultTransferOutAccount": MessageLookupByLibrary.simpleMessage(
      "默认转出账户",
    ),
    "booksDelete": MessageLookupByLibrary.simpleMessage("删除"),
    "booksDeleteBookForeverTitle": m25,
    "booksDeleteBookWarning": MessageLookupByLibrary.simpleMessage(
      "此操作不可恢复。删除前请确认当前分组仍保留至少一个在用启用账本。",
    ),
    "booksDeleteForever": MessageLookupByLibrary.simpleMessage("彻底删除"),
    "booksDeleteGroupForever": MessageLookupByLibrary.simpleMessage("永久删除分组"),
    "booksDeleteGroupTitle": m26,
    "booksDeleteGroupUnderstand": MessageLookupByLibrary.simpleMessage(
      "我理解无法预览数量，仍要删除",
    ),
    "booksDeleteGroupWarning": MessageLookupByLibrary.simpleMessage(
      "此操作不可恢复，会删除账本、账户、分类、标签、交易对象、成员关系、全部账单记录与照片。当前版本无法预览具体数量。",
    ),
    "booksDisable": MessageLookupByLibrary.simpleMessage("停用"),
    "booksDisabled": MessageLookupByLibrary.simpleMessage("已停用"),
    "booksEdit": MessageLookupByLibrary.simpleMessage("编辑"),
    "booksEditBook": MessageLookupByLibrary.simpleMessage("编辑账本"),
    "booksEditGroup": MessageLookupByLibrary.simpleMessage("编辑分组"),
    "booksEmptyBooks": MessageLookupByLibrary.simpleMessage(
      "该分组暂无账本，点击右上角 + 新增",
    ),
    "booksEmptyGroups": MessageLookupByLibrary.simpleMessage("暂无分组，点击右上角 + 新增"),
    "booksEnable": MessageLookupByLibrary.simpleMessage("启用"),
    "booksEnableBookBeforeDefault": MessageLookupByLibrary.simpleMessage(
      "请先启用该账本再设为默认",
    ),
    "booksEnableGroupBeforeCreateBook": MessageLookupByLibrary.simpleMessage(
      "启用分组后可新建账本",
    ),
    "booksEnableGroupFirst": MessageLookupByLibrary.simpleMessage("请先启用该分组"),
    "booksEnabled": MessageLookupByLibrary.simpleMessage("启用"),
    "booksFilterAll": MessageLookupByLibrary.simpleMessage("全部"),
    "booksFilterDisabled": MessageLookupByLibrary.simpleMessage("已停用"),
    "booksFilterEnabled": MessageLookupByLibrary.simpleMessage("启用中"),
    "booksGroupAlreadyDisabled": MessageLookupByLibrary.simpleMessage("该分组已停用"),
    "booksGroupAlreadyEnabled": MessageLookupByLibrary.simpleMessage("该分组已启用"),
    "booksGroupCreated": MessageLookupByLibrary.simpleMessage("分组已创建"),
    "booksGroupDetailTitle": MessageLookupByLibrary.simpleMessage("分组详情"),
    "booksGroupDisabledReadonly": MessageLookupByLibrary.simpleMessage(
      "该分组已停用，仅可查看历史账本；启用分组后可编辑。",
    ),
    "booksGroupDisabledViewOnly": MessageLookupByLibrary.simpleMessage(
      "已停用 · 仅可查看",
    ),
    "booksGroupName": MessageLookupByLibrary.simpleMessage("分组名称"),
    "booksGroupNameHint": MessageLookupByLibrary.simpleMessage("如：家庭账"),
    "booksGroupNameRequired": MessageLookupByLibrary.simpleMessage("请输入分组名称"),
    "booksGroupNoAvailableBook": MessageLookupByLibrary.simpleMessage(
      "该分组暂无可用账本，请先新建或启用账本",
    ),
    "booksGroupNoBooks": MessageLookupByLibrary.simpleMessage("该分组暂无账本"),
    "booksGroupSaved": MessageLookupByLibrary.simpleMessage("分组已保存"),
    "booksGroupSearchHint": MessageLookupByLibrary.simpleMessage(
      "搜索分组名称 / 备注 / 币种",
    ),
    "booksHasMore": MessageLookupByLibrary.simpleMessage("还有更多"),
    "booksInfo": MessageLookupByLibrary.simpleMessage("信息"),
    "booksInvite": MessageLookupByLibrary.simpleMessage("邀请"),
    "booksInviteConfirmMessage": m27,
    "booksInviteConfirmTitle": MessageLookupByLibrary.simpleMessage("确认邀请"),
    "booksInviteHelp": MessageLookupByLibrary.simpleMessage(
      "请确认对方用户名完全一致。当前接口无法预览昵称或头像。",
    ),
    "booksInviteInputError": MessageLookupByLibrary.simpleMessage(
      "请输入用户名并选择角色",
    ),
    "booksInviteMembers": MessageLookupByLibrary.simpleMessage("邀请成员"),
    "booksInvitedUser": m28,
    "booksKeepOneEnabledGroup": MessageLookupByLibrary.simpleMessage(
      "至少保留一个启用分组",
    ),
    "booksManageAllBooksInTab": MessageLookupByLibrary.simpleMessage(
      "去账本 Tab 管理全部账本",
    ),
    "booksManageTitle": MessageLookupByLibrary.simpleMessage("分组与账本"),
    "booksMembersCount": m29,
    "booksMoveToRecycle": MessageLookupByLibrary.simpleMessage("移入回收站"),
    "booksNoBooks": MessageLookupByLibrary.simpleMessage("暂无账本"),
    "booksNoDefaultBook": MessageLookupByLibrary.simpleMessage("默认账本：未设置"),
    "booksNoEnabledAccounts": MessageLookupByLibrary.simpleMessage(
      "本分组暂无启用账户\n可先保存账本，稍后在账户管理中设置默认账户",
    ),
    "booksNoMatchingGroups": MessageLookupByLibrary.simpleMessage("暂无匹配分组"),
    "booksNoPermissionDeleteBook": MessageLookupByLibrary.simpleMessage(
      "你没有删除账本的权限",
    ),
    "booksNoPermissionDeleteGroup": MessageLookupByLibrary.simpleMessage(
      "你没有删除分组的权限",
    ),
    "booksNoPermissionMoveBook": MessageLookupByLibrary.simpleMessage(
      "你没有移动账本的权限",
    ),
    "booksNoPermissionRestoreBook": MessageLookupByLibrary.simpleMessage(
      "你没有恢复账本的权限",
    ),
    "booksNoPermissionSetDefaultBook": MessageLookupByLibrary.simpleMessage(
      "你没有设置默认账本的权限",
    ),
    "booksNoPermissionSetDefaultGroup": MessageLookupByLibrary.simpleMessage(
      "你没有设置默认分组的权限",
    ),
    "booksNoPermissionToggleBook": MessageLookupByLibrary.simpleMessage(
      "你没有启停账本的权限",
    ),
    "booksNoPermissionToggleGroup": MessageLookupByLibrary.simpleMessage(
      "你没有启停分组的权限",
    ),
    "booksNoRemark": MessageLookupByLibrary.simpleMessage("暂无备注"),
    "booksNone": MessageLookupByLibrary.simpleMessage("无"),
    "booksOnlyAvailableBook": MessageLookupByLibrary.simpleMessage(
      "这是当前分组唯一可用账本，请先新建或启用其他账本",
    ),
    "booksPermanentlyDelete": MessageLookupByLibrary.simpleMessage("永久删除"),
    "booksPutBack": MessageLookupByLibrary.simpleMessage("移出"),
    "booksRecycleBin": MessageLookupByLibrary.simpleMessage("回收站"),
    "booksRecycleCannotCreateBook": MessageLookupByLibrary.simpleMessage(
      "回收站中不可新建账本",
    ),
    "booksRecycleEmpty": MessageLookupByLibrary.simpleMessage("回收站为空"),
    "booksRemarkHint": MessageLookupByLibrary.simpleMessage("备注"),
    "booksRemarkOptional": MessageLookupByLibrary.simpleMessage("备注（可选）"),
    "booksRemarkValue": m30,
    "booksRemoveBookMessage": m31,
    "booksRemoveBookTitle": MessageLookupByLibrary.simpleMessage("彻底删除账本"),
    "booksRemoveGroupMessage": m32,
    "booksRemoveGroupTitle": MessageLookupByLibrary.simpleMessage("删除分组"),
    "booksRestoreBookFirst": MessageLookupByLibrary.simpleMessage("请先恢复该账本"),
    "booksRole": MessageLookupByLibrary.simpleMessage("角色"),
    "booksRoleActor": MessageLookupByLibrary.simpleMessage("协作者"),
    "booksRoleOwner": MessageLookupByLibrary.simpleMessage("管理员"),
    "booksRoleVisitor": MessageLookupByLibrary.simpleMessage("访客"),
    "booksSaveChanges": MessageLookupByLibrary.simpleMessage("保存修改"),
    "booksSelectGroup": MessageLookupByLibrary.simpleMessage("请选择分组"),
    "booksSelectGroupFirst": MessageLookupByLibrary.simpleMessage("请先选择分组"),
    "booksSendInvite": MessageLookupByLibrary.simpleMessage("发送邀请"),
    "booksSetDefaultBook": MessageLookupByLibrary.simpleMessage("设为默认账本"),
    "booksSetDefaultGroup": MessageLookupByLibrary.simpleMessage("设为默认分组"),
    "booksSetOtherDefaultBookFirst": MessageLookupByLibrary.simpleMessage(
      "请先设置其他账本为默认账本",
    ),
    "booksSetOtherDefaultGroupFirst": MessageLookupByLibrary.simpleMessage(
      "请先设置其他分组为默认分组",
    ),
    "booksSortHint": MessageLookupByLibrary.simpleMessage("数值越小越靠前"),
    "booksSortOptional": MessageLookupByLibrary.simpleMessage("排序（可选）"),
    "booksSortValue": m33,
    "booksSwitchGroup": MessageLookupByLibrary.simpleMessage("切换分组"),
    "booksSwitchedToGroup": m34,
    "booksTabBookShort": MessageLookupByLibrary.simpleMessage("账本"),
    "booksTabBooks": MessageLookupByLibrary.simpleMessage("账本管理"),
    "booksTabGroupShort": MessageLookupByLibrary.simpleMessage("分组"),
    "booksTabGroups": MessageLookupByLibrary.simpleMessage("分组管理"),
    "booksTapSwitchGroup": MessageLookupByLibrary.simpleMessage("点击切换管理分组"),
    "booksThisBook": MessageLookupByLibrary.simpleMessage("该账本"),
    "booksThisGroup": MessageLookupByLibrary.simpleMessage("该分组"),
    "booksUnknownRole": MessageLookupByLibrary.simpleMessage("角色未知"),
    "booksUnnamedAccount": MessageLookupByLibrary.simpleMessage("未命名账户"),
    "booksUnnamedBook": MessageLookupByLibrary.simpleMessage("未命名账本"),
    "booksUnnamedGroup": MessageLookupByLibrary.simpleMessage("未命名分组"),
    "booksUnnamedMember": MessageLookupByLibrary.simpleMessage("未知成员"),
    "booksUnsupportedAccount": m35,
    "booksUsername": MessageLookupByLibrary.simpleMessage("用户名"),
    "booksVisitorCannotCreateBook": MessageLookupByLibrary.simpleMessage(
      "访客无法新建账本",
    ),
    "booksVisitorCannotCreateGroup": MessageLookupByLibrary.simpleMessage(
      "访客无法新建分组",
    ),
    "booksVisitorViewGroupOnly": MessageLookupByLibrary.simpleMessage(
      "你是访客，仅可查看分组信息",
    ),
    "captchaRefresh": MessageLookupByLibrary.simpleMessage("刷新验证码"),
    "captchaRequired": MessageLookupByLibrary.simpleMessage("请输入图片中的验证码"),
    "captchaSubtitle": MessageLookupByLibrary.simpleMessage("完成安全校验后继续登录"),
    "captchaTitle": MessageLookupByLibrary.simpleMessage("请输入验证码"),
    "categoriesAdd": MessageLookupByLibrary.simpleMessage("新增分类"),
    "categoriesCreate": MessageLookupByLibrary.simpleMessage("创建分类"),
    "categoriesDelete": MessageLookupByLibrary.simpleMessage("删除"),
    "categoriesDeletePermanently": MessageLookupByLibrary.simpleMessage("彻底删除"),
    "categoriesDeletePermanentlyConfirm": m36,
    "categoriesEdit": MessageLookupByLibrary.simpleMessage("编辑分类"),
    "categoriesEmpty": MessageLookupByLibrary.simpleMessage("暂无分类，点击右上角 + 新增"),
    "categoriesEnable": MessageLookupByLibrary.simpleMessage("启用"),
    "categoriesExpenseSection": MessageLookupByLibrary.simpleMessage("支出分类"),
    "categoriesIncomeSection": MessageLookupByLibrary.simpleMessage("收入分类"),
    "categoriesMove": MessageLookupByLibrary.simpleMessage("移入"),
    "categoriesMoveToRecycleBin": MessageLookupByLibrary.simpleMessage("移入回收站"),
    "categoriesMoveToRecycleBinConfirm": m37,
    "categoriesNameHint": MessageLookupByLibrary.simpleMessage("如：餐饮"),
    "categoriesNameLabel": MessageLookupByLibrary.simpleMessage("分类名称"),
    "categoriesNameRequired": MessageLookupByLibrary.simpleMessage("请输入分类名称"),
    "categoriesParentLabel": MessageLookupByLibrary.simpleMessage("父级分类（可选）"),
    "categoriesParentNone": MessageLookupByLibrary.simpleMessage("无（顶级分类）"),
    "categoriesRemarkHint": MessageLookupByLibrary.simpleMessage("备注"),
    "categoriesRemarkLabel": MessageLookupByLibrary.simpleMessage("备注（可选）"),
    "categoriesSaveEdit": MessageLookupByLibrary.simpleMessage("保存修改"),
    "categoriesSearchHint": MessageLookupByLibrary.simpleMessage("搜索分类名称"),
    "categoriesSelectBookFirst": MessageLookupByLibrary.simpleMessage("请先选择账本"),
    "categoriesSortHint": MessageLookupByLibrary.simpleMessage("数字越小越靠前"),
    "categoriesSortLabel": MessageLookupByLibrary.simpleMessage("排序（可选）"),
    "categoriesThisCategory": MessageLookupByLibrary.simpleMessage("该分类"),
    "categoriesTitle": MessageLookupByLibrary.simpleMessage("分类管理"),
    "categoriesTypeExpense": MessageLookupByLibrary.simpleMessage("支出"),
    "categoriesTypeIncome": MessageLookupByLibrary.simpleMessage("收入"),
    "categoriesTypeLabel": MessageLookupByLibrary.simpleMessage("分类类型"),
    "categoriesUnnamed": MessageLookupByLibrary.simpleMessage("未命名"),
    "commonCancel": MessageLookupByLibrary.simpleMessage("取消"),
    "commonChinese": MessageLookupByLibrary.simpleMessage("中文"),
    "commonConfirm": MessageLookupByLibrary.simpleMessage("确定"),
    "commonEnglish": MessageLookupByLibrary.simpleMessage("English"),
    "commonFollowSystem": MessageLookupByLibrary.simpleMessage("跟随系统"),
    "commonHideAmounts": MessageLookupByLibrary.simpleMessage("隐藏金额"),
    "commonLanguage": MessageLookupByLibrary.simpleMessage("语言"),
    "commonMoreActions": MessageLookupByLibrary.simpleMessage("更多操作"),
    "commonPleaseSelect": MessageLookupByLibrary.simpleMessage("请选择"),
    "commonRetry": MessageLookupByLibrary.simpleMessage("重试"),
    "commonSave": MessageLookupByLibrary.simpleMessage("保存"),
    "commonShowAmounts": MessageLookupByLibrary.simpleMessage("显示金额"),
    "commonSystemBusy": MessageLookupByLibrary.simpleMessage("系统繁忙，请稍后重试"),
    "confirm": MessageLookupByLibrary.simpleMessage("确认"),
    "confirmDestructiveWarning": MessageLookupByLibrary.simpleMessage(
      "此操作不可撤销。",
    ),
    "dashboardAssets": MessageLookupByLibrary.simpleMessage("资产"),
    "dashboardAssetsLiabilities": MessageLookupByLibrary.simpleMessage("资产负债"),
    "dashboardBillFallback": MessageLookupByLibrary.simpleMessage("账单"),
    "dashboardDoneEditing": MessageLookupByLibrary.simpleMessage("完成"),
    "dashboardDragToReorder": MessageLookupByLibrary.simpleMessage(
      "长按卡片拖到另一张上，对方会被挤开让位；松手后保存。点右上角可移除",
    ),
    "dashboardEditLayout": MessageLookupByLibrary.simpleMessage("编辑布局"),
    "dashboardExpenseTrend": MessageLookupByLibrary.simpleMessage("支出趋势"),
    "dashboardHiddenCards": MessageLookupByLibrary.simpleMessage("可添加的卡片"),
    "dashboardIncomeExpenseTrend": MessageLookupByLibrary.simpleMessage("收支趋势"),
    "dashboardInsufficientData": MessageLookupByLibrary.simpleMessage("数据不足"),
    "dashboardLiabilities": MessageLookupByLibrary.simpleMessage("负债"),
    "dashboardLoadFailed": MessageLookupByLibrary.simpleMessage("加载失败"),
    "dashboardNetWorth": MessageLookupByLibrary.simpleMessage("净资产"),
    "dashboardNoBillsYet": MessageLookupByLibrary.simpleMessage("还没有账单"),
    "dashboardNoData": MessageLookupByLibrary.simpleMessage("暂无数据"),
    "dashboardNoRecordsYet": MessageLookupByLibrary.simpleMessage("还没有记录"),
    "dashboardNoVisibleCards": MessageLookupByLibrary.simpleMessage(
      "还没有展示的卡片，可点右上角编辑后添加",
    ),
    "dashboardPeriodExpense": MessageLookupByLibrary.simpleMessage("本账期支出"),
    "dashboardPeriodIncome": MessageLookupByLibrary.simpleMessage("本账期收入"),
    "dashboardPlaceCard": MessageLookupByLibrary.simpleMessage("放置"),
    "dashboardQuickAdd": MessageLookupByLibrary.simpleMessage("记一笔"),
    "dashboardRecentBills": MessageLookupByLibrary.simpleMessage("最近账单"),
    "dashboardRemoveCard": MessageLookupByLibrary.simpleMessage("移除卡片"),
    "dashboardResetLayout": MessageLookupByLibrary.simpleMessage("恢复默认布局"),
    "dashboardSelectBook": MessageLookupByLibrary.simpleMessage("选择账本"),
    "dashboardSelectBookFirst": MessageLookupByLibrary.simpleMessage(
      "请先选择一个账本",
    ),
    "dashboardSelectGroup": MessageLookupByLibrary.simpleMessage("选择分组"),
    "dashboardStartFirstBill": MessageLookupByLibrary.simpleMessage("开始记第一笔"),
    "dashboardTopCategories": MessageLookupByLibrary.simpleMessage(
      "本月支出分类 Top3",
    ),
    "dashboardUncategorized": MessageLookupByLibrary.simpleMessage("未分类"),
    "dashboardViewAll": MessageLookupByLibrary.simpleMessage("全部"),
    "default_comment": MessageLookupByLibrary.simpleMessage("敬请期待"),
    "developerPrefixUnlocked": MessageLookupByLibrary.simpleMessage(
      "已显示开发者设置：接口前缀（仅本次启动有效）",
    ),
    "domain": MessageLookupByLibrary.simpleMessage("域名"),
    "dont_worry_be_happy": MessageLookupByLibrary.simpleMessage("别难过，这种事经常发生。"),
    "editTodoAddAppBarTitle": MessageLookupByLibrary.simpleMessage("新建账单明细"),
    "editTodoDescriptionLabel": MessageLookupByLibrary.simpleMessage("描述"),
    "editTodoEditAppBarTitle": MessageLookupByLibrary.simpleMessage("修改账单明细"),
    "editTodoSaveButtonTooltip": MessageLookupByLibrary.simpleMessage("保存修改"),
    "editTodoTitleLabel": MessageLookupByLibrary.simpleMessage("标题"),
    "email_auth": MessageLookupByLibrary.simpleMessage("需要包含@，且用.com结尾"),
    "error": MessageLookupByLibrary.simpleMessage("错误"),
    "female": MessageLookupByLibrary.simpleMessage("女"),
    "fill_to_signup": MessageLookupByLibrary.simpleMessage("即将完成注册，请补充以下信息"),
    "forgot_huh": MessageLookupByLibrary.simpleMessage("你不会忘了密码吧？点我"),
    "fxClearLabel": MessageLookupByLibrary.simpleMessage("清空"),
    "fxConfirmFailure": MessageLookupByLibrary.simpleMessage("操作未完成，请重试"),
    "fxDatePickerDateTimeTitle": MessageLookupByLibrary.simpleMessage(
      "选择日期和时间",
    ),
    "fxDatePickerDateTitle": MessageLookupByLibrary.simpleMessage("选择日期"),
    "fxDatePickerDone": MessageLookupByLibrary.simpleMessage("完成"),
    "fxDatePickerNextYear": MessageLookupByLibrary.simpleMessage("下一年"),
    "fxDatePickerPreviousYear": MessageLookupByLibrary.simpleMessage("上一年"),
    "fxDatePickerStartOfMonth": MessageLookupByLibrary.simpleMessage("本月初"),
    "fxDatePickerToday": MessageLookupByLibrary.simpleMessage("今天"),
    "fxDatePickerYesterday": MessageLookupByLibrary.simpleMessage("昨天"),
    "fxDeleteLabel": MessageLookupByLibrary.simpleMessage("删除"),
    "fxDiscardChanges": MessageLookupByLibrary.simpleMessage("放弃修改"),
    "fxKeepEditing": MessageLookupByLibrary.simpleMessage("继续编辑"),
    "fxTreePickerClear": MessageLookupByLibrary.simpleMessage("清空"),
    "fxTreePickerCollapse": m38,
    "fxTreePickerConfirm": m39,
    "fxTreePickerDone": MessageLookupByLibrary.simpleMessage("完成"),
    "fxTreePickerExpand": m40,
    "fxTreePickerNoMatches": MessageLookupByLibrary.simpleMessage("无匹配项"),
    "fxTreePickerSearch": MessageLookupByLibrary.simpleMessage("搜索"),
    "fxTreePickerTitle": MessageLookupByLibrary.simpleMessage("选择"),
    "fxUnsavedChangesMessage": MessageLookupByLibrary.simpleMessage(
      "当前内容尚未保存，离开后本次修改将丢失。",
    ),
    "fxUnsavedChangesTitle": MessageLookupByLibrary.simpleMessage("放弃未保存的修改？"),
    "go_back": MessageLookupByLibrary.simpleMessage("返回"),
    "goodsAddTitle": MessageLookupByLibrary.simpleMessage("添加物品"),
    "goodsDailyAvg": m41,
    "goodsDaysValue": m42,
    "goodsDetailTitle": MessageLookupByLibrary.simpleMessage("物品详情"),
    "goodsEditTitle": MessageLookupByLibrary.simpleMessage("编辑物品"),
    "goodsEmptyCategory": MessageLookupByLibrary.simpleMessage("无分类"),
    "goodsEmptyHint": MessageLookupByLibrary.simpleMessage("暂无物品，点击右上角 + 添加"),
    "goodsEmptyTag": MessageLookupByLibrary.simpleMessage("无标签"),
    "goodsErrCategoryRequired": MessageLookupByLibrary.simpleMessage("请选择分类"),
    "goodsErrInvalidPrice": MessageLookupByLibrary.simpleMessage("请输入有效价格"),
    "goodsErrNameRequired": MessageLookupByLibrary.simpleMessage("请输入物品名称"),
    "goodsErrStatusRequired": MessageLookupByLibrary.simpleMessage("请选择物品状态"),
    "goodsFieldCategory": MessageLookupByLibrary.simpleMessage("分类"),
    "goodsFieldHoldingTime": MessageLookupByLibrary.simpleMessage("持有天数"),
    "goodsFieldProfit": MessageLookupByLibrary.simpleMessage("出售盈亏"),
    "goodsFieldPurchaseDate": MessageLookupByLibrary.simpleMessage("购买日期"),
    "goodsFieldRemark": MessageLookupByLibrary.simpleMessage("备注"),
    "goodsFieldRetiredDate": MessageLookupByLibrary.simpleMessage("退役日期"),
    "goodsFieldSoldPrice": MessageLookupByLibrary.simpleMessage("出售价格"),
    "goodsFieldStatus": MessageLookupByLibrary.simpleMessage("状态"),
    "goodsFieldTag": MessageLookupByLibrary.simpleMessage("标签"),
    "goodsFieldUsageCount": MessageLookupByLibrary.simpleMessage("使用次数"),
    "goodsFieldWarrantyDate": MessageLookupByLibrary.simpleMessage("保修日期"),
    "goodsFieldWarrantyStatus": MessageLookupByLibrary.simpleMessage("保修状态"),
    "goodsHintName": MessageLookupByLibrary.simpleMessage("如：iPhone 15"),
    "goodsHintUsageNum": MessageLookupByLibrary.simpleMessage("如：120"),
    "goodsHoldingDays": m43,
    "goodsLabelAttachOptional": MessageLookupByLibrary.simpleMessage("附件（可选）"),
    "goodsLabelCategoryOptional": MessageLookupByLibrary.simpleMessage("分类"),
    "goodsLabelName": MessageLookupByLibrary.simpleMessage("物品名称"),
    "goodsLabelPrice": MessageLookupByLibrary.simpleMessage("购买价格"),
    "goodsLabelRemarkOptional": MessageLookupByLibrary.simpleMessage("备注（可选）"),
    "goodsLabelTagOptional": MessageLookupByLibrary.simpleMessage("标签（可选）"),
    "goodsLabelWarrantyOptional": MessageLookupByLibrary.simpleMessage(
      "保修日期（可选）",
    ),
    "goodsMenuDelete": MessageLookupByLibrary.simpleMessage("删除"),
    "goodsMenuDetail": MessageLookupByLibrary.simpleMessage("查看详情"),
    "goodsMenuEdit": MessageLookupByLibrary.simpleMessage("编辑"),
    "goodsNoCategoryOptions": MessageLookupByLibrary.simpleMessage(
      "暂无分类，请先在分类管理中创建",
    ),
    "goodsNoOptions": m44,
    "goodsNone": MessageLookupByLibrary.simpleMessage("不选"),
    "goodsNotSet": MessageLookupByLibrary.simpleMessage("未设置"),
    "goodsPickDate": MessageLookupByLibrary.simpleMessage("选择日期"),
    "goodsRemoveConfirm": m45,
    "goodsRemoveTitle": MessageLookupByLibrary.simpleMessage("删除物品"),
    "goodsSaveChanges": MessageLookupByLibrary.simpleMessage("保存修改"),
    "goodsSectionBasic": MessageLookupByLibrary.simpleMessage("基础信息"),
    "goodsSectionCategoryTag": MessageLookupByLibrary.simpleMessage("分类与标签"),
    "goodsSectionDisposal": MessageLookupByLibrary.simpleMessage("处置"),
    "goodsSectionRemarkAttach": MessageLookupByLibrary.simpleMessage("备注与附件"),
    "goodsSectionWarrantyStatus": MessageLookupByLibrary.simpleMessage("保修与状态"),
    "goodsSelectBookFirst": MessageLookupByLibrary.simpleMessage("请先选择账本"),
    "goodsStatActiveCost": MessageLookupByLibrary.simpleMessage("在役成本"),
    "goodsStatAllCost": MessageLookupByLibrary.simpleMessage("全部成本"),
    "goodsStatDailyCost": MessageLookupByLibrary.simpleMessage("日均成本"),
    "goodsStatusUnrecognized": m46,
    "goodsThisItem": MessageLookupByLibrary.simpleMessage("该物品"),
    "goodsTitle": MessageLookupByLibrary.simpleMessage("归物"),
    "goodsUnknown": MessageLookupByLibrary.simpleMessage("未知"),
    "goodsUnnamed": MessageLookupByLibrary.simpleMessage("未命名"),
    "goodsUseByTimes": MessageLookupByLibrary.simpleMessage("按次使用"),
    "groupUsersEmpty": MessageLookupByLibrary.simpleMessage("该分组暂无成员"),
    "groupUsersInvite": MessageLookupByLibrary.simpleMessage("邀请"),
    "groupUsersInviteSent": MessageLookupByLibrary.simpleMessage("邀请已发送"),
    "groupUsersInviteTitle": MessageLookupByLibrary.simpleMessage("邀请用户"),
    "groupUsersRemove": MessageLookupByLibrary.simpleMessage("移除"),
    "groupUsersRemoveConfirm": m47,
    "groupUsersRemoveTitle": MessageLookupByLibrary.simpleMessage("移除成员"),
    "groupUsersRoleLabel": MessageLookupByLibrary.simpleMessage("角色"),
    "groupUsersRoleRequired": MessageLookupByLibrary.simpleMessage("请选择角色"),
    "groupUsersSelectGroupFirst": MessageLookupByLibrary.simpleMessage(
      "请先选择分组",
    ),
    "groupUsersSendInvite": MessageLookupByLibrary.simpleMessage("发送邀请"),
    "groupUsersTitle": MessageLookupByLibrary.simpleMessage("成员管理"),
    "groupUsersTitleWithName": m48,
    "groupUsersUsernameHint": MessageLookupByLibrary.simpleMessage(
      "输入被邀请人的用户名",
    ),
    "groupUsersUsernameLabel": MessageLookupByLibrary.simpleMessage("用户名"),
    "groupUsersUsernameRequired": MessageLookupByLibrary.simpleMessage(
      "请输入用户名",
    ),
    "help_me": MessageLookupByLibrary.simpleMessage("帮帮我"),
    "imageSaveDownloadFailed": MessageLookupByLibrary.simpleMessage("下载失败"),
    "imageSaveDownloadStarted": MessageLookupByLibrary.simpleMessage("已开始下载"),
    "imageSaveFailed": MessageLookupByLibrary.simpleMessage("保存失败，请重试"),
    "imageSaveSaving": MessageLookupByLibrary.simpleMessage("正在保存…"),
    "imageSaveSuccess": MessageLookupByLibrary.simpleMessage("已保存到相册"),
    "imageSaveUnsupported": MessageLookupByLibrary.simpleMessage(
      "当前平台暂不支持直接保存，请截图或使用下载方式",
    ),
    "invalidDomain": MessageLookupByLibrary.simpleMessage("无效的域名或IP地址"),
    "invalidPort": MessageLookupByLibrary.simpleMessage("无效的端口号"),
    "invalid_email": MessageLookupByLibrary.simpleMessage("无效的邮箱地址"),
    "invalid_phone_number": MessageLookupByLibrary.simpleMessage("无效的手机号码"),
    "ioDone": MessageLookupByLibrary.simpleMessage("完成"),
    "ioDownloadErrorDetails": MessageLookupByLibrary.simpleMessage("下载错误明细"),
    "ioDownloadFailed": MessageLookupByLibrary.simpleMessage("下载失败"),
    "ioDownloadStarted": m49,
    "ioDownloadTemplate": MessageLookupByLibrary.simpleMessage("下载模板"),
    "ioDownloadTemplateSubtitle": MessageLookupByLibrary.simpleMessage(
      "获取标准 Excel 模板，按格式填写后导入",
    ),
    "ioDownloadTemplateTitle": MessageLookupByLibrary.simpleMessage("下载导入模板"),
    "ioExport": MessageLookupByLibrary.simpleMessage("导出"),
    "ioExportBillsSubtitle": MessageLookupByLibrary.simpleMessage(
      "导出当前账本账单（含筛选，最大 10000 条）",
    ),
    "ioExportBillsTitle": MessageLookupByLibrary.simpleMessage("导出账单 Excel"),
    "ioExportFailedNoData": MessageLookupByLibrary.simpleMessage("导出失败：无数据"),
    "ioFail": MessageLookupByLibrary.simpleMessage("失败"),
    "ioImportBillsSubtitle": MessageLookupByLibrary.simpleMessage(
      "选择 .xlsx 文件上传，导入完成后展示结果",
    ),
    "ioImportBillsTitle": MessageLookupByLibrary.simpleMessage("导入账单 Excel"),
    "ioImportFailedWithErrors": MessageLookupByLibrary.simpleMessage(
      "导入失败，存在错误行。可下载错误明细 Excel 查看具体原因。",
    ),
    "ioImportResult": MessageLookupByLibrary.simpleMessage("导入结果"),
    "ioReadFileFailed": MessageLookupByLibrary.simpleMessage("读取文件失败"),
    "ioSavedTo": m50,
    "ioSelectBookFirst": MessageLookupByLibrary.simpleMessage("请先选择账本"),
    "ioSelectFileImport": MessageLookupByLibrary.simpleMessage("选择文件导入"),
    "ioSuccess": MessageLookupByLibrary.simpleMessage("成功"),
    "ioTitle": MessageLookupByLibrary.simpleMessage("导出"),
    "ioTotal": MessageLookupByLibrary.simpleMessage("共"),
    "login_account": MessageLookupByLibrary.simpleMessage("账号"),
    "login_button_text": MessageLookupByLibrary.simpleMessage("登录"),
    "login_confirm": MessageLookupByLibrary.simpleMessage("确认"),
    "login_email": MessageLookupByLibrary.simpleMessage("邮箱"),
    "login_host": MessageLookupByLibrary.simpleMessage("demo.fortuneboot.com"),
    "login_message": MessageLookupByLibrary.simpleMessage("你可以通过此界面注册/登录"),
    "login_nickname": MessageLookupByLibrary.simpleMessage("昵称"),
    "login_pass": MessageLookupByLibrary.simpleMessage("密码"),
    "logsBrowser": MessageLookupByLibrary.simpleMessage("浏览器"),
    "logsBusinessType": MessageLookupByLibrary.simpleMessage("操作类型"),
    "logsEmpty": MessageLookupByLibrary.simpleMessage("暂无日志"),
    "logsError": MessageLookupByLibrary.simpleMessage("错误信息"),
    "logsIp": MessageLookupByLibrary.simpleMessage("IP"),
    "logsLocation": MessageLookupByLibrary.simpleMessage("地点"),
    "logsLogin": MessageLookupByLibrary.simpleMessage("登录日志"),
    "logsMessage": MessageLookupByLibrary.simpleMessage("说明"),
    "logsMethod": MessageLookupByLibrary.simpleMessage("请求方法"),
    "logsModule": MessageLookupByLibrary.simpleMessage("模块"),
    "logsOperation": MessageLookupByLibrary.simpleMessage("操作日志"),
    "logsParam": MessageLookupByLibrary.simpleMessage("请求参数"),
    "logsResult": MessageLookupByLibrary.simpleMessage("返回结果"),
    "logsSearchHint": MessageLookupByLibrary.simpleMessage("按用户名搜索"),
    "logsStatus": MessageLookupByLibrary.simpleMessage("状态"),
    "logsSystem": MessageLookupByLibrary.simpleMessage("系统"),
    "logsTime": MessageLookupByLibrary.simpleMessage("时间"),
    "logsUrl": MessageLookupByLibrary.simpleMessage("请求地址"),
    "logsUsername": MessageLookupByLibrary.simpleMessage("用户名"),
    "main_logo": MessageLookupByLibrary.simpleMessage("好记"),
    "male": MessageLookupByLibrary.simpleMessage("男"),
    "manageSearchBranchResults": m51,
    "manageSharedDeleteForever": MessageLookupByLibrary.simpleMessage("彻底删除"),
    "manageSharedEdit": MessageLookupByLibrary.simpleMessage("编辑"),
    "manageSharedMoveToRecycleBin": MessageLookupByLibrary.simpleMessage(
      "移入回收站",
    ),
    "manageSharedPutBack": MessageLookupByLibrary.simpleMessage("移出回收站"),
    "manageSharedSearchHint": MessageLookupByLibrary.simpleMessage("搜索名称"),
    "manageSharedTabAll": MessageLookupByLibrary.simpleMessage("全部"),
    "manageSharedTabDisabled": MessageLookupByLibrary.simpleMessage("停用"),
    "manageSharedTabEnabled": MessageLookupByLibrary.simpleMessage("启用"),
    "manageSharedTabRecycleBin": MessageLookupByLibrary.simpleMessage("回收站"),
    "membersAdd": MessageLookupByLibrary.simpleMessage("新增成员"),
    "membersCreate": MessageLookupByLibrary.simpleMessage("创建成员"),
    "membersDelete": MessageLookupByLibrary.simpleMessage("删除"),
    "membersDeletePermanently": MessageLookupByLibrary.simpleMessage("彻底删除"),
    "membersDeletePermanentlyConfirm": m52,
    "membersEdit": MessageLookupByLibrary.simpleMessage("编辑成员"),
    "membersEmpty": MessageLookupByLibrary.simpleMessage("暂无成员，点击右上角 + 新增"),
    "membersEnable": MessageLookupByLibrary.simpleMessage("启用"),
    "membersMove": MessageLookupByLibrary.simpleMessage("移入"),
    "membersMoveToRecycleBin": MessageLookupByLibrary.simpleMessage("移入回收站"),
    "membersMoveToRecycleBinConfirm": m53,
    "membersNameHint": MessageLookupByLibrary.simpleMessage("如：张三"),
    "membersNameLabel": MessageLookupByLibrary.simpleMessage("成员名称"),
    "membersNameRequired": MessageLookupByLibrary.simpleMessage("请输入成员名称"),
    "membersRemarkHint": MessageLookupByLibrary.simpleMessage("备注"),
    "membersRemarkLabel": MessageLookupByLibrary.simpleMessage("备注（可选）"),
    "membersSaveEdit": MessageLookupByLibrary.simpleMessage("保存修改"),
    "membersSearchHint": MessageLookupByLibrary.simpleMessage("搜索成员名称"),
    "membersSelectBookFirst": MessageLookupByLibrary.simpleMessage("请先选择账本"),
    "membersSortHint": MessageLookupByLibrary.simpleMessage("数字越小越靠前"),
    "membersSortLabel": MessageLookupByLibrary.simpleMessage("排序（可选）"),
    "membersStatusDisabled": MessageLookupByLibrary.simpleMessage("停用"),
    "membersStatusEnabled": MessageLookupByLibrary.simpleMessage("启用"),
    "membersThisMember": MessageLookupByLibrary.simpleMessage("该成员"),
    "membersTitle": MessageLookupByLibrary.simpleMessage("成员管理"),
    "membersUnnamed": MessageLookupByLibrary.simpleMessage("未命名"),
    "mine": MessageLookupByLibrary.simpleMessage("我的"),
    "navBills": MessageLookupByLibrary.simpleMessage("账单"),
    "navDashboard": MessageLookupByLibrary.simpleMessage("仪表盘"),
    "navInDevelopment": MessageLookupByLibrary.simpleMessage("开发中"),
    "navProfile": MessageLookupByLibrary.simpleMessage("我的"),
    "navStats": MessageLookupByLibrary.simpleMessage("统计"),
    "nickname_required": MessageLookupByLibrary.simpleMessage("昵称不能为空"),
    "not_match": MessageLookupByLibrary.simpleMessage("不匹配！"),
    "oh_no": MessageLookupByLibrary.simpleMessage("我的天呐"),
    "ok": MessageLookupByLibrary.simpleMessage("确定"),
    "or_login_with": MessageLookupByLibrary.simpleMessage("通过其他方式登录"),
    "orderActionFee": MessageLookupByLibrary.simpleMessage("支付手续费"),
    "orderActionInterestIn": MessageLookupByLibrary.simpleMessage("收到利息"),
    "orderActionInterestOut": MessageLookupByLibrary.simpleMessage("支付利息"),
    "orderActionWriteOffPayable": MessageLookupByLibrary.simpleMessage(
      "对方免除还款",
    ),
    "orderActionWriteOffReceivable": MessageLookupByLibrary.simpleMessage(
      "确认无法收回",
    ),
    "orderActionWriteOffReimbursement": MessageLookupByLibrary.simpleMessage(
      "转为自付",
    ),
    "ordersActionAdvance": MessageLookupByLibrary.simpleMessage("记录垫付"),
    "ordersActionFee": MessageLookupByLibrary.simpleMessage("支付手续费"),
    "ordersActionInterestIn": MessageLookupByLibrary.simpleMessage("收到利息"),
    "ordersActionInterestOut": MessageLookupByLibrary.simpleMessage("支付利息"),
    "ordersActionLoanIn": MessageLookupByLibrary.simpleMessage("记录借入"),
    "ordersActionLoanOut": MessageLookupByLibrary.simpleMessage("记录借出"),
    "ordersActionLoanRecover": MessageLookupByLibrary.simpleMessage("收回本金"),
    "ordersActionLoanRepay": MessageLookupByLibrary.simpleMessage("归还本金"),
    "ordersActionReimburse": MessageLookupByLibrary.simpleMessage("报销到账"),
    "ordersActiveEntries": MessageLookupByLibrary.simpleMessage("有效流水"),
    "ordersAddTitle": MessageLookupByLibrary.simpleMessage("新增单据"),
    "ordersAdjustedAmount": MessageLookupByLibrary.simpleMessage("调整金额"),
    "ordersAllEntries": MessageLookupByLibrary.simpleMessage("全部流水"),
    "ordersAmountUnknown": MessageLookupByLibrary.simpleMessage("待核对"),
    "ordersArchive": MessageLookupByLibrary.simpleMessage("归档"),
    "ordersArchiveConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "归档后单据和流水只读，历史统计保留。",
    ),
    "ordersArchiveConfirmTitle": MessageLookupByLibrary.simpleMessage("确认归档？"),
    "ordersArchiveTooltip": MessageLookupByLibrary.simpleMessage(
      "归档后此订单不再算入统计",
    ),
    "ordersArchivedTime": m54,
    "ordersAuditTitle": MessageLookupByLibrary.simpleMessage("操作审计"),
    "ordersComponentFee": MessageLookupByLibrary.simpleMessage("手续费"),
    "ordersComponentInterest": MessageLookupByLibrary.simpleMessage("利息"),
    "ordersComponentPrincipal": MessageLookupByLibrary.simpleMessage("本金"),
    "ordersComponentUnknown": MessageLookupByLibrary.simpleMessage("普通流水"),
    "ordersComponentWriteOff": MessageLookupByLibrary.simpleMessage("差额结清"),
    "ordersContinueToEntry": MessageLookupByLibrary.simpleMessage("下一步，记一笔"),
    "ordersCounterparty": MessageLookupByLibrary.simpleMessage("交易对象"),
    "ordersCounterpartyHint": MessageLookupByLibrary.simpleMessage("选择对象或填写名称"),
    "ordersCounterpartyLockedReason": MessageLookupByLibrary.simpleMessage(
      "已有流水历史，对象不可更改",
    ),
    "ordersCounterpartyRequired": MessageLookupByLibrary.simpleMessage(
      "请填写交易对象",
    ),
    "ordersCreateOrder": MessageLookupByLibrary.simpleMessage("创建报销单"),
    "ordersDelete": MessageLookupByLibrary.simpleMessage("删除"),
    "ordersDeleteOnlyEmptyMessage": MessageLookupByLibrary.simpleMessage(
      "仅无任何流水历史的空单据可删除。",
    ),
    "ordersDueDateHint": MessageLookupByLibrary.simpleMessage("选择或清空日期"),
    "ordersDueDateOptional": MessageLookupByLibrary.simpleMessage("到期日（可选）"),
    "ordersEditEntry": MessageLookupByLibrary.simpleMessage("编辑流水"),
    "ordersEditMetadata": MessageLookupByLibrary.simpleMessage("编辑元数据"),
    "ordersEditTitle": m55,
    "ordersEmpty": MessageLookupByLibrary.simpleMessage("暂无单据，点击右上角 + 新增"),
    "ordersEntriesEmpty": MessageLookupByLibrary.simpleMessage("暂无流水"),
    "ordersFeeAmount": MessageLookupByLibrary.simpleMessage("手续费"),
    "ordersFilterEmpty": MessageLookupByLibrary.simpleMessage("没有符合当前筛选的单据"),
    "ordersInLabel": MessageLookupByLibrary.simpleMessage("转入 "),
    "ordersInterestExpense": MessageLookupByLibrary.simpleMessage("利息支出"),
    "ordersInterestIncome": MessageLookupByLibrary.simpleMessage("利息收入"),
    "ordersIssueCalculationInvalid": MessageLookupByLibrary.simpleMessage(
      "金额计算异常，需人工核对",
    ),
    "ordersIssueCashEffectUnknown": MessageLookupByLibrary.simpleMessage(
      "历史现金效果未知",
    ),
    "ordersIssueLegacyLoanIsolated": MessageLookupByLibrary.simpleMessage(
      "历史借贷流水孤立，需人工核对",
    ),
    "ordersIssuedAdvance": MessageLookupByLibrary.simpleMessage("累计垫付"),
    "ordersIssuedAmount": MessageLookupByLibrary.simpleMessage("形成金额"),
    "ordersIssuedLoanIn": MessageLookupByLibrary.simpleMessage("累计借入"),
    "ordersIssuedLoanOut": MessageLookupByLibrary.simpleMessage("累计借出"),
    "ordersLoadMore": MessageLookupByLibrary.simpleMessage("加载更多"),
    "ordersLoadMoreFailed": MessageLookupByLibrary.simpleMessage("加载更多失败，请重试"),
    "ordersMetricCount": m56,
    "ordersMoreActions": MessageLookupByLibrary.simpleMessage("更多操作"),
    "ordersOpenFocusedOrder": MessageLookupByLibrary.simpleMessage("打开该单据"),
    "ordersOrderTitle": MessageLookupByLibrary.simpleMessage("报销单标题"),
    "ordersOrphanLegacyCount": m57,
    "ordersOutLabel": MessageLookupByLibrary.simpleMessage("支出 "),
    "ordersOverdue": MessageLookupByLibrary.simpleMessage("逾期"),
    "ordersOverdueOnly": MessageLookupByLibrary.simpleMessage("仅逾期"),
    "ordersOverduePayable": MessageLookupByLibrary.simpleMessage("逾期待归还"),
    "ordersOverdueReceivable": MessageLookupByLibrary.simpleMessage("逾期待收回"),
    "ordersOverdueReimbursement": MessageLookupByLibrary.simpleMessage("逾期待报销"),
    "ordersPartiallySettled": MessageLookupByLibrary.simpleMessage("部分结清"),
    "ordersPendingConfirmation": MessageLookupByLibrary.simpleMessage("待确认"),
    "ordersPendingEntryCount": m58,
    "ordersPendingPayable": MessageLookupByLibrary.simpleMessage("待归还"),
    "ordersPendingReceivable": MessageLookupByLibrary.simpleMessage("待收回"),
    "ordersPendingReimbursement": MessageLookupByLibrary.simpleMessage("待报销"),
    "ordersReconciliationBillTitle": m59,
    "ordersReconciliationCandidatePending":
        MessageLookupByLibrary.simpleMessage("待核对余额"),
    "ordersReconciliationCashUnknown": MessageLookupByLibrary.simpleMessage(
      "现金影响未知",
    ),
    "ordersReconciliationEmpty": MessageLookupByLibrary.simpleMessage(
      "暂无历史核对明细。单据仍可能处于「待核对」，请打开单据详情核对流水。",
    ),
    "ordersReconciliationInAmount": MessageLookupByLibrary.simpleMessage("原收入"),
    "ordersReconciliationOrderTitle": m60,
    "ordersReconciliationOriginalIn": MessageLookupByLibrary.simpleMessage(
      "原收入",
    ),
    "ordersReconciliationOriginalOut": MessageLookupByLibrary.simpleMessage(
      "原支出",
    ),
    "ordersReconciliationOutAmount": MessageLookupByLibrary.simpleMessage(
      "原支出",
    ),
    "ordersReconciliationPendingAmount": MessageLookupByLibrary.simpleMessage(
      "待确认差额",
    ),
    "ordersReconciliationTitle": MessageLookupByLibrary.simpleMessage("历史核对报告"),
    "ordersReconciliationUnknownTitle": MessageLookupByLibrary.simpleMessage(
      "未关联单据",
    ),
    "ordersRemarkHint": MessageLookupByLibrary.simpleMessage("备注"),
    "ordersRemarkOptional": MessageLookupByLibrary.simpleMessage("备注（可选）"),
    "ordersRemoveMessage": m61,
    "ordersRemoveTitle": MessageLookupByLibrary.simpleMessage("删除报销单"),
    "ordersReopen": MessageLookupByLibrary.simpleMessage("重开"),
    "ordersReopenConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "重开后允许补录和纠错，不会回滚资金。",
    ),
    "ordersReopenConfirmTitle": MessageLookupByLibrary.simpleMessage("确认重开？"),
    "ordersRestore": MessageLookupByLibrary.simpleMessage("恢复"),
    "ordersRestoreConfirmMessage": MessageLookupByLibrary.simpleMessage(
      "恢复会按原确认状态重新生效，不是重新付款或银行撤款。",
    ),
    "ordersRestoreConfirmTitle": MessageLookupByLibrary.simpleMessage("确认恢复？"),
    "ordersReviewRequired": MessageLookupByLibrary.simpleMessage("待核对"),
    "ordersReviewRequiredCount": m62,
    "ordersReviewRequiredHint": MessageLookupByLibrary.simpleMessage(
      "该单据金额尚无法可靠计算，已从汇总中排除。请先查看核对报告，或补录/修正关联流水后再核对。",
    ),
    "ordersSaveChanges": MessageLookupByLibrary.simpleMessage("保存修改"),
    "ordersSaveDraft": MessageLookupByLibrary.simpleMessage("保存草稿"),
    "ordersSearchHint": MessageLookupByLibrary.simpleMessage("搜索标题 / 对象"),
    "ordersSelectBookFirst": MessageLookupByLibrary.simpleMessage("请先选择账本"),
    "ordersSettledAmount": MessageLookupByLibrary.simpleMessage("结算金额"),
    "ordersSettledRecovered": MessageLookupByLibrary.simpleMessage("已收回"),
    "ordersSettledReimbursed": MessageLookupByLibrary.simpleMessage("已到账"),
    "ordersSettledRepaid": MessageLookupByLibrary.simpleMessage("已归还"),
    "ordersSettledTag": MessageLookupByLibrary.simpleMessage("已结清"),
    "ordersStatusClosed": MessageLookupByLibrary.simpleMessage("已归档"),
    "ordersStatusDraft": MessageLookupByLibrary.simpleMessage("草稿"),
    "ordersStatusUnrecognized": MessageLookupByLibrary.simpleMessage(
      "该订单状态无法识别",
    ),
    "ordersStatusUsing": MessageLookupByLibrary.simpleMessage("进行中"),
    "ordersSubmitTime": m63,
    "ordersThisOrder": MessageLookupByLibrary.simpleMessage("该报销单"),
    "ordersTitle": MessageLookupByLibrary.simpleMessage("单据管理"),
    "ordersTitleHint": MessageLookupByLibrary.simpleMessage("如：8月差旅报销"),
    "ordersTitleOfType": m64,
    "ordersTitleRequired": MessageLookupByLibrary.simpleMessage("请输入单据标题"),
    "ordersType": MessageLookupByLibrary.simpleMessage("类型"),
    "ordersTypeLockedReason": MessageLookupByLibrary.simpleMessage(
      "单据类型创建后不可更改",
    ),
    "ordersTypePayable": MessageLookupByLibrary.simpleMessage("债务单"),
    "ordersTypeReceivable": MessageLookupByLibrary.simpleMessage("债权单"),
    "ordersTypeReimbursement": MessageLookupByLibrary.simpleMessage("报销单"),
    "ordersUnconfirm": MessageLookupByLibrary.simpleMessage("取消确认"),
    "ordersUnnamedOrder": MessageLookupByLibrary.simpleMessage("未命名报销单"),
    "ordersUse": MessageLookupByLibrary.simpleMessage("使用"),
    "ordersViewReconciliation": MessageLookupByLibrary.simpleMessage("核对报告"),
    "ordersVoid": MessageLookupByLibrary.simpleMessage("作废"),
    "ordersVoidCashRollback": m65,
    "ordersVoidConfirmTitle": MessageLookupByLibrary.simpleMessage("确认作废？"),
    "ordersVoidNoCashChange": MessageLookupByLibrary.simpleMessage(
      "作废后金额不再计入统计，但不会改变账户余额。",
    ),
    "ordersVoided": MessageLookupByLibrary.simpleMessage("已作废"),
    "ordersWriteOff": MessageLookupByLibrary.simpleMessage("差额结清"),
    "ordersWriteOffConfirmMessage": m66,
    "ordersWriteOffConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "确认差额结清？",
    ),
    "ordersWriteOffNoCashChange": MessageLookupByLibrary.simpleMessage(
      "这是非现金调整，不会再次改变账户余额。",
    ),
    "passwordPolicyHint": MessageLookupByLibrary.simpleMessage(
      "密码需为8-18位，包含字母、数字或特殊字符，且不能包含中文",
    ),
    "password_is_empty": MessageLookupByLibrary.simpleMessage("密码不能为空"),
    "password_rescued_successfully": MessageLookupByLibrary.simpleMessage(
      "密码重置成功",
    ),
    "payeesAdd": MessageLookupByLibrary.simpleMessage("新增交易对象"),
    "payeesCanExpenseShort": MessageLookupByLibrary.simpleMessage("可支"),
    "payeesCanIncomeShort": MessageLookupByLibrary.simpleMessage("可收"),
    "payeesCreate": MessageLookupByLibrary.simpleMessage("创建交易对象"),
    "payeesDelete": MessageLookupByLibrary.simpleMessage("删除"),
    "payeesDeletePermanently": MessageLookupByLibrary.simpleMessage("彻底删除"),
    "payeesDeletePermanentlyConfirm": m67,
    "payeesEdit": MessageLookupByLibrary.simpleMessage("编辑交易对象"),
    "payeesEmpty": MessageLookupByLibrary.simpleMessage("暂无交易对象，点击右上角 + 新增"),
    "payeesMove": MessageLookupByLibrary.simpleMessage("移入"),
    "payeesMoveToRecycleBin": MessageLookupByLibrary.simpleMessage("移入回收站"),
    "payeesMoveToRecycleBinConfirm": m68,
    "payeesNameHint": MessageLookupByLibrary.simpleMessage("如：肯德基"),
    "payeesNameLabel": MessageLookupByLibrary.simpleMessage("交易对象名称"),
    "payeesNameRequired": MessageLookupByLibrary.simpleMessage("请输入交易对象名称"),
    "payeesRemarkHint": MessageLookupByLibrary.simpleMessage("备注"),
    "payeesRemarkLabel": MessageLookupByLibrary.simpleMessage("备注（可选）"),
    "payeesSaveEdit": MessageLookupByLibrary.simpleMessage("保存修改"),
    "payeesSearchHint": MessageLookupByLibrary.simpleMessage("搜索交易对象名称"),
    "payeesSelectBookFirst": MessageLookupByLibrary.simpleMessage("请先选择账本"),
    "payeesSortHint": MessageLookupByLibrary.simpleMessage("数字越小越靠前"),
    "payeesSortLabel": MessageLookupByLibrary.simpleMessage("排序（可选）"),
    "payeesSortValue": m69,
    "payeesThisPayee": MessageLookupByLibrary.simpleMessage("该交易对象"),
    "payeesTitle": MessageLookupByLibrary.simpleMessage("交易对象"),
    "payeesUnnamed": MessageLookupByLibrary.simpleMessage("未命名"),
    "permissionVisitorNoAccess": MessageLookupByLibrary.simpleMessage(
      "你是访客，无权限访问",
    ),
    "phone_number": MessageLookupByLibrary.simpleMessage("手机号"),
    "pleaseEnterDomain": MessageLookupByLibrary.simpleMessage("请输入域名"),
    "pleaseEnterPort": MessageLookupByLibrary.simpleMessage("请输入端口"),
    "port": MessageLookupByLibrary.simpleMessage("端口"),
    "profileAbout": MessageLookupByLibrary.simpleMessage("关于"),
    "profileAboutApp": MessageLookupByLibrary.simpleMessage("关于好记"),
    "profileAccountManage": MessageLookupByLibrary.simpleMessage("账户管理"),
    "profileApiVersion": MessageLookupByLibrary.simpleMessage("API 版本"),
    "profileAppIcp": MessageLookupByLibrary.simpleMessage("App 备案"),
    "profileAppLock": MessageLookupByLibrary.simpleMessage("应用锁"),
    "profileAppLockEnableReason": MessageLookupByLibrary.simpleMessage(
      "验证身份以开启应用锁",
    ),
    "profileAppLockFailed": MessageLookupByLibrary.simpleMessage(
      "验证未通过，开关未打开。",
    ),
    "profileAppLockFingerprintHint": MessageLookupByLibrary.simpleMessage(
      "请按指纹传感器",
    ),
    "profileAppLockGestureAgain": MessageLookupByLibrary.simpleMessage(
      "请再画一次手势",
    ),
    "profileAppLockGestureHint": MessageLookupByLibrary.simpleMessage(
      "请连接至少 4 个点",
    ),
    "profileAppLockGestureMismatch": MessageLookupByLibrary.simpleMessage(
      "两次手势不一致，请重试",
    ),
    "profileAppLockGestureSetup": MessageLookupByLibrary.simpleMessage(
      "设置应用手势",
    ),
    "profileAppLockGestureUnlock": MessageLookupByLibrary.simpleMessage(
      "请绘制解锁手势",
    ),
    "profileAppLockGestureWrong": MessageLookupByLibrary.simpleMessage("手势不正确"),
    "profileAppLockMethod": MessageLookupByLibrary.simpleMessage("解锁方式"),
    "profileAppLockMethodFace": MessageLookupByLibrary.simpleMessage("面容"),
    "profileAppLockMethodFingerprint": MessageLookupByLibrary.simpleMessage(
      "指纹",
    ),
    "profileAppLockMethodGesture": MessageLookupByLibrary.simpleMessage(
      "自定义手势",
    ),
    "profileAppLockMethodPassword": MessageLookupByLibrary.simpleMessage(
      "自定义密码",
    ),
    "profileAppLockPasswordConfirm": MessageLookupByLibrary.simpleMessage(
      "再次输入密码",
    ),
    "profileAppLockPasswordMismatch": MessageLookupByLibrary.simpleMessage(
      "两次密码不一致",
    ),
    "profileAppLockPasswordSetup": MessageLookupByLibrary.simpleMessage(
      "设置应用密码",
    ),
    "profileAppLockPasswordTooShort": MessageLookupByLibrary.simpleMessage(
      "密码至少 4 位",
    ),
    "profileAppLockPasswordWrong": MessageLookupByLibrary.simpleMessage(
      "密码不正确",
    ),
    "profileAppLockPickMethod": MessageLookupByLibrary.simpleMessage("选择解锁方式"),
    "profileAppLockSubtitle": MessageLookupByLibrary.simpleMessage(
      "锁定后使用你选择的面容、指纹、自定义密码或自定义手势。",
    ),
    "profileAppLockUnavailable": MessageLookupByLibrary.simpleMessage(
      "请先设置自定义密码或手势；面容和指纹需系统已录入。",
    ),
    "profileAppVersion": MessageLookupByLibrary.simpleMessage("应用版本"),
    "profileAvatarUpdated": MessageLookupByLibrary.simpleMessage("头像已更新"),
    "profileBack": MessageLookupByLibrary.simpleMessage("返回个人中心"),
    "profileBillingManage": MessageLookupByLibrary.simpleMessage("记账管理"),
    "profileBookGroup": MessageLookupByLibrary.simpleMessage("账本与分组"),
    "profileBookManage": MessageLookupByLibrary.simpleMessage("账本管理"),
    "profileCategoryManage": MessageLookupByLibrary.simpleMessage("分类管理"),
    "profileChangePassword": MessageLookupByLibrary.simpleMessage("修改密码"),
    "profileColorAdjust": MessageLookupByLibrary.simpleMessage("调整"),
    "profileColorAdvance": MessageLookupByLibrary.simpleMessage("垫付"),
    "profileColorExpense": MessageLookupByLibrary.simpleMessage("支出"),
    "profileColorHoliday": MessageLookupByLibrary.simpleMessage("节假日"),
    "profileColorIncome": MessageLookupByLibrary.simpleMessage("收入"),
    "profileColorPresetDefault": MessageLookupByLibrary.simpleMessage("默认红绿"),
    "profileColorPresetDeuteranopia": MessageLookupByLibrary.simpleMessage(
      "红绿色盲友好",
    ),
    "profileColorPresetProtanopia": MessageLookupByLibrary.simpleMessage(
      "红色盲友好",
    ),
    "profileColorPresetTitle": MessageLookupByLibrary.simpleMessage("色盲友好预设"),
    "profileColorPresetTritanopia": MessageLookupByLibrary.simpleMessage(
      "蓝黄色盲友好",
    ),
    "profileColorReimburse": MessageLookupByLibrary.simpleMessage("报销"),
    "profileColorRest": MessageLookupByLibrary.simpleMessage("休"),
    "profileColorTransfer": MessageLookupByLibrary.simpleMessage("转账"),
    "profileColorWork": MessageLookupByLibrary.simpleMessage("班"),
    "profileConfirmChange": MessageLookupByLibrary.simpleMessage("确认修改"),
    "profileConfirmNewPassword": MessageLookupByLibrary.simpleMessage("确认新密码"),
    "profileCopyUsesCurrentTime": MessageLookupByLibrary.simpleMessage(
      "复制账单使用当前时间",
    ),
    "profileCopyUsesCurrentTimeSubtitle": MessageLookupByLibrary.simpleMessage(
      "关闭后，复制的新账单沿用原账单时间",
    ),
    "profileCurrencyRefresh": MessageLookupByLibrary.simpleMessage("汇率刷新"),
    "profileCurrencyRefreshFailed": m70,
    "profileCurrencyRefreshed": MessageLookupByLibrary.simpleMessage("汇率已刷新"),
    "profileCurrencyRefreshing": MessageLookupByLibrary.simpleMessage(
      "正在刷新汇率…",
    ),
    "profileCurrentGroupBook": MessageLookupByLibrary.simpleMessage("当前分组·账本"),
    "profileDeleteAccount": MessageLookupByLibrary.simpleMessage("注销账号"),
    "profileDeleteAccountConfirm": MessageLookupByLibrary.simpleMessage("确认注销"),
    "profileDeleteAccountFailed": MessageLookupByLibrary.simpleMessage(
      "注销失败，请稍后重试",
    ),
    "profileDeleteAccountHidePassword": MessageLookupByLibrary.simpleMessage(
      "隐藏密码",
    ),
    "profileDeleteAccountPasswordLabel": MessageLookupByLibrary.simpleMessage(
      "当前密码",
    ),
    "profileDeleteAccountPasswordRequired":
        MessageLookupByLibrary.simpleMessage("请输入当前密码"),
    "profileDeleteAccountShowPassword": MessageLookupByLibrary.simpleMessage(
      "显示密码",
    ),
    "profileDeleteAccountWarning": MessageLookupByLibrary.simpleMessage(
      "注销后账号无法恢复。仅本人使用的分组和账本数据将被删除；共享分组会保留给其他成员，管理员权限将移交给其他成员。",
    ),
    "profileDesktopWidget": MessageLookupByLibrary.simpleMessage("添加到桌面卡片"),
    "profileDesktopWidgetSubtitle": MessageLookupByLibrary.simpleMessage(
      "支持 6×4 统计收支日历，也可长按桌面空白处添加",
    ),
    "profileDetailedInformation": MessageLookupByLibrary.simpleMessage("详细信息"),
    "profileDetailsTitle": MessageLookupByLibrary.simpleMessage("个人资料"),
    "profileDonate": MessageLookupByLibrary.simpleMessage("捐赠"),
    "profileDonateAlipay": MessageLookupByLibrary.simpleMessage("支付宝"),
    "profileDonateContent": MessageLookupByLibrary.simpleMessage(
      "感谢你的支持！\n如愿意赞助开发，可通过项目主页获取捐赠方式。",
    ),
    "profileDonateIapStartFailed": MessageLookupByLibrary.simpleMessage(
      "无法发起捐赠，请稍后重试",
    ),
    "profileDonateIapUnavailable": MessageLookupByLibrary.simpleMessage(
      "暂无法获取捐赠项目，请稍后重试",
    ),
    "profileDonateScanHint": MessageLookupByLibrary.simpleMessage(
      "长按二维码保存到相册，或用另一台设备扫描二维码",
    ),
    "profileDonateThanks": MessageLookupByLibrary.simpleMessage("感谢支持！"),
    "profileDonateWechat": MessageLookupByLibrary.simpleMessage("微信"),
    "profileEditAvatar": MessageLookupByLibrary.simpleMessage("编辑头像"),
    "profileEditProfile": MessageLookupByLibrary.simpleMessage("编辑资料"),
    "profileEditTitle": MessageLookupByLibrary.simpleMessage("编辑资料"),
    "profileEmail": MessageLookupByLibrary.simpleMessage("邮箱"),
    "profileEmailHint": MessageLookupByLibrary.simpleMessage("请输入邮箱"),
    "profileFinanceColors": MessageLookupByLibrary.simpleMessage("账单颜色"),
    "profileFinanceColorsSubtitle": MessageLookupByLibrary.simpleMessage(
      "自定义收入 / 支出 / 节假日等语义颜色",
    ),
    "profileGoodsManage": MessageLookupByLibrary.simpleMessage("归物管理"),
    "profileGroupManage": MessageLookupByLibrary.simpleMessage("分组管理"),
    "profileHelp": MessageLookupByLibrary.simpleMessage("帮助"),
    "profileHelpBillsBody": MessageLookupByLibrary.simpleMessage(
      "账单页以账期为单位展示收支。顶部左右箭头可在相邻账期间切换，向下滚动会自动加载更早的账单。你可以在「我的 → 每月开始日」自定义账期起始日（例如每月 5 号），适配发薪日记账习惯。",
    ),
    "profileHelpBillsTitle": MessageLookupByLibrary.simpleMessage("账单与账期"),
    "profileHelpBookBody": MessageLookupByLibrary.simpleMessage(
      "分组用于隔离不同场景（如个人、家庭、公司），每个分组下可建立多个账本。在「我的 → 分组管理 / 账本管理」中新增、编辑、设为默认或停用；切换当前账本后，账单、统计、账户都会随之刷新。",
    ),
    "profileHelpBookTitle": MessageLookupByLibrary.simpleMessage("分组与账本"),
    "profileHelpContactBody": MessageLookupByLibrary.simpleMessage(
      "若遇到数据异常或功能疑问，请先尝试下拉刷新或重新登录；仍无法解决时，可联系分组管理员，或前往项目主页查阅文档与反馈问题。",
    ),
    "profileHelpContactTitle": MessageLookupByLibrary.simpleMessage("获取帮助"),
    "profileHelpContent": MessageLookupByLibrary.simpleMessage(
      "好记是一款多分组、多账本的记账应用。\n\n· 在首页快速记一笔，或在账单页查看明细。\n· 通过\"我的\"进入分类、标签、账户、成员等管理。\n· 遇到问题可联系管理员或查看项目文档。",
    ),
    "profileHelpIntro": MessageLookupByLibrary.simpleMessage(
      "好记是一款支持多分组、多账本协作的记账应用。下面是常见功能的使用说明，帮助你快速上手。",
    ),
    "profileHelpManageBody": MessageLookupByLibrary.simpleMessage(
      "分类、标签、交易对象、成员、账户均可独立管理。分类与标签支持树形层级；账户区分现金、信用卡、资产、贷款四类，并汇总净资产。停用或删除的项目会进入回收站，可随时还原。",
    ),
    "profileHelpManageTitle": MessageLookupByLibrary.simpleMessage("基础数据管理"),
    "profileHelpPrivacyBody": MessageLookupByLibrary.simpleMessage(
      "开启「隐藏金额」后，首页与账单中的金额会以圆点遮盖，适合在公共场合查看。你还可以自定义收入/支出等颜色，以及切换浅色/深色主题。",
    ),
    "profileHelpPrivacyTitle": MessageLookupByLibrary.simpleMessage("隐私与显示"),
    "profileHelpQuickBody": MessageLookupByLibrary.simpleMessage(
      "点击底部中间的蓝色「+」按钮即可记一笔。先填写标题，再在金额区选择分类并输入金额；支出、收入、转账、垫付、报销可通过顶部分段切换。支持添加多个分类拆分、附加手续费/优惠、上传票据图片。",
    ),
    "profileHelpQuickTitle": MessageLookupByLibrary.simpleMessage("快速记账"),
    "profileHelpRecurringBody": MessageLookupByLibrary.simpleMessage(
      "在「我的 → 周期记账」中创建自动记账规则。通过可视化的频率选择器（每天/每周/每月/每年）即可生成规则，无需手写 cron；进阶用户也可切换到自定义模式直接编辑 cron 表达式。",
    ),
    "profileHelpRecurringTitle": MessageLookupByLibrary.simpleMessage("周期记账"),
    "profileHideAmounts": MessageLookupByLibrary.simpleMessage("首页金额显示"),
    "profileHideAmountsSubtitle": MessageLookupByLibrary.simpleMessage(
      "隐藏后首页金额显示为 ••••",
    ),
    "profileIcp": MessageLookupByLibrary.simpleMessage("服务端备案"),
    "profileImportExport": MessageLookupByLibrary.simpleMessage("导出"),
    "profileLanguage": MessageLookupByLibrary.simpleMessage("语言"),
    "profileLoadFailed": MessageLookupByLibrary.simpleMessage("资料加载失败"),
    "profileLoginIp": MessageLookupByLibrary.simpleMessage("登录 IP"),
    "profileLoginTime": MessageLookupByLibrary.simpleMessage("登录时间"),
    "profileLogout": MessageLookupByLibrary.simpleMessage("退出登录"),
    "profileLogoutConfirm": MessageLookupByLibrary.simpleMessage("确定要退出当前账号吗？"),
    "profileLogs": MessageLookupByLibrary.simpleMessage("日志"),
    "profileMemberManageBill": MessageLookupByLibrary.simpleMessage("成员管理（账单）"),
    "profileMemberManageGroup": MessageLookupByLibrary.simpleMessage(
      "成员管理（分组协作）",
    ),
    "profileMissingUserInfoPassword": MessageLookupByLibrary.simpleMessage(
      "缺少用户信息，无法修改密码",
    ),
    "profileMissingUserInfoSave": MessageLookupByLibrary.simpleMessage(
      "缺少用户信息，无法保存",
    ),
    "profileMissingUserInfoUpload": MessageLookupByLibrary.simpleMessage(
      "缺少用户信息，无法上传",
    ),
    "profileMonthStartDay": MessageLookupByLibrary.simpleMessage("账单月开始日"),
    "profileMonthStartDayHint": MessageLookupByLibrary.simpleMessage(
      "短月份自动使用当月最后一天",
    ),
    "profileMonthStartDayValue": m71,
    "profileNewPassword": MessageLookupByLibrary.simpleMessage("新密码"),
    "profileNickname": MessageLookupByLibrary.simpleMessage("昵称"),
    "profileNicknameHint": MessageLookupByLibrary.simpleMessage("请输入昵称"),
    "profileNicknameRequired": MessageLookupByLibrary.simpleMessage("昵称不能为空"),
    "profileNotLoggedIn": MessageLookupByLibrary.simpleMessage("未登录"),
    "profileNotSelected": MessageLookupByLibrary.simpleMessage("未选择"),
    "profileNotSet": MessageLookupByLibrary.simpleMessage("未设置"),
    "profileOldPassword": MessageLookupByLibrary.simpleMessage("旧密码"),
    "profileOrdersManage": MessageLookupByLibrary.simpleMessage("单据管理"),
    "profilePasswordChangeFailed": m72,
    "profilePasswordChanged": MessageLookupByLibrary.simpleMessage("密码修改成功"),
    "profilePasswordFillOldNew": MessageLookupByLibrary.simpleMessage(
      "请填写旧密码和新密码",
    ),
    "profilePasswordMinLength": MessageLookupByLibrary.simpleMessage(
      "新密码至少 6 位",
    ),
    "profilePasswordMismatch": MessageLookupByLibrary.simpleMessage(
      "两次输入的新密码不一致",
    ),
    "profilePayeeManage": MessageLookupByLibrary.simpleMessage("交易对象管理"),
    "profilePhone": MessageLookupByLibrary.simpleMessage("电话"),
    "profilePhoneHint": MessageLookupByLibrary.simpleMessage("请输入手机号"),
    "profilePreferences": MessageLookupByLibrary.simpleMessage("偏好设置"),
    "profileQrCode": MessageLookupByLibrary.simpleMessage("个人二维码"),
    "profileRecurringManage": MessageLookupByLibrary.simpleMessage("周期记账"),
    "profileRefresh": MessageLookupByLibrary.simpleMessage("刷新"),
    "profileRemark": MessageLookupByLibrary.simpleMessage("备注"),
    "profileRestoreDefault": MessageLookupByLibrary.simpleMessage("恢复默认"),
    "profileRole": MessageLookupByLibrary.simpleMessage("角色"),
    "profileSaveFailed": m73,
    "profileSaveFailedRetry": MessageLookupByLibrary.simpleMessage("保存失败，请重试"),
    "profileSaved": MessageLookupByLibrary.simpleMessage("资料已保存"),
    "profileScreenCaptureAllowed": MessageLookupByLibrary.simpleMessage(
      "允许截屏与录屏",
    ),
    "profileScreenCaptureAllowedIosHint": MessageLookupByLibrary.simpleMessage(
      "iPhone 和 iPad 无法阻止系统静态截图；保护模式会遮挡录屏、镜像和应用切换预览中的内容。",
    ),
    "profileScreenCaptureAllowedSubtitle": MessageLookupByLibrary.simpleMessage(
      "默认限制截屏、录屏和应用预览；仅在需要分享内容时开启。",
    ),
    "profileScreenCaptureProtectionFailed":
        MessageLookupByLibrary.simpleMessage("屏幕保护设置未生效，请重试。"),
    "profileSelectLanguage": MessageLookupByLibrary.simpleMessage("选择语言"),
    "profileSex": MessageLookupByLibrary.simpleMessage("性别"),
    "profileSexFemale": MessageLookupByLibrary.simpleMessage("女"),
    "profileSexMale": MessageLookupByLibrary.simpleMessage("男"),
    "profileSigningCountdown": m74,
    "profileSigningExpired": MessageLookupByLibrary.simpleMessage("已过期"),
    "profileSigningExpiresOn": m75,
    "profileSigningValidity": MessageLookupByLibrary.simpleMessage("签名有效期"),
    "profileStatsAssets": MessageLookupByLibrary.simpleMessage("资产统计"),
    "profileStatsLoans": MessageLookupByLibrary.simpleMessage("借贷理财"),
    "profileStatsPolicy": MessageLookupByLibrary.simpleMessage("统计策略说明"),
    "profileSystemRecords": MessageLookupByLibrary.simpleMessage("系统记录"),
    "profileTagManage": MessageLookupByLibrary.simpleMessage("标签管理"),
    "profileTapToChangeAvatar": MessageLookupByLibrary.simpleMessage("点击更换头像"),
    "profileThemeDark": MessageLookupByLibrary.simpleMessage("暗色"),
    "profileThemeLight": MessageLookupByLibrary.simpleMessage("亮色"),
    "profileThemeMode": MessageLookupByLibrary.simpleMessage("主题模式"),
    "profileToolbox": MessageLookupByLibrary.simpleMessage("工具箱"),
    "profileUploadFailed": m76,
    "profileUsername": MessageLookupByLibrary.simpleMessage("账号"),
    "profileViewProfile": MessageLookupByLibrary.simpleMessage("查看个人资料"),
    "protocol": MessageLookupByLibrary.simpleMessage("协议"),
    "recurringAccount": MessageLookupByLibrary.simpleMessage("账户"),
    "recurringAccountRequired": MessageLookupByLibrary.simpleMessage("请选择账户"),
    "recurringAddRule": MessageLookupByLibrary.simpleMessage("新增周期规则"),
    "recurringAdvancedCron": MessageLookupByLibrary.simpleMessage(
      "自定义 cron（高级）",
    ),
    "recurringAdvancedCronHint": MessageLookupByLibrary.simpleMessage(
      "手动编辑 cron 表达式，适合高级用户",
    ),
    "recurringAmount": MessageLookupByLibrary.simpleMessage("金额"),
    "recurringAmountRequired": MessageLookupByLibrary.simpleMessage(
      "请输入有效的模板金额",
    ),
    "recurringAtTime": MessageLookupByLibrary.simpleMessage("时间"),
    "recurringBillTitleHint": MessageLookupByLibrary.simpleMessage("账单标题"),
    "recurringBillTitleRequired": MessageLookupByLibrary.simpleMessage(
      "请填写账单标题或规则名称",
    ),
    "recurringCategory": MessageLookupByLibrary.simpleMessage("分类"),
    "recurringCategoryRequired": MessageLookupByLibrary.simpleMessage("请选择分类"),
    "recurringCreateRule": MessageLookupByLibrary.simpleMessage("创建规则"),
    "recurringCron": MessageLookupByLibrary.simpleMessage("cron 表达式"),
    "recurringCronHint": MessageLookupByLibrary.simpleMessage("如：0 0 1 * * ?"),
    "recurringCronInvalid": MessageLookupByLibrary.simpleMessage("cron 表达式无效"),
    "recurringCronInvalidFix": MessageLookupByLibrary.simpleMessage(
      "cron 表达式无效，请修正",
    ),
    "recurringCronRequired": MessageLookupByLibrary.simpleMessage(
      "请输入 cron 表达式",
    ),
    "recurringCronValid": MessageLookupByLibrary.simpleMessage("cron 表达式有效"),
    "recurringCustomSchedule": MessageLookupByLibrary.simpleMessage("特殊调度"),
    "recurringDayOfMonthValue": m77,
    "recurringDelete": MessageLookupByLibrary.simpleMessage("删除"),
    "recurringDiscardCustomCronMessage": MessageLookupByLibrary.simpleMessage(
      "当前自定义 cron 表达式无法转换为可视化规则。",
    ),
    "recurringDiscardCustomCronTitle": MessageLookupByLibrary.simpleMessage(
      "切回可视化选择？",
    ),
    "recurringDiscardCustomCronWarning": MessageLookupByLibrary.simpleMessage(
      "继续后将使用当前可视化规则覆盖该表达式，且无法恢复。",
    ),
    "recurringEdit": MessageLookupByLibrary.simpleMessage("编辑"),
    "recurringEditRule": MessageLookupByLibrary.simpleMessage("编辑周期规则"),
    "recurringEmpty": MessageLookupByLibrary.simpleMessage("暂无周期规则，点击右上角 + 新增"),
    "recurringEnabled": MessageLookupByLibrary.simpleMessage("启用"),
    "recurringEndDateOptional": MessageLookupByLibrary.simpleMessage(
      "结束日期（可选）",
    ),
    "recurringExecutedCount": m78,
    "recurringExecutedLabel": MessageLookupByLibrary.simpleMessage("已执行"),
    "recurringFreqDaily": MessageLookupByLibrary.simpleMessage("每天"),
    "recurringFreqMonthly": MessageLookupByLibrary.simpleMessage("每月"),
    "recurringFreqWeekly": MessageLookupByLibrary.simpleMessage("每周"),
    "recurringFreqYearly": MessageLookupByLibrary.simpleMessage("每年"),
    "recurringLastDayOfMonth": MessageLookupByLibrary.simpleMessage("月末"),
    "recurringLegacyVisualNotice": MessageLookupByLibrary.simpleMessage(
      "原调度无法通过可视化选项展示，已切换为每天 09:00，请确认后保存。",
    ),
    "recurringLogBillId": m79,
    "recurringLogDuration": m80,
    "recurringLogs": MessageLookupByLibrary.simpleMessage("执行日志"),
    "recurringLogsTitle": m81,
    "recurringMaxExecutionsHint": MessageLookupByLibrary.simpleMessage("留空为不限"),
    "recurringMaxExecutionsOptional": MessageLookupByLibrary.simpleMessage(
      "最大执行次数（可选）",
    ),
    "recurringMonthValue": m82,
    "recurringNextExecution": MessageLookupByLibrary.simpleMessage("下次执行"),
    "recurringNoLogs": MessageLookupByLibrary.simpleMessage("暂无执行记录"),
    "recurringNoOptions": MessageLookupByLibrary.simpleMessage("暂无可选项"),
    "recurringOnDayOfMonth": MessageLookupByLibrary.simpleMessage("每月几号"),
    "recurringOnDays": MessageLookupByLibrary.simpleMessage("重复"),
    "recurringOnMonth": MessageLookupByLibrary.simpleMessage("月份"),
    "recurringRecoveryStrategy": MessageLookupByLibrary.simpleMessage("补偿策略"),
    "recurringRemoveMessage": m83,
    "recurringRemoveTitle": MessageLookupByLibrary.simpleMessage("删除规则"),
    "recurringRuleName": MessageLookupByLibrary.simpleMessage("规则名称"),
    "recurringRuleNameHint": MessageLookupByLibrary.simpleMessage("如：每月房租"),
    "recurringRuleNameRequired": MessageLookupByLibrary.simpleMessage(
      "请输入规则名称",
    ),
    "recurringSaveChanges": MessageLookupByLibrary.simpleMessage("保存修改"),
    "recurringSchedule": MessageLookupByLibrary.simpleMessage("执行频率"),
    "recurringScheduleSummary": MessageLookupByLibrary.simpleMessage("执行时间"),
    "recurringSectionRule": MessageLookupByLibrary.simpleMessage("规则设置"),
    "recurringSectionTemplate": MessageLookupByLibrary.simpleMessage("账单模板"),
    "recurringSelectBookFirst": MessageLookupByLibrary.simpleMessage("请先选择账本"),
    "recurringStartDateOptional": MessageLookupByLibrary.simpleMessage(
      "开始日期（可选）",
    ),
    "recurringSummaryDaily": m84,
    "recurringSummaryMonthly": m85,
    "recurringSummaryWeekly": m86,
    "recurringSummaryYearly": m87,
    "recurringTagsOptional": MessageLookupByLibrary.simpleMessage("标签（可多选，可选）"),
    "recurringThisRule": MessageLookupByLibrary.simpleMessage("该规则"),
    "recurringTitle": MessageLookupByLibrary.simpleMessage("周期记账"),
    "recurringTitleOptional": MessageLookupByLibrary.simpleMessage(
      "标题（可选，空则用规则名）",
    ),
    "recurringType": MessageLookupByLibrary.simpleMessage("类型"),
    "recurringUnnamedRule": MessageLookupByLibrary.simpleMessage("未命名规则"),
    "recurringUseAdvanced": MessageLookupByLibrary.simpleMessage("切换到自定义 cron"),
    "recurringUseVisual": MessageLookupByLibrary.simpleMessage("使用可视化选择"),
    "recurringWeekdayFri": MessageLookupByLibrary.simpleMessage("周五"),
    "recurringWeekdayMon": MessageLookupByLibrary.simpleMessage("周一"),
    "recurringWeekdaySat": MessageLookupByLibrary.simpleMessage("周六"),
    "recurringWeekdaySun": MessageLookupByLibrary.simpleMessage("周日"),
    "recurringWeekdayThu": MessageLookupByLibrary.simpleMessage("周四"),
    "recurringWeekdayTue": MessageLookupByLibrary.simpleMessage("周二"),
    "recurringWeekdayWed": MessageLookupByLibrary.simpleMessage("周三"),
    "register": MessageLookupByLibrary.simpleMessage("注册"),
    "registration_failed": MessageLookupByLibrary.simpleMessage("注册失败"),
    "serverConnectionFailed": MessageLookupByLibrary.simpleMessage(
      "无法连接服务器，请检查地址、端口或网络",
    ),
    "serverHistory": MessageLookupByLibrary.simpleMessage("历史地址"),
    "serverHistoryEmpty": MessageLookupByLibrary.simpleMessage("暂无历史"),
    "serverHistorySelect": MessageLookupByLibrary.simpleMessage("选择已保存的服务器"),
    "service_required": MessageLookupByLibrary.simpleMessage("同意以继续"),
    "sex": MessageLookupByLibrary.simpleMessage("性别"),
    "sex_valid": MessageLookupByLibrary.simpleMessage("当前只支持两种性别，请填写‘男’或‘女’"),
    "sign_up_submit": MessageLookupByLibrary.simpleMessage("提交"),
    "sign_up_success": MessageLookupByLibrary.simpleMessage("注册成功"),
    "statsActiveTodoCountLabel": MessageLookupByLibrary.simpleMessage(
      "未完成账单明细",
    ),
    "statsAppBarTitle": MessageLookupByLibrary.simpleMessage("统计概览"),
    "statsArchivedLoanIncomeExpense": MessageLookupByLibrary.simpleMessage(
      "已归档借款收支",
    ),
    "statsArchivedLoanNote": MessageLookupByLibrary.simpleMessage(
      "按已归档债权/债务单的利息、手续费和差额结清计算，不是投资收益率。",
    ),
    "statsAssetsByAccountType": MessageLookupByLibrary.simpleMessage("按账户类型"),
    "statsAssetsComposition": MessageLookupByLibrary.simpleMessage("资产负债构成"),
    "statsAssetsEntrySubtitle": MessageLookupByLibrary.simpleMessage(
      "资产负债构成、净资产趋势和信用卡概览",
    ),
    "statsAssetsTitle": MessageLookupByLibrary.simpleMessage("资产统计"),
    "statsBarChartSemantics": m88,
    "statsBasicTitle": MessageLookupByLibrary.simpleMessage("收支洞察"),
    "statsBillCount": m89,
    "statsCalendarDateSummary": m90,
    "statsCalendarDayBills": MessageLookupByLibrary.simpleMessage("当天账单"),
    "statsCalendarDayBillsEmpty": MessageLookupByLibrary.simpleMessage(
      "当天暂无账单",
    ),
    "statsCalendarExpense": MessageLookupByLibrary.simpleMessage("支"),
    "statsCalendarExpenseCount": m91,
    "statsCalendarHistory": MessageLookupByLibrary.simpleMessage("历史"),
    "statsCalendarIncome": MessageLookupByLibrary.simpleMessage("收"),
    "statsCalendarIncomeCount": m92,
    "statsCalendarMonth": MessageLookupByLibrary.simpleMessage("月"),
    "statsCalendarNext": MessageLookupByLibrary.simpleMessage("下一个"),
    "statsCalendarPrevious": MessageLookupByLibrary.simpleMessage("上一个"),
    "statsCalendarTotalCount": m93,
    "statsCalendarViewBills": MessageLookupByLibrary.simpleMessage("在账单页查看"),
    "statsCalendarYear": MessageLookupByLibrary.simpleMessage("年"),
    "statsCategoryShare": MessageLookupByLibrary.simpleMessage("分类占比"),
    "statsCompletedTodoCountLabel": MessageLookupByLibrary.simpleMessage(
      "已完成账单明细",
    ),
    "statsCreditCardDates": m94,
    "statsCreditCardOverview": MessageLookupByLibrary.simpleMessage("信用卡概览"),
    "statsDonutChartSemantics": m95,
    "statsExpense": MessageLookupByLibrary.simpleMessage("支出"),
    "statsExpenseAnalytics": MessageLookupByLibrary.simpleMessage("支出分析"),
    "statsExpenseCategoryShare": MessageLookupByLibrary.simpleMessage("支出分类占比"),
    "statsExpensePayees": MessageLookupByLibrary.simpleMessage("支出交易对象"),
    "statsExpenseTags": MessageLookupByLibrary.simpleMessage("支出标签"),
    "statsExpenseTrend": MessageLookupByLibrary.simpleMessage("支出趋势"),
    "statsFinanceProfit": MessageLookupByLibrary.simpleMessage("理财收益"),
    "statsIncome": MessageLookupByLibrary.simpleMessage("收入"),
    "statsIncomeAnalytics": MessageLookupByLibrary.simpleMessage("收入分析"),
    "statsIncomeCategoryShare": MessageLookupByLibrary.simpleMessage("收入分类占比"),
    "statsIncomeExpenseCalendar": MessageLookupByLibrary.simpleMessage("收支日历"),
    "statsIncomePayees": MessageLookupByLibrary.simpleMessage("收入交易对象"),
    "statsIncomeTags": MessageLookupByLibrary.simpleMessage("收入标签"),
    "statsIncomeTrend": MessageLookupByLibrary.simpleMessage("收入趋势"),
    "statsLineChartSemantics": m96,
    "statsLoanOverview": MessageLookupByLibrary.simpleMessage("借贷概览"),
    "statsLoanPayable": MessageLookupByLibrary.simpleMessage("待归还"),
    "statsLoanPendingCount": m97,
    "statsLoanReceivable": MessageLookupByLibrary.simpleMessage("待收回"),
    "statsLoansEntrySubtitle": MessageLookupByLibrary.simpleMessage(
      "借贷应收应付、理财盈亏和待确认账单",
    ),
    "statsLoansTitle": MessageLookupByLibrary.simpleMessage("借贷理财"),
    "statsLoss": MessageLookupByLibrary.simpleMessage("亏损"),
    "statsMoreReports": MessageLookupByLibrary.simpleMessage("更多统计报表"),
    "statsNetAssetsTrend": MessageLookupByLibrary.simpleMessage("净资产趋势"),
    "statsNetProfit": MessageLookupByLibrary.simpleMessage("净收益"),
    "statsNoRecordsThisPeriod": MessageLookupByLibrary.simpleMessage("本期暂无记录"),
    "statsOverduePayable": MessageLookupByLibrary.simpleMessage("逾期待还"),
    "statsOverdueReceivable": MessageLookupByLibrary.simpleMessage("逾期待收"),
    "statsPayees": MessageLookupByLibrary.simpleMessage("交易对象"),
    "statsPendingConfirm": MessageLookupByLibrary.simpleMessage("待确认"),
    "statsPolicyBillTypes": MessageLookupByLibrary.simpleMessage("账单类型口径"),
    "statsPolicyDefaultDesc": MessageLookupByLibrary.simpleMessage(
      "已确认且开启“计入统计”的账单会进入收支、趋势、分类和资产相关报表；关闭计入统计的账单仅保留明细，不影响统计图表。",
    ),
    "statsPolicyDefaultExclude": MessageLookupByLibrary.simpleMessage(
      "默认不计入统计",
    ),
    "statsPolicyDefaultInclude": MessageLookupByLibrary.simpleMessage("默认计入统计"),
    "statsPolicyEndpointFallback": MessageLookupByLibrary.simpleMessage(
      "当前后端尚未提供完整策略接口，以下按前端约定展示。",
    ),
    "statsPolicyEntrySubtitle": MessageLookupByLibrary.simpleMessage(
      "查看哪些账单会进入统计图表",
    ),
    "statsPolicyExcluded": MessageLookupByLibrary.simpleMessage("不计入"),
    "statsPolicyIncluded": MessageLookupByLibrary.simpleMessage("计入"),
    "statsPolicyScope": MessageLookupByLibrary.simpleMessage("统计口径"),
    "statsPolicyTitle": MessageLookupByLibrary.simpleMessage("统计策略说明"),
    "statsProfit": MessageLookupByLibrary.simpleMessage("盈利"),
    "statsRangeCustom": MessageLookupByLibrary.simpleMessage("自定义"),
    "statsRangePeriod": MessageLookupByLibrary.simpleMessage("本账期"),
    "statsRangeWeek": MessageLookupByLibrary.simpleMessage("本周"),
    "statsRangeYear": MessageLookupByLibrary.simpleMessage("本年"),
    "statsReceiptAmountCol": MessageLookupByLibrary.simpleMessage("金额"),
    "statsReceiptCashier": MessageLookupByLibrary.simpleMessage("收银员：好记"),
    "statsReceiptDate": m98,
    "statsReceiptDiscountTotal": m99,
    "statsReceiptFeeTotal": m100,
    "statsReceiptFooterCounter": MessageLookupByLibrary.simpleMessage(
      "当前什么都不支持",
    ),
    "statsReceiptFooterDelivery": MessageLookupByLibrary.simpleMessage(
      "24小时内完成账单交付",
    ),
    "statsReceiptFooterExcel": MessageLookupByLibrary.simpleMessage(
      "请保留好小票，如需赞助",
    ),
    "statsReceiptFooterScan": MessageLookupByLibrary.simpleMessage(
      "扫描二维码进行赞助，非常感谢！",
    ),
    "statsReceiptFooterUrl": MessageLookupByLibrary.simpleMessage(
      "网址：https://www.fortuneboot.com/",
    ),
    "statsReceiptFooterWelcome": MessageLookupByLibrary.simpleMessage(
      "欢迎再次光临--服务邮箱：san.bug@qq.com",
    ),
    "statsReceiptIncomeGoods": MessageLookupByLibrary.simpleMessage("收入商品数"),
    "statsReceiptItem": MessageLookupByLibrary.simpleMessage("品名"),
    "statsReceiptKeep": MessageLookupByLibrary.simpleMessage("请保留好小票"),
    "statsReceiptPayment": MessageLookupByLibrary.simpleMessage("付款方式：刷脸"),
    "statsReceiptQty": MessageLookupByLibrary.simpleMessage("数量"),
    "statsReceiptSave": MessageLookupByLibrary.simpleMessage("保存小票"),
    "statsReceiptSerial": m101,
    "statsReceiptSoldGoods": MessageLookupByLibrary.simpleMessage("售出商品数"),
    "statsReceiptThanks": MessageLookupByLibrary.simpleMessage("谢谢惠顾"),
    "statsReceiptTransferCount": MessageLookupByLibrary.simpleMessage("转账数"),
    "statsReceiptWelcome": MessageLookupByLibrary.simpleMessage("欢迎光临"),
    "statsSelectBookFirst": MessageLookupByLibrary.simpleMessage("请先选择一个账本"),
    "statsSelectGroupFirst": MessageLookupByLibrary.simpleMessage("请先选择分组"),
    "statsSurplus": MessageLookupByLibrary.simpleMessage("结余"),
    "statsTableDetail": MessageLookupByLibrary.simpleMessage("详情"),
    "statsTableItem": MessageLookupByLibrary.simpleMessage("项目"),
    "statsTableSemantics": m102,
    "statsTableShare": MessageLookupByLibrary.simpleMessage("占比"),
    "statsTableValue": MessageLookupByLibrary.simpleMessage("数值"),
    "statsTags": MessageLookupByLibrary.simpleMessage("标签"),
    "statsTitle": MessageLookupByLibrary.simpleMessage("统计"),
    "statsUncategorized": MessageLookupByLibrary.simpleMessage("未分类"),
    "statsUnnamed": MessageLookupByLibrary.simpleMessage("未命名"),
    "statsViewChart": MessageLookupByLibrary.simpleMessage("查看图表"),
    "statsViewTable": MessageLookupByLibrary.simpleMessage("查看表格"),
    "succes": MessageLookupByLibrary.simpleMessage("搞定！"),
    "tagsAdd": MessageLookupByLibrary.simpleMessage("新增标签"),
    "tagsCreate": MessageLookupByLibrary.simpleMessage("创建标签"),
    "tagsDelete": MessageLookupByLibrary.simpleMessage("删除"),
    "tagsDeletePermanently": MessageLookupByLibrary.simpleMessage("彻底删除"),
    "tagsDeletePermanentlyConfirm": m103,
    "tagsEdit": MessageLookupByLibrary.simpleMessage("编辑标签"),
    "tagsEmpty": MessageLookupByLibrary.simpleMessage("暂无标签，点击右上角 + 新增"),
    "tagsMove": MessageLookupByLibrary.simpleMessage("移入"),
    "tagsMoveToRecycleBin": MessageLookupByLibrary.simpleMessage("移入回收站"),
    "tagsMoveToRecycleBinConfirm": m104,
    "tagsNameHint": MessageLookupByLibrary.simpleMessage("如：聚餐"),
    "tagsNameLabel": MessageLookupByLibrary.simpleMessage("标签名称"),
    "tagsNameRequired": MessageLookupByLibrary.simpleMessage("请输入标签名称"),
    "tagsParentLabel": MessageLookupByLibrary.simpleMessage("父级标签（可选）"),
    "tagsParentNone": MessageLookupByLibrary.simpleMessage("无（顶级标签）"),
    "tagsRemarkHint": MessageLookupByLibrary.simpleMessage("备注"),
    "tagsRemarkLabel": MessageLookupByLibrary.simpleMessage("备注（可选）"),
    "tagsSaveEdit": MessageLookupByLibrary.simpleMessage("保存修改"),
    "tagsSearchHint": MessageLookupByLibrary.simpleMessage("搜索标签名称"),
    "tagsSelectBookFirst": MessageLookupByLibrary.simpleMessage("请先选择账本"),
    "tagsSortHint": MessageLookupByLibrary.simpleMessage("数字越小越靠前"),
    "tagsSortLabel": MessageLookupByLibrary.simpleMessage("排序（可选）"),
    "tagsThisTag": MessageLookupByLibrary.simpleMessage("该标签"),
    "tagsTitle": MessageLookupByLibrary.simpleMessage("标签管理"),
    "tagsUnnamed": MessageLookupByLibrary.simpleMessage("未命名"),
    "term_of_services": MessageLookupByLibrary.simpleMessage("服务条款"),
    "todoDetailsAppBarTitle": MessageLookupByLibrary.simpleMessage("账单明细详情"),
    "todoDetailsDeleteButtonTooltip": MessageLookupByLibrary.simpleMessage(
      "删除",
    ),
    "todoDetailsEditButtonTooltip": MessageLookupByLibrary.simpleMessage("修改"),
    "todosOverviewAppBarTitle": MessageLookupByLibrary.simpleMessage("账单明细"),
    "todosOverviewClearCompletedButtonText":
        MessageLookupByLibrary.simpleMessage("清除已完成"),
    "todosOverviewEmptyText": MessageLookupByLibrary.simpleMessage(
      "未找到符合筛选条件的账单明细",
    ),
    "todosOverviewErrorSnackbarText": MessageLookupByLibrary.simpleMessage(
      "加载账单明细时发生错误。",
    ),
    "todosOverviewFilterActiveOnly": MessageLookupByLibrary.simpleMessage(
      "仅未完成",
    ),
    "todosOverviewFilterAll": MessageLookupByLibrary.simpleMessage("全部"),
    "todosOverviewFilterCompletedOnly": MessageLookupByLibrary.simpleMessage(
      "仅已完成",
    ),
    "todosOverviewFilterTooltip": MessageLookupByLibrary.simpleMessage("筛选"),
    "todosOverviewMarkAllCompleteButtonText":
        MessageLookupByLibrary.simpleMessage("全部标记为完成"),
    "todosOverviewOptionsClearCompleted": MessageLookupByLibrary.simpleMessage(
      "清除已完成账单明细",
    ),
    "todosOverviewOptionsMarkAllComplete": MessageLookupByLibrary.simpleMessage(
      "全部标记为完成",
    ),
    "todosOverviewOptionsMarkAllIncomplete":
        MessageLookupByLibrary.simpleMessage("全部标记为未完成"),
    "todosOverviewOptionsTooltip": MessageLookupByLibrary.simpleMessage("操作"),
    "todosOverviewTodoDeletedSnackbarText": m105,
    "todosOverviewUndoDeletionButtonText": MessageLookupByLibrary.simpleMessage(
      "撤销",
    ),
    "user_auth_vaild": MessageLookupByLibrary.simpleMessage("账号不能为空"),
    "user_not_exist": MessageLookupByLibrary.simpleMessage("用户不存在"),
    "username": MessageLookupByLibrary.simpleMessage("用户名"),
    "valid_phone_number": MessageLookupByLibrary.simpleMessage("请输入正确的手机号"),
  };
}
