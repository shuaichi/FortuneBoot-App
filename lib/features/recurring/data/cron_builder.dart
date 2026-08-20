/// 周期记账 cron 表达式引擎。
///
/// 后端使用 Spring 6 段 cron：`秒 分 时 日 月 周`。本引擎把用户在下拉框中选择的
/// 频率规则映射成 cron 字符串，并可反向把常见 cron 解析回可视化选择，供高级用户
/// 手写与可视化两种模式互转。无法解析的表达式回退为「自定义」模式。
library;

/// 频率类型。
enum CronFrequency { daily, weekly, monthly, yearly }

/// 周几（Spring cron 使用 MON-SUN 名称，最直观且不受 0/7 歧义影响）。
enum CronWeekday { mon, tue, wed, thu, fri, sat, sun }

extension CronWeekdayX on CronWeekday {
  /// Spring cron 字段用的英文缩写（大写）。
  String get token => switch (this) {
    CronWeekday.mon => 'MON',
    CronWeekday.tue => 'TUE',
    CronWeekday.wed => 'WED',
    CronWeekday.thu => 'THU',
    CronWeekday.fri => 'FRI',
    CronWeekday.sat => 'SAT',
    CronWeekday.sun => 'SUN',
  };

  /// ISO 序号（周一=1 … 周日=7），用于稳定排序。
  int get isoIndex => index + 1;
}

/// 可视化 cron 规格。[frequency] + 时分 + 频率相关的日期字段。
class CronSpec {
  final CronFrequency frequency;
  final int hour; // 0-23
  final int minute; // 0-59

  /// 每周：选中的星期集合（weekly 生效）。
  final Set<CronWeekday> weekdays;

  /// 每月/每年：几号（1-31，monthly/yearly 生效）。
  final int dayOfMonth;

  /// 每月/每年：是否使用 Spring cron 的 L（月末）语义。
  final bool lastDayOfMonth;

  /// 每年：几月（1-12，yearly 生效）。
  final int month;

  const CronSpec({
    this.frequency = CronFrequency.daily,
    this.hour = 9,
    this.minute = 0,
    this.weekdays = const {CronWeekday.mon},
    this.dayOfMonth = 1,
    this.lastDayOfMonth = false,
    this.month = 1,
  });

  CronSpec copyWith({
    CronFrequency? frequency,
    int? hour,
    int? minute,
    Set<CronWeekday>? weekdays,
    int? dayOfMonth,
    bool? lastDayOfMonth,
    int? month,
  }) {
    return CronSpec(
      frequency: frequency ?? this.frequency,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      weekdays: weekdays ?? this.weekdays,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      lastDayOfMonth: lastDayOfMonth ?? this.lastDayOfMonth,
      month: month ?? this.month,
    );
  }
}

/// cron 构造 / 解析引擎（纯逻辑，无 Flutter 依赖）。
abstract final class CronBuilder {
  const CronBuilder._();

  /// 由可视化规格构造 Spring 6 段 cron。
  static String build(CronSpec spec) {
    const s = '0';
    final m = '${spec.minute}';
    final h = '${spec.hour}';
    switch (spec.frequency) {
      case CronFrequency.daily:
        return '$s $m $h * * ?';
      case CronFrequency.weekly:
        final days =
            (spec.weekdays.isEmpty ? {CronWeekday.mon} : spec.weekdays).toList()
              ..sort((a, b) => a.isoIndex.compareTo(b.isoIndex));
        final dow = days.map((d) => d.token).join(',');
        return '$s $m $h ? * $dow';
      case CronFrequency.monthly:
        final dom = spec.lastDayOfMonth ? 'L' : '${_clampDom(spec.dayOfMonth)}';
        return '$s $m $h $dom * ?';
      case CronFrequency.yearly:
        final dom = spec.lastDayOfMonth ? 'L' : '${_clampDom(spec.dayOfMonth)}';
        return '$s $m $h $dom ${_clampMonth(spec.month)} ?';
    }
  }

