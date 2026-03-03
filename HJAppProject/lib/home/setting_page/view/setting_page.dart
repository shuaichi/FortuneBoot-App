import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hjproject/home/setting_page/bloc/setting_bloc.dart';
import 'package:hjproject/home/setting_page/models/mine_setting.dart';
import 'package:hjproject/home/setting_page/models/setting_select_item.dart';
import 'package:hjproject/home/setting_page/utils/setting_filter.dart';
import 'package:hjproject/login/model/users.dart';
import 'package:hjproject/login/view/base_url_config_page.dart';
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

import 'package:hjproject/home/setting_page/view/widgets/donate_qr_sheet.dart';
import 'package:hjproject/home/setting_page/view/widgets/help_dialog.dart';
import 'package:hjproject/home/setting_page/view/widgets/api_info_dialog.dart';
import 'package:hjproject/home/setting_page/view/widgets/setting_detail_dialog.dart';
import 'package:hjproject/home/setting_page/view/widgets/logout_confirm_dialog.dart';
import 'package:hjproject/home/setting_page/view/widgets/selection_bottom_sheet.dart';
import 'package:hjproject/util/dio_client.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SettingBloc(billsRepository: context.read<BillsRepository>())
            ..add(SettingInitDataLoaded()),
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
    final elements = [
      ...state.settings,
      ...state.remoteSettings,
      ...state.groupSettings
    ];
    Setting.sortList(elements);
    final groups = SettingFilter.groupSettings(elements);

    final usernameSetting = elements.firstWhere(
        (e) => e.type == SettingType.username,
        orElse: () => const Setting(SettingType.username, content: '未登录用户'));

    return UIStateHandler(
      state: uiState,
      onRetry: () => context.read<SettingBloc>().add(GroupSettingFetched()),
      child: HJSettingsTemplate(
        header: HJAvatarSection(
          name: usernameSetting.content ?? '未登录用户',
          role: '基础用户',
          onViewProfile: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ProfilePage())),
          onShowQRCode: () => _showQRCode(context),
        ),
        sections: [
          if (groups.hasAccountSettings)
            SectionCard(
              title: '账户概览',
              items:
                  groups.accountSettings.map((e) => _buildListItem(e)).toList(),
            ),
          SectionCard(
            title: '账本配置',
            items: [
              HJChevronItem(
                  icon: Icons.category_outlined,
                  title: '分类管理',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CategoryManagePage()))),
              HJChevronItem(
                  icon: Icons.label_outline,
                  title: '标签管理',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TagManagePage()))),
              HJChevronItem(
                  icon: Icons.people_outline,
                  title: '交易对象',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PayeeManagePage()))),
              HJChevronItem(
                  icon: Icons.account_balance_outlined,
                  title: '账户管理',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AccountManagePage()))),
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
              items:
                  groups.aboutSettings.map((e) => _buildListItem(e)).toList(),
            ),
          SectionCard(
            title: '更多',
            items: [
              HJChevronItem(
                  icon: Icons.favorite_outline,
                  title: '打赏作者',
                  onTap: () => _showQRCode(context)),
              HJChevronItem(
                  icon: Icons.help_outline,
                  title: '帮助文档',
                  onTap: () => showDialog(
                      context: context, builder: (_) => const HelpDialog())),
            ],
          )
        ],
        footer: HJButton.critical(
          text: '退出登录',
          onPressed: () => showDialog(
              context: context,
              builder: (_) => LogoutConfirmDialog(
                    onConfirm: () {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已退出登录')),
                      );
                      UserDataSingleton().remove(UserDataSingleton.userInfo);
                      DioClient().refreshToken({});
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const BaseUrlConfigPage(),
                        ),
                      );
                    },
                  )),
        ),
      ),
    );
  }

  Widget _buildListItem(Setting element) {
    if (element.type == SettingType.accountOverview) {
      return HJAccountItem(
        icon: Icons.account_balance_wallet,
        title: element.type.title,
        subtitle: element.detail?.replaceAll('\r\n', '   ') ?? '',
        onTap: () => showDialog(
            context: context,
            builder: (_) => SettingDetailDialog(
                title: element.type.title,
                contentText: element.content,
                detailText: element.detail)),
      );
    }

    return HJValueItem(
      icon: _getIconForType(element.type),
      title: element.type.title,
      valueText: element.content ?? element.detail,
      onTap: () async {
        switch (element.type) {
          case SettingType.currentTheme:
          case SettingType.currentLanguage:
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('功能开发中...')));
            break;
          case SettingType.api:
            showDialog(
                context: context,
                builder: (_) => ApiInfoDialog(apiDetail: element.detail));
            break;
          case SettingType.currentGroup:
          case SettingType.currentBook:
            final items = await _loadGroupOptions(element);
            if (context.mounted) _showSelectionSheet(context, element, items);
            break;
          default:
            showDialog(
                context: context,
                builder: (_) => SettingDetailDialog(
                    title: element.type.title,
                    contentText: element.content,
                    detailText: element.detail));
            break;
        }
      },
    );
  }

  IconData _getIconForType(SettingType type) {
    switch (type) {
      case SettingType.currentGroup:
        return Icons.group_work_outlined;
      case SettingType.currentBook:
        return Icons.book_outlined;
      case SettingType.currentTheme:
        return Icons.color_lens_outlined;
      case SettingType.currentLanguage:
        return Icons.language_outlined;
      case SettingType.api:
        return Icons.api_outlined;
      case SettingType.currentVersion:
        return Icons.info_outline;
      case SettingType.apiVersion:
        return Icons.cloud_outlined;
      default:
        return Icons.settings;
    }
  }

  void _showQRCode(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (_) =>
            DonateQrSheet(onLongPressWechat: () {}, onLongPressAlipay: () {}));
  }

  Future<List<SelectionOption<SettingSelectItem>>> _loadGroupOptions(
      Setting element) async {
    List<SelectionOption<SettingSelectItem>> items = [];
    try {
      if (element.type == SettingType.currentGroup) {
        var res = await GroupService().getEnableList();
        if (res.code == 0) {
          for (final remoteItem in (res.data as List? ?? [])) {
            var name = remoteItem['groupName']?.toString() ?? '';
            items.add(SelectionOption(
                label: name,
                value:
                    SettingSelectItem(name, remoteItem['groupId'] as int? ?? 0),
                selected: name == element.content));
          }
        }
      } else if (element.type == SettingType.currentBook) {
        var res = await BookService()
            .getEnableList(element.data?['groupId'] as int? ?? 0);
        if (res.code == 0) {
          for (final item in (res.data as List? ?? [])) {
            var name = item['bookName']?.toString() ?? '';
            items.add(SelectionOption(
                label: name,
                value: SettingSelectItem(name, item['bookId'] as int? ?? 0),
                selected: name == element.content));
          }
        }
      }
    } catch (e) {
      developer.log("获取选项失败: $e");
    }
    return items;
  }

  void _showSelectionSheet(BuildContext context, Setting element,
      List<SelectionOption<SettingSelectItem>> items) {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('暂无可选项'), behavior: SnackBarBehavior.floating));
      return;
    }
    var settingBloc = context.read<SettingBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return SelectionBottomSheet<SettingSelectItem>(
          title: element.type == SettingType.currentGroup ? '选择分组' : '选择账本',
          options: items,
          onSelected: (option) {
            if (element.type == SettingType.currentGroup)
              settingBloc.add(GroupSettingFetched(groupId: option.value.id));
            else if (element.type == SettingType.currentBook)
              settingBloc
                  .add(BookIdChanged(option.value.id, option.value.title));
          },
        );
      },
    );
  }
}
