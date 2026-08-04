import 'package:fortuneboot/core/network/fx_api.dart';

/// 单据类型。
///
/// TODO(后端确认): type/typeDesc 的 int 值文档未定义，此处为经验映射
/// （垫付=1 / 报销=2）。列表展示优先用后端 [FortuneFinanceOrderVo.typeDesc]；
/// 仅“新增”时用本枚举提供选项与传值。若后端提供类型枚举接口应改为动态消费。
enum FinanceOrderType {
  advance(1, '垫付'),
  reimburse(2, '报销');

  const FinanceOrderType(this.value, this.label);

  final int value;
  final String label;
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
