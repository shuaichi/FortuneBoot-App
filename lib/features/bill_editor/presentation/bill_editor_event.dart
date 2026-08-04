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

class CategoryRowAdded extends BillEditorEvent {
  const CategoryRowAdded();
}

class CategoryRowRemoved extends BillEditorEvent {
  final int index;
  const CategoryRowRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

class CategoryRowCategoryChanged extends BillEditorEvent {
  final int index;
  final int? categoryId;
  final String? categoryName;
  const CategoryRowCategoryChanged(this.index, this.categoryId, this.categoryName);

  @override
  List<Object?> get props => [index, categoryId, categoryName];
}

class CategoryRowAmountChanged extends BillEditorEvent {
  final int index;
  final double amount;
  const CategoryRowAmountChanged(this.index, this.amount);

  @override
  List<Object?> get props => [index, amount];
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
  const ExtraRowAdded();
}

class ExtraRowRemoved extends BillEditorEvent {
  final int index;
  const ExtraRowRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

class ExtraRowChanged extends BillEditorEvent {
  final int index;
  final ExtraRow row;
  const ExtraRowChanged(this.index, this.row);

  @override
  List<Object?> get props => [index, row];
}

class AttachmentsAdded extends BillEditorEvent {
  final List<File> files;
  const AttachmentsAdded(this.files);

  @override
  List<Object?> get props => [files.length];
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
