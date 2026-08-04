/// 应用级常量。API 版本区间原在 BillsRepository（旧代码），迁移至此以便删除旧 Repository。
abstract final class AppConstants {
  static const String minApiVersion = '1.1.0';
  static const String maxApiVersion = '2.0.0';

  const AppConstants._();
}
