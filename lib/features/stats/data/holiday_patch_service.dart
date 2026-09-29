import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/core/app_constants.dart';
import 'package:lunar/lunar.dart';

/// 打包进安装包的调休补丁：启动时从 assets 读取并 [HolidayUtil.fix]。
///
/// 更新方式：编辑源文件后运行 `tool/build_holiday_patch.bat`，
/// 生成 `assets/calendar/holiday-patch.json`，再发版。
class HolidayPatchService {
  HolidayPatchService({
    this.assetPath = AppConstants.holidayPatchAsset,
    Future<String> Function(String key)? loadAsset,
  }) : _loadAsset = loadAsset ?? rootBundle.loadString;

  final String assetPath;
  final Future<String> Function(String key) _loadAsset;

  static final HolidayPatchService instance = HolidayPatchService();

  /// 启动时注入安装包内补丁；文件缺失或无效时静默跳过。
  Future<bool> applyBundled() async {
    try {
      final text = await _loadAsset(assetPath);
      return applyFromRaw(jsonDecode(text));
    } on FlutterError catch (e, st) {
      log('holiday patch asset missing: $e', stackTrace: st);
      return false;
    } catch (e, st) {
      log('holiday patch apply failed: $e', stackTrace: st);
      return false;
    }
  }

  /// 解析并注入补丁对象。供单测直接调用。
  bool applyFromRaw(dynamic raw) {
    if (raw is! Map) return false;
    final map = Map<String, dynamic>.from(raw);
    final data = map['data']?.toString() ?? '';
    if (data.isEmpty || data.length % 18 != 0) return false;
    HolidayUtil.fix(null, data);
    return true;
  }
}
