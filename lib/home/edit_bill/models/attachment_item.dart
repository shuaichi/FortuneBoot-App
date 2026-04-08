import 'dart:io';
import 'package:flutter/foundation.dart';

/// 附件项模型
@immutable
class AttachmentItem {
  final String id;
  final String name;
  final String path;
  final int size;
  final String mimeType;
  final AttachmentType type;
  final File? file; // 本地文件对象
  final Uint8List? bytes; // Web平台使用的字节数据

  const AttachmentItem({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.mimeType,
    required this.type,
    this.file,
    this.bytes,
  });

  /// 获取文件大小的可读格式
  String get sizeFormatted {
    if (size < 1024) {
      return '${size}B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  /// 获取文件扩展名
  String get extension {
    // 优先从文件名获取扩展名，如果没有点号则从 MIME 类型推断
    final fileName = name.isNotEmpty ? name : path;
    if (fileName.contains('.')) {
      return fileName.split('.').last.toLowerCase();
    }
    
    // 从 MIME 类型推断扩展名
    switch (mimeType) {
      case 'image/jpeg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'image/gif':
        return 'gif';
      case 'image/webp':
        return 'webp';
      case 'application/pdf':
        return 'pdf';
      case 'application/msword':
        return 'doc';
      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        return 'docx';
      case 'application/vnd.ms-excel':
        return 'xls';
      case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
        return 'xlsx';
      default:
        return 'unknown';
    }
  }

  /// 是否为图片文件
  bool get isImage {
    return type == AttachmentType.image;
  }

  /// 是否为文档文件
  bool get isDocument {
    return type == AttachmentType.document;
  }

  /// 复制并修改属性
  AttachmentItem copyWith({
    String? id,
    String? name,
    String? path,
    int? size,
    String? mimeType,
    AttachmentType? type,
    File? file,
    Uint8List? bytes,
  }) {
    return AttachmentItem(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
      type: type ?? this.type,
      file: file ?? this.file,
      bytes: bytes ?? this.bytes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttachmentItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AttachmentItem{id: $id, name: $name, size: $size, type: $type}';
  }
}

/// 附件类型枚举
enum AttachmentType {
  image,
  document,
  other;

  /// 根据MIME类型判断附件类型
  static AttachmentType fromMimeType(String mimeType) {
    if (mimeType.startsWith('image/')) {
      return AttachmentType.image;
    } else if (mimeType.startsWith('application/pdf') ||
        mimeType.startsWith('application/msword') ||
        mimeType.startsWith('application/vnd.openxmlformats-officedocument') ||
        mimeType.startsWith('text/')) {
      return AttachmentType.document;
    } else {
      return AttachmentType.other;
    }
  }
}