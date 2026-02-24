import 'package:flutter/material.dart';
import 'package:hjproject/repository/api/local_bills_storage_api.dart';
import 'package:hjproject/home/bootstrap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hjproject/login/model/users.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  UserDataSingleton().init(sharedPreferences);
  final billsApi = LocalStorageBillsApi(
    plugin: sharedPreferences,
  );

  bootstrap(billsApi: billsApi);
}
