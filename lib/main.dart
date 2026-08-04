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
