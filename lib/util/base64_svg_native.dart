import 'package:flutter/material.dart';

/// 条件导入 stub（非 Web 平台编译时加载此文件，避免引入 dart:html）
/// 运行时不会被调用，由 kIsWeb 守护
Widget buildSvgForWeb(String dataUri, BoxFit fit, {Key? key}) {
  throw UnsupportedError(
    'buildSvgForWeb should not be called on non-web platforms',
  );
}
