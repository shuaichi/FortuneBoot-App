// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_file_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillFileItem _$BillFileItemFromJson(Map<String, dynamic> json) => BillFileItem(
      fileId: (json['fileId'] as num?)?.toInt(),
      contentType: json['contentType'] as String?,
      fileData: json['fileData'] as String?,
      size: (json['size'] as num?)?.toInt(),
      originalName: json['originalName'] as String?,
      billId: (json['billId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BillFileItemToJson(BillFileItem instance) =>
    <String, dynamic>{
      'fileId': instance.fileId,
      'contentType': instance.contentType,
      'fileData': instance.fileData,
      'size': instance.size,
      'originalName': instance.originalName,
      'billId': instance.billId,
    };
