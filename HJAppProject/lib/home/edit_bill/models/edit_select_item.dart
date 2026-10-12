import 'package:json_annotation/json_annotation.dart';

part 'edit_select_item.g.dart';

abstract class BaseSelectItem {
  String title;
  int id;

  /// 自定义图标名（Iconify 名称，如 ep:wallet），为空表示使用默认图标
  String? icon;
  BaseSelectItem(this.title, this.id, {this.icon});
  @override
  String toString() {
    return '$title $id $icon';
  }
}

class AccountSelectItem extends BaseSelectItem {
  AccountSelectItem(super.title, super.id, {super.icon});
}

class BookSelectItem extends BaseSelectItem {
  BookSelectItem(super.title, super.id, {super.icon});
}

class PayeeSelectItem extends BaseSelectItem {
  PayeeSelectItem(super.title, super.id, {super.icon});
}

abstract class BaseTreeSelectItem<T extends BaseTreeSelectItem<T>> {
  List<T>? children;
  String title;
  int id;

  /// 自定义图标名（Iconify 名称），为空表示使用默认图标
  String? icon;

  BaseTreeSelectItem(this.title, this.id, {this.children, this.icon});

  // 检查是否有子项
  bool get hasChildren => children != null && children!.isNotEmpty;

  // 获取所有子项（包括子项的子项）
  List<T> getAllChildren() {
    List<T> allChildren = [];
    if (hasChildren) {
      for (var child in children!) {
        allChildren.add(child);
        if (child.hasChildren) {
          allChildren.addAll(child.getAllChildren());
        }
      }
    }
    return allChildren;
  }

  // 根据ID查找项（包括子项）
  T? findById(int searchId) {
    if (id == searchId) return this as T;
    if (hasChildren) {
      for (var child in children!) {
        final result = child.findById(searchId);
        if (result != null) return result;
      }
    }
    return null;
  }

  @override
  String toString() => '$title $id $children';
}

@JsonSerializable()
class CategorySelectItem extends BaseTreeSelectItem<CategorySelectItem> {
  List<CategorySelectItem>? children;

  @JsonKey(name: 'categoryName')
  String title;
  @JsonKey(name: 'categoryId')
  int id;

  /// 分类自定义图标名（Iconify 名称）
  String? icon;

  CategorySelectItem(this.title, this.id, {this.children, this.icon})
      : super(title, id, icon: icon);

  factory CategorySelectItem.fromJson(Map<String, dynamic> json) =>
      _$CategorySelectItemFromJson(json);
  Map<String, dynamic> toJson() => _$CategorySelectItemToJson(this);

  // 获取分类的层级路径
  String getFullPath({String separator = ' > '}) {
    return title;
  }

  // 获取分类的完整路径（包括父分类）
  static String getFullPathById(
      List<CategorySelectItem> allCategories, int categoryId,
      {String separator = ' > '}) {
    print('lxjtodo: getFullPathById: $categoryId $allCategories');
    for (var category in allCategories) {
      if (category.id == categoryId) {
        return category.title;
      }

      if (category.hasChildren) {
        for (var subCategory in category.children!) {
          if (subCategory.id == categoryId) {
            return '${category.title}$separator${subCategory.title}';
          }

          if (subCategory.hasChildren) {
            for (var thirdCategory in subCategory.children!) {
              if (thirdCategory.id == categoryId) {
                return '${category.title}$separator${subCategory.title}$separator${thirdCategory.title}';
              }
            }
          }
        }
      }
    }
    return '未知分类';
  }

  @override
  String toString() {
    return '$title $id $children';
  }
}

@JsonSerializable()
class TagSelectItem extends BaseTreeSelectItem<TagSelectItem> {
  List<TagSelectItem>? children;

  @JsonKey(name: 'tagName')
  String title;
  @JsonKey(name: 'tagId')
  int id;

  /// 标签自定义图标名（Iconify 名称）
  String? icon;

  TagSelectItem(this.title, this.id, {this.children, this.icon})
      : super(title, id, icon: icon);

  factory TagSelectItem.fromJson(Map<String, dynamic> json) =>
      _$TagSelectItemFromJson(json);
  Map<String, dynamic> toJson() => _$TagSelectItemToJson(this);

  // 获取标签的完整路径（包括父标签）
  static String getFullPathById(List<TagSelectItem> allTags, int tagId,
      {String separator = ' > '}) {
    for (var tag in allTags) {
      if (tag.id == tagId) {
        return tag.title;
      }

      if (tag.hasChildren) {
        for (var subTag in tag.children!) {
          if (subTag.id == tagId) {
            return '${tag.title}$separator${subTag.title}';
          }

          if (subTag.hasChildren) {
            for (var thirdTag in subTag.children!) {
              if (thirdTag.id == tagId) {
                return '${tag.title}$separator${subTag.title}$separator${thirdTag.title}';
              }
            }
          }
        }
      }
    }
    return '未知标签';
  }

  @override
  String toString() {
    return '$title $id $children';
  }
}
