import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// 权限处理辅助类
class PermissionHelper {
  /// 请求照片权限
  static Future<bool> requestPhotoPermission() async {
    if (kIsWeb) return true;

    if (Platform.isAndroid) {
      // 先尝试使用 photos 权限（Android 13+）
      // 如果失败，则回退到 storage 权限（Android 12及以下）
      try {
        final photosStatus = await Permission.photos.request();
        if (photosStatus.isGranted) {
          return true;
        }
      } catch (e) {
        // photos 权限不可用，可能是低版本Android
      }
      
      // 回退到存储权限
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } else if (Platform.isIOS) {
      // iOS 使用照片权限
      final status = await Permission.photos.request();
      return status.isGranted;
    }

    return false;
  }

  /// 请求相机权限
  static Future<bool> requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// 检查照片权限状态
  static Future<PermissionStatus> getPhotoPermissionStatus() async {
    if (kIsWeb) return PermissionStatus.granted;

    if (Platform.isAndroid) {
      // 先检查 photos 权限状态
      try {
        final photosStatus = await Permission.photos.status;
        if (photosStatus.isGranted) {
          return photosStatus;
        }
      } catch (e) {
        // photos 权限不可用
      }
      
      // 检查存储权限状态
      return await Permission.storage.status;
    } else if (Platform.isIOS) {
      // iOS 使用照片权限
      return await Permission.photos.status;
    }

    return PermissionStatus.denied;
  }

  /// 检查相机权限状态
  static Future<PermissionStatus> getCameraPermissionStatus() async {
    if (kIsWeb) return PermissionStatus.granted;
    return await Permission.camera.status;
  }

  /// 显示权限设置对话框
  static Future<bool> showPermissionDialog() async {
    return await openAppSettings();
  }

  /// 获取权限被拒绝的提示信息
  static String getPermissionDeniedMessage(String permissionType) {
    if (Platform.isAndroid) {
      return '需要$permissionType权限才能使用此功能。请在设置中开启权限。';
    } else if (Platform.isIOS) {
      return '需要$permissionType权限才能使用此功能。请在"设置 > 隐私与安全性"中开启权限。';
    }
    return '需要$permissionType权限才能使用此功能。';
  }
}