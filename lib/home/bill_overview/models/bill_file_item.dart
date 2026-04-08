import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'bill_file_item.g.dart';

// 使用下面命令自动生成代码
// flutter pub run build_runner build
@immutable
@JsonSerializable()
class BillFileItem extends Equatable {
  int? fileId;
  String? contentType;
  String? fileData;
  int? size;
  String? originalName;
  int? billId;

  BillFileItem(
      {required this.fileId,
      required this.contentType,
      required this.fileData,
      required this.size,
      required this.originalName,
      required this.billId});

  factory BillFileItem.fromJson(Map<String, dynamic> json) =>
      _$BillFileItemFromJson(json);
  Map<String, dynamic> toJson() => _$BillFileItemToJson(this);

  // 重写 ==
  @override
  bool operator ==(Object other) {
    // 同一对象实例 => 直接返回 true
    if (identical(this, other)) return true;

    // 类型不同 => 返回 false
    if (other.runtimeType != runtimeType) return false;

    // 类型安全转换并比较字段
    return other is BillFileItem && other.fileId == fileId;
  }

  // 必须同时重写 hashCode（一致性原则）
  @override
  int get hashCode => fileId.hashCode ^ billId.hashCode;

  // String calculateStringMD5(String input) {
  //   // 将字符串转为 UTF-8 字节流
  //   List<int> bytes = utf8.encode(input);
  //   // 计算 MD5 哈希
  //   Digest digest = md5.convert(bytes);
  //   // 返回 16 进制字符串
  //   return digest.toString();
  // }

  // Future<String> saveImageToAppDir(Uint8List bytes, String fileName) async {
  //   try {
  //     final dir = await getApplicationDocumentsDirectory();
  //     final imageDir = Directory('${dir.path}/images');
  //     if (!await imageDir.exists()) await imageDir.create(recursive: true);

  //     final filePath = '${imageDir.path}/$fileName';
  //     await File(filePath).writeAsBytes(bytes);
  //     return filePath; // 返回本地路径
  //   } catch (e) {
  //     print('保存失败: $e');
  //     throw Exception('保存失败');
  //   }
  // }

  Uint8List decodeBase64ToImage(String base64String) {
    // 移除 Base64 前缀
    final pureBase64 = base64String.split(',').last;
    return base64Decode(pureBase64); // 返回二进制数据
  }

  // 显示图片
  Widget buildBase64Image(String base64String) {
    final bytes = decodeBase64ToImage(base64String);
    return Image.memory(
      bytes,
      height: 80,
    );
  }

  // copyWith
  BillFileItem copyWith(
      {int? fileId,
      String? contentType,
      String? fileData,
      int? size,
      String? originalName,
      int? billId}) {
    return BillFileItem(
        fileId: fileId ?? this.fileId,
        contentType: contentType ?? this.contentType,
        fileData: fileData ?? this.fileData,
        size: size ?? this.size,
        originalName: originalName ?? this.originalName,
        billId: billId ?? this.billId);
  }

  @override
  String toString() {
    return 'BillFileItem{billId: $billId fileId: $fileId, contentType: $contentType originalName: $originalName size: $size}';
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        billId,
        contentType,
        fileData,
        size,
        originalName,
      ];
}
