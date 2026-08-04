import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/profile/data/profile_models.dart';
import 'package:fortuneboot/features/profile/data/profile_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// 个人中心 Bloc：加载用户资料 + 应用信息。
///
/// 资料失败整页兜底；应用信息（版本/API/ICP）失败静默降级，不阻塞用户卡。
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService _service;

  ProfileBloc({ProfileService? service})
      : _service = service ?? ProfileService(),
        super(const ProfileState()) {
    on<ProfileLoaded>(_onLoaded);
    on<ProfileUserRefreshed>(_onUserRefreshed);
  }

  Future<void> _onLoaded(
    ProfileLoaded event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await _service.getProfile();
      emit(state.copyWith(status: ProfileStatus.ready, profile: profile));
    } on FxApiException catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, errorMessage: e.message));
    } on Object catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
    // 应用信息独立拉取，失败不影响资料展示。
    await _loadAbout(emit);
  }

  /// 编辑资料/头像成功后回来只刷新用户卡，不动整页状态。
  Future<void> _onUserRefreshed(
    ProfileUserRefreshed event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final profile = await _service.getProfile();
      emit(state.copyWith(status: ProfileStatus.ready, profile: profile));
    } on Object {
      // 静默：保留旧资料。
    }
  }

  Future<void> _loadAbout(Emitter<ProfileState> emit) async {
    var appVersion = '';
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion = info.version;
    } on Object {
      appVersion = '';
    }

    String? apiVersion;
    String? icp;
    try {
      apiVersion = await _service.getApiVersion();
    } on Object {
      apiVersion = null;
    }
    try {
      icp = await _service.getIcp();
    } on Object {
      icp = null;
    }

    emit(state.copyWith(
      about: AppAbout(
        appVersion: appVersion,
        apiVersion: apiVersion,
        icp: icp,
      ),
    ));
  }
}
