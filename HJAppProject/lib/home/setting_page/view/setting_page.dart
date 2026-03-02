import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

import 'package:hjproject/home/setting_page/bloc/setting_bloc.dart';
import 'package:hjproject/home/setting_page/models/mine_setting.dart';
import 'package:hjproject/home/setting_page/models/setting_select_item.dart';
import 'package:hjproject/home/setting_page/utils/setting_filter.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';

import 'package:hjproject/request/group_request.dart';
import 'package:hjproject/request/book_request.dart';

import 'package:hjproject/home/setting_page/view/profile_page.dart';
import 'package:hjproject/home/account_manage/view/account_manage_page.dart';
import 'package:hjproject/home/category_manage/view/category_manage_page.dart';
import 'package:hjproject/home/tag_manage/view/tag_manage_page.dart';
import 'package:hjproject/home/payee_manage/view/payee_manage_page.dart';

import 'package:hjproject/home/design_system/hjds_theme.dart';
import 'package:hjproject/home/design_system/hjds_components.dart';

import 'widgets/donate_qr_sheet.dart';
import 'widgets/help_dialog.dart';
import 'widgets/api_info_dialog.dart';
import 'widgets/setting_detail_dialog.dart';
import 'widgets/logout_confirm_dialog.dart';
import 'widgets/selection_bottom_sheet.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingBloc(billsRepository: context.read<BillsRepository>())..add(SettingInitDataLoaded()),
      child: const MineView(),
    );
  }
}

class MineView extends StatefulWidget {
  const MineView({super.key});

  @override
  State<MineView> createState() => _MineViewState();
}

class _MineViewState extends State<MineView> {
  @override
  void initState() {
    super.initState();
    context.read<SettingBloc>().add(GroupSettingFetched());
  }

