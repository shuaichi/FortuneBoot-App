import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart'
    show MissingPluginException, PlatformException, rootBundle;
import 'package:fortuneboot/util/web_download_stub.dart'
    if (dart.library.html) 'package:fortuneboot/util/web_download.dart'
    as webdl;
import 'package:fortuneboot_ohos_security/fortuneboot_ohos_security.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

enum ImageSaveResult { saved, downloadStarted, failed, unsupported }

/// 跨平台图片保存/下载服务，将平台差异封装在此处。
class ImageSaveService {
  /// 保存内置资源图片到相册（移动端）或触发下载（Web）。
  static Future<ImageSaveResult> saveAssetImage(
    String assetPath,
    String name, {
    FortunebootOhosSecurity? ohosSecurity,
    String? operatingSystem,
  }) async {
    try {
      final data = await rootBundle.load(assetPath);
      return saveBytes(
        data.buffer.asUint8List(),
        name,
        mimeHint: _ext(assetPath),
        ohosSecurity: ohosSecurity,
        operatingSystem: operatingSystem,
      );
    } on Exception catch (_) {
      return ImageSaveResult.failed;
    }
  }

  /// 保存内存中的图片到相册（移动端）或触发下载（Web）。
  static Future<ImageSaveResult> saveBytes(
    Uint8List bytes,
    String name, {
    String? mimeHint,
    FortunebootOhosSecurity? ohosSecurity,
    String? operatingSystem,
  }) async {
    try {
      if (kIsWeb) {
        final mimeType = _toMimeType(mimeHint ?? _ext(name));
        final ok = await webdl.downloadBytes(name, bytes, mimeType);
        return ok ? ImageSaveResult.downloadStarted : ImageSaveResult.failed;
      }

      final os = operatingSystem ?? Platform.operatingSystem;
      if (os == 'ohos') {
        return _saveOnOhos(
          bytes: bytes,
          fileName: name,
          ohosSecurity: ohosSecurity ?? FortunebootOhosSecurity(),
        );
      }

      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        name: name,
        quality: 100,
        isReturnImagePathOfIOS: true,
      );
      return _isSaveSuccess(result)
          ? ImageSaveResult.saved
          : ImageSaveResult.failed;
    } on MissingPluginException catch (_) {
      return ImageSaveResult.unsupported;
    } on PlatformException catch (_) {
      return ImageSaveResult.unsupported;
    } on Exception catch (_) {
      return ImageSaveResult.failed;
    }
  }

  static Future<ImageSaveResult> _saveOnOhos({
    required Uint8List bytes,
    required String fileName,
    required FortunebootOhosSecurity ohosSecurity,
  }) async {
    try {
      final ok = await ohosSecurity.saveImageToGallery(
        bytes: bytes,
        fileName: fileName,
      );
      return ok ? ImageSaveResult.saved : ImageSaveResult.failed;
    } on MissingPluginException catch (_) {
      return ImageSaveResult.unsupported;
    } on PlatformException catch (_) {
      return ImageSaveResult.failed;
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

  /// 兼容多平台多返回结构的成功判断。
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
    } on Exception catch (_) {
      return false;
    }
  }
}
