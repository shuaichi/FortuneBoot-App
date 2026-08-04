import 'package:flutter/widgets.dart';

/// 全局导航键。登录页/会话过期回调/FxApp 共用，取代旧 AppView.navigatorKey。
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
