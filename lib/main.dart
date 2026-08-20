import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:fortuneboot/core/app/fx_app.dart';
import 'package:fortuneboot/core/app/fx_bloc_observer.dart';
import 'package:fortuneboot/features/accounts/accounts_registration.dart';
import 'package:fortuneboot/features/bill_editor/bill_editor_registration.dart';
import 'package:fortuneboot/features/bills/bills_registration.dart';
import 'package:fortuneboot/features/books/books_registration.dart';
import 'package:fortuneboot/features/categories/categories_registration.dart';
import 'package:fortuneboot/features/dashboard/dashboard_registration.dart';
import 'package:fortuneboot/features/goods/goods_registration.dart';
import 'package:fortuneboot/features/group_users/group_users_registration.dart';
import 'package:fortuneboot/features/io/io_registration.dart';
import 'package:fortuneboot/features/members/members_registration.dart';
import 'package:fortuneboot/features/orders/orders_registration.dart';
import 'package:fortuneboot/features/payees/payees_registration.dart';
import 'package:fortuneboot/features/profile/profile_registration.dart';
import 'package:fortuneboot/features/recurring/recurring_registration.dart';
import 'package:fortuneboot/features/stats/stats_registration.dart';
import 'package:fortuneboot/features/tags/tags_registration.dart';
import 'package:fortuneboot/login/model/users.dart';
import 'package:fortuneboot/login/server/server_endpoint.dart';
import 'package:fortuneboot/util/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    log(error.toString(), stackTrace: stack);
    return true;
  };
  Bloc.observer = const FxBlocObserver();

  final sharedPreferences = await SharedPreferences.getInstance();
  UserDataSingleton().init(sharedPreferences);

  // 热重启/冷启动时同步恢复 baseUrl 与 auth header 到 DioClient。
  // DioClient 是内存单例，shift+r 热重启会清空其 baseUrl；若不在此恢复，
  // 未经过 BaseUrlConfigPage 初始化流程时所有请求都会失败。
  _restoreDioClientFromStorage(sharedPreferences);

  // 注册各 feature 的 MainShell tab 槽位与路由。
  registerDashboardSlot();
  registerBillsSlot();
  registerStatsSlot();
  registerBillEditorFeature();
  registerAccountsFeature();
  // 管理类
  registerCategoriesFeature();
  registerTagsFeature();
  registerPayeesFeature();
  registerMembersFeature();
  // 高级模块
  registerGoodsFeature();
  registerOrdersFeature();
  registerIoFeature();
  registerRecurringFeature();
  registerGroupUsersFeature();
  registerBooksFeature();
  registerProfileFeature();

  runApp(const FxApp());
}

/// 从本地存储恢复 baseUrl 与登录态到 DioClient 单例。
/// 覆盖热重启场景（不重新经过 BaseUrlConfigPage 初始化）。
void _restoreDioClientFromStorage(SharedPreferences prefs) {
  final protocol = prefs.getString(UserDataSingleton.baseUrlProtocol);
  final domain = prefs.getString(UserDataSingleton.baseUrlDomain);
  final port = prefs.getString(UserDataSingleton.baseUrlPort);
  if (protocol != null && domain != null) {
    try {
      final endpoint = ServerEndpoint.parse(
        protocol: protocol,
        host: domain,
        port: port,
      );
      DioClient().updateBaseUrl(endpoint.apiBaseUri.toString());
    } on ServerEndpointFormatException {
      // Keep the persisted values for correction in the configuration screen.
    }
  }

  final tokenRaw = prefs.getString(UserDataSingleton.userToken);
  if (tokenRaw != null && tokenRaw.isNotEmpty) {
    try {
      final decoded = jsonDecode(tokenRaw);
      if (decoded is Map && decoded.isNotEmpty) {
        DioClient().setAuthHeader(Map<String, dynamic>.from(decoded));
      }
    } on FormatException {
      // 存储损坏时忽略，交由 BaseUrlConfigPage 重新登录流程处理。
    }
  }
}
