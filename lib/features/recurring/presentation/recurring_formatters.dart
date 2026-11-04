/// 将后端 ISO 时间转换为面向用户的中性日期时间文本。
String formatRecurringExecutionTime(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '-';
  final value = DateTime.tryParse(raw.replaceFirst(' ', 'T'));
  if (value == null) return raw;
  final date =
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
  final time =
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
  return '$date $time';
}
