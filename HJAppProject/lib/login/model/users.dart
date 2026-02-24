import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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

  // 数据存储核心结构
  Map<String, dynamic> _userData = {};

  // 工厂构造函数返回唯一实例
  factory UserDataSingleton() => _instance;

  // 私有构造函数防止外部实例化
  UserDataSingleton._internal();

  void init(SharedPreferences pre) {
    prefs = pre;
  }

  // 数据操作方法
  void setMap(String key, Map<String, dynamic> value) {
    _userData[key] = value;
    if (prefs == null) {
      SharedPreferences.getInstance().then((pre) {
        prefs = pre;
        prefs!.setString(key, jsonEncode(value));
      });
    } else {
      prefs!.setString(key, jsonEncode(value));
    }
  }

  void setStr(String key, String value) {
    _userData[key] = value;
    if (prefs == null) {
      SharedPreferences.getInstance().then((pre) {
        prefs = pre;
        prefs!.setString(key, value);
      });
    } else {
      prefs!.setString(key, value);
    }
  }

  Future<Map<String, dynamic>?> getMap(String key) async {
    if (_userData[key] != null) {
      return _userData[key] as Map<String, dynamic>?;
    }
    prefs ??= await SharedPreferences.getInstance();
    String? localValue = prefs!.getString(key);
    var localData =
        Map<String, dynamic>.from(jsonDecode(localValue ?? '{}') as Map? ?? {});
    if (localData.isNotEmpty) {
      _userData[key] = localData;
    }
    return localData;
  }

  Future<String?> getStr(String key) async {
    if (_userData[key] != null) {
      return _userData[key] as String?;
    }
    prefs ??= await SharedPreferences.getInstance();
    String? localValue = prefs!.getString(key);
    if (localValue != null) {
      _userData[key] = localValue;
    }
    return localValue;
  }

  void remove(String key) {
    _userData.remove(key);
    if (prefs == null) {
      SharedPreferences.getInstance().then((value) {
        prefs = value;
        prefs!.remove(key);
      });
    } else {
      prefs!.remove(key);
    }
  }

  bool containsKey(String key) => _userData.containsKey(key);
}
