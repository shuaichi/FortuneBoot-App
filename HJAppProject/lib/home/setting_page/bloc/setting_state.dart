part of 'setting_bloc.dart';

enum SettingStatus { initial, success, failure }

final class SettingState extends Equatable {
  const SettingState({
    this.status = SettingStatus.initial,
    this.remoteSettings = const <Setting>[],
    this.groupSettings = const <Setting>[],
    this.settings = const <Setting>[],
  });

  final SettingStatus status;
  final List<Setting> settings;
  final List<Setting> remoteSettings;
  final List<Setting> groupSettings;

  SettingState copyWith({
    SettingStatus? status,
    List<Setting>? settings,
    List<Setting>? remoteSettings,
    List<Setting>? groupSettings,
  }) {
    return SettingState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      remoteSettings: remoteSettings ?? this.remoteSettings,
      groupSettings: groupSettings ?? this.groupSettings,
    );
  }

  @override
  List<Object> get props => [status, settings, remoteSettings, groupSettings];
}