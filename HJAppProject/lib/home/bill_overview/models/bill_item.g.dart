// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillItem _$BillItemFromJson(Map<String, dynamic> json) => BillItem(
      billId: (json['billId'] as num?)?.toInt(),
      bookId: (json['bookId'] as num?)?.toInt(),
      bookName: json['bookName'] as String?,
      title: json['title'] as String?,
      tradeTime: json['tradeTime'] == null
          ? null
          : DateTime.parse(json['tradeTime'] as String),
      accountId: (json['accountId'] as num?)?.toInt(),
      accountName: json['accountName'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      currencyCode: json['currencyCode'] as String?,
      convertedAmount: (json['convertedAmount'] as num?)?.toDouble(),
      payeeId: (json['payeeId'] as num?)?.toInt(),
      payeeName: json['payeeName'] as String?,
      billType: $enumDecodeNullable(_$BillTypeEnumMap, json['billType']),
      toAccountId: (json['toAccountId'] as num?)?.toInt(),
      toAccountName: json['toAccountName'] as String?,
      confirm: json['confirm'] as bool?,
      include: json['include'] as bool?,
      remark: json['remark'] as String?,
      categoryAmountPair: (json['categoryAmountPair'] as List<dynamic>?)
          ?.map((e) => CategoryAmountPair.fromJson(e as Map<String, dynamic>))
          .toList(),
      tagList: (json['tagList'] as List<dynamic>?)
          ?.map((e) => TagList.fromJson(e as Map<String, dynamic>))
          .toList(),
      fileList: (json['fileList'] as List<dynamic>?)
          ?.map((e) => BillFileItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BillItemToJson(BillItem instance) => <String, dynamic>{
      'billId': instance.billId,
      'bookId': instance.bookId,
      'bookName': instance.bookName,
      'title': instance.title,
      'tradeTime': instance.tradeTime?.toIso8601String(),
      'accountId': instance.accountId,
      'accountName': instance.accountName,
      'amount': instance.amount,
      'currencyCode': instance.currencyCode,
      'convertedAmount': instance.convertedAmount,
      'payeeId': instance.payeeId,
      'payeeName': instance.payeeName,
      'billType': _$BillTypeEnumMap[instance.billType],
      'toAccountId': instance.toAccountId,
      'toAccountName': instance.toAccountName,
      'confirm': instance.confirm,
      'include': instance.include,
      'remark': instance.remark,
      'categoryAmountPair': instance.categoryAmountPair,
      'tagList': instance.tagList,
      'fileList': instance.fileList,
    };

const _$BillTypeEnumMap = {
  BillType.expenditure: 1,
  BillType.income: 2,
  BillType.transfer: 3,
  BillType.adjust: 4,
  BillType.advance: 7,
  BillType.reimburse: 8,
};

CategoryAmountPair _$CategoryAmountPairFromJson(Map<String, dynamic> json) =>
    CategoryAmountPair(
      categoryId: (json['categoryId'] as num?)?.toInt(),
      categoryName: json['categoryName'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CategoryAmountPairToJson(CategoryAmountPair instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'amount': instance.amount,
    };

TagList _$TagListFromJson(Map<String, dynamic> json) => TagList(
      children: json['children'] as List<dynamic>?,
      tagId: (json['tagId'] as num?)?.toInt(),
      tagName: json['tagName'] as String?,
      bookId: (json['bookId'] as num?)?.toInt(),
      parentId: (json['parentId'] as num?)?.toInt(),
      canExpense: json['canExpense'] as bool?,
      canIncome: json['canIncome'] as bool?,
      canTransfer: json['canTransfer'] as bool?,
      enable: json['enable'] as bool?,
      sort: (json['sort'] as num?)?.toInt(),
      remark: json['remark'] as String?,
      id: (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TagListToJson(TagList instance) => <String, dynamic>{
      'children': instance.children,
      'tagId': instance.tagId,
      'tagName': instance.tagName,
      'bookId': instance.bookId,
      'parentId': instance.parentId,
      'canExpense': instance.canExpense,
      'canIncome': instance.canIncome,
      'canTransfer': instance.canTransfer,
      'enable': instance.enable,
      'sort': instance.sort,
      'remark': instance.remark,
      'id': instance.id,
    };
