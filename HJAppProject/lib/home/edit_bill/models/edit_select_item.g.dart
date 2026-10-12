// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_select_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategorySelectItem _$CategorySelectItemFromJson(Map<String, dynamic> json) =>
    CategorySelectItem(
      json['categoryName'] as String,
      json['categoryId'] as int,
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => CategorySelectItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$CategorySelectItemToJson(CategorySelectItem instance) =>
    <String, dynamic>{
      'children': instance.children,
      'categoryName': instance.title,
      'categoryId': instance.id,
      'icon': instance.icon,
    };

TagSelectItem _$TagSelectItemFromJson(Map<String, dynamic> json) =>
    TagSelectItem(
      json['tagName'] as String,
      json['tagId'] as int,
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => TagSelectItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$TagSelectItemToJson(TagSelectItem instance) =>
    <String, dynamic>{
      'children': instance.children,
      'tagName': instance.title,
      'tagId': instance.id,
      'icon': instance.icon,
    };
