import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:fortuneboot/home/edit_bill/models/attachment_item.dart';
import 'package:fortuneboot/home/edit_bill/services/permission_helper.dart';

// https://pub.dev/packages/permission_handler
enum PermissionType {
  camera,
  photo,
  file,
}

/// 附件上传服务
class AttachmentService {
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const int maxTotalSize = 15 * 1024 * 1024; // 15MB
  static const int maxFileCount = 9; // 最多9个文件

  final ImagePicker _imagePicker = ImagePicker();

  /// 检查权限
  Future<bool> _checkPermissions({PermissionType? type}) async {
    if (kIsWeb) return true; // Web平台不需要权限检查
    
    switch (type) {
      case PermissionType.file:
        // 文件选择通常不需要特殊权限，FilePicker会处理
        return true;
      case PermissionType.camera:
        // 检查相机权限
        return await PermissionHelper.requestCameraPermission();
      case PermissionType.photo:
        // 检查照片权限
        return await PermissionHelper.requestPhotoPermission();
      default:
    }
    return false;
  }

  /// 从相册选择图片
  Future<List<AttachmentItem>> pickImagesFromGallery({
    int maxImages = 9,
  }) async {
    try {
      if (!await _checkPermissions(type: PermissionType.photo)) {
        throw Exception(PermissionHelper.getPermissionDeniedMessage('照片'));
      }

      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      return await _convertXFilesToAttachments(images);
    } catch (e) {
      if (e.toString().contains('权限') || e.toString().contains('permission')) {
        rethrow;
      }
      throw Exception('选择图片失败: $e');
    }
  }

  /// 拍照
  Future<AttachmentItem?> takePhoto() async {
    try {
      if (!await _checkPermissions(type: PermissionType.camera)) {
        throw Exception(PermissionHelper.getPermissionDeniedMessage('相机'));
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;

      final attachments = await _convertXFilesToAttachments([image]);
      return attachments.isNotEmpty ? attachments.first : null;
    } catch (e) {
      if (e.toString().contains('权限') || e.toString().contains('permission')) {
        rethrow;
      }
      throw Exception('拍照失败: $e');
    }
  }

  /// 选择文件
  Future<List<AttachmentItem>> pickFiles({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
        withData: kIsWeb, // Web平台需要获取字节数据
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      return await _convertPlatformFilesToAttachments(result.files);
    } catch (e) {
      throw Exception('选择文件失败: $e');
    }
  }

  /// 将XFile转换为AttachmentItem
  Future<List<AttachmentItem>> _convertXFilesToAttachments(
      List<XFile> xFiles) async {
    final List<AttachmentItem> attachments = [];

    for (final xFile in xFiles) {
      try {
        // Web平台处理文件名
        final String fileName = kIsWeb ? xFile.name : path.basename(xFile.path);
        print('lxjtodo: filePath: ${xFile.path}');
        final int fileSize = await xFile.length();

        // Web平台处理MIME类型
        final String mimeType = kIsWeb
            ? (xFile.mimeType ?? 'application/octet-stream')
            : (lookupMimeType(xFile.path) ?? 'application/octet-stream');

        // 检查文件大小
        if (fileSize > maxFileSize) {
          throw Exception('文件 $fileName 超过5MB限制');
        }

        File? file;
        Uint8List? bytes;
        String filePath;

        if (kIsWeb) {
          bytes = await xFile.readAsBytes();
          filePath = fileName; // Web平台使用文件名作为路径
        } else {
          file = File(xFile.path);
          filePath = xFile.path;
        }

        final attachment = AttachmentItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() +
              attachments.length.toString(),
          name: fileName,
          path: filePath,
          size: fileSize,
          mimeType: mimeType,
          type: AttachmentType.fromMimeType(mimeType),
          file: file,
          bytes: bytes,
        );

        attachments.add(attachment);
      } catch (e) {
        final fileName = kIsWeb ? xFile.name : xFile.path;
        print('转换文件失败: $fileName, 错误: $e');
        continue;
      }
    }

    return attachments;
  }

  /// 将PlatformFile转换为AttachmentItem
  Future<List<AttachmentItem>> _convertPlatformFilesToAttachments(
      List<PlatformFile> platformFiles) async {
    final List<AttachmentItem> attachments = [];

    for (final platformFile in platformFiles) {
      try {
        final String fileName = platformFile.name;
        final int fileSize = platformFile.size;

        // Web平台和移动平台的MIME类型处理
        final String mimeType = kIsWeb
            ? (platformFile.extension != null
                ? lookupMimeType('file.${platformFile.extension}') ??
                    'application/octet-stream'
                : 'application/octet-stream')
            : (lookupMimeType(fileName) ?? 'application/octet-stream');

        // 检查文件大小
        if (fileSize > maxFileSize) {
          throw Exception('文件 $fileName 超过5MB限制');
        }

        File? file;
        Uint8List? bytes;
        String filePath;

        if (kIsWeb) {
          bytes = platformFile.bytes;
          filePath = fileName; // Web平台使用文件名作为路径
        } else if (platformFile.path != null) {
          file = File(platformFile.path!);
          filePath = platformFile.path!;
        } else {
          throw Exception('无法获取文件路径');
        }

        final attachment = AttachmentItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() +
              attachments.length.toString(),
          name: fileName,
          path: filePath,
          size: fileSize,
          mimeType: mimeType,
          type: AttachmentType.fromMimeType(mimeType),
          file: file,
          bytes: bytes,
        );

        attachments.add(attachment);
      } catch (e) {
        print('转换文件失败: ${platformFile.name}, 错误: $e');
        continue;
      }
    }

    return attachments;
  }

  /// 验证附件列表
  static String? validateAttachments(List<AttachmentItem> attachments) {
    // 检查文件数量
    if (attachments.length > maxFileCount) {
      return '最多只能上传$maxFileCount个文件';
    }

    // 检查总文件大小
    final totalSize = attachments.fold<int>(0, (sum, item) => sum + item.size);
    if (totalSize > maxTotalSize) {
      return '文件总大小不能超过${(maxTotalSize / (1024 * 1024)).toStringAsFixed(0)}MB';
    }

    // 检查单个文件大小
    for (final attachment in attachments) {
      if (attachment.size > maxFileSize) {
        return '文件 ${attachment.name} 超过${(maxFileSize / (1024 * 1024)).toStringAsFixed(0)}MB限制';
      }
    }

    return null; // 验证通过
  }

  /// 获取文件图标
  static String getFileIcon(AttachmentItem attachment) {
    switch (attachment.type) {
      case AttachmentType.image:
        return '🖼️';
      case AttachmentType.document:
        if (attachment.extension == 'pdf') {
          return '📄';
        } else if (['doc', 'docx'].contains(attachment.extension)) {
          return '📝';
        } else if (['xls', 'xlsx'].contains(attachment.extension)) {
          return '📊';
        } else if (['ppt', 'pptx'].contains(attachment.extension)) {
          return '📋';
        } else {
          return '📄';
        }
      case AttachmentType.other:
        return '📎';
    }
  }
}
