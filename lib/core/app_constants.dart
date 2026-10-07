/// 应用级常量。API 版本区间原在 BillsRepository（旧代码），迁移至此以便删除旧 Repository。
abstract final class AppConstants {
  static const String minApiVersion = '1.7.0';
  static const String maxApiVersion = '2.0.0';

  /// 鸿蒙 App ICP 备案号。
  static const String appIcpFiling = '豫ICP备2025158026号-3A';

  /// 打包进安装包的国务院调休补丁（由 tool/build_holiday_patch 生成）。
  static const String holidayPatchAsset = 'assets/calendar/holiday-patch.json';

  const AppConstants._();
}
