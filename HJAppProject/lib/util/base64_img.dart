import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hjproject/util/svg_painter.dart';

import 'package:hjproject/util/base64_svg_native.dart'
    if (dart.library.html) 'package:hjproject/util/base64_svg_web.dart'
    as svg_platform;

class Base64Image extends StatelessWidget {
  final String base64String;
  final BoxFit fit;
  final Widget? errorWidget;

  const Base64Image({
    super.key,
    required this.base64String,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (base64String.isEmpty) {
      return errorWidget ?? const Text("图片数据为空");
    }

    try {
      final bool isSvg = base64String.contains('image/svg+xml');

      if (isSvg && kIsWeb) {
        // ========== Web 平台 ==========
        return svg_platform.buildSvgForWeb(
          base64String,
          fit,
          key: ValueKey<String>(base64String),
        );
      }

      // ========== 非 Web 平台 ==========
      String pureBase64 = base64String;
      if (base64String.contains(',')) {
        pureBase64 = base64String.split(',')[1];
      }
      pureBase64 = pureBase64.trim();

      if (pureBase64.isEmpty) {
        return errorWidget ?? const Text("图片数据为空");
      }

      final Uint8List bytes = base64Decode(pureBase64);

      if (isSvg) {
        // SVG 格式（非 Web 平台）：Android/iOS/鸿蒙/macOS/Linux/Windows
        // 使用自定义 CustomPainter 直接用 Canvas API 绘制 SVG
        // 不依赖 flutter_svg，彻底避免鸿蒙等平台的兼容性问题
        final String svgString = utf8.decode(bytes);
        return LayoutBuilder(
          builder: (context, constraints) {
            final double w =
                constraints.maxWidth.isFinite ? constraints.maxWidth : 200;
            final double h =
                constraints.maxHeight.isFinite ? constraints.maxHeight : 54;
            return CustomPaint(
              size: Size(w, h),
              painter: SvgCaptchaPainter(svgString),
            );
          },
        );
      } else {
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (_, __, ___) =>
              errorWidget ?? const Icon(Icons.error),
        );
      }
    } on FormatException catch (_) {
      return errorWidget ?? const Text("图片解析失败");
    } catch (e) {
      debugPrint('[Base64Image] Exception: $e');
      return errorWidget ?? const Text("图片解析失败");
    }
  }
}