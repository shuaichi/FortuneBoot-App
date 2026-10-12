import 'package:hjproject/home/edit_bill/models/edit_select_item.dart';
import 'package:hjproject/request/base_request.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

typedef ItemMapper<T> = T Function(String name, int id, String? icon);

Future<List<DropdownItem<T>>> _fetchDropdownItems<T>(
  int? id,
  int? type,
  String nameKey,
  String idKey,
  BaseService service,
  ItemMapper<T> itemMapper,
) async {
  final response = await service.getEnableList(id ?? 1, type: type);

  if (response.code != 0) return [];

  return (response.data as List? ?? []).map((element) {
    final name = element[nameKey] as String? ?? '';
    final id = element[idKey] as int? ?? 0;
    // 后端返回的自定义图标名（Iconify 名称），未设置时为 null
    final icon = element['icon'] as String?;
    return DropdownItem<T>(
      label: name,
      value: itemMapper(name, id, icon),
    );
  }).toList();
}

// 具体实现（类型安全 + 简洁调用）
Future<List<DropdownItem<PayeeSelectItem>>> payeeItems(BaseService service,
        {int? id, int? type}) =>
    _fetchDropdownItems(
      id,
      type,
      'payeeName',
      'payeeId',
      service,
      (name, id, icon) => PayeeSelectItem(name, id, icon: icon),
    );

Future<List<DropdownItem<AccountSelectItem>>> accountItems(BaseService service,
        {int? id, int? type}) =>
    _fetchDropdownItems(
      id,
      type,
      'accountName',
      'accountId',
      service,
      (name, id, icon) => AccountSelectItem(name, id, icon: icon),
    );

Future<List<DropdownItem<BookSelectItem>>> bookItems(BaseService service,
        {int? id, int? type}) =>
    _fetchDropdownItems(
      id,
      type,
      'bookName',
      'bookId',
      service,
      (name, id, icon) => BookSelectItem(name, id),
    );
