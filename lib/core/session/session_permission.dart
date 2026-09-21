import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/books/domain/books_manage_capabilities.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 当前分组角色 / 访客写权限相关辅助。
abstract final class SessionPermission {
  const SessionPermission._();

  static ManageCapabilities capabilitiesOf(FortuneGroupVo? group) {
    return CapabilityResolver.fromRoleType(
      group?.roleType,
      description: group?.roleTypeDesc,
    );
  }

  static bool isVisitor(FortuneGroupVo? group) =>
      capabilitiesOf(group).role == ManageRole.visitor;

  static bool canWrite(FortuneGroupVo? group) =>
      capabilitiesOf(group).canWrite;

  /// 将接口原始错误文案转为更友好的提示。
  ///
  /// 仅把明确的无权限/空内部错误映射为访客提示；其它业务错误原样返回。
  static String friendlyApiMessage(int code, String raw) {
    final msg = raw.trim();
    if (msg.isEmpty || msg.toLowerCase() == 'null') {
      return S.current.commonSystemBusy;
    }
    final looksInternalNull = RegExp(
      r'^系统内部错误[:：]\s*null$',
      caseSensitive: false,
    ).hasMatch(msg);
    if (looksInternalNull) {
      return S.current.commonSystemBusy;
    }
    final looksNoPermission =
        msg.contains('没有权限') ||
        msg.contains('无权限') ||
        msg.toLowerCase().contains('access is denied') ||
        msg.toLowerCase().contains('access denied');
    if (looksNoPermission) {
      return S.current.permissionVisitorNoAccess;
    }
    return msg;
  }
}
