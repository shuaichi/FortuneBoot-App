import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:hjproject/utils/harmony_preferences.dart';
import 'package:hjproject/utils/platform_logger.dart';

const mockUsers = {
  'dribbble@gmail.com': '12345',
  'hunter@gmail.com': 'hunter',
  'near.huscarl@gmail.com': 'subscribe to pewdiepie',
  '@.com': '.',
};

class UserDataSingleton {
  static const String userInfo = 'userInfo';
  static const String userToken = 'userToken';
  static const String baseUrlDomain = 'baseUrlDomain';
  static const String baseUrlPort = 'baseUrlPort';
  static const String baseUrlProtocol = 'baseUrlProtocol';
  
  // 私有静态实例
  static final UserDataSingleton _instance = UserDataSingleton._internal();

  SharedPreferences? prefs;
  HarmonyPreferences? _harmonyPrefs;

  // 数据存储核心结构
  Map<String, dynamic> _userData = {};

  // 工厂构造函数返回唯一实例
  factory UserDataSingleton() => _instance;

  // 私有构造函数防止外部实例化
  UserDataSingleton._internal();

  /// 初始化方法,兼容鸿蒙平台
  void init(SharedPreferences pre) {
    prefs = pre;
    PlatformLogger.info('✅ UserDataSingleton 初始化完成(SharedPreferences)');
  }

  /// 初始化方法(兼容鸿蒙平台的异步初始化)
  Future<void> initAsync() async {
    try {
      prefs = await SharedPreferences.getInstance();
      PlatformLogger.info('✅ UserDataSingleton 异步初始化完成(SharedPreferences)');
    } catch (e) {
      PlatformLogger.warning('⚠️ SharedPreferences 不可用,使用 HarmonyPreferences: $e');
      _harmonyPrefs = await HarmonyPreferences.getInstance();
    }
  }

  // 数据操作方法
  Future<void> setMap(String key, Map<String, dynamic> value) async {
    _userData[key] = value;
    
    try {
      if (prefs != null) {
        await prefs!.setString(key, jsonEncode(value));
      } else if (_harmonyPrefs != null) {
        await _harmonyPrefs!.setMap(key, value);
      } else {
        // 尝试使用 HarmonyPreferences
        _harmonyPrefs ??= await HarmonyPreferences.getInstance();
        await _harmonyPrefs!.setMap(key, value);
      }
      PlatformLogger.debug('保存 Map 成功: $key');
    } catch (e) {
      PlatformLogger.warning('保存 Map 失败: $key, $e');
    }
  }

  Future<void> setStr(String key, String value) async {
    _userData[key] = value;
    
    try {
      if (prefs != null) {
        await prefs!.setString(key, value);
      } else if (_harmonyPrefs != null) {
        await _harmonyPrefs!.setString(key, value);
      } else {
        // 尝试使用 HarmonyPreferences
        _harmonyPrefs ??= await HarmonyPreferences.getInstance();
        await _harmonyPrefs!.setString(key, value);
      }
      PlatformLogger.debug('保存字符串成功: $key');
    } catch (e) {
      PlatformLogger.warning('保存字符串失败: $key, $e');
    }
  }

  Future<Map<String, dynamic>?> getMap(String key) async {
    try {
      // 先检查内存缓存
      if (_userData[key] != null) {
        PlatformLogger.debug('从内存缓存获取 Map: $key');
        return _userData[key] as Map<String, dynamic>?;
      }

      // 尝试从 SharedPreferences 获取
      if (prefs != null) {
        String? localValue = prefs!.getString(key);
        if (localValue != null && localValue.isNotEmpty) {
          final localData = Map<String, dynamic>.from(
            jsonDecode(localValue) as Map? ?? {}
          );
          if (localData.isNotEmpty) {
            _userData[key] = localData;
          }
          PlatformLogger.debug('从 SharedPreferences 获取 Map: $key');
          return localData;
        }
      }

      // 尝试从 HarmonyPreferences 获取
      _harmonyPrefs ??= await HarmonyPreferences.getInstance();
      final localData = await _harmonyPrefs!.getMap(key);
      if (localData != null && localData.isNotEmpty) {
        _userData[key] = localData;
      }
      PlatformLogger.debug('从 HarmonyPreferences 获取 Map: $key');
      return localData;
    } catch (e) {
      PlatformLogger.warning('获取 Map 失败: $key, $e');
      return _userData[key] as Map<String, dynamic>?;
    }
  }

  Future<String?> getStr(String key) async {
    try {
      // 先检查内存缓存
      if (_userData[key] != null) {
        PlatformLogger.debug('从内存缓存获取字符串: $key');
        return _userData[key] as String?;
      }

      // 尝试从 SharedPreferences 获取
      if (prefs != null) {
        String? localValue = prefs!.getString(key);
        if (localValue != null) {
          _userData[key] = localValue;
          PlatformLogger.debug('从 SharedPreferences 获取字符串: $key');
          return localValue;
        }
      }

      // 尝试从 HarmonyPreferences 获取
      _harmonyPrefs ??= await HarmonyPreferences.getInstance();
      final localValue = await _harmonyPrefs!.getString(key);
      if (localValue != null) {
        _userData[key] = localValue;
      }
      PlatformLogger.debug('从 HarmonyPreferences 获取字符串: $key');
      return localValue;
    } catch (e) {
      PlatformLogger.warning('获取字符串失败: $key, $e');
      return _userData[key] as String?;
    }
  }

  Future<void> remove(String key) async {
    _userData.remove(key);
    
    try {
      if (prefs != null) {
        await prefs!.remove(key);
      } else if (_harmonyPrefs != null) {
        await _harmonyPrefs!.remove(key);
      } else {
        _harmonyPrefs ??= await HarmonyPreferences.getInstance();
        await _harmonyPrefs!.remove(key);
      }
      PlatformLogger.debug('删除 key 成功: $key');
    } catch (e) {
      PlatformLogger.warning('删除 key 失败: $key, $e');
    }
  }

  bool containsKey(String key) => _userData.containsKey(key);
}