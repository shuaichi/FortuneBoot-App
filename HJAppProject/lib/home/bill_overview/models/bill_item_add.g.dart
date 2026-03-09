// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_item_add.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillItemAdd _$BillItemAddFromJson(Map<String, dynamic> json) => BillItemAdd(
      data: json['data'] == null
          ? null
          : BillItemAddData.fromJson(json['data'] as Map<String, dynamic>),
      files: (json['files'] as List<dynamic>?)
          ?.map((e) => BillFileItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BillItemAddToJson(BillItemAdd instance) =>
    <String, dynamic>{
      'data': instance.data,
      'files': instance.files,
    };

BillItemAddData _$BillItemAddDataFromJson(Map<String, dynamic> json) =>
    BillItemAddData(
      bookId: (json['bookId'] as num?)?.toInt(),
      billId: (json['billId'] as num?)?.toInt(),
      title: json['title'] as String?,
      tradeTime: json['tradeTime'] as String?,
      accountId: (json['accountId'] as num?)?.toInt(),
      accountToId: (json['accountToId'] as num?)?.toInt(),
      categoryAmountPair: (json['categoryAmountPair'] as List<dynamic>?)
          ?.map((e) => Map<String, num>.from(e as Map))
          .toList(),
      amount: (json['amount'] as num?)?.toDouble(),
      convertedAmount: (json['convertedAmount'] as num?)?.toDouble(),
      payeeId: (json['payeeId'] as num?)?.toInt(),
      billType: (json['billType'] as num?)?.toInt(),
      toAccountId: (json['toAccountId'] as num?)?.toInt(),
      confirm: json['confirm'] as bool?,
      include: json['include'] as bool?,
      remark: json['remark'] as String?,
      tagIdList: (json['tagIdList'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      fileList: (json['fileList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$BillItemAddDataToJson(BillItemAddData instance) =>
    <String, dynamic>{
      'billId': instance.billId,
      'bookId': instance.bookId,
      'title': instance.title,
      'tradeTime': instance.tradeTime,
      'accountId': instance.accountId,
      'accountToId': instance.accountToId,
      'categoryAmountPair': instance.categoryAmountPair,
      'amount': instance.amount,
      'convertedAmount': instance.convertedAmount,
      'payeeId': instance.payeeId,
      'billType': instance.billType,
      'toAccountId': instance.toAccountId,
      'confirm': instance.confirm,
      'include': instance.include,
      'remark': instance.remark,
      'tagIdList': instance.tagIdList,
      'fileList': instance.fileList,
    };
