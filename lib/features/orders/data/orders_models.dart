import 'package:fortuneboot/core/network/fx_api.dart';

/// 当前客户端支持的报销单类型。
///
/// 后端枚举值 1 为报销单；2（借出单）和 3（借入单）为预留类型，
/// 当前客户端不展示也不提交。
enum FinanceOrderType {
  reimbursement(1);

  const FinanceOrderType(this.value);

  final int value;
}

/// 后端单据状态：INIT=100、USING=200、CLOSE=1000。
enum FinanceOrderStatus {
  init(100),
  using(200),
  closed(1000);

  const FinanceOrderStatus(this.value);

  final int value;
}

/// 后端状态机接口 action：using / close / reopen。
enum FinanceOrderTransitionAction {
  using('using'),
  close('close'),
  reopen('reopen');

  const FinanceOrderTransitionAction(this.value);

  final String value;
}

/// 单据 VO。
class FortuneFinanceOrderVo {
  final int? orderId;
  final int? bookId;
  final String? title;
  final int? type;
  final String? typeDesc;
  final double? outAmount;
  final double? inAmount;
  final int? status;
  final String? statusDesc;
  final String? submitTime; // yyyy-MM-dd HH:mm:ss
  final String? closeTime;
  final String? remark;

  const FortuneFinanceOrderVo({
    this.orderId,
    this.bookId,
    this.title,
    this.type,
    this.typeDesc,
    this.outAmount,
    this.inAmount,
    this.status,
    this.statusDesc,
    this.submitTime,
    this.closeTime,
    this.remark,
  });

  bool get isInitial => status == FinanceOrderStatus.init.value;

  bool get isUsing => status == FinanceOrderStatus.using.value;

  bool get isClosed => status == FinanceOrderStatus.closed.value;

  FinanceOrderTransitionAction? get nextTransitionAction {
    if (isInitial) return FinanceOrderTransitionAction.using;
    if (isUsing) return FinanceOrderTransitionAction.close;
    if (isClosed) return FinanceOrderTransitionAction.reopen;
    return null;
  }

  bool get isReimbursementOrder => type == FinanceOrderType.reimbursement.value;

  factory FortuneFinanceOrderVo.fromJson(Map<String, dynamic> json) {
    return FortuneFinanceOrderVo(
      orderId: FxApi.asId(json['orderId']),
      bookId: FxApi.asId(json['bookId']),
      title: json['title']?.toString(),
      type: FxApi.asId(json['type']),
      typeDesc: json['typeDesc']?.toString(),
      outAmount: FxApi.asDouble(json['outAmount']),
      inAmount: FxApi.asDouble(json['inAmount']),
      status: FxApi.asId(json['status']),
      statusDesc: json['statusDesc']?.toString(),
      submitTime: json['submitTime']?.toString(),
      closeTime: json['closeTime']?.toString(),
      remark: json['remark']?.toString(),
    );
  }
}

/// 分页结果。
class OrdersPage {
  final List<FortuneFinanceOrderVo> rows;
  final int total;
  const OrdersPage({this.rows = const [], this.total = 0});
}
