/// 应用级常量。API 版本区间原在 BillsRepository（旧代码），迁移至此以便删除旧 Repository。
abstract final class AppConstants {
  static const String minApiVersion = '1.7.0';
  static const String maxApiVersion = '2.0.0';

  /// 鸿蒙 App ICP 备案号。
  static const String appIcpFiling = '豫ICP备2025158026号-3A';

  const AppConstants._();
}
