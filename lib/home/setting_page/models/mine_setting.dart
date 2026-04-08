import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum SettingClickType { title, selector, newPage }

enum SettingType {
  username(0, '用户名'),
  accountOverview(1, '账户概览'),
  currentGroup(2, '当前分组'),
  currentBook(3, '当前账本'),
  currentTheme(4, '当前主题'),
  currentLanguage(5, '当前语言'),
  api(6, 'API'),
  currentVersion(7, '当前版本'),
  apiVersion(8, 'API版本');

  final int sort;
  final String title;
  const SettingType(this.sort, this.title);
}

final class Setting extends Equatable {
  const Setting(this.type, {this.detail, this.content, this.leadingWidget, this.data});

  final SettingType type;
  final String? detail;
  final String? content;
  final Widget? leadingWidget;
  final Map<String, dynamic>? data;

  @override
  List<Object> get props =>
      [type, detail ?? '', content ?? '', leadingWidget.hashCode, data.toString()];

  static void sortList(List<Setting> settings) {
    settings.sort((a, b) {
      return a.type.sort - b.type.sort;
    });
  }
}
