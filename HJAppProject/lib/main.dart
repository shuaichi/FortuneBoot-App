import 'package:flutter/material.dart';
import 'package:hjproject/repository/api/local_bills_storage_api.dart';
import 'package:hjproject/home/bootstrap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hjproject/login/model/users.dart';
import 'package:hjproject/utils/platform_logger.dart';

void main() async {
  PlatformLogger.info('🚀 应用启动 - 开始初始化');
  
  try {
    // 确保 Flutter 绑定初始化
    WidgetsFlutterBinding.ensureInitialized();
    PlatformLogger.info('✅ Flutter 绑定初始化完成');

    // 尝试初始化 SharedPreferences (兼容鸿蒙平台)
    SharedPreferences? sharedPreferences;
    try {
      sharedPreferences = await SharedPreferences.getInstance();
      PlatformLogger.info('✅ SharedPreferences 初始化成功');
      
      // 使用传统方式初始化
      UserDataSingleton().init(sharedPreferences);
    } catch (e) {
      PlatformLogger.warning('⚠️ SharedPreferences 初始化失败,使用鸿蒙兼容模式: $e');
      
      // 鸿蒙平台:使用异步初始化方式
      await UserDataSingleton().initAsync();
    }

    // 创建本地存储 API
    final billsApi = LocalStorageBillsApi(
      plugin: sharedPreferences,
    );
    PlatformLogger.info('✅ BillsApi 创建完成');

    // 启动应用
    PlatformLogger.info('🎯 开始启动应用 UI');
    bootstrap(billsApi: billsApi);
  } catch (e, stackTrace) {
    PlatformLogger.error('❌ 应用初始化失败', e, stackTrace);
    rethrow;
  }
}