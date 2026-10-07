import 'dart:developer';

import 'package:bloc/bloc.dart';

/// 全局 Bloc 观察者：仅记录错误。
class FxBlocObserver extends BlocObserver {
  const FxBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('Bloc error in ${bloc.runtimeType}: $error', stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
