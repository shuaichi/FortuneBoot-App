import 'package:fortuneboot/core/network/fx_api.dart';

/// 成员 VO（FortuneMemberVo）——扁平列表，无 can* 开关。
class FortuneMemberVo {
  final int? memberId;
  final String? memberName;
  final int? sort;
  final bool enable;
  final String? remark;

  const FortuneMemberVo({
    this.memberId,
    this.memberName,
    this.sort,
    this.enable = true,
    this.remark,
  });

  factory FortuneMemberVo.fromJson(Map<String, dynamic> json) {
    return FortuneMemberVo(
      memberId: FxApi.asId(json['memberId']),
      memberName: json['memberName']?.toString(),
      sort: FxApi.asId(json['sort']),
      enable: FxApi.asBool(json['enable'], orElse: true),
      remark: json['remark']?.toString(),
    );
  }

  FortuneMemberVo copyWith({bool? enable}) {
    return FortuneMemberVo(
      memberId: memberId,
      memberName: memberName,
      sort: sort,
      enable: enable ?? this.enable,
      remark: remark,
    );
  }
}
