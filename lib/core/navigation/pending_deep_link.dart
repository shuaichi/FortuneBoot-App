import 'package:fortuneboot/core/navigation/deep_link_target.dart';

/// 启动校验期间暂存的目标路由。
///
/// 只保存一个目标；登录/会话恢复完成后由主壳消费。目标在成功进入前不会
/// 被丢弃，避免刷新二级页后直接回首页。
final class PendingDeepLink {
  PendingDeepLink._();

  /// 进程内唯一入口；启动守卫写入，主壳消费。
  static final PendingDeepLink instance = PendingDeepLink._();

  DeepLinkTarget? _target;

  void capture(String? rawRoute) {
    final target = DeepLinkTarget.tryParse(rawRoute);
    if (target == null) return;
    _target = target;
  }

  DeepLinkTarget? peek() => _target;

  /// 成功进入目标或用户明确放弃后消费。
  DeepLinkTarget? take() {
    final target = _target;
    _target = null;
    return target;
  }

  void clear() => _target = null;
}
