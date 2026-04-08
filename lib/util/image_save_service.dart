import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'web_download_stub.dart' if (dart.library.html) 'web_download.dart'
    as webdl;

/// 跨平台图片保存/下载服务，将平台差异与异常提示封装在此处
class ImageSaveService {
  /// 保存内置资源图片到相册（移动端）或触发下载（Web）
  static Future<void> saveAssetImage(
      BuildContext context, String assetPath, String name) async {
    try {
      // 读取内置资源
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();

      if (kIsWeb) {
        final mimeType = _toMimeType(_ext(assetPath));
        final ok = await webdl.downloadBytes(name, bytes, mimeType);
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ok ? '已开始下载' : '下载失败')),
        );
        return;
      }

      // Android/iOS：保存到系统相册
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        name: name,
        quality: 100,
        isReturnImagePathOfIOS: true,
      );

      final success = _isSaveSuccess(result);
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '已保存到相册' : '保存失败'),
          backgroundColor: success ? null : Colors.red,
        ),
      );
    } on PlatformException catch (_) {
      // 和谐OS或不支持场景：给出友好降级提示
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('当前平台暂不支持直接保存，请截图或使用下载方式'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失败：$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static String _ext(String assetPath) {
    final dot = assetPath.lastIndexOf('.');
    if (dot != -1 && dot + 1 < assetPath.length) {
      final ext = assetPath.substring(dot + 1).toLowerCase();
      if (ext.isNotEmpty) return ext;
    }
    return 'jpg';
  }

  static String _toMimeType(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  /// 兼容多平台多返回结构的成功判断
  static bool _isSaveSuccess(dynamic result) {
    try {
      if (result == null) return false;
      if (result is bool) return result;
      if (result is Map) {
        if (result['isSuccess'] == true) return true;
        final status = result['status'];
        if (status == 'success' || status == true) return true;
        final filePath = result['filePath'] ?? result['savedFilePath'];
        if (filePath is String && filePath.isNotEmpty) return true;
        return false;
      }
      if (result is String) return result.isNotEmpty;
      return false;
    } catch (_) {
      return false;
    }
  }
}
