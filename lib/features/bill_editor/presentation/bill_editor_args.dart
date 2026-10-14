import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';

/// BillEditor 入参。
///
/// 路由参数是 Map（其它页面传来）。约定支持三种形态：
/// - `{'mode':'copy', 'bill': FortuneBillVo}` → 复制（预填但不带 billId，存为新账单）
/// - `{'mode':'edit', 'billId': int}` → 编辑（带 billId，billType 锁定）
/// - `{'mode':'new', 'billType': int?}` 或 `null` → 新建（默认支出）
///
/// 兼容直接传 [BillEditorArgs] 或 [FortuneBillVo]（视为复制）。
class BillEditorArgs {
  /// new | edit | copy
  final String mode;
  final int? billId;

  /// 复制/预填来源账单（copy 模式主要来源）。
  final FortuneBillVo? sourceBill;

  /// 预填字段 Map（copyData，扩展用）。
  final Map<String, dynamic>? copyData;

  /// 新建时预选的账单类型（默认支出）。
  final int? presetBillType;

  /// 单据上下文预填与锁定。
  final int? presetBookId;
  final int? presetOrderId;
  final FinanceOrderComponent? presetOrderComponent;
  final int? expectedOrderVersion;
  final bool lockOrderContext;

  /// 结算类动作预填的剩余本金（分）。仅新建（new）时生效。
  final int? presetAmountCents;

  const BillEditorArgs({
    this.mode = 'new',
    this.billId,
    this.sourceBill,
    this.copyData,
    this.presetBillType,
    this.presetBookId,
    this.presetOrderId,
    this.presetOrderComponent,
    this.expectedOrderVersion,
    this.lockOrderContext = false,
    this.presetAmountCents,
  });

  bool get isEdit => mode == 'edit';
  bool get isCopy => mode == 'copy';
  bool get isNew => !isEdit && !isCopy;

  /// billType 是否锁定（编辑或由单据详情发起时锁定）。
  bool get lockBillType => isEdit || lockOrderContext;

  /// 从路由参数解析。宽松兼容多种入参形态。
  factory BillEditorArgs.fromRouteArgs(Object? args) {
    if (args == null) return const BillEditorArgs();

    if (args is BillEditorArgs) return args;

    // 直接传账单 VO：按复制处理。
    if (args is FortuneBillVo) {
      return BillEditorArgs(mode: 'copy', sourceBill: args);
    }

    if (args is Map) {
      final map = Map<String, dynamic>.from(args);
      final mode = map['mode']?.toString() ?? 'new';
      final billRaw = map['bill'];
      final sourceBill = switch (billRaw) {
        final FortuneBillVo v => v,
        final Map<dynamic, dynamic> m => FortuneBillVo.fromJson(
          Map<String, dynamic>.from(m),
        ),
        _ => null,
      };
      final billId = _asInt(map['billId']) ?? sourceBill?.billId;
      final presetBillType = _asInt(map['billType'] ?? map['presetBillType']);
      final presetBookId = _asInt(
        map['presetBookId'] ?? map['bookId'] ?? sourceBill?.bookId,
      );
      final presetOrderId = _asInt(
        map['presetOrderId'] ?? sourceBill?.orderId,
      );
      final rawOrderComponent =
          map['presetOrderComponent'] ?? sourceBill?.orderComponent?.value;
      final presetOrderComponent = rawOrderComponent == null
          ? null
          : FinanceOrderComponent.fromValue(rawOrderComponent.toString());
      final expectedOrderVersion = _asInt(
        map['expectedOrderVersion'] ?? map['expectedVersion'],
      );
      final lockOrderContext = _asBool(
            map['lockOrderContext'],
          ) ||
          presetOrderComponent != null;
      final copyData = switch (map['copyData']) {
        final Map<dynamic, dynamic> m => Map<String, dynamic>.from(m),
        _ => null,
      };
      return BillEditorArgs(
        mode: mode,
        billId: mode == 'edit' ? billId : (mode == 'copy' ? null : billId),
        sourceBill: sourceBill,
        copyData: copyData,
        presetBillType: presetBillType,
        presetBookId: presetBookId,
        presetOrderId: presetOrderId,
        presetOrderComponent: presetOrderComponent,
        expectedOrderVersion: expectedOrderVersion,
        lockOrderContext: lockOrderContext,
        presetAmountCents: _asInt(map['presetAmountCents']),
      );
    }

    return const BillEditorArgs();
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    return v.toString().toLowerCase() == 'true';
  }
}
