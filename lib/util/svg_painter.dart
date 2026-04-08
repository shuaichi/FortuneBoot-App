import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;

/// 轻量级 SVG 验证码绘制器
/// 直接使用 dart:ui Canvas API 绘制，不依赖任何第三方 SVG 渲染库
/// 支持验证码 SVG 中常见的元素：rect, line, circle, ellipse, text, path(基础)
class SvgCaptchaPainter extends CustomPainter {
  final String svgString;

  SvgCaptchaPainter(this.svgString);

  @override
  void paint(Canvas canvas, Size size) {
    try {
      final doc = xml.XmlDocument.parse(svgString);
      final svgElement = doc.rootElement;

      // 获取 SVG 原始尺寸
      final double svgW =
          double.tryParse(svgElement.getAttribute('width') ?? '') ?? size.width;
      final double svgH =
          double.tryParse(svgElement.getAttribute('height') ?? '') ??
              size.height;

      // 缩放 Canvas 以适配容器尺寸
      final double scaleX = size.width / svgW;
      final double scaleY = size.height / svgH;
      canvas.scale(scaleX, scaleY);

      // 遍历绘制所有子元素
      for (final node in svgElement.children) {
        if (node is xml.XmlElement) {
          _drawElement(canvas, node);
        }
      }
    } catch (e) {
      debugPrint('[SvgCaptchaPainter] paint error: $e');
    }
  }

  void _drawElement(Canvas canvas, xml.XmlElement element) {
    switch (element.name.local) {
      case 'rect':
        _drawRect(canvas, element);
        break;
      case 'line':
        _drawLine(canvas, element);
        break;
      case 'circle':
        _drawCircle(canvas, element);
        break;
      case 'ellipse':
        _drawEllipse(canvas, element);
        break;
      case 'text':
        _drawText(canvas, element);
        break;
      case 'path':
        _drawPath(canvas, element);
        break;
      case 'g':
        // 递归处理 <g> 分组
        for (final child in element.children) {
          if (child is xml.XmlElement) {
            _drawElement(canvas, child);
          }
        }
        break;
    }
  }

  void _drawRect(Canvas canvas, xml.XmlElement el) {
    final double x = _d(el, 'x');
    final double y = _d(el, 'y');
    double w = _d(el, 'width');
    double h = _d(el, 'height');

    // 处理百分比宽高
    final wStr = el.getAttribute('width') ?? '';
    final hStr = el.getAttribute('height') ?? '';
    if (wStr.endsWith('%')) {
      final svgW = double.tryParse(
              el.parent?.getAttribute('width') ?? '') ??
          160;
      w = svgW * (double.tryParse(wStr.replaceAll('%', '')) ?? 100) / 100;
    }
    if (hStr.endsWith('%')) {
      final svgH = double.tryParse(
              el.parent?.getAttribute('height') ?? '') ??
          60;
      h = svgH * (double.tryParse(hStr.replaceAll('%', '')) ?? 100) / 100;
    }

    final rect = Rect.fromLTWH(x, y, w, h);

    final fill = _parseColor(el.getAttribute('fill'));
    if (fill != null) {
      canvas.drawRect(rect, Paint()..color = fill);
    }

    final stroke = _parseColor(el.getAttribute('stroke'));
    if (stroke != null) {
      canvas.drawRect(
        rect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = _d(el, 'stroke-width', fallback: 1),
      );
    }
  }

  void _drawLine(Canvas canvas, xml.XmlElement el) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _d(el, 'stroke-width', fallback: 1)
      ..color = _parseColor(el.getAttribute('stroke')) ?? Colors.black;

    final opacity = double.tryParse(el.getAttribute('opacity') ?? '1') ?? 1.0;
    paint.color = paint.color.withOpacity(opacity);

