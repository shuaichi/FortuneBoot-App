import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hjproject/utils/platform_logger.dart';

/// 鸿蒙平台兼容的 SharedPreferences 包装类
/// 解决鸿蒙平台 SharedPreferences 插件未实现的问题
class HarmonyPreferences {
  static HarmonyPreferences? _instance;
  static SharedPreferences? _preferences;
  static Map<String, dynamic> _memoryCache = {};
  static bool _initialized = false;

  HarmonyPreferences._();

  /// 获取单例实例
  static Future<HarmonyPreferences> getInstance() async {
    if (_instance == null || !_initialized) {
      _instance = HarmonyPreferences._();
      await _instance!._init();
    }
    return _instance!;
  }

  /// 初始化 SharedPreferences
  Future<void> _init() async {
    try {
      PlatformLogger.info('🔧 开始初始化 SharedPreferences');
      _preferences = await SharedPreferences.getInstance();
      _initialized = true;
      PlatformLogger.info('✅ SharedPreferences 初始化成功');
    } catch (e, stackTrace) {
      PlatformLogger.warning('⚠️ SharedPreferences 初始化失败,使用内存缓存模式: $e');
      // 如果 SharedPreferences 不可用(如鸿蒙平台),使用内存缓存
      _initialized = true;
      _preferences = null;
    }
  }

  /// 保存字符串
  Future<bool> setString(String key, String value) async {
    try {
      _memoryCache[key] = value;
      if (_preferences != null) {
        return await _preferences!.setString(key, value);
      }
      PlatformLogger.debug('内存缓存: 保存字符串 $key = $value');
      return true;
    } catch (e) {
      PlatformLogger.warning('保存字符串失败: $key, $e');
      return false;
    }
  }

  /// 获取字符串
  Future<String?> getString(String key) async {
    try {
      if (_preferences != null) {
        final value = _preferences!.getString(key);
        PlatformLogger.debug('SharedPreferences: 获取字符串 $key = $value');
        return value;
      }
      final value = _memoryCache[key] as String?;
      PlatformLogger.debug('内存缓存: 获取字符串 $key = $value');
      return value;
    } catch (e) {
      PlatformLogger.warning('获取字符串失败: $key, $e');
      return _memoryCache[key] as String?;
    }
  }

  /// 保存 Map
  Future<bool> setMap(String key, Map<String, dynamic> value) async {
    try {
      _memoryCache[key] = value;
      if (_preferences != null) {
        final jsonString = jsonEncode(value);
        return await _preferences!.setString(key, jsonString);
      }
      PlatformLogger.debug('内存缓存: 保存 Map $key');
      return true;
    } catch (e) {
      PlatformLogger.warning('保存 Map 失败: $key, $e');
      return false;
    }
  }

  /// 获取 Map
  Future<Map<String, dynamic>?> getMap(String key) async {
    try {
      if (_preferences != null) {
        final jsonString = _preferences!.getString(key);
        if (jsonString != null && jsonString.isNotEmpty) {
          final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
          PlatformLogger.debug('SharedPreferences: 获取 Map $key');
          return decoded;
        }
        return null;
      }
      final value = _memoryCache[key] as Map<String, dynamic>?;
      PlatformLogger.debug('内存缓存: 获取 Map $key');
      return value;
    } catch (e) {
      PlatformLogger.warning('获取 Map 失败: $key, $e');
      return _memoryCache[key] as Map<String, dynamic>?;
    }
  }

  /// 保存布尔值
  Future<bool> setBool(String key, bool value) async {
    try {
      _memoryCache[key] = value;
      if (_preferences != null) {
        return await _preferences!.setBool(key, value);
      }
      PlatformLogger.debug('内存缓存: 保存布尔值 $key = $value');
      return true;
    } catch (e) {
      PlatformLogger.warning('保存布尔值失败: $key, $e');
      return false;
    }
  }

  /// 获取布尔值
  Future<bool?> getBool(String key) async {
    try {
      if (_preferences != null) {
        final value = _preferences!.getBool(key);
        PlatformLogger.debug('SharedPreferences: 获取布尔值 $key = $value');
        return value;
      }
      final value = _memoryCache[key] as bool?;
      PlatformLogger.debug('内存缓存: 获取布尔值 $key = $value');
      return value;
    } catch (e) {
      PlatformLogger.warning('获取布尔值失败: $key, $e');
      return _memoryCache[key] as bool?;
    }
  }

