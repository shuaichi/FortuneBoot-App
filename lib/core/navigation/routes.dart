/// 集中路由名常量。所有 Navigator.pushNamed 走这里，杜绝散落字符串。
abstract final class Routes {
  static const String baseUrlConfig = '/base_url_config';
  static const String auth = '/auth';
  static const String main = '/main'; // MainShell（底部导航容器）

  // MainShell 内 tab 对应逻辑页（也可独立 push）
  static const String dashboard = '/dashboard';
  static const String bills = '/bills';
  static const String stats = '/stats';
  static const String profile = '/profile';

  // 二级页面
  static const String billEditor = '/bill_editor';
  static const String accounts = '/accounts';
  static const String accountEditor = '/account_editor';
  static const String categories = '/categories';
  static const String tags = '/tags';
  static const String payees = '/payees';
  static const String members = '/members';
  static const String goods = '/goods';
  static const String goodsEditor = '/goods_editor';
  static const String orders = '/orders';
  static const String recurring = '/recurring';
  static const String recurringEditor = '/recurring_editor';
  static const String groupUsers = '/group_users';
  static const String books = '/books';
  static const String groups = '/groups';
  static const String io = '/io';
  static const String logs = '/logs';
  static const String statsAssets = '/stats/assets';
  static const String statsLoans = '/stats/loans';
  static const String statsPolicy = '/stats/policy';
  static const String profileEdit = '/profile_edit';

  const Routes._();
}
