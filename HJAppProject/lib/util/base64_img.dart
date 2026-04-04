import 'dart:convert';
import 'package:flutter/material.dart';

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
    try {
      String pureBase64 = base64String;
      
      // 处理 Data URL 格式 (data:image/xxx;base64,xxxxx)
      if (base64String.contains(',')) {
        pureBase64 = base64String.split(',')[1];
      }
      
      return Image.memory(
        base64Decode(pureBase64),
        fit: fit,
        errorBuilder: (_, __, ___) => errorWidget ?? const Icon(Icons.error),
      );
    } catch (e) {
      return errorWidget ?? const Text("图片解析失败");
    }
  }
}
