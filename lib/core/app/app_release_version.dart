/// App release version (aligned with pubspec.yaml / store listing).
///
/// Run scripts/set_ohos_version.bat before DevEco packaging to refresh this file.
/// On HarmonyOS, package_info_plus is unavailable; About page uses this fallback.
class AppReleaseVersion {
  const AppReleaseVersion._();

  /// versionName, e.g. 1.4.3
  static const String name = '1.5.0';

  /// versionCode, e.g. 2026082115
  static const String build = '2026092901';

  /// About page display: 1.4.3 (2026082115)
  static String get display {
    if (name.isEmpty) return '';
    if (build.isEmpty) return name;
    return '$name\uFF08$build\uFF09';
  }
}