  UIState _mapToUIState(SettingStatus status) {
    switch (status) {
      case SettingStatus.initial:
        return UIState.loading;
      case SettingStatus.failure:
        return UIState.error;
      case SettingStatus.success:
        return UIState.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SettingBloc>().state;
    final uiState = _mapToUIState(state.status);
    final elements =[...state.settings, ...state.remoteSettings, ...state.groupSettings];
    Setting.sortList(elements);
    final groups = SettingFilter.groupSettings(elements);

    final usernameSetting = elements.firstWhere((e) => e.type == SettingType.username, orElse: () => const Setting(SettingType.username, content: '未登录用户'));

    return UIStateHandler(
      state: uiState,
      onRetry: () => context.read<SettingBloc>().add(GroupSettingFetched()),
      child: HJSettingsTemplate(
        header: HJAvatarSection(
          name: usernameSetting.content ?? '未登录用户',
          role: '基础用户',
          onViewProfile: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
          onShowQRCode: () => _showQRCode(context),
        ),
        sections:[
          if (groups.hasAccountSettings)
            SectionCard(
              title: '账户概览',
              items: groups.accountSettings.map((e) => _buildListItem(e)).toList(),
            ),
          SectionCard(
            title: '账本配置',
            items:[
              HJListItem.chevron(icon: Icons.category_outlined, title: '分类管理', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryManagePage()))),
              HJListItem.chevron(icon: Icons.label_outline, title: '标签管理', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TagManagePage()))),
              HJListItem.chevron(icon: Icons.people_outline, title: '交易对象', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PayeeManagePage()))),
              HJListItem.chevron(icon: Icons.account_balance_outlined, title: '账户管理', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountManagePage()))),
            ],
          ),
          if (groups.hasAppSettings)
            SectionCard(
              title: '应用设置',
              items: groups.appSettings.map((e) => _buildListItem(e)).toList(),
            ),
          if (groups.hasAboutSettings)
            SectionCard(
              title: '关于',
              items: groups.aboutSettings.map((e) => _buildListItem(e)).toList(),
            ),
          SectionCard(
            title: '更多',
            items:[
              HJListItem.chevron(icon: Icons.favorite_outline, title: '打赏作者', onTap: () => _showQRCode(context)),
              HJListItem.chevron(icon: Icons.help_outline, title: '帮助文档', onTap: () => showDialog(context: context, builder: (_) => const HelpDialog())),
            ],
          )
        ],
        footer: HJButton.critical(
          text: '退出登录',
          onPressed: () => showDialog(context: context, builder: (_) => LogoutConfirmDialog(onConfirm: () => Navigator.pop(context))),
        ),
      ),
    );
  }

  Widget _buildListItem(Setting element) {
    // 【修复】账户概览改为弹窗展示具体资产数据（恢复原始意图）
    if (element.type == SettingType.accountOverview) {
      return HJListItem.account(
        icon: Icons.account_balance_wallet,
        title: element.type.title,
        subtitle: element.detail?.replaceAll('\r\n', '   ') ?? '', // 将换行符转为空格在一行展示概要
        onTap: () => showDialog(
            context: context,
            builder: (_) => SettingDetailDialog(
              title: element.type.title,
              contentText: element.content,
              detailText: element.detail,
            )
        ),
      );
    }

    return HJListItem.value(
      icon: _getIconForType(element.type),
      title: element.type.title,
      valueText: element.content ?? element.detail,
      onTap: () {
        switch (element.type) {
          case SettingType.currentTheme:
          case SettingType.currentLanguage:
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('功能开发中...')));
            break;
          case SettingType.api:
            showDialog(context: context, builder: (_) => ApiInfoDialog(apiDetail: element.detail));
            break;
          case SettingType.currentGroup:
          case SettingType.currentBook:
            _showSelectionDialog(context, element);
            break;
          default:
            showDialog(context: context, builder: (_) => SettingDetailDialog(title: element.type.title, contentText: element.content, detailText: element.detail));
            break;
        }
      },
    );
  }

  IconData _getIconForType(SettingType type) {
    switch (type) {
      case SettingType.currentGroup: return Icons.group_work_outlined;
      case SettingType.currentBook: return Icons.book_outlined;
      case SettingType.currentTheme: return Icons.color_lens_outlined;
      case SettingType.currentLanguage: return Icons.language_outlined;
      case SettingType.api: return Icons.api_outlined;
      case SettingType.currentVersion: return Icons.info_outline;
      case SettingType.apiVersion: return Icons.cloud_outlined;
      default: return Icons.settings;
    }
  }

  void _showQRCode(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DonateQrSheet(
        onLongPressWechat: () {},
        onLongPressAlipay: () {},
      ),
    );
  }

  void _showSelectionDialog(BuildContext context, Setting element) async {
    List<SelectionOption<SettingSelectItem>> items =[];

    if (element.type == SettingType.currentGroup) {
      GroupService groupService = GroupService();
      var res = await groupService.getEnableList();
      if (res.code == 0) {
        var remoteList = res.data as List? ??[];
        for (final remoteItem in remoteList) {
          var remoteGroupName = remoteItem['groupName']?.toString() ?? '';
          bool selected = remoteGroupName == element.content;
          var groupId = remoteItem['groupId'] as int? ?? 0;
          items.add(SelectionOption<SettingSelectItem>(
            label: remoteGroupName,
            value: SettingSelectItem(remoteGroupName, groupId),
            selected: selected,
          ));
        }
      }
    } else if (element.type == SettingType.currentBook) {
      final BookService bookService = BookService();
      final remoteBookResponse = await bookService.getEnableList(element.data?['groupId'] as int? ?? 0);
      if (remoteBookResponse.code == 0) {
        final remoteBookList = remoteBookResponse.data as List? ??[];
        for (final remoteBookItem in remoteBookList) {
          final remoteBookName = remoteBookItem['bookName']?.toString() ?? '';
          final bool selected = remoteBookName == element.content;
          items.add(SelectionOption<SettingSelectItem>(
            label: remoteBookName,
            value: SettingSelectItem(remoteBookName, remoteBookItem['bookId'] as int? ?? 0),
            selected: selected,
          ));
        }
      }
    }

    if (items.isEmpty) {
      if(!context.mounted) return;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无可选项'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    if(!context.mounted) return;
    var settingBloc = context.read<SettingBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SelectionBottomSheet<SettingSelectItem>(
          title: element.type == SettingType.currentGroup ? '选择分组' : '选择账本',
          options: items,
          onSelected: (option) {
            if (element.type == SettingType.currentGroup) {
              settingBloc.add(GroupSettingFetched(groupId: option.value.id));
            } else if (element.type == SettingType.currentBook) {
              settingBloc.add(BookIdChanged(option.value.id, option.value.title));
            }
          },
        );
      },
    );
  }
}