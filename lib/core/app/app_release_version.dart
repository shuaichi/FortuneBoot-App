/// 应用发布版本（与 pubspec.yaml / 上架版本对齐）。
///
/// DevEco 打包前运行 `scripts/set_ohos_version.ps1` 会同步更新本文件。
/// 鸿蒙端 `package_info_plus` 无实现时，关于页以此为准。
class AppReleaseVersion {
  const AppReleaseVersion._();

  /// 版本号（versionName），例如 1.4.3。
  static const String name = '1.6.1';

  /// 构建号（versionCode），例如 2026082115。
  static const String build = '2026101816';

  /// 关于页 / 列表展示用：1.4.3（2026082115）
  static String get display {
    if (name.isEmpty) return '';
    if (build.isEmpty) return name;
    return '$name（$build）';
  }
}
