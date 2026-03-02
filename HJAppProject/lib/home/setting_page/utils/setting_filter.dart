import 'package:hjproject/home/setting_page/models/mine_setting.dart';

/// 设置项过滤工具类
/// 提供高效的设置项分组和过滤功能
class SettingFilter {
  /// 将设置项列表按类型分组
  /// 使用单次遍历优化性能，避免多次 where 操作
  static SettingGroups groupSettings(List<Setting> elements) {
    final accountSettings = <Setting>[];
    final appSettings = <Setting>[];
    final aboutSettings = <Setting>[];

    for (final element in elements) {
      switch (element.type) {
        case SettingType.currentGroup:
        case SettingType.currentBook:
        case SettingType.accountOverview:
          accountSettings.add(element);
          break;
        case SettingType.currentTheme:
        case SettingType.currentLanguage:
          appSettings.add(element);
          break;
        case SettingType.api:
        case SettingType.currentVersion:
        case SettingType.apiVersion:
          aboutSettings.add(element);
          break;
        default:
          break;
      }
    }

    return SettingGroups(
      accountSettings: accountSettings,
      appSettings: appSettings,
      aboutSettings: aboutSettings,
    );
  }

  /// 查找特定类型的设置项
  static Setting? findSettingByType(
    List<Setting> elements,
    SettingType type,
  ) {
    try {
      return elements.firstWhere((element) => element.type == type);
    } catch (_) {
      return null;
    }
  }
}

/// 设置项分组数据类
class SettingGroups {
  final List<Setting> accountSettings;
  final List<Setting> appSettings;
  final List<Setting> aboutSettings;

  const SettingGroups({
    required this.accountSettings,
    required this.appSettings,
    required this.aboutSettings,
  });

  bool get hasAccountSettings => accountSettings.isNotEmpty;
  bool get hasAppSettings => appSettings.isNotEmpty;
  bool get hasAboutSettings => aboutSettings.isNotEmpty;
}
