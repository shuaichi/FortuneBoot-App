import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hjproject/home/setting_page/models/mine_setting.dart';
import 'package:hjproject/login/model/login_model.dart';
import 'package:hjproject/login/model/users.dart';
import 'package:hjproject/request/book_request.dart';
import 'package:hjproject/request/group_request.dart';
import 'package:hjproject/request/include_request.dart';
import 'package:hjproject/request/login_request.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';
import 'package:hjproject/util/dio_client.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stream_transform/stream_transform.dart';

part 'setting_event.dart';
part 'setting_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final LoginService _loginService = LoginService();
  final IncludeService _accountService = IncludeService();
  final GroupService _groupService = GroupService();
  final BookService _bookService = BookService();

  SettingBloc({
    required BillsRepository billsRepository,
  })  : _billsRepository = billsRepository,
        super(const SettingState()) {
    on<SettingInitDataLoaded>(
      _onInitData,
      transformer: throttleDroppable(throttleDuration),
    );
    on<GroupSettingFetched>(
      _onFetchedGroup,
      transformer: throttleDroppable(throttleDuration),
    );
    on<BookIdChanged>(
      _onChangedBookId,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final BillsRepository _billsRepository;

  static int curId = 0;

  Future<void> _onInitData(
    SettingInitDataLoaded event,
    Emitter<SettingState> emit,
  ) async {
    final elements = await _fetchStaticSettings();
    emit(
      state.copyWith(status: SettingStatus.initial, settings: elements),
    );
    var settings = await _fetchStaticSettings();
    var remoteSetting = await _fetchSettings();
    emit(
      state.copyWith(
          status: SettingStatus.success,
          settings: settings,
          remoteSettings: remoteSetting),
    );
  }

  Future<List<Setting>> _fetchStaticSettings() async {
    final user = UserDataSingleton();
    final List<Setting> elements = [];
    final curUser = await user.getMap(UserDataSingleton.userInfo) ?? {};
    final userInfo =
        Map<String, dynamic>.from(curUser['userInfo'] as Map? ?? {});
    final nickName = userInfo['nickname'] as String? ?? '';
    elements.add(Setting(SettingType.username,
        content: nickName,
        leadingWidget: const Icon(Icons.face_retouching_natural)));
    elements.add(const Setting(SettingType.currentTheme,
        content: '跟随系统', leadingWidget: Icon(Icons.dark_mode))); // todo：主题
    final String currentLocale =
        (Intl.defaultLocale ?? 'en') == 'en' ? '🇺🇸 English' : '🇨🇳 简体中文';
    elements.add(Setting(SettingType.currentLanguage,
        content: currentLocale, leadingWidget: Icon(Icons.translate)));
    elements.add(Setting(SettingType.api,
        detail: DioClient().dio.options.baseUrl,
        leadingWidget: const Icon(Icons.edit_note)));
    elements.add(Setting(SettingType.currentVersion,
        content: await getBuildVersion(), leadingWidget: Icon(Icons.abc)));
    return elements;
  }

  Future<String> getBuildVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version}(${packageInfo.buildNumber})'; // 格式与 pubspec.yaml 的 version 一致[3,4](@ref)
  }

  Future<void> _onFetchedGroup(
    GroupSettingFetched event,
    Emitter<SettingState> emit,
  ) async {
    developer.log('🔄 开始获取分组设置 - GroupId: ${event.groupId}', name: 'SettingBloc');
    var curSetting = state.settings;
    try {
      developer.log('📡 调用 _fetchGroupSettings...', name: 'SettingBloc');
      // 并行获取分组设置和新的账户概览信息
      final results = await Future.wait([
        _fetchGroupSettings(event.groupId),
        _fetchSettings(groupId: event.groupId),
      ]);

      final groupSettings = results[0];
      final remoteSettings = results[1];

      developer.log('✅ 设置获取成功 - 分组设置: ${groupSettings.length}, 远程设置: ${remoteSettings.length}', name: 'SettingBloc');
      
      emit(
        state.copyWith(
            status: SettingStatus.success,
            settings: curSetting,
            groupSettings: groupSettings,
            remoteSettings: remoteSettings),
      );
      developer.log('✅ 状态更新完成 - 新状态: ${state.status}', name: 'SettingBloc');
    } catch (error, stackTrace) {
      developer.log('❌ 分组设置获取失败', error: error, stackTrace: stackTrace, name: 'SettingBloc');
      emit(
        state.copyWith(status: SettingStatus.failure, settings: curSetting),
      );
    }
  }

  Future<List<Setting>> _fetchSettings({int? groupId}) async {
    final targetGroupId = groupId ?? _billsRepository.groupId() ?? 1;
    final HJResponse apiResponse = await _loginService.apiVersion();
    final HJResponse accountResponse =
        await _accountService.getFortuneAssetsLiabilities(targetGroupId);
    var settings = <Setting>[];
    if (apiResponse.code == 0) {
      final String apiVersion = apiResponse.data as String? ?? '';
      settings.add(
        Setting(
          SettingType.apiVersion,
          content: apiVersion,
          leadingWidget: const Icon(Icons.cloud_queue),
        ),
      );
    }
    if (accountResponse.code == 0) {
      final Map<String, dynamic> accountData =
          Map<String, dynamic>.from(accountResponse.data as Map? ?? {});
      final double totalAssets = accountData['totalAssets'] as double? ?? 0.0;
      final double totalLiabilities =
          accountData['totalLiabilities'] as double? ?? 0.0;
      settings.add(
        Setting(
          SettingType.accountOverview,
          // \r\n净资产：$netAssets
          detail: '资产：$totalAssets\r\n负债：$totalLiabilities',
          leadingWidget: const Icon(Icons.paid),
        ),
      );
    }
    return settings;
  }

  // 查询分组 & 账本设置
  Future<List<Setting>> _fetchGroupSettings(int? groupId) async {
    developer.log('🔍 开始查询分组设置 - 输入GroupId: $groupId', name: 'SettingBloc');
    var settings = <Setting>[];
    int? findGroupId = groupId;
    
    if (findGroupId == null) {
      developer.log('🔍 GroupId为空，查询默认分组...', name: 'SettingBloc');
      try {
        final HJResponse defaultGroupIdResponse = await _groupService.getDefaultGroupId();
        developer.log('📡 默认分组查询响应 - Code: ${defaultGroupIdResponse.code}', name: 'SettingBloc');
        if (defaultGroupIdResponse.code == 0) {
          findGroupId = defaultGroupIdResponse.data as int? ?? 0;
          developer.log('✅ 获取到默认GroupId: $findGroupId', name: 'SettingBloc');
        }
      } catch (error) {
        developer.log('❌ 查询默认分组失败', error: error, name: 'SettingBloc');
      }
    }
    
    if (findGroupId == null) {
      developer.log('⚠️ 无法获取有效的GroupId，返回空设置', name: 'SettingBloc');
      return settings;
    }
    
    try {
      developer.log('📡 查询分组详情 - GroupId: $findGroupId', name: 'SettingBloc');
      final HJResponse accountInfo = await _groupService.getByGroupId(findGroupId);
      developer.log('📡 分组详情响应 - Code: ${accountInfo.code}', name: 'SettingBloc');
      
      if (accountInfo.code == 0) {
        var data = accountInfo.data as Map? ?? {};
        var groupName = data['groupName'] as String? ?? '';
        var defaultBookName = data['defaultBookName'] as String? ?? '默认账本';
        var defaultBookId = data['defaultBookId'] as int? ?? 1;
        
        developer.log('📊 分组数据 - Name: $groupName, BookName: $defaultBookName, BookId: $defaultBookId', name: 'SettingBloc');
        
        settings.add(Setting(SettingType.currentGroup,
            content: groupName,
            leadingWidget: const Icon(Icons.group),
            data: {"groupId": data['groupId'], "bookId": defaultBookId}));
        settings.add(Setting(SettingType.currentBook,
            content: defaultBookName,
            leadingWidget: const Icon(Icons.book_online_outlined),
            data: {"groupId": data['groupId'], "bookId": defaultBookId}));
        
        developer.log('🔄 更新Repository - GroupId: $findGroupId, BookId: $defaultBookId', name: 'SettingBloc');
        try {
          _billsRepository.updateRemoteBill(groupId: findGroupId, bookId: defaultBookId);
          developer.log('✅ Repository更新成功', name: 'SettingBloc');
        } catch (error) {
          developer.log('❌ Repository更新失败', error: error, name: 'SettingBloc');
        }
      } else {
        developer.log('⚠️ 分组详情查询失败 - Code: ${accountInfo.code}', name: 'SettingBloc');
      }
    } catch (error) {
      developer.log('❌ 查询分组详情异常', error: error, name: 'SettingBloc');
    }
    
    developer.log('✅ 分组设置查询完成 - 设置项数量: ${settings.length}', name: 'SettingBloc');
    return settings;
  }

  FutureOr<void> _onChangedBookId(
      BookIdChanged event, Emitter<SettingState> emit) async {
    developer.log('🔄 开始切换账本 - BookId: ${event.bookId}, BookName: ${event.bookName}', name: 'SettingBloc');
    
    try {
      final newGroup = <Setting>[];
      
      developer.log('📊 当前分组设置数量: ${state.groupSettings.length}', name: 'SettingBloc');
      
      // 使用更高效的方式查找和更新设置项
      for (final element in state.groupSettings) {
        if (element.type == SettingType.currentGroup) {
          newGroup.add(element);
          developer.log('✅ 保留分组设置: ${element.content}', name: 'SettingBloc');
        } else if (element.type == SettingType.currentBook) {
          final newBookSetting = Setting(
            SettingType.currentBook,
            content: event.bookName,
            leadingWidget: const Icon(Icons.book_online_outlined),
            data: {
              "groupId": _billsRepository.groupId(),
              "bookId": event.bookId,
            },
          );
          newGroup.add(newBookSetting);
          developer.log('✅ 更新账本设置: ${event.bookName} (ID: ${event.bookId})', name: 'SettingBloc');
        }
      }
      
      developer.log('🔄 更新Repository账本ID...', name: 'SettingBloc');
      try {
        _billsRepository.updateRemoteBill(bookId: event.bookId);
        developer.log('✅ Repository账本ID更新成功', name: 'SettingBloc');
      } catch (error) {
        developer.log('❌ Repository账本ID更新失败', error: error, name: 'SettingBloc');
      }
      
      developer.log('🔄 发射新状态 - 新分组设置数量: ${newGroup.length}', name: 'SettingBloc');
      emit(
        state.copyWith(
          status: SettingStatus.success,
          groupSettings: newGroup,
        ),
      );
      developer.log('✅ 账本切换完成', name: 'SettingBloc');
      
    } catch (error, stackTrace) {
      developer.log('❌ 账本切换异常', error: error, stackTrace: stackTrace, name: 'SettingBloc');
      emit(
        state.copyWith(status: SettingStatus.failure),
      );
    }
  }
}