    canvas.drawLine(
      Offset(_d(el, 'x1'), _d(el, 'y1')),
      Offset(_d(el, 'x2'), _d(el, 'y2')),
      paint,
    );
  }

  void _drawCircle(Canvas canvas, xml.XmlElement el) {
    final cx = _d(el, 'cx');
    final cy = _d(el, 'cy');
    final r = _d(el, 'r');
    final opacity = double.tryParse(el.getAttribute('opacity') ?? '1') ?? 1.0;

    final fill = _parseColor(el.getAttribute('fill'));
    if (fill != null) {
      canvas.drawCircle(
          Offset(cx, cy), r, Paint()..color = fill.withOpacity(opacity));
    }

    final stroke = _parseColor(el.getAttribute('stroke'));
    if (stroke != null) {
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = stroke.withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _d(el, 'stroke-width', fallback: 1),
      );
    }
  }

  void _drawEllipse(Canvas canvas, xml.XmlElement el) {
    final cx = _d(el, 'cx');
    final cy = _d(el, 'cy');
    final rx = _d(el, 'rx');
    final ry = _d(el, 'ry');
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2);

    final fill = _parseColor(el.getAttribute('fill'));
    if (fill != null) {
      canvas.drawOval(rect, Paint()..color = fill);
    }
  }

  void _drawText(Canvas canvas, xml.XmlElement el) {
    final x = _d(el, 'x');
    final y = _d(el, 'y');
    final text = el.innerText;
    final fill = _parseColor(el.getAttribute('fill')) ?? Colors.black;
    final fontSize =
        double.tryParse(el.getAttribute('font-size') ?? '20') ?? 20;
    final fontWeight = (el.getAttribute('font-weight') ?? '') == 'bold'
        ? FontWeight.bold
        : FontWeight.normal;
    final opacity = double.tryParse(el.getAttribute('opacity') ?? '1') ?? 1.0;

    final style = el.getAttribute('style') ?? '';
    final rotation = _parseTransformRotation(el.getAttribute('transform'));

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: fill.withOpacity(opacity),
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: style.contains('italic') ? FontStyle.italic : FontStyle.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    if (rotation != null) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation * 3.14159265 / 180);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    } else {
      tp.paint(canvas, Offset(x, y - tp.height));
    }
  }

  void _drawPath(Canvas canvas, xml.XmlElement el) {
    final d = el.getAttribute('d');
    if (d == null || d.isEmpty) return;
    try {
      final path = _parseSvgPath(d);
      final fill = _parseColor(el.getAttribute('fill'));
      if (fill != null && el.getAttribute('fill') != 'none') {
        canvas.drawPath(path, Paint()..color = fill);
      }
      final stroke = _parseColor(el.getAttribute('stroke'));
      if (stroke != null) {
        canvas.drawPath(
          path,
          Paint()
            ..color = stroke
            ..style = PaintingStyle.stroke
            ..strokeWidth = _d(el, 'stroke-width', fallback: 1),
        );
      }
    } catch (e) {
      debugPrint('[SvgCaptchaPainter] path parse error: $e');
    }
  }

  // ========== 工具方法 ==========

  double _d(xml.XmlElement el, String attr, {double fallback = 0}) {
    return double.tryParse(el.getAttribute(attr) ?? '') ?? fallback;
  }

  double? _parseTransformRotation(String? transform) {
    if (transform == null) return null;
    final match = RegExp(r'rotate\(([-\d.]+)').firstMatch(transform);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }

  /// 解析 CSS/SVG 颜色值
  Color? _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty || colorStr == 'none') return null;

    // 命名颜色映射（验证码常用子集）
    const namedColors = <String, Color>{
      'black': Colors.black,
      'white': Colors.white,
      'red': Colors.red,
      'green': Colors.green,
      'blue': Colors.blue,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'gray': Colors.grey,
      'grey': Colors.grey,
    };

    final lower = colorStr.trim().toLowerCase();
    if (namedColors.containsKey(lower)) return namedColors[lower];

    // hex 颜色 (#fff, #ffffff, #rrggbbaa)
    if (lower.startsWith('#')) {
      String hex = lower.substring(1);
      if (hex.length == 3) {
        hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
      }
      if (hex.length == 6) hex = 'ff$hex';
      final val = int.tryParse(hex, radix: 16);
      if (val != null) return Color(val);
    }

    // rgb(r,g,b) / rgba(r,g,b,a)
    final rgbMatch =
        RegExp(r'rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)')
            .firstMatch(lower);
    if (rgbMatch != null) {
      final r = int.parse(rgbMatch.group(1)!);
      final g = int.parse(rgbMatch.group(2)!);
      final b = int.parse(rgbMatch.group(3)!);
      final a = rgbMatch.group(4) != null
          ? (double.parse(rgbMatch.group(4)!) * 255).round()
          : 255;
      return Color.fromARGB(a, r, g, b);
    }

    return null;
  }

  /// 基础 SVG path 解析器（支持 M, L, H, V, C, S, Q, Z 命令）
  ui.Path _parseSvgPath(String d) {
    final path = ui.Path();
    final tokens = RegExp(r'[MmLlHhVvCcSsQqTtAaZz]|[-+]?[\d]*\.?[\d]+(?:[eE][-+]?\d+)?')
        .allMatches(d)
        .map((m) => m.group(0)!)
        .toList();

    double cx = 0, cy = 0; // current point
    int i = 0;

    double next() => double.parse(tokens[i++]);

    while (i < tokens.length) {
      final cmd = tokens[i];
      if (RegExp(r'[A-Za-z]').hasMatch(cmd)) {
        i++;
      } else {
        break;
      }

      switch (cmd) {
        case 'M':
          cx = next(); cy = next();
          path.moveTo(cx, cy);
          while (i < tokens.length && !RegExp(r'[A-Za-z]').hasMatch(tokens[i])) {
            cx = next(); cy = next();
            path.lineTo(cx, cy);
          }
          break;
        case 'm':
          cx += next(); cy += next();
          path.moveTo(cx, cy);
          while (i < tokens.length && !RegExp(r'[A-Za-z]').hasMatch(tokens[i])) {
            cx += next(); cy += next();
            path.lineTo(cx, cy);
          }
          break;
        case 'L':
          while (i < tokens.length && !RegExp(r'[A-Za-z]').hasMatch(tokens[i])) {
            cx = next(); cy = next();
            path.lineTo(cx, cy);
          }
          break;
        case 'l':
          while (i < tokens.length && !RegExp(r'[A-Za-z]').hasMatch(tokens[i])) {
            cx += next(); cy += next();
            path.lineTo(cx, cy);
          }
          break;
        case 'H':
          cx = next(); path.lineTo(cx, cy);
          break;
        case 'h':
          cx += next(); path.lineTo(cx, cy);
          break;
        case 'V':
          cy = next(); path.lineTo(cx, cy);
          break;
        case 'v':
          cy += next(); path.lineTo(cx, cy);
          break;
        case 'C':
          while (i < tokens.length && !RegExp(r'[A-Za-z]').hasMatch(tokens[i])) {
            final x1 = next(), y1 = next(), x2 = next(), y2 = next();
            cx = next(); cy = next();
            path.cubicTo(x1, y1, x2, y2, cx, cy);
          }
          break;
        case 'c':
          while (i < tokens.length && !RegExp(r'[A-Za-z]').hasMatch(tokens[i])) {
            final x1 = cx + next(), y1 = cy + next();
            final x2 = cx + next(), y2 = cy + next();
            cx += next(); cy += next();
            path.cubicTo(x1, y1, x2, y2, cx, cy);
          }
          break;
        case 'Q':
          while (i < tokens.length && !RegExp(r'[A-Za-z]').hasMatch(tokens[i])) {
            final x1 = next(), y1 = next();
            cx = next(); cy = next();
            path.quadraticBezierTo(x1, y1, cx, cy);
          }
          break;
        case 'q':
          while (i < tokens.length && !RegExp(r'[A-Za-z]').hasMatch(tokens[i])) {
            final x1 = cx + next(), y1 = cy + next();
            cx += next(); cy += next();
            path.quadraticBezierTo(x1, y1, cx, cy);
          }
          break;
        case 'Z':
        case 'z':
          path.close();
          break;
        default:
          // 跳过不支持的命令参数
          while (i < tokens.length && !RegExp(r'[A-Za-z]').hasMatch(tokens[i])) {
            i++;
          }
          break;
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant SvgCaptchaPainter oldDelegate) {
    return oldDelegate.svgString != svgString;
  }
}