  /// 尝试把 cron 反解析成可视化规格；无法识别返回 null（→ 走自定义模式）。
  static CronSpec? tryParse(String? expression) {
    if (expression == null) return null;
    final parts = expression.trim().split(RegExp(r'\s+'));
    if (parts.length != 6) return null;
    final sec = parts[0];
    final min = int.tryParse(parts[1]);
    final hour = int.tryParse(parts[2]);
    final dom = parts[3];
    final mon = parts[4];
    final dow = parts[5];
    // 仅支持固定秒（0）、固定分/时的常见调度。
    if (sec != '0' || min == null || hour == null) return null;
    if (min < 0 || min > 59 || hour < 0 || hour > 23) return null;

    // 每天：日/月通配，周通配。
    if (_isWild(dom) && _isWild(mon) && _isWild(dow)) {
      return CronSpec(frequency: CronFrequency.daily, hour: hour, minute: min);
    }
    // 每周：日通配、月通配、周为具体星期集合。
    if (_isWild(dom) && _isWild(mon) && !_isWild(dow)) {
      final days = _parseWeekdays(dow);
      if (days == null || days.isEmpty) return null;
      return CronSpec(
        frequency: CronFrequency.weekly,
        hour: hour,
        minute: min,
        weekdays: days,
      );
    }
    final lastDayOfMonth = dom.toUpperCase() == 'L';
    final domValue = lastDayOfMonth ? 31 : int.tryParse(dom);
    if (domValue == null || domValue < 1 || domValue > 31) return null;
    // 每月：具体日/月末、月通配、周通配。
    if (_isWild(mon) && _isWild(dow)) {
      return CronSpec(
        frequency: CronFrequency.monthly,
        hour: hour,
        minute: min,
        dayOfMonth: domValue,
        lastDayOfMonth: lastDayOfMonth,
      );
    }
    // 每年：具体日/月末 + 具体月、周通配。
    final monValue = int.tryParse(mon);
    if (monValue != null && monValue >= 1 && monValue <= 12 && _isWild(dow)) {
      return CronSpec(
        frequency: CronFrequency.yearly,
        hour: hour,
        minute: min,
        dayOfMonth: domValue,
        lastDayOfMonth: lastDayOfMonth,
        month: monValue,
      );
    }
    return null;
  }

  static bool _isWild(String field) => field == '*' || field == '?';

  static Set<CronWeekday>? _parseWeekdays(String field) {
    const tokenMap = {
      'MON': CronWeekday.mon,
      'TUE': CronWeekday.tue,
      'WED': CronWeekday.wed,
      'THU': CronWeekday.thu,
      'FRI': CronWeekday.fri,
      'SAT': CronWeekday.sat,
      'SUN': CronWeekday.sun,
    };
    // Spring 数字：0/7=SUN，1=MON … 6=SAT。
    const numMap = {
      0: CronWeekday.sun,
      1: CronWeekday.mon,
      2: CronWeekday.tue,
      3: CronWeekday.wed,
      4: CronWeekday.thu,
      5: CronWeekday.fri,
      6: CronWeekday.sat,
      7: CronWeekday.sun,
    };
    final result = <CronWeekday>{};
    for (final raw in field.split(',')) {
      final token = raw.trim().toUpperCase();
      if (token.isEmpty) continue;
      final byName = tokenMap[token];
      if (byName != null) {
        result.add(byName);
        continue;
      }
      final num = int.tryParse(token);
      final byNum = num == null ? null : numMap[num];
      if (byNum == null) return null;
      result.add(byNum);
    }
    return result;
  }

  static int _clampDom(int d) => d < 1 ? 1 : (d > 31 ? 31 : d);

  static int _clampMonth(int m) => m < 1 ? 1 : (m > 12 ? 12 : m);
}
