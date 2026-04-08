import 'package:flutter/material.dart';

class FlutterTodosTheme {
  static ThemeData get light {
    return ThemeData().copyWith(
      appBarTheme: const AppBarTheme(color: Color.fromARGB(255, 117, 208, 247)),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF13B9FF),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        CustomColors(
          transferTextColor: Colors.black,
          incomeTextColor: Colors.red,
          expenseTextColor: Colors.lightGreen,
          adjustTextColor: Colors.black,
          floatingDateColor: Colors.black,
        ), // 亮色主题色
      ],
    );
  }

  static ThemeData get dark {
    return ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(255, 16, 46, 59),
        ),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF13B9FF),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
        extensions: const <ThemeExtension<dynamic>>[
          CustomColors(
            transferTextColor: Colors.white,
            incomeTextColor: Colors.red,
            expenseTextColor: Colors.lightGreen,
            adjustTextColor: Colors.white,
            floatingDateColor: Colors.white,
          ), // 暗色主题色
        ]);
  }
}

// 1. 定义主题扩展类
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color incomeTextColor;
  final Color expenseTextColor;
  final Color transferTextColor;
  final Color adjustTextColor;
  final Color floatingDateColor;

  const CustomColors({
    required this.transferTextColor,
    required this.incomeTextColor,
    required this.expenseTextColor,
    required this.adjustTextColor,
    required this.floatingDateColor,
  });

  @override
  CustomColors copyWith(
      {Color? transferTextColor,
      Color? incomeTextColor,
      Color? expenseTextColor,
      Color? adjustTextColor,
      Color? floatingDateColor}) {
    return CustomColors(
      transferTextColor: transferTextColor ?? this.transferTextColor,
      incomeTextColor: incomeTextColor ?? this.incomeTextColor,
      expenseTextColor: expenseTextColor ?? this.expenseTextColor,
      adjustTextColor: adjustTextColor ?? this.adjustTextColor,
      floatingDateColor: floatingDateColor ?? this.floatingDateColor,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      transferTextColor:
          Color.lerp(transferTextColor, other.transferTextColor, t)!,
      incomeTextColor: Color.lerp(incomeTextColor, other.incomeTextColor, t)!,
      expenseTextColor:
          Color.lerp(expenseTextColor, other.expenseTextColor, t)!,
      adjustTextColor: Color.lerp(adjustTextColor, other.adjustTextColor, t)!,
      floatingDateColor: Color.lerp(floatingDateColor, other.floatingDateColor, t)!
    );
  }
}

// // 3. 使用主题色
// Text(
//   '转账',
//   style: TextStyle(
//     color: Theme.of(context)
//         .extension<CustomColors>()!
//         .transferTextColor, // 动态获取颜色
//   ),
// )
