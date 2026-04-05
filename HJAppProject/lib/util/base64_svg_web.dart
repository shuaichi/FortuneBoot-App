// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

/// Web 平台：使用浏览器原生 <img> 标签渲染 SVG data URI
/// 这是 Web 上最可靠的 SVG 渲染方式，不受 CanvasKit 限制
Widget buildSvgForWeb(String dataUri, BoxFit fit, {Key? key}) {
  // 为每个不同的 dataUri 生成唯一的 viewType
  final String viewType = 'captcha-svg-${dataUri.hashCode}';

  // ignore: undefined_prefixed_name
  ui_web.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) {
      // 用 div 包裹 img，确保居中显示
      final container = html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'flex'
        ..style.alignItems = 'center'
        ..style.justifyContent = 'center'
        ..style.overflow = 'hidden';

      final img = html.ImageElement()
        ..src = dataUri
        ..style.maxWidth = '100%'
        ..style.maxHeight = '100%'
        ..style.display = 'block';

      switch (fit) {
        case BoxFit.contain:
          img.style.objectFit = 'contain';
          break;
        case BoxFit.fill:
          img.style.objectFit = 'fill';
          break;
        case BoxFit.cover:
        default:
          img.style.objectFit = 'cover';
          break;
      }

      container.append(img);
      return container;
    },
  );

  return HtmlElementView(key: key, viewType: viewType);
}