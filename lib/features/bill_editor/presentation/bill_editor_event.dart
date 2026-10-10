part of 'bill_editor_bloc.dart';

sealed class BillEditorEvent extends Equatable {
  const BillEditorEvent();

  @override
  List<Object?> get props => [];
}

/// 初始化：解析 args + 并发加载选项 + 预填。
class BillEditorInitialized extends BillEditorEvent {
  final BillEditorArgs args;
  const BillEditorInitialized(this.args);

  @override
  List<Object?> get props => [args];
}

/// 重试加载选项。
class BillEditorRetried extends BillEditorEvent {
  const BillEditorRetried();
}

class BillTypeChanged extends BillEditorEvent {
  final FxBillType billType;
  const BillTypeChanged(this.billType);

  @override
  List<Object?> get props => [billType];
}

/// 转账单一金额变更。
class TransferAmountChanged extends BillEditorEvent {
  final double amount;
  const TransferAmountChanged(this.amount);

  @override
  List<Object?> get props => [amount];
}

/// 单据 9—12 的单一金额变更，单位为整数分。
class SingleAmountChanged extends BillEditorEvent {
  final int cents;
  const SingleAmountChanged(this.cents);

  @override
  List<Object?> get props => [cents];
}

class CategoryRowAdded extends BillEditorEvent {
  const CategoryRowAdded();
}

class CategoryRowRemoved extends BillEditorEvent {
  final String rowId;
  const CategoryRowRemoved(this.rowId);

  @override
  List<Object?> get props => [rowId];
}

class CategoryRowCategoryChanged extends BillEditorEvent {
  final String rowId;
  final int? categoryId;
  final String? categoryName;
  const CategoryRowCategoryChanged(
    this.rowId,
    this.categoryId,
    this.categoryName,
  );

  @override
  List<Object?> get props => [rowId, categoryId, categoryName];
}

class CategoryRowAmountChanged extends BillEditorEvent {
  final String rowId;
  final double amount;
  const CategoryRowAmountChanged(this.rowId, this.amount);

  @override
  List<Object?> get props => [rowId, amount];
}

/// 单据关联分类拆分金额变更，单位为整数分。
class OrderCategoryRowAmountChanged extends BillEditorEvent {
  final String rowId;
  final int cents;
  const OrderCategoryRowAmountChanged(this.rowId, this.cents);

  @override
  List<Object?> get props => [rowId, cents];
}

class AccountChanged extends BillEditorEvent {
  final int? accountId;
  final String? accountName;
  const AccountChanged(this.accountId, this.accountName);

  @override
  List<Object?> get props => [accountId, accountName];
}

class ToAccountChanged extends BillEditorEvent {
  final int? accountId;
  final String? accountName;
  const ToAccountChanged(this.accountId, this.accountName);

  @override
  List<Object?> get props => [accountId, accountName];
}

class PayeeChanged extends BillEditorEvent {
  final int? payeeId;
  final String? payeeName;
  const PayeeChanged(this.payeeId, this.payeeName);

  @override
  List<Object?> get props => [payeeId, payeeName];
}

class TradeTimeChanged extends BillEditorEvent {
  final DateTime tradeTime;
  const TradeTimeChanged(this.tradeTime);

  @override
  List<Object?> get props => [tradeTime];
}

class TagsChanged extends BillEditorEvent {
  final List<int> tagIds;
  final List<String> tagNames;
  const TagsChanged(this.tagIds, this.tagNames);

  @override
  List<Object?> get props => [tagIds, tagNames];
}

class MembersChanged extends BillEditorEvent {
  final List<int> memberIds;
  final List<String> memberNames;
  const MembersChanged(this.memberIds, this.memberNames);

  @override
  List<Object?> get props => [memberIds, memberNames];
}

class OrderChanged extends BillEditorEvent {
  final int? orderId;
  final String? orderTitle;
  const OrderChanged(this.orderId, this.orderTitle);

  @override
  List<Object?> get props => [orderId, orderTitle];
}

class ExtraRowAdded extends BillEditorEvent {
  final int? categoryId;
  const ExtraRowAdded({this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class ExtraRowRemoved extends BillEditorEvent {
  final String rowId;
  const ExtraRowRemoved(this.rowId);

  @override
  List<Object?> get props => [rowId];
}

class ExtraRowChanged extends BillEditorEvent {
  final String rowId;
  final ExtraRow row;
  const ExtraRowChanged(this.rowId, this.row);

  @override
  List<Object?> get props => [rowId, row];
}

class AttachmentsAdded extends BillEditorEvent {
  final List<BillAttachment> attachments;
  const AttachmentsAdded(this.attachments);

  @override
  List<Object?> get props => [attachments];
}

class AttachmentRemoved extends BillEditorEvent {
  final int index;
  const AttachmentRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

class RemarkChanged extends BillEditorEvent {
  final String remark;
  const RemarkChanged(this.remark);

  @override
  List<Object?> get props => [remark];
}

class TitleChanged extends BillEditorEvent {
  final String title;
  const TitleChanged(this.title);

  @override
  List<Object?> get props => [title];
}

class ConfirmToggled extends BillEditorEvent {
  final bool value;
  const ConfirmToggled(this.value);

  @override
  List<Object?> get props => [value];
}

class IncludeToggled extends BillEditorEvent {
  final bool value;
  const IncludeToggled(this.value);

  @override
  List<Object?> get props => [value];
}

class BillEditorSubmitted extends BillEditorEvent {
  const BillEditorSubmitted();
}
