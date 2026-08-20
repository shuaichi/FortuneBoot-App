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

  /// 是否“使用中”——用于按钮显隐。文档未给 int 值，仅按 statusDesc 文案判定；
  /// 文案无法识别时返回 false（未知态不猜按钮），由后端兜底。
  bool get isUsing {
    final desc = statusDesc ?? '';
    return desc.contains('使用');
  }

  bool get isClosed {
    final desc = statusDesc ?? '';
    return desc.contains('关闭') || desc.contains('已关');
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
