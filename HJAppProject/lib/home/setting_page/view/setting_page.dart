import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hjproject/home/setting_page/bloc/setting_bloc.dart';
import 'package:hjproject/home/setting_page/models/mine_setting.dart';
import 'package:hjproject/home/setting_page/models/setting_select_item.dart';
import 'package:hjproject/login/view/base_url_config_page.dart';
import 'package:hjproject/request/book_request.dart';
import 'package:hjproject/request/group_request.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';
import 'package:hjproject/util/image_save_service.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../../generated/l10n.dart';

import 'package:hjproject/home/setting_page/view/profile_page.dart';
import 'package:hjproject/home/setting_page/view/widgets/user_header.dart';
import 'package:hjproject/home/setting_page/view/widgets/book_config_group.dart';
import 'package:hjproject/home/setting_page/view/widgets/additional_options_group.dart';
import 'package:hjproject/home/setting_page/view/widgets/setting_group_card.dart';
import 'package:hjproject/home/setting_page/view/widgets/setting_item_tile.dart';
import 'package:hjproject/home/setting_page/view/widgets/donate_qr_sheet.dart';
import 'package:hjproject/home/setting_page/view/widgets/help_dialog.dart';
import 'package:hjproject/home/setting_page/view/widgets/api_info_dialog.dart';
import 'package:hjproject/home/setting_page/view/widgets/setting_detail_dialog.dart';
import 'package:hjproject/home/setting_page/view/widgets/logout_confirm_dialog.dart';
import 'package:hjproject/home/setting_page/view/widgets/selection_bottom_sheet.dart';
import 'package:hjproject/home/setting_page/utils/setting_filter.dart';
import 'package:hjproject/Home/account_manage/view/account_manage_page.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingBloc(
        billsRepository: context.read<BillsRepository>(),
      )..add(SettingInitDataLoaded()),
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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SettingBloc>().state;
    developer.log('🎨 UI重建 - 状态: ${state.status}, 设置数量: ${state.settings.length}', name: 'SettingPage');
    
    var elements = [
      ...state.settings,
      ...state.remoteSettings,
      ...state.groupSettings
    ];
    Setting.sortList(elements);
    
    // Design Token: Background #FAFAFA
    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        elevation: 0,
        title: Text(
          S.current.mine,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[50], // Seamless blend
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87),
            tooltip: 'Help',
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24), // Spacing
        child: Column(
          children: [
            _buildUserHeader(context, elements),
            const SizedBox(height: 16), // Spacing Rhythm
            _buildSettingsGroups(context, elements),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, List<Setting> elements) {
    final usernameSetting = elements.firstWhere(
      (element) => element.type == SettingType.username,
      orElse: () => const Setting(SettingType.username, content: '未登录用户'),
    );

    final username = usernameSetting.content ?? '未登录用户';

    return MineUserHeader(
      username: username,
      onViewProfile: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ProfilePage(),
          ),
        );
      },
      onShowQRCode: () => _showQRCode(context),
    );
  }

  Widget _buildSettingsGroups(BuildContext context, List<Setting> elements) {
    final groups = SettingFilter.groupSettings(elements);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (groups.hasAccountSettings) ...[
          _buildSettingGroup(context, '账户设置', groups.accountSettings),
          const SizedBox(height: 16),
        ],
        // 账本配置单独作为一组
        _buildBookConfigGroup(context),
        const SizedBox(height: 16),
        if (groups.hasAppSettings) ...[
          _buildSettingGroup(context, '应用设置', groups.appSettings),
          const SizedBox(height: 16),
        ],
        if (groups.hasAboutSettings) ...[
          _buildSettingGroup(context, '关于', groups.aboutSettings),
          const SizedBox(height: 16),
        ],
        _buildAdditionalOptions(context),
      ],
    );
  }

  Widget _buildSettingGroup(
      BuildContext context, String title, List<Setting> settings) {
    return SettingGroupCard(
      title: title,
      children:
          settings.map((setting) => _getSettingItem(context, setting)).toList(),
    );
  }

  Widget _buildBookConfigGroup(BuildContext context) {
    return const BookConfigGroup();
  }

  Widget _getSettingItem(BuildContext context, Setting element) {
    return SettingItemTile(
      element: element,
      onSelectSetting: (setting) {
        _showSelectionDialog(context, setting);
      },
      onTapSetting: (setting) {
        _handleSettingTap(context, setting);
      },
    );
  }

  void _handleSettingTap(BuildContext context, Setting element) {
    switch (element.type) {
      case SettingType.currentTheme:
        emptyPage();
        break;
      case SettingType.currentLanguage:
        emptyPage();
        break;
      case SettingType.api:
        _showApiSettingDialog(context, element);
        break;
      case SettingType.accountOverview:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AccountManagePage(),
          ),
        );
        break;
      default:
        _showSettingDetailDialog(context, element);
        break;
    }
  }

  Widget _buildAdditionalOptions(BuildContext context) {
    return AdditionalOptionsGroup(
      onDonate: () => _showQRCode(context),
      onFeedback: () => emptyPage(),
      onRate: () => emptyPage(),
      onLogout: () => _showLogoutConfirmation(context),
    );
  }

  void emptyPage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('功能开发中...')),
    );
  }

  // FIXED: Changed `currentApiUrl` to `apiDetail`
  void _showApiSettingDialog(BuildContext context, Setting element) {
    showDialog(
      context: context,
      builder: (context) => ApiInfoDialog(
        apiDetail: element.detail ?? '',
      ),
    );
  }

  // FIXED: Changed constructor params to match `SettingDetailDialog`
  void _showSettingDetailDialog(BuildContext context, Setting element) {
    showDialog(
      context: context,
      builder: (context) => SettingDetailDialog(
        title: element.type.title,
        contentText: element.content,
        detailText: element.detail,
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LogoutConfirmDialog(
        onConfirm: () {
           // Logout logic here
           Navigator.of(context).pop();
        },
      ),
    );
  }
  
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const HelpDialog(),
    );
  }

  // FIXED: Changed class name to `DonateQrSheet` and added required callbacks
  void _showQRCode(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DonateQrSheet(
        onLongPressWechat: () => _saveImage(context, 'assets/images/donate_wechat.jpg'),
        onLongPressAlipay: () => _saveImage(context, 'assets/images/donate_alipay.jpg'),
      ),
    );
  }

  // Helper method for saving images
  // FIXED: Updated method call to use `saveAssetImage`
  void _saveImage(BuildContext context, String assetPath) async {
    try {
      await ImageSaveService.saveAssetImage(context, assetPath, 'donate_qrcode');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }

  void _showSelectionDialog(BuildContext context, Setting element) async {
    List<DropdownItem<SettingSelectItem>> items = [];

    if (element.type == SettingType.currentGroup) {
      GroupService groupService = GroupService();
      var res = await groupService.getEnableList();
      if (res.code == 0) {
        var remoteList = res.data as List? ?? [];
        for (final remoteItem in remoteList) {
          var remoteGroupName = remoteItem['groupName'] as String? ?? '';
          bool selected = remoteGroupName == element.content;
          var groupId = remoteItem['groupId'] as int? ?? 0;
          items.add(DropdownItem(
            label: remoteGroupName,
            value: SettingSelectItem(remoteGroupName, groupId),
            selected: selected,
          ));
        }
      }
    } else if (element.type == SettingType.currentBook) {
      final BookService bookService = BookService();
      final remoteBookResponse = await bookService
          .getEnableList(element.data!['groupId'] as int? ?? 0);
      if (remoteBookResponse.code == 0) {
        final remoteBookList = remoteBookResponse.data as List? ?? [];
        for (final remoteBookItem in remoteBookList) {
          final remoteBookName = remoteBookItem['bookName'] as String? ?? '';
          final bool selected = remoteBookName == element.content;
          items.add(
            DropdownItem(
              label: remoteBookName,
              value: SettingSelectItem(
                remoteBookName,
                remoteBookItem['bookId'] as int? ?? 0,
              ),
              selected: selected,
            ),
          );
        }
      }
    }

    if (items.isEmpty) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('暂无可选项'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if(!mounted) return;
    var settingBloc = context.read<SettingBloc>();

    // FIXED: Updated `SelectionBottomSheet` usage to match definition
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SelectionBottomSheet<SettingSelectItem>(
           title: element.type == SettingType.currentGroup ? '选择分组' : '选择账本',
           // Map DropdownItem to SelectionOption
           options: items.map((item) => SelectionOption<SettingSelectItem>(
              label: item.label,
              value: item.value,
              selected: item.selected,
           )).toList(),
           onSelected: (option) {
             if (element.type == SettingType.currentGroup) {
               // FIXED: Correct Event
               settingBloc.add(GroupSettingFetched(groupId: option.value.id));
             } else if (element.type == SettingType.currentBook) {
               // FIXED: Correct Event
               settingBloc.add(BookIdChanged(option.value.id, option.value.title));
             }
             // Navigator.pop handled by SelectionBottomSheet internally if successful, 
             // but safe to do nothing here or let BLoC handle logic
           },
        );
      },
    );
  }
}