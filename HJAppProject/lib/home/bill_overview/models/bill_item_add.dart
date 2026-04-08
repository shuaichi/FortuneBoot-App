import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fortuneboot/home/bill_overview/models/bill_file_item.dart';
import 'package:fortuneboot/home/bill_overview/models/bill_item.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'bill_item_add.g.dart';

@immutable
@JsonSerializable()
class BillItemAdd {
  BillItemAddData? data;
  List<BillFileItem>? files;

  BillItemAdd({this.data, this.files});
  factory BillItemAdd.fromJson(Map<String, dynamic> json) =>
      _$BillItemAddFromJson(json);
  Map<String, dynamic> toJson() => _$BillItemAddToJson(this);

  // copyWith
  BillItemAdd copyWith({
    BillItemAddData? data,
    List<BillFileItem>? files,
  }) {
    return BillItemAdd(
      data: data ?? this.data!.copyWith(),
      files: files ?? this.files,
    );
  }

  @override
  String toString() {
    return 'BillItemAdd{data: $data, files: $files}';
  }

  BillItemAdd.fromBillItem(BillItem billItem) {
    List<Map<String, num>> categoryAmountPairList = [];
    billItem.categoryAmountPair
        ?.forEach((CategoryAmountPair categoryAmountPair) {
      categoryAmountPairList.add({
        "categoryId": categoryAmountPair.categoryId ?? 0,
        "amount": categoryAmountPair.amount ?? 0
      });
    });
    data = BillItemAddData(
      billId: billItem.billId,
      bookId: billItem.bookId,
      title: billItem.title,
      tradeTime: billItem.tradeTimeString,
      accountId: billItem.accountId,
      accountToId: billItem.toAccountId,
      categoryAmountPair: categoryAmountPairList,
      payeeId: billItem.payeeId,
      billType: billItem.billType?.value,
      tagIdList: billItem.tagList?.map((TagList it) => it.id ?? 0).toList(),
      remark: billItem.remark,
      confirm: billItem.confirm,
      include: billItem.include,
      toAccountId: billItem.toAccountId,
      amount: billItem.amount,
    );
    files = billItem.fileList;
  }
}

@JsonSerializable()
class BillItemAddData {
  int? billId;
  int? bookId;
  String? title;
  String? tradeTime;
  int? accountId;
  int? accountToId;
  List<Map<String, num>>? categoryAmountPair;
  double? amount;
  double? convertedAmount;
  int? payeeId;
  int? billType;
  int? toAccountId;
  bool? confirm;
  bool? include;
  String? remark;
  List<int>? tagIdList;
  List<String>? fileList;

  BillItemAddData.init(
      {required this.bookId,
      this.billId,
      this.accountId,
      this.accountToId,
      this.categoryAmountPair,
      this.amount,
      this.convertedAmount,
      this.payeeId,
      this.toAccountId,
      this.remark,
      this.tagIdList,
      this.title,
      this.fileList}) {
    tradeTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    confirm = true;
    include = true;
    billType = BillType.expenditure.value;
  }

  BillItemAddData(
      {this.bookId,
      this.billId,
      this.title,
      this.tradeTime,
      this.accountId,
      this.accountToId,
      this.categoryAmountPair,
      this.amount,
      this.convertedAmount,
      this.payeeId,
      this.billType,
      this.toAccountId,
      this.confirm,
      this.include,
      this.remark,
      this.tagIdList,
      this.fileList}) {
    if (accountId == -1) {
      accountId = null;
    }
    if (accountToId == -1) {
      accountToId = null;
    }
    if (payeeId == -1) {
      payeeId = null;
    }
  }

  factory BillItemAddData.fromJson(Map<String, dynamic> json) =>
      _$BillItemAddDataFromJson(json);
  Map<String, dynamic> toJson() => _$BillItemAddDataToJson(this);

  DateTime? get tradeDate => tradeTime != null
      ? DateFormat("yyyy-MM-dd HH:mm:ss").parse(tradeTime!)
      : DateTime.now();

  // copyWith
  BillItemAddData copyWith({
    int? billId,
    int? bookId,
    String? title,
    String? tradeTime,
    int? accountId,
    int? accountToId,
    List<Map<String, num>>? categoryAmountPair,
    double? amount,
    double? convertedAmount,
    int? payeeId,
    int? billType,
    int? toAccountId,
    bool? confirm,
    bool? include,
    String? remark,
    List<int>? tagIdList,
    List<String>? fileList,
  }) {
    return BillItemAddData(
      billId: billId ?? this.billId,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      tradeTime: tradeTime ?? this.tradeTime,
      accountId: accountId ?? this.accountId,
      accountToId: accountToId ?? this.accountToId,
      categoryAmountPair: categoryAmountPair ?? this.categoryAmountPair,
      amount: amount ?? this.amount,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      payeeId: payeeId ?? this.payeeId,
      billType: billType ?? this.billType,
      toAccountId: toAccountId ?? this.toAccountId,
      confirm: confirm ?? this.confirm,
      include: include ?? this.include,
      remark: remark ?? this.remark,
      tagIdList: tagIdList ?? this.tagIdList,
      fileList: fileList ?? this.fileList,
    );
  }

  @override
  String toString() {
    return 'BillItemAddData{billId:$billId bookId: $bookId, title: $title, tradeTime: $tradeTime, accountId: $accountId, accountToId: $accountToId, categoryAmountPair: $categoryAmountPair, amount: $amount, convertedAmount: $convertedAmount, payeeId: $payeeId, billType: $billType, toAccountId: $toAccountId, confirm: $confirm, include: $include, remark: $remark, tagIdList: $tagIdList, fileList: $fileList}';
  }
}