  /// 保存整数
  Future<bool> setInt(String key, int value) async {
    try {
      _memoryCache[key] = value;
      if (_preferences != null) {
        return await _preferences!.setInt(key, value);
      }
      PlatformLogger.debug('内存缓存: 保存整数 $key = $value');
      return true;
    } catch (e) {
      PlatformLogger.warning('保存整数失败: $key, $e');
      return false;
    }
  }

  /// 获取整数
  Future<int?> getInt(String key) async {
    try {
      if (_preferences != null) {
        final value = _preferences!.getInt(key);
        PlatformLogger.debug('SharedPreferences: 获取整数 $key = $value');
        return value;
      }
      final value = _memoryCache[key] as int?;
      PlatformLogger.debug('内存缓存: 获取整数 $key = $value');
      return value;
    } catch (e) {
      PlatformLogger.warning('获取整数失败: $key, $e');
      return _memoryCache[key] as int?;
    }
  }

  /// 保存双精度浮点数
  Future<bool> setDouble(String key, double value) async {
    try {
      _memoryCache[key] = value;
      if (_preferences != null) {
        return await _preferences!.setDouble(key, value);
      }
      PlatformLogger.debug('内存缓存: 保存双精度浮点数 $key = $value');
      return true;
    } catch (e) {
      PlatformLogger.warning('保存双精度浮点数失败: $key, $e');
      return false;
    }
  }

  /// 获取双精度浮点数
  Future<double?> getDouble(String key) async {
    try {
      if (_preferences != null) {
        final value = _preferences!.getDouble(key);
        PlatformLogger.debug('SharedPreferences: 获取双精度浮点数 $key = $value');
        return value;
      }
      final value = _memoryCache[key] as double?;
      PlatformLogger.debug('内存缓存: 获取双精度浮点数 $key = $value');
      return value;
    } catch (e) {
      PlatformLogger.warning('获取双精度浮点数失败: $key, $e');
      return _memoryCache[key] as double?;
    }
  }

  /// 保存字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      _memoryCache[key] = value;
      if (_preferences != null) {
        return await _preferences!.setStringList(key, value);
      }
      PlatformLogger.debug('内存缓存: 保存字符串列表 $key');
      return true;
    } catch (e) {
      PlatformLogger.warning('保存字符串列表失败: $key, $e');
      return false;
    }
  }

  /// 获取字符串列表
  Future<List<String>?> getStringList(String key) async {
    try {
      if (_preferences != null) {
        final value = _preferences!.getStringList(key);
        PlatformLogger.debug('SharedPreferences: 获取字符串列表 $key');
        return value;
      }
      final value = _memoryCache[key] as List<String>?;
      PlatformLogger.debug('内存缓存: 获取字符串列表 $key');
      return value;
    } catch (e) {
      PlatformLogger.warning('获取字符串列表失败: $key, $e');
      return _memoryCache[key] as List<String>?;
    }
  }

  /// 删除指定 key
  Future<bool> remove(String key) async {
    try {
      _memoryCache.remove(key);
      if (_preferences != null) {
        return await _preferences!.remove(key);
      }
      PlatformLogger.debug('内存缓存: 删除 key $key');
      return true;
    } catch (e) {
      PlatformLogger.warning('删除 key 失败: $key, $e');
      return false;
    }
  }

  /// 清空所有数据
  Future<bool> clear() async {
    try {
      _memoryCache.clear();
      if (_preferences != null) {
        return await _preferences!.clear();
      }
      PlatformLogger.debug('内存缓存: 清空所有数据');
      return true;
    } catch (e) {
      PlatformLogger.warning('清空数据失败: $e');
      return false;
    }
  }

  /// 检查 key 是否存在
  Future<bool> containsKey(String key) async {
    try {
      if (_preferences != null) {
        return _preferences!.containsKey(key);
      }
      return _memoryCache.containsKey(key);
    } catch (e) {
      PlatformLogger.warning('检查 key 失败: $key, $e');
      return _memoryCache.containsKey(key);
    }
  }

  /// 获取所有 keys
  Set<String> getKeys() {
    try {
      if (_preferences != null) {
        return _preferences!.getKeys();
      }
      return _memoryCache.keys.toSet();
    } catch (e) {
      PlatformLogger.warning('获取所有 keys 失败: $e');
      return _memoryCache.keys.toSet();
    }
  }

  /// 重新加载缓存(仅当 SharedPreferences 可用时有效)
  Future<void> reload() async {
    try {
      if (_preferences != null) {
        await _preferences!.reload();
        PlatformLogger.debug('SharedPreferences 缓存已重新加载');
      }
    } catch (e) {
      PlatformLogger.warning('重新加载缓存失败: $e');
    }
  }
}