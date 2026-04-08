part of 'edit_bill_bloc.dart';

sealed class EditBillEvent extends Equatable {
  const EditBillEvent();

  @override
  List<Object> get props => [];
}

// 初始化数据
final class EditBillInitialized extends EditBillEvent {
  BillType type;
  EditBillInitialized(this.type);
  @override
  List<Object> get props => [type];
}

final class EditBillTypeChange extends EditBillEvent {
  BillType type;
  EditBillTypeChange(this.type);
  @override
  List<Object> get props => [type];
}

final class EditBillSubmitted extends EditBillEvent {
  const EditBillSubmitted();
}

final class EditBillAttachmentsChanged extends EditBillEvent {
  final List<AttachmentItem> attachments;
  
  const EditBillAttachmentsChanged(this.attachments);
  
  @override
  List<Object> get props => [attachments];
}
