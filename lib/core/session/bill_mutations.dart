import 'package:flutter/foundation.dart';

/// 全局账单变更信号。任何账单写操作（新增/编辑/复制/删除/确认/统计）成功后 [bump]，
/// 依赖账单数据的页面（Dashboard/Bills/Stats）监听并刷新。
///
/// 解决"记一笔后返回常驻 tab 但 bookId 未变、列表/看板不刷新"的闭环断裂。
class BillMutations {
  BillMutations._();
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static void bump() => revision.value++;
}
